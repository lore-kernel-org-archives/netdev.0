From: Dan Murphy <dmurphy@ti.com>
Subject: [PATCH v5 1/2] net: phy: DP83822 initial driver submission
Date: Tue, 10 Oct 2017 12:42:55 -0500
Message-ID: <20171010174256.21930-1-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Woojung.Huh@microchip.com>,
        <afd@ti.com>, Dan Murphy <dmurphy@ti.com>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:46115 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932243AbdJJRoC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 13:44:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the TI  DP83822 10/100Mbit ethernet phy.

The DP83822 provides flexibility to connect to a MAC through a
standard MII, RMII or RGMII interface.

In addition the DP83822 needs to be removed from the DP83848 driver
as the WoL support is added here for this device.

Datasheet:
http://www.ti.com/product/DP83822I/datasheet

Signed-off-by: Dan Murphy <dmurphy@ti.com>
---

v5 - Fixed bit mask, added config_init to set WOL register bits, fixed spacing
issues, moved password storage under secure on if statement, and added INT_EN bit
setting for interrupt enable.
https://www.mail-archive.com/netdev@vger.kernel.org/msg192495.html

v4 - Squash DP83822 removal patch into this patch -
https://www.mail-archive.com/netdev@vger.kernel.org/msg192424.html

v3 - Fixed WoL indication bit and removed mutex for suspend/resume - 
https://www.mail-archive.com/netdev@vger.kernel.org/msg191891.html and
https://www.mail-archive.com/netdev@vger.kernel.org/msg191665.html

v2 - Updated per comments.  Removed unnessary parantheis, called genphy_suspend/
resume routines and then performing WoL changes, reworked sopass storage and reduced
the number of phy reads, and moved WOL_SECURE_ON - 
https://www.mail-archive.com/netdev@vger.kernel.org/msg191392.html

 drivers/net/phy/Kconfig   |   5 +
 drivers/net/phy/Makefile  |   1 +
 drivers/net/phy/dp83822.c | 344 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/dp83848.c |   3 -
 4 files changed, 350 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/phy/dp83822.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index cd931cf9dcc2..8e78a482e09e 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -277,6 +277,11 @@ config DAVICOM_PHY
 	---help---
 	  Currently supports dm9161e and dm9131
 
+config DP83822_PHY
+	tristate "Texas Instruments DP83822 PHY"
+	---help---
+	  Supports the DP83822 PHY.
+
 config DP83848_PHY
 	tristate "Texas Instruments DP83848 PHY"
 	---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 416df92fbf4f..df3b82ba8550 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -55,6 +55,7 @@ obj-$(CONFIG_CICADA_PHY)	+= cicada.o
 obj-$(CONFIG_CORTINA_PHY)	+= cortina.o
 obj-$(CONFIG_DAVICOM_PHY)	+= davicom.o
 obj-$(CONFIG_DP83640_PHY)	+= dp83640.o
+obj-$(CONFIG_DP83822_PHY)	+= dp83822.o
 obj-$(CONFIG_DP83848_PHY)	+= dp83848.o
 obj-$(CONFIG_DP83867_PHY)	+= dp83867.o
 obj-$(CONFIG_FIXED_PHY)		+= fixed_phy.o
diff --git a/drivers/net/phy/dp83822.c b/drivers/net/phy/dp83822.c
new file mode 100644
index 000000000000..14335d14e9e4
--- /dev/null
+++ b/drivers/net/phy/dp83822.c
@@ -0,0 +1,344 @@
+/*
+ * Driver for the Texas Instruments DP83822 PHY
+ *
+ * Copyright (C) 2017 Texas Instruments Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/ethtool.h>
+#include <linux/etherdevice.h>
+#include <linux/kernel.h>
+#include <linux/mii.h>
+#include <linux/module.h>
+#include <linux/of.h>
+#include <linux/phy.h>
+#include <linux/netdevice.h>
+
+#define DP83822_PHY_ID	        0x2000a240
+#define DP83822_DEVADDR		0x1f
+
+#define MII_DP83822_PHYSCR	0x11
+#define MII_DP83822_MISR1	0x12
+#define MII_DP83822_MISR2	0x13
+#define MII_DP83822_RESET_CTRL	0x1f
+
+#define DP83822_HW_RESET	BIT(15)
+#define DP83822_SW_RESET	BIT(14)
+
+/* PHYSCR Register Fields */
+#define DP83822_PHYSCR_INT_OE		BIT(0) /* Interrupt Output Enable */
+#define DP83822_PHYSCR_INTEN		BIT(1) /* Interrupt Enable */
+
+/* MISR1 bits */
+#define DP83822_RX_ERR_HF_INT_EN	BIT(0)
+#define DP83822_FALSE_CARRIER_HF_INT_EN	BIT(1)
+#define DP83822_ANEG_COMPLETE_INT_EN	BIT(2)
+#define DP83822_DUP_MODE_CHANGE_INT_EN	BIT(3)
+#define DP83822_SPEED_CHANGED_INT_EN	BIT(4)
+#define DP83822_LINK_STAT_INT_EN	BIT(5)
+#define DP83822_ENERGY_DET_INT_EN	BIT(6)
+#define DP83822_LINK_QUAL_INT_EN	BIT(7)
+
+/* MISR2 bits */
+#define DP83822_JABBER_DET_INT_EN	BIT(0)
+#define DP83822_WOL_PKT_INT_EN		BIT(1)
+#define DP83822_SLEEP_MODE_INT_EN	BIT(2)
+#define DP83822_MDI_XOVER_INT_EN	BIT(3)
+#define DP83822_LB_FIFO_INT_EN		BIT(4)
+#define DP83822_PAGE_RX_INT_EN		BIT(5)
+#define DP83822_ANEG_ERR_INT_EN		BIT(6)
+#define DP83822_EEE_ERROR_CHANGE_INT_EN	BIT(7)
+
+/* INT_STAT1 bits */
+#define DP83822_WOL_INT_EN	BIT(4)
+#define DP83822_WOL_INT_STAT	BIT(12)
+
+#define MII_DP83822_RXSOP1	0x04a5
+#define	MII_DP83822_RXSOP2	0x04a6
+#define	MII_DP83822_RXSOP3	0x04a7
+
+/* WoL Registers */
+#define	MII_DP83822_WOL_CFG	0x04a0
+#define	MII_DP83822_WOL_STAT	0x04a1
+#define	MII_DP83822_WOL_DA1	0x04a2
+#define	MII_DP83822_WOL_DA2	0x04a3
+#define	MII_DP83822_WOL_DA3	0x04a4
+
+/* WoL bits */
+#define DP83822_WOL_MAGIC_EN	BIT(0)
+#define DP83822_WOL_SECURE_ON	BIT(5)
+#define DP83822_WOL_EN		BIT(7)
+#define DP83822_WOL_INDICATION_SEL BIT(8)
+#define DP83822_WOL_CLR_INDICATION BIT(11)
+
+static int dp83822_ack_interrupt(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_read(phydev, MII_DP83822_MISR1);
+	if (err < 0)
+		return err;
+
+	err = phy_read(phydev, MII_DP83822_MISR2);
+	if (err < 0)
+		return err;
+
+	return 0;
+}
+
+static int dp83822_set_wol(struct phy_device *phydev,
+			   struct ethtool_wolinfo *wol)
+{
+	struct net_device *ndev = phydev->attached_dev;
+	u16 value;
+	const u8 *mac;
+
+	if (wol->wolopts & (WAKE_MAGIC | WAKE_MAGICSECURE)) {
+		mac = (const u8 *)ndev->dev_addr;
+
+		if (!is_valid_ether_addr(mac))
+			return -EINVAL;
+
+		/* MAC addresses start with byte 5, but stored in mac[0].
+		 * 822 PHYs store bytes 4|5, 2|3, 0|1
+		 */
+		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_DA1,
+			      (mac[1] << 8) | mac[0]);
+		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_DA2,
+			      (mac[3] << 8) | mac[2]);
+		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_DA3,
+			      (mac[5] << 8) | mac[4]);
+
+		value = phy_read_mmd(phydev, DP83822_DEVADDR,
+				     MII_DP83822_WOL_CFG);
+		if (wol->wolopts & WAKE_MAGIC)
+			value |= DP83822_WOL_MAGIC_EN;
+		else
+			value &= ~DP83822_WOL_MAGIC_EN;
+
+		if (wol->wolopts & WAKE_MAGICSECURE) {
+			phy_write_mmd(phydev, DP83822_DEVADDR,
+				      MII_DP83822_RXSOP1,
+				      (wol->sopass[1] << 8) | wol->sopass[0]);
+			phy_write_mmd(phydev, DP83822_DEVADDR,
+				      MII_DP83822_RXSOP2,
+				      (wol->sopass[3] << 8) | wol->sopass[2]);
+			phy_write_mmd(phydev, DP83822_DEVADDR,
+				      MII_DP83822_RXSOP3,
+				      (wol->sopass[5] << 8) | wol->sopass[4]);
+			value |= DP83822_WOL_SECURE_ON;
+		} else {
+			value &= ~DP83822_WOL_SECURE_ON;
+		}
+
+		value |= (DP83822_WOL_EN | DP83822_WOL_INDICATION_SEL |
+			  DP83822_WOL_CLR_INDICATION);
+		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
+			      value);
+	} else {
+		value = phy_read_mmd(phydev, DP83822_DEVADDR,
+				     MII_DP83822_WOL_CFG);
+		value &= ~DP83822_WOL_EN;
+		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
+			      value);
+	}
+
+	return 0;
+}
+
+static void dp83822_get_wol(struct phy_device *phydev,
+			    struct ethtool_wolinfo *wol)
+{
+	int value;
+	u16 sopass_val;
+
+	wol->supported = (WAKE_MAGIC | WAKE_MAGICSECURE);
+	wol->wolopts = 0;
+
+	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
+
+	if (value & DP83822_WOL_MAGIC_EN)
+		wol->wolopts |= WAKE_MAGIC;
+
+	if (value & DP83822_WOL_SECURE_ON) {
+		sopass_val = phy_read_mmd(phydev, DP83822_DEVADDR,
+					  MII_DP83822_RXSOP1);
+		wol->sopass[0] = (sopass_val & 0xff);
+		wol->sopass[1] = (sopass_val >> 8);
+
+		sopass_val = phy_read_mmd(phydev, DP83822_DEVADDR,
+					  MII_DP83822_RXSOP2);
+		wol->sopass[2] = (sopass_val & 0xff);
+		wol->sopass[3] = (sopass_val >> 8);
+
+		sopass_val = phy_read_mmd(phydev, DP83822_DEVADDR,
+					  MII_DP83822_RXSOP3);
+		wol->sopass[4] = (sopass_val & 0xff);
+		wol->sopass[5] = (sopass_val >> 8);
+
+		wol->wolopts |= WAKE_MAGICSECURE;
+	}
+
+	/* WoL is not enabled so set wolopts to 0 */
+	if (!(value & DP83822_WOL_EN))
+		wol->wolopts = 0;
+}
+
+static int dp83822_config_intr(struct phy_device *phydev)
+{
+	int misr_status;
+	int physcr_status;
+	int err;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
+		misr_status = phy_read(phydev, MII_DP83822_MISR1);
+		if (misr_status < 0)
+			return misr_status;
+
+		misr_status |= (DP83822_RX_ERR_HF_INT_EN |
+				DP83822_FALSE_CARRIER_HF_INT_EN |
+				DP83822_ANEG_COMPLETE_INT_EN |
+				DP83822_DUP_MODE_CHANGE_INT_EN |
+				DP83822_SPEED_CHANGED_INT_EN |
+				DP83822_LINK_STAT_INT_EN |
+				DP83822_ENERGY_DET_INT_EN |
+				DP83822_LINK_QUAL_INT_EN);
+
+		err = phy_write(phydev, MII_DP83822_MISR1, misr_status);
+		if (err < 0)
+			return err;
+
+		misr_status = phy_read(phydev, MII_DP83822_MISR2);
+		if (misr_status < 0)
+			return misr_status;
+
+		misr_status |= (DP83822_JABBER_DET_INT_EN |
+				DP83822_WOL_PKT_INT_EN |
+				DP83822_SLEEP_MODE_INT_EN |
+				DP83822_MDI_XOVER_INT_EN |
+				DP83822_LB_FIFO_INT_EN |
+				DP83822_PAGE_RX_INT_EN |
+				DP83822_ANEG_ERR_INT_EN |
+				DP83822_EEE_ERROR_CHANGE_INT_EN);
+
+		err = phy_write(phydev, MII_DP83822_MISR2, misr_status);
+		if (err < 0)
+			return err;
+
+		physcr_status = phy_read(phydev, MII_DP83822_PHYSCR);
+		if (physcr_status < 0)
+			return physcr_status;
+
+		physcr_status |= DP83822_PHYSCR_INT_OE | DP83822_PHYSCR_INTEN;
+
+	} else {
+		err = phy_write(phydev, MII_DP83822_MISR1, 0);
+		if (err < 0)
+			return err;
+
+		err = phy_write(phydev, MII_DP83822_MISR1, 0);
+		if (err < 0)
+			return err;
+
+		physcr_status = phy_read(phydev, MII_DP83822_PHYSCR);
+		if (physcr_status < 0)
+			return physcr_status;
+
+		physcr_status &= ~DP83822_PHYSCR_INTEN;
+	}
+
+	return phy_write(phydev, MII_DP83822_PHYSCR, physcr_status);
+}
+
+static int dp83822_config_init(struct phy_device *phydev)
+{
+	int err;
+	int value;
+
+	err = genphy_config_init(phydev);
+	if (err < 0)
+		return err;
+
+	value = DP83822_WOL_MAGIC_EN | DP83822_WOL_SECURE_ON | DP83822_WOL_EN;
+
+	return phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
+	      value);
+}
+
+static int dp83822_phy_reset(struct phy_device *phydev)
+{
+	int err;
+
+	err = phy_write(phydev, MII_DP83822_RESET_CTRL, DP83822_HW_RESET);
+	if (err < 0)
+		return err;
+
+	dp83822_config_init(phydev);
+
+	return 0;
+}
+
+static int dp83822_suspend(struct phy_device *phydev)
+{
+	int value;
+
+	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
+
+	if (!(value & DP83822_WOL_EN))
+		genphy_suspend(phydev);
+
+	return 0;
+}
+
+static int dp83822_resume(struct phy_device *phydev)
+{
+	int value;
+
+	genphy_resume(phydev);
+
+	value = phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
+
+	phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG, value |
+		      DP83822_WOL_CLR_INDICATION);
+
+	return 0;
+}
+
+static struct phy_driver dp83822_driver[] = {
+	{
+		.phy_id = DP83822_PHY_ID,
+		.phy_id_mask = 0xfffffff0,
+		.name = "TI DP83822",
+		.features = PHY_BASIC_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_init = dp83822_config_init,
+		.soft_reset = dp83822_phy_reset,
+		.get_wol = dp83822_get_wol,
+		.set_wol = dp83822_set_wol,
+		.ack_interrupt = dp83822_ack_interrupt,
+		.config_intr = dp83822_config_intr,
+		.config_aneg = genphy_config_aneg,
+		.read_status = genphy_read_status,
+		.suspend = dp83822_suspend,
+		.resume = dp83822_resume,
+	 },
+};
+module_phy_driver(dp83822_driver);
+
+static struct mdio_device_id __maybe_unused dp83822_tbl[] = {
+	{ DP83822_PHY_ID, 0xfffffff0 },
+	{ },
+};
+MODULE_DEVICE_TABLE(mdio, dp83822_tbl);
+
+MODULE_DESCRIPTION("Texas Instruments DP83822 PHY driver");
+MODULE_AUTHOR("Dan Murphy <dmurphy@ti.com");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
index 3de4fe4dda77..3966d43c5146 100644
--- a/drivers/net/phy/dp83848.c
+++ b/drivers/net/phy/dp83848.c
@@ -20,7 +20,6 @@
 #define TI_DP83620_PHY_ID		0x20005ce0
 #define NS_DP83848C_PHY_ID		0x20005c90
 #define TLK10X_PHY_ID			0x2000a210
-#define TI_DP83822_PHY_ID		0x2000a240
 
 /* Registers */
 #define DP83848_MICR			0x11 /* MII Interrupt Control Register */
@@ -80,7 +79,6 @@ static struct mdio_device_id __maybe_unused dp83848_tbl[] = {
 	{ NS_DP83848C_PHY_ID, 0xfffffff0 },
 	{ TI_DP83620_PHY_ID, 0xfffffff0 },
 	{ TLK10X_PHY_ID, 0xfffffff0 },
-	{ TI_DP83822_PHY_ID, 0xfffffff0 },
 	{ }
 };
 MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
@@ -110,7 +108,6 @@ static struct phy_driver dp83848_driver[] = {
 	DP83848_PHY_DRIVER(NS_DP83848C_PHY_ID, "NS DP83848C 10/100 Mbps PHY"),
 	DP83848_PHY_DRIVER(TI_DP83620_PHY_ID, "TI DP83620 10/100 Mbps PHY"),
 	DP83848_PHY_DRIVER(TLK10X_PHY_ID, "TI TLK10X 10/100 Mbps PHY"),
-	DP83848_PHY_DRIVER(TI_DP83822_PHY_ID, "TI DP83822 10/100 Mbps PHY"),
 };
 module_phy_driver(dp83848_driver);
 
-- 
2.14.0
