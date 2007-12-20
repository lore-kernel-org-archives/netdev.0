From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 4/8] tg3: Replace some magic 5704S constants
Date: Thu, 20 Dec 2007 15:21:39 -0800
Message-ID: <1198192899.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1091 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755322AbXLTXUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 18:20:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch replaces magic values with preprocessor definitions for
the sg_dig_ctrl and sg_dig_status registers.  This is preparatory work
for the next patch.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 9e51457..9985166 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2683,7 +2683,7 @@ static int tg3_setup_fiber_hw_autoneg(struct tg3 *tp, u32 mac_status)
 	sg_dig_ctrl = tr32(SG_DIG_CTRL);
 
 	if (tp->link_config.autoneg != AUTONEG_ENABLE) {
-		if (sg_dig_ctrl & (1 << 31)) {
+		if (sg_dig_ctrl & SG_DIG_USING_HW_AUTONEG) {
 			if (workaround) {
 				u32 val = serdes_cfg;
 
@@ -2693,7 +2693,8 @@ static int tg3_setup_fiber_hw_autoneg(struct tg3 *tp, u32 mac_status)
 					val |= 0x4010000;
 				tw32_f(MAC_SERDES_CFG, val);
 			}
-			tw32_f(SG_DIG_CTRL, 0x01388400);
+
+			tw32_f(SG_DIG_CTRL, SG_DIG_COMMON_SETUP);
 		}
 		if (mac_status & MAC_STATUS_PCS_SYNCED) {
 			tg3_setup_flow_control(tp, 0, 0);
@@ -2703,13 +2704,13 @@ static int tg3_setup_fiber_hw_autoneg(struct tg3 *tp, u32 mac_status)
 	}
 
 	/* Want auto-negotiation.  */
-	expected_sg_dig_ctrl = 0x81388400;
+	expected_sg_dig_ctrl = SG_DIG_USING_HW_AUTONEG | SG_DIG_COMMON_SETUP;
 
 	/* Pause capability */
-	expected_sg_dig_ctrl |= (1 << 11);
+	expected_sg_dig_ctrl |= SG_DIG_PAUSE_CAP;
 
 	/* Asymettric pause */
-	expected_sg_dig_ctrl |= (1 << 12);
+	expected_sg_dig_ctrl |= SG_DIG_ASYM_PAUSE;
 
 	if (sg_dig_ctrl != expected_sg_dig_ctrl) {
 		if ((tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT) &&
@@ -2724,7 +2725,7 @@ static int tg3_setup_fiber_hw_autoneg(struct tg3 *tp, u32 mac_status)
 restart_autoneg:
 		if (workaround)
 			tw32_f(MAC_SERDES_CFG, serdes_cfg | 0xc011000);
-		tw32_f(SG_DIG_CTRL, expected_sg_dig_ctrl | (1 << 30));
+		tw32_f(SG_DIG_CTRL, expected_sg_dig_ctrl | SG_DIG_SOFT_RESET);
 		udelay(5);
 		tw32_f(SG_DIG_CTRL, expected_sg_dig_ctrl);
 
@@ -2735,22 +2736,22 @@ restart_autoneg:
 		sg_dig_status = tr32(SG_DIG_STATUS);
 		mac_status = tr32(MAC_STATUS);
 
-		if ((sg_dig_status & (1 << 1)) &&
+		if ((sg_dig_status & SG_DIG_AUTONEG_COMPLETE) &&
 		    (mac_status & MAC_STATUS_PCS_SYNCED)) {
 			u32 local_adv, remote_adv;
 
 			local_adv = ADVERTISE_PAUSE_CAP;
 			remote_adv = 0;
-			if (sg_dig_status & (1 << 19))
+			if (sg_dig_status & SG_DIG_PARTNER_PAUSE_CAPABLE)
 				remote_adv |= LPA_PAUSE_CAP;
-			if (sg_dig_status & (1 << 20))
+			if (sg_dig_status & SG_DIG_PARTNER_ASYM_PAUSE)
 				remote_adv |= LPA_PAUSE_ASYM;
 
 			tg3_setup_flow_control(tp, local_adv, remote_adv);
 			current_link_up = 1;
 			tp->serdes_counter = 0;
 			tp->tg3_flags2 &= ~TG3_FLG2_PARALLEL_DETECT;
-		} else if (!(sg_dig_status & (1 << 1))) {
+		} else if (!(sg_dig_status & SG_DIG_AUTONEG_COMPLETE)) {
 			if (tp->serdes_counter)
 				tp->serdes_counter--;
 			else {
@@ -2765,7 +2766,7 @@ restart_autoneg:
 					tw32_f(MAC_SERDES_CFG, val);
 				}
 
-				tw32_f(SG_DIG_CTRL, 0x01388400);
+				tw32_f(SG_DIG_CTRL, SG_DIG_COMMON_SETUP);
 				udelay(40);
 
 				/* Link parallel detection - link is up */
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index ac47c17..3938eb3 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -545,6 +545,8 @@
 #define  SG_DIG_FIBER_MODE		 0x00008000
 #define  SG_DIG_REMOTE_FAULT_MASK	 0x00006000
 #define  SG_DIG_PAUSE_MASK		 0x00001800
+#define  SG_DIG_PAUSE_CAP		 0x00000800
+#define  SG_DIG_ASYM_PAUSE		 0x00001000
 #define  SG_DIG_GBIC_ENABLE		 0x00000400
 #define  SG_DIG_CHECK_END_ENABLE	 0x00000200
 #define  SG_DIG_SGMII_AUTONEG_TIMER	 0x00000100
@@ -556,6 +558,11 @@
 #define  SG_DIG_AUTONEG_LOW_ENABLE	 0x00000004
 #define  SG_DIG_REMOTE_LOOPBACK		 0x00000002
 #define  SG_DIG_LOOPBACK		 0x00000001
+#define  SG_DIG_COMMON_SETUP (SG_DIG_CRC16_CLEAR_N | \
+			      SG_DIG_LOCAL_DUPLEX_STATUS | \
+			      SG_DIG_LOCAL_LINK_STATUS | \
+			      (0x2 << SG_DIG_SPEED_STATUS_SHIFT) | \
+			      SG_DIG_FIBER_MODE | SG_DIG_GBIC_ENABLE)
 #define SG_DIG_STATUS			0x000005b4
 #define  SG_DIG_CRC16_BUS_MASK		 0xffff0000
 #define  SG_DIG_PARTNER_FAULT_MASK	 0x00600000 /* If !MRADV_CRC16_SELECT */


