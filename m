From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC 03/13] net: phy: move phy_lookup_setting() and guts of
 phy_supported_speeds() to phy-core
Date: Tue, 25 Jul 2017 15:02:47 +0100
Message-ID: <E1da0QB-0007L2-Rk@rmk-PC.armlinux.org.uk>
References: <20170725140138.GK31807@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:50854 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751810AbdGYOCw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 10:02:52 -0400
In-Reply-To: <20170725140138.GK31807@n2100.armlinux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_lookup_setting() provides useful functionality in ethtool code
outside phylib.  Move it to phy-core and allow it to be re-used (eg,
in phylink) rather than duplicated elsewhere.  Note that this supports
the larger linkmode space.

As we move the phy settings table, we also need to move the guts of
phy_supported_speeds() as well.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/phy/phy-core.c | 126 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/phy.c      | 130 +--------------------------------------------
 include/linux/phy.h        |  15 ++++++
 3 files changed, 142 insertions(+), 129 deletions(-)

diff --git a/drivers/net/phy/phy-core.c b/drivers/net/phy/phy-core.c
index bf01a24f21ce..c07845e77004 100644
--- a/drivers/net/phy/phy-core.c
+++ b/drivers/net/phy/phy-core.c
@@ -58,6 +58,132 @@ const char *phy_duplex_to_str(unsigned int duplex)
 }
 EXPORT_SYMBOL_GPL(phy_duplex_to_str);
 
+/* A mapping of all SUPPORTED settings to speed/duplex.  This table
+ * must be grouped by speed and sorted in descending match priority
+ * - iow, descending speed. */
+static const struct phy_setting settings[] = {
+	{
+		.speed = SPEED_10000,
+		.duplex = DUPLEX_FULL,
+		.bit = ETHTOOL_LINK_MODE_10000baseKR_Full_BIT,
+	},
+	{
+		.speed = SPEED_10000,
+		.duplex = DUPLEX_FULL,
+		.bit = ETHTOOL_LINK_MODE_10000baseKX4_Full_BIT,
+	},
+	{
+		.speed = SPEED_10000,
+		.duplex = DUPLEX_FULL,
+		.bit = ETHTOOL_LINK_MODE_10000baseT_Full_BIT,
+	},
+	{
+		.speed = SPEED_2500,
+		.duplex = DUPLEX_FULL,
+		.bit = ETHTOOL_LINK_MODE_2500baseX_Full_BIT,
+	},
+	{
+		.speed = SPEED_1000,
+		.duplex = DUPLEX_FULL,
+		.bit = ETHTOOL_LINK_MODE_1000baseKX_Full_BIT,
+	},
+	{
+		.speed = SPEED_1000,
+		.duplex = DUPLEX_FULL,
+		.bit = ETHTOOL_LINK_MODE_1000baseT_Full_BIT,
+	},
+	{
+		.speed = SPEED_1000,
+		.duplex = DUPLEX_HALF,
+		.bit = ETHTOOL_LINK_MODE_1000baseT_Half_BIT,
+	},
+	{
+		.speed = SPEED_100,
+		.duplex = DUPLEX_FULL,
+		.bit = ETHTOOL_LINK_MODE_100baseT_Full_BIT,
+	},
+	{
+		.speed = SPEED_100,
+		.duplex = DUPLEX_HALF,
+		.bit = ETHTOOL_LINK_MODE_100baseT_Half_BIT,
+	},
+	{
+		.speed = SPEED_10,
+		.duplex = DUPLEX_FULL,
+		.bit = ETHTOOL_LINK_MODE_10baseT_Full_BIT,
+	},
+	{
+		.speed = SPEED_10,
+		.duplex = DUPLEX_HALF,
+		.bit = ETHTOOL_LINK_MODE_10baseT_Half_BIT,
+	},
+};
+
+/**
+ * phy_lookup_setting - lookup a PHY setting
+ * @speed: speed to match
+ * @duplex: duplex to match
+ * @mask: allowed link modes
+ * @maxbit: bit size of link modes
+ * @exact: an exact match is required
+ *
+ * Search the settings array for a setting that matches the speed and
+ * duplex, and which is supported.
+ *
+ * If @exact is unset, either an exact match or %NULL for no match will
+ * be returned.
+ *
+ * If @exact is set, an exact match, the fastest supported setting at
+ * or below the specified speed, the slowest supported setting, or if
+ * they all fail, %NULL will be returned.
+ */
+const struct phy_setting *
+phy_lookup_setting(int speed, int duplex, const unsigned long *mask,
+		   size_t maxbit, bool exact)
+{
+	const struct phy_setting *p, *match = NULL, *last = NULL;
+	int i;
+
+	for (i = 0, p = settings; i < ARRAY_SIZE(settings); i++, p++) {
+		if (p->bit < maxbit && test_bit(p->bit, mask)) {
+			last = p;
+			if (p->speed == speed && p->duplex == duplex) {
+				/* Exact match for speed and duplex */
+				match = p;
+				break;
+			} else if (!exact) {
+				if (!match && p->speed <= speed)
+					/* Candidate */
+					match = p;
+
+				if (p->speed < speed)
+					break;
+			}
+		}
+	}
+
+	if (!match && !exact)
+		match = last;
+
+	return match;
+}
+EXPORT_SYMBOL_GPL(phy_lookup_setting);
+
+size_t phy_speeds(unsigned int *speeds, size_t size,
+		  unsigned long *mask, size_t maxbit)
+{
+	size_t count;
+	int i;
+
+	for (i = 0, count = 0; i < ARRAY_SIZE(settings) && count < size; i++)
+		if (settings[i].bit < maxbit &&
+		    test_bit(settings[i].bit, mask) &&
+		    (count == 0 || speeds[count - 1] != settings[i].speed))
+			speeds[count++] = settings[i].speed;
+
+	return count;
+}
+
 static void mmd_phy_indirect(struct mii_bus *bus, int phy_addr, int devad,
 			     u16 regnum)
 {
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index f128a538388f..74873bc3a565 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -158,125 +158,6 @@ int phy_aneg_done(struct phy_device *phydev)
 }
 EXPORT_SYMBOL(phy_aneg_done);
 
-/* A structure for mapping a particular speed and duplex
- * combination to a particular SUPPORTED and ADVERTISED value
- */
-struct phy_setting {
-	int speed;
-	int duplex;
-	int bit;
-};
-
-/* A mapping of all SUPPORTED settings to speed/duplex.  This table
- * must be grouped by speed and sorted in descending match priority
- * - iow, descending speed. */
-static const struct phy_setting settings[] = {
-	{
-		.speed = SPEED_10000,
-		.duplex = DUPLEX_FULL,
-		.bit = ETHTOOL_LINK_MODE_10000baseKR_Full_BIT,
-	},
-	{
-		.speed = SPEED_10000,
-		.duplex = DUPLEX_FULL,
-		.bit = ETHTOOL_LINK_MODE_10000baseKX4_Full_BIT,
-	},
-	{
-		.speed = SPEED_10000,
-		.duplex = DUPLEX_FULL,
-		.bit = ETHTOOL_LINK_MODE_10000baseT_Full_BIT,
-	},
-	{
-		.speed = SPEED_2500,
-		.duplex = DUPLEX_FULL,
-		.bit = ETHTOOL_LINK_MODE_2500baseX_Full_BIT,
-	},
-	{
-		.speed = SPEED_1000,
-		.duplex = DUPLEX_FULL,
-		.bit = ETHTOOL_LINK_MODE_1000baseKX_Full_BIT,
-	},
-	{
-		.speed = SPEED_1000,
-		.duplex = DUPLEX_FULL,
-		.bit = ETHTOOL_LINK_MODE_1000baseT_Full_BIT,
-	},
-	{
-		.speed = SPEED_1000,
-		.duplex = DUPLEX_HALF,
-		.bit = ETHTOOL_LINK_MODE_1000baseT_Half_BIT,
-	},
-	{
-		.speed = SPEED_100,
-		.duplex = DUPLEX_FULL,
-		.bit = ETHTOOL_LINK_MODE_100baseT_Full_BIT,
-	},
-	{
-		.speed = SPEED_100,
-		.duplex = DUPLEX_HALF,
-		.bit = ETHTOOL_LINK_MODE_100baseT_Half_BIT,
-	},
-	{
-		.speed = SPEED_10,
-		.duplex = DUPLEX_FULL,
-		.bit = ETHTOOL_LINK_MODE_10baseT_Full_BIT,
-	},
-	{
-		.speed = SPEED_10,
-		.duplex = DUPLEX_HALF,
-		.bit = ETHTOOL_LINK_MODE_10baseT_Half_BIT,
-	},
-};
-
-/**
- * phy_lookup_setting - lookup a PHY setting
- * @speed: speed to match
- * @duplex: duplex to match
- * @mask: allowed link modes
- * @maxbit: bit size of link modes
- * @exact: an exact match is required
- *
- * Search the settings array for a setting that matches the speed and
- * duplex, and which is supported.
- *
- * If @exact is unset, either an exact match or %NULL for no match will
- * be returned.
- *
- * If @exact is set, an exact match, the fastest supported setting at
- * or below the specified speed, the slowest supported setting, or if
- * they all fail, %NULL will be returned.
- */
-static const struct phy_setting *
-phy_lookup_setting(int speed, int duplex, const unsigned long *mask,
-		   size_t maxbit, bool exact)
-{
-	const struct phy_setting *p, *match = NULL, *last = NULL;
-	int i;
-
-	for (i = 0, p = settings; i < ARRAY_SIZE(settings); i++, p++) {
-		if (p->bit < maxbit && test_bit(p->bit, mask)) {
-			last = p;
-			if (p->speed == speed && p->duplex == duplex) {
-				/* Exact match for speed and duplex */
-				match = p;
-				break;
-			} else if (!exact) {
-				if (!match && p->speed <= speed)
-					/* Candidate */
-					match = p;
-
-				if (p->speed < speed)
-					break;
-			}
-		}
-	}
-
-	if (!match && !exact)
-		match = last;
-
-	return match;
-}
-
 /**
  * phy_find_valid - find a PHY setting that matches the requested parameters
  * @speed: desired speed
@@ -313,17 +194,8 @@ unsigned int phy_supported_speeds(struct phy_device *phy,
 				  unsigned int size)
 {
 	unsigned long supported = phy->supported;
-	unsigned int count = 0;
-	unsigned int idx = 0;
-
-	for (idx = 0; idx < ARRAY_SIZE(settings) && count < size; idx++)
-		/* Assumes settings are grouped by speed */
-		if (settings[idx].bit < BITS_PER_LONG &&
-		    !test_bit(settings[idx].bit, &supported) &&
-		    (count == 0 || speeds[count - 1] != settings[idx].speed))
-			speeds[count++] = settings[idx].speed;
 
-	return count;
+	return phy_speeds(speeds, size, &supported, BITS_PER_LONG);
 }
 
 /**
diff --git a/include/linux/phy.h b/include/linux/phy.h
index 755793c29ad1..46a47d8efb95 100644
--- a/include/linux/phy.h
+++ b/include/linux/phy.h
@@ -670,6 +670,21 @@ struct phy_fixup {
 const char *phy_speed_to_str(int speed);
 const char *phy_duplex_to_str(unsigned int duplex);
 
+/* A structure for mapping a particular speed and duplex
+ * combination to a particular SUPPORTED and ADVERTISED value
+ */
+struct phy_setting {
+	u32 speed;
+	u8 duplex;
+	u8 bit;
+};
+
+const struct phy_setting *
+phy_lookup_setting(int speed, int duplex, const unsigned long *mask,
+		   size_t maxbit, bool exact);
+size_t phy_speeds(unsigned int *speeds, size_t size,
+		  unsigned long *mask, size_t maxbit);
+
 /**
  * phy_read_mmd - Convenience function for reading a register
  * from an MMD on a given PHY.
-- 
2.7.4
