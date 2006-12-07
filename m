From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/7][TG3]: Allow partial speed advertisement.
Date: Wed, 06 Dec 2006 23:46:47 -0800
Message-ID: <1165477607.8488.30.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3275 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031748AbWLGG4p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 01:56:45 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Allow partial speed advertisement.

Honor the advertisement bitmask from ethtool.  We used to always
advertise the full capability when autoneg was set to on.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6a2f019..5dfeb64 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1558,12 +1558,6 @@ static void tg3_phy_copper_begin(struct
 
 		tg3_writephy(tp, MII_ADVERTISE, new_adv);
 	} else if (tp->link_config.speed == SPEED_INVALID) {
-		tp->link_config.advertising =
-			(ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
-			 ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
-			 ADVERTISED_1000baseT_Half | ADVERTISED_1000baseT_Full |
-			 ADVERTISED_Autoneg | ADVERTISED_MII);
-
 		if (tp->tg3_flags & TG3_FLAG_10_100_ONLY)
 			tp->link_config.advertising &=
 				~(ADVERTISED_1000baseT_Half |
@@ -1707,25 +1701,36 @@ static int tg3_init_5401phy_dsp(struct t
 	return err;
 }
 
-static int tg3_copper_is_advertising_all(struct tg3 *tp)
+static int tg3_copper_is_advertising_all(struct tg3 *tp, u32 mask)
 {
-	u32 adv_reg, all_mask;
+	u32 adv_reg, all_mask = 0;
+
+	if (mask & ADVERTISED_10baseT_Half)
+		all_mask |= ADVERTISE_10HALF;
+	if (mask & ADVERTISED_10baseT_Full)
+		all_mask |= ADVERTISE_10FULL;
+	if (mask & ADVERTISED_100baseT_Half)
+		all_mask |= ADVERTISE_100HALF;
+	if (mask & ADVERTISED_100baseT_Full)
+		all_mask |= ADVERTISE_100FULL;
 
 	if (tg3_readphy(tp, MII_ADVERTISE, &adv_reg))
 		return 0;
 
-	all_mask = (ADVERTISE_10HALF | ADVERTISE_10FULL |
-		    ADVERTISE_100HALF | ADVERTISE_100FULL);
 	if ((adv_reg & all_mask) != all_mask)
 		return 0;
 	if (!(tp->tg3_flags & TG3_FLAG_10_100_ONLY)) {
 		u32 tg3_ctrl;
 
+		all_mask = 0;
+		if (mask & ADVERTISED_1000baseT_Half)
+			all_mask |= ADVERTISE_1000HALF;
+		if (mask & ADVERTISED_1000baseT_Full)
+			all_mask |= ADVERTISE_1000FULL;
+
 		if (tg3_readphy(tp, MII_TG3_CTRL, &tg3_ctrl))
 			return 0;
 
-		all_mask = (MII_TG3_CTRL_ADV_1000_HALF |
-			    MII_TG3_CTRL_ADV_1000_FULL);
 		if ((tg3_ctrl & all_mask) != all_mask)
 			return 0;
 	}
@@ -1885,7 +1890,8 @@ static int tg3_setup_copper_phy(struct t
 				/* Force autoneg restart if we are exiting
 				 * low power mode.
 				 */
-				if (!tg3_copper_is_advertising_all(tp))
+				if (!tg3_copper_is_advertising_all(tp,
+						tp->link_config.advertising))
 					current_link_up = 0;
 			} else {
 				current_link_up = 0;
@@ -10156,7 +10162,7 @@ static int __devinit tg3_phy_probe(struc
 
 	if (!(tp->tg3_flags2 & TG3_FLG2_ANY_SERDES) &&
 	    !(tp->tg3_flags & TG3_FLAG_ENABLE_ASF)) {
-		u32 bmsr, adv_reg, tg3_ctrl;
+		u32 bmsr, adv_reg, tg3_ctrl, mask;
 
 		tg3_readphy(tp, MII_BMSR, &bmsr);
 		if (!tg3_readphy(tp, MII_BMSR, &bmsr) &&
@@ -10180,7 +10186,10 @@ static int __devinit tg3_phy_probe(struc
 					     MII_TG3_CTRL_ENABLE_AS_MASTER);
 		}
 
-		if (!tg3_copper_is_advertising_all(tp)) {
+		mask = (ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full |
+			ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full |
+			ADVERTISED_1000baseT_Half | ADVERTISED_1000baseT_Full);
+		if (!tg3_copper_is_advertising_all(tp, mask)) {
 			tg3_writephy(tp, MII_ADVERTISE, adv_reg);
 
 			if (!(tp->tg3_flags & TG3_FLAG_10_100_ONLY))


