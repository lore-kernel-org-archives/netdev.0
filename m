From: Bernd Edlinger <bernd.edlinger@hotmail.de>
Subject: [PATCHv2] Add a driver for Renesas uPD60620 and uPD60620A PHYs
Date: Sun, 8 Oct 2017 13:40:08 +0000
Message-ID: <AM5PR0701MB2657AEF45DB8CDEC543A8A11E4770@AM5PR0701MB2657.eurprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oln040092066096.outbound.protection.outlook.com ([40.92.66.96]:54464
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751179AbdJHNkL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Oct 2017 09:40:11 -0400
Content-Language: de-DE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bernd Edlinger <bernd.edlinger@hotmail.de>
---
 drivers/net/phy/Kconfig    |   5 +++
 drivers/net/phy/Makefile   |   1 +
 drivers/net/phy/uPD60620.c | 109 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 115 insertions(+)
 create mode 100644 drivers/net/phy/uPD60620.c

diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index cd931cf..e2cf8ff 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -366,6 +366,11 @@ config REALTEK_PHY
 	---help---
 	  Supports the Realtek 821x PHY.
 
+config RENESAS_PHY
+	tristate "Driver for Renesas PHYs"
+	---help---
+	  Supports the Renesas PHYs uPD60620 and uPD60620A.
+
 config ROCKCHIP_PHY
         tristate "Driver for Rockchip Ethernet PHYs"
         ---help---
diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 416df92..1404ad3 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -72,6 +72,7 @@ obj-$(CONFIG_MICROSEMI_PHY)	+= mscc.o
 obj-$(CONFIG_NATIONAL_PHY)	+= national.o
 obj-$(CONFIG_QSEMI_PHY)		+= qsemi.o
 obj-$(CONFIG_REALTEK_PHY)	+= realtek.o
+obj-$(CONFIG_RENESAS_PHY)	+= uPD60620.o
 obj-$(CONFIG_ROCKCHIP_PHY)	+= rockchip.o
 obj-$(CONFIG_SMSC_PHY)		+= smsc.o
 obj-$(CONFIG_STE10XP)		+= ste10Xp.o
diff --git a/drivers/net/phy/uPD60620.c b/drivers/net/phy/uPD60620.c
new file mode 100644
index 0000000..96b3347
--- /dev/null
+++ b/drivers/net/phy/uPD60620.c
@@ -0,0 +1,109 @@
+/*
+ * Driver for the Renesas PHY uPD60620.
+ *
+ * Copyright (C) 2015 Softing Industrial Automation GmbH
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/phy.h>
+
+#define UPD60620_PHY_ID    0xb8242824
+
+/* Extended Registers and values */
+/* PHY Special Control/Status    */
+#define PHY_PHYSCR         0x1F      /* PHY.31 */
+#define PHY_PHYSCR_10MB    0x0004    /* PHY speed = 10mb */
+#define PHY_PHYSCR_100MB   0x0008    /* PHY speed = 100mb */
+#define PHY_PHYSCR_DUPLEX  0x0010    /* PHY Duplex */
+
+/* PHY Special Modes */
+#define PHY_SPM            0x12      /* PHY.18 */
+
+/* Init PHY */
+
+static int upd60620_config_init(struct phy_device *phydev)
+{
+	/* Enable support for passive HUBs (could be a strap option) */
+	/* PHYMODE: All speeds, HD in parallel detect */
+	return phy_write(phydev, PHY_SPM, 0x0180 | phydev->mdio.addr);
+}
+
+/* Get PHY status from common registers */
+
+static int upd60620_read_status(struct phy_device *phydev)
+{
+	int phy_state;
+
+	/* Read negotiated state */
+	phy_state = phy_read(phydev, MII_BMSR);
+	if (phy_state < 0)
+		return phy_state;
+
+	phydev->link = 0;
+	phydev->lp_advertising = 0;
+	phydev->pause = 0;
+	phydev->asym_pause = 0;
+
+	if (phy_state & (BMSR_ANEGCOMPLETE | BMSR_LSTATUS)) {
+		phy_state = phy_read(phydev, PHY_PHYSCR);
+		if (phy_state < 0)
+			return phy_state;
+
+		if (phy_state & (PHY_PHYSCR_10MB | PHY_PHYSCR_100MB)) {
+			phydev->link = 1;
+			phydev->speed = SPEED_10;
+			phydev->duplex = DUPLEX_HALF;
+
+			if (phy_state & PHY_PHYSCR_100MB)
+				phydev->speed = SPEED_100;
+			if (phy_state & PHY_PHYSCR_DUPLEX)
+				phydev->duplex = DUPLEX_FULL;
+
+			phy_state = phy_read(phydev, MII_LPA);
+			if (phy_state < 0)
+				return phy_state;
+
+			phydev->lp_advertising
+				= mii_lpa_to_ethtool_lpa_t(phy_state);
+
+			if (phydev->duplex == DUPLEX_FULL) {
+				if (phy_state & LPA_PAUSE_CAP)
+					phydev->pause = 1;
+				if (phy_state & LPA_PAUSE_ASYM)
+					phydev->asym_pause = 1;
+			}
+		}
+	}
+	return 0;
+}
+
+MODULE_DESCRIPTION("Renesas uPD60620 PHY driver");
+MODULE_AUTHOR("Bernd Edlinger <bernd.edlinger@hotmail.de>");
+MODULE_LICENSE("GPL");
+
+static struct phy_driver upd60620_driver[1] = { {
+	.phy_id         = UPD60620_PHY_ID,
+	.phy_id_mask    = 0xfffffffe,
+	.name           = "Renesas uPD60620",
+	.features       = PHY_BASIC_FEATURES,
+	.flags          = 0,
+	.config_init    = upd60620_config_init,
+	.config_aneg    = genphy_config_aneg,
+	.read_status    = upd60620_read_status,
+} };
+
+module_phy_driver(upd60620_driver);
+
+static struct mdio_device_id __maybe_unused upd60620_tbl[] = {
+	{ UPD60620_PHY_ID, 0xfffffffe },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, upd60620_tbl);
-- 
1.9.1
