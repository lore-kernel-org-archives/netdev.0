From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 10/36] bnx2x: Adding XAUI CL73 autoneg support
Date: Wed, 12 Aug 2009 21:23:04 +0300
Message-ID: <1250101384.27379.162.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2270 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753140AbZHLSX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:23:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding CL73 support to the built in PHY in the 5771x device. Also supporting
fallbacks to CL73 if the link partner does not respond.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |  197 +++++++++++++++++++++++++++++++++++++++-------
 drivers/net/bnx2x_reg.h  |   13 +++
 2 files changed, 180 insertions(+), 30 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index db4f3c0..371310d 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1151,7 +1151,8 @@ static void bnx2x_set_parallel_detection(struct link_params *params,
 }
 
 static void bnx2x_set_autoneg(struct link_params *params,
-			    struct link_vars   *vars)
+			    struct link_vars *vars,
+			    u8 enable_cl73)
 {
 	struct bnx2x *bp = params->bp;
 	u16 reg_val;
@@ -1181,7 +1182,9 @@ static void bnx2x_set_autoneg(struct link_params *params,
 			      params->phy_addr,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1, &reg_val);
-	reg_val &= ~MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_SIGNAL_DETECT_EN;
+	reg_val &= ~(MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_SIGNAL_DETECT_EN |
+		    MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_INVERT_SIGNAL_DETECT);
+	reg_val |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_FIBER_MODE;
 	if (vars->line_speed == SPEED_AUTO_NEG)
 		reg_val |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET;
 	else
@@ -1213,8 +1216,51 @@ static void bnx2x_set_autoneg(struct link_params *params,
 			      MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL,
 			      reg_val);
 
-	/* CL73 Autoneg Disabled */
-	reg_val = 0;
+	if (enable_cl73) {
+		/* Enable Cl73 FSM status bits */
+		CL45_WR_OVER_CL22(bp, params->port,
+				      params->phy_addr,
+				      MDIO_REG_BANK_CL73_USERB0,
+				    MDIO_CL73_USERB0_CL73_UCTRL,
+				    MDIO_CL73_USERB0_CL73_UCTRL_USTAT1_MUXSEL);
+
+		/* Enable BAM Station Manager*/
+		CL45_WR_OVER_CL22(bp, params->port,
+			params->phy_addr,
+			MDIO_REG_BANK_CL73_USERB0,
+			MDIO_CL73_USERB0_CL73_BAM_CTRL1,
+			MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_EN |
+			MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_STATION_MNGR_EN |
+			MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_NP_AFTER_BP_EN);
+
+		/* Merge CL73 and CL37 aneg resolution */
+		CL45_RD_OVER_CL22(bp, params->port,
+				      params->phy_addr,
+				      MDIO_REG_BANK_CL73_USERB0,
+				      MDIO_CL73_USERB0_CL73_BAM_CTRL3,
+				      &reg_val);
+
+		if (params->speed_cap_mask &
+		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G) {
+			/* Set the CL73 AN speed */
+			CL45_RD_OVER_CL22(bp, params->port,
+					      params->phy_addr,
+					      MDIO_REG_BANK_CL73_IEEEB1,
+					      MDIO_CL73_IEEEB1_AN_ADV2,
+					      &reg_val);
+
+			CL45_WR_OVER_CL22(bp, params->port,
+					      params->phy_addr,
+					      MDIO_REG_BANK_CL73_IEEEB1,
+					      MDIO_CL73_IEEEB1_AN_ADV2,
+			  reg_val | MDIO_CL73_IEEEB1_AN_ADV2_ADVR_10G_KX4);
+
+		}
+		/* CL73 Autoneg Enabled */
+		reg_val = MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN;
+
+	} else /* CL73 Autoneg Disabled */
+		reg_val = 0;
 
 	CL45_WR_OVER_CL22(bp, params->port,
 			      params->phy_addr,
@@ -1297,7 +1343,7 @@ static void bnx2x_set_brcm_cl37_advertisment(struct link_params *params)
 	CL45_WR_OVER_CL22(bp, params->port,
 			      params->phy_addr,
 			      MDIO_REG_BANK_OVER_1G,
-			      MDIO_OVER_1G_UP3, 0);
+			      MDIO_OVER_1G_UP3, 0x400);
 }
 
 static void bnx2x_calc_ieee_aneg_adv(struct link_params *params, u32 *ieee_fc)
@@ -1345,28 +1391,46 @@ static void bnx2x_set_ieee_aneg_advertisment(struct link_params *params,
 			      MDIO_COMBO_IEEE0_AUTO_NEG_ADV, (u16)ieee_fc);
 }
 
-static void bnx2x_restart_autoneg(struct link_params *params)
+static void bnx2x_restart_autoneg(struct link_params *params, u8 enable_cl73)
 {
 	struct bnx2x *bp = params->bp;
 	u16 mii_control;
+
 	DP(NETIF_MSG_LINK, "bnx2x_restart_autoneg\n");
 	/* Enable and restart BAM/CL37 aneg */
 
-	CL45_RD_OVER_CL22(bp, params->port,
-			      params->phy_addr,
-			      MDIO_REG_BANK_COMBO_IEEE0,
-			      MDIO_COMBO_IEEE0_MII_CONTROL,
-			      &mii_control);
-	DP(NETIF_MSG_LINK,
-		 "bnx2x_restart_autoneg mii_control before = 0x%x\n",
-		 mii_control);
-	CL45_WR_OVER_CL22(bp, params->port,
-			      params->phy_addr,
-			      MDIO_REG_BANK_COMBO_IEEE0,
-			      MDIO_COMBO_IEEE0_MII_CONTROL,
-			      (mii_control |
-			       MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
-			       MDIO_COMBO_IEEO_MII_CONTROL_RESTART_AN));
+	if (enable_cl73) {
+		CL45_RD_OVER_CL22(bp, params->port,
+				      params->phy_addr,
+				      MDIO_REG_BANK_CL73_IEEEB0,
+				      MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
+				      &mii_control);
+
+		CL45_WR_OVER_CL22(bp, params->port,
+				params->phy_addr,
+				MDIO_REG_BANK_CL73_IEEEB0,
+				MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
+				(mii_control |
+				MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN |
+				MDIO_CL73_IEEEB0_CL73_AN_CONTROL_RESTART_AN));
+	} else {
+
+		CL45_RD_OVER_CL22(bp, params->port,
+				      params->phy_addr,
+				      MDIO_REG_BANK_COMBO_IEEE0,
+				      MDIO_COMBO_IEEE0_MII_CONTROL,
+				      &mii_control);
+		DP(NETIF_MSG_LINK,
+			 "bnx2x_restart_autoneg mii_control before = 0x%x\n",
+			 mii_control);
+		CL45_WR_OVER_CL22(bp, params->port,
+				      params->phy_addr,
+				      MDIO_REG_BANK_COMBO_IEEE0,
+				      MDIO_COMBO_IEEE0_MII_CONTROL,
+				      (mii_control |
+				       MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
+				       MDIO_COMBO_IEEO_MII_CONTROL_RESTART_AN));
+	}
 }
 
 static void bnx2x_initialize_sgmii_process(struct link_params *params,
@@ -1438,7 +1502,7 @@ static void bnx2x_initialize_sgmii_process(struct link_params *params,
 
 	} else { /* AN mode */
 		/* enable and restart AN */
-		bnx2x_restart_autoneg(params);
+		bnx2x_restart_autoneg(params, 0);
 	}
 }
 
@@ -1591,7 +1655,73 @@ static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 	DP(NETIF_MSG_LINK, "flow_ctrl 0x%x\n", vars->flow_ctrl);
 }
 
-
+static void bnx2x_check_fallback_to_cl37(struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	u16 rx_status, ustat_val, cl37_fsm_recieved;
+	DP(NETIF_MSG_LINK, "bnx2x_check_fallback_to_cl37\n");
+	/* Step 1: Make sure signal is detected */
+	CL45_RD_OVER_CL22(bp, params->port,
+			      params->phy_addr,
+			      MDIO_REG_BANK_RX0,
+			      MDIO_RX0_RX_STATUS,
+			      &rx_status);
+	if ((rx_status & MDIO_RX0_RX_STATUS_SIGDET) !=
+	    (MDIO_RX0_RX_STATUS_SIGDET)) {
+		DP(NETIF_MSG_LINK, "Signal is not detected. Restoring CL73."
+			     "rx_status(0x80b0) = 0x%x\n", rx_status);
+		CL45_WR_OVER_CL22(bp, params->port,
+				      params->phy_addr,
+				      MDIO_REG_BANK_CL73_IEEEB0,
+				      MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
+				      MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN);
+		return;
+	}
+	/* Step 2: Check CL73 state machine */
+	CL45_RD_OVER_CL22(bp, params->port,
+			      params->phy_addr,
+			      MDIO_REG_BANK_CL73_USERB0,
+			      MDIO_CL73_USERB0_CL73_USTAT1,
+			      &ustat_val);
+	if ((ustat_val &
+	     (MDIO_CL73_USERB0_CL73_USTAT1_LINK_STATUS_CHECK |
+	      MDIO_CL73_USERB0_CL73_USTAT1_AN_GOOD_CHECK_BAM37)) !=
+	    (MDIO_CL73_USERB0_CL73_USTAT1_LINK_STATUS_CHECK |
+	      MDIO_CL73_USERB0_CL73_USTAT1_AN_GOOD_CHECK_BAM37)) {
+		DP(NETIF_MSG_LINK, "CL73 state-machine is not stable. "
+			     "ustat_val(0x8371) = 0x%x\n", ustat_val);
+		return;
+	}
+	/* Step 3: Check CL37 Message Pages received to indicate LP
+	supports only CL37 */
+	CL45_RD_OVER_CL22(bp, params->port,
+			      params->phy_addr,
+			      MDIO_REG_BANK_REMOTE_PHY,
+			      MDIO_REMOTE_PHY_MISC_RX_STATUS,
+			      &cl37_fsm_recieved);
+	if ((cl37_fsm_recieved &
+	     (MDIO_REMOTE_PHY_MISC_RX_STATUS_CL37_FSM_RECEIVED_OVER1G_MSG |
+	     MDIO_REMOTE_PHY_MISC_RX_STATUS_CL37_FSM_RECEIVED_BRCM_OUI_MSG)) !=
+	    (MDIO_REMOTE_PHY_MISC_RX_STATUS_CL37_FSM_RECEIVED_OVER1G_MSG |
+	      MDIO_REMOTE_PHY_MISC_RX_STATUS_CL37_FSM_RECEIVED_BRCM_OUI_MSG)) {
+		DP(NETIF_MSG_LINK, "No CL37 FSM were received. "
+			     "misc_rx_status(0x8330) = 0x%x\n",
+			 cl37_fsm_recieved);
+		return;
+	}
+	/* The combined cl37/cl73 fsm state information indicating that we are
+	connected to a device which does not support cl73, but does support
+	cl37 BAM. In this case we disable cl73 and restart cl37 auto-neg */
+	/* Disable CL73 */
+	CL45_WR_OVER_CL22(bp, params->port,
+			      params->phy_addr,
+			      MDIO_REG_BANK_CL73_IEEEB0,
+			      MDIO_CL73_IEEEB0_CL73_AN_CONTROL,
+			      0);
+	/* Restart CL37 autoneg */
+	bnx2x_restart_autoneg(params, 0);
+	DP(NETIF_MSG_LINK, "Disabling CL73, and restarting CL37 autoneg\n");
+}
 static u8 bnx2x_link_settings_status(struct link_params *params,
 				   struct link_vars *vars,
 				   u32 gp_status,
@@ -1755,6 +1885,13 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
 		vars->autoneg = AUTO_NEG_DISABLED;
 		vars->mac_type = MAC_TYPE_NONE;
+
+		if ((params->req_line_speed == SPEED_AUTO_NEG) &&
+		    ((XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
+		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT))) {
+			/* Check signal is detected */
+			bnx2x_check_fallback_to_cl37(params);
+		}
 	}
 
 	DP(NETIF_MSG_LINK, "gp_status 0x%x  phy_link_up %x line_speed %x \n",
@@ -3425,7 +3562,8 @@ static void bnx2x_8481_set_10G_led_mode(struct link_params *params,
 
 
 static void bnx2x_init_internal_phy(struct link_params *params,
-				struct link_vars *vars)
+				  struct link_vars *vars,
+				  u8 enable_cl73)
 {
 	struct bnx2x *bp = params->bp;
 	if (!(vars->phy_flags & PHY_SGMII_FLAG)) {
@@ -3440,7 +3578,7 @@ static void bnx2x_init_internal_phy(struct link_params *params,
 			DP(NETIF_MSG_LINK, "not SGMII, no AN\n");
 
 			/* disable autoneg */
-			bnx2x_set_autoneg(params, vars);
+			bnx2x_set_autoneg(params, vars, 0);
 
 			/* program speed and duplex */
 			bnx2x_program_serdes(params, vars);
@@ -3456,10 +3594,10 @@ static void bnx2x_init_internal_phy(struct link_params *params,
 						       vars->ieee_fc);
 
 			/* enable autoneg */
-			bnx2x_set_autoneg(params, vars);
+			bnx2x_set_autoneg(params, vars, enable_cl73);
 
 			/* enable and restart AN */
-			bnx2x_restart_autoneg(params);
+			bnx2x_restart_autoneg(params, enable_cl73);
 		}
 
 	} else { /* SGMII mode */
@@ -5815,11 +5953,10 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	if (non_ext_phy ||
 	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
 	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) ||
-	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481) ||
 	    (params->loopback_mode == LOOPBACK_EXT_PHY)) {
 		if (params->req_line_speed == SPEED_AUTO_NEG)
 			bnx2x_set_parallel_detection(params, vars->phy_flags);
-		bnx2x_init_internal_phy(params, vars);
+		bnx2x_init_internal_phy(params, vars, non_ext_phy);
 	}
 
 	if (!non_ext_phy)
@@ -6296,7 +6433,7 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) &&
 	    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) &&
 	    (ext_phy_link_up && !vars->phy_link_up))
-		bnx2x_init_internal_phy(params, vars);
+		bnx2x_init_internal_phy(params, vars, 0);
 
 	/* link is up only if both local phy and external phy are up */
 	vars->link_up = (ext_phy_link_up && vars->phy_link_up);
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 9a20da5..9998386 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -5596,6 +5596,9 @@
 #define MDIO_CL73_IEEEB1_AN_ADV2_ADVR_10G_KR		0x0080
 
 #define MDIO_REG_BANK_RX0				0x80b0
+#define MDIO_RX0_RX_STATUS				0x10
+#define MDIO_RX0_RX_STATUS_SIGDET			0x8000
+#define MDIO_RX0_RX_STATUS_RX_SEQ_DONE			0x1000
 #define MDIO_RX0_RX_EQ_BOOST				0x1c
 #define MDIO_RX0_RX_EQ_BOOST_EQUALIZER_CTRL_MASK	0x7
 #define MDIO_RX0_RX_EQ_BOOST_OFFSET_CTRL		0x10
@@ -5789,12 +5792,22 @@
 #define MDIO_OVER_1G_LP_UP2_PREEMPHASIS_SHIFT				7
 #define MDIO_OVER_1G_LP_UP3						0x1E
 
+#define MDIO_REG_BANK_REMOTE_PHY			0x8330
+#define MDIO_REMOTE_PHY_MISC_RX_STATUS				0x10
+#define MDIO_REMOTE_PHY_MISC_RX_STATUS_CL37_FSM_RECEIVED_OVER1G_MSG	0x0010
+#define MDIO_REMOTE_PHY_MISC_RX_STATUS_CL37_FSM_RECEIVED_BRCM_OUI_MSG	0x0600
+
 #define MDIO_REG_BANK_BAM_NEXT_PAGE			0x8350
 #define MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL			0x10
 #define MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_BAM_MODE			0x0001
 #define MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_TETON_AN			0x0002
 
 #define MDIO_REG_BANK_CL73_USERB0		0x8370
+#define MDIO_CL73_USERB0_CL73_UCTRL				0x10
+#define MDIO_CL73_USERB0_CL73_UCTRL_USTAT1_MUXSEL			0x0002
+#define MDIO_CL73_USERB0_CL73_USTAT1				0x11
+#define MDIO_CL73_USERB0_CL73_USTAT1_LINK_STATUS_CHECK			0x0100
+#define MDIO_CL73_USERB0_CL73_USTAT1_AN_GOOD_CHECK_BAM37		0x0400
 #define MDIO_CL73_USERB0_CL73_BAM_CTRL1 			0x12
 #define MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_EN				0x8000
 #define MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_STATION_MNGR_EN		0x4000
-- 
1.5.4.3




