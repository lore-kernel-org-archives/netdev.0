From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/8] tg3: Add 1000T & 1000X flowctl adv helpers
Date: Thu, 20 Dec 2007 15:21:36 -0800
Message-ID: <1198192896.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1087 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755297AbXLTXUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 18:20:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds two functions designed to convert abstract TX & RX
flow control parameters to 1000-BaseT and 1000-BaseX autonegotiation
advertisements.  Code that uses standard definitions which statically
advertises TX & RX flow control has been replaced with code that
configures the advertisements based on administrator dictated
preferences.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0cb0a6a..9e51457 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1612,6 +1612,38 @@ static void tg3_link_report(struct tg3 *tp)
 	}
 }
 
+static u16 tg3_advert_flowctrl_1000T(u8 flow_ctrl)
+{
+	u16 miireg;
+
+	if ((flow_ctrl & TG3_FLOW_CTRL_TX) && (flow_ctrl & TG3_FLOW_CTRL_RX))
+		miireg = ADVERTISE_PAUSE_CAP;
+	else if (flow_ctrl & TG3_FLOW_CTRL_TX)
+		miireg = ADVERTISE_PAUSE_ASYM;
+	else if (flow_ctrl & TG3_FLOW_CTRL_RX)
+		miireg = ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
+	else
+		miireg = 0;
+
+	return miireg;
+}
+
+static u16 tg3_advert_flowctrl_1000X(u8 flow_ctrl)
+{
+	u16 miireg;
+
+	if ((flow_ctrl & TG3_FLOW_CTRL_TX) && (flow_ctrl & TG3_FLOW_CTRL_RX))
+		miireg = ADVERTISE_1000XPAUSE;
+	else if (flow_ctrl & TG3_FLOW_CTRL_TX)
+		miireg = ADVERTISE_1000XPSE_ASYM;
+	else if (flow_ctrl & TG3_FLOW_CTRL_RX)
+		miireg = ADVERTISE_1000XPAUSE | ADVERTISE_1000XPSE_ASYM;
+	else
+		miireg = 0;
+
+	return miireg;
+}
+
 static u8 tg3_resolve_flowctrl_1000T(u16 lcladv, u16 rmtadv)
 {
 	u8 cap = 0;
@@ -1764,7 +1796,7 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 				~(ADVERTISED_1000baseT_Half |
 				  ADVERTISED_1000baseT_Full);
 
-		new_adv = (ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+		new_adv = ADVERTISE_CSMA;
 		if (tp->link_config.advertising & ADVERTISED_10baseT_Half)
 			new_adv |= ADVERTISE_10HALF;
 		if (tp->link_config.advertising & ADVERTISED_10baseT_Full)
@@ -1773,6 +1805,9 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 			new_adv |= ADVERTISE_100HALF;
 		if (tp->link_config.advertising & ADVERTISED_100baseT_Full)
 			new_adv |= ADVERTISE_100FULL;
+
+		new_adv |= tg3_advert_flowctrl_1000T(tp->link_config.flowctrl);
+
 		tg3_writephy(tp, MII_ADVERTISE, new_adv);
 
 		if (tp->link_config.advertising &
@@ -1792,9 +1827,11 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 			tg3_writephy(tp, MII_TG3_CTRL, 0);
 		}
 	} else {
+		new_adv = tg3_advert_flowctrl_1000T(tp->link_config.flowctrl);
+		new_adv |= ADVERTISE_CSMA;
+
 		/* Asking for a specific link mode. */
 		if (tp->link_config.speed == SPEED_1000) {
-			new_adv = ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP;
 			tg3_writephy(tp, MII_ADVERTISE, new_adv);
 
 			if (tp->link_config.duplex == DUPLEX_FULL)
@@ -1805,11 +1842,7 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 			    tp->pci_chip_rev_id == CHIPREV_ID_5701_B0)
 				new_adv |= (MII_TG3_CTRL_AS_MASTER |
 					    MII_TG3_CTRL_ENABLE_AS_MASTER);
-			tg3_writephy(tp, MII_TG3_CTRL, new_adv);
 		} else {
-			tg3_writephy(tp, MII_TG3_CTRL, 0);
-
-			new_adv = ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP;
 			if (tp->link_config.speed == SPEED_100) {
 				if (tp->link_config.duplex == DUPLEX_FULL)
 					new_adv |= ADVERTISE_100FULL;
@@ -1822,7 +1855,11 @@ static void tg3_phy_copper_begin(struct tg3 *tp)
 					new_adv |= ADVERTISE_10HALF;
 			}
 			tg3_writephy(tp, MII_ADVERTISE, new_adv);
+
+			new_adv = 0;
 		}
+
+		tg3_writephy(tp, MII_TG3_CTRL, new_adv);
 	}
 
 	if (tp->link_config.autoneg == AUTONEG_DISABLE &&
@@ -2118,17 +2155,15 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 
 		if (tg3_readphy(tp, MII_ADVERTISE, &local_adv))
 			local_adv = 0;
-		local_adv &= (ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM);
 
 		if (tg3_readphy(tp, MII_LPA, &remote_adv))
 			remote_adv = 0;
 
-		remote_adv &= (LPA_PAUSE_CAP | LPA_PAUSE_ASYM);
-
-		/* If we are not advertising full pause capability,
-		 * something is wrong.  Bring the link down and reconfigure.
+		/* If we are not advertising what has been requested,
+		 * bring the link down and reconfigure.
 		 */
-		if (local_adv != ADVERTISE_PAUSE_CAP) {
+		if (local_adv !=
+		    tg3_advert_flowctrl_1000T(tp->link_config.flowctrl)) {
 			current_link_up = 0;
 		} else {
 			tg3_setup_flow_control(tp, local_adv, remote_adv);
@@ -2973,8 +3008,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 				  ADVERTISE_1000XPSE_ASYM |
 				  ADVERTISE_SLCT);
 
-		/* Always advertise symmetric PAUSE just like copper */
-		new_adv |= ADVERTISE_1000XPAUSE;
+		new_adv |= tg3_advert_flowctrl_1000X(tp->link_config.flowctrl);
 
 		if (tp->link_config.advertising & ADVERTISED_1000baseT_Half)
 			new_adv |= ADVERTISE_1000XHALF;


