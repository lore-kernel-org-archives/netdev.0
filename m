From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/9][TG3]: Improve 5704S autoneg.
Date: Wed, 27 Sep 2006 13:34:15 -0700
Message-ID: <1159389255.3411.18.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:23570 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030786AbWI0Uhv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 16:37:51 -0400
To: davem@davemloft.net, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Improve 5704S autoneg.

Improve 5704S autoneg logic by using a serdes_counter field to keep
track of the transient states.  This eliminates a 200 msec busy
loop in the code.  Autoneg will take its course without the driver
busy waiting for it to finish.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index aaf45b9..4eef798 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2406,24 +2406,27 @@ static int tg3_setup_fiber_hw_autoneg(st
 	expected_sg_dig_ctrl |= (1 << 12);
 
 	if (sg_dig_ctrl != expected_sg_dig_ctrl) {
+		if ((tp->tg3_flags2 & TG3_FLG2_PARALLEL_DETECT) &&
+		    tp->serdes_counter &&
+		    ((mac_status & (MAC_STATUS_PCS_SYNCED |
+				    MAC_STATUS_RCVD_CFG)) ==
+		     MAC_STATUS_PCS_SYNCED)) {
+			tp->serdes_counter--;
+			current_link_up = 1;
+			goto out;
+		}
+restart_autoneg:
 		if (workaround)
 			tw32_f(MAC_SERDES_CFG, serdes_cfg | 0xc011000);
 		tw32_f(SG_DIG_CTRL, expected_sg_dig_ctrl | (1 << 30));
 		udelay(5);
 		tw32_f(SG_DIG_CTRL, expected_sg_dig_ctrl);
 
-		tp->tg3_flags2 |= TG3_FLG2_PHY_JUST_INITTED;
+		tp->serdes_counter = SERDES_AN_TIMEOUT_5704S;
+		tp->tg3_flags2 &= ~TG3_FLG2_PARALLEL_DETECT;
 	} else if (mac_status & (MAC_STATUS_PCS_SYNCED |
 				 MAC_STATUS_SIGNAL_DET)) {
-		int i;
-
-		/* Giver time to negotiate (~200ms) */
-		for (i = 0; i < 40000; i++) {
-			sg_dig_status = tr32(SG_DIG_STATUS);
-			if (sg_dig_status & (0x3))
-				break;
-			udelay(5);
-		}
+		sg_dig_status = tr32(SG_DIG_STATUS);
 		mac_status = tr32(MAC_STATUS);
 
 		if ((sg_dig_status & (1 << 1)) &&
@@ -2439,10 +2442,11 @@ static int tg3_setup_fiber_hw_autoneg(st
 
 			tg3_setup_flow_control(tp, local_adv, remote_adv);
 			current_link_up = 1;
-			tp->tg3_flags2 &= ~TG3_FLG2_PHY_JUST_INITTED;
+			tp->serdes_counter = 0;
+			tp->tg3_flags2 &= ~TG3_FLG2_PARALLEL_DETECT;
 		} else if (!(sg_dig_status & (1 << 1))) {
-			if (tp->tg3_flags2 & TG3_FLG2_PHY_JUST_INITTED)
-				tp->tg3_flags2 &= ~TG3_FLG2_PHY_JUST_INITTED;
+			if (tp->serdes_counter)
+				tp->serdes_counter--;
 			else {
 				if (workaround) {
 					u32 val = serdes_cfg;
@@ -2466,9 +2470,17 @@ static int tg3_setup_fiber_hw_autoneg(st
 				    !(mac_status & MAC_STATUS_RCVD_CFG)) {
 					tg3_setup_flow_control(tp, 0, 0);
 					current_link_up = 1;
-				}
+					tp->tg3_flags2 |=
+						TG3_FLG2_PARALLEL_DETECT;
+					tp->serdes_counter =
+						SERDES_PARALLEL_DET_TIMEOUT;
+				} else
+					goto restart_autoneg;
 			}
 		}
+	} else {
+		tp->serdes_counter = SERDES_AN_TIMEOUT_5704S;
+		tp->tg3_flags2 &= ~TG3_FLG2_PARALLEL_DETECT;
 	}
 
 out:
@@ -2599,14 +2611,16 @@ static int tg3_setup_fiber_phy(struct tg
 				    MAC_STATUS_CFG_CHANGED));
 		udelay(5);
 		if ((tr32(MAC_STATUS) & (MAC_STATUS_SYNC_CHANGED |
-					 MAC_STATUS_CFG_CHANGED)) == 0)
+					 MAC_STATUS_CFG_CHANGED |
+					 MAC_STATUS_LNKSTATE_CHANGED)) == 0)
 			break;
 	}
 
 	mac_status = tr32(MAC_STATUS);
 	if ((mac_status & MAC_STATUS_PCS_SYNCED) == 0) {
 		current_link_up = 0;
-		if (tp->link_config.autoneg == AUTONEG_ENABLE) {
+		if (tp->link_config.autoneg == AUTONEG_ENABLE &&
+		    tp->serdes_counter == 0) {
 			tw32_f(MAC_MODE, (tp->mac_mode |
 					  MAC_MODE_SEND_CONFIGS));
 			udelay(1);
@@ -2711,7 +2725,7 @@ static int tg3_setup_fiber_mii_phy(struc
 			tg3_writephy(tp, MII_BMCR, bmcr);
 
 			tw32_f(MAC_EVENT, MAC_EVENT_LNKSTATE_CHANGED);
-			tp->tg3_flags2 |= TG3_FLG2_PHY_JUST_INITTED;
+			tp->serdes_counter = SERDES_AN_TIMEOUT_5714S;
 			tp->tg3_flags2 &= ~TG3_FLG2_PARALLEL_DETECT;
 
 			return err;
@@ -2816,9 +2830,9 @@ static int tg3_setup_fiber_mii_phy(struc
 
 static void tg3_serdes_parallel_detect(struct tg3 *tp)
 {
-	if (tp->tg3_flags2 & TG3_FLG2_PHY_JUST_INITTED) {
+	if (tp->serdes_counter) {
 		/* Give autoneg time to complete. */
-		tp->tg3_flags2 &= ~TG3_FLG2_PHY_JUST_INITTED;
+		tp->serdes_counter--;
 		return;
 	}
 	if (!netif_carrier_ok(tp->dev) &&
@@ -6660,12 +6674,14 @@ static void tg3_timer(unsigned long __op
 				need_setup = 1;
 			}
 			if (need_setup) {
-				tw32_f(MAC_MODE,
-				     (tp->mac_mode &
-				      ~MAC_MODE_PORT_MODE_MASK));
-				udelay(40);
-				tw32_f(MAC_MODE, tp->mac_mode);
-				udelay(40);
+				if (!tp->serdes_counter) {
+					tw32_f(MAC_MODE,
+					     (tp->mac_mode &
+					      ~MAC_MODE_PORT_MODE_MASK));
+					udelay(40);
+					tw32_f(MAC_MODE, tp->mac_mode);
+					udelay(40);
+				}
 				tg3_setup_phy(tp, 0);
 			}
 		} else if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 3ecf356..f9c81ba 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2203,7 +2203,6 @@ struct tg3 {
 #define TG3_FLG2_PCI_EXPRESS		0x00000200
 #define TG3_FLG2_ASF_NEW_HANDSHAKE	0x00000400
 #define TG3_FLG2_HW_AUTONEG		0x00000800
-#define TG3_FLG2_PHY_JUST_INITTED	0x00001000
 #define TG3_FLG2_PHY_SERDES		0x00002000
 #define TG3_FLG2_CAPACITIVE_COUPLING	0x00004000
 #define TG3_FLG2_FLASH			0x00008000
@@ -2236,6 +2235,12 @@ struct tg3 {
 	u16				asf_counter;
 	u16				asf_multiplier;
 
+	/* 1 second counter for transient serdes link events */
+	u32				serdes_counter;
+#define SERDES_AN_TIMEOUT_5704S		2
+#define SERDES_PARALLEL_DET_TIMEOUT	1
+#define SERDES_AN_TIMEOUT_5714S		1
+
 	struct tg3_link_config		link_config;
 	struct tg3_bufmgr_config	bufmgr_config;
 


