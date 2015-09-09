From: <Woojung.Huh@microchip.com>
Subject: [PATCH net] add microchip LAN88xx phy driver
Date: Wed, 9 Sep 2015 20:49:53 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D556925@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:52329 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752026AbbIIUt7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 16:49:59 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add Microchip LAN88XX phy driver for phylib.

Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
---
 drivers/net/phy/Kconfig      |   5 ++
 drivers/net/phy/Makefile     |   1 +
 drivers/net/phy/microchip.c  | 148 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/microchipphy.h |  73 +++++++++++++++++++++
 4 files changed, 227 insertions(+)
 create mode 100644 drivers/net/phy/microchip.c
 create mode 100644 include/linux/microchipphy.h

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index c07030d..c5ad98a 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -127,6 +127,11 @@ config DP83867_PHY
 	---help---
 	  Currently supports the DP83867 PHY.
 
+config MICROCHIP_PHY
+	tristate "Drivers for Microchip PHYs"
+	help
+	  Supports the LAN88XX PHYs.
+
 config FIXED_PHY
 	tristate "Driver for MDIO Bus/PHY emulation with fixed speed/link PHYs"
 	depends on PHYLIB
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 9bb1033..87f079c 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -37,3 +37,4 @@ obj-$(CONFIG_MDIO_BUS_MUX_MMIOREG) += mdio-mux-mmioreg.o
 obj-$(CONFIG_MDIO_SUN4I)	+= mdio-sun4i.o
 obj-$(CONFIG_MDIO_MOXART)	+= mdio-moxart.o
 obj-$(CONFIG_MDIO_BCM_UNIMAC)	+= mdio-bcm-unimac.o
+obj-$(CONFIG_MICROCHIP_PHY)	+= microchip.o
diff --git a/drivers/net/phy/microchip.c b/drivers/net/phy/microchip.c
new file mode 100644
index 0000000..c0a20eb
--- /dev/null
+++ b/drivers/net/phy/microchip.c
@@ -0,0 +1,148 @@
+/*
+ * Copyright (C) 2015 Microchip Technology
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/phy.h>
+#include <linux/microchipphy.h>
+
+#define DRIVER_AUTHOR	"WOOJUNG HUH <woojung.huh@microchip.com>"
+#define DRIVER_DESC	"Microchip LAN88XX PHY driver"
+
+struct lan88xx_priv {
+	int	chip_id;
+	int	chip_rev;
+	__u32	wolopts;
+};
+
+static int lan88xx_phy_config_intr(struct phy_device *phydev)
+{
+	int rc;
+
+	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
+		/* unmask all source and clear them before enable */
+		rc = phy_write(phydev, LAN88XX_INT_MASK, 0x7FFF);
+		rc = phy_read(phydev, LAN88XX_INT_STS);
+		rc = phy_write(phydev, LAN88XX_INT_MASK,
+			       LAN88XX_INT_MASK_MDINTPIN_EN_ |
+			       LAN88XX_INT_MASK_LINK_CHANGE_);
+	} else {
+		rc = phy_write(phydev, LAN88XX_INT_MASK, 0);
+	}
+
+	return rc < 0 ? rc : 0;
+}
+
+static int lan88xx_phy_ack_interrupt(struct phy_device *phydev)
+{
+	int rc = phy_read(phydev, LAN88XX_INT_STS);
+
+	return rc < 0 ? rc : 0;
+}
+
+int lan88xx_suspend(struct phy_device *phydev)
+{
+	struct lan88xx_priv *priv = phydev->priv;
+
+	/* do not power down PHY when WOL is enabled */
+	if (!priv->wolopts)
+		genphy_suspend(phydev);
+
+	return 0;
+}
+
+static int lan88xx_probe(struct phy_device *phydev)
+{
+	struct device *dev = &phydev->dev;
+	struct lan88xx_priv *priv;
+
+	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
+	if (!priv)
+		return -ENOMEM;
+
+	priv->wolopts = 0;
+
+	/* these values can be used to identify internal PHY */
+	priv->chip_id = phy_read_mmd_indirect(phydev, LAN88XX_MMD3_CHIP_ID,
+					      3, phydev->addr);
+	priv->chip_rev = phy_read_mmd_indirect(phydev, LAN88XX_MMD3_CHIP_REV,
+					       3, phydev->addr);
+
+	phydev->priv = priv;
+
+	return 0;
+}
+
+static void lan88xx_remove(struct phy_device *phydev)
+{
+	struct device *dev = &phydev->dev;
+	struct lan88xx_priv *priv = phydev->priv;
+
+	if (priv)
+		devm_kfree(dev, priv);
+}
+
+static int lan88xx_set_wol(struct phy_device *phydev,
+			   struct ethtool_wolinfo *wol)
+{
+	struct lan88xx_priv *priv = phydev->priv;
+
+	priv->wolopts = wol->wolopts;
+
+	return 0;
+}
+
+static struct phy_driver microchip_phy_driver[] = {
+{
+	.phy_id		= 0x0007c130,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "Microchip LAN88xx",
+
+	.features	= (PHY_GBIT_FEATURES |
+			   SUPPORTED_Pause | SUPPORTED_Asym_Pause),
+	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
+
+	.probe		= lan88xx_probe,
+	.remove		= lan88xx_remove,
+
+	.config_init	= genphy_config_init,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+
+	.ack_interrupt	= lan88xx_phy_ack_interrupt,
+	.config_intr	= lan88xx_phy_config_intr,
+
+	.suspend	= lan88xx_suspend,
+	.resume		= genphy_resume,
+	.set_wol	= lan88xx_set_wol,
+
+	.driver		= { .owner = THIS_MODULE, }
+} };
+
+module_phy_driver(microchip_phy_driver);
+
+static struct mdio_device_id __maybe_unused microchip_tbl[] = {
+	{ 0x0007c130, 0xfffffff0 },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, microchip_tbl);
+
+MODULE_AUTHOR(DRIVER_AUTHOR);
+MODULE_DESCRIPTION(DRIVER_DESC);
+MODULE_LICENSE("GPL");
diff --git a/include/linux/microchipphy.h b/include/linux/microchipphy.h
new file mode 100644
index 0000000..eb492d4
--- /dev/null
+++ b/include/linux/microchipphy.h
@@ -0,0 +1,73 @@
+/*
+ * Copyright (C) 2015 Microchip Technology
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef _MICROCHIPPHY_H
+#define _MICROCHIPPHY_H
+
+#define LAN88XX_INT_MASK			(0x19)
+#define LAN88XX_INT_MASK_MDINTPIN_EN_		(0x8000)
+#define LAN88XX_INT_MASK_SPEED_CHANGE_		(0x4000)
+#define LAN88XX_INT_MASK_LINK_CHANGE_		(0x2000)
+#define LAN88XX_INT_MASK_FDX_CHANGE_		(0x1000)
+#define LAN88XX_INT_MASK_AUTONEG_ERR_		(0x0800)
+#define LAN88XX_INT_MASK_AUTONEG_DONE_		(0x0400)
+#define LAN88XX_INT_MASK_POE_DETECT_		(0x0200)
+#define LAN88XX_INT_MASK_SYMBOL_ERR_		(0x0100)
+#define LAN88XX_INT_MASK_FAST_LINK_FAIL_	(0x0080)
+#define LAN88XX_INT_MASK_WOL_EVENT_		(0x0040)
+#define LAN88XX_INT_MASK_EXTENDED_INT_		(0x0020)
+#define LAN88XX_INT_MASK_RESERVED_		(0x0010)
+#define LAN88XX_INT_MASK_FALSE_CARRIER_		(0x0008)
+#define LAN88XX_INT_MASK_LINK_SPEED_DS_		(0x0004)
+#define LAN88XX_INT_MASK_MASTER_SLAVE_DONE_	(0x0002)
+#define LAN88XX_INT_MASK_RX__ER_		(0x0001)
+
+#define LAN88XX_INT_STS				(0x1A)
+#define LAN88XX_INT_STS_INT_ACTIVE_		(0x8000)
+#define LAN88XX_INT_STS_SPEED_CHANGE_		(0x4000)
+#define LAN88XX_INT_STS_LINK_CHANGE_		(0x2000)
+#define LAN88XX_INT_STS_FDX_CHANGE_		(0x1000)
+#define LAN88XX_INT_STS_AUTONEG_ERR_		(0x0800)
+#define LAN88XX_INT_STS_AUTONEG_DONE_		(0x0400)
+#define LAN88XX_INT_STS_POE_DETECT_		(0x0200)
+#define LAN88XX_INT_STS_SYMBOL_ERR_		(0x0100)
+#define LAN88XX_INT_STS_FAST_LINK_FAIL_		(0x0080)
+#define LAN88XX_INT_STS_WOL_EVENT_		(0x0040)
+#define LAN88XX_INT_STS_EXTENDED_INT_		(0x0020)
+#define LAN88XX_INT_STS_RESERVED_		(0x0010)
+#define LAN88XX_INT_STS_FALSE_CARRIER_		(0x0008)
+#define LAN88XX_INT_STS_LINK_SPEED_DS_		(0x0004)
+#define LAN88XX_INT_STS_MASTER_SLAVE_DONE_	(0x0002)
+#define LAN88XX_INT_STS_RX_ER_			(0x0001)
+
+#define LAN88XX_EXT_PAGE_ACCESS			(0x1F)
+#define LAN88XX_EXT_PAGE_SPACE_0		(0x0000)
+#define LAN88XX_EXT_PAGE_SPACE_1		(0x0001)
+#define LAN88XX_EXT_PAGE_SPACE_2		(0x0002)
+
+/* Extended Register Page 1 space */
+#define LAN88XX_EXT_MODE_CTRL			(0x13)
+#define LAN88XX_EXT_MODE_CTRL_MDIX_MASK_	(0x000C)
+#define LAN88XX_EXT_MODE_CTRL_AUTO_MDIX_	(0x0000)
+#define LAN88XX_EXT_MODE_CTRL_MDI_		(0x0008)
+#define LAN88XX_EXT_MODE_CTRL_MDI_X_		(0x000C)
+
+/* MMD 3 Registers */
+#define	LAN88XX_MMD3_CHIP_ID			(32877)
+#define	LAN88XX_MMD3_CHIP_REV			(32878)
+
+#endif /* _MICROCHIPPHY_H */
-- 
2.1.4
