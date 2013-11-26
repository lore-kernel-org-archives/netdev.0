From: <shh.xie@gmail.com>
Subject: [PATCH 3/5][v2] phylib: Add generic 10G driver
Date: Tue, 26 Nov 2013 17:54:35 +0800
Message-ID: <1385459675-30364-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Emilian.Medve@freescale.com>, <madalin.bucur@freescale.com>
To: <davem@davemloft.net>, <jg1.han@samsung.com>,
	<mugunthanvnm@ti.com>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Fleming <afleming@freescale.com>

Very incomplete, but will allow for binding an ethernet controller
to it.

Signed-off-by: Andy Fleming <afleming@freescale.com>
Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
v2: turn genphy_driver to an array, add generic 10g driver to it.

 drivers/net/phy/phy_device.c | 96 ++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 89 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index d6447b3..96a5e03 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -32,6 +32,7 @@
 #include <linux/module.h>
 #include <linux/mii.h>
 #include <linux/ethtool.h>
+#include <linux/mdio.h>
 #include <linux/phy.h>
 
 #include <asm/io.h>
@@ -53,7 +54,7 @@ static void phy_device_release(struct device *dev)
 	kfree(to_phy_device(dev));
 }
 
-static struct phy_driver genphy_driver;
+static struct phy_driver genphy_driver[2];
 extern int mdio_bus_init(void);
 extern void mdio_bus_exit(void);
 
@@ -539,7 +540,7 @@ static int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 			return -ENODEV;
 		}
 
-		d->driver = &genphy_driver.driver;
+		d->driver = &genphy_driver[0].driver;
 
 		err = d->driver->probe(d);
 		if (err >= 0)
@@ -620,7 +621,7 @@ void phy_detach(struct phy_device *phydev)
 	 * was using the generic driver), we unbind the device
 	 * from the generic driver so that there's a chance a
 	 * real driver could be loaded */
-	if (phydev->dev.driver == &genphy_driver.driver)
+	if (phydev->dev.driver == &genphy_driver[0].driver)
 		device_release_driver(&phydev->dev);
 }
 EXPORT_SYMBOL(phy_detach);
@@ -689,6 +690,12 @@ static int genphy_config_advert(struct phy_device *phydev)
 	return changed;
 }
 
+int gen10g_config_advert(struct phy_device *dev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_config_advert);
+
 /**
  * genphy_setup_forced - configures/forces speed/duplex from @phydev
  * @phydev: target phy_device struct
@@ -742,6 +749,11 @@ int genphy_restart_aneg(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_restart_aneg);
 
+int gen10g_restart_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_restart_aneg);
 
 /**
  * genphy_config_aneg - restart auto-negotiation or write BMCR
@@ -784,6 +796,12 @@ int genphy_config_aneg(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_config_aneg);
 
+int gen10g_config_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_config_aneg);
+
 /**
  * genphy_update_link - update link status in @phydev
  * @phydev: target phy_device struct
@@ -913,6 +931,34 @@ int genphy_read_status(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_read_status);
 
+int gen10g_read_status(struct phy_device *phydev)
+{
+	int devad, reg;
+	u32 mmd_mask = phydev->c45_ids.devices_in_package;
+
+	phydev->link = 1;
+
+	/* For now just lie and say it's 10G all the time */
+	phydev->speed = SPEED_10000;
+	phydev->duplex = DUPLEX_FULL;
+
+	for (devad = 0; mmd_mask; devad++, mmd_mask = mmd_mask >> 1) {
+		if (!(mmd_mask & 1))
+			continue;
+
+		/* Read twice because link state is latched and a
+		 * read moves the current state into the register
+		 */
+		phy_read_mmd(phydev, devad, MDIO_STAT1);
+		reg = phy_read_mmd(phydev, devad, MDIO_STAT1);
+		if (reg < 0 || !(reg & MDIO_STAT1_LSTATUS))
+			phydev->link = 0;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_read_status);
+
 static int genphy_config_init(struct phy_device *phydev)
 {
 	int val;
@@ -959,6 +1005,16 @@ static int genphy_config_init(struct phy_device *phydev)
 
 	return 0;
 }
+
+static int gen10g_config_init(struct phy_device *phydev)
+{
+	/* Temporarily just say we support everything */
+	phydev->supported = SUPPORTED_10000baseT_Full;
+	phydev->advertising = SUPPORTED_10000baseT_Full;
+
+	return 0;
+}
+
 int genphy_suspend(struct phy_device *phydev)
 {
 	int value;
@@ -974,6 +1030,12 @@ int genphy_suspend(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_suspend);
 
+int gen10g_suspend(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_suspend);
+
 int genphy_resume(struct phy_device *phydev)
 {
 	int value;
@@ -989,6 +1051,12 @@ int genphy_resume(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_resume);
 
+int gen10g_resume(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_resume);
+
 /**
  * phy_probe - probe and init a PHY device
  * @dev: device to probe and init
@@ -1116,7 +1184,8 @@ void phy_drivers_unregister(struct phy_driver *drv, int n)
 }
 EXPORT_SYMBOL(phy_drivers_unregister);
 
-static struct phy_driver genphy_driver = {
+static struct phy_driver genphy_driver[] = {
+{
 	.phy_id		= 0xffffffff,
 	.phy_id_mask	= 0xffffffff,
 	.name		= "Generic PHY",
@@ -1127,7 +1196,18 @@ static struct phy_driver genphy_driver = {
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
 	.driver		= {.owner= THIS_MODULE, },
-};
+}, {
+	.phy_id         = 0xffffffff,
+	.phy_id_mask    = 0xffffffff,
+	.name           = "Generic 10G PHY",
+	.config_init    = gen10g_config_init,
+	.features       = 0,
+	.config_aneg    = gen10g_config_aneg,
+	.read_status    = gen10g_read_status,
+	.suspend        = gen10g_suspend,
+	.resume         = gen10g_resume,
+	.driver         = {.owner = THIS_MODULE, },
+} };
 
 static int __init phy_init(void)
 {
@@ -1137,7 +1217,8 @@ static int __init phy_init(void)
 	if (rc)
 		return rc;
 
-	rc = phy_driver_register(&genphy_driver);
+	rc = phy_drivers_register(genphy_driver,
+				  ARRAY_SIZE(genphy_driver));
 	if (rc)
 		mdio_bus_exit();
 
@@ -1146,7 +1227,8 @@ static int __init phy_init(void)
 
 static void __exit phy_exit(void)
 {
-	phy_driver_unregister(&genphy_driver);
+	phy_drivers_unregister(genphy_driver,
+			       ARRAY_SIZE(genphy_driver));
 	mdio_bus_exit();
 }
 
-- 
1.8.4.1
