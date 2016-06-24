From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 11/15] drivers: net: davinci_mdio: implement pm runtime auto mode
Date: Fri, 24 Jun 2016 21:23:51 +0300
Message-ID: <20160624182355.23515-12-grygorii.strashko@ti.com>
References: <20160624182355.23515-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160624182355.23515-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Davinci MDIO is always used as slave device which services
read/write requests from MDIO/PHY core. It doesn't use IRQ also.

As result, It's possible to relax PM runtime constraints for Davinci
MDIO and enable it on demand, instead of powering it during probe
and powering off during removal.

Hence, implement PM runtime autosuspend for Davinci MDIO, but keep it
disabled by default, because Davinci MDIO is integrated in big set of
TI devices and not all of them expected to work corectly with RPM
 autosuspend enabled:
- expected to work on SoCs where MDIO is part of TI CPSW
(cpsw.c DRA7/am57x, am437x, am335x, dm814x)
- not verified on Keystone 2 and other SoCs where MDIO is used with TI EMAC IP
(davinci_emac.c:  dm6467-emac, am3517-emac, dm816-emac).

Davinci MDIO RPM autosuspend can be enabled through sysfs:
 echo 100 > /sys/devices/../48484000.ethernet/48485000.mdio/power/autosuspend_delay_ms

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 48 +++++++++++++++++++++++++++-------
 1 file changed, 39 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 13f5080..ce3ec42 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -93,6 +93,7 @@ struct davinci_mdio_data {
 	struct clk	*clk;
 	struct device	*dev;
 	struct mii_bus	*bus;
+	bool            active_in_suspend;
 	unsigned long	access_time; /* jiffies */
 	/* Indicates that driver shouldn't modify phy_mask in case
 	 * if MDIO bus is registered from DT.
@@ -141,8 +142,13 @@ static int davinci_mdio_reset(struct mii_bus *bus)
 {
 	struct davinci_mdio_data *data = bus->priv;
 	u32 phy_mask, ver;
+	int ret;
 
-	davinci_mdio_enable(data);
+	ret = pm_runtime_get_sync(data->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(data->dev);
+		return ret;
+	}
 
 	/* wait for scan logic to settle */
 	msleep(PHY_MAX_ADDR * data->access_time);
@@ -153,7 +159,7 @@ static int davinci_mdio_reset(struct mii_bus *bus)
 		 (ver >> 8) & 0xff, ver & 0xff);
 
 	if (data->skip_scan)
-		return 0;
+		goto done;
 
 	/* get phy mask from the alive register */
 	phy_mask = __raw_readl(&data->regs->alive);
@@ -168,6 +174,10 @@ static int davinci_mdio_reset(struct mii_bus *bus)
 	}
 	data->bus->phy_mask = phy_mask;
 
+done:
+	pm_runtime_mark_last_busy(data->dev);
+	pm_runtime_put_autosuspend(data->dev);
+
 	return 0;
 }
 
@@ -228,6 +238,12 @@ static int davinci_mdio_read(struct mii_bus *bus, int phy_id, int phy_reg)
 	if (phy_reg & ~PHY_REG_MASK || phy_id & ~PHY_ID_MASK)
 		return -EINVAL;
 
+	ret = pm_runtime_get_sync(data->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(data->dev);
+		return ret;
+	}
+
 	reg = (USERACCESS_GO | USERACCESS_READ | (phy_reg << 21) |
 	       (phy_id << 16));
 
@@ -251,6 +267,8 @@ static int davinci_mdio_read(struct mii_bus *bus, int phy_id, int phy_reg)
 		break;
 	}
 
+	pm_runtime_mark_last_busy(data->dev);
+	pm_runtime_put_autosuspend(data->dev);
 	return ret;
 }
 
@@ -264,6 +282,12 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 	if (phy_reg & ~PHY_REG_MASK || phy_id & ~PHY_ID_MASK)
 		return -EINVAL;
 
+	ret = pm_runtime_get_sync(data->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(data->dev);
+		return ret;
+	}
+
 	reg = (USERACCESS_GO | USERACCESS_WRITE | (phy_reg << 21) |
 		   (phy_id << 16) | (phy_data & USERACCESS_DATA));
 
@@ -282,7 +306,10 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 		break;
 	}
 
-	return 0;
+	pm_runtime_mark_last_busy(data->dev);
+	pm_runtime_put_autosuspend(data->dev);
+
+	return ret;
 }
 
 #if IS_ENABLED(CONFIG_OF)
@@ -357,8 +384,9 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 
 	davinci_mdio_init_clk(data);
 
+	pm_runtime_set_autosuspend_delay(&pdev->dev, -1);
+	pm_runtime_use_autosuspend(&pdev->dev);
 	pm_runtime_enable(&pdev->dev);
-	pm_runtime_get_sync(&pdev->dev);
 
 	/* register the mii bus
 	 * Create PHYs from DT only in case if PHY child nodes are explicitly
@@ -387,9 +415,8 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 	return 0;
 
 bail_out:
-	pm_runtime_put_sync(&pdev->dev);
+	pm_runtime_dont_use_autosuspend(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
-
 	return ret;
 }
 
@@ -400,7 +427,7 @@ static int davinci_mdio_remove(struct platform_device *pdev)
 	if (data->bus)
 		mdiobus_unregister(data->bus);
 
-	pm_runtime_put_sync(&pdev->dev);
+	pm_runtime_dont_use_autosuspend(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 
 	return 0;
@@ -436,7 +463,9 @@ static int davinci_mdio_suspend(struct device *dev)
 	struct davinci_mdio_data *data = dev_get_drvdata(dev);
 	int ret = 0;
 
-	ret = pm_runtime_force_suspend(dev);
+	data->active_in_suspend = !pm_runtime_status_suspended(dev);
+	if (data->active_in_suspend)
+		ret = pm_runtime_force_suspend(dev);
 	if (ret < 0)
 		return ret;
 
@@ -453,7 +482,8 @@ static int davinci_mdio_resume(struct device *dev)
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(dev);
 
-	pm_runtime_force_resume(dev);
+	if (data->active_in_suspend)
+		pm_runtime_force_resume(dev);
 
 	return 0;
 }
-- 
2.9.0
