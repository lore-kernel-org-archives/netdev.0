From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 04/10] bnx2x: Adjust flow-control with the new
 scheme
Date: Wed, 8 Sep 2010 00:41:01 +0300
Message-ID: <1283895661.5452.64.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3335 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932438Ab0IGSXD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 14:23:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flow control implementation is split to be done in each PHY function.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c |  213 ++++++++++++++++++++++++++--------------
 1 files changed, 138 insertions(+), 75 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 758ded4..fec3d75 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -171,13 +171,13 @@
 
 #define CL45_WR_OVER_CL22(_bp, _phy, _bank, _addr, _val) \
 	bnx2x_cl45_write(_bp, _phy, \
-		DEFAULT_PHY_DEV_ADDR, \
+		(_phy)->def_md_devad, \
 		(_bank + (_addr & 0xf)), \
 		_val)
 
 #define CL45_RD_OVER_CL22(_bp, _phy, _bank, _addr, _val) \
 	bnx2x_cl45_read(_bp, _phy, \
-		DEFAULT_PHY_DEV_ADDR, \
+		(_phy)->def_md_devad, \
 		(_bank + (_addr & 0xf)), \
 		_val)
 
@@ -634,24 +634,22 @@ void bnx2x_link_status_update(struct link_params *params,
 				break;
 		}
 
+		vars->flow_ctrl = 0;
 		if (vars->link_status & LINK_STATUS_TX_FLOW_CONTROL_ENABLED)
 			vars->flow_ctrl |= BNX2X_FLOW_CTRL_TX;
-		else
-			vars->flow_ctrl &= ~BNX2X_FLOW_CTRL_TX;
 
 		if (vars->link_status & LINK_STATUS_RX_FLOW_CONTROL_ENABLED)
 			vars->flow_ctrl |= BNX2X_FLOW_CTRL_RX;
-		else
-			vars->flow_ctrl &= ~BNX2X_FLOW_CTRL_RX;
 
-		if (vars->phy_flags & PHY_XGXS_FLAG) {
-			if (vars->line_speed &&
-			    ((vars->line_speed == SPEED_10) ||
-			     (vars->line_speed == SPEED_100))) {
-				vars->phy_flags |= PHY_SGMII_FLAG;
-			} else {
-				vars->phy_flags &= ~PHY_SGMII_FLAG;
-			}
+		if (!vars->flow_ctrl)
+			vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+
+		if (vars->line_speed &&
+		    ((vars->line_speed == SPEED_10) ||
+		     (vars->line_speed == SPEED_100))) {
+			vars->phy_flags |= PHY_SGMII_FLAG;
+		} else {
+			vars->phy_flags &= ~PHY_SGMII_FLAG;
 		}
 
 		/* anything 10 and over uses the bmac */
@@ -1137,12 +1135,12 @@ static void bnx2x_set_parallel_detection(struct bnx2x_phy *phy,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL2,
 			      &control2);
-	if (params->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)
+	if (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)
 		control2 |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_PRL_DT_EN;
 	else
 		control2 &= ~MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_PRL_DT_EN;
-	DP(NETIF_MSG_LINK, "params->speed_cap_mask = 0x%x, control2 = 0x%x\n",
-		params->speed_cap_mask, control2);
+	DP(NETIF_MSG_LINK, "phy->speed_cap_mask = 0x%x, control2 = 0x%x\n",
+		phy->speed_cap_mask, control2);
 	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL2,
@@ -1261,10 +1259,10 @@ static void bnx2x_set_autoneg(struct bnx2x_phy *phy,
 					      MDIO_REG_BANK_CL73_IEEEB1,
 					      MDIO_CL73_IEEEB1_AN_ADV2,
 					      &reg_val);
-		if (params->speed_cap_mask &
+		if (phy->speed_cap_mask &
 		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
 			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_10G_KX4;
-		if (params->speed_cap_mask &
+		if (phy->speed_cap_mask &
 		    PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)
 			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_1000M_KX;
 
@@ -1299,7 +1297,7 @@ static void bnx2x_program_serdes(struct bnx2x_phy *phy,
 	reg_val &= ~(MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX |
 		     MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
 		     MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_MASK);
-	if (params->req_duplex == DUPLEX_FULL)
+	if (phy->req_duplex == DUPLEX_FULL)
 		reg_val |= MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX;
 	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_COMBO_IEEE0,
@@ -1345,9 +1343,9 @@ static void bnx2x_set_brcm_cl37_advertisment(struct bnx2x_phy *phy,
 	/* configure the 48 bits for BAM AN */
 
 	/* set extended capabilities */
-	if (params->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G)
+	if (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G)
 		val |= MDIO_OVER_1G_UP1_2_5G;
-	if (params->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
+	if (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
 		val |= MDIO_OVER_1G_UP1_10G;
 	CL45_WR_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_OVER_1G,
@@ -1366,7 +1364,7 @@ static void bnx2x_calc_ieee_aneg_adv(struct bnx2x_phy *phy,
 	/* resolve pause mode and advertisement
 	 * Please refer to Table 28B-3 of the 802.3ab-1999 spec */
 
-	switch (params->req_flow_ctrl) {
+	switch (phy->req_flow_ctrl) {
 	case BNX2X_FLOW_CTRL_AUTO:
 		if (params->req_fc_auto_adv == BNX2X_FLOW_CTRL_BOTH) {
 			*ieee_fc |=
@@ -1511,7 +1509,7 @@ static void bnx2x_initialize_sgmii_process(struct bnx2x_phy *phy,
 		}
 
 		/* setting the full duplex */
-		if (params->req_duplex == DUPLEX_FULL)
+		if (phy->req_duplex == DUPLEX_FULL)
 			mii_control |=
 				MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX;
 		CL45_WR_OVER_CL22(bp, phy,
@@ -1551,6 +1549,11 @@ static void bnx2x_pause_resolve(struct link_vars *vars, u32 pause_result)
 	default:
 		break;
 	}
+	if (pause_result & (1<<0))
+		vars->link_status |= LINK_STATUS_LINK_PARTNER_SYMMETRIC_PAUSE;
+	if (pause_result & (1<<1))
+		vars->link_status |= LINK_STATUS_LINK_PARTNER_ASYMMETRIC_PAUSE;
+
 }
 
 static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
@@ -1560,19 +1563,17 @@ static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 ld_pause;		/* local */
 	u16 lp_pause;		/* link partner */
-	u16 an_complete;	/* AN complete */
 	u16 pause_result;
 	u8 ret = 0;
 	/* read twice */
 
-	bnx2x_cl45_read(bp, phy,
-		      MDIO_AN_DEVAD,
-		      MDIO_AN_REG_STATUS, &an_complete);
-	bnx2x_cl45_read(bp, phy,
-		      MDIO_AN_DEVAD,
-		      MDIO_AN_REG_STATUS, &an_complete);
+	vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
 
-	if (an_complete & MDIO_AN_REG_STATUS_AN_COMPLETE) {
+	if (phy->req_flow_ctrl != BNX2X_FLOW_CTRL_AUTO)
+		vars->flow_ctrl = phy->req_flow_ctrl;
+	else if (phy->req_line_speed != SPEED_AUTO_NEG)
+		vars->flow_ctrl = params->req_fc_auto_adv;
+	else if (vars->link_status & LINK_STATUS_AUTO_NEGOTIATE_COMPLETE) {
 		ret = 1;
 		bnx2x_cl45_read(bp, phy,
 			      MDIO_AN_DEVAD,
@@ -1587,24 +1588,6 @@ static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK, "Ext PHY pause result 0x%x\n",
 		   pause_result);
 		bnx2x_pause_resolve(vars, pause_result);
-		if (vars->flow_ctrl == BNX2X_FLOW_CTRL_NONE &&
-		     phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_AN_DEVAD,
-				      MDIO_AN_REG_CL37_FC_LD, &ld_pause);
-
-			bnx2x_cl45_read(bp, phy,
-				      MDIO_AN_DEVAD,
-				      MDIO_AN_REG_CL37_FC_LP, &lp_pause);
-			pause_result = (ld_pause &
-				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) >> 5;
-			pause_result |= (lp_pause &
-				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) >> 7;
-
-			bnx2x_pause_resolve(vars, pause_result);
-			DP(NETIF_MSG_LINK, "Ext PHY CL37 pause result 0x%x\n",
-				 pause_result);
-		}
 	}
 	return ret;
 }
@@ -1614,6 +1597,8 @@ static u8 bnx2x_direct_parallel_detect_used(struct bnx2x_phy *phy,
 {
 	struct bnx2x *bp = params->bp;
 	u16 pd_10g, status2_1000x;
+	if (phy->req_line_speed != SPEED_AUTO_NEG)
+		return 0;
 	CL45_RD_OVER_CL22(bp, phy,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_STATUS2,
@@ -1654,10 +1639,12 @@ static void bnx2x_flow_ctrl_resolve(struct bnx2x_phy *phy,
 	vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
 
 	/* resolve from gp_status in case of AN complete and not sgmii */
-	if ((params->req_flow_ctrl == BNX2X_FLOW_CTRL_AUTO) &&
-	    (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) &&
-	    (!(vars->phy_flags & PHY_SGMII_FLAG)) &&
-	    (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT)) {
+	if (phy->req_flow_ctrl != BNX2X_FLOW_CTRL_AUTO)
+		vars->flow_ctrl = phy->req_flow_ctrl;
+	else if (phy->req_line_speed != SPEED_AUTO_NEG)
+		vars->flow_ctrl = params->req_fc_auto_adv;
+	else if ((gp_status & MDIO_AN_CL73_OR_37_COMPLETE) &&
+		 (!(vars->phy_flags & PHY_SGMII_FLAG))) {
 		if (bnx2x_direct_parallel_detect_used(phy, params)) {
 			vars->flow_ctrl = params->req_fc_auto_adv;
 			return;
@@ -1701,14 +1688,6 @@ static void bnx2x_flow_ctrl_resolve(struct bnx2x_phy *phy,
 				 pause_result);
 		}
 		bnx2x_pause_resolve(vars, pause_result);
-	} else if ((params->req_flow_ctrl == BNX2X_FLOW_CTRL_AUTO) &&
-		   (bnx2x_ext_phy_resolve_fc(phy, params, vars))) {
-		return;
-	} else {
-		if (params->req_flow_ctrl == BNX2X_FLOW_CTRL_AUTO)
-			vars->flow_ctrl = params->req_fc_auto_adv;
-		else
-			vars->flow_ctrl = params->req_flow_ctrl;
 	}
 	DP(NETIF_MSG_LINK, "flow_ctrl 0x%x\n", vars->flow_ctrl);
 }
@@ -1776,6 +1755,21 @@ static void bnx2x_check_fallback_to_cl37(struct bnx2x_phy *phy,
 	bnx2x_restart_autoneg(phy, params, 0);
 	DP(NETIF_MSG_LINK, "Disabling CL73, and restarting CL37 autoneg\n");
 }
+
+static void bnx2x_xgxs_an_resolve(struct bnx2x_phy *phy,
+				  struct link_params *params,
+				  struct link_vars *vars,
+				  u32 gp_status)
+{
+	if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE)
+		vars->link_status |=
+			LINK_STATUS_AUTO_NEGOTIATE_COMPLETE;
+
+	if (bnx2x_direct_parallel_detect_used(phy, params))
+		vars->link_status |=
+			LINK_STATUS_PARALLEL_DETECTION_USED;
+}
+
 static u8 bnx2x_link_settings_status(struct bnx2x_phy *phy,
 				     struct link_params *params,
 				     struct link_vars *vars)
@@ -1789,7 +1783,8 @@ static u8 bnx2x_link_settings_status(struct bnx2x_phy *phy,
 				MDIO_REG_BANK_GP_STATUS,
 				MDIO_GP_STATUS_TOP_AN_STATUS1,
 				&gp_status);
-
+	if (phy->req_line_speed == SPEED_AUTO_NEG)
+		vars->link_status |= LINK_STATUS_AUTO_NEGOTIATE_ENABLED;
 	if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) {
 		DP(NETIF_MSG_LINK, "phy link up gp_status=0x%x\n",
 			 gp_status);
@@ -1802,8 +1797,12 @@ static u8 bnx2x_link_settings_status(struct bnx2x_phy *phy,
 		else
 			vars->duplex = DUPLEX_HALF;
 
-		bnx2x_flow_ctrl_resolve(&params->phy[INT_PHY],
-					params, vars, gp_status);
+		if (SINGLE_MEDIA_DIRECT(params)) {
+			bnx2x_flow_ctrl_resolve(phy, params, vars, gp_status);
+			if (phy->req_line_speed == SPEED_AUTO_NEG)
+				bnx2x_xgxs_an_resolve(phy, params, vars,
+						      gp_status);
+		}
 
 		switch (gp_status & GP_STATUS_SPEED_MASK) {
 		case GP_STATUS_10M:
@@ -1910,14 +1909,6 @@ static u8 bnx2x_link_settings_status(struct bnx2x_phy *phy,
 				LINK_STATUS_PARALLEL_DETECTION_USED;
 
 		}
-		if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
-			vars->link_status |=
-				LINK_STATUS_TX_FLOW_CONTROL_ENABLED;
-
-		if (vars->flow_ctrl & BNX2X_FLOW_CTRL_RX)
-			vars->link_status |=
-				LINK_STATUS_RX_FLOW_CONTROL_ENABLED;
-
 
 	} else { /* link_down */
 		DP(NETIF_MSG_LINK, "phy link down\n");
@@ -3025,7 +3016,7 @@ static void bnx2x_ext_phy_set_pause(struct link_params *params,
 	val &= ~MDIO_AN_REG_ADV_PAUSE_BOTH;
 
 	/* Please refer to Table 28B-3 of 802.3ab-1999 spec. */
-
+	bnx2x_calc_ieee_aneg_adv(phy, params, &vars->ieee_fc);
 	if ((vars->ieee_fc &
 	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) ==
 	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) {
@@ -3821,6 +3812,24 @@ static u8 bnx2x_8481_config_init(struct bnx2x_phy *phy,
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 1<<15);
 	return bnx2x_848xx_cmn_config_init(phy, params, vars);
 }
+
+
+static void bnx2x_ext_phy_10G_an_resolve(struct bnx2x *bp,
+				       struct bnx2x_phy *phy,
+				       struct link_vars *vars)
+{
+	u16 val;
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD,
+			MDIO_AN_REG_STATUS, &val);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD,
+			MDIO_AN_REG_STATUS, &val);
+	if (val & (1<<5))
+		vars->link_status |= LINK_STATUS_AUTO_NEGOTIATE_COMPLETE;
+	if ((val & (1<<0)) == 0)
+		vars->link_status |= LINK_STATUS_PARALLEL_DETECTION_USED;
+}
 static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 				      struct link_params *params)
 {
@@ -4114,6 +4123,40 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 	return link_up;
 }
 
+static void bnx2x_8073_resolve_fc(struct bnx2x_phy *phy,
+				  struct link_params *params,
+				  struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	if (phy->req_line_speed == SPEED_10 ||
+	    phy->req_line_speed == SPEED_100) {
+		vars->flow_ctrl = phy->req_flow_ctrl;
+		return;
+	}
+
+	if (bnx2x_ext_phy_resolve_fc(phy, params, vars) &&
+	    (vars->flow_ctrl == BNX2X_FLOW_CTRL_NONE)) {
+		u16 pause_result;
+		u16 ld_pause;		/* local */
+		u16 lp_pause;		/* link partner */
+		bnx2x_cl45_read(bp, phy,
+				MDIO_AN_DEVAD,
+				MDIO_AN_REG_CL37_FC_LD, &ld_pause);
+
+		bnx2x_cl45_read(bp, phy,
+				MDIO_AN_DEVAD,
+				MDIO_AN_REG_CL37_FC_LP, &lp_pause);
+		pause_result = (ld_pause &
+				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) >> 5;
+		pause_result |= (lp_pause &
+				 MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) >> 7;
+
+		bnx2x_pause_resolve(vars, pause_result);
+		DP(NETIF_MSG_LINK, "Ext PHY CL37 pause result 0x%x\n",
+			   pause_result);
+	}
+}
+
 static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
@@ -4218,6 +4261,10 @@ static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
 			   params->port);
 	}
 
+	if (link_up) {
+		bnx2x_ext_phy_10G_an_resolve(bp, phy, vars);
+		bnx2x_8073_resolve_fc(phy, params, vars);
+	}
 	return link_up;
 }
 
@@ -4251,6 +4298,8 @@ static u8 bnx2x_7101_read_status(struct bnx2x_phy *phy,
 		vars->line_speed = SPEED_10000;
 		DP(NETIF_MSG_LINK, "SFX7101 AN status 0x%x->Master=%x\n",
 			   val2, (val2 & (1<<14)));
+		bnx2x_ext_phy_10G_an_resolve(bp, phy, vars);
+		bnx2x_ext_phy_resolve_fc(phy, params, vars);
 	}
 	return link_up;
 }
@@ -4276,6 +4325,7 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 	if (val2 & (1<<11)) {
 		vars->line_speed = SPEED_10000;
 		link_up = 1;
+		bnx2x_ext_phy_10G_an_resolve(bp, phy, vars);
 	} else { /* Check Legacy speed link */
 		u16 legacy_status, legacy_speed;
 
@@ -4330,6 +4380,12 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 					LINK_STATUS_PARALLEL_DETECTION_USED;
 		}
 	}
+	if (link_up) {
+		DP(NETIF_MSG_LINK, "BCM84823: link speed is %d\n",
+			   vars->line_speed);
+		bnx2x_ext_phy_resolve_fc(phy, params, vars);
+	}
+
 	return link_up;
 }
 static void bnx2x_link_int_enable(struct link_params *params)
@@ -5298,6 +5354,13 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 	u8 rc = 0;
 
 	vars->link_status |= LINK_STATUS_LINK_UP;
+	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
+		vars->link_status |=
+			LINK_STATUS_TX_FLOW_CONTROL_ENABLED;
+
+	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_RX)
+		vars->link_status |=
+			LINK_STATUS_RX_FLOW_CONTROL_ENABLED;
 	if (link_10g) {
 		bnx2x_bmac_enable(params, vars, 0);
 		bnx2x_set_led(params, LED_MODE_OPER, SPEED_10000);
-- 
1.7.1




