From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: [PATCH] net: phy: micrel: Add KSZ8041FTL fiber mode support
Date: Thu, 14 Jul 2016 12:18:48 +0200
Message-ID: <1468491528-17515-1-git-send-email-p.zabel@pengutronix.de>
Cc: Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	devicetree@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Philipp Zabel <p.zabel@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:45228 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750959AbcGNKSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 06:18:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can't detect the FXEN (fiber mode) bootstrap pin, so configure
it via a boolean device tree property "fxen". If it is enabled,
auto-negotiation is not supported. The only available modes are
100base-fx (full duplex and half duplex).

Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>
---
I didn't see a way to reliably detect whether the PHY is set to fiber
mode in the datasheet [1], so this patch adds a device tree property
to enforce fiber mode (disable auto-negotiation, set speed to 100).

[1] http://ww1.microchip.com/downloads/en/DeviceDoc/ksz8041tl-ftl-mll.pdf
---
 .../devicetree/bindings/net/micrel-ksz8041.txt     | 24 ++++++++++++++++
 drivers/net/phy/micrel.c                           | 32 ++++++++++++++++++++--
 include/linux/micrel_phy.h                         |  1 +
 3 files changed, 55 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/micrel-ksz8041.txt

diff --git a/Documentation/devicetree/bindings/net/micrel-ksz8041.txt b/Documentation/devicetree/bindings/net/micrel-ksz8041.txt
new file mode 100644
index 0000000..4bce38d2
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/micrel-ksz8041.txt
@@ -0,0 +1,24 @@
+Micrel KSZ8041 Gigabit Ethernet PHY
+
+The KSZ8041FTL variant supports fiber mode, enabled by the FXEN boot
+strapping pin. It can't be determined from the PHY registers whether
+the PHY is in fiber mode, so a boolean device tree property can be
+used to describe this.
+
+Optional properties:
+ - fxen : KSZ8041FTL is strapped to fiber mode. Auto-negotiation is disabled
+          and the PHY can only work in 100base-fx (full and half duplex) modes.
+
+Examples:
+
+	mdio {
+		phy0: ethernet-phy@0 {
+			reg = <0>;
+			fxen;
+		};
+	};
+	ethernet@70000 {
+		status = "okay";
+		phy = <&phy0>;
+		phy-mode = "rgmii-id";
+	};
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 5a8fefc..4ecd929 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -311,6 +311,34 @@ static int kszphy_config_init(struct phy_device *phydev)
 	return 0;
 }
 
+static int ksz8041_config_init(struct phy_device *phydev)
+{
+	/* Limit supported and advertised modes in fiber mode */
+	if (of_property_read_bool(phydev->mdio.dev.of_node, "fxen")) {
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
@@ -788,8 +816,8 @@ static struct phy_driver ksphy_driver[] = {
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
