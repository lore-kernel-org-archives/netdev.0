From: <cristian.bercaru@freescale.com>
Subject: [PATCH v3] phy: unmask link partner capabilities
Date: Tue, 25 Feb 2014 10:22:48 +0200
Message-ID: <1393316568-24891-1-git-send-email-cristian.bercaru@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cristian Bercaru <cristian.bercaru@freescale.com>,
	<madalin.bucur@freescale.com>, <shaohui.xie@freescale.com>,
	<shruti@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:9115 "EHLO
	va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751485AbaBYIW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 03:22:58 -0500
Received: from mail91-va3 (localhost [127.0.0.1])	by mail91-va3-R.bigfish.com
 (Postfix) with ESMTP id BFA11601AA	for <netdev@vger.kernel.org>; Tue, 25 Feb
 2014 08:22:57 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cristian Bercaru <cristian.bercaru@freescale.com>

Masking the link partner's capabilities with local capabilities can be
misleading in autonegotiation scenarios such as PAUSE frame
autonegotiation.
This patch calculates the join between the local capabilities and the
link parner capabilities, when it determines the speed and duplex
settings, but does not mask any of the link partner capabilities when
it calculates PAUSE frame settings.

Signed-off-by: Cristian Bercaru <cristian.bercaru@freescale.com>
---
v3 initializes 'common_adv_gb'

 drivers/net/phy/phy_device.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index a70b604..a2fbb3e 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -933,6 +933,8 @@ int genphy_read_status(struct phy_device *phydev)
 	int err;
 	int lpa;
 	int lpagb = 0;
+	int common_adv;
+	int common_adv_gb = 0;
 
 	/* Update the link, but return if there was an error */
 	err = genphy_update_link(phydev);
@@ -954,7 +956,7 @@ int genphy_read_status(struct phy_device *phydev)
 
 			phydev->lp_advertising =
 				mii_stat1000_to_ethtool_lpa_t(lpagb);
-			lpagb &= adv << 2;
+			common_adv_gb = lpagb & adv << 2;
 		}
 
 		lpa = phy_read(phydev, MII_LPA);
@@ -967,25 +969,25 @@ int genphy_read_status(struct phy_device *phydev)
 		if (adv < 0)
 			return adv;
 
-		lpa &= adv;
+		common_adv = lpa & adv;
 
 		phydev->speed = SPEED_10;
 		phydev->duplex = DUPLEX_HALF;
 		phydev->pause = 0;
 		phydev->asym_pause = 0;
 
-		if (lpagb & (LPA_1000FULL | LPA_1000HALF)) {
+		if (common_adv_gb & (LPA_1000FULL | LPA_1000HALF)) {
 			phydev->speed = SPEED_1000;
 
-			if (lpagb & LPA_1000FULL)
+			if (common_adv_gb & LPA_1000FULL)
 				phydev->duplex = DUPLEX_FULL;
-		} else if (lpa & (LPA_100FULL | LPA_100HALF)) {
+		} else if (common_adv & (LPA_100FULL | LPA_100HALF)) {
 			phydev->speed = SPEED_100;
 
-			if (lpa & LPA_100FULL)
+			if (common_adv & LPA_100FULL)
 				phydev->duplex = DUPLEX_FULL;
 		} else
-			if (lpa & LPA_10FULL)
+			if (common_adv & LPA_10FULL)
 				phydev->duplex = DUPLEX_FULL;
 
 		if (phydev->duplex == DUPLEX_FULL) {
-- 
1.7.11.7
