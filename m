From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 17/25] bnx2x: Pause settings
Date: Wed, 13 Aug 2008 17:15:37 +0300
Message-ID: <1218636937.547.93.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1973 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753057AbYHMOPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:15:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pause settings
- 1G pause was not working due to missing write to the emac block
  (TX_MODE_FLOW_EN)
- The flow control should use the negotiated result (after autoneg) so 
  we should save both the requested autoneg and the result
- The HW credits with flow control at 1G speed were not optimized and 
  caused low throughput
- It is recommended to turn off flow control if the MTU is bigger than 
  5000B due to internal buffers size

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |  202 ++++++++++++++++++++++++++--------------------
 drivers/net/bnx2x_link.h |    4 +-
 drivers/net/bnx2x_main.c |    9 ++-
 drivers/net/bnx2x_reg.h  |    4 +-
 4 files changed, 128 insertions(+), 91 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 3b63c8c..36fa356 100755
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -38,7 +38,6 @@
 #define ETH_MAX_JUMBO_PACKET_SIZE	9600
 #define MDIO_ACCESS_TIMEOUT		1000
 #define BMAC_CONTROL_RX_ENABLE	2
-#define MAX_MTU_SIZE		5000
 
 /***********************************************************/
 /*                       Shortcut definitions              */
@@ -298,11 +297,13 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 				    EMAC_RX_MODE_FLOW_EN);
 
 		bnx2x_bits_dis(bp,  emac_base + EMAC_REG_EMAC_TX_MODE,
-			       EMAC_TX_MODE_EXT_PAUSE_EN);
+			     (EMAC_TX_MODE_EXT_PAUSE_EN |
+			      EMAC_TX_MODE_FLOW_EN));
 		if (vars->flow_ctrl & FLOW_CTRL_TX)
 			bnx2x_bits_en(bp, emac_base +
 				    EMAC_REG_EMAC_TX_MODE,
-				      EMAC_TX_MODE_EXT_PAUSE_EN);
+				   (EMAC_TX_MODE_EXT_PAUSE_EN |
+				    EMAC_TX_MODE_FLOW_EN));
 	}
 
 	/* KEEP_VLAN_TAG, promiscuous */
@@ -591,9 +592,9 @@ void bnx2x_link_status_update(struct link_params *params,
 			vars->flow_ctrl &= ~FLOW_CTRL_RX;
 
 		if (vars->phy_flags & PHY_XGXS_FLAG) {
-			if (params->req_line_speed &&
-			    ((params->req_line_speed == SPEED_10) ||
-			     (params->req_line_speed == SPEED_100))) {
+			if (vars->line_speed &&
+			    ((vars->line_speed == SPEED_10) ||
+			     (vars->line_speed == SPEED_100))) {
 				vars->phy_flags |= PHY_SGMII_FLAG;
 			} else {
 				vars->phy_flags &= ~PHY_SGMII_FLAG;
@@ -670,7 +671,6 @@ static u8 bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 	u8 port = params->port;
 	u32 init_crd, crd;
 	u32 count = 1000;
-	u32 pause = 0;
 
 	/* disable port */
 	REG_WR(bp, PBF_REG_DISABLE_NEW_TASK_PROC_P0 + port*4, 0x1);
@@ -693,33 +693,25 @@ static u8 bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 		return -EINVAL;
 	}
 
-	if (flow_ctrl & FLOW_CTRL_RX)
-		pause = 1;
-	REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + port*4, pause);
-	if (pause) {
+	if (flow_ctrl & FLOW_CTRL_RX ||
+	    line_speed == SPEED_10 ||
+	    line_speed == SPEED_100 ||
+	    line_speed == SPEED_1000 ||
+	    line_speed == SPEED_2500) {
+		REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + port*4, 1);
 		/* update threshold */
 		REG_WR(bp, PBF_REG_P0_ARB_THRSH + port*4, 0);
 		/* update init credit */
-		init_crd = 778;		/* (800-18-4) */
+		init_crd = 778; 	/* (800-18-4) */
 
 	} else {
 		u32 thresh = (ETH_MAX_JUMBO_PACKET_SIZE +
 			      ETH_OVREHEAD)/16;
-
+		REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + port*4, 0);
 		/* update threshold */
 		REG_WR(bp, PBF_REG_P0_ARB_THRSH + port*4, thresh);
 		/* update init credit */
 		switch (line_speed) {
-		case SPEED_10:
-		case SPEED_100:
-		case SPEED_1000:
-			init_crd = thresh + 55 - 22;
-			break;
-
-		case SPEED_2500:
-			init_crd = thresh + 138 - 22;
-			break;
-
 		case SPEED_10000:
 			init_crd = thresh + 553 - 22;
 			break;
@@ -1114,7 +1106,7 @@ static void bnx2x_set_autoneg(struct link_params *params,
 			      MDIO_COMBO_IEEE0_MII_CONTROL, &reg_val);
 
 	/* CL37 Autoneg Enabled */
-	if (params->req_line_speed == SPEED_AUTO_NEG)
+	if (vars->line_speed == SPEED_AUTO_NEG)
 		reg_val |= MDIO_COMBO_IEEO_MII_CONTROL_AN_EN;
 	else /* CL37 Autoneg Disabled */
 		reg_val &= ~(MDIO_COMBO_IEEO_MII_CONTROL_AN_EN |
@@ -1132,7 +1124,7 @@ static void bnx2x_set_autoneg(struct link_params *params,
 			      MDIO_REG_BANK_SERDES_DIGITAL,
 			      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1, &reg_val);
 	reg_val &= ~MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_SIGNAL_DETECT_EN;
-	if (params->req_line_speed == SPEED_AUTO_NEG)
+	if (vars->line_speed == SPEED_AUTO_NEG)
 		reg_val |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET;
 	else
 		reg_val &= ~MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET;
@@ -1148,7 +1140,7 @@ static void bnx2x_set_autoneg(struct link_params *params,
 			      MDIO_REG_BANK_BAM_NEXT_PAGE,
 			      MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL,
 			  &reg_val);
-	if (params->req_line_speed == SPEED_AUTO_NEG) {
+	if (vars->line_speed == SPEED_AUTO_NEG) {
 		/* Enable BAM aneg Mode and TetonII aneg Mode */
 		reg_val |= (MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_BAM_MODE |
 			    MDIO_BAM_NEXT_PAGE_MP5_NEXT_PAGE_CTRL_TETON_AN);
@@ -1164,7 +1156,7 @@ static void bnx2x_set_autoneg(struct link_params *params,
 			      reg_val);
 
 	/* Enable Clause 73 Aneg */
-	if ((params->req_line_speed == SPEED_AUTO_NEG) &&
+	if ((vars->line_speed == SPEED_AUTO_NEG) &&
 	    (SUPPORT_CL73)) {
 		/* Enable BAM Station Manager */
 
@@ -1226,7 +1218,8 @@ static void bnx2x_set_autoneg(struct link_params *params,
 }
 
 /* program SerDes, forced speed */
-static void bnx2x_program_serdes(struct link_params *params)
+static void bnx2x_program_serdes(struct link_params *params,
+			       struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u16 reg_val;
@@ -1248,28 +1241,35 @@ static void bnx2x_program_serdes(struct link_params *params)
 
 	/* program speed
 	   - needed only if the speed is greater than 1G (2.5G or 10G) */
-	if (!((params->req_line_speed == SPEED_1000) ||
-	      (params->req_line_speed == SPEED_100) ||
-	      (params->req_line_speed == SPEED_10))) {
-		CL45_RD_OVER_CL22(bp, params->port,
+	CL45_RD_OVER_CL22(bp, params->port,
 				      params->phy_addr,
 				      MDIO_REG_BANK_SERDES_DIGITAL,
 				      MDIO_SERDES_DIGITAL_MISC1, &reg_val);
-		/* clearing the speed value before setting the right speed */
-		reg_val &= ~MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_MASK;
+	/* clearing the speed value before setting the right speed */
+	DP(NETIF_MSG_LINK, "MDIO_REG_BANK_SERDES_DIGITAL = 0x%x\n", reg_val);
+
+	reg_val &= ~(MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_MASK |
+		     MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_SEL);
+
+	if (!((vars->line_speed == SPEED_1000) ||
+	      (vars->line_speed == SPEED_100) ||
+	      (vars->line_speed == SPEED_10))) {
+
 		reg_val |= (MDIO_SERDES_DIGITAL_MISC1_REFCLK_SEL_156_25M |
 			    MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_SEL);
-		if (params->req_line_speed == SPEED_10000)
+		if (vars->line_speed == SPEED_10000)
 			reg_val |=
 				MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_10G_CX4;
-		if (params->req_line_speed == SPEED_13000)
+		if (vars->line_speed == SPEED_13000)
 			reg_val |=
 				MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_13G;
-		CL45_WR_OVER_CL22(bp, params->port,
+	}
+
+	CL45_WR_OVER_CL22(bp, params->port,
 				      params->phy_addr,
 				      MDIO_REG_BANK_SERDES_DIGITAL,
 				      MDIO_SERDES_DIGITAL_MISC1, reg_val);
-	}
+
 }
 
 static void bnx2x_set_brcm_cl37_advertisment(struct link_params *params)
@@ -1295,48 +1295,49 @@ static void bnx2x_set_brcm_cl37_advertisment(struct link_params *params)
 			      MDIO_OVER_1G_UP3, 0);
 }
 
-static void bnx2x_set_ieee_aneg_advertisment(struct link_params *params,
-					   u32 *ieee_fc)
+static void bnx2x_calc_ieee_aneg_adv(struct link_params *params, u32 *ieee_fc)
 {
-	struct bnx2x *bp = params->bp;
-	/* for AN, we are always publishing full duplex */
-	u16 an_adv = MDIO_COMBO_IEEE0_AUTO_NEG_ADV_FULL_DUPLEX;
-
+	*ieee_fc = MDIO_COMBO_IEEE0_AUTO_NEG_ADV_FULL_DUPLEX;
 	/* resolve pause mode and advertisement
 	 * Please refer to Table 28B-3 of the 802.3ab-1999 spec */
 
 	switch (params->req_flow_ctrl) {
 	case FLOW_CTRL_AUTO:
-		if (params->mtu <= MAX_MTU_SIZE) {
-			an_adv |=
+		if (params->req_fc_auto_adv == FLOW_CTRL_BOTH) {
+			*ieee_fc |=
 			     MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
 		} else {
-			an_adv |=
+			*ieee_fc |=
 		       MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
 		}
 		break;
 	case FLOW_CTRL_TX:
-		an_adv |=
+		*ieee_fc |=
 		       MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
 		break;
 
 	case FLOW_CTRL_RX:
 	case FLOW_CTRL_BOTH:
-		an_adv |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
+		*ieee_fc |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
 		break;
 
 	case FLOW_CTRL_NONE:
 	default:
-		an_adv |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE;
+		*ieee_fc |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE;
 		break;
 	}
+}
 
-	*ieee_fc = an_adv;
+static void bnx2x_set_ieee_aneg_advertisment(struct link_params *params,
+					   u32 ieee_fc)
+{
+	struct bnx2x *bp = params->bp;
+	/* for AN, we are always publishing full duplex */
 
 	CL45_WR_OVER_CL22(bp, params->port,
 			      params->phy_addr,
 			      MDIO_REG_BANK_COMBO_IEEE0,
-			      MDIO_COMBO_IEEE0_AUTO_NEG_ADV, an_adv);
+			      MDIO_COMBO_IEEE0_AUTO_NEG_ADV, (u16)ieee_fc);
 }
 
 static void bnx2x_restart_autoneg(struct link_params *params)
@@ -1382,7 +1383,8 @@ static void bnx2x_restart_autoneg(struct link_params *params)
 	}
 }
 
-static void bnx2x_initialize_sgmii_process(struct link_params *params)
+static void bnx2x_initialize_sgmii_process(struct link_params *params,
+					 struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u16 control1;
@@ -1406,7 +1408,7 @@ static void bnx2x_initialize_sgmii_process(struct link_params *params)
 			      control1);
 
 	/* if forced speed */
-	if (!(params->req_line_speed == SPEED_AUTO_NEG)) {
+	if (!(vars->line_speed == SPEED_AUTO_NEG)) {
 		/* set speed, disable autoneg */
 		u16 mii_control;
 
@@ -1419,7 +1421,7 @@ static void bnx2x_initialize_sgmii_process(struct link_params *params)
 				 MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_MASK|
 				 MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX);
 
-		switch (params->req_line_speed) {
+		switch (vars->line_speed) {
 		case SPEED_100:
 			mii_control |=
 				MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_100;
@@ -1433,8 +1435,8 @@ static void bnx2x_initialize_sgmii_process(struct link_params *params)
 			break;
 		default:
 			/* invalid speed for SGMII */
-			DP(NETIF_MSG_LINK, "Invalid req_line_speed 0x%x\n",
-				  params->req_line_speed);
+			DP(NETIF_MSG_LINK, "Invalid line_speed 0x%x\n",
+				  vars->line_speed);
 			break;
 		}
 
@@ -1460,20 +1462,20 @@ static void bnx2x_initialize_sgmii_process(struct link_params *params)
  */
 
 static void bnx2x_pause_resolve(struct link_vars *vars, u32 pause_result)
-{
-	switch (pause_result) {			/* ASYM P ASYM P */
-	case 0xb:				/*   1  0   1  1 */
+{						/*  LD	    LP	 */
+	switch (pause_result) { 		/* ASYM P ASYM P */
+	case 0xb:       			/*   1  0   1  1 */
 		vars->flow_ctrl = FLOW_CTRL_TX;
 		break;
 
-	case 0xe:				/*   1  1   1  0 */
+	case 0xe:       			/*   1  1   1  0 */
 		vars->flow_ctrl = FLOW_CTRL_RX;
 		break;
 
-	case 0x5:				/*   0  1   0  1 */
-	case 0x7:				/*   0  1   1  1 */
-	case 0xd:				/*   1  1   0  1 */
-	case 0xf:				/*   1  1   1  1 */
+	case 0x5:       			/*   0  1   0  1 */
+	case 0x7:       			/*   0  1   1  1 */
+	case 0xd:       			/*   1  1   0  1 */
+	case 0xf:       			/*   1  1   1  1 */
 		vars->flow_ctrl = FLOW_CTRL_BOTH;
 		break;
 
@@ -1487,8 +1489,8 @@ static u8 bnx2x_ext_phy_resove_fc(struct link_params *params,
 {
 	struct bnx2x *bp = params->bp;
 	u8 ext_phy_addr;
-	u16 ld_pause;	/* local */
-	u16 lp_pause;	/* link partner */
+	u16 ld_pause;   /* local */
+	u16 lp_pause;   /* link partner */
 	u16 an_complete; /* AN complete */
 	u16 pause_result;
 	u8 ret = 0;
@@ -1531,6 +1533,28 @@ static u8 bnx2x_ext_phy_resove_fc(struct link_params *params,
 		DP(NETIF_MSG_LINK, "Ext PHY pause result 0x%x \n",
 		   pause_result);
 		bnx2x_pause_resolve(vars, pause_result);
+		if (vars->flow_ctrl == FLOW_CTRL_NONE &&
+		     ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
+			bnx2x_cl45_read(bp, port,
+				      ext_phy_type,
+				      ext_phy_addr,
+				      MDIO_AN_DEVAD,
+				      MDIO_AN_REG_CL37_FC_LD, &ld_pause);
+
+			bnx2x_cl45_read(bp, port,
+				      ext_phy_type,
+				      ext_phy_addr,
+				      MDIO_AN_DEVAD,
+				      MDIO_AN_REG_CL37_FC_LP, &lp_pause);
+			pause_result = (ld_pause &
+				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) >> 5;
+			pause_result |= (lp_pause &
+				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) >> 7;
+
+			bnx2x_pause_resolve(vars, pause_result);
+			DP(NETIF_MSG_LINK, "Ext PHY CL37 pause result 0x%x \n",
+				 pause_result);
+		}
 	}
 	return ret;
 }
@@ -1573,13 +1597,10 @@ static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 		   (bnx2x_ext_phy_resove_fc(params, vars))) {
 		return;
 	} else {
-		vars->flow_ctrl = params->req_flow_ctrl;
-		if (vars->flow_ctrl == FLOW_CTRL_AUTO) {
-			if (params->mtu <= MAX_MTU_SIZE)
-				vars->flow_ctrl = FLOW_CTRL_BOTH;
-			else
-				vars->flow_ctrl = FLOW_CTRL_TX;
-		}
+		if (params->req_flow_ctrl == FLOW_CTRL_AUTO)
+			vars->flow_ctrl = params->req_fc_auto_adv;
+		else
+			vars->flow_ctrl = params->req_flow_ctrl;
 	}
 	DP(NETIF_MSG_LINK, "flow_ctrl 0x%x\n", vars->flow_ctrl);
 }
@@ -1709,12 +1730,12 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 
 		}
 		if (vars->flow_ctrl & FLOW_CTRL_TX)
-		       vars->link_status |=
-			LINK_STATUS_TX_FLOW_CONTROL_ENABLED;
+			vars->link_status |=
+				LINK_STATUS_TX_FLOW_CONTROL_ENABLED;
 
 		if (vars->flow_ctrl & FLOW_CTRL_RX)
-		       vars->link_status |=
-			LINK_STATUS_RX_FLOW_CONTROL_ENABLED;
+			vars->link_status |=
+				LINK_STATUS_RX_FLOW_CONTROL_ENABLED;
 
 	} else { /* link_down */
 		DP(NETIF_MSG_LINK, "phy link down\n");
@@ -2286,13 +2307,16 @@ static void bnx2x_ext_phy_set_pause(struct link_params *params,
 		      MDIO_AN_REG_ADV_PAUSE, &val);
 
 	val &= ~MDIO_AN_REG_ADV_PAUSE_BOTH;
+
 	/* Please refer to Table 28B-3 of 802.3ab-1999 spec. */
 
-	if (vars->ieee_fc &
+	if ((vars->ieee_fc &
+	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) ==
 	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) {
 		val |=  MDIO_AN_REG_ADV_PAUSE_ASYMMETRIC;
 	}
-	if (vars->ieee_fc &
+	if ((vars->ieee_fc &
+	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) ==
 	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) {
 		val |=
 		 MDIO_AN_REG_ADV_PAUSE_PAUSE;
@@ -2339,7 +2363,7 @@ static void bnx2x_init_internal_phy(struct link_params *params,
 			bnx2x_set_autoneg(params, vars);
 
 			/* program speed and duplex */
-			bnx2x_program_serdes(params);
+			bnx2x_program_serdes(params, vars);
 
 		} else { /* AN_mode */
 			DP(NETIF_MSG_LINK, "not SGMII, AN\n");
@@ -2349,7 +2373,7 @@ static void bnx2x_init_internal_phy(struct link_params *params,
 
 			/* program duplex & pause advertisement (for aneg) */
 			bnx2x_set_ieee_aneg_advertisment(params,
-						       &vars->ieee_fc);
+						       vars->ieee_fc);
 
 			/* enable autoneg */
 			bnx2x_set_autoneg(params, vars);
@@ -2361,7 +2385,7 @@ static void bnx2x_init_internal_phy(struct link_params *params,
 	} else { /* SGMII mode */
 		DP(NETIF_MSG_LINK, "SGMII\n");
 
-		bnx2x_initialize_sgmii_process(params);
+		bnx2x_initialize_sgmii_process(params, vars);
 	}
 }
 
@@ -2481,7 +2505,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					       ext_phy_type,
 					       ext_phy_addr,
 					       MDIO_AN_DEVAD,
-					       MDIO_AN_REG_CL37_FD,
+					       MDIO_AN_REG_CL37_FC_LP,
 					       0x0020);
 				/* Enable CL37 AN */
 				bnx2x_cl45_write(bp, params->port,
@@ -2657,13 +2681,13 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				       ext_phy_type,
 				       ext_phy_addr,
 				       MDIO_AN_DEVAD,
-				       MDIO_AN_REG_CL37_CL73, 0x040c);
+				       MDIO_AN_REG_CL37_FC_LD, 0x040c);
 			/* Add support for CL37 (passive mode) II */
 			bnx2x_cl45_write(bp, params->port,
 				       ext_phy_type,
 				       ext_phy_addr,
 				       MDIO_AN_DEVAD,
-				       MDIO_AN_REG_CL37_FD, 0x20);
+				       MDIO_AN_REG_CL37_FC_LD, 0x20);
 			/* Add support for CL37 (passive mode) III */
 			bnx2x_cl45_write(bp, params->port,
 				       ext_phy_type,
@@ -2785,7 +2809,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 
 
 static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
-				  struct link_vars *vars)
+				 struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u32 ext_phy_type;
@@ -2826,6 +2850,8 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 				      MDIO_PMA_REG_RX_SD, &rx_sd);
 			DP(NETIF_MSG_LINK, "8705 rx_sd 0x%x\n", rx_sd);
 			ext_phy_link_up = (rx_sd & 0x1);
+			if (ext_phy_link_up)
+				vars->line_speed = SPEED_10000;
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
@@ -3734,7 +3760,7 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	   req_line_speed*/
 	vars->line_speed = params->req_line_speed;
 
-	bnx2x_set_ieee_aneg_advertisment(params, &vars->ieee_fc);
+	bnx2x_calc_ieee_aneg_adv(params, &vars->ieee_fc);
 
 	/* init ext phy and enable link state int */
 	non_ext_phy = ((ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) ||
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x_link.h
index 714d37a..b222552 100644
--- a/drivers/net/bnx2x_link.h
+++ b/drivers/net/bnx2x_link.h
@@ -58,11 +58,13 @@ struct link_params {
 
 	u16 req_duplex;
 	u16 req_flow_ctrl;
+	u16 req_fc_auto_adv; /* Should be set to TX / BOTH when
+	req_flow_ctrl is set to AUTO */
 	u16 req_line_speed; /* Also determine AutoNeg */
 
 	/* Device parameters */
 	u8 mac_addr[6];
-	u16 mtu;
+
 
 
 	/* shmem parameters */
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index d29f227..a37549b 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1946,7 +1946,14 @@ static u8 bnx2x_initial_phy_init(struct bnx2x *bp)
 		u8 rc;
 
 		/* Initialize link parameters structure variables */
-		bp->link_params.mtu = bp->dev->mtu;
+		/* It is recommended to turn off RX FC for jumbo frames
+		   for better performance */
+		if (IS_E1HMF(bp))
+			bp->link_params.req_fc_auto_adv = FLOW_CTRL_BOTH;
+		else if (bp->dev->mtu > 5000)
+			bp->link_params.req_fc_auto_adv = FLOW_CTRL_TX;
+		else
+			bp->link_params.req_fc_auto_adv = FLOW_CTRL_BOTH;
 
 		bnx2x_acquire_phy_lock(bp);
 		rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 58fbeb1..5029d1e 100755
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -4966,6 +4966,7 @@
 #define EMAC_RX_MODE_PROMISCUOUS				 (1L<<8)
 #define EMAC_RX_MTU_SIZE_JUMBO_ENA				 (1L<<31)
 #define EMAC_TX_MODE_EXT_PAUSE_EN				 (1L<<3)
+#define EMAC_TX_MODE_FLOW_EN					 (1L<<4)
 #define MISC_REGISTERS_GPIO_0					 0
 #define MISC_REGISTERS_GPIO_1					 1
 #define MISC_REGISTERS_GPIO_2					 2
@@ -5615,7 +5616,8 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_AN_REG_LINK_STATUS 	0x8304
 #define MDIO_AN_REG_CL37_CL73		0x8370
 #define MDIO_AN_REG_CL37_AN		0xffe0
-#define MDIO_AN_REG_CL37_FD		0xffe4
+#define MDIO_AN_REG_CL37_FC_LD		0xffe4
+#define MDIO_AN_REG_CL37_FC_LP		0xffe5
 
 
 #define IGU_FUNC_BASE			0x0400
-- 
1.5.3.2




