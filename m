From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/6] tg3: Track LP advertising
Date: Thu, 8 Dec 2011 13:50:00 -0800
Message-ID: <1323381002-31565-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2492 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430Ab1LHVti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 16:49:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to track the autonegotiation advertisements of the
link partner and report them through ethtool.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   41 ++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/broadcom/tg3.h |    1 +
 2 files changed, 39 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index d1681db..ae1e838 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3803,6 +3803,29 @@ static bool tg3_phy_copper_an_config_ok(struct tg3 *tp, u32 *lcladv)
 	return true;
 }
 
+static bool tg3_phy_copper_fetch_rmtadv(struct tg3 *tp, u32 *rmtadv)
+{
+	u32 val, lpeth = 0;
+
+	if (!(tp->phy_flags & TG3_PHYFLG_10_100_ONLY)) {
+		if (tg3_readphy(tp, MII_STAT1000, &val))
+			return false;
+
+		lpeth = mii_stat1000_to_ethtool_lpa_t(val);
+	}
+
+	if (tg3_readphy(tp, MII_LPA, &val))
+		return false;
+
+	lpeth |= mii_lpa_to_ethtool_lpa_t(val);
+	tp->link_config.rmt_adv = lpeth;
+
+	if (tg3_flag(tp, PAUSE_AUTONEG))
+		*rmtadv = val;
+
+	return true;
+}
+
 static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 {
 	int current_link_up;
@@ -3907,6 +3930,7 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 	current_speed = SPEED_INVALID;
 	current_duplex = DUPLEX_INVALID;
 	tp->phy_flags &= ~TG3_PHYFLG_MDIX_STATE;
+	tp->link_config.rmt_adv = 0;
 
 	if (tp->phy_flags & TG3_PHYFLG_CAPACITIVE_COUPLING) {
 		err = tg3_phy_auxctl_read(tp,
@@ -3963,8 +3987,7 @@ static int tg3_setup_copper_phy(struct tg3 *tp, int force_reset)
 		if (tp->link_config.autoneg == AUTONEG_ENABLE) {
 			if ((bmcr & BMCR_ANENABLE) &&
 			    tg3_phy_copper_an_config_ok(tp, &lcl_adv) &&
-			    (tg3_flag(tp, PAUSE_AUTONEG) &&
-			     !tg3_readphy(tp, MII_LPA, &rmt_adv)))
+			    tg3_phy_copper_fetch_rmtadv(tp, &rmt_adv))
 				current_link_up = 1;
 		} else {
 			if (!(bmcr & BMCR_ANENABLE) &&
@@ -4601,6 +4624,9 @@ restart_autoneg:
 			if (sg_dig_status & SG_DIG_PARTNER_ASYM_PAUSE)
 				remote_adv |= LPA_1000XPAUSE_ASYM;
 
+			tp->link_config.rmt_adv =
+					   mii_adv_to_ethtool_adv_x(remote_adv);
+
 			tg3_setup_flow_control(tp, local_adv, remote_adv);
 			current_link_up = 1;
 			tp->serdes_counter = 0;
@@ -4672,6 +4698,9 @@ static int tg3_setup_fiber_by_hand(struct tg3 *tp, u32 mac_status)
 			if (rxflags & MR_LP_ADV_ASYM_PAUSE)
 				remote_adv |= LPA_1000XPAUSE_ASYM;
 
+			tp->link_config.rmt_adv =
+					   mii_adv_to_ethtool_adv_x(remote_adv);
+
 			tg3_setup_flow_control(tp, local_adv, remote_adv);
 
 			current_link_up = 1;
@@ -4754,6 +4783,7 @@ static int tg3_setup_fiber_phy(struct tg3 *tp, int force_reset)
 	udelay(40);
 
 	current_link_up = 0;
+	tp->link_config.rmt_adv = 0;
 	mac_status = tr32(MAC_STATUS);
 
 	if (tg3_flag(tp, HW_AUTONEG))
@@ -4845,6 +4875,7 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 	current_link_up = 0;
 	current_speed = SPEED_INVALID;
 	current_duplex = DUPLEX_INVALID;
+	tp->link_config.rmt_adv = 0;
 
 	err |= tg3_readphy(tp, MII_BMSR, &bmsr);
 	err |= tg3_readphy(tp, MII_BMSR, &bmsr);
@@ -4951,6 +4982,9 @@ static int tg3_setup_fiber_mii_phy(struct tg3 *tp, int force_reset)
 					current_duplex = DUPLEX_FULL;
 				else
 					current_duplex = DUPLEX_HALF;
+
+				tp->link_config.rmt_adv =
+					   mii_adv_to_ethtool_adv_x(remote_adv);
 			} else if (!tg3_flag(tp, 5780_CLASS)) {
 				/* Link is up via parallel detect */
 			} else {
@@ -10283,9 +10317,10 @@ static int tg3_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			cmd->advertising |= ADVERTISED_Asym_Pause;
 		}
 	}
-	if (netif_running(dev)) {
+	if (netif_running(dev) && netif_carrier_ok(dev)) {
 		ethtool_cmd_speed_set(cmd, tp->link_config.active_speed);
 		cmd->duplex = tp->link_config.active_duplex;
+		cmd->lp_advertising = tp->link_config.rmt_adv;
 		if (!(tp->phy_flags & TG3_PHYFLG_ANY_SERDES)) {
 			if (tp->phy_flags & TG3_PHYFLG_MDIX_STATE)
 				cmd->eth_tp_mdix = ETH_TP_MDI_X;
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index a2818ef..9d9f634 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2698,6 +2698,7 @@ struct tg3_link_config {
 #define DUPLEX_INVALID		0xff
 #define AUTONEG_INVALID		0xff
 	u16				active_speed;
+	u32				rmt_adv;
 
 	/* When we go in and out of low power mode we need
 	 * to swap with this state.
-- 
1.7.3.4
