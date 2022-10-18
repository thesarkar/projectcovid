Use PortfolioProject
Select * 
from PortfolioProject..CovidDeaths
order by 3,4

--Select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4

--Selecting data to work with

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying from COVID in India
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--Highest Infection rate compare to population
Select location,population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location,population
order by PercentPopulationInfected desc

--Highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--using cast function because total_death column is of nvarchar data type hence the results are inaccurate
From PortfolioProject..CovidDeaths
Group by location
order by TotalDeathCount desc

--Continent wise
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--using cast function because total_death column is of nvarchar data type hence the results are inaccurate
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

---the total death count is only showing for USA and not for other regions 


Select population, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where location like '%United States%'
Group by population
order by TotalDeathCount desc

--the death count is same for North America continent and USA

Select location, Max(cast(total_deaths as int)) as totaldeathcount
From PortfolioProject..CovidDeaths
where continent is Null
group by location
order by totaldeathcount desc

--Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at total populations vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- with Common table expression (CTE)
with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeoplVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeoplVaccinated/population)*100 as Percentage from PopvsVac

--Temp Table
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric, 
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as Percentage
From #PercentPopulationVaccinated 

-- Creating View  to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as  
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select * from PercentPopulationVaccinated