From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH RFC] net: phy: improve phylib correctness for non-autoneg settings
Date: Fri, 24 Mar 2017 11:46:04 +0000
Message-ID: <E1crNfQ-0004QO-JM@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:46224 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756100AbdCXLqb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 07:46:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phylib has some undesirable behaviour when forcing a link mode through
ethtool.  phylib uses this code:

	idx = phy_find_valid(phy_find_setting(phydev->speed, phydev->duplex),
			features);

to find an index in the settings table.  phy_find_setting() starts at
index 0, and scans upwards looking for an exact speed and duplex match.
When it doesn't find it, it returns MAX_NUM_SETTINGS - 1, which is
10baseT-Half duplex.

phy_find_valid() then scans from the point (and effectively only checks
one entry) before bailing out, returning MAX_NUM_SETTINGS - 1.

phy_sanitize_settings() then sets ->speed to SPEED_10 and ->duplex to
DUPLEX_HALF whether or not 10baseT-Half is supported or not.  This goes
against all the comments against these functions, and 10baseT-Half may
not even be supported by the hardware.

Rework these functions, introducing a new method of scanning the table.
There are two modes of lookup that phylib wants: exact, and inexact.

- in exact mode, we return either an exact match or failure
- in inexact mode, we return an exact match if it exists, a match at
  the highest speed that is not greater than the requested speed
  (ignoring duplex), or failing that, the lowest supported speed, or
  failure.

The biggest difference is that we always check whether the entry is
supported before further consideration, so all unsupported entries are
not considered as candidates.

This results in arguably saner behaviour, better matches the comments,
and is probably what users would expect.

This becomes important as ethernet speeds increase, PHYs exist which do
not support the 10Mbit speeds, and half-duplex is likely to become
obsolete - it's already not even an option on 10Gbit and faster links.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
This is pretty stand-alone from my other patches thus far, but should
be kept together as future patches depend on this change.

 drivers/net/phy/phy.c | 102 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 64 insertions(+), 38 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index f86cbd5e6f3f..a57b97b98354 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -162,7 +162,9 @@ struct phy_setting {
 	u32 setting;
 };
 
-/* A mapping of all SUPPORTED settings to speed/duplex */
+/* A mapping of all SUPPORTED settings to speed/duplex.  This table
+ * must be grouped by speed and sorted in descending match priority
+ * - iow, descending speed. */
 static const struct phy_setting settings[] = {
 	{
 		.speed = SPEED_10000,
@@ -221,45 +223,70 @@ static const struct phy_setting settings[] = {
 	},
 };
 
-#define MAX_NUM_SETTINGS ARRAY_SIZE(settings)
-
 /**
- * phy_find_setting - find a PHY settings array entry that matches speed & duplex
+ * phy_lookup_setting - lookup a PHY setting
  * @speed: speed to match
  * @duplex: duplex to match
+ * @feature: allowed link modes
+ * @exact: an exact match is required
+ *
+ * Search the settings array for a setting that matches the speed and
+ * duplex, and which is supported.
+ *
+ * If @exact is unset, either an exact match or %NULL for no match will
+ * be returned.
  *
- * Description: Searches the settings array for the setting which
- *   matches the desired speed and duplex, and returns the index
- *   of that setting.  Returns the index of the last setting if
- *   none of the others match.
+ * If @exact is set, an exact match, the fastest supported setting at
+ * or below the specified speed, the slowest supported setting, or if
+ * they all fail, %NULL will be returned.
  */
-static inline unsigned int phy_find_setting(int speed, int duplex)
+static const struct phy_setting *
+phy_lookup_setting(int speed, int duplex, u32 features, bool exact)
 {
-	unsigned int idx = 0;
+	const struct phy_setting *p, *match = NULL, *last = NULL;
+	int i;
+
+	for (i = 0, p = settings; i < ARRAY_SIZE(settings); i++, p++) {
+		if (p->setting & features) {
+			last = p;
+			if (p->speed == speed && p->duplex == duplex) {
+				/* Exact match for speed and duplex */
+				match = p;
+				break;
+			} else if (!exact) {
+				if (!match && p->speed <= speed)
+					/* Candidate */
+					match = p;
 
-	while (idx < ARRAY_SIZE(settings) &&
-	       (settings[idx].speed != speed || settings[idx].duplex != duplex))
-		idx++;
+				if (p->speed < speed)
+					break;
+			}
+		}
+	}
+
+	if (!match && !exact)
+		match = last;
 
-	return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;
+	return match;
 }
 
 /**
- * phy_find_valid - find a PHY setting that matches the requested features mask
- * @idx: The first index in settings[] to search
- * @features: A mask of the valid settings
+ * phy_find_valid - find a PHY setting that matches the requested parameters
+ * @speed: desired speed
+ * @duplex: desired duplex
+ * @supported: mask of supported link modes
  *
- * Description: Returns the index of the first valid setting less
- *   than or equal to the one pointed to by idx, as determined by
- *   the mask in features.  Returns the index of the last setting
- *   if nothing else matches.
+ * Locate a supported phy setting that is, in priority order:
+ * - an exact match for the specified speed and duplex mode
+ * - a match for the specified speed, or slower speed
+ * - the slowest supported speed
+ * Returns the matched phy_setting entry, or %NULL if no supported phy
+ * settings were found.
  */
-static inline unsigned int phy_find_valid(unsigned int idx, u32 features)
+static const struct phy_setting *
+phy_find_valid(int speed, int duplex, u32 supported)
 {
-	while (idx < MAX_NUM_SETTINGS && !(settings[idx].setting & features))
-		idx++;
-
-	return idx < MAX_NUM_SETTINGS ? idx : MAX_NUM_SETTINGS - 1;
+	return phy_lookup_setting(speed, duplex, supported, false);
 }
 
 /**
@@ -308,12 +335,7 @@ unsigned int phy_supported_speeds(struct phy_device *phy,
  */
 static inline bool phy_check_valid(int speed, int duplex, u32 features)
 {
-	unsigned int idx;
-
-	idx = phy_find_valid(phy_find_setting(speed, duplex), features);
-
-	return settings[idx].speed == speed && settings[idx].duplex == duplex &&
-		(settings[idx].setting & features);
+	return !!phy_lookup_setting(speed, duplex, features, true);
 }
 
 /**
@@ -326,18 +348,22 @@ static inline bool phy_check_valid(int speed, int duplex, u32 features)
  */
 static void phy_sanitize_settings(struct phy_device *phydev)
 {
+	const struct phy_setting *setting;
 	u32 features = phydev->supported;
-	unsigned int idx;
 
 	/* Sanitize settings based on PHY capabilities */
 	if ((features & SUPPORTED_Autoneg) == 0)
 		phydev->autoneg = AUTONEG_DISABLE;
 
-	idx = phy_find_valid(phy_find_setting(phydev->speed, phydev->duplex),
-			features);
-
-	phydev->speed = settings[idx].speed;
-	phydev->duplex = settings[idx].duplex;
+	setting = phy_find_valid(phydev->speed, phydev->duplex, features);
+	if (setting) {
+		phydev->speed = setting->speed;
+		phydev->duplex = setting->duplex;
+	} else {
+		/* We failed to find anything (no supported speeds?) */
+		phydev->speed = SPEED_UNKNOWN;
+		phydev->duplex = DUPLEX_UNKNOWN;
+	}
 }
 
 /**
-- 
2.7.4
