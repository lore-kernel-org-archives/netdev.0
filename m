From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next 02/10] bnx2x: Fix CL73 autoneg issues
Date: Thu, 5 Nov 2009 19:18:07 +0200
Message-ID: <1257441487.3390.49.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2641 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754916AbZKEPSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Nov 2009 10:18:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Advertise 1G KX4 in CL73 when 1G speed capability is enabled
- Add flow-control negotiation over CL73
- External loopback test on Serdes should be done in FORCE mode, since in 
CL73 it is unable to link up with the same core using AUTONEG
- Fix bnx2x_set_led function to support CL73 link leds

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |  132 +++++++++++++++++++++++++++++-----------------
 drivers/net/bnx2x_link.h |    3 +-
 drivers/net/bnx2x_main.c |   16 ++----
 drivers/net/bnx2x_reg.h  |   18 +++++--
 4 files changed, 104 insertions(+), 65 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index b5964cb..eabdd11 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1228,7 +1228,7 @@ static void bnx2x_set_autoneg(struct link_params *params,
 				      params->phy_addr,
 				      MDIO_REG_BANK_CL73_USERB0,
 				    MDIO_CL73_USERB0_CL73_UCTRL,
-				    MDIO_CL73_USERB0_CL73_UCTRL_USTAT1_MUXSEL);
+				      0xe);
 
 		/* Enable BAM Station Manager*/
 		CL45_WR_OVER_CL22(bp, params->port,
@@ -1239,29 +1239,25 @@ static void bnx2x_set_autoneg(struct link_params *params,
 			MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_STATION_MNGR_EN |
 			MDIO_CL73_USERB0_CL73_BAM_CTRL1_BAM_NP_AFTER_BP_EN);
 
-		/* Merge CL73 and CL37 aneg resolution */
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
-				      MDIO_REG_BANK_CL73_USERB0,
-				      MDIO_CL73_USERB0_CL73_BAM_CTRL3,
-				      &reg_val);
-
-		if (params->speed_cap_mask &
-		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G) {
-			/* Set the CL73 AN speed */
+		/* Advertise CL73 link speeds */
 			CL45_RD_OVER_CL22(bp, params->port,
 					      params->phy_addr,
 					      MDIO_REG_BANK_CL73_IEEEB1,
 					      MDIO_CL73_IEEEB1_AN_ADV2,
 					      &reg_val);
+		if (params->speed_cap_mask &
+		    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
+			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_10G_KX4;
+		if (params->speed_cap_mask &
+		    PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)
+			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_1000M_KX;
 
 			CL45_WR_OVER_CL22(bp, params->port,
 					      params->phy_addr,
 					      MDIO_REG_BANK_CL73_IEEEB1,
 					      MDIO_CL73_IEEEB1_AN_ADV2,
-			  reg_val | MDIO_CL73_IEEEB1_AN_ADV2_ADVR_10G_KX4);
+				      reg_val);
 
-		}
 		/* CL73 Autoneg Enabled */
 		reg_val = MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN;
 
@@ -1389,12 +1385,23 @@ static void bnx2x_set_ieee_aneg_advertisment(struct link_params *params,
 					   u16 ieee_fc)
 {
 	struct bnx2x *bp = params->bp;
+	u16 val;
 	/* for AN, we are always publishing full duplex */
 
 	CL45_WR_OVER_CL22(bp, params->port,
 			      params->phy_addr,
 			      MDIO_REG_BANK_COMBO_IEEE0,
 			      MDIO_COMBO_IEEE0_AUTO_NEG_ADV, ieee_fc);
+	CL45_RD_OVER_CL22(bp, params->port,
+			      params->phy_addr,
+			      MDIO_REG_BANK_CL73_IEEEB1,
+			      MDIO_CL73_IEEEB1_AN_ADV1, &val);
+	val &= ~MDIO_CL73_IEEEB1_AN_ADV1_PAUSE_BOTH;
+	val |= ((ieee_fc<<3) & MDIO_CL73_IEEEB1_AN_ADV1_PAUSE_MASK);
+	CL45_WR_OVER_CL22(bp, params->port,
+			      params->phy_addr,
+			      MDIO_REG_BANK_CL73_IEEEB1,
+			      MDIO_CL73_IEEEB1_AN_ADV1, val);
 }
 
 static void bnx2x_restart_autoneg(struct link_params *params, u8 enable_cl73)
@@ -1630,21 +1637,49 @@ static void bnx2x_flow_ctrl_resolve(struct link_params *params,
 	    (!(vars->phy_flags & PHY_SGMII_FLAG)) &&
 	    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
 	     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT)) {
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
-				      MDIO_REG_BANK_COMBO_IEEE0,
-				      MDIO_COMBO_IEEE0_AUTO_NEG_ADV,
-				      &ld_pause);
-		CL45_RD_OVER_CL22(bp, params->port,
-				      params->phy_addr,
-			MDIO_REG_BANK_COMBO_IEEE0,
-			MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1,
-			&lp_pause);
-		pause_result = (ld_pause &
+		if ((gp_status &
+		    (MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_AUTONEG_COMPLETE |
+		     MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_MR_LP_NP_AN_ABLE)) ==
+		    (MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_AUTONEG_COMPLETE |
+		     MDIO_GP_STATUS_TOP_AN_STATUS1_CL73_MR_LP_NP_AN_ABLE)) {
+
+			CL45_RD_OVER_CL22(bp, params->port,
+					      params->phy_addr,
+					      MDIO_REG_BANK_CL73_IEEEB1,
+					      MDIO_CL73_IEEEB1_AN_ADV1,
+					      &ld_pause);
+			CL45_RD_OVER_CL22(bp, params->port,
+					     params->phy_addr,
+					     MDIO_REG_BANK_CL73_IEEEB1,
+					     MDIO_CL73_IEEEB1_AN_LP_ADV1,
+					     &lp_pause);
+			pause_result = (ld_pause &
+					MDIO_CL73_IEEEB1_AN_ADV1_PAUSE_MASK)
+					>> 8;
+			pause_result |= (lp_pause &
+					MDIO_CL73_IEEEB1_AN_LP_ADV1_PAUSE_MASK)
+					>> 10;
+			DP(NETIF_MSG_LINK, "pause_result CL73 0x%x\n",
+				 pause_result);
+		} else {
+
+			CL45_RD_OVER_CL22(bp, params->port,
+					      params->phy_addr,
+					      MDIO_REG_BANK_COMBO_IEEE0,
+					      MDIO_COMBO_IEEE0_AUTO_NEG_ADV,
+					      &ld_pause);
+			CL45_RD_OVER_CL22(bp, params->port,
+			       params->phy_addr,
+			       MDIO_REG_BANK_COMBO_IEEE0,
+			       MDIO_COMBO_IEEE0_AUTO_NEG_LINK_PARTNER_ABILITY1,
+			       &lp_pause);
+			pause_result = (ld_pause &
 				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK)>>5;
-		pause_result |= (lp_pause &
+			pause_result |= (lp_pause &
 				 MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK)>>7;
-		DP(NETIF_MSG_LINK, "pause_result 0x%x\n", pause_result);
+			DP(NETIF_MSG_LINK, "pause_result CL37 0x%x\n",
+				 pause_result);
+		}
 		bnx2x_pause_resolve(vars, pause_result);
 	} else if ((params->req_flow_ctrl == BNX2X_FLOW_CTRL_AUTO) &&
 		   (bnx2x_ext_phy_resolve_fc(params, vars))) {
@@ -1990,8 +2025,7 @@ static u8 bnx2x_emac_program(struct link_params *params,
 		    GRCBASE_EMAC0 + port*0x400 + EMAC_REG_EMAC_MODE,
 		    mode);
 
-	bnx2x_set_led(bp, params->port, LED_MODE_OPER,
-		    line_speed, params->hw_led_mode, params->chip_id);
+	bnx2x_set_led(params, LED_MODE_OPER, line_speed);
 	return 0;
 }
 
@@ -3547,7 +3581,10 @@ static void bnx2x_init_internal_phy(struct link_params *params,
 			bnx2x_set_preemphasis(params);
 
 		/* forced speed requested? */
-		if (vars->line_speed != SPEED_AUTO_NEG) {
+		if (vars->line_speed != SPEED_AUTO_NEG ||
+		    ((XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
+		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
+			  params->loopback_mode == LOOPBACK_EXT)) {
 			DP(NETIF_MSG_LINK, "not SGMII, no AN\n");
 
 			/* disable autoneg */
@@ -5731,13 +5768,15 @@ u8 bnx2x_override_led_value(struct bnx2x *bp, u8 port,
 }
 
 
-u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
-	       u16 hw_led_mode, u32 chip_id)
+u8 bnx2x_set_led(struct link_params *params, u8 mode, u32 speed)
 {
+	u8 port = params->port;
+	u16 hw_led_mode = params->hw_led_mode;
 	u8 rc = 0;
 	u32 tmp;
 	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-
+	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
+	struct bnx2x *bp = params->bp;
 	DP(NETIF_MSG_LINK, "bnx2x_set_led: port %x, mode %d\n", port, mode);
 	DP(NETIF_MSG_LINK, "speed 0x%x, hw_led_mode 0x%x\n",
 		 speed, hw_led_mode);
@@ -5752,7 +5791,14 @@ u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
 		break;
 
 	case LED_MODE_OPER:
-		REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, hw_led_mode);
+		if (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) {
+			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
+			REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 1);
+		} else {
+			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
+				   hw_led_mode);
+		}
+
 		REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0 +
 			   port*4, 0);
 		/* Set blinking rate to ~15.9Hz */
@@ -5764,7 +5810,7 @@ u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
 		EMAC_WR(bp, EMAC_REG_EMAC_LED,
 			    (tmp & (~EMAC_LED_OVERRIDE)));
 
-		if (!CHIP_IS_E1H(bp) &&
+		if (CHIP_IS_E1(bp) &&
 		    ((speed == SPEED_2500) ||
 		     (speed == SPEED_1000) ||
 		     (speed == SPEED_100) ||
@@ -6033,10 +6079,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
 			    params->port*4, 0);
 
-		bnx2x_set_led(bp, params->port, LED_MODE_OPER,
-			    vars->line_speed, params->hw_led_mode,
-			    params->chip_id);
-
+		bnx2x_set_led(params, LED_MODE_OPER, vars->line_speed);
 	} else
 	/* No loopback */
 	{
@@ -6094,8 +6137,6 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 {
 	struct bnx2x *bp = params->bp;
 	u32 ext_phy_config = params->ext_phy_config;
-	u16 hw_led_mode = params->hw_led_mode;
-	u32 chip_id = params->chip_id;
 	u8 port = params->port;
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(ext_phy_config);
 	u32 val = REG_RD(bp, params->shmem_base +
@@ -6130,7 +6171,7 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	 * Hold it as vars low
 	 */
 	 /* clear link led */
-	bnx2x_set_led(bp, port, LED_MODE_OFF, 0, hw_led_mode, chip_id);
+	bnx2x_set_led(params, LED_MODE_OFF, 0);
 	if (reset_ext_phy) {
 		switch (ext_phy_type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
@@ -6201,9 +6242,7 @@ static u8 bnx2x_update_link_down(struct link_params *params,
 	u8 port = params->port;
 
 	DP(NETIF_MSG_LINK, "Port %x: Link is down\n", port);
-	bnx2x_set_led(bp, port, LED_MODE_OFF,
-		    0, params->hw_led_mode,
-		    params->chip_id);
+	bnx2x_set_led(params, LED_MODE_OFF, 0);
 
 	/* indicate no mac active */
 	vars->mac_type = MAC_TYPE_NONE;
@@ -6240,10 +6279,7 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 	vars->link_status |= LINK_STATUS_LINK_UP;
 	if (link_10g) {
 		bnx2x_bmac_enable(params, vars, 0);
-		bnx2x_set_led(bp, port, LED_MODE_OPER,
-			    SPEED_10000, params->hw_led_mode,
-			    params->chip_id);
-
+		bnx2x_set_led(params, LED_MODE_OPER, SPEED_10000);
 	} else {
 		bnx2x_emac_enable(params, vars, 0);
 		rc = bnx2x_emac_program(params, vars->line_speed,
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x_link.h
index f3e2522..40c2981 100644
--- a/drivers/net/bnx2x_link.h
+++ b/drivers/net/bnx2x_link.h
@@ -178,8 +178,7 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
    Basically, the CLC takes care of the led for the link, but in case one needs
    to set/unset the led unnaturally, set the "mode" to LED_MODE_OPER to
    blink the led, and LED_MODE_OFF to set the led off.*/
-u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
-	       u16 hw_led_mode, u32 chip_id);
+u8 bnx2x_set_led(struct link_params *params, u8 mode, u32 speed);
 #define LED_MODE_OFF	0
 #define LED_MODE_OPER 	2
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 59b58d8..6f16547 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -10855,7 +10855,6 @@ static void bnx2x_get_ethtool_stats(struct net_device *dev,
 static int bnx2x_phys_id(struct net_device *dev, u32 data)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	int port = BP_PORT(bp);
 	int i;
 
 	if (!netif_running(dev))
@@ -10869,13 +10868,10 @@ static int bnx2x_phys_id(struct net_device *dev, u32 data)
 
 	for (i = 0; i < (data * 2); i++) {
 		if ((i % 2) == 0)
-			bnx2x_set_led(bp, port, LED_MODE_OPER, SPEED_1000,
-				      bp->link_params.hw_led_mode,
-				      bp->link_params.chip_id);
+			bnx2x_set_led(&bp->link_params, LED_MODE_OPER,
+				      SPEED_1000);
 		else
-			bnx2x_set_led(bp, port, LED_MODE_OFF, 0,
-				      bp->link_params.hw_led_mode,
-				      bp->link_params.chip_id);
+			bnx2x_set_led(&bp->link_params, LED_MODE_OFF, 0);
 
 		msleep_interruptible(500);
 		if (signal_pending(current))
@@ -10883,10 +10879,8 @@ static int bnx2x_phys_id(struct net_device *dev, u32 data)
 	}
 
 	if (bp->link_vars.link_up)
-		bnx2x_set_led(bp, port, LED_MODE_OPER,
-			      bp->link_vars.line_speed,
-			      bp->link_params.hw_led_mode,
-			      bp->link_params.chip_id);
+		bnx2x_set_led(&bp->link_params, LED_MODE_OPER,
+			      bp->link_vars.line_speed);
 
 	return 0;
 }
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index aa76cba..b80fde4 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -4772,18 +4772,28 @@
 #define PCI_ID_VAL2					0x438
 
 
-#define MDIO_REG_BANK_CL73_IEEEB0			0x0
-#define MDIO_CL73_IEEEB0_CL73_AN_CONTROL		0x0
+#define MDIO_REG_BANK_CL73_IEEEB0	0x0
+#define MDIO_CL73_IEEEB0_CL73_AN_CONTROL	0x0
 #define MDIO_CL73_IEEEB0_CL73_AN_CONTROL_RESTART_AN	0x0200
 #define MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN		0x1000
 #define MDIO_CL73_IEEEB0_CL73_AN_CONTROL_MAIN_RST	0x8000
 
-#define MDIO_REG_BANK_CL73_IEEEB1			0x10
-#define MDIO_CL73_IEEEB1_AN_ADV2				0x01
+#define MDIO_REG_BANK_CL73_IEEEB1	0x10
+#define MDIO_CL73_IEEEB1_AN_ADV1		0x00
+#define MDIO_CL73_IEEEB1_AN_ADV1_PAUSE			0x0400
+#define MDIO_CL73_IEEEB1_AN_ADV1_ASYMMETRIC		0x0800
+#define MDIO_CL73_IEEEB1_AN_ADV1_PAUSE_BOTH		0x0C00
+#define MDIO_CL73_IEEEB1_AN_ADV1_PAUSE_MASK		0x0C00
+#define MDIO_CL73_IEEEB1_AN_ADV2		0x01
 #define MDIO_CL73_IEEEB1_AN_ADV2_ADVR_1000M		0x0000
 #define MDIO_CL73_IEEEB1_AN_ADV2_ADVR_1000M_KX		0x0020
 #define MDIO_CL73_IEEEB1_AN_ADV2_ADVR_10G_KX4		0x0040
 #define MDIO_CL73_IEEEB1_AN_ADV2_ADVR_10G_KR		0x0080
+#define MDIO_CL73_IEEEB1_AN_LP_ADV1		0x03
+#define MDIO_CL73_IEEEB1_AN_LP_ADV1_PAUSE		0x0400
+#define MDIO_CL73_IEEEB1_AN_LP_ADV1_ASYMMETRIC		0x0800
+#define MDIO_CL73_IEEEB1_AN_LP_ADV1_PAUSE_BOTH		0x0C00
+#define MDIO_CL73_IEEEB1_AN_LP_ADV1_PAUSE_MASK		0x0C00
 
 #define MDIO_REG_BANK_RX0				0x80b0
 #define MDIO_RX0_RX_STATUS				0x10
-- 
1.6.5.2




