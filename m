From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH] add the ICPlus IP175C PHY driver
Date: Tue, 10 Apr 2007 16:57:13 -0500
Message-ID: <20070410165713.7b3d6158.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:59260 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914AbXDJV5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 17:57:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Barkowski <michael.barkowski@freescale.com>

The ICPlus IP175C sports a 100Mbit/s 5-port switch in addition
to a dedicated 100Mbit/s WAN port.

Signed-off-by: Michael Barkowski <michael.barkowski@freescale.com>
Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
please consider for 2.6.22

 drivers/net/phy/Kconfig  |    6 ++
 drivers/net/phy/Makefile |    1 +
 drivers/net/phy/icplus.c |  121 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 128 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/icplus.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index f994f12..91cf33e 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -62,6 +62,12 @@ config BROADCOM_PHY
 	---help---
 	  Currently supports the BCM5411, BCM5421 and BCM5461 PHYs.
 
+config ICPLUS_PHY
+	tristate "Drivers for ICPlus PHYs"
+	depends on PHYLIB
+	---help---
+	  Currently supports the IP175C PHY.
+
 config FIXED_PHY
 	tristate "Drivers for PHY emulation on fixed speed/link"
 	depends on PHYLIB
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index bcd1efb..8885650 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -11,4 +11,5 @@ obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
 obj-$(CONFIG_SMSC_PHY)		+= smsc.o
 obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
 obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
+obj-$(CONFIG_ICPLUS_PHY)	+= icplus.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed.o
diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
new file mode 100644
index 0000000..4e2912c
--- /dev/null
+++ b/drivers/net/phy/icplus.c
@@ -0,0 +1,121 @@
+/*
+ * Driver for ICPlus PHYs
+ *
+ * Copyright (c) 2007 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#include <linux/kernel.h>
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
+MODULE_DESCRIPTION("ICPlus IP175C PHY driver");
+MODULE_AUTHOR("Michael Barkowski");
+MODULE_LICENSE("GPL");
+
+static int ip175c_config_init(struct phy_device *phydev)
+{
+	int err, i;
+	static int full_reset_performed = 0;
+
+	if (full_reset_performed == 0) {
+
+		/* master reset */
+		err = phydev->bus->write(phydev->bus, 30, 0, 0x175c);
+		if (err < 0)
+			return err;
+
+		/* data sheet specifies reset period is 2 msec */
+		udelay(3000);
+
+		/* enable IP175C mode */
+		err = phydev->bus->write(phydev->bus, 29, 31, 0x175c);
+		if (err < 0)
+			return err;
+
+		for (i=0; i<5; i++) {
+			err = phydev->bus->write(phydev->bus, i, MII_BMCR, BMCR_RESET);
+		}
+		udelay(3000);
+
+		full_reset_performed = 1;
+	}
+
+	if (phydev->addr != 4) {
+		phydev->state = PHY_RUNNING;
+		phydev->speed = SPEED_100;
+		phydev->duplex = DUPLEX_FULL;
+		phydev->link = 1;
+		netif_carrier_on(phydev->attached_dev);
+	}
+
+	printk("PHY %d initialized\n",phydev->addr);
+	return 0;
+}
+
+static int ip175c_read_status(struct phy_device *phydev)
+{
+	if (phydev->addr == 4) { /* if WAN port */
+		genphy_read_status(phydev);
+	}
+
+	return 0;
+}
+
+
+static int ip175c_config_aneg(struct phy_device *phydev)
+{
+	if (phydev->addr == 4) { /* if WAN port */
+		genphy_config_aneg(phydev);
+	}
+
+	return 0;
+}
+
+
+static struct phy_driver ip175c_driver = {
+	.phy_id		= 0x02430d80,
+	.name		= "ICPlus IP175C",
+	.phy_id_mask	= 0x0ffffff0,
+	.features	= PHY_BASIC_FEATURES,
+	.config_init	= &ip175c_config_init,
+	.config_aneg	= &ip175c_config_aneg,
+	.read_status	= &ip175c_read_status,
+	.driver		= { .owner = THIS_MODULE,},
+};
+
+static int __init ip175c_init(void)
+{
+	return phy_driver_register(&ip175c_driver);
+}
+
+static void __exit ip175c_exit(void)
+{
+	phy_driver_unregister(&ip175c_driver);
+}
+
+module_init(ip175c_init);
+module_exit(ip175c_exit);
+
-- 
1.5.0.1

