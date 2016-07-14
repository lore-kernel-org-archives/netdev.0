From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: [PATCH] net: phy: micrel: Add KSZ8041FTL fiber mode support
Date: Thu, 14 Jul 2016 16:29:43 +0200
Message-ID: <1468506583-27299-1-git-send-email-p.zabel@pengutronix.de>
Cc: Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	devicetree@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Philipp Zabel <p.zabel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:46800 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750897AbcGNO3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 10:29:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can't detect the FXEN (fiber mode) bootstrap pin, so configure
it via a boolean device tree property "micrel,fiber-mode".
If it is enabled, auto-negotiation is not supported.
The only available modes are 100base-fx (full duplex and half duplex).

Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>
---
Changes since v1:
 - Rename device tree property from "fxen" to "micrel,fiber-mode".
 - Move device tree documentation into micrel.txt, this property could be
   useful for other PHYs, too.
---
 Documentation/devicetree/bindings/net/micrel.txt | 10 +++++++
 drivers/net/phy/micrel.c                         | 34 ++++++++++++++++++++++--
 include/linux/micrel_phy.h                       |  1 +
 3 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
index 87496a8..8d157f0 100644
--- a/Documentation/devicetree/bindings/net/micrel.txt
+++ b/Documentation/devicetree/bindings/net/micrel.txt
@@ -35,3 +35,13 @@ Optional properties:
 	supported clocks:
 	- KSZ8021, KSZ8031, KSZ8081, KSZ8091: "rmii-ref": The RMII reference
 	  input clock. Used to determine the XI input clock.
+
+ - micrel,fiber-mode: If present the PHY is configured to operate in fiber mode
+
+	Some PHYs, such as the KSZ8041FTL variant, support fiber mode, enabled
+	by the FXEN boot strapping pin. It can't be determined from the PHY
+	registers whether the PHY is in fiber mode, so this boolean device tree
+	property can be used to describe it.
+
+	In fiber mode, auto-negotiation is disabled and the PHY can only work in
+	100base-fx (full and half duplex) modes.
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 5a8fefc..059f13b 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -311,6 +311,36 @@ static int kszphy_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int ksz8041_config_init(struct phy_device *phydev)
+{
+	struct device_node *of_node = phydev->mdio.dev.of_node;
+
+	/* Limit supported and advertised modes in fiber mode */
+	if (of_property_read_bool(of_node, "micrel,fiber-mode")) {
+		phydev->dev_flags |= MICREL_PHY_FXEN;
+		phydev->supported &= SUPPORTED_FIBRE |
+				     SUPPORTED_100baseT_Full |
+				     SUPPORTED_100baseT_Half;
+		phydev->advertising &= ADVERTISED_FIBRE |
+				       ADVERTISED_100baseT_Full |
+				       ADVERTISED_100baseT_Half;
+		phydev->autoneg = AUTONEG_DISABLE;
+	}
+
+	return kszphy_config_init(phydev);
+}
+
+static int ksz8041_config_aneg(struct phy_device *phydev)
+{
+	/* Skip auto-negotiation in fiber mode */
+	if (phydev->dev_flags & MICREL_PHY_FXEN) {
+		phydev->speed = SPEED_100;
+		return 0;
+	}
+
+	return genphy_config_aneg(phydev);
+}
+
 static int ksz9021_load_values_from_of(struct phy_device *phydev,
 				       const struct device_node *of_node,
 				       u16 reg,
@@ -788,8 +818,8 @@ static struct phy_driver ksphy_driver[] = {
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
 	.driver_data	= &ksz8041_type,
 	.probe		= kszphy_probe,
-	.config_init	= kszphy_config_init,
-	.config_aneg	= genphy_config_aneg,
+	.config_init	= ksz8041_config_init,
+	.config_aneg	= ksz8041_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
 	.config_intr	= kszphy_config_intr,
diff --git a/include/linux/micrel_phy.h b/include/linux/micrel_phy.h
index 2e5b194..257173e 100644
--- a/include/linux/micrel_phy.h
+++ b/include/linux/micrel_phy.h
@@ -37,6 +37,7 @@
 
 /* struct phy_device dev_flags definitions */
 #define MICREL_PHY_50MHZ_CLK	0x00000001
+#define MICREL_PHY_FXEN		0x00000002
 
 #define MICREL_KSZ9021_EXTREG_CTRL	0xB
 #define MICREL_KSZ9021_EXTREG_DATA_WRITE	0xC
-- 
2.8.1
