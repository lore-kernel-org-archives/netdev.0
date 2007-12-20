From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 7/8] tg3: Fix supporting flowctrl code
Date: Thu, 20 Dec 2007 15:21:46 -0800
Message-ID: <1198192906.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1627 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754895AbXLTXUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 18:20:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does three things.  It modifies tg3_setup_flow_control() to
use the administrator requested flow control settings if
autonegotiation is turned off.  It slightly modifies the
tg3_setup_fiber_mii_phy() function to account for this new use case.
And finally, it does the same for tg3_setup_copper_phy().

The copper modifications are more than a small multi-line change.  The
new code makes an attempt to avoid a link renegotiation if the link is
active at half duplex and the only difference between the current
advertised settings and requested advertised settings is the
flow control advertisements.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 373642c..dd9229c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1694,7 +1694,8 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 local_adv, u32 remote_adv
 	u32 old_rx_mode = tp->rx_mode;
 	u32 old_tx_mode = tp->tx_mode;
 
-	if (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG) {
+	if (tp->link_config.autoneg == AUTONEG_ENABLE &&
+	    (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG)) {
 		if (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES)
 			new_tg3_flags = tg3_resolve_flowctrl_1000X(local_adv,
 								   remote_adv);
@@ -1975,10 +1976,44 @@ static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
 	return 1;
 }
 
+static int tg3_adv_1000T_flowctrl_ok(struct tg3 *tp, u32 *lcladv, u32 *rmtadv)
+{
+	u32 curadv, reqadv;
+
+	if (tg3_readphy(tp, MII_ADVERTISE, lcladv))
+		return 1;
+
+	curadv = *lcladv & (ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
+	reqadv = tg3_advert_flowctrl_1000T(tp->link_config.flowctrl);
+
+	if (tp->link_config.active_duplex == DUPLEX_FULL) {
+		if (curadv != reqadv)
+			return 0;
+
+		if (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG)
+			tg3_readphy(tp, MII_LPA, rmtadv);
+	} else {
+		/* Reprogram the advertisement register, even if it
+		 * does not affect the current link.  If the link
+		 * gets renegotiated in the future, we can save an
+		 * additional renegotiation cycle by advertising
+		 * it correctly in the first place.
+		 */
+		if (curadv != reqadv) {
+			*lcladv &= ~(ADVERTISE_PAUSE_CAP |
+				     ADVERTISE_PAUSE_ASYM);
+			tg3_writephy(tp, MII_ADVERTISE, *lcladv | reqadv);
+		}
+	}
+
+	return 1;
+}
+
 static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 {
 	int current_link_up;
 	u32 bmsr, dummy;
+	u32 lcl_adv, rmt_adv;
 	u16 current_speed;
 	u8 current_duplex;
 	int i, err;
@@ -2121,54 +2156,35 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 			udelay(10);
 		}
 
-		if (tp->link_config.autoneg == AUTONEG_ENABLE) {
-			if (bmcr & BMCR_ANENABLE) {
-				current_link_up = 1;
+		lcl_adv = 0;
+		rmt_adv = 0;
 
-				/* Force autoneg restart if we are exiting
-				 * low power mode.
-				 */
-				if (!tg3_copper_is_advertising_all(tp,
-						tp->link_config.advertising))
-					current_link_up = 0;
-			} else {
-				current_link_up = 0;
+		tp->link_config.active_speed = current_speed;
+		tp->link_config.active_duplex = current_duplex;
+
+		if (tp->link_config.autoneg == AUTONEG_ENABLE) {
+			if ((bmcr & BMCR_ANENABLE) &&
+			    tg3_copper_is_advertising_all(tp,
+						tp->link_config.advertising)) {
+				if (tg3_adv_1000T_flowctrl_ok(tp, &lcl_adv,
+								  &rmt_adv))
+					current_link_up = 1;
 			}
 		} else {
 			if (!(bmcr & BMCR_ANENABLE) &&
 			    tp->link_config.speed == current_speed &&
-			    tp->link_config.duplex == current_duplex) {
+			    tp->link_config.duplex == current_duplex &&
+			    tp->link_config.flowctrl ==
+			    tp->link_config.active_flowctrl) {
 				current_link_up = 1;
-			} else {
-				current_link_up = 0;
 			}
 		}
 
-		tp->link_config.active_speed = current_speed;
-		tp->link_config.active_duplex = current_duplex;
+		if (current_link_up == 1 &&
+		    tp->link_config.active_duplex == DUPLEX_FULL)
+			tg3_setup_flow_control(tp, lcl_adv, rmt_adv);
 	}
 
-	if (current_link_up == 1 &&
-	    (tp->link_config.active_duplex == DUPLEX_FULL) &&
-	    (tp->link_config.autoneg == AUTONEG_ENABLE)) {
-		u32 local_adv, remote_adv;
-
-		if (tg3_readphy(tp, MII_ADVERTISE, &local_adv))
-			local_adv = 0;
-
-		if (tg3_readphy(tp, MII_LPA, &remote_adv))
-			remote_adv = 0;
-
-		/* If we are not advertising what has been requested,
-		 * bring the link down and reconfigure.
-		 */
-		if (local_adv !=
-		    tg3_advert_flowctrl_1000T(tp->link_config.flowctrl)) {
-			current_link_up = 0;
-		} else {
-			tg3_setup_flow_control(tp, local_adv, remote_adv);
-		}
-	}
 relink:
 	if (current_link_up == 0 || tp->link_config.phy_is_low_power) {
 		u32 tmp;
@@ -2981,6 +2997,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 	u32 bmsr, bmcr;
 	u16 current_speed;
 	u8 current_duplex;
+	u32 local_adv, remote_adv;
 
 	tp->mac_mode |= MAC_MODE_PORT_MODE_GMII;
 	tw32_f(MAC_MODE, tp->mac_mode);
@@ -3014,7 +3031,8 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 	err |= tg3_readphy(tp, MII_BMCR, &bmcr);
 
 	if ((tp->link_config.autoneg == AUTONEG_ENABLE) && !force_reset &&
-	    (tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT)) {
+	    (tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT) &&
+	     tp->link_config.flowctrl == tp->link_config.active_flowctrl) {
 		/* do nothing, just check for link up at the end */
 	} else if (tp->link_config.autoneg == AUTONEG_ENABLE) {
 		u32 adv, new_adv;
@@ -3096,8 +3114,11 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 		else
 			current_duplex = DUPLEX_HALF;
 
+		local_adv = 0;
+		remote_adv = 0;
+
 		if (bmcr & BMCR_ANENABLE) {
-			u32 local_adv, remote_adv, common;
+			u32 common;
 
 			err |= tg3_readphy(tp, MII_ADVERTISE, &local_adv);
 			err |= tg3_readphy(tp, MII_LPA, &remote_adv);
@@ -3108,15 +3129,15 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 					current_duplex = DUPLEX_FULL;
 				else
 					current_duplex = DUPLEX_HALF;
-
-				tg3_setup_flow_control(tp, local_adv,
-						       remote_adv);
 			}
 			else
 				current_link_up = 0;
 		}
 	}
 
+	if (current_link_up == 1 && current_duplex == DUPLEX_FULL)
+		tg3_setup_flow_control(tp, local_adv, remote_adv);
+
 	tp->mac_mode &= ~MAC_MODE_HALF_DUPLEX;
 	if (tp->link_config.active_duplex == DUPLEX_HALF)
 		tp->mac_mode |= MAC_MODE_HALF_DUPLEX;


