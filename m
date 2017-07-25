From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC 01/13] net: phy: allow settings table to support more than
 32 link modes
Date: Tue, 25 Jul 2017 15:02:37 +0100
Message-ID: <E1da0Q1-0007Ko-Fu@rmk-PC.armlinux.org.uk>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:50836 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751651AbdGYOCk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 10:02:40 -0400
In-Reply-To: <20170725140138.GK31807@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the phy settings table to support more than 32 link modes by
switching to the ethtool link mode bit number representation, rather
than storing the mask.  This will allow phylink and other ethtool
code to share the settings table to look up settings.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy.c | 44 ++++++++++++++++++++++++++------------------
 1 file changed, 26 insertions(+), 18 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index d0626bf5c540..0fe478002908 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -200,7 +200,7 @@ EXPORT_SYMBOL(phy_aneg_done);
 struct phy_setting {
 	int speed;
 	int duplex;
-	u32 setting;
+	int bit;
 };
 
 /* A mapping of all SUPPORTED settings to speed/duplex.  This table
@@ -210,57 +210,57 @@ static const struct phy_setting settings[] = {
 	{
 		.speed = SPEED_10000,
 		.duplex = DUPLEX_FULL,
-		.setting = SUPPORTED_10000baseKR_Full,
+		.bit = ETHTOOL_LINK_MODE_10000baseKR_Full_BIT,
 	},
 	{
 		.speed = SPEED_10000,
 		.duplex = DUPLEX_FULL,
-		.setting = SUPPORTED_10000baseKX4_Full,
+		.bit = ETHTOOL_LINK_MODE_10000baseKX4_Full_BIT,
 	},
 	{
 		.speed = SPEED_10000,
 		.duplex = DUPLEX_FULL,
-		.setting = SUPPORTED_10000baseT_Full,
+		.bit = ETHTOOL_LINK_MODE_10000baseT_Full_BIT,
 	},
 	{
 		.speed = SPEED_2500,
 		.duplex = DUPLEX_FULL,
-		.setting = SUPPORTED_2500baseX_Full,
+		.bit = ETHTOOL_LINK_MODE_2500baseX_Full_BIT,
 	},
 	{
 		.speed = SPEED_1000,
 		.duplex = DUPLEX_FULL,
-		.setting = SUPPORTED_1000baseKX_Full,
+		.bit = ETHTOOL_LINK_MODE_1000baseKX_Full_BIT,
 	},
 	{
 		.speed = SPEED_1000,
 		.duplex = DUPLEX_FULL,
-		.setting = SUPPORTED_1000baseT_Full,
+		.bit = ETHTOOL_LINK_MODE_1000baseT_Full_BIT,
 	},
 	{
 		.speed = SPEED_1000,
 		.duplex = DUPLEX_HALF,
-		.setting = SUPPORTED_1000baseT_Half,
+		.bit = ETHTOOL_LINK_MODE_1000baseT_Half_BIT,
 	},
 	{
 		.speed = SPEED_100,
 		.duplex = DUPLEX_FULL,
-		.setting = SUPPORTED_100baseT_Full,
+		.bit = ETHTOOL_LINK_MODE_100baseT_Full_BIT,
 	},
 	{
 		.speed = SPEED_100,
 		.duplex = DUPLEX_HALF,
-		.setting = SUPPORTED_100baseT_Half,
+		.bit = ETHTOOL_LINK_MODE_100baseT_Half_BIT,
 	},
 	{
 		.speed = SPEED_10,
 		.duplex = DUPLEX_FULL,
-		.setting = SUPPORTED_10baseT_Full,
+		.bit = ETHTOOL_LINK_MODE_10baseT_Full_BIT,
 	},
 	{
 		.speed = SPEED_10,
 		.duplex = DUPLEX_HALF,
-		.setting = SUPPORTED_10baseT_Half,
+		.bit = ETHTOOL_LINK_MODE_10baseT_Half_BIT,
 	},
 };
 
@@ -268,7 +268,8 @@ static const struct phy_setting settings[] = {
  * phy_lookup_setting - lookup a PHY setting
  * @speed: speed to match
  * @duplex: duplex to match
- * @features: allowed link modes
+ * @mask: allowed link modes
+ * @maxbit: bit size of link modes
  * @exact: an exact match is required
  *
  * Search the settings array for a setting that matches the speed and
@@ -282,13 +283,14 @@ static const struct phy_setting settings[] = {
  * they all fail, %NULL will be returned.
  */
 static const struct phy_setting *
-phy_lookup_setting(int speed, int duplex, u32 features, bool exact)
+phy_lookup_setting(int speed, int duplex, const unsigned long *mask,
+		   size_t maxbit, bool exact)
 {
 	const struct phy_setting *p, *match = NULL, *last = NULL;
 	int i;
 
 	for (i = 0, p = settings; i < ARRAY_SIZE(settings); i++, p++) {
-		if (p->setting & features) {
+		if (p->bit < maxbit && test_bit(p->bit, mask)) {
 			last = p;
 			if (p->speed == speed && p->duplex == duplex) {
 				/* Exact match for speed and duplex */
@@ -327,7 +329,9 @@ phy_lookup_setting(int speed, int duplex, u32 features, bool exact)
 static const struct phy_setting *
 phy_find_valid(int speed, int duplex, u32 supported)
 {
-	return phy_lookup_setting(speed, duplex, supported, false);
+	unsigned long mask = supported;
+
+	return phy_lookup_setting(speed, duplex, &mask, BITS_PER_LONG, false);
 }
 
 /**
@@ -344,12 +348,14 @@ unsigned int phy_supported_speeds(struct phy_device *phy,
 				  unsigned int *speeds,
 				  unsigned int size)
 {
+	unsigned long supported = phy->supported;
 	unsigned int count = 0;
 	unsigned int idx = 0;
 
 	for (idx = 0; idx < ARRAY_SIZE(settings) && count < size; idx++)
 		/* Assumes settings are grouped by speed */
-		if ((settings[idx].setting & phy->supported) &&
+		if (settings[idx].bit < BITS_PER_LONG &&
+		    !test_bit(settings[idx].bit, &supported) &&
 		    (count == 0 || speeds[count - 1] != settings[idx].speed))
 			speeds[count++] = settings[idx].speed;
 
@@ -367,7 +373,9 @@ unsigned int phy_supported_speeds(struct phy_device *phy,
  */
 static inline bool phy_check_valid(int speed, int duplex, u32 features)
 {
-	return !!phy_lookup_setting(speed, duplex, features, true);
+	unsigned long mask = features;
+
+	return !!phy_lookup_setting(speed, duplex, &mask, BITS_PER_LONG, true);
 }
 
 /**
-- 
2.7.4
