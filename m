From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] phy: micrel: add of configuration for LED mode
Date: Wed, 26 Feb 2014 11:48:00 +0000
Message-ID: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: f.fainelli@gmail.com, Ben Dooks <ben.dooks@codethink.co.uk>
To: linux-kernel@lists.codethink.co.uk, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-68-191-81.dsl.posilan.com ([82.68.191.81]:35174 "EHLO
	rainbowdash.ducie.codethink.co.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750918AbaBZLsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 06:48:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the led-mode property for the following PHYs
which have a single LED mode configuration value.

KSZ8001 and KSZ8041 which both use register 0x1e bits 15,14 and
KSZ8021, KSZ8031 and KSZ8051 which use register 0x1f bits 5,4
to control the LED configuration.

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
 Documentation/devicetree/bindings/net/micrel.txt | 18 +++++++++
 drivers/net/phy/micrel.c                         | 49 ++++++++++++++++++++++--
 2 files changed, 63 insertions(+), 4 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/micrel.txt

diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
new file mode 100644
index 0000000..98a3e61
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/micrel.txt
@@ -0,0 +1,18 @@
+Micrel PHY properties.
+
+These properties cover the base properties Micrel PHYs.
+
+Optional properties:
+
+ - micrel,led-mode : LED mode value to set for PHYs with configurable LEDs.
+
+              Configure the LED mode with single value. The list of PHYs and
+	      the bits that are currently supported:
+
+	      KSZ8001: register 0x1e, bits 15..14
+	      KSZ8041: register 0x1e, bits 15..14
+	      KSZ8021: register 0x1f, bits 5..4
+	      KSZ8031: register 0x1f, bits 5..4
+	      KSZ8051: register 0x1f, bits 5..4
+
+              See the respective PHY datasheet for the mode values.
diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 5a8993b..0c9e434 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -148,15 +148,52 @@ static int ks8737_config_intr(struct phy_device *phydev)
 	return rc < 0 ? rc : 0;
 }
 
+static int kszphy_setup_led(struct phy_device *phydev,
+			    unsigned int reg, unsigned int shift)
+{
+
+	struct device *dev = &phydev->dev;
+	struct device_node *of_node = dev->of_node;
+	int rc, temp;
+	u32 val;
+
+	if (!of_node && dev->parent->of_node)
+		of_node = dev->parent->of_node;
+
+	if (of_property_read_u32(of_node, "micrel,led-mode", &val))
+		return 0;
+
+	temp = phy_read(phydev, reg);
+	if (temp < 0)
+		return temp;
+
+	temp &= 3 << shift;
+	temp |= val << shift;
+	rc = phy_write(phydev, reg, temp);
+
+	return rc < 0 ? rc : 0;
+}
+
 static int kszphy_config_init(struct phy_device *phydev)
 {
 	return 0;
 }
 
+static int kszphy_config_init_led8041(struct phy_device *phydev)
+{
+	/* single led control, register 0x1e bits 15..14 */
+	return kszphy_setup_led(phydev, 0x1e, 14);
+}
+
 static int ksz8021_config_init(struct phy_device *phydev)
 {
-	int rc;
 	const u16 val = KSZPHY_OMSO_B_CAST_OFF | KSZPHY_OMSO_RMII_OVERRIDE;
+	int rc;
+
+	rc = kszphy_setup_led(phydev, 0x1f, 4);
+	if (rc)
+		dev_err(&phydev->dev, "failed to set led mode\n");
+
 	phy_write(phydev, MII_KSZPHY_OMSO, val);
 	rc = ksz_config_flags(phydev);
 	return rc < 0 ? rc : 0;
@@ -166,6 +203,10 @@ static int ks8051_config_init(struct phy_device *phydev)
 {
 	int rc;
 
+	rc = kszphy_setup_led(phydev, 0x1f, 4);
+	if (rc)
+		dev_err(&phydev->dev, "failed to set led mode\n");
+
 	rc = ksz_config_flags(phydev);
 	return rc < 0 ? rc : 0;
 }
@@ -327,7 +368,7 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
 				| SUPPORTED_Asym_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
+	.config_init	= kszphy_config_init_led8041,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
@@ -342,7 +383,7 @@ static struct phy_driver ksphy_driver[] = {
 	.features	= PHY_BASIC_FEATURES |
 			  SUPPORTED_Pause | SUPPORTED_Asym_Pause,
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
+	.config_init	= kszphy_config_init_led8041,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
@@ -371,7 +412,7 @@ static struct phy_driver ksphy_driver[] = {
 	.phy_id_mask	= 0x00ffffff,
 	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause),
 	.flags		= PHY_HAS_MAGICANEG | PHY_HAS_INTERRUPT,
-	.config_init	= kszphy_config_init,
+	.config_init	= kszphy_config_init_led8041,
 	.config_aneg	= genphy_config_aneg,
 	.read_status	= genphy_read_status,
 	.ack_interrupt	= kszphy_ack_interrupt,
-- 
1.8.5.3
