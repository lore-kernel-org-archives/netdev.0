From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net] net: phy: ensure Gigabit features are masked off if requested
Date: Mon, 3 Feb 2014 12:35:46 -0800
Message-ID: <1391459746-2631-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <jcmvbkbc@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:35341 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbaBCUf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 15:35:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a Gigabit PHY device is connected to a 10/100Mbits capable Ethernet
MAC, the driver will restrict the phydev->supported modes to mask off
Gigabit. If the Gigabit PHY comes out of reset with the Gigabit features
set by default in MII_CTRL1000, it will keep advertising these feature,
so by the time we call genphy_config_advert(), the condition on
phydev->supported having the Gigabit features on is false, and we do not
update MII_CTRL1000 with updated values, and we keep advertising Gigabit
features, eventually configuring the PHY for Gigabit whilst the Ethernet
MAC does not support that.

This patches fixes the problem by ensuring that the Gigabit feature bits
are always cleared in MII_CTRL1000, if the PHY happens to be a Gigabit
PHY, and then, if Gigabit features are supported, setting those and
updating MII_CTRL1000 accordingly.

Reported-by: Max Filippov <jcmvbkbc@gmail.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/phy/phy_device.c | 38 ++++++++++++++++++++++++--------------
 1 file changed, 24 insertions(+), 14 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 4b03e63..82514e7 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -719,7 +719,7 @@ int phy_resume(struct phy_device *phydev)
 static int genphy_config_advert(struct phy_device *phydev)
 {
 	u32 advertise;
-	int oldadv, adv;
+	int oldadv, adv, bmsr;
 	int err, changed = 0;
 
 	/* Only allow advertising what this PHY supports */
@@ -744,26 +744,36 @@ static int genphy_config_advert(struct phy_device *phydev)
 		changed = 1;
 	}
 
+	bmsr = phy_read(phydev, MII_BMSR);
+	if (bmsr < 0)
+		return bmsr;
+
+	/* Per 802.3-2008, Section 22.2.4.2.16 Extended status all
+	 * 1000Mbits/sec capable PHYs shall have the BMSR_ESTATEN bit set to a
+	 * logical 1.
+	 */
+	if (!(bmsr & BMSR_ESTATEN))
+		return changed;
+
 	/* Configure gigabit if it's supported */
+	adv = phy_read(phydev, MII_CTRL1000);
+	if (adv < 0)
+		return adv;
+
+	oldadv = adv;
+	adv &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
+
 	if (phydev->supported & (SUPPORTED_1000baseT_Half |
 				 SUPPORTED_1000baseT_Full)) {
-		adv = phy_read(phydev, MII_CTRL1000);
-		if (adv < 0)
-			return adv;
-
-		oldadv = adv;
-		adv &= ~(ADVERTISE_1000FULL | ADVERTISE_1000HALF);
 		adv |= ethtool_adv_to_mii_ctrl1000_t(advertise);
-
-		if (adv != oldadv) {
-			err = phy_write(phydev, MII_CTRL1000, adv);
-
-			if (err < 0)
-				return err;
+		if (adv != oldadv)
 			changed = 1;
-		}
 	}
 
+	err = phy_write(phydev, MII_CTRL1000, adv);
+	if (err < 0)
+		return err;
+
 	return changed;
 }
 
-- 
1.8.3.2
