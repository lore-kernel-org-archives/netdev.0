From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/6] tg3: Integrate flowctrl check into AN adv
 check
Date: Thu, 8 Dec 2011 13:49:59 -0800
Message-ID: <1323381002-31565-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2490 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752420Ab1LHVti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 16:49:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch integrates tg3_adv_1000T_flowctrl_ok() into
tg3_copper_is_advertising_all() and renames the function
tg3_phy_copper_an_config_ok().

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   81 +++++++++++------------------------
 1 files changed, 25 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 713e37a..d1681db 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3768,65 +3768,39 @@ static int tg3_init_5401phy_dsp(struct tg3 *tp)
 	return err;
 }
 
-static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
+static bool tg3_phy_copper_an_config_ok(struct tg3 *tp, u32 *lcladv)
 {
-	u32 adv_reg, all_mask = 0;
+	u32 advmsk, tgtadv, advertising;
 
-	all_mask = ethtool_adv_to_mii_adv_t(mask) & ADVERTISE_ALL;
+	advertising = tp->link_config.advertising;
+	tgtadv = ethtool_adv_to_mii_adv_t(advertising) & ADVERTISE_ALL;
 
-	if (tg3_readphy(tp, MII_ADVERTISE, &adv_reg))
-		return 0;
+	advmsk = ADVERTISE_ALL;
+	if (tp->link_config.active_duplex == DUPLEX_FULL) {
+		tgtadv |= tg3_advert_flowctrl_1000T(tp->link_config.flowctrl);
+		advmsk |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
+	}
 
-	if ((adv_reg & ADVERTISE_ALL) != all_mask)
-		return 0;
+	if (tg3_readphy(tp, MII_ADVERTISE, lcladv))
+		return false;
+
+	if ((*lcladv & advmsk) != tgtadv)
+		return false;
 
 	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
 		u32 tg3_ctrl;
 
-		all_mask = ethtool_adv_to_mii_ctrl1000_t(mask);
+		tgtadv = ethtool_adv_to_mii_ctrl1000_t(advertising);
 
 		if (tg3_readphy(tp, MII_CTRL1000, &tg3_ctrl))
-			return 0;
+			return false;
 
 		tg3_ctrl &= (ADVERTISE_1000HALF | ADVERTISE_1000FULL);
-		if (tg3_ctrl != all_mask)
-			return 0;
-	}
-
-	return 1;
-}
-
-static int tg3_adv_1000T_flowctrl_ok(struct tg3 *tp, u32 *lcladv, u32 *rmtadv)
-{
-	u32 curadv, reqadv;
-
-	if (tg3_readphy(tp, MII_ADVERTISE, lcladv))
-		return 1;
-
-	curadv = *lcladv & (ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
-	reqadv = tg3_advert_flowctrl_1000T(tp->link_config.flowctrl);
-
-	if (tp->link_config.active_duplex == DUPLEX_FULL) {
-		if (curadv != reqadv)
-			return 0;
-
-		if (tg3_flag(tp, PAUSE_AUTONEG))
-			tg3_readphy(tp, MII_LPA, rmtadv);
-	} else {
-		/* Reprogram the advertisement register, even if it
-		 * does not affect the current link.  If the link
-		 * gets renegotiated in the future, we can save an
-		 * additional renegotiation cycle by advertising
-		 * it correctly in the first place.
-		 */
-		if (curadv != reqadv) {
-			*lcladv &= ~(ADVERTISE_PAUSE_CAP |
-				     ADVERTISE_PAUSE_ASYM);
-			tg3_writephy(tp, MII_ADVERTISE, *lcladv | reqadv);
-		}
+		if (tg3_ctrl != tgtadv)
+			return false;
 	}
 
-	return 1;
+	return true;
 }
 
 static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
@@ -3988,12 +3962,10 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 
 		if (tp->link_config.autoneg == AUTONEG_ENABLE) {
 			if ((bmcr & BMCR_ANENABLE) &&
-			    tg3_copper_is_advertising_all(tp,
-						tp->link_config.advertising)) {
-				if (tg3_adv_1000T_flowctrl_ok(tp, &lcl_adv,
-								  &rmt_adv))
-					current_link_up = 1;
-			}
+			    tg3_phy_copper_an_config_ok(tp, &lcl_adv) &&
+			    (tg3_flag(tp, PAUSE_AUTONEG) &&
+			     !tg3_readphy(tp, MII_LPA, &rmt_adv)))
+				current_link_up = 1;
 		} else {
 			if (!(bmcr & BMCR_ANENABLE) &&
 			    tp->link_config.speed == current_speed &&
@@ -13323,7 +13295,7 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 	if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES) &&
 	    !tg3_flag(tp, ENABLE_APE) &&
 	    !tg3_flag(tp, ENABLE_ASF)) {
-		u32 bmsr, mask;
+		u32 bmsr, dummy;
 
 		tg3_readphy(tp, MII_BMSR, &bmsr);
 		if (!tg3_readphy(tp, MII_BMSR, &bmsr) &&
@@ -13336,10 +13308,7 @@ static int __devinit tg3_phy_probe(struct tg3 *tp)
 
 		tg3_phy_set_wirespeed(tp);
 
-		mask = (ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
-			ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
-			ADVERTISED_1000baseT_Half | ADVERTISED_1000baseT_Full);
-		if (!tg3_copper_is_advertising_all(tp, mask)) {
+		if (!tg3_phy_copper_an_config_ok(tp, &dummy)) {
 			tg3_phy_autoneg_cfg(tp, tp->link_config.advertising,
 					    tp->link_config.flowctrl);
 
-- 
1.7.3.4
