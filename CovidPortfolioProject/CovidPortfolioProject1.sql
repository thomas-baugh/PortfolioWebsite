Select location
From PortfolioProject..CovidDeaths$
WHERE location not like '%income%'
Group by location
Order by location

--Select *
--From PortfolioProject..CovidVaccinations$
--Order by 3,4


Select Location,date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
Order by 1,2


--Looking at Total Cases vs Total Deaths

Select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
WHERE location like '%states%'
Order by 5 DESC


--Look at Total Cases vs Population

Select Location,date, total_cases, population, (total_cases/population)*100 as CasePopulation
From PortfolioProject..CovidDeaths$
WHERE location like '%states%'
Order by 5 DESC

--What countries have the highest infection rates compared to population

Select Location,Population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population) as InfectionRate
From PortfolioProject..CovidDeaths$
Group by Location,Population 
Order by InfectionRate DESC

--Countries with the Highest Death Count Per Population
Select Location,Population, MAX(cast(total_deaths as INT)) as HighestDeathCount, (MAX(Cast(total_deaths as INT))/population)*100 as DeathRate
From PortfolioProject..CovidDeaths$
WHERE Continent is not null
Group by Location,Population 
Order by DeathRate DESC

--Country with highest Total Death Count
Select Location,Population, MAX(cast(total_deaths as INT)) as HighestDeathCount, (MAX(Cast(total_deaths as INT))/population)*100 as DeathRate
From PortfolioProject..CovidDeaths$
WHERE Continent is not null
Group by Location,Population 
Order by HighestDeathCount DESC

--Total Death Count By Continent
Select location, MAX(Cast(total_deaths as INT)) as HighestDeathCount
From PortfolioProject..CovidDeaths$
WHERE Continent is null and location not like '%income%'
Group by Location
Order by HighestDeathCount DESC

--Death Rate Daily Global
Select date, SUM(new_cases), SUM(Cast(new_deaths as INT)), SUM(Cast(new_deaths as INT))/SUM(new_cases)*100
FROM PortfolioProject..CovidDeaths$
WHERE new_cases!=0
Group by date
Order by date

--Death Rate Global
Select SUM(new_cases) as TotalCases, SUM(Cast(new_deaths as INT)) as TotalDeaths, SUM(Cast(new_deaths as INT))/SUM(new_cases)*100
FROM PortfolioProject..CovidDeaths$


--Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$ dea
	ON vac.location = dea.location and vac.date = dea.date
WHERE dea.continent is not null and vac.new_vaccinations is not null and dea.location not like '%income%'
Order by 2,3

-- USE CTE
With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$ dea
	ON vac.location = dea.location and vac.date = dea.date
WHERE dea.continent is not null and vac.new_vaccinations is not null and dea.location not like '%income%'
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Creating View to data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as bigINT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidVaccinations$ vac
JOIN PortfolioProject..CovidDeaths$ dea
	ON vac.location = dea.location and vac.date = dea.date
WHERE dea.continent is not null and vac.new_vaccinations is not null and dea.location not like '%income%'

Select * 
From PercentPopulationVaccinated