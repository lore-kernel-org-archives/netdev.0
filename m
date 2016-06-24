From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 08/15] drivers: net: davinci_mdio: drop suspended and lock fields from mdio_data
Date: Fri, 24 Jun 2016 21:23:48 +0300
Message-ID: <20160624182355.23515-9-grygorii.strashko@ti.com>
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

It's not expected Davinci MDIO to be accessible after its suspend
callbacks have been called:
 - all consumers of Davinci MDIO will stop/disconnect phys at Device
suspend stage;
 - all phys are expected to be suspned already by PHY/MDIO core;
 - MDIO locking is done by MDIO Bus code.

Hence, it's safe to drop "suspended" and "lock" fields from mdio_data.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 30 ------------------------------
 1 file changed, 30 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 291c42e..b6d0059 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -90,11 +90,9 @@ static const struct mdio_platform_data default_pdata = {
 struct davinci_mdio_data {
 	struct mdio_platform_data pdata;
 	struct davinci_mdio_regs __iomem *regs;
-	spinlock_t	lock;
 	struct clk	*clk;
 	struct device	*dev;
 	struct mii_bus	*bus;
-	bool		suspended;
 	unsigned long	access_time; /* jiffies */
 	/* Indicates that driver shouldn't modify phy_mask in case
 	 * if MDIO bus is registered from DT.
@@ -225,13 +223,6 @@ static int davinci_mdio_read(struct mii_bus *bus, int phy_id, int phy_reg)
 	if (phy_reg & ~PHY_REG_MASK || phy_id & ~PHY_ID_MASK)
 		return -EINVAL;
 
-	spin_lock(&data->lock);
-
-	if (data->suspended) {
-		spin_unlock(&data->lock);
-		return -ENODEV;
-	}
-
 	reg = (USERACCESS_GO | USERACCESS_READ | (phy_reg << 21) |
 	       (phy_id << 16));
 
@@ -255,8 +246,6 @@ static int davinci_mdio_read(struct mii_bus *bus, int phy_id, int phy_reg)
 		break;
 	}
 
-	spin_unlock(&data->lock);
-
 	return ret;
 }
 
@@ -270,13 +259,6 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 	if (phy_reg & ~PHY_REG_MASK || phy_id & ~PHY_ID_MASK)
 		return -EINVAL;
 
-	spin_lock(&data->lock);
-
-	if (data->suspended) {
-		spin_unlock(&data->lock);
-		return -ENODEV;
-	}
-
 	reg = (USERACCESS_GO | USERACCESS_WRITE | (phy_reg << 21) |
 		   (phy_id << 16) | (phy_data & USERACCESS_DATA));
 
@@ -295,8 +277,6 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 		break;
 	}
 
-	spin_unlock(&data->lock);
-
 	return 0;
 }
 
@@ -364,7 +344,6 @@ static int davinci_mdio_probe(struct platform_device *pdev)
 
 	dev_set_drvdata(dev, data);
 	data->dev = dev;
-	spin_lock_init(&data->lock);
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	data->regs = devm_ioremap_resource(dev, res);
@@ -426,17 +405,12 @@ static int davinci_mdio_suspend(struct device *dev)
 	struct davinci_mdio_data *data = dev_get_drvdata(dev);
 	u32 ctrl;
 
-	spin_lock(&data->lock);
-
 	/* shutdown the scan state machine */
 	ctrl = __raw_readl(&data->regs->control);
 	ctrl &= ~CONTROL_ENABLE;
 	__raw_writel(ctrl, &data->regs->control);
 	wait_for_idle(data);
 
-	data->suspended = true;
-	spin_unlock(&data->lock);
-
 	/* Select sleep pin state */
 	pinctrl_pm_select_sleep_state(dev);
 
@@ -450,13 +424,9 @@ static int davinci_mdio_resume(struct device *dev)
 	/* Select default pin state */
 	pinctrl_pm_select_default_state(dev);
 
-	spin_lock(&data->lock);
 	/* restart the scan state machine */
 	__davinci_mdio_reset(data);
 
-	data->suspended = false;
-	spin_unlock(&data->lock);
-
 	return 0;
 }
 #endif
-- 
2.9.0
