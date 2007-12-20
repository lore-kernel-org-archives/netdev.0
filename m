From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 6/8] tg3: Correct sw autoneg flow control advertisements
Date: Thu, 20 Dec 2007 15:21:43 -0800
Message-ID: <1198192903.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1091 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755830AbXLTXUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 18:20:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies the software autoneg code to use the administrator
specified flow control parameters.  Since the autonegotiation code uses
alternative flow control enumerations, the 1000-BaseX utility functions
are used and code was added to convert the definitions to and from the
alternate enumerations.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e30a99f..373642c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1695,7 +1695,7 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 local_adv, u32 remote_adv
 	u32 old_tx_mode = tp->tx_mode;
 
 	if (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG) {
-		if (tp->tg3_flags2 & (TG3_FLG2_MII_SERDES|TG3_FLG2_HW_AUTONEG))
+		if (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES)
 			new_tg3_flags = tg3_resolve_flowctrl_1000X(local_adv,
 								   remote_adv);
 		else
@@ -2317,6 +2317,7 @@ struct tg3_fiber_aneginfo {
 static int tg3_fiber_aneg_smachine(struct tg3 *tp,
 				   struct tg3_fiber_aneginfo *ap)
 {
+	u16 flowctrl;
 	unsigned long delta;
 	u32 rx_cfg_reg;
 	int ret;
@@ -2416,7 +2417,12 @@ static int tg3_fiber_aneg_smachine(struct tg3 *tp,
 
 	case ANEG_STATE_ABILITY_DETECT_INIT:
 		ap->flags &= ~(MR_TOGGLE_TX);
-		ap->txconfig = (ANEG_CFG_FD | ANEG_CFG_PS1);
+		ap->txconfig = ANEG_CFG_FD;
+		flowctrl = tg3_advert_flowctrl_1000X(tp->link_config.flowctrl);
+		if (flowctrl & ADVERTISE_1000XPAUSE)
+			ap->txconfig |= ANEG_CFG_PS1;
+		if (flowctrl & ADVERTISE_1000XPSE_ASYM)
+			ap->txconfig |= ANEG_CFG_PS2;
 		tw32(MAC_TX_AUTO_NEG, ap->txconfig);
 		tp->mac_mode |= MAC_MODE_SEND_CONFIGS;
 		tw32_f(MAC_MODE, tp->mac_mode);
@@ -2562,7 +2568,7 @@ static int tg3_fiber_aneg_smachine(struct tg3 *tp,
 	return ret;
 }
 
-static int fiber_autoneg(struct tg3 *tp, u32 *flags)
+static int fiber_autoneg(struct tg3 *tp, u32 *txflags, u32 *rxflags)
 {
 	int res = 0;
 	struct tg3_fiber_aneginfo aninfo;
@@ -2596,7 +2602,8 @@ static int fiber_autoneg(struct tg3 *tp, u32 *flags)
 	tw32_f(MAC_MODE, tp->mac_mode);
 	udelay(40);
 
-	*flags = aninfo.flags;
+	*txflags = aninfo.txconfig;
+	*rxflags = aninfo.flags;
 
 	if (status == ANEG_DONE &&
 	    (aninfo.flags & (MR_AN_COMPLETE | MR_LINK_OK |
@@ -2806,18 +2813,21 @@ static int tg3_setup_fiber_by_hand(struct tg3 *tp, u32 mac_status)
 		goto out;
 
 	if (tp->link_config.autoneg == AUTONEG_ENABLE) {
-		u32 flags;
+		u32 txflags, rxflags;
 		int i;
 
-		if (fiber_autoneg(tp, &flags)) {
-			u32 local_adv, remote_adv;
+		if (fiber_autoneg(tp, &txflags, &rxflags)) {
+			u32 local_adv = 0, remote_adv = 0;
 
-			local_adv = ADVERTISE_PAUSE_CAP;
-			remote_adv = 0;
-			if (flags & MR_LP_ADV_SYM_PAUSE)
-				remote_adv |= LPA_PAUSE_CAP;
-			if (flags & MR_LP_ADV_ASYM_PAUSE)
-				remote_adv |= LPA_PAUSE_ASYM;
+			if (txflags & ANEG_CFG_PS1)
+				local_adv |= ADVERTISE_1000XPAUSE;
+			if (txflags & ANEG_CFG_PS2)
+				local_adv |= ADVERTISE_1000XPSE_ASYM;
+
+			if (rxflags & MR_LP_ADV_SYM_PAUSE)
+				remote_adv |= LPA_1000XPAUSE;
+			if (rxflags & MR_LP_ADV_ASYM_PAUSE)
+				remote_adv |= LPA_1000XPAUSE_ASYM;
 
 			tg3_setup_flow_control(tp, local_adv, remote_adv);
 
@@ -2841,6 +2851,8 @@ static int tg3_setup_fiber_by_hand(struct tg3 *tp, u32 mac_status)
 		    !(mac_status & MAC_STATUS_RCVD_CFG))
 			current_link_up = 1;
 	} else {
+		tg3_setup_flow_control(tp, 0, 0);
+
 		/* Forcing 1000FD link up. */
 		current_link_up = 1;
 


