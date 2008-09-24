From: Trent Piepho <tpiepho@freescale.com>
Subject: [PATCH] PHY: Avoid unnecessary aneg restarts
Date: Wed, 24 Sep 2008 13:55:46 -0700
Message-ID: <1222289746-17837-1-git-send-email-tpiepho@freescale.com>
Cc: afleming@freescale.com, Trent Piepho <tpiepho@freescale.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:49480 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbYIXU6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 16:58:31 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id m8OKwTn8004137
	for <netdev@vger.kernel.org>; Wed, 24 Sep 2008 13:58:29 -0700 (MST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY's aneg is configured and restarted whenever the link is brought up,
e.g. when DHCP is started after the kernel has booted.  This can take the
link down for several seconds while auto-negotiation is redone.

If the advertised features haven't changed, then it shouldn't be necessary
to bring down the link and start auto-negotiation over again.

genphy_config_advert() is enhanced to return 0 when the advertised features
haven't been changed and >0 when they have been.

genphy_config_aneg() then uses this information to not call
genphy_restart_aneg() if there has been no change.

Signed-off-by: Trent Piepho <tpiepho@freescale.com>
Acked-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/phy/phy_device.c |   49 +++++++++++++++++++++++++----------------
 1 files changed, 30 insertions(+), 19 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 16a0e7d..1716274 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -419,13 +419,14 @@ EXPORT_SYMBOL(phy_detach);
  *
  * Description: Writes MII_ADVERTISE with the appropriate values,
  *   after sanitizing the values to make sure we only advertise
- *   what is supported.
+ *   what is supported.  Returns < 0 on error, 0 if the PHY's advertisement
+ *   hasn't changed, and > 0 if it has changed.
  */
 int genphy_config_advert(struct phy_device *phydev)
 {
 	u32 advertise;
-	int adv;
-	int err;
+	int oldadv, adv;
+	int err, changed = 0;
 
 	/* Only allow advertising what
 	 * this PHY supports */
@@ -433,7 +434,7 @@ int genphy_config_advert(struct phy_device *phydev)
 	advertise = phydev->advertising;
 
 	/* Setup standard advertisement */
-	adv = phy_read(phydev, MII_ADVERTISE);
+	oldadv = adv = phy_read(phydev, MII_ADVERTISE);
 
 	if (adv < 0)
 		return adv;
@@ -453,15 +454,18 @@ int genphy_config_advert(struct phy_device *phydev)
 	if (advertise & ADVERTISED_Asym_Pause)
 		adv |= ADVERTISE_PAUSE_ASYM;
 
-	err = phy_write(phydev, MII_ADVERTISE, adv);
+	if (adv != oldadv) {
+		err = phy_write(phydev, MII_ADVERTISE, adv);
 
-	if (err < 0)
-		return err;
+		if (err < 0)
+			return err;
+		changed = 1;
+	}
 
 	/* Configure gigabit if it's supported */
 	if (phydev->supported & (SUPPORTED_1000baseT_Half |
 				SUPPORTED_1000baseT_Full)) {
-		adv = phy_read(phydev, MII_CTRL1000);
+		oldadv = adv = phy_read(phydev, MII_CTRL1000);
 
 		if (adv < 0)
 			return adv;
@@ -471,13 +475,17 @@ int genphy_config_advert(struct phy_device *phydev)
 			adv |= ADVERTISE_1000HALF;
 		if (advertise & SUPPORTED_1000baseT_Full)
 			adv |= ADVERTISE_1000FULL;
-		err = phy_write(phydev, MII_CTRL1000, adv);
 
-		if (err < 0)
-			return err;
+		if (adv != oldadv) {
+			err = phy_write(phydev, MII_CTRL1000, adv);
+
+			if (err < 0)
+				return err;
+			changed = 1;
+		}
 	}
 
-	return adv;
+	return changed;
 }
 EXPORT_SYMBOL(genphy_config_advert);
 
@@ -561,19 +569,22 @@ int genphy_restart_aneg(struct phy_device *phydev)
  */
 int genphy_config_aneg(struct phy_device *phydev)
 {
-	int err = 0;
+	int result = 0;
 
 	if (AUTONEG_ENABLE == phydev->autoneg) {
-		err = genphy_config_advert(phydev);
+		int result = genphy_config_advert(phydev);
 
-		if (err < 0)
-			return err;
+		if (result < 0) /* error */
+			return result;
 
-		err = genphy_restart_aneg(phydev);
+		/* Only restart aneg if we are advertising something different
+		 * than we were before.	 */
+		if (result > 0)
+			result = genphy_restart_aneg(phydev);
 	} else
-		err = genphy_setup_forced(phydev);
+		result = genphy_setup_forced(phydev);
 
-	return err;
+	return result;
 }
 EXPORT_SYMBOL(genphy_config_aneg);
 
-- 
1.5.4.1

