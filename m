From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/8] tg3: Add 1000T & 1000X flowctrl resolvers
Date: Thu, 20 Dec 2007 15:21:34 -0800
Message-ID: <1198192894.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1627 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752954AbXLTXUq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 18:20:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds two new utility functions to resolve flow control.  One
function resolves flow control based on 1000-BaseT register definitions.
The other resolves flow control based on 1000-Base X register
definitions.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d503214..0cb0a6a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1612,6 +1612,50 @@ static void tg3_link_report(struct tg3 *tp)
 	}
 }
 
+static u8 tg3_resolve_flowctrl_1000T(u16 lcladv, u16 rmtadv)
+{
+	u8 cap = 0;
+
+	if (lcladv & ADVERTISE_PAUSE_CAP) {
+		if (lcladv & ADVERTISE_PAUSE_ASYM) {
+			if (rmtadv & LPA_PAUSE_CAP)
+				cap = TG3_FLOW_CTRL_TX | TG3_FLOW_CTRL_RX;
+			else if (rmtadv & LPA_PAUSE_ASYM)
+				cap = TG3_FLOW_CTRL_RX;
+		} else {
+			if (rmtadv & LPA_PAUSE_CAP)
+				cap = TG3_FLOW_CTRL_TX | TG3_FLOW_CTRL_RX;
+		}
+	} else if (lcladv & ADVERTISE_PAUSE_ASYM) {
+		if ((rmtadv & LPA_PAUSE_CAP) && (rmtadv & LPA_PAUSE_ASYM))
+			cap = TG3_FLOW_CTRL_TX;
+	}
+
+	return cap;
+}
+
+static u8 tg3_resolve_flowctrl_1000X(u16 lcladv, u16 rmtadv)
+{
+	u8 cap = 0;
+
+	if (lcladv & ADVERTISE_1000XPAUSE) {
+		if (lcladv & ADVERTISE_1000XPSE_ASYM) {
+			if (rmtadv & LPA_1000XPAUSE)
+				cap = TG3_FLOW_CTRL_TX | TG3_FLOW_CTRL_RX;
+			else if (rmtadv & LPA_1000XPAUSE_ASYM)
+				cap = TG3_FLOW_CTRL_RX;
+		} else {
+			if (rmtadv & LPA_1000XPAUSE)
+				cap = TG3_FLOW_CTRL_TX | TG3_FLOW_CTRL_RX;
+		}
+	} else if (lcladv & ADVERTISE_1000XPSE_ASYM) {
+		if ((rmtadv & LPA_1000XPAUSE) && (rmtadv & LPA_1000XPAUSE_ASYM))
+			cap = TG3_FLOW_CTRL_TX;
+	}
+
+	return cap;
+}
+
 static void tg3_setup_flow_control(struct tg3 *tp, u32 local_adv, u32 remote_adv)
 {
 	u8 new_tg3_flags = 0;
@@ -1619,42 +1663,12 @@ static void tg3_setup_flow_control(struct tg3 *tp, u32 local_adv, u32 remote_adv
 	u32 old_tx_mode = tp->tx_mode;
 
 	if (tp->tg3_flags & TG3_FLAG_PAUSE_AUTONEG) {
-
-		/* Convert 1000BaseX flow control bits to 1000BaseT
-		 * bits before resolving flow control.
-		 */
-		if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES) {
-			local_adv &= ~(ADVERTISE_PAUSE_CAP |
-				       ADVERTISE_PAUSE_ASYM);
-			remote_adv &= ~(LPA_PAUSE_CAP | LPA_PAUSE_ASYM);
-
-			if (local_adv & ADVERTISE_1000XPAUSE)
-				local_adv |= ADVERTISE_PAUSE_CAP;
-			if (local_adv & ADVERTISE_1000XPSE_ASYM)
-				local_adv |= ADVERTISE_PAUSE_ASYM;
-			if (remote_adv & LPA_1000XPAUSE)
-				remote_adv |= LPA_PAUSE_CAP;
-			if (remote_adv & LPA_1000XPAUSE_ASYM)
-				remote_adv |= LPA_PAUSE_ASYM;
-		}
-
-		if (local_adv & ADVERTISE_PAUSE_CAP) {
-			if (local_adv & ADVERTISE_PAUSE_ASYM) {
-				if (remote_adv & LPA_PAUSE_CAP)
-					new_tg3_flags = TG3_FLOW_CTRL_RX |
-							TG3_FLOW_CTRL_TX;
-				else if (remote_adv & LPA_PAUSE_ASYM)
-					new_tg3_flags = TG3_FLOW_CTRL_RX;
-			} else {
-				if (remote_adv & LPA_PAUSE_CAP)
-					new_tg3_flags = TG3_FLOW_CTRL_RX |
-							TG3_FLOW_CTRL_TX;
-			}
-		} else if (local_adv & ADVERTISE_PAUSE_ASYM) {
-			if ((remote_adv & LPA_PAUSE_CAP) &&
-			    (remote_adv & LPA_PAUSE_ASYM))
-				new_tg3_flags = TG3_FLOW_CTRL_TX;
-		}
+		if (tp->tg3_flags2 & TG3_FLG2_MII_SERDES)
+			new_tg3_flags = tg3_resolve_flowctrl_1000X(local_adv,
+								   remote_adv);
+		else
+			new_tg3_flags = tg3_resolve_flowctrl_1000T(local_adv,
+								   remote_adv);
 	} else {
 		new_tg3_flags = tp->link_config.flowctrl;
 	}


