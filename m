From: "Choi, David" <David.Choi@Micrel.Com>
Subject: [PATCH linux-2.6.34-rc5] drivers/net/phy: micrel phy driver
Date: Thu, 29 Apr 2010 09:12:41 -0700
Message-ID: <C43529A246480145B0A6D0234BDB0F0D02129E@MELANITE.micrel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c11o145.mxlogic.net ([208.65.144.68]:57219 "EHLO
	p01c11o145.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429Ab0EANU3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 09:20:29 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To whom it may have concerned:

From: David J. Choi <david.choi@micrel.com>
Body of the explanation: This is the first version of phy driver from Micrel Inc.
Signed-off-by: David J. Choi <david.choi@micrel.com>

---
--- linux-2.6.34-rc5/drivers/net/phy/micrel.c.orig	2010-04-29 08:20:51.000000000 -0700
+++ linux-2.6.34-rc5/drivers/net/phy/micrel.c	2010-04-29 08:52:37.000000000 -0700
@@ -0,0 +1,104 @@
+/*
+ * drivers/net/phy/micrel.c
+ *
+ * Driver for Micrel PHYs
+ *
+ * Author: David J. Choi
+ *
+ * Copyright (c) 2010 Micrel, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * Support : ksz9021 , vsc8201, ks8001
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/phy.h>
+
+#define	PHY_ID_KSZ9021			0x00221611
+#define	PHY_ID_VSC8201			0x000FC413
+#define	PHY_ID_KS8001			0x0022161A
+
+
+static int kszphy_config_init(struct phy_device *phydev)
+{
+	return 0;
+}
+
+
+static struct phy_driver ks8001_driver = {
+	.phy_id		= PHY_ID_KS8001,
+	.phy_id_mask	= 0x00fffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_POLL,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.driver		= { .owner = THIS_MODULE,},
+};
+
+static struct phy_driver vsc8201_driver = {
+	.phy_id		= PHY_ID_VSC8201,
+	.name		= "Micrel VSC8201",
+	.phy_id_mask	= 0x00fffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= PHY_POLL,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.driver		= { .owner = THIS_MODULE,},
+};
+
+static struct phy_driver ksz9021_driver = {
+	.phy_id		= PHY_ID_KSZ9021,
+	.phy_id_mask	= 0x000fff10,
+	.name		= "Micrel KSZ9021 Gigabit PHY",
+	.features	= PHY_GBIT_FEATURES | SUPPORTED_Pause,
+	.flags		= PHY_POLL,
+	.config_init	= kszphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.driver		= { .owner = THIS_MODULE, },
+};
+
+static int __init ksphy_init(void)
+{
+	int ret;
+
+	ret = phy_driver_register(&ks8001_driver);
+	if (ret)
+		goto err1;
+	ret = phy_driver_register(&vsc8201_driver);
+	if (ret)
+		goto err2;
+
+	ret = phy_driver_register(&ksz9021_driver);
+	if (ret)
+		goto err3;
+	return 0;
+
+err3:
+	phy_driver_unregister(&vsc8201_driver);
+err2:
+	phy_driver_unregister(&ks8001_driver);
+err1:
+	return ret;
+}
+
+static void __exit ksphy_exit(void)
+{
+	phy_driver_unregister(&ks8001_driver);
+	phy_driver_unregister(&vsc8201_driver);
+	phy_driver_unregister(&ksz9021_driver);
+}
+
+module_init(ksphy_init);
+module_exit(ksphy_exit);
+
+MODULE_DESCRIPTION("Micrel PHY driver");
+MODULE_AUTHOR("David J. Choi");
+MODULE_LICENSE("GPL");
--- linux-2.6.34-rc5/drivers/net/phy/Kconfig.orig	2010-04-29 08:21:12.000000000 -0700
+++ linux-2.6.34-rc5/drivers/net/phy/Kconfig	2010-04-29 08:25:18.000000000 -0700
@@ -88,6 +88,11 @@ config LSI_ET1011C_PHY
 	---help---
 	  Supports the LSI ET1011C PHY.
 
+config MICREL_PHY
+	tristate "Driver for Micrel PHYs"
+	---help---
+	  Supports the KSZ9021, VSC8201, KS8001 PHYs.
+
 config FIXED_PHY
 	bool "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
 	depends on PHYLIB=y
--- linux-2.6.34-rc5/drivers/net/phy/Makefile.orig	2010-04-29 08:20:25.000000000 -0700
+++ linux-2.6.34-rc5/drivers/net/phy/Makefile	2010-04-29 08:31:13.000000000 -0700
@@ -20,4 +20,5 @@ obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitba
 obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
 obj-$(CONFIG_NATIONAL_PHY)	+= national.o
 obj-$(CONFIG_STE10XP)		+= ste10Xp.o
+obj-$(CONFIG_MICREL_PHY)	+= micrel.o
 obj-$(CONFIG_MDIO_OCTEON)	+= mdio-octeon.o

---
