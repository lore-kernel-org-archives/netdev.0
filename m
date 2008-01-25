From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH] phylib: Add Realtek 821x eth PHY support
Date: Thu, 24 Jan 2008 20:28:26 -0600
Message-ID: <20080124202826.a50fa29c.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Johnson Leung <r58129@freescale.com>,
	Kevin Lam <r43770@freescale.com>,
	"Joe D'Abbraccio" <ljd015@freescale.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:52481 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbYAYC2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 21:28:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this PHY present on the MPC8315E and MPC837xE RDB boards.

Signed-off-by: Johnson Leung <r58129@freescale.com>
Signed-off-by: Kevin Lam <r43770@freescale.com>
Signed-off-by: Joe D'Abbraccio <ljd015@freescale.com>
Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
 drivers/net/phy/Kconfig   |    5 +++
 drivers/net/phy/Makefile  |    1 +
 drivers/net/phy/realtek.c |   80 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 86 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/realtek.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 7fe03ce..f4ca059 100644
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
 	bool "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 3d6cc7b..5997d6e 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -12,5 +12,6 @@ obj-$(CONFIG_SMSC_PHY)		+= smsc.o
 obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
 obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
+obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed.o
 obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
new file mode 100644
index 0000000..a052a67
--- /dev/null
+++ b/drivers/net/phy/realtek.c
@@ -0,0 +1,80 @@
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
+static int rtl821x_ack_interrupt(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_read(phydev, RTL821x_INSR);
+
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
+	.phy_id		= 0x001cc912,
+	.name		= "RTL821x Gigabit Ethernet",
+	.phy_id_mask	= 0x001fffff,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &rtl821x_ack_interrupt,
+	.config_intr	= &rtl821x_config_intr,
+	.driver		= { .owner = THIS_MODULE,},
+};
+
+static int __init realtek_init(void)
+{
+	int ret;
+
+	ret = phy_driver_register(&rtl821x_driver);
+
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

