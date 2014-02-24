From: <cristian.bercaru@freescale.com>
Subject: [PATCH v2] phy: unmask link partner capabilities
Date: Mon, 24 Feb 2014 17:52:58 +0200
Message-ID: <1393257178-25052-1-git-send-email-cristian.bercaru@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Cristian Bercaru <cristian.bercaru@freescale.com>,
	<madalin.bucur@freescale.com>, <shaohui.xie@freescale.com>,
	<shruti@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe002.messaging.microsoft.com ([207.46.163.25]:57311
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752181AbaBXPxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 10:53:10 -0500
Received: from mail55-co9 (localhost [127.0.0.1])	by mail55-co9-R.bigfish.com
 (Postfix) with ESMTP id D3B82240350	for <netdev@vger.kernel.org>; Mon, 24 Feb
 2014 15:53:09 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cristian Bercaru <cristian.bercaru@freescale.com>

Masking the link partner's capabilities with local capabilities can be
misleading in autonegotiation scenarios such as PAUSE frame
autonegotiation.
This patch calculates the join between the local capabilities and the
link parner capabilities, when it calculates the speed and duplex
settings, but does not mask any of the link partner capabilities
when it calculates PAUSE frame settings.

Signed-off-by: Cristian Bercaru <cristian.bercaru@freescale.com>
---
v2 caches (lpa & adv) and (lpa & adv << 2) in intermediate variables.

 drivers/net/phy/phy_device.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index a70b604..4b021a3 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -933,6 +933,8 @@ int genphy_read_status(struct phy_device *phydev)
 	int err;
 	int lpa;
 	int lpagb = 0;
+	int common_adv;
+	int common_adv_gb;
 
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
