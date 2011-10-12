From: Andy Fleming <afleming@freescale.com>
Subject: [RFC] phylib: Add rudimentary Generic 10G support
Date: Tue, 11 Oct 2011 20:20:22 -0500
Message-ID: <1318382422-2133-3-git-send-email-afleming@freescale.com>
References: <1318382422-2133-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe010.messaging.microsoft.com ([216.32.180.30]:55007
	"EHLO VA3EHSOBE010.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751491Ab1JLBUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 21:20:31 -0400
In-Reply-To: <1318382422-2133-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is mostly taken from mdio.c, and modified to work under phylib.

However, the support is skewed toward 10GBaseT, as that is the only
PHY available to me at this time.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---

This patch used to be part of the 10G PHY support patch, but I'm
breaking it out, here, so the other stuff can go in faster. My PHY
doesn't appear to provide useful information in fiber mode, and
most of my boards are hooked up via fiber. I'm not sure what the
best approach for getting this in is.

 drivers/net/phy/phy_device.c |  118 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 118 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 22281d4..e2ee8dd 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -10,6 +10,7 @@
  *
  * Copyright (c) 2004-2006, 2008-2011 Freescale Semiconductor, Inc.
  *
+ *
  * This program is free software; you can redistribute  it and/or modify it
  * under  the terms of  the GNU General  Public License as published by the
  * Free Software Foundation;  either version 2 of the  License, or (at your
@@ -54,6 +55,7 @@ static void phy_device_release(struct device *dev)
 }
 
 static struct phy_driver genphy_driver;
+static struct phy_driver gen10g_driver;
 extern int mdio_bus_init(void);
 extern void mdio_bus_exit(void);
 
@@ -439,6 +441,9 @@ int phy_init_hw(struct phy_device *phydev)
 
 static struct phy_driver *generic_for_interface(phy_interface_t interface)
 {
+	if (is_10g_interface(interface))
+		return &gen10g_driver;
+
 	return &genphy_driver;
 }
 
@@ -632,6 +637,12 @@ static int genphy_config_advert(struct phy_device *phydev)
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
@@ -660,6 +671,11 @@ static int genphy_setup_forced(struct phy_device *phydev)
 	return err;
 }
 
+int gen10g_setup_forced(struct phy_device *phydev)
+{
+	return 0;
+}
+
 /**
  * genphy_restart_aneg - Enable and Restart Autonegotiation
  * @phydev: target phy_device struct
@@ -684,6 +700,13 @@ int genphy_restart_aneg(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_restart_aneg);
 
+int gen10g_restart_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_restart_aneg);
+
+
 /**
  * genphy_config_aneg - restart auto-negotiation or write BMCR
  * @phydev: target phy_device struct
@@ -725,6 +748,12 @@ int genphy_config_aneg(struct phy_device *phydev)
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
@@ -854,6 +883,33 @@ int genphy_read_status(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_read_status);
 
+int gen10g_read_status(struct phy_device *phydev)
+{
+	int devad, reg;
+	u32 mmd_mask = phydev->mmds;
+
+	phydev->link = 1;
+
+	/* For now just lie and say it's 10G all the time */
+	phydev->speed = 10000;
+	phydev->duplex = DUPLEX_FULL;
+
+	for (devad = 0; mmd_mask; devad++, mmd_mask = mmd_mask >> 1) {
+		if (!mmd_mask & 1)
+			continue;
+
+		/* Read twice because link state is latched and a
+		 * read moves the current state into the register */
+		phy45_read(phydev, devad, MDIO_STAT1);
+		reg = phy45_read(phydev, devad, MDIO_STAT1);
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
@@ -901,6 +957,35 @@ static int genphy_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+/* Replicate mdio45_probe */
+int gen10g_config_init(struct phy_device *phydev)
+{
+	int mmd, stat2, devs1, devs2;
+
+	phydev->supported = phydev->advertising = SUPPORTED_10000baseT_Full;
+
+	/* Assume PHY must have at least one of PMA/PMD, WIS, PCS, PHY
+	 * XS or DTE XS; give up if none is present. */
+	for (mmd = 1; mmd <= 5; mmd++) {
+		/* Is this MMD present? */
+		stat2 = phy45_read(phydev, mmd, MDIO_STAT2);
+		if (stat2 < 0 ||
+			(stat2 & MDIO_STAT2_DEVPRST) != MDIO_STAT2_DEVPRST_VAL)
+			continue;
+
+		/* It should tell us about all the other MMDs */
+		devs1 = phy45_read(phydev, mmd, MDIO_DEVS1);
+		devs2 = phy45_read(phydev, mmd, MDIO_DEVS2);
+		if (devs1 < 0 || devs2 < 0)
+			continue;
+
+		phydev->mmds = devs1 | (devs2 << 16);
+		return 0;
+	}
+
+	return -ENODEV;
+}
+
 int genphy_suspend(struct phy_device *phydev)
 {
 	int value;
@@ -916,6 +1001,12 @@ int genphy_suspend(struct phy_device *phydev)
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
@@ -931,6 +1022,13 @@ int genphy_resume(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(genphy_resume);
 
+int gen10g_resume(struct phy_device *phydev)
+{
+	return 0;
+}
+EXPORT_SYMBOL(gen10g_resume);
+
+
 /**
  * phy_probe - probe and init a PHY device
  * @dev: device to probe and init
@@ -1044,6 +1142,19 @@ static struct phy_driver genphy_driver = {
 	.driver		= {.owner = THIS_MODULE, },
 };
 
+static struct phy_driver gen10g_driver = {
+	.phy_id		= 0xffffffff,
+	.phy_id_mask	= 0xffffffff,
+	.name		= "Generic 10G PHY",
+	.config_init	= gen10g_config_init,
+	.features	= 0,
+	.config_aneg	= gen10g_config_aneg,
+	.read_status	= gen10g_read_status,
+	.suspend	= gen10g_suspend,
+	.resume		= gen10g_resume,
+	.driver		= {.owner = THIS_MODULE, },
+};
+
 static int __init phy_init(void)
 {
 	int rc;
@@ -1056,8 +1167,14 @@ static int __init phy_init(void)
 	if (rc)
 		goto genphy_register_failed;
 
+	rc = phy_driver_register(&gen10g_driver);
+	if (rc)
+		goto gen10g_register_failed;
+
 	return rc;
 
+gen10g_register_failed:
+	phy_driver_unregister(&genphy_driver);
 genphy_register_failed:
 	mdio_bus_exit();
 
@@ -1066,6 +1183,7 @@ genphy_register_failed:
 
 static void __exit phy_exit(void)
 {
+	phy_driver_unregister(&gen10g_driver);
 	phy_driver_unregister(&genphy_driver);
 	mdio_bus_exit();
 }
-- 
1.7.3.4
