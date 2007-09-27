From: ljd015@freescale.com
Subject: [PATCH] Added Ethernet PHY support for the Realtek 821x
Date: Thu, 27 Sep 2007 14:26:48 -0400
Message-ID: <1190917608524-git-send-email-ljd015@freescale.com>
Cc: "Joe D'Abbraccio" <ljd015@freescale.com>,
	Johnson Leung <r58129@freescale.com>,
	Kevin Lam <r43770@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:46620 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756218AbXI0TLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 15:11:44 -0400
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by de01egw01.freescale.net (8.12.11/de01egw01) with ESMTP id l8RJ6nbN018285
	for <netdev@vger.kernel.org>; Thu, 27 Sep 2007 12:11:41 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe D'Abbraccio <ljd015@freescale.com>

The MPC837xERDB platform uses the RTL8211B Ethernet PHY on the
WAN port (on eth0).  Also added the kernel configuration options for
selecting the PHY.

Signed-off-by: Johnson Leung <r58129@freescale.com>
Signed-off-by: Kevin Lam <r43770@freescale.com>
Signed-off-by: Joe D'Abbraccio <ljd015@freescale.com>
---
 arch/powerpc/configs/mpc837x_rdb_defconfig |    1 +
 drivers/net/phy/Kconfig                    |    5 ++
 drivers/net/phy/Makefile                   |    1 +
 drivers/net/phy/realtek.c                  |   84 ++++++++++++++++++++++++++++
 4 files changed, 91 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/realtek.c

diff --git a/arch/powerpc/configs/mpc837x_rdb_defconfig b/arch/powerpc/configs/mpc837x_rdb_defconfig
index e398e9f..9837493 100644
--- a/arch/powerpc/configs/mpc837x_rdb_defconfig
+++ b/arch/powerpc/configs/mpc837x_rdb_defconfig
@@ -411,6 +411,7 @@ CONFIG_MARVELL_PHY=y
 # CONFIG_SMSC_PHY is not set
 # CONFIG_BROADCOM_PHY is not set
 # CONFIG_ICPLUS_PHY is not set
+CONFIG_REALTEK_PHY=y
 # CONFIG_FIXED_PHY is not set
 CONFIG_NET_ETHERNET=y
 CONFIG_MII=y
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index dd09011..9ce95c9 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -60,6 +60,11 @@ config ICPLUS_PHY
 	---help---
 	  Currently supports the IP175C PHY.
 
+config REALTEK_PHY
+	tristate "Drivers for Realtek PHYs"
+	---help---
+	  Supports the Realtek 821x PHY.
+
 config FIXED_PHY
 	tristate "Drivers for PHY emulation on fixed speed/link"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 8885650..d7bfa4e 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -12,4 +12,5 @@ obj-$(CONFIG_SMSC_PHY)		+= smsc.o
 obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
 obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
+obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed.o
diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
new file mode 100644
index 0000000..546c25f
--- /dev/null
+++ b/drivers/net/phy/realtek.c
@@ -0,0 +1,84 @@
+/*
+ * drivers/net/phy/realtek.c
+ *
+ * Driver for Realtek PHYs
+ *
+ * Author: Johnson Leung <r58129@freescale.com>
+ *
+ * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/phy.h>
+
+#define RTL821x_PHYSR		0x11
+#define RTL821x_PHYSR_DUPLEX	0x2000
+#define RTL821x_PHYSR_SPEED	0xc000
+#define RTL821x_INER		0x12
+#define RTL821x_INER_INIT	0x6400
+#define RTL821x_INSR		0x13
+
+MODULE_DESCRIPTION("Realtek PHY driver");
+MODULE_AUTHOR("Johnson Leung");
+MODULE_LICENSE("GPL");
+
+static int rtl821x_config_init(struct phy_device *phydev)
+{
+	return 0;
+}
+
+static int rtl821x_ack_interrupt(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_read(phydev, RTL821x_INSR);
+	return (err < 0) ? err : 0;
+}
+
+static int rtl821x_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, RTL821x_INER,
+				RTL821x_INER_INIT);
+	else
+		err = phy_write(phydev, RTL821x_INER, 0);
+
+	return err;
+}
+
+/* RTL8211B */
+static struct phy_driver rtl821x_driver = {
+	.phy_id		= 0x0001cc912,
+	.name		= "RTL821x Gigabit Ethernet",
+	.phy_id_mask	= 0x001fffff,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= &rtl821x_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &rtl821x_ack_interrupt,
+	.config_intr	= &rtl821x_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
+static int __init realtek_init(void)
+{
+	int ret;
+
+	ret = phy_driver_register(&rtl821x_driver);
+	return ret;
+}
+
+static void __exit realtek_exit(void)
+{
+	phy_driver_unregister(&rtl821x_driver);
+}
+
+module_init(realtek_init);
+module_exit(realtek_exit);
-- 
1.5.2.2

