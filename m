From: Amy Fong <amy.fong@windriver.com>
Subject: [PATCH] Add Broadcom PHY support
Date: Fri, 15 Sep 2006 16:15:38 -0400
Message-ID: <20060915201538.GA28483@lucciola.windriver.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VbJkn9YxBvnuCH5J"
Cc: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:30431 "EHLO mail.wrs.com")
	by vger.kernel.org with ESMTP id S1751138AbWIOUPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2006 16:15:55 -0400
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

[PATCH] Add Broadcom PHY support

This patch adds a driver to support the bcm5421s and bcm5461s PHY

Kernel version:  linux-2.6.18-rc6

Signed-off-by: Amy Fong <amy.fong@windriver.com>

--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="broadcom-phy.diff"

Index: linux-2.6.18-rc6/drivers/net/phy/broadcom.c
===================================================================
--- /dev/null
+++ linux-2.6.18-rc6/drivers/net/phy/broadcom.c
@@ -0,0 +1,129 @@
+/*
+ * drivers/net/phy/broadcom.c, Driver for Broadcom PHYs
+ *
+ * Copyright (c) 2006 Wind River Systems, Inc.
+ * Written by Amy Fong
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+
+/* BCM5421S control register */
+#define MII_BCM5421S_CONTROL           0x00
+#define MII_BCM5421S_CONTROL_RESET     0x00008000
+#define MII_BCM5421S_CONTROL_INIT      0x00001140
+#define MII_BCM5421S_ANEN              0x00001000
+#define MII_BCM5421S_CR                 0x00
+#define MII_BCM5421S_CR_RST            0x00008000
+#define MII_BCM5421S_CR_INIT           0x00001000
+#define MII_BCM5421S_STATUS            0x1
+#define MII_BCM5421S_STATUS_AN_DONE    0x00000020
+#define MII_BCM5421S_STATUS_LINK       0x0004
+#define MII_BCM5421S_PHYIR1            0x2
+#define MII_BCM5421S_PHYIR2            0x3
+#define MII_BCM5421S_ANLPBPA           0x5
+#define MII_BCM5421S_ANLPBPA_HALF      0x00000040
+#define MII_BCM5421S_ANLPBPA_FULL      0x00000020
+#define MII_BCM5421S_ANEX              0x6
+#define MII_BCM5421S_ANEX_NP           0x00000004
+#define MII_BCM5421S_ANEX_PRX          0x00000002
+
+MODULE_DESCRIPTION("Broadcom PHY driver");
+MODULE_AUTHOR("Amy Fong");
+MODULE_LICENSE("GPL");
+
+static int bcm5421s_config_aneg(struct phy_device *phydev)
+{
+	int err;
+
+       /* Write the appropriate value to the PHY reg */
+	if (phydev->supported & SUPPORTED_1000baseT_Full)
+               err = phy_write(phydev, MII_BCM5421S_CONTROL, MII_BCM5421S_CONTROL_INIT);
+       else
+               err = phy_write(phydev, MII_BCM5421S_CONTROL, MII_BCM5421S_CR_INIT);
+
+	if (err < 0) return err;
+
+       /* doesn't have phy interrupt */
+       phydev->interrupts = PHY_INTERRUPT_DISABLED;
+
+	return 0;
+}
+
+static struct phy_driver bcm5421s_driver = {
+	.phy_id         = 0x002060e1,
+	.phy_id_mask    = 0x00ffffff,
+	.name           = "Broadcom BCM5421S",
+	.features       = PHY_GBIT_FEATURES,
+	.config_aneg    = bcm5421s_config_aneg,
+	.read_status    = genphy_read_status,
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
+/* Glossy description on Broadcom's site seems to hint that the 5461
+   should be a drop-in for the 5421.... */
+static struct phy_driver bcm5461s_driver = {
+	.phy_id         = 0x002060c1,
+	.phy_id_mask    = 0x00ffffff,
+	.name           = "Broadcom BCM5461S",
+	.features       = PHY_GBIT_FEATURES,
+	.config_aneg    = bcm5421s_config_aneg,
+	.read_status    = genphy_read_status,
+	.driver 	= { .owner = THIS_MODULE,},
+};
+
+static int __init broadcom_init(void)
+{
+	int ret;
+
+	ret = phy_driver_register(&bcm5421s_driver);
+	if (!ret) {
+		ret = phy_driver_register(&bcm5461s_driver);
+		if (ret) phy_driver_unregister(&bcm5421s_driver);
+	}
+	return ret;
+}
+
+static void __exit broadcom_exit(void)
+{
+	phy_driver_unregister(&bcm5421s_driver);
+	phy_driver_unregister(&bcm5461s_driver);
+}
+
+module_init(broadcom_init);
+module_exit(broadcom_exit);
Index: linux-2.6.18-rc6/drivers/net/phy/Kconfig
===================================================================
--- linux-2.6.18-rc6.orig/drivers/net/phy/Kconfig
+++ linux-2.6.18-rc6/drivers/net/phy/Kconfig
@@ -56,6 +56,12 @@
 	---help---
 	  Currently supports the LAN83C185 PHY
 
+config BROADCOM_PHY
+	tristate "Drivers for Broadcom PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently supports bcm5421s and bcm5461s
+
 config FIXED_PHY
 	tristate "Drivers for PHY emulation on fixed speed/link"
 	depends on PHYLIB
Index: linux-2.6.18-rc6/drivers/net/phy/Makefile
===================================================================
--- linux-2.6.18-rc6.orig/drivers/net/phy/Makefile
+++ linux-2.6.18-rc6/drivers/net/phy/Makefile
@@ -10,4 +10,5 @@
 obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
 obj-$(CONFIG_SMSC_PHY)		+= smsc.o
 obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
+obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed.o

--VbJkn9YxBvnuCH5J--
