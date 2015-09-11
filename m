From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH/RFC v2 net-next 1/4] phylib: Add phy_set_max_speed helper
Date: Fri, 11 Sep 2015 11:01:15 +0900
Message-ID: <1441936878-18290-2-git-send-email-horms+renesas@verge.net.au>
References: <1441936878-18290-1-git-send-email-horms+renesas@verge.net.au>
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:40846 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbbIKCBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 22:01:47 -0400
In-Reply-To: <1441936878-18290-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper to allow ethernet drivers to limit the speed of a phy
(that they are attached to).

This mainly involves factoring out the business-end of
of_set_phy_supported() and exporting a new symbol.

This code seems to be open coded in several places, in several different
variants.

This code is envisaged this will be used in situations where setting
the "max-speed" property is not appropriate, e.g. because the maximum
speed is not a property of the phy hardware.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---

v2
* First post
---
 drivers/net/phy/phy_device.c | 52 ++++++++++++++++++++++++++++----------------
 include/linux/phy.h          |  1 +
 2 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index c0f211127274..d9a020095972 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1205,6 +1205,37 @@ static int gen10g_resume(struct phy_device *phydev)
 	return 0;
 }
 
+static void __set_phy_supported(struct phy_device *phydev, u32 max_speed)
+{
+	if (!IS_ENABLED(CONFIG_OF_MDIO))
+		return;
+
+	/* The default values for phydev->supported are provided by the PHY
+	 * driver "features" member, we want to reset to sane defaults fist
+	 * before supporting higher speeds.
+	 */
+	phydev->supported &= PHY_DEFAULT_FEATURES;
+
+	switch (max_speed) {
+	default:
+		return;
+
+	case SPEED_1000:
+		phydev->supported |= PHY_1000BT_FEATURES;
+	case SPEED_100:
+		phydev->supported |= PHY_100BT_FEATURES;
+	case SPEED_10:
+		phydev->supported |= PHY_10BT_FEATURES;
+	}
+}
+
+void phy_set_max_speed(struct phy_device *phydev, u32 max_speed)
+{
+	__set_phy_supported(phydev, max_speed);
+	phydev->advertising = phydev->supported;
+}
+EXPORT_SYMBOL(phy_set_max_speed);
+
 static void of_set_phy_supported(struct phy_device *phydev)
 {
 	struct device_node *node = phydev->dev.of_node;
@@ -1216,25 +1247,8 @@ static void of_set_phy_supported(struct phy_device *phydev)
 	if (!node)
 		return;
 
-	if (!of_property_read_u32(node, "max-speed", &max_speed)) {
-		/* The default values for phydev->supported are provided by the PHY
-		 * driver "features" member, we want to reset to sane defaults fist
-		 * before supporting higher speeds.
-		 */
-		phydev->supported &= PHY_DEFAULT_FEATURES;
-
-		switch (max_speed) {
-		default:
-			return;
-
-		case SPEED_1000:
-			phydev->supported |= PHY_1000BT_FEATURES;
-		case SPEED_100:
-			phydev->supported |= PHY_100BT_FEATURES;
-		case SPEED_10:
-			phydev->supported |= PHY_10BT_FEATURES;
-		}
-	}
+	if (!of_property_read_u32(node, "max-speed", &max_speed))
+		__set_phy_supported(phydev, max_speed);
 }
 
 /**
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 962387a192f1..692b202a52af 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -794,6 +794,7 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd);
 int phy_start_interrupts(struct phy_device *phydev);
 void phy_print_status(struct phy_device *phydev);
 void phy_device_free(struct phy_device *phydev);
+void phy_set_max_speed(struct phy_device *phydev, u32 max_speed);
 
 int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask,
 		       int (*run)(struct phy_device *));
-- 
2.1.4
