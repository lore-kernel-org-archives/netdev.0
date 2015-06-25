From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 1/9] bnx2x: Correct asymmetric flow-control
Date: Thu, 25 Jun 2015 15:19:21 +0300
Message-ID: <1435234769-5625-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Yaniv Rosner <Yaniv.Rosner@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:54233 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750968AbbFYMTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 08:19:55 -0400
In-Reply-To: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes several issues relating to asymmetric configuration:
 1. When user requests to disable TX, the local-device needs to
    advertise both PAUSE and ASM_DIR, but to avoid transmitting pause
    frames. In the 578xx, it would ignore the TX disable.

 2. When user advertises RX-only, ASM_DIR was advertised instead of
    PAUSE/ASM_DIR.

 3. When changing mode, the advertised PAUSE/ASM_DIR was not cleared
    before setting new one, so disabling RX or TX had no impact on the
    'advertised' as appeared in the 'ethtool -a' output.

Signed-off-by: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 33 +++++++++++++++++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 10 +++----
 2 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 21a0d6a..b287fc8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3392,9 +3392,9 @@ static void bnx2x_calc_ieee_aneg_adv(struct bnx2x_phy *phy,
 	case BNX2X_FLOW_CTRL_AUTO:
 		switch (params->req_fc_auto_adv) {
 		case BNX2X_FLOW_CTRL_BOTH:
+		case BNX2X_FLOW_CTRL_RX:
 			*ieee_fc |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
 			break;
-		case BNX2X_FLOW_CTRL_RX:
 		case BNX2X_FLOW_CTRL_TX:
 			*ieee_fc |=
 				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
@@ -3488,14 +3488,21 @@ static void bnx2x_ext_phy_set_pause(struct link_params *params,
 	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV_PAUSE, val);
 }
 
-static void bnx2x_pause_resolve(struct link_vars *vars, u32 pause_result)
-{						/*  LD	    LP	 */
+static void bnx2x_pause_resolve(struct bnx2x_phy *phy,
+				struct link_params *params,
+				struct link_vars *vars,
+				u32 pause_result)
+{
+	struct bnx2x *bp = params->bp;
+						/*  LD	    LP	 */
 	switch (pause_result) {			/* ASYM P ASYM P */
 	case 0xb:				/*   1  0   1  1 */
+		DP(NETIF_MSG_LINK, "Flow Control: TX only\n");
 		vars->flow_ctrl = BNX2X_FLOW_CTRL_TX;
 		break;
 
 	case 0xe:				/*   1  1   1  0 */
+		DP(NETIF_MSG_LINK, "Flow Control: RX only\n");
 		vars->flow_ctrl = BNX2X_FLOW_CTRL_RX;
 		break;
 
@@ -3503,10 +3510,22 @@ static void bnx2x_pause_resolve(struct link_vars *vars, u32 pause_result)
 	case 0x7:				/*   0  1   1  1 */
 	case 0xd:				/*   1  1   0  1 */
 	case 0xf:				/*   1  1   1  1 */
-		vars->flow_ctrl = BNX2X_FLOW_CTRL_BOTH;
+		/* If the user selected to advertise RX ONLY,
+		 * although we advertised both, need to enable
+		 * RX only.
+		 */
+		if (params->req_fc_auto_adv == BNX2X_FLOW_CTRL_BOTH) {
+			DP(NETIF_MSG_LINK, "Flow Control: RX & TX\n");
+			vars->flow_ctrl = BNX2X_FLOW_CTRL_BOTH;
+		} else {
+			DP(NETIF_MSG_LINK, "Flow Control: RX only\n");
+			vars->flow_ctrl = BNX2X_FLOW_CTRL_RX;
+		}
 		break;
 
 	default:
+		DP(NETIF_MSG_LINK, "Flow Control: None\n");
+		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
 		break;
 	}
 	if (pause_result & (1<<0))
@@ -3567,7 +3586,7 @@ static void bnx2x_ext_phy_update_adv_fc(struct bnx2x_phy *phy,
 	pause_result |= (lp_pause &
 			 MDIO_AN_REG_ADV_PAUSE_MASK) >> 10;
 	DP(NETIF_MSG_LINK, "Ext PHY pause result 0x%x\n", pause_result);
-	bnx2x_pause_resolve(vars, pause_result);
+	bnx2x_pause_resolve(phy, params, vars, pause_result);
 
 }
 
@@ -5396,7 +5415,7 @@ static void bnx2x_update_adv_fc(struct bnx2x_phy *phy,
 				 MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK)>>7;
 		DP(NETIF_MSG_LINK, "pause_result CL37 0x%x\n", pause_result);
 	}
-	bnx2x_pause_resolve(vars, pause_result);
+	bnx2x_pause_resolve(phy, params, vars, pause_result);
 
 }
 
@@ -7129,7 +7148,7 @@ static void bnx2x_8073_resolve_fc(struct bnx2x_phy *phy,
 		pause_result |= (lp_pause &
 				 MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) >> 7;
 
-		bnx2x_pause_resolve(vars, pause_result);
+		bnx2x_pause_resolve(phy, params, vars, pause_result);
 		DP(NETIF_MSG_LINK, "Ext PHY CL37 pause result 0x%x\n",
 			   pause_result);
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 33501bc..a03a9f2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2287,13 +2287,11 @@ static int bnx2x_set_spio(struct bnx2x *bp, int spio, u32 mode)
 void bnx2x_calc_fc_adv(struct bnx2x *bp)
 {
 	u8 cfg_idx = bnx2x_get_link_cfg_idx(bp);
+
+	bp->port.advertising[cfg_idx] &= ~(ADVERTISED_Asym_Pause |
+					   ADVERTISED_Pause);
 	switch (bp->link_vars.ieee_fc &
 		MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK) {
-	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE:
-		bp->port.advertising[cfg_idx] &= ~(ADVERTISED_Asym_Pause |
-						   ADVERTISED_Pause);
-		break;
-
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH:
 		bp->port.advertising[cfg_idx] |= (ADVERTISED_Asym_Pause |
 						  ADVERTISED_Pause);
@@ -2304,8 +2302,6 @@ void bnx2x_calc_fc_adv(struct bnx2x *bp)
 		break;
 
 	default:
-		bp->port.advertising[cfg_idx] &= ~(ADVERTISED_Asym_Pause |
-						   ADVERTISED_Pause);
 		break;
 	}
 }
-- 
1.9.3
