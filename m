From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 16/25] bnx2x: Link order with external PHY
Date: Wed, 13 Aug 2008 17:15:26 +0300
Message-ID: <1218636926.547.92.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1973 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756631AbYHMOPm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:15:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Link order with external PHY
When external PHY exists (second chip with the PHY to translate to
another physical medium) the link with the eternal PHY and the network
should be established before setting the link between the 5771x and the
PHY. This is the right order and it is important when using autoneg -
the link to the network should use the autoneg and the link between the
two chips should be forced to the network result.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |  380 ++++++++++++++++++++++++++--------------------
 drivers/net/bnx2x_reg.h  |    2 +
 2 files changed, 216 insertions(+), 166 deletions(-)
 mode change 100644 => 100755 drivers/net/bnx2x_link.c
 mode change 100644 => 100755 drivers/net/bnx2x_reg.h

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
old mode 100644
new mode 100755
index ff2743d..3b63c8c
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1690,7 +1690,11 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 
 		vars->link_status |= LINK_STATUS_SERDES_LINK;
 
-		if (params->req_line_speed == SPEED_AUTO_NEG) {
+		if ((params->req_line_speed == SPEED_AUTO_NEG) &&
+		    ((XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
+		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) ||
+		    (XGXS_EXT_PHY_TYPE(params->ext_phy_config) ==
+		     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705))) {
 			vars->autoneg = AUTO_NEG_ENABLED;
 
 			if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
@@ -1716,7 +1720,7 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 		DP(NETIF_MSG_LINK, "phy link down\n");
 
 		vars->phy_link_up = 0;
-		vars->line_speed = 0;
+
 		vars->duplex = DUPLEX_FULL;
 		vars->flow_ctrl = FLOW_CTRL_NONE;
 		vars->autoneg = AUTO_NEG_DISABLED;
@@ -2302,6 +2306,65 @@ static void bnx2x_ext_phy_set_pause(struct link_params *params,
 		       MDIO_AN_REG_ADV_PAUSE, val);
 }
 
+
+static void bnx2x_init_internal_phy(struct link_params *params,
+				struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u8 port = params->port;
+	if (!(vars->phy_flags & PHY_SGMII_FLAG)) {
+		u16 bank, rx_eq;
+
+		rx_eq = ((params->serdes_config &
+			  PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_MASK) >>
+			 PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_SHIFT);
+
+		DP(NETIF_MSG_LINK, "setting rx eq to 0x%x\n", rx_eq);
+		for (bank = MDIO_REG_BANK_RX0; bank <= MDIO_REG_BANK_RX_ALL;
+		      bank += (MDIO_REG_BANK_RX1-MDIO_REG_BANK_RX0)) {
+			CL45_WR_OVER_CL22(bp, port,
+					      params->phy_addr,
+					      bank ,
+					      MDIO_RX0_RX_EQ_BOOST,
+					      ((rx_eq &
+				MDIO_RX0_RX_EQ_BOOST_EQUALIZER_CTRL_MASK) |
+				MDIO_RX0_RX_EQ_BOOST_OFFSET_CTRL));
+		}
+
+		/* forced speed requested? */
+		if (vars->line_speed != SPEED_AUTO_NEG) {
+			DP(NETIF_MSG_LINK, "not SGMII, no AN\n");
+
+			/* disable autoneg */
+			bnx2x_set_autoneg(params, vars);
+
+			/* program speed and duplex */
+			bnx2x_program_serdes(params);
+
+		} else { /* AN_mode */
+			DP(NETIF_MSG_LINK, "not SGMII, AN\n");
+
+			/* AN enabled */
+			bnx2x_set_brcm_cl37_advertisment(params);
+
+			/* program duplex & pause advertisement (for aneg) */
+			bnx2x_set_ieee_aneg_advertisment(params,
+						       &vars->ieee_fc);
+
+			/* enable autoneg */
+			bnx2x_set_autoneg(params, vars);
+
+			/* enable and restart AN */
+			bnx2x_restart_autoneg(params);
+		}
+
+	} else { /* SGMII mode */
+		DP(NETIF_MSG_LINK, "SGMII\n");
+
+		bnx2x_initialize_sgmii_process(params);
+	}
+}
+
 static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
@@ -2343,7 +2406,6 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 
 		switch (ext_phy_type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-			DP(NETIF_MSG_LINK, "XGXS Direct\n");
 			break;
 
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
@@ -2701,10 +2763,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 		}
 
 	} else { /* SerDes */
-/*		ext_phy_addr = ((bp->ext_phy_config &
-				 PORT_HW_CFG_SERDES_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_SERDES_EXT_PHY_ADDR_SHIFT);
-*/
+
 		ext_phy_type = SERDES_EXT_PHY_TYPE(params->ext_phy_config);
 		switch (ext_phy_type) {
 		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT:
@@ -2810,6 +2869,13 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 			 */
 			ext_phy_link_up = ((rx_sd & pcs_status & 0x1) ||
 					   (val2 & (1<<1)));
+			if (ext_phy_link_up) {
+				if (val2 & (1<<1))
+					vars->line_speed = SPEED_1000;
+				else
+					vars->line_speed = SPEED_10000;
+			}
+
 			/* clear LASI indication*/
 			bnx2x_cl45_read(bp, params->port, ext_phy_type,
 				      ext_phy_addr,
@@ -3006,6 +3072,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 					      MDIO_AN_DEVAD,
 					      MDIO_AN_REG_MASTER_STATUS,
 					      &val2);
+				vars->line_speed = SPEED_10000;
 				DP(NETIF_MSG_LINK,
 					 "SFX7101 AN status 0x%x->Master=%x\n",
 					  val2,
@@ -3181,7 +3248,8 @@ static u8 bnx2x_format_ver(u32 num, u8 *str, u16 len)
 }
 
 
-static void bnx2x_turn_on_sf(struct bnx2x *bp, u8 port, u8 ext_phy_addr)
+static void bnx2x_turn_on_ef(struct bnx2x *bp, u8 port, u8 ext_phy_addr,
+			   u32 ext_phy_type)
 {
 	u32 cnt = 0;
 	u16 ctrl = 0;
@@ -3205,7 +3273,7 @@ static void bnx2x_turn_on_sf(struct bnx2x *bp, u8 port, u8 ext_phy_addr)
 	for (cnt = 0; cnt < 1000; cnt++) {
 		msleep(1);
 		bnx2x_cl45_read(bp, port,
-			      PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
+			      ext_phy_type,
 			      ext_phy_addr,
 			      MDIO_PMA_DEVAD,
 			      MDIO_PMA_REG_CTRL,
@@ -3253,7 +3321,8 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 
 		/* Take ext phy out of reset */
 		if (!driver_loaded)
-			bnx2x_turn_on_sf(bp, params->port, ext_phy_addr);
+			bnx2x_turn_on_ef(bp, params->port, ext_phy_addr,
+				       ext_phy_type);
 
 		/*  wait for 1ms */
 		msleep(1);
@@ -3281,6 +3350,11 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
 	{
+		/* Take ext phy out of reset */
+		if (!driver_loaded)
+			bnx2x_turn_on_ef(bp, params->port, ext_phy_addr,
+				       ext_phy_type);
+
 		bnx2x_cl45_read(bp, params->port, ext_phy_type,
 			      ext_phy_addr,
 			      MDIO_PMA_DEVAD,
@@ -3622,7 +3696,8 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
 	u8 rc = 0;
-
+	u8 non_ext_phy;
+	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 	/* Activate the external PHY */
 	bnx2x_ext_phy_reset(params, vars);
 
@@ -3644,10 +3719,6 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 		bnx2x_set_swap_lanes(params);
 	}
 
-	/* Set Parallel Detect */
-	if (params->req_line_speed == SPEED_AUTO_NEG)
-		bnx2x_set_parallel_detection(params, vars->phy_flags);
-
 	if (vars->phy_flags & PHY_XGXS_FLAG) {
 		if (params->req_line_speed &&
 		    ((params->req_line_speed == SPEED_100) ||
@@ -3657,68 +3728,33 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 			vars->phy_flags &= ~PHY_SGMII_FLAG;
 		}
 	}
+	/* In case of external phy existance, the line speed would be the
+	 line speed linked up by the external phy. In case it is direct only,
+	  then the line_speed during initialization will be equal to the
+	   req_line_speed*/
+	vars->line_speed = params->req_line_speed;
 
-	if (!(vars->phy_flags & PHY_SGMII_FLAG)) {
-		u16 bank, rx_eq;
-
-		rx_eq = ((params->serdes_config &
-			  PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_MASK) >>
-			 PORT_HW_CFG_SERDES_RX_DRV_EQUALIZER_SHIFT);
-
-		DP(NETIF_MSG_LINK, "setting rx eq to 0x%x\n", rx_eq);
-		for (bank = MDIO_REG_BANK_RX0; bank <= MDIO_REG_BANK_RX_ALL;
-		      bank += (MDIO_REG_BANK_RX1-MDIO_REG_BANK_RX0)) {
-			CL45_WR_OVER_CL22(bp, port,
-					      params->phy_addr,
-					      bank ,
-					      MDIO_RX0_RX_EQ_BOOST,
-					      ((rx_eq &
-				MDIO_RX0_RX_EQ_BOOST_EQUALIZER_CTRL_MASK) |
-				MDIO_RX0_RX_EQ_BOOST_OFFSET_CTRL));
-		}
-
-		/* forced speed requested? */
-		if (params->req_line_speed != SPEED_AUTO_NEG) {
-			DP(NETIF_MSG_LINK, "not SGMII, no AN\n");
-
-			/* disable autoneg */
-			bnx2x_set_autoneg(params, vars);
-
-			/* program speed and duplex */
-			bnx2x_program_serdes(params);
-			vars->ieee_fc =
-				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE;
-
-		} else { /* AN_mode */
-			DP(NETIF_MSG_LINK, "not SGMII, AN\n");
-
-			/* AN enabled */
-			bnx2x_set_brcm_cl37_advertisment(params);
-
-			/* program duplex & pause advertisement (for aneg) */
-			bnx2x_set_ieee_aneg_advertisment(params,
-						       &vars->ieee_fc);
-
-			/* enable autoneg */
-			bnx2x_set_autoneg(params, vars);
-
-			/* enable and restart AN */
-			bnx2x_restart_autoneg(params);
-		}
+	bnx2x_set_ieee_aneg_advertisment(params, &vars->ieee_fc);
 
-	} else { /* SGMII mode */
-		DP(NETIF_MSG_LINK, "SGMII\n");
-
-		bnx2x_initialize_sgmii_process(params);
+	/* init ext phy and enable link state int */
+	non_ext_phy = ((ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) ||
+		       (params->loopback_mode == LOOPBACK_XGXS_10) ||
+		       (params->loopback_mode == LOOPBACK_EXT_PHY));
+
+	if (non_ext_phy ||
+	    (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705)) {
+		if (params->req_line_speed == SPEED_AUTO_NEG)
+			bnx2x_set_parallel_detection(params, vars->phy_flags);
+		bnx2x_init_internal_phy(params, vars);
 	}
 
-	/* init ext phy and enable link state int */
-	rc |= bnx2x_ext_phy_init(params, vars);
+	if (!non_ext_phy)
+		rc |= bnx2x_ext_phy_init(params, vars);
 
 	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-		       (NIG_STATUS_XGXS0_LINK10G |
-			NIG_STATUS_XGXS0_LINK_STATUS |
-			NIG_STATUS_SERDES0_LINK_STATUS));
+		     (NIG_STATUS_XGXS0_LINK10G |
+		      NIG_STATUS_XGXS0_LINK_STATUS |
+		      NIG_STATUS_SERDES0_LINK_STATUS));
 
 	return rc;
 
@@ -3734,6 +3770,13 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	DP(NETIF_MSG_LINK, "req_speed = %d, req_flowctrl=%d\n",
 		  params->req_line_speed, params->req_flow_ctrl);
 	vars->link_status = 0;
+	vars->phy_link_up = 0;
+	vars->link_up = 0;
+	vars->line_speed = 0;
+	vars->duplex = DUPLEX_FULL;
+	vars->flow_ctrl = FLOW_CTRL_NONE;
+	vars->mac_type = MAC_TYPE_NONE;
+
 	if (params->switch_cfg ==  SWITCH_CFG_1G)
 		vars->phy_flags = PHY_SERDES_FLAG;
 	else
@@ -3894,6 +3937,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		}
 
 		bnx2x_link_initialize(params, vars);
+		msleep(30);
 		bnx2x_link_int_enable(params);
 	}
 	return 0;
@@ -3949,33 +3993,13 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars)
 				       MISC_REGISTERS_GPIO_OUTPUT_LOW);
 
 			DP(NETIF_MSG_LINK, "reset external PHY\n");
-		} else {
-
-			u8 ext_phy_addr = ((ext_phy_config &
-					 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-					 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-
-			/* SW reset */
-			bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_CTRL,
-				       1<<15);
-
-			/* Set Low Power Mode */
-			bnx2x_cl45_write(bp, port, ext_phy_type, ext_phy_addr,
-				  MDIO_PMA_DEVAD,
-				  MDIO_PMA_REG_CTRL,
-				  1<<11);
-
-
-			if (ext_phy_type ==
-			    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
-				DP(NETIF_MSG_LINK, "Setting 8073 port %d into"
+		} else if (ext_phy_type ==
+			   PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073) {
+				DP(NETIF_MSG_LINK, "Setting 8073 port %d into "
 					 "low power mode\n",
 					 port);
 				bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
 					MISC_REGISTERS_GPIO_OUTPUT_LOW);
-			}
 		}
 	}
 	/* reset the SerDes/XGXS */
@@ -3995,6 +4019,73 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars)
 	return 0;
 }
 
+static u8 bnx2x_update_link_down(struct link_params *params,
+			       struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u8 port = params->port;
+	DP(NETIF_MSG_LINK, "Port %x: Link is down\n", port);
+	bnx2x_set_led(bp, port, LED_MODE_OFF,
+		    0, params->hw_led_mode,
+		    params->chip_id);
+
+	/* indicate no mac active */
+	vars->mac_type = MAC_TYPE_NONE;
+
+	/* update shared memory */
+	vars->link_status = 0;
+	vars->line_speed = 0;
+	bnx2x_update_mng(params, vars->link_status);
+
+	/* activate nig drain */
+	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
+
+	/* reset BigMac */
+	bnx2x_bmac_rx_disable(bp, params->port);
+	REG_WR(bp, GRCBASE_MISC +
+		   MISC_REGISTERS_RESET_REG_2_CLEAR,
+		   (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+	return 0;
+}
+
+static u8 bnx2x_update_link_up(struct link_params *params,
+			     struct link_vars *vars,
+			     u8 link_10g, u32 gp_status)
+{
+	struct bnx2x *bp = params->bp;
+	u8 port = params->port;
+	u8 rc = 0;
+	vars->link_status |= LINK_STATUS_LINK_UP;
+	if (link_10g) {
+		bnx2x_bmac_enable(params, vars, 0);
+		bnx2x_set_led(bp, port, LED_MODE_OPER,
+			    SPEED_10000, params->hw_led_mode,
+			    params->chip_id);
+
+	} else {
+		bnx2x_emac_enable(params, vars, 0);
+		rc = bnx2x_emac_program(params, vars->line_speed,
+				      vars->duplex);
+
+		/* AN complete? */
+		if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
+			if (!(vars->phy_flags &
+			      PHY_SGMII_FLAG))
+				bnx2x_set_sgmii_tx_driver(params);
+		}
+	}
+
+	/* PBF - link up */
+	rc |= bnx2x_pbf_update(params, vars->flow_ctrl,
+			      vars->line_speed);
+
+	/* disable drain */
+	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 0);
+
+	/* update shared memory */
+	bnx2x_update_mng(params, vars->link_status);
+	return rc;
+}
 /* This function should called upon link interrupt */
 /* In case vars->link_up, driver needs to
 	1. Update the pbf
@@ -4012,10 +4103,10 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
-	u16 i;
 	u16 gp_status;
-	u16 link_10g;
-	u8 rc = 0;
+	u8 link_10g;
+	u8 ext_phy_link_up, rc = 0;
+	u32 ext_phy_type;
 
 	DP(NETIF_MSG_LINK, "port %x, XGXS?%x, int_status 0x%x\n",
 	 port,
@@ -4031,15 +4122,16 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	  REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK10G + port*0x68),
 	  REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK_STATUS + port*0x68));
 
+	ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 
-	/* avoid fast toggling */
-	for (i = 0; i < 10; i++) {
-		msleep(10);
-		CL45_RD_OVER_CL22(bp, port, params->phy_addr,
-				      MDIO_REG_BANK_GP_STATUS,
-				      MDIO_GP_STATUS_TOP_AN_STATUS1,
-				      &gp_status);
-	}
+	/* Check external link change only for non-direct */
+	ext_phy_link_up = bnx2x_ext_phy_is_link_up(params, vars);
+
+	/* Read gp_status */
+	CL45_RD_OVER_CL22(bp, port, params->phy_addr,
+			      MDIO_REG_BANK_GP_STATUS,
+			      MDIO_GP_STATUS_TOP_AN_STATUS1,
+			      &gp_status);
 
 	rc = bnx2x_link_settings_status(params, vars, gp_status);
 	if (rc != 0)
@@ -4055,69 +4147,25 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 
 	bnx2x_link_int_ack(params, vars, link_10g);
 
-	/* link is up only if both local phy and external phy are up */
-	vars->link_up = (vars->phy_link_up &&
-			   bnx2x_ext_phy_is_link_up(params, vars));
-
-	if (!vars->phy_link_up &&
-	    REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT + port*0x18)) {
-		bnx2x_ext_phy_is_link_up(params, vars); /* Clear interrupt */
-	}
-
-	if (vars->link_up) {
-		vars->link_status |= LINK_STATUS_LINK_UP;
-		if (link_10g) {
-			bnx2x_bmac_enable(params, vars, 0);
-			bnx2x_set_led(bp, port, LED_MODE_OPER,
-				    SPEED_10000, params->hw_led_mode,
-				    params->chip_id);
-
-		} else {
-			bnx2x_emac_enable(params, vars, 0);
-			rc = bnx2x_emac_program(params, vars->line_speed,
-					      vars->duplex);
-
-			/* AN complete? */
-			if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
-				if (!(vars->phy_flags &
-				      PHY_SGMII_FLAG))
-					bnx2x_set_sgmii_tx_driver(params);
-			}
-		}
-
-		/* PBF - link up */
-		rc |= bnx2x_pbf_update(params, vars->flow_ctrl,
-				      vars->line_speed);
+	/* In case external phy link is up, and internal link is down
+	( not initialized yet probably after link initialization, it needs
+	to be initialized.
+	Note that after link down-up as result of cable plug,
+	the xgxs link would probably become up again without the need to
+	initialize it*/
 
-		/* disable drain */
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 0);
+	if ((ext_phy_type != PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT) &&
+	    (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) &&
+	    (ext_phy_link_up && !vars->phy_link_up))
+		bnx2x_init_internal_phy(params, vars);
 
-		/* update shared memory */
-		bnx2x_update_mng(params, vars->link_status);
-
-	} else { /* link down */
-		DP(NETIF_MSG_LINK, "Port %x: Link is down\n", params->port);
-		bnx2x_set_led(bp, port, LED_MODE_OFF,
-			    0, params->hw_led_mode,
-			    params->chip_id);
-
-		/* indicate no mac active */
-		vars->mac_type = MAC_TYPE_NONE;
-
-		/* update shared memory */
-		vars->link_status = 0;
-		bnx2x_update_mng(params, vars->link_status);
-
-		/* activate nig drain */
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
-
-		/* reset BigMac */
-		bnx2x_bmac_rx_disable(bp, params->port);
-		REG_WR(bp, GRCBASE_MISC +
-			   MISC_REGISTERS_RESET_REG_2_CLEAR,
-			   (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+	/* link is up only if both local phy and external phy are up */
+	vars->link_up = (ext_phy_link_up && vars->phy_link_up);
 
-	}
+	if (vars->link_up)
+		rc = bnx2x_update_link_up(params, vars, link_10g, gp_status);
+	else
+		rc = bnx2x_update_link_down(params, vars);
 
 	return rc;
 }
@@ -4508,7 +4556,7 @@ u8 bnx2x_flash_download(struct bnx2x *bp, u8 port, u32 ext_phy_config,
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 		/* Take ext phy out of reset */
 		if (!driver_loaded)
-			bnx2x_turn_on_sf(bp, port, ext_phy_addr);
+			bnx2x_turn_on_ef(bp, port, ext_phy_addr, ext_phy_type);
 		rc = bnx2x_sfx7101_flash_download(bp, port, ext_phy_addr,
 						data, size);
 		if (!driver_loaded)
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
old mode 100644
new mode 100755
index a85ff20..58fbeb1
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -5559,6 +5559,8 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_PMA_REG_GEN_CTRL		0xca10
 #define MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP	0x0188
 #define MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET		0x018a
+#define MDIO_PMA_REG_M8051_MSGIN_REG	0xca12
+#define MDIO_PMA_REG_M8051_MSGOUT_REG	0xca13
 #define MDIO_PMA_REG_ROM_VER1		0xca19
 #define MDIO_PMA_REG_ROM_VER2		0xca1a
 #define MDIO_PMA_REG_EDC_FFE_MAIN	0xca1b
-- 
1.5.3.2




