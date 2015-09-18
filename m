From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH/RFC net-next v3 1/4] phylib: Add phy_set_max_speed helper
Date: Fri, 18 Sep 2015 15:03:20 +0900
Message-ID: <1442556203-657-2-git-send-email-horms+renesas@verge.net.au>
References: <1442556203-657-1-git-send-email-horms+renesas@verge.net.au>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Magnus Damm <magnus.damm@gmail.com>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1442556203-657-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a helper to allow ethernet drivers to limit the speed of a phy
(that they are attached to).

This mainly involves factoring out the business-end of
of_set_phy_supported() and exporting a new symbol.

This code seems to be open coded in several places, in several different
variants.

It is is envisaged that this will be used in situations where setting the
"max-speed" property in DT is not appropriate, e.g. because the maximum
speed is not a property of the phy hardware.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---
v2
* First post

v3
* As suggested by Florian Fainelli
  - Do not check for !IS_ENABLED(CONFIG_OF_MDIO) in __set_phy_supported.
    This is already done in of_set_phy_supported() and is not relevant to
    phy_set_max_speed)
  - Return -ENOTSUPP if 'max_speed' is not an unknown value
* As suggested by Sergei Shtylyov
  - White-space and comment enhancements.
---
 drivers/net/phy/phy_device.c | 59 ++++++++++++++++++++++++++++++--------------
 include/linux/phy.h          |  1 +
 2 files changed, 41 insertions(+), 19 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index c0f211127274..a4d40c5d984f 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1205,6 +1205,44 @@ static int gen10g_resume(struct phy_device *phydev)
 	return 0;
 }
 
+static int __set_phy_supported(struct phy_device *phydev, u32 max_speed)
+{
+	/* The default values for phydev->supported are provided by the PHY
+	 * driver "features" member, we want to reset to sane defaults first
+	 * before supporting higher speeds.
+	 */
+	phydev->supported &= PHY_DEFAULT_FEATURES;
+
+	switch (max_speed) {
+	default:
+		return -ENOTSUPP;
+	case SPEED_1000:
+		phydev->supported |= PHY_1000BT_FEATURES;
+		/* fall through */
+	case SPEED_100:
+		phydev->supported |= PHY_100BT_FEATURES;
+		/* fall through */
+	case SPEED_10:
+		phydev->supported |= PHY_10BT_FEATURES;
+	}
+
+	return 0;
+}
+
+int phy_set_max_speed(struct phy_device *phydev, u32 max_speed)
+{
+	int err;
+
+	err = __set_phy_supported(phydev, max_speed);
+	if (err)
+		return err;
+
+	phydev->advertising = phydev->supported;
+
+	return 0;
+}
+EXPORT_SYMBOL(phy_set_max_speed);
+
 static void of_set_phy_supported(struct phy_device *phydev)
 {
 	struct device_node *node = phydev->dev.of_node;
@@ -1216,25 +1254,8 @@ static void of_set_phy_supported(struct phy_device *phydev)
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
index 962387a192f1..66f8b718396a 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -794,6 +794,7 @@ int phy_mii_ioctl(struct phy_device *phydev, struct ifreq *ifr, int cmd);
 int phy_start_interrupts(struct phy_device *phydev);
 void phy_print_status(struct phy_device *phydev);
 void phy_device_free(struct phy_device *phydev);
+int phy_set_max_speed(struct phy_device *phydev, u32 max_speed);
 
 int phy_register_fixup(const char *bus_id, u32 phy_uid, u32 phy_uid_mask,
 		       int (*run)(struct phy_device *));
-- 
2.1.4

