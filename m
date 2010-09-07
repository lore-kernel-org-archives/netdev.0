From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 02/10] bnx2x: Split PHY functions
Date: Wed, 8 Sep 2010 00:40:54 +0300
Message-ID: <1283895654.5452.62.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1149 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932417Ab0IGSW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 14:22:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the code into PHY oriented functions, and for that a new structure
is defines for each PHY which contain PHY properties and its own
functions. This also enables to encapsulate all PHY specific operations
into the PHY functions. During initialization, the PHYs will be probed
by the "bnx2x_phy_probe" function to detect which PHYs exist on-board,
and configure them accordingly. Note that the ext_phy_reset
implementation was incorporated in the ext_phy_init since it is actually
part of the PHY initialization procedure. 

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_ethtool.c |   35 +-
 drivers/net/bnx2x/bnx2x_link.c    | 1864 +++++++++++++++++++++++++------------
 drivers/net/bnx2x/bnx2x_link.h    |  109 ++-
 drivers/net/bnx2x/bnx2x_main.c    |  270 +-----
 4 files changed, 1425 insertions(+), 853 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 2c7e0ab..becfd9e 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -52,39 +52,14 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->duplex = -1;
 	}
 
-	if (bp->link_params.switch_cfg == SWITCH_CFG_10G) {
-		u32 ext_phy_type =
-			XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
-
-		switch (ext_phy_type) {
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
+	if (bp->link_params.num_phys > 0) {
+		if (bp->link_params.phy[bp->link_params.num_phys - 1].
+		    supported &	SUPPORTED_FIBRE)
 			cmd->port = PORT_FIBRE;
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
+		else
 			cmd->port = PORT_TP;
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
-			BNX2X_ERR("XGXS PHY Failure detected 0x%x\n",
-				  bp->link_params.ext_phy_config);
-			break;
-
-		default:
-			DP(NETIF_MSG_LINK, "BAD XGXS ext_phy_config 0x%x\n",
-			   bp->link_params.ext_phy_config);
-			break;
-		}
 	} else
-		cmd->port = PORT_TP;
-
+		DP(NETIF_MSG_LINK, "No media found\n");
 	cmd->phy_address = bp->mdio.prtad;
 	cmd->transceiver = XCVR_INTERNAL;
 
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index b89439d..1da8f81 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -1776,16 +1776,20 @@ static void bnx2x_check_fallback_to_cl37(struct bnx2x_phy *phy,
 	bnx2x_restart_autoneg(phy, params, 0);
 	DP(NETIF_MSG_LINK, "Disabling CL73, and restarting CL37 autoneg\n");
 }
-static u8 bnx2x_link_settings_status(struct link_params *params,
-				   struct link_vars *vars,
-				   u32 gp_status,
-				   u8 ext_phy_link_up)
+static u8 bnx2x_link_settings_status(struct bnx2x_phy *phy,
+				     struct link_params *params,
+				     struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u16 new_line_speed;
+	u16 new_line_speed , gp_status;
 	u8 rc = 0;
 	u32 ext_phy_type;
-	vars->link_status = 0;
+	/* Read gp_status */
+	CL45_RD_OVER_CL22(bp, phy,
+				MDIO_REG_BANK_GP_STATUS,
+				MDIO_GP_STATUS_TOP_AN_STATUS1,
+				&gp_status);
+
 	if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) {
 		DP(NETIF_MSG_LINK, "phy link up gp_status=0x%x\n",
 			 gp_status);
@@ -1881,23 +1885,6 @@ static u8 bnx2x_link_settings_status(struct link_params *params,
 			return -EINVAL;
 		}
 
-		/* Upon link speed change set the NIG into drain mode.
-		Comes to deals with possible FIFO glitch due to clk change
-		when speed is decreased without link down indicator */
-		if (new_line_speed != vars->line_speed) {
-			if (!SINGLE_MEDIA_DIRECT(params) &&
-			    ext_phy_link_up) {
-				DP(NETIF_MSG_LINK, "Internal link speed %d is"
-					    " different than the external"
-					    " link speed %d\n", new_line_speed,
-					  vars->line_speed);
-				vars->phy_link_up = 0;
-				return 0;
-			}
-			REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE
-				    + params->port*4, 0);
-			msleep(1);
-		}
 		vars->line_speed = new_line_speed;
 		vars->link_status |= LINK_STATUS_SERDES_LINK;
 		ext_phy_type = params->phy[EXT_PHY1].type;
@@ -2001,7 +1988,7 @@ static void bnx2x_set_gmii_tx_driver(struct link_params *params)
 }
 
 static u8 bnx2x_emac_program(struct link_params *params,
-			   u32 line_speed, u32 duplex)
+			     struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
@@ -2013,7 +2000,7 @@ static u8 bnx2x_emac_program(struct link_params *params,
 		     (EMAC_MODE_25G_MODE |
 		     EMAC_MODE_PORT_MII_10M |
 		     EMAC_MODE_HALF_DUPLEX));
-	switch (line_speed) {
+	switch (vars->line_speed) {
 	case SPEED_10:
 		mode |= EMAC_MODE_PORT_MII_10M;
 		break;
@@ -2032,21 +2019,74 @@ static u8 bnx2x_emac_program(struct link_params *params,
 
 	default:
 		/* 10G not valid for EMAC */
-		DP(NETIF_MSG_LINK, "Invalid line_speed 0x%x\n", line_speed);
+		DP(NETIF_MSG_LINK, "Invalid line_speed 0x%x\n",
+			   vars->line_speed);
 		return -EINVAL;
 	}
 
-	if (duplex == DUPLEX_HALF)
+	if (vars->duplex == DUPLEX_HALF)
 		mode |= EMAC_MODE_HALF_DUPLEX;
 	bnx2x_bits_en(bp,
 		    GRCBASE_EMAC0 + port*0x400 + EMAC_REG_EMAC_MODE,
 		    mode);
 
-	bnx2x_set_led(params, LED_MODE_OPER, line_speed);
+	bnx2x_set_led(params, LED_MODE_OPER, vars->line_speed);
 	return 0;
 }
 
+static u8 bnx2x_init_serdes(struct bnx2x_phy *phy,
+			    struct link_params *params,
+			    struct link_vars *vars)
+{
+	u8 rc;
+	vars->phy_flags |= PHY_SGMII_FLAG;
+	bnx2x_calc_ieee_aneg_adv(phy, params, &vars->ieee_fc);
+	bnx2x_set_aer_mmd(params, phy);
+	rc = bnx2x_reset_unicore(params, phy, 1);
+	/* reset the SerDes and wait for reset bit return low */
+	if (rc != 0)
+		return rc;
+	bnx2x_set_aer_mmd(params, phy);
+
+	return rc;
+}
 
+static u8 bnx2x_init_xgxs(struct bnx2x_phy *phy,
+			  struct link_params *params,
+			  struct link_vars *vars)
+{
+	u8 rc;
+	vars->phy_flags = PHY_XGXS_FLAG;
+	if ((phy->req_line_speed &&
+	     ((phy->req_line_speed == SPEED_100) ||
+	      (phy->req_line_speed == SPEED_10))) ||
+	    (!phy->req_line_speed &&
+	     (phy->speed_cap_mask >=
+	      PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL) &&
+	     (phy->speed_cap_mask <
+	      PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)
+	     ))
+		vars->phy_flags |= PHY_SGMII_FLAG;
+	else
+		vars->phy_flags &= ~PHY_SGMII_FLAG;
+
+	bnx2x_calc_ieee_aneg_adv(phy, params, &vars->ieee_fc);
+	bnx2x_set_aer_mmd(params, phy);
+	bnx2x_set_master_ln(params, phy);
+
+	rc = bnx2x_reset_unicore(params, phy, 0);
+	/* reset the SerDes and wait for reset bit return low */
+	if (rc != 0)
+		return rc;
+
+	bnx2x_set_aer_mmd(params, phy);
+
+	/* setting the masterLn_def again after the reset */
+	bnx2x_set_master_ln(params, phy);
+	bnx2x_set_swap_lanes(params, phy);
+
+	return rc;
+}
 /*****************************************************************************/
 /*      		     External Phy section       		     */
 /*****************************************************************************/
@@ -2059,127 +2099,6 @@ void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port)
 		      MISC_REGISTERS_GPIO_OUTPUT_HIGH, port);
 }
 
-static void bnx2x_ext_phy_reset(struct bnx2x_phy   *phy,
-				struct link_params *params,
-				struct link_vars   *vars)
-{
-	struct bnx2x *bp = params->bp;
-	DP(NETIF_MSG_LINK, "Port %x: bnx2x_ext_phy_reset\n", params->port);
-	/* The PHY reset is controled by GPIO 1
-	 * Give it 1ms of reset pulse
-	 */
-		switch (phy->type) {
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-			DP(NETIF_MSG_LINK, "XGXS Direct\n");
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-			DP(NETIF_MSG_LINK, "XGXS 8705/8706\n");
-
-			/* Restore normal power mode*/
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
-					  params->port);
-
-			/* HW reset */
-			bnx2x_ext_phy_hw_reset(bp, params->port);
-
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_CTRL, 0xa040);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-
-			/* Restore normal power mode*/
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-					  MISC_REGISTERS_GPIO_OUTPUT_HIGH,
-					  params->port);
-
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-					  MISC_REGISTERS_GPIO_OUTPUT_HIGH,
-					  params->port);
-
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_CTRL,
-				       1<<15);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-			DP(NETIF_MSG_LINK, "XGXS 8072\n");
-
-			/* Unset Low Power Mode and SW reset */
-			/* Restore normal power mode*/
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
-					  params->port);
-
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_CTRL,
-				       1<<15);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-			DP(NETIF_MSG_LINK, "XGXS 8073\n");
-
-			/* Restore normal power mode*/
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
-					  params->port);
-
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
-					  params->port);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-			DP(NETIF_MSG_LINK, "XGXS SFX7101\n");
-
-			/* Restore normal power mode*/
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
-					  params->port);
-
-			/* HW reset */
-			bnx2x_ext_phy_hw_reset(bp, params->port);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
-			/* Restore normal power mode*/
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-				      MISC_REGISTERS_GPIO_OUTPUT_HIGH,
-					  params->port);
-
-			/* HW reset */
-			bnx2x_ext_phy_hw_reset(bp, params->port);
-
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_CTRL,
-				       1<<15);
-			break;
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
-			msleep(1);
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
-				       MISC_REGISTERS_GPIO_OUTPUT_HIGH,
-				       params->port);
-			break;
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
-			DP(NETIF_MSG_LINK, "XGXS PHY Failure detected\n");
-			break;
-		default:
-			DP(NETIF_MSG_LINK, "BAD phy type 0x%x\n",
-				 phy->type);
-			break;
-		}
-}
-
 static void bnx2x_save_spirom_version(struct bnx2x *bp, u8 port,
 				    u32 shmem_base, u32 spirom_ver)
 {
@@ -2498,11 +2417,13 @@ static void bnx2x_8726_external_rom_boot(struct bnx2x_phy *phy,
 
 static void bnx2x_sfp_set_transmitter(struct bnx2x *bp,
 				      struct bnx2x_phy *phy,
+				      u8 port,
 				      u8 tx_en)
 {
 	u16 val;
 
-	DP(NETIF_MSG_LINK, "Setting transmitter tx_en=%x\n", tx_en);
+	DP(NETIF_MSG_LINK, "Setting transmitter tx_en=%x for port %x\n",
+		 tx_en, port);
 	/* Disable/Enable transmitter ( TX laser of the SFP+ module.)*/
 	bnx2x_cl45_read(bp, phy,
 		      MDIO_PMA_DEVAD,
@@ -2946,9 +2867,10 @@ static void bnx2x_8727_power_module(struct bnx2x *bp,
 	 * In case of NOC feature is disabled and power is up, set GPIO control
 	 *  as input to enable listening of over-current indication
 	 */
-
-	if (!(params->feature_config_flags &
-	      FEATURE_CONFIG_BCM8727_NOC) && is_power_up)
+	if (phy->flags & FLAGS_NOC)
+		return;
+	if (!(phy->flags &
+	      FLAGS_NOC) && is_power_up)
 		val = (1<<4);
 	else
 		/*
@@ -3022,9 +2944,9 @@ static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 	if (rc == 0 ||
 	    (val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) !=
 	    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
-		bnx2x_sfp_set_transmitter(bp, phy, 1);
+		bnx2x_sfp_set_transmitter(bp, phy, params->port, 1);
 	else
-		bnx2x_sfp_set_transmitter(bp, phy, 0);
+		bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
 
 	return rc;
 }
@@ -3068,7 +2990,7 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 		/* Disable transmit for this module */
 		if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
 		    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
-			bnx2x_sfp_set_transmitter(bp, phy, 0);
+			bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
 	}
 }
 
@@ -3233,7 +3155,7 @@ static void bnx2x_set_preemphasis(struct bnx2x_phy *phy,
 			CL45_WR_OVER_CL22(bp, phy,
 					      bank,
 					      MDIO_RX0_RX_EQ_BOOST,
-					      params->xgxs_config_rx[i]);
+					  phy->rx_preemphasis[i]);
 	}
 
 	for (bank = MDIO_REG_BANK_TX0, i = 0; bank <= MDIO_REG_BANK_TX3;
@@ -3241,7 +3163,7 @@ static void bnx2x_set_preemphasis(struct bnx2x_phy *phy,
 			CL45_WR_OVER_CL22(bp, phy,
 					      bank,
 					      MDIO_TX0_TX_DRIVER,
-					      params->xgxs_config_tx[i]);
+					  phy->tx_preemphasis[i]);
 	}
 }
 
@@ -3331,24 +3253,10 @@ static void bnx2x_init_internal_phy(struct bnx2x_phy *phy,
 	}
 }
 
-static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
+static u16 bnx2x_wait_reset_complete(struct bnx2x *bp,
+				     struct bnx2x_phy *phy)
 {
-	struct bnx2x *bp = params->bp;
-	u16 cnt;
-	u16 ctrl = 0;
-	u16 val = 0;
-	u8 rc = 0;
-	struct bnx2x_phy *phy = &params->phy[EXT_PHY1];
-	if (vars->phy_flags & PHY_XGXS_FLAG) {
-		/* Make sure that the soft reset is off (expect for the 8072:
-		 * due to the lock, it will be done inside the specific
-		 * handling)
-		 */
-		if ((phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) &&
-		    (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) &&
-		   (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN) &&
-		    (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072) &&
-		    (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073)) {
+	u16 cnt, ctrl;
 			/* Wait for soft reset to get cleared upto 1 sec */
 			for (cnt = 0; cnt < 1000; cnt++) {
 				bnx2x_cl45_read(bp, phy,
@@ -3360,13 +3268,22 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			}
 			DP(NETIF_MSG_LINK, "control reg 0x%x (after %d ms)\n",
 				 ctrl, cnt);
-		}
-
-		switch (phy->type) {
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-			break;
+			return 0;
+}
 
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
+static u8 bnx2x_8705_config_init(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	DP(NETIF_MSG_LINK, "init 8705\n");
+	/* Restore normal power mode*/
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
+	/* HW reset */
+	bnx2x_ext_phy_hw_reset(bp, params->port);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0xa040);
+	bnx2x_wait_reset_complete(bp, phy);
 			DP(NETIF_MSG_LINK, "XGXS 8705\n");
 
 			bnx2x_cl45_write(bp, phy,
@@ -3388,9 +3305,23 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			/* BCM8705 doesn't have microcode, hence the 0 */
 			bnx2x_save_spirom_version(bp, params->port,
 						params->shmem_base, 0);
-			break;
 
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
+			return 0;
+}
+
+static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	u16 cnt, val;
+	struct bnx2x *bp = params->bp;
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
+	/* HW reset */
+	bnx2x_ext_phy_hw_reset(bp, params->port);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0xa040);
+
+	bnx2x_wait_reset_complete(bp, phy);
 			/* Wait until fw is loaded */
 			for (cnt = 0; cnt < 100; cnt++) {
 				bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD,
@@ -3416,7 +3347,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 					val &= ~0x7;
 					/* Set control bits according to
 					configuation */
-					val |= (params->xgxs_config_rx[i] &
+					val |= (phy->rx_preemphasis[i] &
 						0x7);
 					DP(NETIF_MSG_LINK, "Setting RX"
 						 "Equalizer to BCM8706 reg 0x%x"
@@ -3479,8 +3410,26 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			bnx2x_save_bcm_spirom_ver(bp, params->port,
 						phy,
 						params->shmem_base);
-			break;
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+			return 0;
+}
+
+static u8 bnx2x_8726_config_init(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	DP(NETIF_MSG_LINK, "Initializing BCM8726\n");
+	/* Restore normal power mode*/
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
+
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
+			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
+
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 1<<15);
+	bnx2x_wait_reset_complete(bp, phy);
+
+	bnx2x_wait_reset_complete(bp, phy);
 			DP(NETIF_MSG_LINK, "Initializing BCM8726\n");
 			bnx2x_8726_external_rom_boot(phy, params);
 
@@ -3538,21 +3487,39 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED)) {
 				DP(NETIF_MSG_LINK, "Setting TX_CTRL1 0x%x,"
 					 "TX_CTRL2 0x%x\n",
-					 params->xgxs_config_tx[0],
-					 params->xgxs_config_tx[1]);
+			 phy->tx_preemphasis[0],
+			 phy->tx_preemphasis[1]);
 				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_8726_TX_CTRL1,
-					       params->xgxs_config_tx[0]);
+				 phy->tx_preemphasis[0]);
 
 				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_8726_TX_CTRL2,
-					       params->xgxs_config_tx[1]);
+				 phy->tx_preemphasis[1]);
 			}
-			break;
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
+			return 0;
+
+}
+
+static u8 bnx2x_8072_8073_config_init(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u16 val = 0;
+	u8 gpio_port;
+	DP(NETIF_MSG_LINK, "Init 8073\n");
+
+	gpio_port = params->port;
+	/* Restore normal power mode*/
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
+
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
+			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
+
 		{
 			u16 tmp1;
 			u16 rx_alarm_ctrl_val;
@@ -3606,7 +3573,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 				bnx2x_807x_force_10G(bp, phy);
 				DP(NETIF_MSG_LINK,
 					"Forced speed 10G on 807X\n");
-				break;
+				return 0;
 			} else {
 				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
@@ -3728,21 +3695,25 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			   "Advertise 1G=%x, 10G=%x\n",
 			   ((val & (1<<5)) > 0),
 			   ((val & (1<<7)) > 0));
-			break;
+			return 0;
 		}
+}
 
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
-		{
-			u16 tmp1;
-			u16 rx_alarm_ctrl_val;
-			u16 lasi_ctrl_val;
+static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	u16 tmp1, val, mod_abs;
+	u16 rx_alarm_ctrl_val;
+	u16 lasi_ctrl_val;
+	struct bnx2x *bp = params->bp;
+	/* Enable PMD link, MOD_ABS_FLT, and 1G link alarm */
 
 			/* Enable PMD link, MOD_ABS_FLT, and 1G link alarm */
 
-			u16 mod_abs;
 			rx_alarm_ctrl_val = (1<<2) | (1<<5) ;
 			lasi_ctrl_val = 0x0004;
-
+			bnx2x_wait_reset_complete(bp, phy);
 			DP(NETIF_MSG_LINK, "Initializing BCM8727\n");
 			/* enable LASI */
 			bnx2x_cl45_write(bp, phy,
@@ -3861,28 +3832,39 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED)) {
 				DP(NETIF_MSG_LINK, "Setting TX_CTRL1 0x%x,"
 					 "TX_CTRL2 0x%x\n",
-					 params->xgxs_config_tx[0],
-					 params->xgxs_config_tx[1]);
+					 phy->tx_preemphasis[0],
+			   phy->tx_preemphasis[1]);
 				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_8727_TX_CTRL1,
-					       params->xgxs_config_tx[0]);
+					       phy->tx_preemphasis[0]);
 
 				bnx2x_cl45_write(bp, phy,
 					       MDIO_PMA_DEVAD,
 					       MDIO_PMA_REG_8727_TX_CTRL2,
-					       params->xgxs_config_tx[1]);
+					       phy->tx_preemphasis[1]);
 			}
 
-			break;
-		}
+			return 0;
+}
+
+static u8 bnx2x_7101_config_init(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	u16 fw_ver1, fw_ver2, val;
+	struct bnx2x *bp = params->bp;
+	DP(NETIF_MSG_LINK, "Setting the SFX7101 LASI indication\n");
+
+	/* Restore normal power mode*/
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
+	/* HW reset */
+	bnx2x_ext_phy_hw_reset(bp, params->port);
 
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-		{
-			u16 fw_ver1, fw_ver2;
 			DP(NETIF_MSG_LINK,
 				"Setting the SFX7101 LASI indication\n");
-
+			bnx2x_wait_reset_complete(bp, phy);
 			bnx2x_cl45_write(bp, phy,
 				       MDIO_PMA_DEVAD,
 				       MDIO_PMA_REG_LASI_CTRL, 0x1);
@@ -3912,10 +3894,14 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			bnx2x_save_spirom_version(params->bp, params->port,
 						params->shmem_base,
 						(u32)(fw_ver1<<16 | fw_ver2));
-			break;
-		}
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
+			return 0;
+}
+
+static u8 bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
+				      struct link_params *params,
+				      struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
 		{
 			/* This phy uses the NIG latch mechanism since link
 				indication arrives through its LED4 and not via
@@ -3924,6 +3910,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			u16 autoneg_val, an_1000_val, an_10_100_val, temp;
 			temp = vars->line_speed;
 			vars->line_speed = SPEED_10000;
+			bnx2x_wait_reset_complete(bp, phy);
 			bnx2x_set_autoneg(phy, params, vars, 0);
 			bnx2x_program_serdes(phy, params, vars);
 			vars->line_speed = temp;
@@ -4052,24 +4039,49 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 			/* Save spirom version */
 			bnx2x_save_8481_spirom_version(phy, params,
 						       params->shmem_base);
-			break;
+			return 0;
 		}
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
-			DP(NETIF_MSG_LINK,
-				 "XGXS PHY Failure detected 0x%x\n",
-				 phy->type);
-			rc = -EINVAL;
-			break;
+}
 
-		default:
-			DP(NETIF_MSG_LINK, "BAD SerDes ext_phy_config 0x%x\n",
-			   phy->type);
-			break;
-		}
-	}
-	return rc;
+static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
+				  struct link_params *params,
+				  struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u16 temp;
+	msleep(1);
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
+		       MISC_REGISTERS_GPIO_OUTPUT_HIGH,
+		       params->port);
+	msleep(200); /* 100 is not enough */
+
+	/**
+	 * BCM84823 requires that XGXS links up first @ 10G for normal
+	 * behavior
+	 */
+	temp = vars->line_speed;
+	vars->line_speed = SPEED_10000;
+	bnx2x_set_autoneg(phy, params, vars, 0);
+	bnx2x_program_serdes(phy, params, vars);
+	vars->line_speed = temp;
+	return bnx2x_848xx_cmn_config_init(phy, params, vars);
 }
 
+static u8 bnx2x_8481_config_init(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	/* Restore normal power mode*/
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
+
+	/* HW reset */
+	bnx2x_ext_phy_hw_reset(bp, params->port);
+
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 1<<15);
+	return bnx2x_848xx_cmn_config_init(phy, params, vars);
+}
 static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 				      struct link_params *params)
 {
@@ -4134,7 +4146,7 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 
 		if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
 		    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
-			bnx2x_sfp_set_transmitter(bp, phy, 0);
+			bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
 
 		if (bnx2x_wait_for_sfp_module_initialized(phy, params) == 0)
 			bnx2x_sfp_module_detection(phy, params);
@@ -4148,25 +4160,13 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 	module plugged in/out */
 }
 
-
-static u8 bnx2x_ext_phy_is_link_up(struct bnx2x_phy *phy,
+static u8 bnx2x_8705_read_status(struct bnx2x_phy *phy,
 				 struct link_params *params,
-				 struct link_vars *vars,
-				 u8 is_mi_int)
+				 struct link_vars *vars)
 {
-	struct bnx2x *bp = params->bp;
-	u16 val1 = 0, val2;
-	u16 rx_sd, pcs_status;
 	u8 ext_phy_link_up = 0;
-
-	if (vars->phy_flags & PHY_XGXS_FLAG) {
-		switch (phy->type) {
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-			DP(NETIF_MSG_LINK, "XGXS Direct\n");
-			ext_phy_link_up = 1;
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
+	u16 val1, rx_sd;
+	struct bnx2x *bp = params->bp;
 			DP(NETIF_MSG_LINK, "XGXS 8705\n");
 			bnx2x_cl45_read(bp, phy,
 				      MDIO_WIS_DEVAD,
@@ -4194,10 +4194,16 @@ static u8 bnx2x_ext_phy_is_link_up(struct bnx2x_phy *phy,
 					   ((val1 & (1<<8)) == 0));
 			if (ext_phy_link_up)
 				vars->line_speed = SPEED_10000;
-			break;
+			return ext_phy_link_up;
+}
 
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+static u8 bnx2x_8706_8726_read_status(struct bnx2x_phy *phy,
+				      struct link_params *params,
+				      struct link_vars *vars)
+{
+	u8 link_up = 0;
+	u16 val1, val2, rx_sd, pcs_status;
+	struct bnx2x *bp = params->bp;
 			DP(NETIF_MSG_LINK, "XGXS 8706/8726\n");
 			/* Clear RX Alarm*/
 			bnx2x_cl45_read(bp, phy,
@@ -4233,35 +4239,54 @@ static u8 bnx2x_ext_phy_is_link_up(struct bnx2x_phy *phy,
 			 * bit 0 of pcs_status are set, or if the autoneg bit
 			   1 is set
 			 */
-			ext_phy_link_up = ((rx_sd & pcs_status & 0x1) ||
-					   (val2 & (1<<1)));
-			if (ext_phy_link_up) {
-				if (phy->type ==
-				     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) {
-					/* If transmitter is disabled,
-					ignore false link up indication */
-					bnx2x_cl45_read(bp, phy,
-						   MDIO_PMA_DEVAD,
-						   MDIO_PMA_REG_PHY_IDENTIFIER,
-						   &val1);
-					if (val1 & (1<<15)) {
-						DP(NETIF_MSG_LINK, "Tx is "
-							    "disabled\n");
-						ext_phy_link_up = 0;
-						break;
-					}
-				}
+			link_up = ((rx_sd & pcs_status & 0x1) ||
+					(val2 & (1<<1)));
+			if (link_up) {
 				if (val2 & (1<<1))
 					vars->line_speed = SPEED_1000;
 				else
 					vars->line_speed = SPEED_10000;
+				bnx2x_ext_phy_resolve_fc(phy, params, vars);
+				return link_up;
 			}
-			break;
+			return 0;
+}
 
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
-		{
+static u8 bnx2x_8706_read_status(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	return bnx2x_8706_8726_read_status(phy, params, vars);
+}
+
+static u8 bnx2x_8726_read_status(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u16 val1;
+	u8 link_up = bnx2x_8706_8726_read_status(phy, params, vars);
+	if (link_up) {
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER,
+				&val1);
+		if (val1 & (1<<15)) {
+			DP(NETIF_MSG_LINK, "Tx is disabled\n");
+			link_up = 0;
+			vars->line_speed = 0;
+		}
+	}
+	return link_up;
+}
+static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+
+{
+	struct bnx2x *bp = params->bp;
+	u8 ext_phy_link_up = 0;
 			u16 link_status = 0;
-			u16 rx_alarm_status;
+			u16 rx_alarm_status, val1;
 			/* Check the LASI */
 			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
@@ -4288,8 +4313,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct bnx2x_phy *phy,
 			 * If a module is present and there is need to check
 			 * for over current
 			 */
-			if (!(params->feature_config_flags &
-			      FEATURE_CONFIG_BCM8727_NOC) &&
+			if (!(phy->flags & FLAGS_NOC) &&
 			    !(rx_alarm_status & (1<<5))) {
 				/* Check over-current using 8727 GPIO0 input*/
 				bnx2x_cl45_read(bp, phy,
@@ -4328,7 +4352,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct bnx2x_phy *phy,
 						      MDIO_PMA_DEVAD,
 						      MDIO_PMA_REG_RX_ALARM,
 						      &rx_alarm_status);
-					break;
+					return ext_phy_link_up;
 				}
 			} /* Over current check */
 
@@ -4351,7 +4375,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct bnx2x_phy *phy,
 			if (val1 & (1<<15)) {
 				DP(NETIF_MSG_LINK, "Tx is disabled\n");
 				ext_phy_link_up = 0;
-				break;
+				return ext_phy_link_up;
 			}
 
 			bnx2x_cl45_read(bp, phy,
@@ -4378,12 +4402,16 @@ static u8 bnx2x_ext_phy_is_link_up(struct bnx2x_phy *phy,
 					 "port %x: External link"
 					 " is down\n", params->port);
 			}
-			break;
-		}
+			return ext_phy_link_up;
 
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-		{
+}
+static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u8 ext_phy_link_up = 0;
+	u16 val1, val2;
 			u16 link_status = 0;
 			u16 an1000_status = 0;
 
@@ -4456,7 +4484,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct bnx2x_phy *phy,
 					if (bnx2x_8073_xaui_wa(bp, phy)
 					     != 0) {
 						ext_phy_link_up = 0;
-						break;
+						return ext_phy_link_up;
 					}
 				}
 				bnx2x_cl45_read(bp, phy,
@@ -4561,9 +4589,16 @@ static u8 bnx2x_ext_phy_is_link_up(struct bnx2x_phy *phy,
 				}
 			}
 
-			break;
-		}
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
+			return ext_phy_link_up;
+}
+
+static u8 bnx2x_7101_read_status(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u8 ext_phy_link_up;
+	u16 val1, val2;
 			bnx2x_cl45_read(bp, phy,
 				      MDIO_PMA_DEVAD,
 				      MDIO_PMA_REG_LASI_STATUS, &val2);
@@ -4597,9 +4632,17 @@ static u8 bnx2x_ext_phy_is_link_up(struct bnx2x_phy *phy,
 					  val2,
 					 (val2 & (1<<14)));
 			}
-			break;
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
+			return ext_phy_link_up;
+}
+
+static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
+				       struct link_params *params,
+				       struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u16 val1, val2;
+	u8 ext_phy_link_up = 0;
+
 			/* Check 10G-BaseT link status */
 			/* Check PMD signal ok */
 			bnx2x_cl45_read(bp, phy,
@@ -4661,26 +4704,9 @@ static u8 bnx2x_ext_phy_is_link_up(struct bnx2x_phy *phy,
 						(vars->duplex == DUPLEX_FULL));
 				}
 			}
-			break;
-		default:
-			DP(NETIF_MSG_LINK,
-				 "BAD SerDes ext_phy_config 0x%x\n",
-				 phy->type);
-			ext_phy_link_up = 0;
-			break;
-		}
-	}
-
-		/* Set SGMII mode for external phy */
-		if (phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) {
-			if (vars->line_speed < SPEED_1000)
-				vars->phy_flags |= PHY_SGMII_FLAG;
-			else
-				vars->phy_flags &= ~PHY_SGMII_FLAG;
-		}
-
-	return ext_phy_link_up;
+			return ext_phy_link_up;
 }
+
 static void bnx2x_link_int_enable(struct link_params *params)
 {
 	u8 port = params->port;
@@ -4825,13 +4851,26 @@ static void bnx2x_link_int_ack(struct link_params *params,
 	}
 }
 
-static u8 bnx2x_format_ver(u32 num, u8 *str, u16 len)
+static u8 bnx2x_7101_format_ver(u32 spirom_ver, u8 *str, u16 *len)
+{
+	if (*len < 5)
+		return -EINVAL;
+	str[0] = (spirom_ver & 0xFF);
+	str[1] = (spirom_ver & 0xFF00) >> 8;
+	str[2] = (spirom_ver & 0xFF0000) >> 16;
+	str[3] = (spirom_ver & 0xFF000000) >> 24;
+	str[4] = '\0';
+	*len -= 5;
+	return 0;
+}
+
+static u8 bnx2x_format_ver(u32 num, u8 *str, u16 *len)
 {
 	u8 *str_ptr = str;
 	u32 mask = 0xf0000000;
 	u8 shift = 8*4;
 	u8 digit;
-	if (len < 10) {
+	if (*len < 10) {
 		/* Need more than 10chars for this format */
 		*str_ptr = '\0';
 		return -EINVAL;
@@ -4855,65 +4894,41 @@ static u8 bnx2x_format_ver(u32 num, u8 *str, u16 len)
 	return 0;
 }
 
+static u8 bnx2x_848xx_format_ver(u32 raw_ver, u8 *str, u16 *len)
+{
+	u8 status = 0;
+	u32 spirom_ver;
+	spirom_ver = ((raw_ver & 0xF80) >> 7) << 16 | (raw_ver & 0x7F);
+	status = bnx2x_format_ver(spirom_ver, str, len);
+	return status;
+}
+
+static u8 bnx2x_null_format_ver(u32 spirom_ver, u8 *str, u16 *len)
+{
+	str[0] = '\0';
+	(*len)--;
+	return 0;
+}
+
 u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 			      u8 *version, u16 len)
 {
 	struct bnx2x *bp;
-	u32 ext_phy_type = 0;
 	u32 spirom_ver = 0;
-	u8 status;
-
+	u8 status = 0;
+	u8 *ver_p = version;
 	if (version == NULL || params == NULL)
 		return -EINVAL;
 	bp = params->bp;
 
-	spirom_ver = REG_RD(bp, params->shmem_base +
-		   offsetof(struct shmem_region,
-			    port_mb[params->port].ext_phy_fw_version));
-
-	status = 0;
-	/* reset the returned value to zero */
-	ext_phy_type = params->phy[EXT_PHY1].type;
-	switch (ext_phy_type) {
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-
-		if (len < 5)
-			return -EINVAL;
-
-		version[0] = (spirom_ver & 0xFF);
-		version[1] = (spirom_ver & 0xFF00) >> 8;
-		version[2] = (spirom_ver & 0xFF0000) >> 16;
-		version[3] = (spirom_ver & 0xFF000000) >> 24;
-		version[4] = '\0';
+	/* Extract first external phy*/
+	version[0] = '\0';
+	spirom_ver = REG_RD(bp, params->phy[EXT_PHY1].ver_addr);
 
-		break;
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-		status = bnx2x_format_ver(spirom_ver, version, len);
-		break;
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
-		spirom_ver = ((spirom_ver & 0xF80) >> 7) << 16 |
-			(spirom_ver & 0x7F);
-		status = bnx2x_format_ver(spirom_ver, version, len);
-		break;
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
-		version[0] = '\0';
-		break;
-
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
-		DP(NETIF_MSG_LINK, "bnx2x_get_ext_phy_fw_version:"
-				    " type is FAILURE!\n");
-		status = -EINVAL;
-		break;
-
-	default:
-		break;
-	}
+	if (params->phy[EXT_PHY1].format_fw_ver)
+		status |= params->phy[EXT_PHY1].format_fw_ver(spirom_ver,
+							      ver_p,
+							      &len);
 	return status;
 }
 
@@ -4969,47 +4984,21 @@ static void bnx2x_set_xgxs_loopback(struct bnx2x_phy *phy,
 	}
 }
 
-static void bnx2x_ext_phy_loopback(struct bnx2x_phy *phy,
-				   struct link_params *params)
+static void bnx2x_8726_config_loopback(struct bnx2x_phy *phy,
+				       struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
+	DP(NETIF_MSG_LINK, "PMA/PMD ext_phy_loopback: 8726\n");
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x0001);
+}
 
-	if (params->switch_cfg == SWITCH_CFG_10G) {
-
-		/* CL37 Autoneg Enabled */
-		switch (phy->type) {
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN:
-			DP(NETIF_MSG_LINK,
-				"ext_phy_loopback: We should not get here\n");
-			break;
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
-			DP(NETIF_MSG_LINK, "ext_phy_loopback: 8705\n");
-			break;
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-			DP(NETIF_MSG_LINK, "ext_phy_loopback: 8706\n");
-			break;
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-			DP(NETIF_MSG_LINK, "PMA/PMD ext_phy_loopback: 8726\n");
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_CTRL,
-				       0x0001);
-			break;
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-			/* SFX7101_XGXS_TEST1 */
-			bnx2x_cl45_write(bp, phy,
-				       MDIO_XS_DEVAD,
-				       MDIO_XS_SFX7101_XGXS_TEST1,
-				       0x100);
-			DP(NETIF_MSG_LINK,
-				"ext_phy_loopback: set ext phy loopback\n");
-			break;
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-
-			break;
-		} /* switch external PHY type */
-	}
+static void bnx2x_7101_config_loopback(struct bnx2x_phy *phy,
+				       struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	/* SFX7101_XGXS_TEST1 */
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_XS_DEVAD, MDIO_XS_SFX7101_XGXS_TEST1, 0x100);
 }
 /*
  *------------------------------------------------------------------------
@@ -5204,9 +5193,17 @@ u8 bnx2x_test_link(struct link_params *params, struct link_vars *vars)
 			      MDIO_GP_STATUS_TOP_AN_STATUS1,
 			      &gp_status);
 	/* link is up only if both local phy and external phy are up */
-	if ((gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) &&
-	    bnx2x_ext_phy_is_link_up(&params->phy[EXT_PHY1], params, vars, 1))
-		return 0;
+	if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) {
+		u8 ext_phy_link_up = 1;
+		struct link_vars temp_vars;
+		if (params->phy[EXT_PHY1].read_status)
+			ext_phy_link_up &=
+				params->phy[EXT_PHY1].read_status(
+						&params->phy[EXT_PHY1],
+						params, &temp_vars);
+		if (ext_phy_link_up)
+			return 0;
+	}
 
 	return -ESRCH;
 }
@@ -5217,11 +5214,10 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
 	u8 rc = 0;
-	u8 non_ext_phy;
+	u8 phy_index, non_ext_phy;
 	struct bnx2x_phy *ext_phy = &params->phy[EXT_PHY1];
 	struct bnx2x_phy *int_phy = &params->phy[INT_PHY];
 	/* Activate the external PHY */
-	bnx2x_ext_phy_reset(ext_phy, params, vars);
 
 	bnx2x_set_aer_mmd(params, int_phy);
 
@@ -5282,7 +5278,12 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	}
 
 	if (!non_ext_phy)
-		rc |= bnx2x_ext_phy_init(params, vars);
+		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
+		      phy_index++) {
+			params->phy[phy_index].config_init(
+				&params->phy[phy_index],
+				params, vars);
+		}
 
 	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
 		     (NIG_STATUS_XGXS0_LINK10G |
@@ -5292,6 +5293,35 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	return rc;
 }
 
+static void set_phy_vars(struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	u8 actual_phy_idx, phy_index;
+
+	for (phy_index = INT_PHY; phy_index < params->num_phys;
+	      phy_index++) {
+
+		actual_phy_idx = phy_index;
+		params->phy[actual_phy_idx].req_flow_ctrl  =
+			params->req_flow_ctrl;
+
+		params->phy[actual_phy_idx].req_line_speed =
+			params->req_line_speed;
+
+		params->phy[actual_phy_idx].speed_cap_mask =
+			params->speed_cap_mask;
+
+		params->phy[actual_phy_idx].req_duplex =
+			params->req_duplex;
+
+		DP(NETIF_MSG_LINK, "req_flow_ctrl %x, req_line_speed %x,"
+			   " speed_cap_mask %x\n",
+			   params->phy[actual_phy_idx].req_flow_ctrl,
+			   params->phy[actual_phy_idx].req_line_speed,
+			   params->phy[actual_phy_idx].speed_cap_mask);
+	}
+}
+
 u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
@@ -5307,29 +5337,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	vars->duplex = DUPLEX_FULL;
 	vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
 	vars->mac_type = MAC_TYPE_NONE;
-
-	if (params->switch_cfg ==  SWITCH_CFG_1G) {
-		params->phy[INT_PHY].type =
-				PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT;
-		vars->phy_flags = PHY_SERDES_FLAG;
-	} else {
-		params->phy[INT_PHY].type =
-				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT;
-		vars->phy_flags = PHY_XGXS_FLAG;
-	}
-	params->phy[INT_PHY].mdio_ctrl =
-		bnx2x_get_emac_base(bp,
-				    params->phy[INT_PHY].type, params->port);
-	if (XGXS_EXT_PHY_TYPE(params->ext_phy_config) !=
-	     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) {
-		params->phy[EXT_PHY1].type =
-			XGXS_EXT_PHY_TYPE(params->ext_phy_config);
-		params->phy[EXT_PHY1].addr =
-			XGXS_EXT_PHY_ADDR(params->ext_phy_config);
-		params->phy[EXT_PHY1].mdio_ctrl =
-			bnx2x_get_emac_base(bp, params->phy[EXT_PHY1].type,
-					    params->port);
-	}
+	vars->phy_flags = 0;
 
 	/* disable attentions */
 	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + params->port*4,
@@ -5340,6 +5348,13 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 
 	bnx2x_emac_init(params, vars);
 
+	if (params->num_phys == 0) {
+		DP(NETIF_MSG_LINK, "No phy found for initialization !!\n");
+		return -EINVAL;
+	}
+	set_phy_vars(params);
+
+	DP(NETIF_MSG_LINK, "Num of phys on board: %d\n", params->num_phys);
 	if (CHIP_REV_IS_FPGA(bp)) {
 
 		vars->link_up = 1;
@@ -5420,8 +5435,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		bnx2x_phy_deassert(params, vars->phy_flags);
 		/* set bmac loopback */
 		bnx2x_emac_enable(params, vars, 1);
-		bnx2x_emac_program(params, vars->line_speed,
-					      vars->duplex);
+		bnx2x_emac_program(params, vars);
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
 		    params->port*4, 0);
 
@@ -5438,8 +5452,7 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		val = REG_RD(bp,
 				 NIG_REG_XGXS0_CTRL_PHY_ADDR+
 				 params->port*0x18);
-		params->phy_addr = (u8)val;
-		params->phy[INT_PHY].addr = (u8)val;
+
 		bnx2x_phy_deassert(params, vars->phy_flags);
 		bnx2x_link_initialize(params, vars);
 
@@ -5449,12 +5462,20 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 
 		if (params->loopback_mode == LOOPBACK_XGXS_10) {
 			/* set 10G XGXS loopback */
-			bnx2x_set_xgxs_loopback(&params->phy[INT_PHY],
-						params, 1);
+			params->phy[INT_PHY].config_loopback(
+				&params->phy[INT_PHY],
+				params);
+
 		} else {
 			/* set external phy loopback */
-			bnx2x_ext_phy_loopback(&params->phy[INT_PHY],
+			u8 phy_index;
+			for (phy_index = EXT_PHY1;
+			      phy_index < params->num_phys; phy_index++) {
+				if (params->phy[phy_index].config_loopback)
+					params->phy[phy_index].config_loopback(
+						&params->phy[phy_index],
 					       params);
+			}
 		}
 
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
@@ -5464,37 +5485,9 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	} else
 	/* No loopback */
 	{
+		if (params->switch_cfg == SWITCH_CFG_10G)
+			vars->phy_flags = PHY_XGXS_FLAG;
 		bnx2x_phy_deassert(params, vars->phy_flags);
-		switch (params->switch_cfg) {
-		case SWITCH_CFG_1G:
-			vars->phy_flags |= PHY_SERDES_FLAG;
-			if ((params->ext_phy_config &
-			     PORT_HW_CFG_SERDES_EXT_PHY_TYPE_MASK) ==
-			     PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482) {
-				vars->phy_flags |= PHY_SGMII_FLAG;
-			}
-
-			val = REG_RD(bp,
-					 NIG_REG_SERDES0_CTRL_PHY_ADDR+
-					 params->port*0x10);
-
-			params->phy_addr = (u8)val;
-
-			break;
-		case SWITCH_CFG_10G:
-			vars->phy_flags |= PHY_XGXS_FLAG;
-			val = REG_RD(bp,
-				 NIG_REG_XGXS0_CTRL_PHY_ADDR+
-				 params->port*0x18);
-			params->phy_addr = (u8)val;
-
-			break;
-		default:
-			DP(NETIF_MSG_LINK, "Invalid switch_cfg\n");
-			return -EINVAL;
-		}
-		DP(NETIF_MSG_LINK, "Phy address = 0x%x\n", params->phy_addr);
-		params->phy[INT_PHY].addr = params->phy_addr;
 		bnx2x_link_initialize(params, vars);
 		msleep(30);
 		bnx2x_link_int_enable(params);
@@ -5503,14 +5496,78 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 }
 

-static void bnx2x_8726_reset_phy(struct bnx2x *bp,
-				 struct bnx2x_phy *phy)
+static void bnx2x_8726_link_reset(struct bnx2x_phy *phy,
+				  struct link_params *params)
 {
-	DP(NETIF_MSG_LINK, "bnx2x_8726_reset_phy\n");
+	struct bnx2x *bp = params->bp;
+	DP(NETIF_MSG_LINK, "bnx2x_8726_link_reset port %d\n", params->port);
 	/* Set serial boot control for external load */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL, 0x0001);
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_GEN_CTRL, 0x0001);
+}
+
+static void bnx2x_8727_link_reset(struct bnx2x_phy *phy,
+				  struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	/* Disable Transmitter */
+	bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
+}
+static void bnx2x_8073_link_reset(struct bnx2x_phy *phy,
+				  struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	u8 gpio_port;
+	gpio_port = params->port;
+	DP(NETIF_MSG_LINK, "Setting 8073 port %d into low power mode\n",
+	   gpio_port);
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
+			    gpio_port);
+}
+static void bnx2x_8481_link_reset(struct bnx2x_phy *phy,
+					struct link_params *params)
+{
+	bnx2x_cl45_write(params->bp, phy,
+			 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0x0000);
+	bnx2x_cl45_write(params->bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 1);
+}
+
+static void bnx2x_848x3_link_reset(struct bnx2x_phy *phy,
+				   struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	u8 port = params->port;
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
+			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
+			    port);
+}
+
+static void bnx2x_common_ext_link_reset(struct bnx2x_phy *phy,
+					struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	u8 gpio_port;
+	/* HW reset */
+	gpio_port = params->port;
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
+			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
+			    gpio_port);
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
+			    gpio_port);
+	DP(NETIF_MSG_LINK, "reset external PHY\n");
+}
+
+static void bnx2x_int_link_reset(struct bnx2x_phy *phy,
+				 struct link_params *params)
+{
+	/* reset the SerDes/XGXS */
+	REG_WR(params->bp, GRCBASE_MISC +
+		     MISC_REGISTERS_RESET_REG_3_CLEAR,
+		     (0x1ff << (params->port*16)));
 }
 
 u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
@@ -5518,12 +5575,8 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 {
 	struct bnx2x *bp = params->bp;
 
-	u8 port = params->port;
+	u8 phy_index, port = params->port;
 
-	u32 val = REG_RD(bp, params->shmem_base +
-			     offsetof(struct shmem_region, dev_info.
-				      port_feature_config[params->port].
-				      config));
 	DP(NETIF_MSG_LINK, "Resetting the link of port %d\n", port);
 	/* disable attentions */
 	vars->link_status = 0;
@@ -5554,57 +5607,18 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	 /* clear link led */
 	bnx2x_set_led(params, LED_MODE_OFF, 0);
 	if (reset_ext_phy) {
-		struct bnx2x_phy *phy = &params->phy[EXT_PHY1];
-		switch (phy->type) {
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
-		{
-
-			/* Disable Transmitter */
-			if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
-			    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
-				bnx2x_sfp_set_transmitter(bp, phy, 0);
-			break;
-		}
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-			DP(NETIF_MSG_LINK, "Setting 8073 port %d into "
-				 "low power mode\n",
-				 port);
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-					  MISC_REGISTERS_GPIO_OUTPUT_LOW,
-					  port);
-			break;
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-		{
-			/* Set soft reset */
-			bnx2x_8726_reset_phy(bp, phy);
-			break;
-		}
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
-		{
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
-				       MISC_REGISTERS_GPIO_OUTPUT_LOW,
-				       params->port);
-			break;
-		}
-		default:
-			/* HW reset */
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-					  MISC_REGISTERS_GPIO_OUTPUT_LOW,
-					  port);
-			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-					  MISC_REGISTERS_GPIO_OUTPUT_LOW,
-					  port);
-			DP(NETIF_MSG_LINK, "reset external PHY\n");
+		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
+		      phy_index++) {
+			if (params->phy[phy_index].link_reset)
+				params->phy[phy_index].link_reset(
+					&params->phy[phy_index],
+					params);
 		}
 	}
-	/* reset the SerDes/XGXS */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR,
-	       (0x1ff << (port*16)));
 
+	if (params->phy[INT_PHY].link_reset)
+		params->phy[INT_PHY].link_reset(
+			&params->phy[INT_PHY], params);
 	/* reset BigMac */
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
 	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
@@ -5654,7 +5668,7 @@ static u8 bnx2x_update_link_down(struct link_params *params,
 
 static u8 bnx2x_update_link_up(struct link_params *params,
 			     struct link_vars *vars,
-			     u8 link_10g, u32 gp_status)
+			     u8 link_10g)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
@@ -5665,8 +5679,7 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 		bnx2x_bmac_enable(params, vars, 0);
 		bnx2x_set_led(params, LED_MODE_OPER, SPEED_10000);
 	} else {
-		rc = bnx2x_emac_program(params, vars->line_speed,
-				      vars->duplex);
+		rc = bnx2x_emac_program(params, vars);
 
 		bnx2x_emac_enable(params, vars, 0);
 
@@ -5689,28 +5702,39 @@ static u8 bnx2x_update_link_up(struct link_params *params,
 	msleep(20);
 	return rc;
 }
-/* This function should called upon link interrupt */
-/* In case vars->link_up, driver needs to
-	1. Update the pbf
-	2. Disable drain
-	3. Update the shared memory
-	4. Indicate link up
-	5. Set LEDs
-   Otherwise,
-	1. Update shared memory
-	2. Reset BigMac
-	3. Report link down
-	4. Unset LEDs
+/**
+ * The bnx2x_link_update function should be called upon link
+ * interrupt.
+ * Link is considered up as follows:
+ * - DIRECT_SINGLE_MEDIA - Only XGXS link (internal link) needs
+ *   to be up
+ * - SINGLE_MEDIA - The link between the 577xx and the external
+ *   phy (XGXS) need to up as well as the external link of the
+ *   phy (PHY_EXT1)
+ * - DUAL_MEDIA - The link between the 577xx and the first
+ *   external phy needs to be up, and at least one of the 2
+ *   external phy link must be up.
 */
 u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
+	struct link_vars phy_vars[MAX_PHYS];
 	u8 port = params->port;
-	u16 gp_status;
-	u8 link_10g;
-	u8 ext_phy_link_up, rc = 0;
-	struct bnx2x_phy *int_phy = &params->phy[INT_PHY];
+	u8 link_10g, phy_index;
+	u8 ext_phy_link_up = 0, cur_link_up, rc = 0;
 	u8 is_mi_int = 0;
+	u16 ext_phy_line_speed = 0, prev_line_speed = vars->line_speed;
+	u8 active_external_phy = INT_PHY;
+	vars->link_status = 0;
+	for (phy_index = INT_PHY; phy_index < params->num_phys;
+	      phy_index++) {
+		phy_vars[phy_index].flow_ctrl = 0;
+		phy_vars[phy_index].link_status = 0;
+		phy_vars[phy_index].line_speed = 0;
+		phy_vars[phy_index].duplex = DUPLEX_FULL;
+		phy_vars[phy_index].phy_link_up = 0;
+		phy_vars[phy_index].link_up = 0;
+	}
 
 	DP(NETIF_MSG_LINK, "port %x, XGXS?%x, int_status 0x%x\n",
 		 port, (vars->phy_flags & PHY_XGXS_FLAG),
@@ -5731,21 +5755,94 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	/* disable emac */
 	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
 
-	/* Check external link change only for non-direct */
-	ext_phy_link_up = bnx2x_ext_phy_is_link_up(&params->phy[EXT_PHY1],
-						   params, vars,
-						   is_mi_int);
+	/**
+	* Step 1:
+	* Check external link change only for external phys, and apply
+	* priority selection between them in case the link on both phys
+	* is up. Note that the instead of the common vars, a temporary
+	* vars argument is used since each phy may have different link/
+	* speed/duplex result
+	*/
+	for (phy_index = EXT_PHY1; phy_index < params->num_phys;
+	      phy_index++) {
+		struct bnx2x_phy *phy = &params->phy[phy_index];
+		if (!phy->read_status)
+			continue;
+		/* Read link status and params of this ext phy */
+		cur_link_up = phy->read_status(phy, params,
+					       &phy_vars[phy_index]);
+		if (cur_link_up) {
+			DP(NETIF_MSG_LINK, "phy in index %d link is up\n",
+				   phy_index);
+		} else {
+			DP(NETIF_MSG_LINK, "phy in index %d link is down\n",
+				   phy_index);
+			continue;
+		}
 
-	/* Read gp_status */
-	CL45_RD_OVER_CL22(bp, int_phy,
-			      MDIO_REG_BANK_GP_STATUS,
-			      MDIO_GP_STATUS_TOP_AN_STATUS1,
-			      &gp_status);
+		if (!ext_phy_link_up) {
+			ext_phy_link_up = 1;
+			active_external_phy = phy_index;
+		}
+	}
+	prev_line_speed = vars->line_speed;
+	/**
+	* Step 2:
+	* Read the status of the internal phy. In case of
+	* DIRECT_SINGLE_MEDIA board, this link is the external link,
+	* otherwise this is the link between the 577xx and the first
+	* external phy
+	*/
+	if (params->phy[INT_PHY].read_status)
+		params->phy[INT_PHY].read_status(
+			&params->phy[INT_PHY],
+			params, vars);
+	/**
+	 * The INT_PHY flow control reside in the vars. This include the
+	 * case where the speed or flow control are not set to AUTO.
+	 * Otherwise, the active external phy flow control result is set
+	 * to the vars. The ext_phy_line_speed is needed to check if the
+	 * speed is different between the internal phy and external phy.
+	 * This case may be result of intermediate link speed change.
+	 */
+	if (active_external_phy > INT_PHY) {
+		vars->flow_ctrl = phy_vars[active_external_phy].flow_ctrl;
+		/**
+		 * Link speed is taken from the XGXS. AN and FC result from
+		 * the external phy.
+		 */
+		vars->link_status |= phy_vars[active_external_phy].link_status;
+		ext_phy_line_speed = phy_vars[active_external_phy].line_speed;
+		vars->duplex = phy_vars[active_external_phy].duplex;
+		if (params->phy[active_external_phy].supported &
+		    SUPPORTED_FIBRE)
+			vars->link_status |= LINK_STATUS_SERDES_LINK;
+		DP(NETIF_MSG_LINK, "Active external phy selected: %x\n",
+			   active_external_phy);
+	}
+	DP(NETIF_MSG_LINK, "vars->flow_ctrl = 0x%x, vars->link_status = 0x%x,"
+		   " ext_phy_line_speed = %d\n", vars->flow_ctrl,
+		   vars->link_status, ext_phy_line_speed);
+	/**
+	 * Upon link speed change set the NIG into drain mode. Comes to
+	 * deals with possible FIFO glitch due to clk change when speed
+	 * is decreased without link down indicator
+	 */
 
-	rc = bnx2x_link_settings_status(params, vars, gp_status,
-				      ext_phy_link_up);
-	if (rc != 0)
-		return rc;
+	if (vars->phy_link_up) {
+		if (!(SINGLE_MEDIA_DIRECT(params)) && ext_phy_link_up &&
+		    (ext_phy_line_speed != vars->line_speed)) {
+			DP(NETIF_MSG_LINK, "Internal link speed %d is"
+				   " different than the external"
+				   " link speed %d\n", vars->line_speed,
+				   ext_phy_line_speed);
+			vars->phy_link_up = 0;
+		} else if (prev_line_speed != vars->line_speed) {
+			REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE
+				     + params->port*4, 0);
+			msleep(1);
+		}
+	}
 
 	/* anything 10 and over uses the bmac */
 	link_10g = ((vars->line_speed == SPEED_10000) ||
@@ -5757,31 +5854,469 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 
 	bnx2x_link_int_ack(params, vars, link_10g, is_mi_int);
 
-	/* In case external phy link is up, and internal link is down
-	( not initialized yet probably after link initialization, it needs
-	to be initialized.
-	Note that after link down-up as result of cable plug,
-	the xgxs link would probably become up again without the need to
-	initialize it*/
-
-	if ((int_phy->type != PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT) &&
-	    (int_phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) &&
-	    (int_phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706) &&
-	    (int_phy->type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726) &&
-	    (int_phy->type && !vars->phy_link_up))
-		bnx2x_init_internal_phy(int_phy, params, vars);
-
-	/* link is up only if both local phy and external phy are up */
-	vars->link_up = (ext_phy_link_up && vars->phy_link_up);
+	/**
+	* In case external phy link is up, and internal link is down
+	* (not initialized yet probably after link initialization, it
+	* needs to be initialized.
+	* Note that after link down-up as result of cable plug, the xgxs
+	* link would probably become up again without the need
+	* initialize it
+	*/
+	if (!(SINGLE_MEDIA_DIRECT(params))) {
+		DP(NETIF_MSG_LINK, "ext_phy_link_up = %d, int_link_up = %d,"
+			   " init_preceding = %d\n", ext_phy_link_up,
+			   vars->phy_link_up,
+			   params->phy[EXT_PHY1].flags &
+			   FLAGS_INIT_XGXS_FIRST);
+		if (!(params->phy[EXT_PHY1].flags &
+		      FLAGS_INIT_XGXS_FIRST)
+		    && ext_phy_link_up && !vars->phy_link_up) {
+			vars->line_speed = ext_phy_line_speed;
+			if (vars->line_speed < SPEED_1000)
+				vars->phy_flags |= PHY_SGMII_FLAG;
+			else
+				vars->phy_flags &= ~PHY_SGMII_FLAG;
+			bnx2x_init_internal_phy(&params->phy[INT_PHY],
+						params,
+						vars);
+		}
+	}
+	/**
+	 *  Link is up only if both local phy and external phy (in case of
+	 *  non-direct board) are up
+	 */
+	vars->link_up = (vars->phy_link_up &&
+			 (ext_phy_link_up ||
+			  SINGLE_MEDIA_DIRECT(params)));
 
 	if (vars->link_up)
-		rc = bnx2x_update_link_up(params, vars, link_10g, gp_status);
+		rc = bnx2x_update_link_up(params, vars, link_10g);
 	else
 		rc = bnx2x_update_link_down(params, vars);
 
 	return rc;
 }
 
+static void bnx2x_8481_hw_reset(struct bnx2x_phy *phy,
+				struct link_params *params)
+{
+	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_1,
+			    MISC_REGISTERS_GPIO_OUTPUT_LOW, 0);
+	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_1,
+			    MISC_REGISTERS_GPIO_OUTPUT_LOW, 1);
+}
+
+static void bnx2x_8727_hw_reset(struct bnx2x_phy *phy,
+				struct link_params *params) {
+	u32 swap_val, swap_override;
+	u8 port;
+	/**
+	 * The PHY reset is controlled by GPIO 1. Fake the port number
+	 * to cancel the swap done in set_gpio()
+	 */
+	struct bnx2x *bp = params->bp;
+	swap_val = REG_RD(bp, NIG_REG_PORT_SWAP);
+	swap_override = REG_RD(bp, NIG_REG_STRAP_OVERRIDE);
+	port = (swap_val && swap_override) ^ 1;
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
+			    MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
+}
+
+static void bnx2x_7101_hw_reset(struct bnx2x_phy *phy,
+				struct link_params *params) {
+	/* Low power mode is controlled by GPIO 2 */
+	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_2,
+			    MISC_REGISTERS_GPIO_OUTPUT_LOW, params->port);
+	/* The PHY reset is controlled by GPIO 1 */
+	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_1,
+			    MISC_REGISTERS_GPIO_OUTPUT_LOW, params->port);
+}
+/******************************************************************/
+/*			STATIC PHY DECLARATION			  */
+/******************************************************************/
+
+static struct bnx2x_phy phy_null = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN,
+	.addr		= 0,
+	.flags		= FLAGS_INIT_XGXS_FIRST,
+	.def_md_devad	= 0,
+	.reserved	= 0,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= 0,
+	.media_type	= ETH_PHY_NOT_PRESENT,
+	.ver_addr	= 0,
+	.req_flow_ctrl  = 0,
+	.req_line_speed = 0,
+	.speed_cap_mask = 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)NULL,
+	.read_status	= (read_status_t)NULL,
+	.link_reset	= (link_reset_t)NULL,
+	.config_loopback = (config_loopback_t)NULL,
+	.format_fw_ver	= (format_fw_ver_t)NULL,
+	.hw_reset	= (hw_reset_t)NULL,
+	.set_link_led	= (set_link_led_t)NULL
+};
+
+static struct bnx2x_phy phy_serdes = {
+	.type		= PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT,
+	.addr		= 0xff,
+	.flags		= 0,
+	.def_md_devad	= 0,
+	.reserved	= 0,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= (SUPPORTED_10baseT_Half |
+			   SUPPORTED_10baseT_Full |
+			   SUPPORTED_100baseT_Half |
+			   SUPPORTED_100baseT_Full |
+			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_2500baseX_Full |
+			   SUPPORTED_TP |
+			   SUPPORTED_Autoneg |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.media_type	= ETH_PHY_UNSPECIFIED,
+	.ver_addr	= 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed = 0,
+	.speed_cap_mask = 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)bnx2x_init_serdes,
+	.read_status	= (read_status_t)bnx2x_link_settings_status,
+	.link_reset	= (link_reset_t)bnx2x_int_link_reset,
+	.config_loopback = (config_loopback_t)NULL,
+	.format_fw_ver	= (format_fw_ver_t)NULL,
+	.hw_reset	= (hw_reset_t)NULL,
+	.set_link_led	= (set_link_led_t)NULL
+};
+
+static struct bnx2x_phy phy_xgxs = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT,
+	.addr		= 0xff,
+	.flags		= 0,
+	.def_md_devad	= 0,
+	.reserved	= 0,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= (SUPPORTED_10baseT_Half |
+			   SUPPORTED_10baseT_Full |
+			   SUPPORTED_100baseT_Half |
+			   SUPPORTED_100baseT_Full |
+			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_2500baseX_Full |
+			   SUPPORTED_10000baseT_Full |
+			   SUPPORTED_FIBRE |
+			   SUPPORTED_Autoneg |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.media_type	= ETH_PHY_UNSPECIFIED,
+	.ver_addr	= 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed = 0,
+	.speed_cap_mask = 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)bnx2x_init_xgxs,
+	.read_status	= (read_status_t)bnx2x_link_settings_status,
+	.link_reset	= (link_reset_t)bnx2x_int_link_reset,
+	.config_loopback = (config_loopback_t)bnx2x_set_xgxs_loopback,
+	.format_fw_ver	= (format_fw_ver_t)NULL,
+	.hw_reset	= (hw_reset_t)NULL,
+	.set_link_led	= (set_link_led_t)NULL
+};
+
+static struct bnx2x_phy phy_7101 = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101,
+	.addr		= 0xff,
+	.flags		= FLAGS_FAN_FAILURE_DET_REQ,
+	.def_md_devad	= 0,
+	.reserved	= 0,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= (SUPPORTED_10000baseT_Full |
+			   SUPPORTED_TP |
+			   SUPPORTED_Autoneg |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.media_type	= ETH_PHY_BASE_T,
+	.ver_addr	= 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed = 0,
+	.speed_cap_mask = 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)bnx2x_7101_config_init,
+	.read_status	= (read_status_t)bnx2x_7101_read_status,
+	.link_reset	= (link_reset_t)bnx2x_common_ext_link_reset,
+	.config_loopback = (config_loopback_t)bnx2x_7101_config_loopback,
+	.format_fw_ver	= (format_fw_ver_t)bnx2x_7101_format_ver,
+	.hw_reset	= (hw_reset_t)bnx2x_7101_hw_reset,
+	.set_link_led	= (set_link_led_t)NULL
+};
+static struct bnx2x_phy phy_8073 = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
+	.addr		= 0xff,
+	.flags		= FLAGS_HW_LOCK_REQUIRED,
+	.def_md_devad	= 0,
+	.reserved	= 0,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= (SUPPORTED_10000baseT_Full |
+			   SUPPORTED_2500baseX_Full |
+			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_FIBRE |
+			   SUPPORTED_Autoneg |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.media_type	= ETH_PHY_UNSPECIFIED,
+	.ver_addr	= 0,
+	.req_flow_ctrl  = 0,
+	.req_line_speed = 0,
+	.speed_cap_mask = 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)bnx2x_8072_8073_config_init,
+	.read_status	= (read_status_t)bnx2x_8073_read_status,
+	.link_reset	= (link_reset_t)bnx2x_8073_link_reset,
+	.config_loopback = (config_loopback_t)NULL,
+	.format_fw_ver	= (format_fw_ver_t)bnx2x_format_ver,
+	.hw_reset	= (hw_reset_t)NULL,
+	.set_link_led	= (set_link_led_t)NULL
+};
+static struct bnx2x_phy phy_8705 = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705,
+	.addr		= 0xff,
+	.flags		= FLAGS_INIT_XGXS_FIRST,
+	.def_md_devad	= 0,
+	.reserved	= 0,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= (SUPPORTED_10000baseT_Full |
+			   SUPPORTED_FIBRE |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.media_type	= ETH_PHY_XFP_FIBER,
+	.ver_addr	= 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)bnx2x_8705_config_init,
+	.read_status	= (read_status_t)bnx2x_8705_read_status,
+	.link_reset	= (link_reset_t)bnx2x_common_ext_link_reset,
+	.config_loopback = (config_loopback_t)NULL,
+	.format_fw_ver	= (format_fw_ver_t)bnx2x_null_format_ver,
+	.hw_reset	= (hw_reset_t)NULL,
+	.set_link_led	= (set_link_led_t)NULL
+};
+static struct bnx2x_phy phy_8706 = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706,
+	.addr		= 0xff,
+	.flags		= FLAGS_INIT_XGXS_FIRST,
+	.def_md_devad	= 0,
+	.reserved	= 0,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= (SUPPORTED_10000baseT_Full |
+			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_FIBRE |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.media_type	= ETH_PHY_SFP_FIBER,
+	.ver_addr	= 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)bnx2x_8706_config_init,
+	.read_status	= (read_status_t)bnx2x_8706_read_status,
+	.link_reset	= (link_reset_t)bnx2x_common_ext_link_reset,
+	.config_loopback = (config_loopback_t)NULL,
+	.format_fw_ver	= (format_fw_ver_t)bnx2x_format_ver,
+	.hw_reset	= (hw_reset_t)NULL,
+	.set_link_led	= (set_link_led_t)NULL
+};
+
+static struct bnx2x_phy phy_8726 = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726,
+	.addr		= 0xff,
+	.flags		= (FLAGS_HW_LOCK_REQUIRED |
+			   FLAGS_INIT_XGXS_FIRST),
+	.def_md_devad	= 0,
+	.reserved	= 0,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= (SUPPORTED_10000baseT_Full |
+			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_Autoneg |
+			   SUPPORTED_FIBRE |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.media_type	= ETH_PHY_SFP_FIBER,
+	.ver_addr	= 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)bnx2x_8726_config_init,
+	.read_status	= (read_status_t)bnx2x_8726_read_status,
+	.link_reset	= (link_reset_t)bnx2x_8726_link_reset,
+	.config_loopback = (config_loopback_t)bnx2x_8726_config_loopback,
+	.format_fw_ver	= (format_fw_ver_t)bnx2x_format_ver,
+	.hw_reset	= (hw_reset_t)NULL,
+	.set_link_led	= (set_link_led_t)NULL
+};
+
+static struct bnx2x_phy phy_8727 = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
+	.addr		= 0xff,
+	.flags		= FLAGS_FAN_FAILURE_DET_REQ,
+	.def_md_devad	= 0,
+	.reserved	= 0,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= (SUPPORTED_10000baseT_Full |
+			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_Autoneg |
+			   SUPPORTED_FIBRE |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.media_type	= ETH_PHY_SFP_FIBER,
+	.ver_addr	= 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)bnx2x_8727_config_init,
+	.read_status	= (read_status_t)bnx2x_8727_read_status,
+	.link_reset	= (link_reset_t)bnx2x_8727_link_reset,
+	.config_loopback = (config_loopback_t)NULL,
+	.format_fw_ver	= (format_fw_ver_t)bnx2x_format_ver,
+	.hw_reset	= (hw_reset_t)bnx2x_8727_hw_reset,
+	.set_link_led	= (set_link_led_t)NULL
+};
+static struct bnx2x_phy phy_8481 = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
+	.addr		= 0xff,
+	.flags		= FLAGS_FAN_FAILURE_DET_REQ,
+	.def_md_devad	= 0,
+	.reserved	= 0,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= (SUPPORTED_10baseT_Half |
+			   SUPPORTED_10baseT_Full |
+			   SUPPORTED_100baseT_Half |
+			   SUPPORTED_100baseT_Full |
+			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_10000baseT_Full |
+			   SUPPORTED_TP |
+			   SUPPORTED_Autoneg |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.media_type	= ETH_PHY_BASE_T,
+	.ver_addr	= 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)bnx2x_8481_config_init,
+	.read_status	= (read_status_t)bnx2x_848xx_read_status,
+	.link_reset	= (link_reset_t)bnx2x_8481_link_reset,
+	.config_loopback = (config_loopback_t)NULL,
+	.format_fw_ver	= (format_fw_ver_t)bnx2x_848xx_format_ver,
+	.hw_reset	= (hw_reset_t)bnx2x_8481_hw_reset,
+	.set_link_led	= (set_link_led_t)NULL
+};
+
+static struct bnx2x_phy phy_84823 = {
+	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823,
+	.addr		= 0xff,
+	.flags		= FLAGS_FAN_FAILURE_DET_REQ,
+	.def_md_devad	= 0,
+	.reserved	= 0,
+	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
+	.mdio_ctrl	= 0,
+	.supported	= (SUPPORTED_10baseT_Half |
+			   SUPPORTED_10baseT_Full |
+			   SUPPORTED_100baseT_Half |
+			   SUPPORTED_100baseT_Full |
+			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_10000baseT_Full |
+			   SUPPORTED_TP |
+			   SUPPORTED_Autoneg |
+			   SUPPORTED_Pause |
+			   SUPPORTED_Asym_Pause),
+	.media_type	= ETH_PHY_BASE_T,
+	.ver_addr	= 0,
+	.req_flow_ctrl	= 0,
+	.req_line_speed	= 0,
+	.speed_cap_mask	= 0,
+	.req_duplex	= 0,
+	.rsrv		= 0,
+	.config_init	= (config_init_t)bnx2x_848x3_config_init,
+	.read_status	= (read_status_t)bnx2x_848xx_read_status,
+	.link_reset	= (link_reset_t)bnx2x_848x3_link_reset,
+	.config_loopback = (config_loopback_t)NULL,
+	.format_fw_ver	= (format_fw_ver_t)bnx2x_848xx_format_ver,
+	.hw_reset	= (hw_reset_t)NULL,
+	.set_link_led	= (set_link_led_t)NULL
+};
+
+/*****************************************************************/
+/*                                                               */
+/* Populate the phy according. Main function: bnx2x_populate_phy   */
+/*                                                               */
+/*****************************************************************/
+
+static void bnx2x_populate_preemphasis(struct bnx2x *bp, u32 shmem_base,
+				     struct bnx2x_phy *phy, u8 port,
+				     u8 phy_index)
+{
+	/* Get the 4 lanes xgxs config rx and tx */
+	u32 rx = 0, tx = 0, i;
+	for (i = 0; i < 2; i++) {
+		/**
+		 * INT_PHY and EXT_PHY1 share the same value location in the
+		 * shmem. When num_phys is greater than 1, than this value
+		 * applies only to EXT_PHY1
+		 */
+
+		rx = REG_RD(bp, shmem_base +
+				  offsetof(struct shmem_region,
+		  dev_info.port_hw_config[port].xgxs_config_rx[i<<1]));
+
+		tx = REG_RD(bp, shmem_base +
+				  offsetof(struct shmem_region,
+		  dev_info.port_hw_config[port].xgxs_config_tx[i<<1]));
+
+		phy->rx_preemphasis[i << 1] = ((rx>>16) & 0xffff);
+		phy->rx_preemphasis[(i << 1) + 1] = (rx & 0xffff);
+
+		phy->tx_preemphasis[i << 1] = ((tx>>16) & 0xffff);
+		phy->tx_preemphasis[(i << 1) + 1] = (tx & 0xffff);
+	}
+}
+
 static u32 bnx2x_get_ext_phy_config(struct bnx2x *bp, u32 shmem_base,
 				    u8 phy_index, u8 port)
 {
@@ -5799,6 +6334,45 @@ static u32 bnx2x_get_ext_phy_config(struct bnx2x *bp, u32 shmem_base,
 
 	return ext_phy_config;
 }
+static u8 bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
+				 struct bnx2x_phy *phy)
+{
+	u32 phy_addr;
+	u32 chip_id;
+	u32 switch_cfg = (REG_RD(bp, shmem_base +
+				       offsetof(struct shmem_region,
+			dev_info.port_feature_config[port].link_config)) &
+			  PORT_FEATURE_CONNECTED_SWITCH_MASK);
+	chip_id = REG_RD(bp, MISC_REG_CHIP_NUM) << 16;
+	switch (switch_cfg) {
+	case SWITCH_CFG_1G:
+		phy_addr = REG_RD(bp,
+					NIG_REG_SERDES0_CTRL_PHY_ADDR +
+					port * 0x10);
+		*phy = phy_serdes;
+		break;
+	case SWITCH_CFG_10G:
+		phy_addr = REG_RD(bp,
+					NIG_REG_XGXS0_CTRL_PHY_ADDR +
+					port * 0x18);
+		*phy = phy_xgxs;
+		break;
+	default:
+		DP(NETIF_MSG_LINK, "Invalid switch_cfg\n");
+		return -EINVAL;
+	}
+	phy->addr = (u8)phy_addr;
+	phy->mdio_ctrl = bnx2x_get_emac_base(bp,
+					    phy->type,
+					    port);
+	phy->def_md_devad = DEFAULT_PHY_DEV_ADDR;
+
+	DP(NETIF_MSG_LINK, "Internal phy port=%d, addr=0x%x, mdio_ctl=0x%x\n",
+		   port, phy->addr, phy->mdio_ctrl);
+
+	bnx2x_populate_preemphasis(bp, shmem_base, phy, port, INT_PHY);
+	return 0;
+}
 
 static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 				 u8 phy_index,
@@ -5806,12 +6380,52 @@ static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 				 u8 port,
 				 struct bnx2x_phy *phy)
 {
-	u32 ext_phy_config;
+	u32 ext_phy_config, phy_type;
 
 	ext_phy_config = bnx2x_get_ext_phy_config(bp, shmem_base,
 						  phy_index, port);
-	phy->type = XGXS_EXT_PHY_TYPE(ext_phy_config);
+	phy_type = XGXS_EXT_PHY_TYPE(ext_phy_config);
+	/* Select the phy type */
+	switch (phy_type) {
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
+		*phy = phy_8073;
+		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
+		*phy = phy_8705;
+		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
+		*phy = phy_8706;
+		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
+		*phy = phy_8726;
+		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727_NOC:
+		/* BCM8727_NOC => BCM8727 no over current */
+		*phy = phy_8727;
+		phy->flags |= FLAGS_NOC;
+		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
+		*phy = phy_8727;
+		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
+		*phy = phy_8481;
+		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
+		*phy = phy_84823;
+		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
+		*phy = phy_7101;
+		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
+		*phy = phy_null;
+		return -EINVAL;
+	default:
+		*phy = phy_null;
+		return 0;
+	}
+
 	phy->addr = XGXS_EXT_PHY_ADDR(ext_phy_config);
+	bnx2x_populate_preemphasis(bp, shmem_base, phy, port, phy_index);
 	phy->mdio_ctrl = bnx2x_get_emac_base(bp, phy->type, port);
 	return 0;
 }
@@ -5820,11 +6434,119 @@ static u8 bnx2x_populate_phy(struct bnx2x *bp, u8 phy_index, u32 shmem_base,
 			     u8 port, struct bnx2x_phy *phy)
 {
 	u8 status = 0;
+	phy->type = PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN;
+	if (phy_index == INT_PHY)
+		return bnx2x_populate_int_phy(bp, shmem_base, port, phy);
 	status = bnx2x_populate_ext_phy(bp, phy_index, shmem_base,
 					port, phy);
 	return status;
 }
 
+static void bnx2x_phy_def_cfg(struct link_params *params,
+			      struct bnx2x_phy *phy,
+			      u8 actual_phy_idx)
+{
+	struct bnx2x *bp = params->bp;
+	u32 link_config;
+	/* Populate the default phy configuration for MF mode */
+	link_config = REG_RD(bp, params->shmem_base +
+			offsetof(struct shmem_region, dev_info.
+			port_feature_config[params->port].link_config));
+	phy->speed_cap_mask = REG_RD(bp, params->shmem_base +
+				offsetof(struct shmem_region, dev_info.
+			port_hw_config[params->port].speed_capability_mask));
+
+	phy->req_duplex = DUPLEX_FULL;
+	switch (link_config  & PORT_FEATURE_LINK_SPEED_MASK) {
+	case PORT_FEATURE_LINK_SPEED_10M_HALF:
+		phy->req_duplex = DUPLEX_HALF;
+	case PORT_FEATURE_LINK_SPEED_10M_FULL:
+		phy->req_line_speed = SPEED_10;
+		break;
+	case PORT_FEATURE_LINK_SPEED_100M_HALF:
+		phy->req_duplex = DUPLEX_HALF;
+	case PORT_FEATURE_LINK_SPEED_100M_FULL:
+		phy->req_line_speed = SPEED_100;
+		break;
+	case PORT_FEATURE_LINK_SPEED_1G:
+		phy->req_line_speed = SPEED_1000;
+		break;
+	case PORT_FEATURE_LINK_SPEED_2_5G:
+		phy->req_line_speed = SPEED_2500;
+		break;
+	case PORT_FEATURE_LINK_SPEED_10G_CX4:
+		phy->req_line_speed = SPEED_10000;
+		break;
+	default:
+		phy->req_line_speed = SPEED_AUTO_NEG;
+		break;
+	}
+
+	switch (link_config  & PORT_FEATURE_FLOW_CONTROL_MASK) {
+	case PORT_FEATURE_FLOW_CONTROL_AUTO:
+		phy->req_flow_ctrl = BNX2X_FLOW_CTRL_AUTO;
+		break;
+	case PORT_FEATURE_FLOW_CONTROL_TX:
+		phy->req_flow_ctrl = BNX2X_FLOW_CTRL_TX;
+		break;
+	case PORT_FEATURE_FLOW_CONTROL_RX:
+		phy->req_flow_ctrl = BNX2X_FLOW_CTRL_RX;
+		break;
+	case PORT_FEATURE_FLOW_CONTROL_BOTH:
+		phy->req_flow_ctrl = BNX2X_FLOW_CTRL_BOTH;
+		break;
+	default:
+		phy->req_flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+		break;
+	}
+}
+
+u8 bnx2x_phy_probe(struct link_params *params)
+{
+	u8 phy_index, actual_phy_idx, link_cfg_idx;
+
+	struct bnx2x *bp = params->bp;
+	struct bnx2x_phy *phy;
+	params->num_phys = 0;
+	DP(NETIF_MSG_LINK, "Begin phy probe\n");
+
+	for (phy_index = INT_PHY; phy_index < MAX_PHYS;
+	      phy_index++) {
+		link_cfg_idx = LINK_CONFIG_IDX(phy_index);
+		actual_phy_idx = phy_index;
+
+		phy = &params->phy[actual_phy_idx];
+		if (bnx2x_populate_phy(bp, phy_index, params->shmem_base,
+				       params->port,
+				       phy) != 0) {
+			params->num_phys = 0;
+			DP(NETIF_MSG_LINK, "phy probe failed in phy index %d\n",
+				   phy_index);
+			for (phy_index = INT_PHY;
+			      phy_index < MAX_PHYS;
+			      phy_index++)
+				*phy = phy_null;
+			return -EINVAL;
+		}
+		if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN)
+			break;
+
+		bnx2x_phy_def_cfg(params, phy, actual_phy_idx);
+		params->num_phys++;
+	}
+
+	DP(NETIF_MSG_LINK, "End phy probe. #phys found %x\n", params->num_phys);
+	return 0;
+}
+
+u32 bnx2x_supported_attr(struct link_params *params, u8 phy_idx)
+{
+	if (phy_idx < params->num_phys)
+		return params->phy[phy_idx].supported;
+	return 0;
+}
+
+
 static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 {
 	struct bnx2x_phy phy[PORT_MAX];
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index 9bfe7fa..9717cb1 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -46,6 +46,15 @@
 #define SFP_EEPROM_PART_NO_ADDR 		0x28
 #define SFP_EEPROM_PART_NO_SIZE		16
 #define PWR_FLT_ERR_MSG_LEN			250
+
+#define XGXS_EXT_PHY_TYPE(ext_phy_config) \
+		((ext_phy_config) & PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK)
+#define XGXS_EXT_PHY_ADDR(ext_phy_config) \
+		(((ext_phy_config) & PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >> \
+		 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT)
+#define SERDES_EXT_PHY_TYPE(ext_phy_config) \
+		((ext_phy_config) & PORT_HW_CFG_SERDES_EXT_PHY_TYPE_MASK)
+
 /* Single Media Direct board is the plain 577xx board with CX4/RJ45 jacks */
 #define SINGLE_MEDIA_DIRECT(params)	(params->num_phys == 1)
 /* Single Media board contains single external phy */
@@ -58,6 +67,10 @@
 
 #define MAX_PHYS	2
 
+/* Same configuration is shared between the XGXS and the first external phy */
+#define LINK_CONFIG_SIZE (MAX_PHYS - 1)
+#define LINK_CONFIG_IDX(_phy_idx) ((_phy_idx == INT_PHY) ? \
+					 0 : (_phy_idx - 1))
 /***********************************************************/
 /*                      bnx2x_phy struct                     */
 /*  Defines the required arguments and function per phy    */
@@ -66,13 +79,88 @@ struct link_vars;
 struct link_params;
 struct bnx2x_phy;
 
+typedef u8 (*config_init_t)(struct bnx2x_phy *phy, struct link_params *params,
+			    struct link_vars *vars);
+typedef u8 (*read_status_t)(struct bnx2x_phy *phy, struct link_params *params,
+			    struct link_vars *vars);
+typedef void (*link_reset_t)(struct bnx2x_phy *phy,
+			     struct link_params *params);
+typedef void (*config_loopback_t)(struct bnx2x_phy *phy,
+				  struct link_params *params);
+typedef u8 (*format_fw_ver_t)(u32 raw, u8 *str, u16 *len);
+typedef void (*hw_reset_t)(struct bnx2x_phy *phy, struct link_params *params);
+typedef void (*set_link_led_t)(struct bnx2x_phy *phy,
+			       struct link_params *params, u8 mode);
+
 struct bnx2x_phy {
 	u32 type;
 
 	/* Loaded during init */
 	u8 addr;
 
+	u8 flags;
+	/* Require HW lock */
+#define FLAGS_HW_LOCK_REQUIRED		(1<<0)
+	/* No Over-Current detection */
+#define FLAGS_NOC			(1<<1)
+	/* Fan failure detection required */
+#define FLAGS_FAN_FAILURE_DET_REQ	(1<<2)
+	/* Initialize first the XGXS and only then the phy itself */
+#define FLAGS_INIT_XGXS_FIRST	(1<<3)
+
+	u8 def_md_devad;
+	u8 reserved;
+	/* preemphasis values for the rx side */
+	u16 rx_preemphasis[4];
+
+	/* preemphasis values for the tx side */
+	u16 tx_preemphasis[4];
+
+	/* EMAC address for access MDIO */
 	u32 mdio_ctrl;
+
+	u32 supported;
+
+	u32 media_type;
+#define	ETH_PHY_UNSPECIFIED 0x0
+#define	ETH_PHY_SFP_FIBER   0x1
+#define	ETH_PHY_XFP_FIBER   0x2
+#define	ETH_PHY_DA_TWINAX   0x3
+#define	ETH_PHY_BASE_T      0x4
+#define	ETH_PHY_NOT_PRESENT 0xff
+
+	/* The address in which version is located*/
+	u32 ver_addr;
+
+	u16 req_flow_ctrl;
+
+	u16 req_line_speed;
+
+	u32 speed_cap_mask;
+
+	u16 req_duplex;
+	u16 rsrv;
+	/* Called per phy/port init, and it configures LASI, speed, autoneg,
+	 duplex, flow control negotiation, etc. */
+	config_init_t config_init;
+
+	/* Called due to interrupt. It determines the link, speed */
+	read_status_t read_status;
+
+	/* Called when driver is unloading. Should reset the phy */
+	link_reset_t link_reset;
+
+	/* Set the loopback configuration for the phy */
+	config_loopback_t config_loopback;
+
+	/* Format the given raw number into str up to len */
+	format_fw_ver_t format_fw_ver;
+
+	/* Reset the phy (both ports) */
+	hw_reset_t hw_reset;
+
+	/* Set link led mode (on/off/oper)*/
+	set_link_led_t set_link_led;
 };
 
 /* Inputs parameters to the CLC */
@@ -106,38 +194,23 @@ struct link_params {
 #define SWITCH_CFG_10G		PORT_FEATURE_CON_SWITCH_10G_SWITCH
 #define SWITCH_CFG_AUTO_DETECT	PORT_FEATURE_CON_SWITCH_AUTO_DETECT
 
-	u16 hw_led_mode; /* part of the hw_config read from the shmem */
-
-	/* phy_addr populated by the phy_init function */
-	u8 phy_addr;
-	/*u8 reserved1;*/
-
 	u32 lane_config;
-	u32 ext_phy_config;
-#define XGXS_EXT_PHY_TYPE(ext_phy_config) \
-		((ext_phy_config) & PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK)
-#define XGXS_EXT_PHY_ADDR(ext_phy_config) \
-		(((ext_phy_config) & PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >> \
-		 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT)
-#define SERDES_EXT_PHY_TYPE(ext_phy_config) \
-		((ext_phy_config) & PORT_HW_CFG_SERDES_EXT_PHY_TYPE_MASK)
 
 	/* Phy register parameter */
 	u32 chip_id;
 
-	u16 xgxs_config_rx[4]; /* preemphasis values for the rx side */
-	u16 xgxs_config_tx[4]; /* preemphasis values for the tx side */
-
 	u32 feature_config_flags;
 #define FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED (1<<0)
 #define FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY	(1<<2)
-#define FEATURE_CONFIG_BCM8727_NOC			(1<<3)
 	/* Will be populated during common init */
 	struct bnx2x_phy phy[MAX_PHYS];
 
 	/* Will be populated during common init */
 	u8 num_phys;
 
+	u8 rsrv;
+	u16 hw_led_mode; /* part of the hw_config read from the shmem */
+
 	/* Device pointer passed to all callback functions */
 	struct bnx2x *bp;
 };
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 174ed8b..1ecff37 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1960,12 +1960,16 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 static inline void bnx2x_fan_failure(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
-
+	u32 ext_phy_config;
 	/* mark the failure */
-	bp->link_params.ext_phy_config &= ~PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK;
-	bp->link_params.ext_phy_config |= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE;
+	ext_phy_config =
+		SHMEM_RD(bp,
+			 dev_info.port_hw_config[port].external_phy_config);
+
+	ext_phy_config &= ~PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK;
+	ext_phy_config |= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE;
 	SHMEM_WR(bp, dev_info.port_hw_config[port].external_phy_config,
-		 bp->link_params.ext_phy_config);
+		 ext_phy_config);
 
 	/* log the failure */
 	netdev_err(bp->dev, "Fan Failure on Network Controller has caused"
@@ -1991,7 +1995,7 @@ static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 		BNX2X_ERR("SPIO5 hw attention\n");
 
 		/* Fan failure attention */
-		switch (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config)) {
+		switch (bp->link_params.phy[EXT_PHY1].type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 			/* Low power mode is controlled by GPIO 2 */
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
@@ -4140,7 +4144,7 @@ static int bnx2x_init_common(struct bnx2x *bp)
 		return -EBUSY;
 	}
 
-	switch (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config)) {
+	switch (bp->link_params.phy[EXT_PHY1].type) {
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
@@ -4299,7 +4303,7 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	bnx2x_init_block(bp, MCP_BLOCK, init_stage);
 	bnx2x_init_block(bp, DMAE_BLOCK, init_stage);
 
-	switch (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config)) {
+	switch (bp->link_params.phy[EXT_PHY1].type) {
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 		{
 		u32 swap_val, swap_override, aeu_gpio_mask, offset;
@@ -4480,7 +4484,7 @@ static int bnx2x_init_func(struct bnx2x *bp)
 	/* Reset PCIE errors for debug */
 	REG_WR(bp, 0x2114, 0xffffffff);
 	REG_WR(bp, 0x2120, 0xffffffff);
-
+	bnx2x_phy_probe(&bp->link_params);
 	return 0;
 }
 
@@ -6065,194 +6069,32 @@ static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
 						    u32 switch_cfg)
 {
 	int port = BP_PORT(bp);
-	u32 ext_phy_type;
-
-	switch (switch_cfg) {
-	case SWITCH_CFG_1G:
-		BNX2X_DEV_INFO("switch_cfg 0x%x (1G)\n", switch_cfg);
-
-		ext_phy_type =
-			SERDES_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
-		switch (ext_phy_type) {
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_DIRECT:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (Direct)\n",
-				       ext_phy_type);
-
-			bp->port.supported |= (SUPPORTED_10baseT_Half |
-					       SUPPORTED_10baseT_Full |
-					       SUPPORTED_100baseT_Half |
-					       SUPPORTED_100baseT_Full |
-					       SUPPORTED_1000baseT_Full |
-					       SUPPORTED_2500baseX_Full |
-					       SUPPORTED_TP |
-					       SUPPORTED_FIBRE |
-					       SUPPORTED_Autoneg |
-					       SUPPORTED_Pause |
-					       SUPPORTED_Asym_Pause);
+	bp->port.supported = 0;
+	switch (bp->link_params.num_phys) {
+	case 1:
+		bp->port.supported = bp->link_params.phy[INT_PHY].supported;
 			break;
-
-		case PORT_HW_CFG_SERDES_EXT_PHY_TYPE_BCM5482:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (5482)\n",
-				       ext_phy_type);
-
-			bp->port.supported |= (SUPPORTED_10baseT_Half |
-					       SUPPORTED_10baseT_Full |
-					       SUPPORTED_100baseT_Half |
-					       SUPPORTED_100baseT_Full |
-					       SUPPORTED_1000baseT_Full |
-					       SUPPORTED_TP |
-					       SUPPORTED_FIBRE |
-					       SUPPORTED_Autoneg |
-					       SUPPORTED_Pause |
-					       SUPPORTED_Asym_Pause);
+	case 2:
+		bp->port.supported = bp->link_params.phy[EXT_PHY1].supported;
 			break;
+	}
 
-		default:
-			BNX2X_ERR("NVRAM config error. "
-				  "BAD SerDes ext_phy_config 0x%x\n",
-				  bp->link_params.ext_phy_config);
+	if (!(bp->port.supported)) {
+		BNX2X_ERR("NVRAM config error. BAD phy config."
+			  "PHY1 config 0x%x\n",
+			   SHMEM_RD(bp,
+			   dev_info.port_hw_config[port].external_phy_config));
 			return;
 		}
 
+	switch (switch_cfg) {
+	case SWITCH_CFG_1G:
 		bp->port.phy_addr = REG_RD(bp, NIG_REG_SERDES0_CTRL_PHY_ADDR +
 					   port*0x10);
 		BNX2X_DEV_INFO("phy_addr 0x%x\n", bp->port.phy_addr);
 		break;
 
 	case SWITCH_CFG_10G:
-		BNX2X_DEV_INFO("switch_cfg 0x%x (10G)\n", switch_cfg);
-
-		ext_phy_type =
-			XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
-		switch (ext_phy_type) {
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (Direct)\n",
-				       ext_phy_type);
-
-			bp->port.supported |= (SUPPORTED_10baseT_Half |
-					       SUPPORTED_10baseT_Full |
-					       SUPPORTED_100baseT_Half |
-					       SUPPORTED_100baseT_Full |
-					       SUPPORTED_1000baseT_Full |
-					       SUPPORTED_2500baseX_Full |
-					       SUPPORTED_10000baseT_Full |
-					       SUPPORTED_TP |
-					       SUPPORTED_FIBRE |
-					       SUPPORTED_Autoneg |
-					       SUPPORTED_Pause |
-					       SUPPORTED_Asym_Pause);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (8072)\n",
-				       ext_phy_type);
-
-			bp->port.supported |= (SUPPORTED_10000baseT_Full |
-					       SUPPORTED_1000baseT_Full |
-					       SUPPORTED_FIBRE |
-					       SUPPORTED_Autoneg |
-					       SUPPORTED_Pause |
-					       SUPPORTED_Asym_Pause);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (8073)\n",
-				       ext_phy_type);
-
-			bp->port.supported |= (SUPPORTED_10000baseT_Full |
-					       SUPPORTED_2500baseX_Full |
-					       SUPPORTED_1000baseT_Full |
-					       SUPPORTED_FIBRE |
-					       SUPPORTED_Autoneg |
-					       SUPPORTED_Pause |
-					       SUPPORTED_Asym_Pause);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (8705)\n",
-				       ext_phy_type);
-
-			bp->port.supported |= (SUPPORTED_10000baseT_Full |
-					       SUPPORTED_FIBRE |
-					       SUPPORTED_Pause |
-					       SUPPORTED_Asym_Pause);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (8706)\n",
-				       ext_phy_type);
-
-			bp->port.supported |= (SUPPORTED_10000baseT_Full |
-					       SUPPORTED_1000baseT_Full |
-					       SUPPORTED_FIBRE |
-					       SUPPORTED_Pause |
-					       SUPPORTED_Asym_Pause);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (8726)\n",
-				       ext_phy_type);
-
-			bp->port.supported |= (SUPPORTED_10000baseT_Full |
-					       SUPPORTED_1000baseT_Full |
-					       SUPPORTED_Autoneg |
-					       SUPPORTED_FIBRE |
-					       SUPPORTED_Pause |
-					       SUPPORTED_Asym_Pause);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (8727)\n",
-				       ext_phy_type);
-
-			bp->port.supported |= (SUPPORTED_10000baseT_Full |
-					       SUPPORTED_1000baseT_Full |
-					       SUPPORTED_Autoneg |
-					       SUPPORTED_FIBRE |
-					       SUPPORTED_Pause |
-					       SUPPORTED_Asym_Pause);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (SFX7101)\n",
-				       ext_phy_type);
-
-			bp->port.supported |= (SUPPORTED_10000baseT_Full |
-					       SUPPORTED_TP |
-					       SUPPORTED_Autoneg |
-					       SUPPORTED_Pause |
-					       SUPPORTED_Asym_Pause);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
-			BNX2X_DEV_INFO("ext_phy_type 0x%x (BCM848xx)\n",
-				       ext_phy_type);
-
-			bp->port.supported |= (SUPPORTED_10baseT_Half |
-					       SUPPORTED_10baseT_Full |
-					       SUPPORTED_100baseT_Half |
-					       SUPPORTED_100baseT_Full |
-					       SUPPORTED_1000baseT_Full |
-					       SUPPORTED_10000baseT_Full |
-					       SUPPORTED_TP |
-					       SUPPORTED_Autoneg |
-					       SUPPORTED_Pause |
-					       SUPPORTED_Asym_Pause);
-			break;
-
-		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
-			BNX2X_ERR("XGXS PHY Failure detected 0x%x\n",
-				  bp->link_params.ext_phy_config);
-			break;
-
-		default:
-			BNX2X_ERR("NVRAM config error. "
-				  "BAD XGXS ext_phy_config 0x%x\n",
-				  bp->link_params.ext_phy_config);
-			return;
-		}
-
 		bp->port.phy_addr = REG_RD(bp, NIG_REG_XGXS0_CTRL_PHY_ADDR +
 					   port*0x18);
 		BNX2X_DEV_INFO("phy_addr 0x%x\n", bp->port.phy_addr);
@@ -6264,8 +6106,6 @@ static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
 			  bp->port.link_config);
 		return;
 	}
-	bp->link_params.phy_addr = bp->port.phy_addr;
-
 	/* mask what we support according to speed_cap_mask */
 	if (!(bp->link_params.speed_cap_mask &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF))
@@ -6309,25 +6149,10 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 			bp->link_params.req_line_speed = SPEED_AUTO_NEG;
 			bp->port.advertising = bp->port.supported;
 		} else {
-			u32 ext_phy_type =
-			    XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
-
-			if ((ext_phy_type ==
-			     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705) ||
-			    (ext_phy_type ==
-			     PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706)) {
 				/* force 10G, no AN */
 				bp->link_params.req_line_speed = SPEED_10000;
-				bp->port.advertising =
-						(ADVERTISED_10000baseT_Full |
+			bp->port.advertising =	(ADVERTISED_10000baseT_Full |
 						 ADVERTISED_FIBRE);
-				break;
-			}
-			BNX2X_ERR("NVRAM config error. "
-				  "Invalid link_config 0x%x"
-				  "  Autoneg not supported\n",
-				  bp->port.link_config);
-			return;
 		}
 		break;
 
@@ -6475,27 +6300,13 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	int port = BP_PORT(bp);
 	u32 val, val2;
 	u32 config;
-	u16 i;
-	u32 ext_phy_type;
+	u32 ext_phy_type, ext_phy_config;;
 
 	bp->link_params.bp = bp;
 	bp->link_params.port = port;
 
 	bp->link_params.lane_config =
 		SHMEM_RD(bp, dev_info.port_hw_config[port].lane_config);
-	bp->link_params.ext_phy_config =
-		SHMEM_RD(bp,
-			 dev_info.port_hw_config[port].external_phy_config);
-	/* BCM8727_NOC => BCM8727 no over current */
-	if (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config) ==
-	    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727_NOC) {
-		bp->link_params.ext_phy_config &=
-			~PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK;
-		bp->link_params.ext_phy_config |=
-			PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727;
-		bp->link_params.feature_config_flags |=
-			FEATURE_CONFIG_BCM8727_NOC;
-	}
 
 	bp->link_params.speed_cap_mask =
 		SHMEM_RD(bp,
@@ -6504,18 +6315,6 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	bp->port.link_config =
 		SHMEM_RD(bp, dev_info.port_feature_config[port].link_config);
 
-	/* Get the 4 lanes xgxs config rx and tx */
-	for (i = 0; i < 2; i++) {
-		val = SHMEM_RD(bp,
-			   dev_info.port_hw_config[port].xgxs_config_rx[i<<1]);
-		bp->link_params.xgxs_config_rx[i << 1] = ((val>>16) & 0xffff);
-		bp->link_params.xgxs_config_rx[(i << 1) + 1] = (val & 0xffff);
-
-		val = SHMEM_RD(bp,
-			   dev_info.port_hw_config[port].xgxs_config_tx[i<<1]);
-		bp->link_params.xgxs_config_tx[i << 1] = ((val>>16) & 0xffff);
-		bp->link_params.xgxs_config_tx[(i << 1) + 1] = (val & 0xffff);
-	}
 
 	/* If the device is capable of WoL, set the default state according
 	 * to the HW
@@ -6524,14 +6323,14 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	bp->wol = (!(bp->flags & NO_WOL_FLAG) &&
 		   (config & PORT_FEATURE_WOL_ENABLED));
 
-	BNX2X_DEV_INFO("lane_config 0x%08x  ext_phy_config 0x%08x"
+	BNX2X_DEV_INFO("lane_config 0x%08x"
 		       "  speed_cap_mask 0x%08x  link_config 0x%08x\n",
 		       bp->link_params.lane_config,
-		       bp->link_params.ext_phy_config,
 		       bp->link_params.speed_cap_mask, bp->port.link_config);
 
 	bp->link_params.switch_cfg |= (bp->port.link_config &
 				       PORT_FEATURE_CONNECTED_SWITCH_MASK);
+	bnx2x_phy_probe(&bp->link_params);
 	bnx2x_link_settings_supported(bp, bp->link_params.switch_cfg);
 
 	bnx2x_link_settings_requested(bp);
@@ -6540,14 +6339,17 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	 * If connected directly, work with the internal PHY, otherwise, work
 	 * with the external PHY
 	 */
-	ext_phy_type = XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config);
+	ext_phy_config =
+		SHMEM_RD(bp,
+			 dev_info.port_hw_config[port].external_phy_config);
+	ext_phy_type = XGXS_EXT_PHY_TYPE(ext_phy_config);
 	if (ext_phy_type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT)
-		bp->mdio.prtad = bp->link_params.phy_addr;
+		bp->mdio.prtad = bp->port.phy_addr;
 
 	else if ((ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) &&
 		 (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN))
 		bp->mdio.prtad =
-			XGXS_EXT_PHY_ADDR(bp->link_params.ext_phy_config);
+			XGXS_EXT_PHY_ADDR(ext_phy_config);
 
 	val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_upper);
 	val = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_lower);
-- 
1.7.1




