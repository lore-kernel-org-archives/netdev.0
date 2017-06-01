From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH 3/5] net: phy: split out 10G genphy support
Date: Thu, 01 Jun 2017 11:26:41 +0100
Message-ID: <E1dGNJR-00043n-ON@rmk-PC.armlinux.org.uk>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:53054 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751519AbdFAK04 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 06:26:56 -0400
In-Reply-To: <20170601102327.GF27796@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the old 10G genphy support to sit beside the new clause 45 library
functions, so all the 10G phy code is together.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy-c45.c    |  64 ++++++++++++++++++++++++++
 drivers/net/phy/phy_device.c | 105 ++++++++-----------------------------------
 2 files changed, 83 insertions(+), 86 deletions(-)

diff --git a/drivers/net/phy/phy-c45.c b/drivers/net/phy/phy-c45.c
index 252e49864215..ed77b1cb61de 100644
--- a/drivers/net/phy/phy-c45.c
+++ b/drivers/net/phy/phy-c45.c
@@ -229,3 +229,67 @@ int genphy_c45_read_pma(struct phy_device *phydev)
 	return 0;
 }
 EXPORT_SYMBOL_GPL(genphy_c45_read_pma);
+
+/* The gen10g_* functions are the old Clause 45 stub */
+
+static int gen10g_config_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+
+static int gen10g_read_status(struct phy_device *phydev)
+{
+	u32 mmd_mask = phydev->c45_ids.devices_in_package;
+	int ret;
+
+	/* For now just lie and say it's 10G all the time */
+	phydev->speed = SPEED_10000;
+	phydev->duplex = DUPLEX_FULL;
+
+	/* Avoid reading the vendor MMDs */
+	mmd_mask &= ~(BIT(MDIO_MMD_VEND1) | BIT(MDIO_MMD_VEND2));
+
+	ret = genphy_c45_read_link(phydev, mmd_mask);
+
+	phydev->link = ret > 0 ? 1 : 0;
+
+	return 0;
+}
+
+static int gen10g_soft_reset(struct phy_device *phydev)
+{
+	/* Do nothing for now */
+	return 0;
+}
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
+static int gen10g_suspend(struct phy_device *phydev)
+{
+	return 0;
+}
+
+static int gen10g_resume(struct phy_device *phydev)
+{
+	return 0;
+}
+
+struct phy_driver genphy_10g_driver = {
+	.phy_id         = 0xffffffff,
+	.phy_id_mask    = 0xffffffff,
+	.name           = "Generic 10G PHY",
+	.soft_reset	= gen10g_soft_reset,
+	.config_init    = gen10g_config_init,
+	.features       = 0,
+	.config_aneg    = gen10g_config_aneg,
+	.read_status    = gen10g_read_status,
+	.suspend        = gen10g_suspend,
+	.resume         = gen10g_resume,
+};
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 040575dba98c..cedd1fd91626 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -69,13 +69,8 @@ static void phy_mdio_device_remove(struct mdio_device *mdiodev)
 	phy_device_remove(phydev);
 }
 
-enum genphy_driver {
-	GENPHY_DRV_1G,
-	GENPHY_DRV_10G,
-	GENPHY_DRV_MAX
-};
-
-static struct phy_driver genphy_driver[GENPHY_DRV_MAX];
+static struct phy_driver genphy_driver;
+extern struct phy_driver genphy_10g_driver;
 
 static LIST_HEAD(phy_fixup_list);
 static DEFINE_MUTEX(phy_fixup_lock);
@@ -928,11 +923,9 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
 	 */
 	if (!d->driver) {
 		if (phydev->is_c45)
-			d->driver =
-				&genphy_driver[GENPHY_DRV_10G].mdiodrv.driver;
+			d->driver = &genphy_10g_driver.mdiodrv.driver;
 		else
-			d->driver =
-				&genphy_driver[GENPHY_DRV_1G].mdiodrv.driver;
+			d->driver = &genphy_driver.mdiodrv.driver;
 
 		using_genphy = true;
 	}
@@ -1048,7 +1041,6 @@ void phy_detach(struct phy_device *phydev)
 	struct net_device *dev = phydev->attached_dev;
 	struct module *ndev_owner = dev->dev.parent->driver->owner;
 	struct mii_bus *bus;
-	int i;
 
 	phydev->attached_dev->phydev = NULL;
 	phydev->attached_dev = NULL;
@@ -1063,13 +1055,9 @@ void phy_detach(struct phy_device *phydev)
 	 * from the generic driver so that there's a chance a
 	 * real driver could be loaded
 	 */
-	for (i = 0; i < ARRAY_SIZE(genphy_driver); i++) {
-		if (phydev->mdio.dev.driver ==
-		    &genphy_driver[i].mdiodrv.driver) {
-			device_release_driver(&phydev->mdio.dev);
-			break;
-		}
-	}
+	if (phydev->mdio.dev.driver == &genphy_10g_driver.mdiodrv.driver ||
+	    phydev->mdio.dev.driver == &genphy_driver.mdiodrv.driver)
+		device_release_driver(&phydev->mdio.dev);
 
 	/*
 	 * The phydev might go away on the put_device() below, so avoid
@@ -1343,11 +1331,6 @@ int genphy_aneg_done(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_aneg_done);
 
-static int gen10g_config_aneg(struct phy_device *phydev)
-{
-	return 0;
-}
-
 /**
  * genphy_update_link - update link status in @phydev
  * @phydev: target phy_device struct
@@ -1481,25 +1464,6 @@ int genphy_read_status(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_read_status);
 
-static int gen10g_read_status(struct phy_device *phydev)
-{
-	u32 mmd_mask = phydev->c45_ids.devices_in_package;
-	int ret;
-
-	/* For now just lie and say it's 10G all the time */
-	phydev->speed = SPEED_10000;
-	phydev->duplex = DUPLEX_FULL;
-
-	/* Avoid reading the vendor MMDs */
-	mmd_mask &= ~(BIT(MDIO_MMD_VEND1) | BIT(MDIO_MMD_VEND2));
-
-	ret = genphy_c45_read_link(phydev, mmd_mask);
-
-	phydev->link = ret > 0 ? 1 : 0;
-
-	return 0;
-}
-
 /**
  * genphy_soft_reset - software reset the PHY via BMCR_RESET bit
  * @phydev: target phy_device struct
@@ -1563,23 +1527,8 @@ int genphy_config_init(struct phy_device *phydev)
 
 	return 0;
 }
-
-static int gen10g_soft_reset(struct phy_device *phydev)
-{
-	/* Do nothing for now */
-	return 0;
-}
 EXPORT_SYMBOL(genphy_config_init);
 
-static int gen10g_config_init(struct phy_device *phydev)
-{
-	/* Temporarily just say we support everything */
-	phydev->supported = SUPPORTED_10000baseT_Full;
-	phydev->advertising = SUPPORTED_10000baseT_Full;
-
-	return 0;
-}
-
 int genphy_suspend(struct phy_device *phydev)
 {
 	int value;
@@ -1595,11 +1544,6 @@ int genphy_suspend(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_suspend);
 
-static int gen10g_suspend(struct phy_device *phydev)
-{
-	return 0;
-}
-
 int genphy_resume(struct phy_device *phydev)
 {
 	int value;
@@ -1615,11 +1559,6 @@ int genphy_resume(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_resume);
 
-static int gen10g_resume(struct phy_device *phydev)
-{
-	return 0;
-}
-
 static int __set_phy_supported(struct phy_device *phydev, u32 max_speed)
 {
 	/* The default values for phydev->supported are provided by the PHY
@@ -1851,8 +1790,7 @@ void phy_drivers_unregister(struct phy_driver *drv, int n)
 }
 EXPORT_SYMBOL(phy_drivers_unregister);
 
-static struct phy_driver genphy_driver[] = {
-{
+static struct phy_driver genphy_driver = {
 	.phy_id		= 0xffffffff,
 	.phy_id_mask	= 0xffffffff,
 	.name		= "Generic PHY",
@@ -1866,18 +1804,7 @@ static struct phy_driver genphy_driver[] = {
 	.read_status	= genphy_read_status,
 	.suspend	= genphy_suspend,
 	.resume		= genphy_resume,
-}, {
-	.phy_id         = 0xffffffff,
-	.phy_id_mask    = 0xffffffff,
-	.name           = "Generic 10G PHY",
-	.soft_reset	= gen10g_soft_reset,
-	.config_init    = gen10g_config_init,
-	.features       = 0,
-	.config_aneg    = gen10g_config_aneg,
-	.read_status    = gen10g_read_status,
-	.suspend        = gen10g_suspend,
-	.resume         = gen10g_resume,
-} };
+};
 
 static int __init phy_init(void)
 {
@@ -1887,18 +1814,24 @@ static int __init phy_init(void)
 	if (rc)
 		return rc;
 
-	rc = phy_drivers_register(genphy_driver,
-				  ARRAY_SIZE(genphy_driver), THIS_MODULE);
+	rc = phy_driver_register(&genphy_10g_driver, THIS_MODULE);
 	if (rc)
+		goto err_10g;
+
+	rc = phy_driver_register(&genphy_driver, THIS_MODULE);
+	if (rc) {
+		phy_driver_unregister(&genphy_10g_driver);
+err_10g:
 		mdio_bus_exit();
+	}
 
 	return rc;
 }
 
 static void __exit phy_exit(void)
 {
-	phy_drivers_unregister(genphy_driver,
-			       ARRAY_SIZE(genphy_driver));
+	phy_driver_unregister(&genphy_10g_driver);
+	phy_driver_unregister(&genphy_driver);
 	mdio_bus_exit();
 }
 
-- 
2.7.4
