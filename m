From: Jon Loeliger <jdl@jdl.com>
Subject: [PATCH 9/9 v3] Add Vitesse 8244 PHY for MPC8641 HPCN platform.
Date: Sat, 17 Jun 2006 17:52:55 -0500
Message-ID: <E1Frjex-0004PK-F6@jdl.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jdl.com ([66.118.10.122]:39144 "EHLO jdl.com")
	by vger.kernel.org with ESMTP id S1750985AbWFQWw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2006 18:52:58 -0400
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Kriston Carson <KristonCarson@freescale.com>
Signed-off-by: Xianghua Xiao <x.xiao@freescale.com>
Signed-off-by: Jon Loeliger <jdl@freescale.com>
Acked-by: Jeff Garzik <jeff@garzik.org>

---

 drivers/net/Kconfig       |    6 +-
 drivers/net/phy/Kconfig   |    5 ++
 drivers/net/phy/Makefile  |    1
 drivers/net/phy/vitesse.c |  112 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 121 insertions(+), 3 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index bdaaad8..c1c2758 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2179,11 +2179,11 @@ config SPIDER_NET
 
 config GIANFAR
 	tristate "Gianfar Ethernet"
-	depends on 85xx || 83xx
+	depends on 85xx || 83xx || PPC_86xx
 	select PHYLIB
 	help
-	  This driver supports the Gigabit TSEC on the MPC85xx 
-	  family of chips, and the FEC on the 8540
+	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
+	  and MPC86xx family of chips, and the FEC on the 8540.
 
 config GFAR_NAPI
 	bool "NAPI Support"
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index fa39b94..76e51b1 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -44,6 +44,11 @@ config CICADA_PHY
 	depends on PHYLIB
 	---help---
 	  Currently supports the cis8204
+config VITESSE_PHY
+        tristate "Drivers for the Vitesse PHYs"
+        depends on PHYLIB
+        ---help---
+          Currently supports the vsc8244
 
 endmenu
 
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index e4116a5..a8d066e 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -8,3 +8,4 @@ obj-$(CONFIG_DAVICOM_PHY)	+= davicom.o
 obj-$(CONFIG_CICADA_PHY)	+= cicada.o
 obj-$(CONFIG_LXT_PHY)		+= lxt.o
 obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
+obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
new file mode 100644
index 0000000..ffd215d
--- /dev/null
+++ b/drivers/net/phy/vitesse.c
@@ -0,0 +1,112 @@
+/*
+ * Driver for Vitesse PHYs
+ *
+ * Author: Kriston Carson
+ *
+ * Copyright (c) 2005 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+
+#include <linux/config.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+/* Vitesse Extended Control Register 1 */
+#define MII_VSC8244_EXT_CON1           0x17
+#define MII_VSC8244_EXTCON1_INIT       0x0000
+
+/* Vitesse Interrupt Mask Register */
+#define MII_VSC8244_IMASK		0x19
+#define MII_VSC8244_IMASK_IEN		0x8000
+#define MII_VSC8244_IMASK_SPEED		0x4000
+#define MII_VSC8244_IMASK_LINK		0x2000
+#define MII_VSC8244_IMASK_DUPLEX	0x1000
+#define MII_VSC8244_IMASK_MASK		0xf000
+
+/* Vitesse Interrupt Status Register */
+#define MII_VSC8244_ISTAT		0x1a
+#define MII_VSC8244_ISTAT_STATUS	0x8000
+#define MII_VSC8244_ISTAT_SPEED		0x4000
+#define MII_VSC8244_ISTAT_LINK		0x2000
+#define MII_VSC8244_ISTAT_DUPLEX	0x1000
+
+/* Vitesse Auxiliary Control/Status Register */
+#define MII_VSC8244_AUX_CONSTAT        	0x1c
+#define MII_VSC8244_AUXCONSTAT_INIT    	0x0004
+#define MII_VSC8244_AUXCONSTAT_DUPLEX  	0x0020
+#define MII_VSC8244_AUXCONSTAT_SPEED   	0x0018
+#define MII_VSC8244_AUXCONSTAT_GBIT    	0x0010
+#define MII_VSC8244_AUXCONSTAT_100     	0x0008
+
+MODULE_DESCRIPTION("Vitesse PHY driver");
+MODULE_AUTHOR("Kriston Carson");
+MODULE_LICENSE("GPL");
+
+static int vsc824x_config_init(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_write(phydev, MII_VSC8244_AUX_CONSTAT,
+			MII_VSC8244_AUXCONSTAT_INIT);
+	if (err < 0)
+		return err;
+
+	err = phy_write(phydev, MII_VSC8244_EXT_CON1,
+			MII_VSC8244_EXTCON1_INIT);
+	return err;
+}
+
+static int vsc824x_ack_interrupt(struct phy_device *phydev)
+{
+	int err = phy_read(phydev, MII_VSC8244_ISTAT);
+
+	return (err < 0) ? err : 0;
+}
+
+static int vsc824x_config_intr(struct phy_device *phydev)
+{
+	int err;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
+		err = phy_write(phydev, MII_VSC8244_IMASK,
+				MII_VSC8244_IMASK_MASK);
+	else
+		err = phy_write(phydev, MII_VSC8244_IMASK, 0);
+	return err;
+}
+
+/* Vitesse 824x */
+static struct phy_driver vsc8244_driver = {
+	.phy_id		= 0x000fc6c2,
+	.name		= "Vitesse VSC8244",
+	.phy_id_mask	= 0x000fffc0,
+	.features	= PHY_GBIT_FEATURES,
+	.flags		= PHY_HAS_INTERRUPT,
+	.config_init	= &vsc824x_config_init,
+	.config_aneg	= &genphy_config_aneg,
+	.read_status	= &genphy_read_status,
+	.ack_interrupt	= &vsc824x_ack_interrupt,
+	.config_intr	= &vsc824x_config_intr,
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
+static int __init vsc8244_init(void)
+{
+	return phy_driver_register(&vsc8244_driver);
+}
+
+static void __exit vsc8244_exit(void)
+{
+	phy_driver_unregister(&vsc8244_driver);
+}
+
+module_init(vsc8244_init);
+module_exit(vsc8244_exit);
