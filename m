From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 5/8] tg3: Correct 5704S flowctrl advertisements
Date: Thu, 20 Dec 2007 15:21:41 -0800
Message-ID: <1198192901.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1087 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755770AbXLTXUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 18:20:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies the 5704S hardware autoneg code to use the
administrator specified flow control parameters.  Since the 5704S uses
device specific flow control enumerations, the 1000-BaseX utility
functions are used and code was added to convert the definitions to and
from the proprietary enumerations.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9985166..e30a99f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1695,7 +1695,7 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 local_adv, u32 remote_adv
 	u32 old_tx_mode = tp->tx_mode;
 
 	if (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG) {
-		if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)
+		if (tp->tg3_flags2 & (TG3_FLG2_MII_SERDES|TG3_FLG2_HW_AUTONEG))
 			new_tg3_flags = tg3_resolve_flowctrl_1000X(local_adv,
 								   remote_adv);
 		else
@@ -2658,6 +2658,7 @@ static void tg3_init_bcm8002(struct tg3 *tp)
 
 static int tg3_setup_fiber_hw_autoneg(struct tg3 *tp, u32 mac_status)
 {
+	u16 flowctrl;
 	u32 sg_dig_ctrl, sg_dig_status;
 	u32 serdes_cfg, expected_sg_dig_ctrl;
 	int workaround, port_a;
@@ -2706,11 +2707,11 @@ static int tg3_setup_fiber_hw_autoneg(struct tg3 *tp, u32 mac_status)
 	/* Want auto-negotiation.  */
 	expected_sg_dig_ctrl = SG_DIG_USING_HW_AUTONEG | SG_DIG_COMMON_SETUP;
 
-	/* Pause capability */
-	expected_sg_dig_ctrl |= SG_DIG_PAUSE_CAP;
-
-	/* Asymettric pause */
-	expected_sg_dig_ctrl |= SG_DIG_ASYM_PAUSE;
+	flowctrl = tg3_advert_flowctrl_1000X(tp->link_config.flowctrl);
+	if (flowctrl & ADVERTISE_1000XPAUSE)
+		expected_sg_dig_ctrl |= SG_DIG_PAUSE_CAP;
+	if (flowctrl & ADVERTISE_1000XPSE_ASYM)
+		expected_sg_dig_ctrl |= SG_DIG_ASYM_PAUSE;
 
 	if (sg_dig_ctrl != expected_sg_dig_ctrl) {
 		if ((tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT) &&
@@ -2738,14 +2739,17 @@ restart_autoneg:
 
 		if ((sg_dig_status & SG_DIG_AUTONEG_COMPLETE) &&
 		    (mac_status & MAC_STATUS_PCS_SYNCED)) {
-			u32 local_adv, remote_adv;
+			u32 local_adv = 0, remote_adv = 0;
+
+			if (sg_dig_ctrl & SG_DIG_PAUSE_CAP)
+				local_adv |= ADVERTISE_1000XPAUSE;
+			if (sg_dig_ctrl & SG_DIG_ASYM_PAUSE)
+				local_adv |= ADVERTISE_1000XPSE_ASYM;
 
-			local_adv = ADVERTISE_PAUSE_CAP;
-			remote_adv = 0;
 			if (sg_dig_status & SG_DIG_PARTNER_PAUSE_CAPABLE)
-				remote_adv |= LPA_PAUSE_CAP;
+				remote_adv |= LPA_1000XPAUSE;
 			if (sg_dig_status & SG_DIG_PARTNER_ASYM_PAUSE)
-				remote_adv |= LPA_PAUSE_ASYM;
+				remote_adv |= LPA_1000XPAUSE_ASYM;
 
 			tg3_setup_flow_control(tp, local_adv, remote_adv);
 			current_link_up = 1;


