From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 08/10] tg3: Remove unneeded
 link_config.orig_... members
Date: Mon, 13 Feb 2012 17:20:15 -0800
Message-ID: <1329182417-28223-9-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1636 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758640Ab2BNBVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 20:21:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the unneeded link_config.orig_* members.  When the
phy is in a low power state, the TG3_PHYFLG_IS_LOW_POWER flag solely
determines how the link is configured.  When the phy is powered back up,
it can resume using the original settings.

For the phylib case, the link configuration still needs to be saved, but
since the phylib maintains its own configuration, we can repurpose the
(unused in this case) tg3 link configuration members.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   39 ++++++++++------------------------
 drivers/net/ethernet/broadcom/tg3.h |    8 -------
 2 files changed, 12 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 610997c..859bd22 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -1894,10 +1894,10 @@ static void tg3_phy_start(struct tg3 *tp)
 
 	if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) {
 		tp->phy_flags &= ~TG3_PHYFLG_IS_LOW_POWER;
-		phydev->speed = tp->link_config.orig_speed;
-		phydev->duplex = tp->link_config.orig_duplex;
-		phydev->autoneg = tp->link_config.orig_autoneg;
-		phydev->advertising = tp->link_config.orig_advertising;
+		phydev->speed = tp->link_config.speed;
+		phydev->duplex = tp->link_config.duplex;
+		phydev->autoneg = tp->link_config.autoneg;
+		phydev->advertising = tp->link_config.advertising;
 	}
 
 	phy_start(phydev);
@@ -3564,10 +3564,10 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 
 			tp->phy_flags |= TG3_PHYFLG_IS_LOW_POWER;
 
-			tp->link_config.orig_speed = phydev->speed;
-			tp->link_config.orig_duplex = phydev->duplex;
-			tp->link_config.orig_autoneg = phydev->autoneg;
-			tp->link_config.orig_advertising = phydev->advertising;
+			tp->link_config.speed = phydev->speed;
+			tp->link_config.duplex = phydev->duplex;
+			tp->link_config.autoneg = phydev->autoneg;
+			tp->link_config.advertising = phydev->advertising;
 
 			advertising = ADVERTISED_TP |
 				      ADVERTISED_Pause |
@@ -3600,12 +3600,8 @@ static int tg3_power_down_prepare(struct tg3 *tp)
 	} else {
 		do_low_power = true;
 
-		if (!(tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)) {
+		if (!(tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER))
 			tp->phy_flags |= TG3_PHYFLG_IS_LOW_POWER;
-			tp->link_config.orig_speed = tp->link_config.speed;
-			tp->link_config.orig_duplex = tp->link_config.duplex;
-			tp->link_config.orig_autoneg = tp->link_config.autoneg;
-		}
 
 		if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES))
 			tg3_setup_phy(tp, 0);
@@ -9260,12 +9256,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	}
 
 	if (!tg3_flag(tp, USE_PHYLIB)) {
-		if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER) {
+		if (tp->phy_flags & TG3_PHYFLG_IS_LOW_POWER)
 			tp->phy_flags &= ~TG3_PHYFLG_IS_LOW_POWER;
-			tp->link_config.speed = tp->link_config.orig_speed;
-			tp->link_config.duplex = tp->link_config.orig_duplex;
-			tp->link_config.autoneg = tp->link_config.orig_autoneg;
-		}
 
 		err = tg3_setup_phy(tp, 0);
 		if (err)
@@ -10614,10 +10606,6 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		tp->link_config.duplex = cmd->duplex;
 	}
 
-	tp->link_config.orig_speed = tp->link_config.speed;
-	tp->link_config.orig_duplex = tp->link_config.duplex;
-	tp->link_config.orig_autoneg = tp->link_config.autoneg;
-
 	if (netif_running(dev))
 		tg3_setup_phy(tp, 1);
 
@@ -10864,10 +10852,10 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 			if (!epause->autoneg)
 				tg3_setup_flow_control(tp, 0, 0);
 		} else {
-			tp->link_config.orig_advertising &=
+			tp->link_config.advertising &=
 					~(ADVERTISED_Pause |
 					  ADVERTISED_Asym_Pause);
-			tp->link_config.orig_advertising |= newadv;
+			tp->link_config.advertising |= newadv;
 		}
 	} else {
 		int irq_sync = 0;
@@ -13364,9 +13352,6 @@ static void __devinit tg3_phy_init_link_config(struct tg3 *tp)
 	tp->link_config.autoneg = AUTONEG_ENABLE;
 	tp->link_config.active_speed = SPEED_INVALID;
 	tp->link_config.active_duplex = DUPLEX_INVALID;
-	tp->link_config.orig_speed = SPEED_INVALID;
-	tp->link_config.orig_duplex = DUPLEX_INVALID;
-	tp->link_config.orig_autoneg = AUTONEG_INVALID;
 }
 
 static int __devinit tg3_phy_probe(struct tg3 *tp)
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index aea8f72..2ddd92e 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2707,14 +2707,6 @@ struct tg3_link_config {
 #define AUTONEG_INVALID		0xff
 	u16				active_speed;
 	u32				rmt_adv;
-
-	/* When we go in and out of low power mode we need
-	 * to swap with this state.
-	 */
-	u16				orig_speed;
-	u8				orig_duplex;
-	u8				orig_autoneg;
-	u32				orig_advertising;
 };
 
 struct tg3_bufmgr_config {
-- 
1.7.3.4
