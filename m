From: <shh.xie@gmail.com>
Subject: [PATCH] phylib: add driver for Teranetics TN2020
Date: Fri, 17 Jul 2015 11:19:46 +0800
Message-ID: <1437103186-48034-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0055.outbound.protection.outlook.com ([65.55.169.55]:50586
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752124AbbGQD6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2015 23:58:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

Teranetics TN2020 is compliant with IEEE 802.3an 10 Gigabit.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/phy/Kconfig      |   5 ++
 drivers/net/phy/Makefile     |   1 +
 drivers/net/phy/teranetics.c | 128 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 134 insertions(+)
 create mode 100644 drivers/net/phy/teranetics.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index cf18940..a8225c5 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -54,6 +54,11 @@ config VITESSE_PHY
         ---help---
           Currently supports the vsc8244
 
+config TERANETICS_PHY
+        tristate "Drivers for the Teranetics PHYs"
+        ---help---
+          Currently supports the Teranetics TN2020
+
 config SMSC_PHY
 	tristate "Drivers for SMSC PHYs"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index fcc25a0..16aac1c 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_CICADA_PHY)	+= cicada.o
 obj-$(CONFIG_LXT_PHY)		+= lxt.o
 obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
 obj-$(CONFIG_SMSC_PHY)		+= smsc.o
+obj-$(CONFIG_TERANETICS_PHY)	+= teranetics.o
 obj-$(CONFIG_VITESSE_PHY)	+= vitesse.o
 obj-$(CONFIG_BROADCOM_PHY)	+= broadcom.o
 obj-$(CONFIG_BCM63XX_PHY)	+= bcm63xx.o
diff --git a/drivers/net/phy/teranetics.c b/drivers/net/phy/teranetics.c
new file mode 100644
index 0000000..7dcb5aa
--- /dev/null
+++ b/drivers/net/phy/teranetics.c
@@ -0,0 +1,128 @@
+/*
+ * Driver for Teranetics PHY
+ *
+ * Author: Shaohui Xie <Shaohui.Xie@freescale.com>
+ *
+ * Copyright 2015 Freescale Semiconductor, Inc.
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2.  This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/mdio.h>
+#include <linux/phy.h>
+
+MODULE_DESCRIPTION("Teranetics PHY driver");
+MODULE_AUTHOR("Shaohui Xie <Shaohui.Xie@freescale.com>");
+MODULE_LICENSE("GPL v2");
+
+#define PHY_ID_TN2020	0x00a19410
+#define MDIO_PHYXS_LNSTAT_SYNC0	0x0001
+#define MDIO_PHYXS_LNSTAT_SYNC1	0x0002
+#define MDIO_PHYXS_LNSTAT_SYNC2	0x0004
+#define MDIO_PHYXS_LNSTAT_SYNC3	0x0008
+#define MDIO_PHYXS_LNSTAT_ALIGN 0x1000
+
+#define MDIO_PHYXS_LANE_READY	(MDIO_PHYXS_LNSTAT_SYNC0 | \
+				MDIO_PHYXS_LNSTAT_SYNC1 | \
+				MDIO_PHYXS_LNSTAT_SYNC2 | \
+				MDIO_PHYXS_LNSTAT_SYNC3 | \
+				MDIO_PHYXS_LNSTAT_ALIGN)
+
+static int teranetics_config_init(struct phy_device *phydev)
+{
+	phydev->supported = SUPPORTED_10000baseT_Full;
+	phydev->advertising = SUPPORTED_10000baseT_Full;
+
+	return 0;
+}
+
+static int teranetics_soft_reset(struct phy_device *phydev)
+{
+	return 0;
+}
+
+static int teranetics_aneg_done(struct phy_device *phydev)
+{
+	int reg;
+
+	reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
+	return (reg < 0) ? reg : (reg & BMSR_ANEGCOMPLETE);
+}
+
+static int teranetics_config_aneg(struct phy_device *phydev)
+{
+	return 0;
+}
+
+static int teranetics_read_status(struct phy_device *phydev)
+{
+	int reg;
+
+	phydev->link = 1;
+
+	phydev->speed = SPEED_10000;
+	phydev->duplex = DUPLEX_FULL;
+
+	if (!phy_read_mmd(phydev, MDIO_MMD_VEND1, 93)) {
+		reg = phy_read_mmd(phydev, MDIO_MMD_PHYXS, MDIO_PHYXS_LNSTAT);
+		if (reg < 0 ||
+		    !((reg & MDIO_PHYXS_LANE_READY) == MDIO_PHYXS_LANE_READY)) {
+			phydev->link = 0;
+			return 0;
+		}
+
+		reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_STAT1);
+		if (reg < 0 || !(reg & MDIO_STAT1_LSTATUS))
+			phydev->link = 0;
+	}
+
+	return 0;
+}
+
+static int teranetics_match_phy_device(struct phy_device *phydev)
+{
+	return phydev->c45_ids.device_ids[3] == PHY_ID_TN2020;
+}
+
+static struct phy_driver teranetics_driver[] = {
+{
+	.phy_id		= PHY_ID_TN2020,
+	.phy_id_mask	= 0xffffffff,
+	.name		= "Teranetics TN2020",
+	.soft_reset	= teranetics_soft_reset,
+	.aneg_done	= teranetics_aneg_done,
+	.config_init    = teranetics_config_init,
+	.config_aneg    = teranetics_config_aneg,
+	.read_status	= teranetics_read_status,
+	.match_phy_device = teranetics_match_phy_device,
+	.driver		= { .owner = THIS_MODULE,},
+},
+};
+
+static int __init teranetics_init(void)
+{
+	return phy_drivers_register(teranetics_driver,
+				    ARRAY_SIZE(teranetics_driver));
+}
+
+static void __exit teranetics_exit(void)
+{
+	return phy_drivers_unregister(teranetics_driver,
+				      ARRAY_SIZE(teranetics_driver));
+}
+
+module_init(teranetics_init);
+module_exit(teranetics_exit);
+
+static struct mdio_device_id __maybe_unused teranetics_tbl[] = {
+	{ PHY_ID_TN2020, 0xffffffff },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, teranetics_tbl);
-- 
2.1.0.27.g96db324
