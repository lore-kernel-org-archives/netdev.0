From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 2/2] net: phy: make of_set_phy_supported work with genphy driver
Date: Wed, 21 May 2014 15:29:45 +0200
Message-ID: <1400678985-24022-3-git-send-email-s.hauer@pengutronix.de>
References: <1400678985-24022-1-git-send-email-s.hauer@pengutronix.de>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49078 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaEUN3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 09:29:47 -0400
In-Reply-To: <1400678985-24022-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

of_set_phy_supported allows overwiting hardware capabilities of
a phy with values from the devicetree. of_set_phy_supported is
called right after phy_device_register in the assumption that
phy_probe is called from phy_device_register and the features
of the phy are already initialized. For the genphy driver this
is not true, here phy_probe is called later during phy_connect
time. phy_probe will then overwrite all settings done from
of_set_phy_supported
Fix this by moving of_set_phy_supported to the core phy code
and calling it from phy_probe.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/phy/phy_device.c | 36 +++++++++++++++++++++++++++++++++++-
 drivers/of/of_mdio.c         | 26 --------------------------
 2 files changed, 35 insertions(+), 27 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 9db3fba..2dcab24 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -33,6 +33,7 @@
 #include <linux/mdio.h>
 #include <linux/io.h>
 #include <linux/uaccess.h>
+#include <linux/of.h>
 
 #include <asm/irq.h>
 
@@ -1165,6 +1166,38 @@ static int gen10g_resume(struct phy_device *phydev)
 	return 0;
 }
 
+static void of_set_phy_supported(struct phy_device *phydev)
+{
+	struct device_node *node = phydev->dev.of_node;
+	u32 max_speed;
+
+	if (!IS_ENABLED(CONFIG_OF_MDIO))
+		return;
+
+	if (!node)
+		return;
+
+	if (!of_property_read_u32(node, "max-speed", &max_speed)) {
+		/* The default values for phydev->supported are provided by the PHY
+		 * driver "features" member, we want to reset to sane defaults fist
+		 * before supporting higher speeds.
+		 */
+		phydev->supported &= PHY_DEFAULT_FEATURES;
+
+		switch (max_speed) {
+		default:
+			return;
+
+		case SPEED_1000:
+			phydev->supported |= PHY_1000BT_FEATURES;
+		case SPEED_100:
+			phydev->supported |= PHY_100BT_FEATURES;
+		case SPEED_10:
+			phydev->supported |= PHY_10BT_FEATURES;
+		}
+	}
+}
+
 /**
  * phy_probe - probe and init a PHY device
  * @dev: device to probe and init
@@ -1199,7 +1232,8 @@ static int phy_probe(struct device *dev)
 	 * or both of these values
 	 */
 	phydev->supported = phydrv->features;
-	phydev->advertising = phydrv->features;
+	of_set_phy_supported(phydev);
+	phydev->advertising = phydev->supported;
 
 	/* Set the state to READY by default */
 	phydev->state = PHY_READY;
diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 9a95831..007fb7a 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -22,27 +22,6 @@
 MODULE_AUTHOR("Grant Likely <grant.likely@secretlab.ca>");
 MODULE_LICENSE("GPL");
 
-static void of_set_phy_supported(struct phy_device *phydev, u32 max_speed)
-{
-	/* The default values for phydev->supported are provided by the PHY
-	 * driver "features" member, we want to reset to sane defaults fist
-	 * before supporting higher speeds.
-	 */
-	phydev->supported &= PHY_DEFAULT_FEATURES;
-
-	switch (max_speed) {
-	default:
-		return;
-
-	case SPEED_1000:
-		phydev->supported |= PHY_1000BT_FEATURES;
-	case SPEED_100:
-		phydev->supported |= PHY_100BT_FEATURES;
-	case SPEED_10:
-		phydev->supported |= PHY_10BT_FEATURES;
-	}
-}
-
 /* Extract the clause 22 phy ID from the compatible string of the form
  * ethernet-phy-idAAAA.BBBB */
 static int of_get_phy_id(struct device_node *device, u32 *phy_id)
@@ -103,11 +82,6 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio, struct device_node *chi
 		return 1;
 	}
 
-	/* Set phydev->supported based on the "max-speed" property
-	 * if present */
-	if (!of_property_read_u32(child, "max-speed", &max_speed))
-		of_set_phy_supported(phy, max_speed);
-
 	dev_dbg(&mdio->dev, "registered phy %s at address %i\n",
 		child->name, addr);
 
-- 
2.0.0.rc0
