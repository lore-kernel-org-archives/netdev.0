From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 07/10] bnx2x: Organize PHY functions
Date: Wed, 8 Sep 2010 00:41:13 +0300
Message-ID: <1283895673.5452.67.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3992 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932436Ab0IGSXF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 14:23:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Group all PHY specific functions together to have an organized code

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_ethtool.c |    2 +-
 drivers/net/bnx2x/bnx2x_link.c    | 4897 +++++++++++++++++++------------------
 drivers/net/bnx2x/bnx2x_link.h    |    2 +-
 drivers/net/bnx2x/bnx2x_main.c    |    2 +-
 4 files changed, 2475 insertions(+), 2428 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index becfd9e..dbcfa7a 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1282,7 +1282,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	/* check the loopback mode */
 	switch (loopback_mode) {
 	case BNX2X_PHY_LOOPBACK:
-		if (bp->link_params.loopback_mode != LOOPBACK_XGXS_10)
+		if (bp->link_params.loopback_mode != LOOPBACK_XGXS)
 			return -EINVAL;
 		break;
 	case BNX2X_MAC_LOOPBACK:
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 469e0e4..5ff8268 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -181,20 +181,6 @@
 		(_bank + (_addr & 0xf)), \
 		_val)
 
-static void bnx2x_set_serdes_access(struct bnx2x *bp, u8 port)
-{
-	u32 emac_base = (port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-
-	/* Set Clause 22 */
-	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_ST + port*0x10, 1);
-	REG_WR(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM, 0x245f8000);
-	udelay(500);
-	REG_WR(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM, 0x245d000f);
-	udelay(500);
-	 /* Set Clause 45 */
-	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_ST + port*0x10, 0);
-}
-
 static u32 bnx2x_bits_en(struct bnx2x *bp, u32 reg, u32 bits)
 {
 	u32 val = REG_RD(bp, reg);
@@ -510,175 +496,6 @@ static u8 bnx2x_bmac_enable(struct link_params *params, struct link_vars *vars,
 	return 0;
 }
 
-static void bnx2x_serdes_deassert(struct bnx2x *bp, u8 port)
-{
-	u32 val;
-
-	DP(NETIF_MSG_LINK, "bnx2x_serdes_deassert\n");
-
-	val = SERDES_RESET_BITS << (port*16);
-
-	/* reset and unreset the SerDes/XGXS */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR, val);
-	udelay(500);
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET, val);
-
-	bnx2x_set_serdes_access(bp, port);
-
-	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_DEVAD +
-		     port*0x10,
-		     DEFAULT_PHY_DEV_ADDR);
-}
-
-static void bnx2x_xgxs_deassert(struct link_params *params)
-{
-	struct bnx2x *bp = params->bp;
-	u8 port;
-	u32 val;
-	DP(NETIF_MSG_LINK, "bnx2x_xgxs_deassert\n");
-	port = params->port;
-
-	val = XGXS_RESET_BITS << (port*16);
-
-	/* reset and unreset the SerDes/XGXS */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR, val);
-	udelay(500);
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET, val);
-
-	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_ST +
-		     port*0x18, 0);
-	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18,
-		     params->phy[INT_PHY].def_md_devad);
-}
-void bnx2x_link_status_update(struct link_params *params,
-			    struct link_vars   *vars)
-{
-	struct bnx2x *bp = params->bp;
-	u8 link_10g;
-	u8 port = params->port;
-
-	if (params->switch_cfg ==  SWITCH_CFG_1G)
-		vars->phy_flags = PHY_SERDES_FLAG;
-	else
-		vars->phy_flags = PHY_XGXS_FLAG;
-	vars->link_status = REG_RD(bp, params->shmem_base +
-					  offsetof(struct shmem_region,
-					   port_mb[port].link_status));
-
-	vars->link_up = (vars->link_status & LINK_STATUS_LINK_UP);
-
-	if (vars->link_up) {
-		DP(NETIF_MSG_LINK, "phy link up\n");
-
-		vars->phy_link_up = 1;
-		vars->duplex = DUPLEX_FULL;
-		switch (vars->link_status &
-					LINK_STATUS_SPEED_AND_DUPLEX_MASK) {
-			case LINK_10THD:
-				vars->duplex = DUPLEX_HALF;
-				/* fall thru */
-			case LINK_10TFD:
-				vars->line_speed = SPEED_10;
-				break;
-
-			case LINK_100TXHD:
-				vars->duplex = DUPLEX_HALF;
-				/* fall thru */
-			case LINK_100T4:
-			case LINK_100TXFD:
-				vars->line_speed = SPEED_100;
-				break;
-
-			case LINK_1000THD:
-				vars->duplex = DUPLEX_HALF;
-				/* fall thru */
-			case LINK_1000TFD:
-				vars->line_speed = SPEED_1000;
-				break;
-
-			case LINK_2500THD:
-				vars->duplex = DUPLEX_HALF;
-				/* fall thru */
-			case LINK_2500TFD:
-				vars->line_speed = SPEED_2500;
-				break;
-
-			case LINK_10GTFD:
-				vars->line_speed = SPEED_10000;
-				break;
-
-			case LINK_12GTFD:
-				vars->line_speed = SPEED_12000;
-				break;
-
-			case LINK_12_5GTFD:
-				vars->line_speed = SPEED_12500;
-				break;
-
-			case LINK_13GTFD:
-				vars->line_speed = SPEED_13000;
-				break;
-
-			case LINK_15GTFD:
-				vars->line_speed = SPEED_15000;
-				break;
-
-			case LINK_16GTFD:
-				vars->line_speed = SPEED_16000;
-				break;
-
-			default:
-				break;
-		}
-
-		vars->flow_ctrl = 0;
-		if (vars->link_status & LINK_STATUS_TX_FLOW_CONTROL_ENABLED)
-			vars->flow_ctrl |= BNX2X_FLOW_CTRL_TX;
-
-		if (vars->link_status & LINK_STATUS_RX_FLOW_CONTROL_ENABLED)
-			vars->flow_ctrl |= BNX2X_FLOW_CTRL_RX;
-
-		if (!vars->flow_ctrl)
-			vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-
-		if (vars->line_speed &&
-		    ((vars->line_speed == SPEED_10) ||
-		     (vars->line_speed == SPEED_100))) {
-			vars->phy_flags |= PHY_SGMII_FLAG;
-		} else {
-			vars->phy_flags &= ~PHY_SGMII_FLAG;
-		}
-
-		/* anything 10 and over uses the bmac */
-		link_10g = ((vars->line_speed == SPEED_10000) ||
-			    (vars->line_speed == SPEED_12000) ||
-			    (vars->line_speed == SPEED_12500) ||
-			    (vars->line_speed == SPEED_13000) ||
-			    (vars->line_speed == SPEED_15000) ||
-			    (vars->line_speed == SPEED_16000));
-		if (link_10g)
-			vars->mac_type = MAC_TYPE_BMAC;
-		else
-			vars->mac_type = MAC_TYPE_EMAC;
-
-	} else { /* link down */
-		DP(NETIF_MSG_LINK, "phy link down\n");
-
-		vars->phy_link_up = 0;
-
-		vars->line_speed = 0;
-		vars->duplex = DUPLEX_FULL;
-		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-
-		/* indicate no mac active */
-		vars->mac_type = MAC_TYPE_NONE;
-	}
-
-	DP(NETIF_MSG_LINK, "link_status 0x%x  phy_link_up %x\n",
-		 vars->link_status, vars->phy_link_up);
-	DP(NETIF_MSG_LINK, "line_speed %x  duplex %x  flow_ctrl 0x%x\n",
-		 vars->line_speed, vars->duplex, vars->flow_ctrl);
-}
 
 static void bnx2x_update_mng(struct link_params *params, u32 link_status)
 {
@@ -1023,6 +840,196 @@ static void bnx2x_set_aer_mmd(struct link_params *params,
 			      MDIO_AER_BLOCK_AER_REG, 0x3800 + offset);
 }
 
+/******************************************************************/
+/*			Internal phy section			  */
+/******************************************************************/
+
+static void bnx2x_set_serdes_access(struct bnx2x *bp, u8 port)
+{
+	u32 emac_base = (port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+
+	/* Set Clause 22 */
+	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_ST + port*0x10, 1);
+	REG_WR(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM, 0x245f8000);
+	udelay(500);
+	REG_WR(bp, emac_base + EMAC_REG_EMAC_MDIO_COMM, 0x245d000f);
+	udelay(500);
+	 /* Set Clause 45 */
+	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_ST + port*0x10, 0);
+}
+
+static void bnx2x_serdes_deassert(struct bnx2x *bp, u8 port)
+{
+	u32 val;
+
+	DP(NETIF_MSG_LINK, "bnx2x_serdes_deassert\n");
+
+	val = SERDES_RESET_BITS << (port*16);
+
+	/* reset and unreset the SerDes/XGXS */
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR, val);
+	udelay(500);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET, val);
+
+	bnx2x_set_serdes_access(bp, port);
+
+	REG_WR(bp, NIG_REG_SERDES0_CTRL_MD_DEVAD +
+		     port*0x10,
+		     DEFAULT_PHY_DEV_ADDR);
+}
+
+static void bnx2x_xgxs_deassert(struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	u8 port;
+	u32 val;
+	DP(NETIF_MSG_LINK, "bnx2x_xgxs_deassert\n");
+	port = params->port;
+
+	val = XGXS_RESET_BITS << (port*16);
+
+	/* reset and unreset the SerDes/XGXS */
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR, val);
+	udelay(500);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET, val);
+
+	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_ST +
+		     port*0x18, 0);
+	REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18,
+		     params->phy[INT_PHY].def_md_devad);
+}
+
+void bnx2x_link_status_update(struct link_params *params,
+			    struct link_vars   *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u8 link_10g;
+	u8 port = params->port;
+
+	if (params->switch_cfg ==  SWITCH_CFG_1G)
+		vars->phy_flags = PHY_SERDES_FLAG;
+	else
+		vars->phy_flags = PHY_XGXS_FLAG;
+	vars->link_status = REG_RD(bp, params->shmem_base +
+					  offsetof(struct shmem_region,
+					   port_mb[port].link_status));
+
+	vars->link_up = (vars->link_status & LINK_STATUS_LINK_UP);
+
+	if (vars->link_up) {
+		DP(NETIF_MSG_LINK, "phy link up\n");
+
+		vars->phy_link_up = 1;
+		vars->duplex = DUPLEX_FULL;
+		switch (vars->link_status &
+					LINK_STATUS_SPEED_AND_DUPLEX_MASK) {
+			case LINK_10THD:
+				vars->duplex = DUPLEX_HALF;
+				/* fall thru */
+			case LINK_10TFD:
+				vars->line_speed = SPEED_10;
+				break;
+
+			case LINK_100TXHD:
+				vars->duplex = DUPLEX_HALF;
+				/* fall thru */
+			case LINK_100T4:
+			case LINK_100TXFD:
+				vars->line_speed = SPEED_100;
+				break;
+
+			case LINK_1000THD:
+				vars->duplex = DUPLEX_HALF;
+				/* fall thru */
+			case LINK_1000TFD:
+				vars->line_speed = SPEED_1000;
+				break;
+
+			case LINK_2500THD:
+				vars->duplex = DUPLEX_HALF;
+				/* fall thru */
+			case LINK_2500TFD:
+				vars->line_speed = SPEED_2500;
+				break;
+
+			case LINK_10GTFD:
+				vars->line_speed = SPEED_10000;
+				break;
+
+			case LINK_12GTFD:
+				vars->line_speed = SPEED_12000;
+				break;
+
+			case LINK_12_5GTFD:
+				vars->line_speed = SPEED_12500;
+				break;
+
+			case LINK_13GTFD:
+				vars->line_speed = SPEED_13000;
+				break;
+
+			case LINK_15GTFD:
+				vars->line_speed = SPEED_15000;
+				break;
+
+			case LINK_16GTFD:
+				vars->line_speed = SPEED_16000;
+				break;
+
+			default:
+				break;
+		}
+
+		vars->flow_ctrl = 0;
+		if (vars->link_status & LINK_STATUS_TX_FLOW_CONTROL_ENABLED)
+			vars->flow_ctrl |= BNX2X_FLOW_CTRL_TX;
+
+		if (vars->link_status & LINK_STATUS_RX_FLOW_CONTROL_ENABLED)
+			vars->flow_ctrl |= BNX2X_FLOW_CTRL_RX;
+
+		if (!vars->flow_ctrl)
+			vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+
+		if (vars->line_speed &&
+		    ((vars->line_speed == SPEED_10) ||
+		     (vars->line_speed == SPEED_100))) {
+			vars->phy_flags |= PHY_SGMII_FLAG;
+		} else {
+			vars->phy_flags &= ~PHY_SGMII_FLAG;
+		}
+
+		/* anything 10 and over uses the bmac */
+		link_10g = ((vars->line_speed == SPEED_10000) ||
+			    (vars->line_speed == SPEED_12000) ||
+			    (vars->line_speed == SPEED_12500) ||
+			    (vars->line_speed == SPEED_13000) ||
+			    (vars->line_speed == SPEED_15000) ||
+			    (vars->line_speed == SPEED_16000));
+		if (link_10g)
+			vars->mac_type = MAC_TYPE_BMAC;
+		else
+			vars->mac_type = MAC_TYPE_EMAC;
+
+	} else { /* link down */
+		DP(NETIF_MSG_LINK, "phy link down\n");
+
+		vars->phy_link_up = 0;
+
+		vars->line_speed = 0;
+		vars->duplex = DUPLEX_FULL;
+		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+
+		/* indicate no mac active */
+		vars->mac_type = MAC_TYPE_NONE;
+	}
+
+	DP(NETIF_MSG_LINK, "link_status 0x%x  phy_link_up %x\n",
+		 vars->link_status, vars->phy_link_up);
+	DP(NETIF_MSG_LINK, "line_speed %x  duplex %x  flow_ctrl 0x%x\n",
+		 vars->line_speed, vars->duplex, vars->flow_ctrl);
+}
+
+
 static void bnx2x_set_master_ln(struct link_params *params,
 				struct bnx2x_phy *phy)
 {
@@ -1271,9 +1278,9 @@ static void bnx2x_set_autoneg(struct bnx2x_phy *phy,
 			reg_val |= MDIO_CL73_IEEEB1_AN_ADV2_ADVR_1000M_KX;
 
 		CL45_WR_OVER_CL22(bp, phy,
-				      MDIO_REG_BANK_CL73_IEEEB1,
-				      MDIO_CL73_IEEEB1_AN_ADV2,
-			      reg_val);
+					      MDIO_REG_BANK_CL73_IEEEB1,
+					      MDIO_CL73_IEEEB1_AN_ADV2,
+				      reg_val);
 
 		/* CL73 Autoneg Enabled */
 		reg_val = MDIO_CL73_IEEEB0_CL73_AN_CONTROL_AN_EN;
@@ -1560,42 +1567,6 @@ static void bnx2x_pause_resolve(struct link_vars *vars, u32 pause_result)
 
 }
 
-static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
-				   struct link_params *params,
-				   struct link_vars *vars)
-{
-	struct bnx2x *bp = params->bp;
-	u16 ld_pause;		/* local */
-	u16 lp_pause;		/* link partner */
-	u16 pause_result;
-	u8 ret = 0;
-	/* read twice */
-
-	vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-
-	if (phy->req_flow_ctrl != BNX2X_FLOW_CTRL_AUTO)
-		vars->flow_ctrl = phy->req_flow_ctrl;
-	else if (phy->req_line_speed != SPEED_AUTO_NEG)
-		vars->flow_ctrl = params->req_fc_auto_adv;
-	else if (vars->link_status & LINK_STATUS_AUTO_NEGOTIATE_COMPLETE) {
-		ret = 1;
-		bnx2x_cl45_read(bp, phy,
-			      MDIO_AN_DEVAD,
-			      MDIO_AN_REG_ADV_PAUSE, &ld_pause);
-		bnx2x_cl45_read(bp, phy,
-			      MDIO_AN_DEVAD,
-			      MDIO_AN_REG_LP_AUTO_NEG, &lp_pause);
-		pause_result = (ld_pause &
-				MDIO_AN_REG_ADV_PAUSE_MASK) >> 8;
-		pause_result |= (lp_pause &
-				 MDIO_AN_REG_ADV_PAUSE_MASK) >> 10;
-		DP(NETIF_MSG_LINK, "Ext PHY pause result 0x%x\n",
-		   pause_result);
-		bnx2x_pause_resolve(vars, pause_result);
-	}
-	return ret;
-}
-
 static u8 bnx2x_direct_parallel_detect_used(struct bnx2x_phy *phy,
 					    struct link_params *params)
 {
@@ -2004,6 +1975,79 @@ static u8 bnx2x_emac_program(struct link_params *params,
 	return 0;
 }
 
+static void bnx2x_set_preemphasis(struct bnx2x_phy *phy,
+				  struct link_params *params)
+{
+
+	u16 bank, i = 0;
+	struct bnx2x *bp = params->bp;
+
+	for (bank = MDIO_REG_BANK_RX0, i = 0; bank <= MDIO_REG_BANK_RX3;
+	      bank += (MDIO_REG_BANK_RX1-MDIO_REG_BANK_RX0), i++) {
+			CL45_WR_OVER_CL22(bp, phy,
+					  bank,
+					  MDIO_RX0_RX_EQ_BOOST,
+					  phy->rx_preemphasis[i]);
+	}
+
+	for (bank = MDIO_REG_BANK_TX0, i = 0; bank <= MDIO_REG_BANK_TX3;
+		      bank += (MDIO_REG_BANK_TX1 - MDIO_REG_BANK_TX0), i++) {
+			CL45_WR_OVER_CL22(bp, phy,
+					  bank,
+					  MDIO_TX0_TX_DRIVER,
+					  phy->tx_preemphasis[i]);
+	}
+}
+
+static void bnx2x_init_internal_phy(struct bnx2x_phy *phy,
+				    struct link_params *params,
+				    struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u8 enable_cl73 = (SINGLE_MEDIA_DIRECT(params) ||
+			  (params->loopback_mode == LOOPBACK_XGXS));
+	if (!(vars->phy_flags & PHY_SGMII_FLAG)) {
+		if (SINGLE_MEDIA_DIRECT(params) &&
+		    (params->feature_config_flags &
+		     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED))
+			bnx2x_set_preemphasis(phy, params);
+
+		/* forced speed requested? */
+		if (vars->line_speed != SPEED_AUTO_NEG ||
+		    (SINGLE_MEDIA_DIRECT(params) &&
+			  params->loopback_mode == LOOPBACK_EXT)) {
+			DP(NETIF_MSG_LINK, "not SGMII, no AN\n");
+
+			/* disable autoneg */
+			bnx2x_set_autoneg(phy, params, vars, 0);
+
+			/* program speed and duplex */
+			bnx2x_program_serdes(phy, params, vars);
+
+		} else { /* AN_mode */
+			DP(NETIF_MSG_LINK, "not SGMII, AN\n");
+
+			/* AN enabled */
+			bnx2x_set_brcm_cl37_advertisment(phy, params);
+
+			/* program duplex & pause advertisement (for aneg) */
+			bnx2x_set_ieee_aneg_advertisment(phy, params,
+						       vars->ieee_fc);
+
+			/* enable autoneg */
+			bnx2x_set_autoneg(phy, params, vars, enable_cl73);
+
+			/* enable and restart AN */
+			bnx2x_restart_autoneg(phy, params, enable_cl73);
+		}
+
+	} else { /* SGMII mode */
+		DP(NETIF_MSG_LINK, "SGMII\n");
+
+		bnx2x_initialize_sgmii_process(phy, params, vars);
+	}
+}
+
 static u8 bnx2x_init_serdes(struct bnx2x_phy *phy,
 			    struct link_params *params,
 			    struct link_vars *vars)
@@ -2058,16 +2102,845 @@ static u8 bnx2x_init_xgxs(struct bnx2x_phy *phy,
 	return rc;
 }
 
+static u16 bnx2x_wait_reset_complete(struct bnx2x *bp,
+				     struct bnx2x_phy *phy)
+{
+	u16 cnt, ctrl;
+	/* Wait for soft reset to get cleared upto 1 sec */
+	for (cnt = 0; cnt < 1000; cnt++) {
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, &ctrl);
+		if (!(ctrl & (1<<15)))
+			break;
+		msleep(1);
+	}
+	DP(NETIF_MSG_LINK, "control reg 0x%x (after %d ms)\n", ctrl, cnt);
+	return cnt;
+}
+
+static void bnx2x_link_int_enable(struct link_params *params)
+{
+	u8 port = params->port;
+	u32 mask;
+	struct bnx2x *bp = params->bp;
+
+	/* setting the status to report on link up
+	   for either XGXS or SerDes */
+
+	if (params->switch_cfg == SWITCH_CFG_10G) {
+		mask = (NIG_MASK_XGXS0_LINK10G |
+			NIG_MASK_XGXS0_LINK_STATUS);
+		DP(NETIF_MSG_LINK, "enabled XGXS interrupt\n");
+		if (!(SINGLE_MEDIA_DIRECT(params)) &&
+			params->phy[INT_PHY].type !=
+				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) {
+			mask |= NIG_MASK_MI_INT;
+			DP(NETIF_MSG_LINK, "enabled external phy int\n");
+		}
+
+	} else { /* SerDes */
+		mask = NIG_MASK_SERDES0_LINK_STATUS;
+		DP(NETIF_MSG_LINK, "enabled SerDes interrupt\n");
+		if (!(SINGLE_MEDIA_DIRECT(params)) &&
+			params->phy[INT_PHY].type !=
+				PORT_HW_CFG_SERDES_EXT_PHY_TYPE_NOT_CONN) {
+			mask |= NIG_MASK_MI_INT;
+			DP(NETIF_MSG_LINK, "enabled external phy int\n");
+		}
+	}
+	bnx2x_bits_en(bp,
+		      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
+		      mask);
+
+	DP(NETIF_MSG_LINK, "port %x, is_xgxs %x, int_status 0x%x\n", port,
+		 (params->switch_cfg == SWITCH_CFG_10G),
+		 REG_RD(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4));
+	DP(NETIF_MSG_LINK, " int_mask 0x%x, MI_INT %x, SERDES_LINK %x\n",
+		 REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4),
+		 REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT + port*0x18),
+		 REG_RD(bp, NIG_REG_SERDES0_STATUS_LINK_STATUS+port*0x3c));
+	DP(NETIF_MSG_LINK, " 10G %x, XGXS_LINK %x\n",
+	   REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK10G + port*0x68),
+	   REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK_STATUS + port*0x68));
+}
+
+static void bnx2x_8481_rearm_latch_signal(struct bnx2x *bp, u8 port,
+					  u8 is_mi_int)
+{
+	u32 latch_status = 0, is_mi_int_status;
+	/* Disable the MI INT ( external phy int )
+	 * by writing 1 to the status register. Link down indication
+	 * is high-active-signal, so in this case we need to write the
+	 * status to clear the XOR
+	 */
+	/* Read Latched signals */
+	latch_status = REG_RD(bp,
+				  NIG_REG_LATCH_STATUS_0 + port*8);
+	is_mi_int_status = REG_RD(bp,
+				  NIG_REG_STATUS_INTERRUPT_PORT0 + port*4);
+	DP(NETIF_MSG_LINK, "original_signal = 0x%x, nig_status = 0x%x,"
+		     "latch_status = 0x%x\n",
+		 is_mi_int, is_mi_int_status, latch_status);
+	/* Handle only those with latched-signal=up.*/
+	if (latch_status & 1) {
+		/* For all latched-signal=up,Write original_signal to status */
+		if (is_mi_int)
+			bnx2x_bits_en(bp,
+				    NIG_REG_STATUS_INTERRUPT_PORT0
+				    + port*4,
+				    NIG_STATUS_EMAC0_MI_INT);
+		else
+			bnx2x_bits_dis(bp,
+				     NIG_REG_STATUS_INTERRUPT_PORT0
+				     + port*4,
+				     NIG_STATUS_EMAC0_MI_INT);
+		/* For all latched-signal=up : Re-Arm Latch signals */
+		REG_WR(bp, NIG_REG_LATCH_STATUS_0 + port*8,
+			   (latch_status & 0xfffe) | (latch_status & 1));
+	}
+}
+
+static void bnx2x_link_int_ack(struct link_params *params,
+			     struct link_vars *vars, u8 is_10g,
+			     u8 is_mi_int)
+{
+	struct bnx2x *bp = params->bp;
+	u8 port = params->port;
+
+	/* first reset all status
+	 * we assume only one line will be change at a time */
+	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
+		     (NIG_STATUS_XGXS0_LINK10G |
+		      NIG_STATUS_XGXS0_LINK_STATUS |
+		      NIG_STATUS_SERDES0_LINK_STATUS));
+	if ((params->phy[EXT_PHY1].type
+		== PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481) ||
+	(params->phy[EXT_PHY1].type
+		== PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823)) {
+		bnx2x_8481_rearm_latch_signal(bp, port, is_mi_int);
+	}
+	if (vars->phy_link_up) {
+		if (is_10g) {
+			/* Disable the 10G link interrupt
+			 * by writing 1 to the status register
+			 */
+			DP(NETIF_MSG_LINK, "10G XGXS phy link up\n");
+			bnx2x_bits_en(bp,
+				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
+				      NIG_STATUS_XGXS0_LINK10G);
+
+		} else if (params->switch_cfg == SWITCH_CFG_10G) {
+			/* Disable the link interrupt
+			 * by writing 1 to the relevant lane
+			 * in the status register
+			 */
+			u32 ser_lane = ((params->lane_config &
+				    PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
+				    PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
+
+			DP(NETIF_MSG_LINK, "%d speed XGXS phy link up\n",
+				 vars->line_speed);
+			bnx2x_bits_en(bp,
+				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
+				      ((1 << ser_lane) <<
+				       NIG_STATUS_XGXS0_LINK_STATUS_SIZE));
+
+		} else { /* SerDes */
+			DP(NETIF_MSG_LINK, "SerDes phy link up\n");
+			/* Disable the link interrupt
+			 * by writing 1 to the status register
+			 */
+			bnx2x_bits_en(bp,
+				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
+				      NIG_STATUS_SERDES0_LINK_STATUS);
+		}
+
+	}
+}
+
+static u8 bnx2x_format_ver(u32 num, u8 *str, u16 *len)
+{
+	u8 *str_ptr = str;
+	u32 mask = 0xf0000000;
+	u8 shift = 8*4;
+	u8 digit;
+	if (*len < 10) {
+		/* Need more than 10chars for this format */
+		*str_ptr = '\0';
+		return -EINVAL;
+	}
+	while (shift > 0) {
+
+		shift -= 4;
+		digit = ((num & mask) >> shift);
+		if (digit < 0xa)
+			*str_ptr = digit + '0';
+		else
+			*str_ptr = digit - 0xa + 'a';
+		str_ptr++;
+		mask = mask >> 4;
+		if (shift == 4*4) {
+			*str_ptr = ':';
+			str_ptr++;
+		}
+	}
+	*str_ptr = '\0';
+	return 0;
+}
+
+static u8 bnx2x_null_format_ver(u32 spirom_ver, u8 *str, u16 *len)
+{
+	str[0] = '\0';
+	(*len)--;
+	return 0;
+}
+
+u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
+			      u8 *version, u16 len)
+{
+	struct bnx2x *bp;
+	u32 spirom_ver = 0;
+	u8 status = 0;
+	u8 *ver_p = version;
+	if (version == NULL || params == NULL)
+		return -EINVAL;
+	bp = params->bp;
+
+	/* Extract first external phy*/
+	version[0] = '\0';
+	spirom_ver = REG_RD(bp, params->phy[EXT_PHY1].ver_addr);
+
+	if (params->phy[EXT_PHY1].format_fw_ver)
+		status |= params->phy[EXT_PHY1].format_fw_ver(spirom_ver,
+							      ver_p,
+							      &len);
+	return status;
+}
+
+static void bnx2x_set_xgxs_loopback(struct bnx2x_phy *phy,
+				    struct link_params *params)
+{
+	u8 port = params->port;
+	struct bnx2x *bp = params->bp;
+
+	if (phy->req_line_speed != SPEED_1000) {
+		u32 md_devad;
+
+		DP(NETIF_MSG_LINK, "XGXS 10G loopback enable\n");
+
+		/* change the uni_phy_addr in the nig */
+		md_devad = REG_RD(bp, (NIG_REG_XGXS0_CTRL_MD_DEVAD +
+					  port*0x18));
+
+		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18, 0x5);
+
+		bnx2x_cl45_write(bp, phy,
+			       5,
+			       (MDIO_REG_BANK_AER_BLOCK +
+				(MDIO_AER_BLOCK_AER_REG & 0xf)),
+			       0x2800);
+
+		bnx2x_cl45_write(bp, phy,
+			       5,
+			       (MDIO_REG_BANK_CL73_IEEEB0 +
+				(MDIO_CL73_IEEEB0_CL73_AN_CONTROL & 0xf)),
+			       0x6041);
+		msleep(200);
+		/* set aer mmd back */
+		bnx2x_set_aer_mmd(params, phy);
+
+		/* and md_devad */
+		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18,
+			    md_devad);
+
+	} else {
+		u16 mii_ctrl;
+		DP(NETIF_MSG_LINK, "XGXS 1G loopback enable\n");
+		bnx2x_cl45_read(bp, phy, 5,
+				(MDIO_REG_BANK_COMBO_IEEE0 +
+				(MDIO_COMBO_IEEE0_MII_CONTROL & 0xf)),
+				&mii_ctrl);
+		bnx2x_cl45_write(bp, phy, 5,
+				 (MDIO_REG_BANK_COMBO_IEEE0 +
+				 (MDIO_COMBO_IEEE0_MII_CONTROL & 0xf)),
+				 mii_ctrl |
+				 MDIO_COMBO_IEEO_MII_CONTROL_LOOPBACK);
+	}
+}
+
+/*
+ *------------------------------------------------------------------------
+ * bnx2x_override_led_value -
+ *
+ * Override the led value of the requested led
+ *
+ *------------------------------------------------------------------------
+ */
+u8 bnx2x_override_led_value(struct bnx2x *bp, u8 port,
+			  u32 led_idx, u32 value)
+{
+	u32 reg_val;
+
+	/* If port 0 then use EMAC0, else use EMAC1*/
+	u32 emac_base = (port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+
+	DP(NETIF_MSG_LINK,
+		 "bnx2x_override_led_value() port %x led_idx %d value %d\n",
+		 port, led_idx, value);
+
+	switch (led_idx) {
+	case 0: /* 10MB led */
+		/* Read the current value of the LED register in
+		the EMAC block */
+		reg_val = REG_RD(bp, emac_base + EMAC_REG_EMAC_LED);
+		/* Set the OVERRIDE bit to 1 */
+		reg_val |= EMAC_LED_OVERRIDE;
+		/* If value is 1, set the 10M_OVERRIDE bit,
+		otherwise reset it.*/
+		reg_val = (value == 1) ? (reg_val | EMAC_LED_10MB_OVERRIDE) :
+			(reg_val & ~EMAC_LED_10MB_OVERRIDE);
+		REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
+		break;
+	case 1: /*100MB led    */
+		/*Read the current value of the LED register in
+		the EMAC block */
+		reg_val = REG_RD(bp, emac_base + EMAC_REG_EMAC_LED);
+		/*  Set the OVERRIDE bit to 1 */
+		reg_val |= EMAC_LED_OVERRIDE;
+		/*  If value is 1, set the 100M_OVERRIDE bit,
+		otherwise reset it.*/
+		reg_val = (value == 1) ? (reg_val | EMAC_LED_100MB_OVERRIDE) :
+			(reg_val & ~EMAC_LED_100MB_OVERRIDE);
+		REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
+		break;
+	case 2: /* 1000MB led */
+		/* Read the current value of the LED register in the
+		EMAC block */
+		reg_val = REG_RD(bp, emac_base + EMAC_REG_EMAC_LED);
+		/* Set the OVERRIDE bit to 1 */
+		reg_val |= EMAC_LED_OVERRIDE;
+		/* If value is 1, set the 1000M_OVERRIDE bit, otherwise
+		reset it. */
+		reg_val = (value == 1) ? (reg_val | EMAC_LED_1000MB_OVERRIDE) :
+			(reg_val & ~EMAC_LED_1000MB_OVERRIDE);
+		REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
+		break;
+	case 3: /* 2500MB led */
+		/*  Read the current value of the LED register in the
+		EMAC block*/
+		reg_val = REG_RD(bp, emac_base + EMAC_REG_EMAC_LED);
+		/* Set the OVERRIDE bit to 1 */
+		reg_val |= EMAC_LED_OVERRIDE;
+		/*  If value is 1, set the 2500M_OVERRIDE bit, otherwise
+		reset it.*/
+		reg_val = (value == 1) ? (reg_val | EMAC_LED_2500MB_OVERRIDE) :
+			(reg_val & ~EMAC_LED_2500MB_OVERRIDE);
+		REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
+		break;
+	case 4: /*10G led */
+		if (port == 0) {
+			REG_WR(bp, NIG_REG_LED_10G_P0,
+				    value);
+		} else {
+			REG_WR(bp, NIG_REG_LED_10G_P1,
+				    value);
+		}
+		break;
+	case 5: /* TRAFFIC led */
+		/* Find if the traffic control is via BMAC or EMAC */
+		if (port == 0)
+			reg_val = REG_RD(bp, NIG_REG_NIG_EMAC0_EN);
+		else
+			reg_val = REG_RD(bp, NIG_REG_NIG_EMAC1_EN);
+
+		/*  Override the traffic led in the EMAC:*/
+		if (reg_val == 1) {
+			/* Read the current value of the LED register in
+			the EMAC block */
+			reg_val = REG_RD(bp, emac_base +
+					     EMAC_REG_EMAC_LED);
+			/* Set the TRAFFIC_OVERRIDE bit to 1 */
+			reg_val |= EMAC_LED_OVERRIDE;
+			/* If value is 1, set the TRAFFIC bit, otherwise
+			reset it.*/
+			reg_val = (value == 1) ? (reg_val | EMAC_LED_TRAFFIC) :
+				(reg_val & ~EMAC_LED_TRAFFIC);
+			REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
+		} else { /* Override the traffic led in the BMAC: */
+			REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0
+				   + port*4, 1);
+			REG_WR(bp, NIG_REG_LED_CONTROL_TRAFFIC_P0 + port*4,
+				    value);
+		}
+		break;
+	default:
+		DP(NETIF_MSG_LINK,
+			 "bnx2x_override_led_value() unknown led index %d "
+			 "(should be 0-5)\n", led_idx);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+u8 bnx2x_set_led(struct link_params *params, u8 mode, u32 speed)
+{
+	u8 port = params->port;
+	u16 hw_led_mode = params->hw_led_mode;
+	u8 rc = 0;
+	u32 tmp;
+	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
+	struct bnx2x *bp = params->bp;
+	DP(NETIF_MSG_LINK, "bnx2x_set_led: port %x, mode %d\n", port, mode);
+	DP(NETIF_MSG_LINK, "speed 0x%x, hw_led_mode 0x%x\n",
+		 speed, hw_led_mode);
+	switch (mode) {
+	case LED_MODE_OFF:
+		REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 0);
+		REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
+			   SHARED_HW_CFG_LED_MAC1);
+
+		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
+		EMAC_WR(bp, EMAC_REG_EMAC_LED, (tmp | EMAC_LED_OVERRIDE));
+		break;
+
+	case LED_MODE_OPER:
+		if (SINGLE_MEDIA_DIRECT(params)) {
+			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
+			REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 1);
+		} else {
+			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
+				   hw_led_mode);
+		}
+
+		REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0 +
+			   port*4, 0);
+		/* Set blinking rate to ~15.9Hz */
+		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_P0 + port*4,
+			   LED_BLINK_RATE_VAL);
+		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_ENA_P0 +
+			   port*4, 1);
+		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
+		EMAC_WR(bp, EMAC_REG_EMAC_LED,
+			    (tmp & (~EMAC_LED_OVERRIDE)));
+
+		if (CHIP_IS_E1(bp) &&
+		    ((speed == SPEED_2500) ||
+		     (speed == SPEED_1000) ||
+		     (speed == SPEED_100) ||
+		     (speed == SPEED_10))) {
+			/* On Everest 1 Ax chip versions for speeds less than
+			10G LED scheme is different */
+			REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0
+				   + port*4, 1);
+			REG_WR(bp, NIG_REG_LED_CONTROL_TRAFFIC_P0 +
+				   port*4, 0);
+			REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_TRAFFIC_P0 +
+				   port*4, 1);
+		}
+		break;
+
+	default:
+		rc = -EINVAL;
+		DP(NETIF_MSG_LINK, "bnx2x_set_led: Invalid led mode %d\n",
+			 mode);
+		break;
+	}
+	return rc;
+
+}
+
+u8 bnx2x_test_link(struct link_params *params, struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u16 gp_status = 0, phy_index = 0;
+
+	CL45_RD_OVER_CL22(bp, &params->phy[INT_PHY],
+			      MDIO_REG_BANK_GP_STATUS,
+			      MDIO_GP_STATUS_TOP_AN_STATUS1,
+			      &gp_status);
+	/* link is up only if both local phy and external phy are up */
+	if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) {
+		u8 ext_phy_link_up = 1;
+		struct link_vars temp_vars;
+		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
+		      phy_index++) {
+			if (params->phy[phy_index].read_status)
+				ext_phy_link_up &=
+					params->phy[phy_index].read_status(
+						&params->phy[phy_index],
+						params, &temp_vars);
+		}
+		if (ext_phy_link_up)
+			return 0;
+	}
+	return -ESRCH;
+}
+
+static u8 bnx2x_link_initialize(struct link_params *params,
+				struct link_vars *vars)
+{
+	u8 rc = 0;
+	u8 phy_index, non_ext_phy;
+	struct bnx2x *bp = params->bp;
+	/**
+	* In case of external phy existence, the line speed would be the
+	* line speed linked up by the external phy. In case it is direct
+	* only, then the line_speed during initialization will be
+	* equal to the req_line_speed
+	*/
+	vars->line_speed = params->phy[INT_PHY].req_line_speed;
+
+	/**
+	 * Initialize the internal phy in case this is a direct board
+	 * (no external phys), or this board has external phy which requires
+	 * to first.
+	 */
+
+	if (params->phy[INT_PHY].config_init)
+		params->phy[INT_PHY].config_init(
+			&params->phy[INT_PHY],
+			params, vars);
+
+	/* init ext phy and enable link state int */
+	non_ext_phy = (SINGLE_MEDIA_DIRECT(params) ||
+		       (params->loopback_mode == LOOPBACK_XGXS));
+
+	if (non_ext_phy ||
+	    (params->phy[EXT_PHY1].flags & FLAGS_INIT_XGXS_FIRST) ||
+	    (params->loopback_mode == LOOPBACK_EXT_PHY)) {
+		struct bnx2x_phy *phy = &params->phy[INT_PHY];
+		if (vars->line_speed == SPEED_AUTO_NEG)
+			bnx2x_set_parallel_detection(phy, params);
+		bnx2x_init_internal_phy(phy, params, vars);
+	}
+
+	/* Init external phy*/
+	if (!non_ext_phy)
+		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
+		      phy_index++) {
+			params->phy[phy_index].config_init(
+				&params->phy[phy_index],
+				params, vars);
+		}
+
+	/* Reset the interrupt indication after phy was initialized */
+	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 +
+		       params->port*4,
+		       (NIG_STATUS_XGXS0_LINK10G |
+			NIG_STATUS_XGXS0_LINK_STATUS |
+			NIG_STATUS_SERDES0_LINK_STATUS |
+			NIG_MASK_MI_INT));
+	return rc;
+}
+
+static void bnx2x_int_link_reset(struct bnx2x_phy *phy,
+				 struct link_params *params)
+{
+	/* reset the SerDes/XGXS */
+	REG_WR(params->bp, GRCBASE_MISC +
+		     MISC_REGISTERS_RESET_REG_3_CLEAR,
+		     (0x1ff << (params->port*16)));
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
+static u8 bnx2x_update_link_down(struct link_params *params,
+			       struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u8 port = params->port;
+
+	DP(NETIF_MSG_LINK, "Port %x: Link is down\n", port);
+	bnx2x_set_led(params, LED_MODE_OFF, 0);
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
+	/* disable emac */
+	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
+
+	msleep(10);
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
+			     u8 link_10g)
+{
+	struct bnx2x *bp = params->bp;
+	u8 port = params->port;
+	u8 rc = 0;
+
+	vars->link_status |= LINK_STATUS_LINK_UP;
+	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
+		vars->link_status |=
+			LINK_STATUS_TX_FLOW_CONTROL_ENABLED;
+
+	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_RX)
+		vars->link_status |=
+			LINK_STATUS_RX_FLOW_CONTROL_ENABLED;
+	if (link_10g) {
+		bnx2x_bmac_enable(params, vars, 0);
+		bnx2x_set_led(params, LED_MODE_OPER, SPEED_10000);
+	} else {
+		rc = bnx2x_emac_program(params, vars);
+
+		bnx2x_emac_enable(params, vars, 0);
+
+		/* AN complete? */
+		if ((vars->link_status & LINK_STATUS_AUTO_NEGOTIATE_COMPLETE)
+		    && (!(vars->phy_flags & PHY_SGMII_FLAG)) &&
+		    SINGLE_MEDIA_DIRECT(params))
+			bnx2x_set_gmii_tx_driver(params);
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
+	msleep(20);
+	return rc;
+}
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
+ */
+u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	struct link_vars phy_vars[MAX_PHYS];
+	u8 port = params->port;
+	u8 link_10g, phy_index;
+	u8 ext_phy_link_up = 0, cur_link_up, rc = 0;
+	u8 is_mi_int = 0;
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
+
+	DP(NETIF_MSG_LINK, "port %x, XGXS?%x, int_status 0x%x\n",
+		 port, (vars->phy_flags & PHY_XGXS_FLAG),
+		 REG_RD(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4));
+
+	is_mi_int = (u8)(REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT +
+				    port*0x18) > 0);
+	DP(NETIF_MSG_LINK, "int_mask 0x%x MI_INT %x, SERDES_LINK %x\n",
+		 REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4),
+		 is_mi_int,
+		 REG_RD(bp,
+			    NIG_REG_SERDES0_STATUS_LINK_STATUS + port*0x3c));
+
+	DP(NETIF_MSG_LINK, " 10G %x, XGXS_LINK %x\n",
+	  REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK10G + port*0x68),
+	  REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK_STATUS + port*0x68));
+
+	/* disable emac */
+	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
+
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
+
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
+
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
+
+	/* anything 10 and over uses the bmac */
+	link_10g = ((vars->line_speed == SPEED_10000) ||
+		    (vars->line_speed == SPEED_12000) ||
+		    (vars->line_speed == SPEED_12500) ||
+		    (vars->line_speed == SPEED_13000) ||
+		    (vars->line_speed == SPEED_15000) ||
+		    (vars->line_speed == SPEED_16000));
+
+	bnx2x_link_int_ack(params, vars, link_10g, is_mi_int);
+
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
+
+	if (vars->link_up)
+		rc = bnx2x_update_link_up(params, vars, link_10g);
+	else
+		rc = bnx2x_update_link_down(params, vars);
+
+	return rc;
+}
+
+
 /*****************************************************************************/
 /*			    External Phy section			     */
 /*****************************************************************************/
 void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port)
 {
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-		       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
+			    MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
 	msleep(1);
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, port);
+			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, port);
 }
 
 static void bnx2x_save_spirom_version(struct bnx2x *bp, u8 port,
@@ -2094,59 +2967,211 @@ static void bnx2x_save_bcm_spirom_ver(struct bnx2x *bp,
 				  phy->ver_addr);
 }
 
-static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
-					   struct link_params *params)
+static void bnx2x_ext_phy_set_pause(struct link_params *params,
+				    struct bnx2x_phy *phy,
+				    struct link_vars *vars)
 {
-	u16 val, fw_ver1, fw_ver2, cnt;
+	u16 val;
 	struct bnx2x *bp = params->bp;
+	/* read modify write pause advertizing */
+	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV_PAUSE, &val);
 
-	/* For the 32 bits registers in 848xx, access via MDIO2ARM interface.*/
-	/* (1) set register 0xc200_0014(SPI_BRIDGE_CTRL_2) to 0x03000000 */
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819, 0x0014);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A, 0xc200);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81B, 0x0000);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81C, 0x0300);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817, 0x0009);
+	val &= ~MDIO_AN_REG_ADV_PAUSE_BOTH;
 
-	for (cnt = 0; cnt < 100; cnt++) {
-		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818, &val);
-		if (val & 1)
-			break;
-		udelay(5);
+	/* Please refer to Table 28B-3 of 802.3ab-1999 spec. */
+	bnx2x_calc_ieee_aneg_adv(phy, params, &vars->ieee_fc);
+	if ((vars->ieee_fc &
+	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) ==
+	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) {
+		val |=  MDIO_AN_REG_ADV_PAUSE_ASYMMETRIC;
 	}
-	if (cnt == 100) {
-		DP(NETIF_MSG_LINK, "Unable to read 848xx phy fw version(1)\n");
-		bnx2x_save_spirom_version(bp, params->port, 0,
-					  phy->ver_addr);
+	if ((vars->ieee_fc &
+	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) ==
+	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) {
+		val |= MDIO_AN_REG_ADV_PAUSE_PAUSE;
+	}
+	DP(NETIF_MSG_LINK, "Ext phy AN advertize 0x%x\n", val);
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV_PAUSE, val);
+}
+
+static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
+				   struct link_params *params,
+				   struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u16 ld_pause;		/* local */
+	u16 lp_pause;		/* link partner */
+	u16 pause_result;
+	u8 ret = 0;
+	/* read twice */
+
+	vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+
+	if (phy->req_flow_ctrl != BNX2X_FLOW_CTRL_AUTO)
+		vars->flow_ctrl = phy->req_flow_ctrl;
+	else if (phy->req_line_speed != SPEED_AUTO_NEG)
+		vars->flow_ctrl = params->req_fc_auto_adv;
+	else if (vars->link_status & LINK_STATUS_AUTO_NEGOTIATE_COMPLETE) {
+		ret = 1;
+		bnx2x_cl45_read(bp, phy,
+			      MDIO_AN_DEVAD,
+			      MDIO_AN_REG_ADV_PAUSE, &ld_pause);
+		bnx2x_cl45_read(bp, phy,
+			      MDIO_AN_DEVAD,
+			      MDIO_AN_REG_LP_AUTO_NEG, &lp_pause);
+		pause_result = (ld_pause &
+				MDIO_AN_REG_ADV_PAUSE_MASK) >> 8;
+		pause_result |= (lp_pause &
+				 MDIO_AN_REG_ADV_PAUSE_MASK) >> 10;
+		DP(NETIF_MSG_LINK, "Ext PHY pause result 0x%x\n",
+		   pause_result);
+		bnx2x_pause_resolve(vars, pause_result);
+	}
+	return ret;
+}
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
+
+/******************************************************************/
+/*		common BCM8073/BCM8727 PHY SECTION		  */
+/******************************************************************/
+static void bnx2x_8073_resolve_fc(struct bnx2x_phy *phy,
+				  struct link_params *params,
+				  struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	if (phy->req_line_speed == SPEED_10 ||
+	    phy->req_line_speed == SPEED_100) {
+		vars->flow_ctrl = phy->req_flow_ctrl;
 		return;
 	}
 
+	if (bnx2x_ext_phy_resolve_fc(phy, params, vars) &&
+	    (vars->flow_ctrl == BNX2X_FLOW_CTRL_NONE)) {
+		u16 pause_result;
+		u16 ld_pause;		/* local */
+		u16 lp_pause;		/* link partner */
+		bnx2x_cl45_read(bp, phy,
+				MDIO_AN_DEVAD,
+				MDIO_AN_REG_CL37_FC_LD, &ld_pause);
 
-	/* 2) read register 0xc200_0000 (SPI_FW_STATUS) */
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819, 0x0000);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A, 0xc200);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817, 0x000A);
-	for (cnt = 0; cnt < 100; cnt++) {
-		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818, &val);
-		if (val & 1)
-			break;
-		udelay(5);
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
 	}
-	if (cnt == 100) {
-		DP(NETIF_MSG_LINK, "Unable to read 848xx phy fw version(2)\n");
-		bnx2x_save_spirom_version(bp, params->port, 0,
-					  phy->ver_addr);
+}
+
+static void bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
+					      struct bnx2x_phy *phy,
+					      u8 port)
+{
+	/* Boot port from external ROM  */
+	/* EDC grst */
+	bnx2x_cl45_write(bp, phy,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_GEN_CTRL,
+		       0x0001);
+
+	/* ucode reboot and rst */
+	bnx2x_cl45_write(bp, phy,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_GEN_CTRL,
+		       0x008c);
+
+	bnx2x_cl45_write(bp, phy,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_MISC_CTRL1, 0x0001);
+
+	/* Reset internal microprocessor */
+	bnx2x_cl45_write(bp, phy,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_GEN_CTRL,
+		       MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
+
+	/* Release srst bit */
+	bnx2x_cl45_write(bp, phy,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_GEN_CTRL,
+		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
+
+	/* wait for 120ms for code download via SPI port */
+	msleep(120);
+
+	/* Clear ser_boot_ctl bit */
+	bnx2x_cl45_write(bp, phy,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
+	bnx2x_save_bcm_spirom_ver(bp, phy, port);
+}
+
+static void bnx2x_8073_set_xaui_low_power_mode(struct bnx2x *bp,
+					       struct bnx2x_phy *phy)
+{
+	u16 val;
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_8073_CHIP_REV, &val);
+
+	if (val == 0) {
+		/* Mustn't set low power mode in 8073 A0 */
 		return;
 	}
 
-	/* lower 16 bits of the register SPI_FW_STATUS */
-	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81B, &fw_ver1);
-	/* upper 16 bits of register SPI_FW_STATUS */
-	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81C, &fw_ver2);
+	/* Disable PLL sequencer (use read-modify-write to clear bit 13) */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, &val);
+	val &= ~(1<<13);
+	bnx2x_cl45_write(bp, phy,
+		       MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, val);
 
-	bnx2x_save_spirom_version(bp, params->port, (fw_ver2<<16) | fw_ver1,
-				  phy->ver_addr);
+	/* PLL controls */
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805E, 0x1077);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805D, 0x0000);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805C, 0x030B);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805B, 0x1240);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805A, 0x2490);
+
+	/* Tx Controls */
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80A7, 0x0C74);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80A6, 0x9041);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80A5, 0x4640);
+
+	/* Rx Controls */
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80FE, 0x01C4);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80FD, 0x9249);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80FC, 0x2015);
+
+	/* Enable PLL sequencer  (use read-modify-write to set bit 13) */
+	bnx2x_cl45_read(bp, phy, MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, &val);
+	val |= (1<<13);
+	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, val);
 }
+
+/******************************************************************/
+/*			BCM8073 PHY SECTION			  */
+/******************************************************************/
 static u8 bnx2x_8073_is_snr_needed(struct bnx2x *bp, struct bnx2x_phy *phy)
 {
 	/* This is only required for 8073A1, version 102 only */
@@ -2172,6 +3197,7 @@ static u8 bnx2x_8073_is_snr_needed(struct bnx2x *bp, struct bnx2x_phy *phy)
 
 	return 1;
 }
+
 static u8 bnx2x_8073_xaui_wa(struct bnx2x *bp, struct bnx2x_phy *phy)
 {
 	u16 val, cnt, cnt1 ;
@@ -2225,87 +3251,374 @@ static u8 bnx2x_8073_xaui_wa(struct bnx2x *bp, struct bnx2x_phy *phy)
 	return -EINVAL;
 }
 
-static void bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
-					      struct bnx2x_phy *phy,
-					      u8 port)
+static void bnx2x_807x_force_10G(struct bnx2x *bp, struct bnx2x_phy *phy)
 {
-	/* Boot port from external ROM  */
-	/* EDC grst */
+	/* Force KR or KX */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       0x0001);
-
-	/* ucode reboot and rst */
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x2040);
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       0x008c);
-
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_10G_CTRL2, 0x000b);
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_MISC_CTRL1, 0x0001);
-
-	/* Reset internal microprocessor */
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_BCM_CTRL, 0x0000);
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
+			 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0x0000);
+}
 
-	/* Release srst bit */
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
+static void bnx2x_8073_set_pause_cl37(struct link_params *params,
+				      struct bnx2x_phy *phy,
+				      struct link_vars *vars)
+{
+	u16 cl37_val;
+	struct bnx2x *bp = params->bp;
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD, &cl37_val);
 
-	/* wait for 120ms for code download via SPI port */
-	msleep(120);
+	cl37_val &= ~MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
+	/* Please refer to Table 28B-3 of 802.3ab-1999 spec. */
+	bnx2x_calc_ieee_aneg_adv(phy, params, &vars->ieee_fc);
+	if ((vars->ieee_fc &
+	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_SYMMETRIC) ==
+	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_SYMMETRIC) {
+		cl37_val |=  MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_SYMMETRIC;
+	}
+	if ((vars->ieee_fc &
+	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) ==
+	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) {
+		cl37_val |=  MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
+	}
+	if ((vars->ieee_fc &
+	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) ==
+	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) {
+		cl37_val |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
+	}
+	DP(NETIF_MSG_LINK,
+		 "Ext phy AN advertize cl37 0x%x\n", cl37_val);
 
-	/* Clear ser_boot_ctl bit */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
-	bnx2x_save_bcm_spirom_ver(bp, phy, port);
+			 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD, cl37_val);
+	msleep(500);
 }
 
-static void bnx2x_8726_external_rom_boot(struct bnx2x_phy *phy,
-					 struct link_params *params)
+static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	/* Need to wait 100ms after reset */
-	msleep(100);
+	u16 val = 0, tmp1;
+	u8 gpio_port;
+	DP(NETIF_MSG_LINK, "Init 8073\n");
 
-	/* Micro controller re-boot */
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_GEN_CTRL, 0x018B);
+	gpio_port = params->port;
+	/* Restore normal power mode*/
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
 
-	/* Set soft reset */
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
+			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
 
+	/* enable LASI */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_MISC_CTRL1, 0x0001);
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM_CTRL, (1<<2));
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL,  0x0004);
+
+	bnx2x_8073_set_pause_cl37(params, phy, vars);
+
+	bnx2x_8073_set_xaui_low_power_mode(bp, phy);
+
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_M8051_MSGOUT_REG, &tmp1);
 
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM, &tmp1);
+
+	DP(NETIF_MSG_LINK, "Before rom RX_ALARM(port1): 0x%x\n", tmp1);
+
+	/* Enable CL37 BAM */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD,
+			MDIO_AN_REG_8073_BAM, &val);
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_GEN_CTRL,
-		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
+			 MDIO_AN_DEVAD,
+			 MDIO_AN_REG_8073_BAM, val | 1);
 
-	/* wait for 150ms for microcode load */
-	msleep(150);
+	if (params->loopback_mode == LOOPBACK_EXT) {
+		bnx2x_807x_force_10G(bp, phy);
+		DP(NETIF_MSG_LINK, "Forced speed 10G on 807X\n");
+		return 0;
+	} else {
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_BCM_CTRL, 0x0002);
+	}
+	if (phy->req_line_speed != SPEED_AUTO_NEG) {
+		if (phy->req_line_speed == SPEED_10000) {
+			val = (1<<7);
+		} else if (phy->req_line_speed ==  SPEED_2500) {
+			val = (1<<5);
+			/* Note that 2.5G works only
+			when used with 1G advertisment */
+		} else
+			val = (1<<5);
+	} else {
+		val = 0;
+		if (phy->speed_cap_mask &
+			PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
+			val |= (1<<7);
+
+		/* Note that 2.5G works only when
+		used with 1G advertisment */
+		if (phy->speed_cap_mask &
+			(PORT_HW_CFG_SPEED_CAPABILITY_D0_1G |
+			 PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G))
+			val |= (1<<5);
+		DP(NETIF_MSG_LINK, "807x autoneg val = 0x%x\n", val);
+	}
+
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV, val);
+	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_8073_2_5G, &tmp1);
+
+	if (((phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G) &&
+	     (phy->req_line_speed == SPEED_AUTO_NEG)) ||
+	    (phy->req_line_speed == SPEED_2500)) {
+		u16 phy_ver;
+		/* Allow 2.5G for A1 and above */
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD, MDIO_PMA_REG_8073_CHIP_REV,
+				&phy_ver);
+		DP(NETIF_MSG_LINK, "Add 2.5G\n");
+		if (phy_ver > 0)
+			tmp1 |= 1;
+		else
+			tmp1 &= 0xfffe;
+	} else {
+		DP(NETIF_MSG_LINK, "Disable 2.5G\n");
+		tmp1 &= 0xfffe;
+	}
+
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_8073_2_5G, tmp1);
+	/* Add support for CL37 (passive mode) II */
+
+	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD, &tmp1);
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD,
+			 (tmp1 | ((phy->req_duplex == DUPLEX_FULL) ?
+				  0x20 : 0x40)));
+
+	/* Add support for CL37 (passive mode) III */
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x1000);
+
+	/* The SNR will improve about 2db by changing
+	BW and FEE main tap. Rest commands are executed
+	after link is up*/
+	if (bnx2x_8073_is_snr_needed(bp, phy))
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_EDC_FFE_MAIN,
+				 0xFB0C);
+
+	/* Enable FEC (Forware Error Correction) Request in the AN */
+	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV2, &tmp1);
+	tmp1 |= (1<<15);
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV2, tmp1);
+
+	bnx2x_ext_phy_set_pause(params, phy, vars);
+
+	/* Restart autoneg */
+	msleep(500);
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0x1200);
+	DP(NETIF_MSG_LINK, "807x Autoneg Restart: Advertise 1G=%x, 10G=%x\n",
+		   ((val & (1<<5)) > 0), ((val & (1<<7)) > 0));
+	return 0;
+}
+
+static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u8 link_up = 0;
+	u16 val1, val2;
+	u16 link_status = 0;
+	u16 an1000_status = 0;
+
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val1);
+
+	DP(NETIF_MSG_LINK, "8703 LASI status 0x%x\n", val1);
+
+	/* clear the interrupt LASI status register */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &val2);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "807x PCS status 0x%x->0x%x\n", val2, val1);
+	/* Clear MSG-OUT */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_M8051_MSGOUT_REG, &val1);
+
+	/* Check the LASI */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM, &val2);
+
+	DP(NETIF_MSG_LINK, "KR 0x9003 0x%x\n", val2);
+
+	/* Check the link status */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &val2);
+	DP(NETIF_MSG_LINK, "KR PCS status 0x%x\n", val2);
+
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val2);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val1);
+	link_up = ((val1 & 4) == 4);
+	DP(NETIF_MSG_LINK, "PMA_REG_STATUS=0x%x\n", val1);
+
+	if (link_up &&
+	     ((phy->req_line_speed != SPEED_10000))) {
+		if (bnx2x_8073_xaui_wa(bp, phy) != 0)
+			return 0;
+	}
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS, &an1000_status);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS, &an1000_status);
+
+	/* Check the link status on 1.1.2 */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val2);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "KR PMA status 0x%x->0x%x,"
+		   "an_link_status=0x%x\n", val2, val1, an1000_status);
+
+	link_up = (((val1 & 4) == 4) || (an1000_status & (1<<1)));
+	if (link_up && bnx2x_8073_is_snr_needed(bp, phy)) {
+		/* The SNR will improve about 2dbby
+		changing the BW and FEE main tap.*/
+		/* The 1st write to change FFE main
+		tap is set before restart AN */
+		/* Change PLL Bandwidth in EDC
+		register */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_PLL_BANDWIDTH,
+				 0x26BC);
+
+		/* Change CDR Bandwidth in EDC register */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_CDR_BANDWIDTH,
+				 0x0333);
+	}
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
+			&link_status);
+
+	/* Bits 0..2 --> speed detected, bits 13..15--> link is down */
+	if ((link_status & (1<<2)) && (!(link_status & (1<<15)))) {
+		link_up = 1;
+		vars->line_speed = SPEED_10000;
+		DP(NETIF_MSG_LINK, "port %x: External link up in 10G\n",
+			   params->port);
+	} else if ((link_status & (1<<1)) && (!(link_status & (1<<14)))) {
+		link_up = 1;
+		vars->line_speed = SPEED_2500;
+		DP(NETIF_MSG_LINK, "port %x: External link up in 2.5G\n",
+			   params->port);
+	} else if ((link_status & (1<<0)) && (!(link_status & (1<<13)))) {
+		link_up = 1;
+		vars->line_speed = SPEED_1000;
+		DP(NETIF_MSG_LINK, "port %x: External link up in 1G\n",
+			   params->port);
+	} else {
+		link_up = 0;
+		DP(NETIF_MSG_LINK, "port %x: External link is down\n",
+			   params->port);
+	}
+
+	if (link_up) {
+		bnx2x_ext_phy_10G_an_resolve(bp, phy, vars);
+		bnx2x_8073_resolve_fc(phy, params, vars);
+	}
+	return link_up;
+}
+
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
+
+/******************************************************************/
+/*			BCM8705 PHY SECTION			  */
+/******************************************************************/
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
 
-	/* Disable serial boot control, tristates pins SS_N, SCK, MOSI, MISO */
 	bnx2x_cl45_write(bp, phy,
-		       MDIO_PMA_DEVAD,
-		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_MISC_CTRL, 0x8288);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, 0x7fbf);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_CMU_PLL_BYPASS, 0x0100);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_WIS_DEVAD, MDIO_WIS_REG_LASI_CNTL, 0x1);
+	/* BCM8705 doesn't have microcode, hence the 0 */
+	bnx2x_save_spirom_version(bp, params->port, params->shmem_base, 0);
+	return 0;
+}
 
-	msleep(200);
-	bnx2x_save_bcm_spirom_ver(bp, phy, params->port);
+static u8 bnx2x_8705_read_status(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	u8 link_up = 0;
+	u16 val1, rx_sd;
+	struct bnx2x *bp = params->bp;
+	DP(NETIF_MSG_LINK, "read status 8705\n");
+	bnx2x_cl45_read(bp, phy,
+		      MDIO_WIS_DEVAD, MDIO_WIS_REG_LASI_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
+
+	bnx2x_cl45_read(bp, phy,
+		      MDIO_WIS_DEVAD, MDIO_WIS_REG_LASI_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
+
+	bnx2x_cl45_read(bp, phy,
+		      MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_SD, &rx_sd);
+
+	bnx2x_cl45_read(bp, phy,
+		      MDIO_PMA_DEVAD, 0xc809, &val1);
+	bnx2x_cl45_read(bp, phy,
+		      MDIO_PMA_DEVAD, 0xc809, &val1);
+
+	DP(NETIF_MSG_LINK, "8705 1.c809 val=0x%x\n", val1);
+	link_up = ((rx_sd & 0x1) && (val1 & (1<<9)) && ((val1 & (1<<8)) == 0));
+	if (link_up) {
+		vars->line_speed = SPEED_10000;
+		bnx2x_ext_phy_resolve_fc(phy, params, vars);
+	}
+	return link_up;
 }
 
+/******************************************************************/
+/*			SFP+ module Section			  */
+/******************************************************************/
 static void bnx2x_sfp_set_transmitter(struct bnx2x *bp,
 				      struct bnx2x_phy *phy,
 				      u8 port,
@@ -2392,7 +3705,7 @@ static u8 bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 			      MDIO_PMA_REG_SFP_TWO_WIRE_CTRL, &val);
 		if ((val & MDIO_PMA_REG_SFP_TWO_WIRE_CTRL_STATUS_MASK) ==
 		    MDIO_PMA_REG_SFP_TWO_WIRE_STATUS_IDLE)
-			return 0;
+			return 0;;
 		msleep(1);
 	}
 	return -EINVAL;
@@ -2637,6 +3950,64 @@ static u8 bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 	return -EINVAL;
 }
 
+static u8 bnx2x_wait_for_sfp_module_initialized(struct bnx2x_phy *phy,
+						struct link_params *params)
+
+{
+	u8 val;
+	struct bnx2x *bp = params->bp;
+	u16 timeout;
+	/* Initialization time after hot-plug may take up to 300ms for some
+	phys type ( e.g. JDSU ) */
+	for (timeout = 0; timeout < 60; timeout++) {
+		if (bnx2x_read_sfp_module_eeprom(phy, params, 1, 1, &val)
+		    == 0) {
+			DP(NETIF_MSG_LINK, "SFP+ module initialization "
+				     "took %d ms\n", timeout * 5);
+			return 0;
+		}
+		msleep(5);
+	}
+	return -EINVAL;
+}
+
+static void bnx2x_8727_power_module(struct bnx2x *bp,
+				    struct bnx2x_phy *phy,
+				    u8 is_power_up) {
+	/* Make sure GPIOs are not using for LED mode */
+	u16 val;
+	/*
+	 * In the GPIO register, bit 4 is use to detemine if the GPIOs are
+	 * operating as INPUT or as OUTPUT. Bit 1 is for input, and 0 for
+	 * output
+	 * Bits 0-1 determine the gpios value for OUTPUT in case bit 4 val is 0
+	 * Bits 8-9 determine the gpios value for INPUT in case bit 4 val is 1
+	 * where the 1st bit is the over-current(only input), and 2nd bit is
+	 * for power( only output )
+	*/
+
+	/*
+	 * In case of NOC feature is disabled and power is up, set GPIO control
+	 *  as input to enable listening of over-current indication
+	 */
+	if (phy->flags & FLAGS_NOC)
+		return;
+	if (!(phy->flags &
+	      FLAGS_NOC) && is_power_up)
+		val = (1<<4);
+	else
+		/*
+		 * Set GPIO control to OUTPUT, and set the power bit
+		 * to according to the is_power_up
+		 */
+		val = ((!(is_power_up)) << 1);
+
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8727_GPIO_CTRL,
+			 val);
+}
+
 static u8 bnx2x_8726_set_limiting_mode(struct bnx2x *bp,
 				       struct bnx2x_phy *phy,
 				       u16 edc_mode)
@@ -2721,65 +4092,6 @@ static u8 bnx2x_8727_set_limiting_mode(struct bnx2x *bp,
 	return 0;
 }
 
-
-static u8 bnx2x_wait_for_sfp_module_initialized(struct bnx2x_phy *phy,
-						struct link_params *params)
-
-{
-	u8 val;
-	struct bnx2x *bp = params->bp;
-	u16 timeout;
-	/* Initialization time after hot-plug may take up to 300ms for some
-	phys type ( e.g. JDSU ) */
-	for (timeout = 0; timeout < 60; timeout++) {
-		if (bnx2x_read_sfp_module_eeprom(phy, params, 1, 1, &val)
-		    == 0) {
-			DP(NETIF_MSG_LINK, "SFP+ module initialization "
-				     "took %d ms\n", timeout * 5);
-			return 0;
-		}
-		msleep(5);
-	}
-	return -EINVAL;
-}
-
-static void bnx2x_8727_power_module(struct bnx2x *bp,
-				    struct bnx2x_phy *phy,
-				    u8 is_power_up) {
-	/* Make sure GPIOs are not using for LED mode */
-	u16 val;
-	/*
-	 * In the GPIO register, bit 4 is use to detemine if the GPIOs are
-	 * operating as INPUT or as OUTPUT. Bit 1 is for input, and 0 for
-	 * output
-	 * Bits 0-1 determine the gpios value for OUTPUT in case bit 4 val is 0
-	 * Bits 8-9 determine the gpios value for INPUT in case bit 4 val is 1
-	 * where the 1st bit is the over-current(only input), and 2nd bit is
-	 * for power( only output )
-	*/
-
-	/*
-	 * In case of NOC feature is disabled and power is up, set GPIO control
-	 *  as input to enable listening of over-current indication
-	 */
-	if (phy->flags & FLAGS_NOC)
-		return;
-	if (!(phy->flags &
-	      FLAGS_NOC) && is_power_up)
-		val = (1<<4);
-	else
-		/*
-		 * Set GPIO control to OUTPUT, and set the power bit
-		 * to according to the is_power_up
-		 */
-		val = ((!(is_power_up)) << 1);
-
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD,
-			 MDIO_PMA_REG_8727_GPIO_CTRL,
-			 val);
-}
-
 static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 				     struct link_params *params)
 {
@@ -2889,276 +4201,56 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 	}
 }
 
-static void bnx2x_807x_force_10G(struct bnx2x *bp, struct bnx2x_phy *phy)
-{
-	/* Force KR or KX */
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x2040);
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_10G_CTRL2, 0x000b);
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_BCM_CTRL, 0x0000);
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0x0000);
-}
-
-static void bnx2x_8073_set_xaui_low_power_mode(struct bnx2x *bp,
-					       struct bnx2x_phy *phy)
-{
-	u16 val;
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_8073_CHIP_REV, &val);
-
-	if (val == 0) {
-		/* Mustn't set low power mode in 8073 A0 */
-		return;
-	}
-
-	/* Disable PLL sequencer (use read-modify-write to clear bit 13) */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, &val);
-	val &= ~(1<<13);
-	bnx2x_cl45_write(bp, phy,
-		       MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, val);
-
-	/* PLL controls */
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805E, 0x1077);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805D, 0x0000);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805C, 0x030B);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805B, 0x1240);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x805A, 0x2490);
-
-	/* Tx Controls */
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80A7, 0x0C74);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80A6, 0x9041);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80A5, 0x4640);
-
-	/* Rx Controls */
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80FE, 0x01C4);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80FD, 0x9249);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, 0x80FC, 0x2015);
-
-	/* Enable PLL sequencer  (use read-modify-write to set bit 13) */
-	bnx2x_cl45_read(bp, phy, MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, &val);
-	val |= (1<<13);
-	bnx2x_cl45_write(bp, phy, MDIO_XS_DEVAD, MDIO_XS_PLL_SEQUENCER, val);
-}
-
-static void bnx2x_8073_set_pause_cl37(struct link_params *params,
-				      struct bnx2x_phy *phy,
+/******************************************************************/
+/*		common BCM8706/BCM8726 PHY SECTION		  */
+/******************************************************************/
+static u8 bnx2x_8706_8726_read_status(struct bnx2x_phy *phy,
+				      struct link_params *params,
 				      struct link_vars *vars)
 {
-	u16 cl37_val;
+	u8 link_up = 0;
+	u16 val1, val2, rx_sd, pcs_status;
 	struct bnx2x *bp = params->bp;
+	DP(NETIF_MSG_LINK, "XGXS 8706/8726\n");
+	/* Clear RX Alarm*/
 	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD, &cl37_val);
-
-	cl37_val &= ~MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
-	/* Please refer to Table 28B-3 of 802.3ab-1999 spec. */
-	bnx2x_calc_ieee_aneg_adv(phy, params, &vars->ieee_fc);
-	if ((vars->ieee_fc &
-	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_SYMMETRIC) ==
-	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_SYMMETRIC) {
-		cl37_val |=  MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_SYMMETRIC;
-	}
-	if ((vars->ieee_fc &
-	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) ==
-	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) {
-		cl37_val |=  MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
-	}
-	if ((vars->ieee_fc &
-	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) ==
-	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) {
-		cl37_val |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
-	}
-	DP(NETIF_MSG_LINK,
-		 "Ext phy AN advertize cl37 0x%x\n", cl37_val);
-
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD, cl37_val);
-	msleep(500);
-}
-
-static void bnx2x_ext_phy_set_pause(struct link_params *params,
-				    struct bnx2x_phy *phy,
-				    struct link_vars *vars)
-{
-	u16 val;
-	struct bnx2x *bp = params->bp;
-	/* read modify write pause advertizing */
-	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV_PAUSE, &val);
-
-	val &= ~MDIO_AN_REG_ADV_PAUSE_BOTH;
-
-	/* Please refer to Table 28B-3 of 802.3ab-1999 spec. */
-	bnx2x_calc_ieee_aneg_adv(phy, params, &vars->ieee_fc);
-	if ((vars->ieee_fc &
-	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) ==
-	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC) {
-		val |=  MDIO_AN_REG_ADV_PAUSE_ASYMMETRIC;
-	}
-	if ((vars->ieee_fc &
-	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) ==
-	    MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) {
-		val |= MDIO_AN_REG_ADV_PAUSE_PAUSE;
-	}
-	DP(NETIF_MSG_LINK, "Ext phy AN advertize 0x%x\n", val);
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV_PAUSE, val);
-}
-
-static void bnx2x_set_preemphasis(struct bnx2x_phy *phy,
-				  struct link_params *params)
-{
-
-	u16 bank, i = 0;
-	struct bnx2x *bp = params->bp;
-
-	for (bank = MDIO_REG_BANK_RX0, i = 0; bank <= MDIO_REG_BANK_RX3;
-	      bank += (MDIO_REG_BANK_RX1-MDIO_REG_BANK_RX0), i++) {
-			CL45_WR_OVER_CL22(bp, phy,
-					  bank,
-					  MDIO_RX0_RX_EQ_BOOST,
-					  phy->rx_preemphasis[i]);
-	}
-
-	for (bank = MDIO_REG_BANK_TX0, i = 0; bank <= MDIO_REG_BANK_TX3;
-		      bank += (MDIO_REG_BANK_TX1 - MDIO_REG_BANK_TX0), i++) {
-			CL45_WR_OVER_CL22(bp, phy,
-					  bank,
-					  MDIO_TX0_TX_DRIVER,
-					  phy->tx_preemphasis[i]);
-	}
-}
-
-static void bnx2x_848xx_set_led(struct bnx2x *bp,
-				struct bnx2x_phy *phy)
-{
-	u16 val;
-
-	/* PHYC_CTL_LED_CTL */
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM, &val2);
+	/* clear LASI indication*/
 	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD,
-			MDIO_PMA_REG_8481_LINK_SIGNAL, &val);
-	val &= 0xFE00;
-	val |= 0x0092;
-
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD,
-			 MDIO_PMA_REG_8481_LINK_SIGNAL, val);
-
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD,
-			 MDIO_PMA_REG_8481_LED1_MASK,
-			 0x80);
-
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD,
-			 MDIO_PMA_REG_8481_LED2_MASK,
-			 0x18);
-
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD,
-			 MDIO_PMA_REG_8481_LED3_MASK,
-			 0x0040);
-
-	/* 'Interrupt Mask' */
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_AN_DEVAD,
-			 0xFFFB, 0xFFFD);
-}
-
-static void bnx2x_init_internal_phy(struct bnx2x_phy *phy,
-				    struct link_params *params,
-				    struct link_vars *vars)
-{
-	struct bnx2x *bp = params->bp;
-	u8 enable_cl73 = (SINGLE_MEDIA_DIRECT(params) ||
-			  (params->loopback_mode == LOOPBACK_XGXS_10));
-	if (!(vars->phy_flags & PHY_SGMII_FLAG)) {
-		if (SINGLE_MEDIA_DIRECT(params) &&
-		    (params->feature_config_flags &
-		     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED))
-			bnx2x_set_preemphasis(phy, params);
-
-		/* forced speed requested? */
-		if (vars->line_speed != SPEED_AUTO_NEG ||
-		    (SINGLE_MEDIA_DIRECT(params) &&
-			  params->loopback_mode == LOOPBACK_EXT)) {
-			DP(NETIF_MSG_LINK, "not SGMII, no AN\n");
-
-			/* disable autoneg */
-			bnx2x_set_autoneg(phy, params, vars, 0);
-
-			/* program speed and duplex */
-			bnx2x_program_serdes(phy, params, vars);
-
-		} else { /* AN_mode */
-			DP(NETIF_MSG_LINK, "not SGMII, AN\n");
-
-			/* AN enabled */
-			bnx2x_set_brcm_cl37_advertisment(phy, params);
-
-			/* program duplex & pause advertisement (for aneg) */
-			bnx2x_set_ieee_aneg_advertisment(phy, params,
-						       vars->ieee_fc);
-
-			/* enable autoneg */
-			bnx2x_set_autoneg(phy, params, vars, enable_cl73);
-
-			/* enable and restart AN */
-			bnx2x_restart_autoneg(phy, params, enable_cl73);
-		}
-
-	} else { /* SGMII mode */
-		DP(NETIF_MSG_LINK, "SGMII\n");
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val1);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val2);
+	DP(NETIF_MSG_LINK, "8706/8726 LASI status 0x%x--> 0x%x\n", val1, val2);
 
-		bnx2x_initialize_sgmii_process(phy, params, vars);
-	}
-}
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_SD, &rx_sd);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &pcs_status);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS, &val2);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS, &val2);
 
-static u16 bnx2x_wait_reset_complete(struct bnx2x *bp,
-				     struct bnx2x_phy *phy)
-{
-	u16 cnt, ctrl;
-	/* Wait for soft reset to get cleared upto 1 sec */
-	for (cnt = 0; cnt < 1000; cnt++) {
-		bnx2x_cl45_read(bp, phy,
-				MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, &ctrl);
-		if (!(ctrl & (1<<15)))
-			break;
-		msleep(1);
+	DP(NETIF_MSG_LINK, "8706/8726 rx_sd 0x%x pcs_status 0x%x 1Gbps"
+			" link_status 0x%x\n", rx_sd, pcs_status, val2);
+	/* link is up if both bit 0 of pmd_rx_sd and
+	 * bit 0 of pcs_status are set, or if the autoneg bit
+	 * 1 is set
+	 */
+	link_up = ((rx_sd & pcs_status & 0x1) || (val2 & (1<<1)));
+	if (link_up) {
+		if (val2 & (1<<1))
+			vars->line_speed = SPEED_1000;
+		else
+			vars->line_speed = SPEED_10000;
+		bnx2x_ext_phy_resolve_fc(phy, params, vars);
 	}
-	DP(NETIF_MSG_LINK, "control reg 0x%x (after %d ms)\n", ctrl, cnt);
-	return cnt;
-}
-
-static u8 bnx2x_8705_config_init(struct bnx2x_phy *phy,
-				 struct link_params *params,
-				 struct link_vars *vars)
-{
-	struct bnx2x *bp = params->bp;
-	DP(NETIF_MSG_LINK, "init 8705\n");
-	/* Restore normal power mode*/
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
-	/* HW reset */
-	bnx2x_ext_phy_hw_reset(bp, params->port);
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0xa040);
-	bnx2x_wait_reset_complete(bp, phy);
-
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_MISC_CTRL, 0x8288);
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, 0x7fbf);
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_CMU_PLL_BYPASS, 0x0100);
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_WIS_DEVAD, MDIO_WIS_REG_LASI_CNTL, 0x1);
-	/* BCM8705 doesn't have microcode, hence the 0 */
-	bnx2x_save_spirom_version(bp, params->port, params->shmem_base, 0);
-	return 0;
+	return link_up;
 }
 
+/******************************************************************/
+/*			BCM8706 PHY SECTION			  */
+/******************************************************************/
 static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
@@ -3240,6 +4332,83 @@ static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
 	return 0;
 }
 
+static u8 bnx2x_8706_read_status(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
+{
+	return bnx2x_8706_8726_read_status(phy, params, vars);
+}
+
+/******************************************************************/
+/*			BCM8726 PHY SECTION			  */
+/******************************************************************/
+static void bnx2x_8726_config_loopback(struct bnx2x_phy *phy,
+				       struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	DP(NETIF_MSG_LINK, "PMA/PMD ext_phy_loopback: 8726\n");
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x0001);
+}
+
+static void bnx2x_8726_external_rom_boot(struct bnx2x_phy *phy,
+					 struct link_params *params)
+{
+	struct bnx2x *bp = params->bp;
+	/* Need to wait 100ms after reset */
+	msleep(100);
+
+	/* Micro controller re-boot */
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_GEN_CTRL, 0x018B);
+
+	/* Set soft reset */
+	bnx2x_cl45_write(bp, phy,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_GEN_CTRL,
+		       MDIO_PMA_REG_GEN_CTRL_ROM_MICRO_RESET);
+
+	bnx2x_cl45_write(bp, phy,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_MISC_CTRL1, 0x0001);
+
+	bnx2x_cl45_write(bp, phy,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_GEN_CTRL,
+		       MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
+
+	/* wait for 150ms for microcode load */
+	msleep(150);
+
+	/* Disable serial boot control, tristates pins SS_N, SCK, MOSI, MISO */
+	bnx2x_cl45_write(bp, phy,
+		       MDIO_PMA_DEVAD,
+		       MDIO_PMA_REG_MISC_CTRL1, 0x0000);
+
+	msleep(200);
+	bnx2x_save_bcm_spirom_ver(bp, phy, params->port);
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
+
+
 static u8 bnx2x_8726_config_init(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
@@ -3356,136 +4525,35 @@ static u8 bnx2x_8726_config_init(struct bnx2x_phy *phy,
 
 }
 
-static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
-				 struct link_params *params,
-				 struct link_vars *vars)
+static void bnx2x_8726_link_reset(struct bnx2x_phy *phy,
+				  struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
-	u16 val = 0, tmp1;
-	u8 gpio_port;
-	DP(NETIF_MSG_LINK, "Init 8073\n");
-
-	gpio_port = params->port;
-	/* Restore normal power mode*/
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
-
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
-
-	/* enable LASI */
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM_CTRL, (1<<2));
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL,  0x0004);
-
-	bnx2x_8073_set_pause_cl37(params, phy, vars);
-
-	bnx2x_8073_set_xaui_low_power_mode(bp, phy);
-
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_M8051_MSGOUT_REG, &tmp1);
-
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM, &tmp1);
-
-	DP(NETIF_MSG_LINK, "Before rom RX_ALARM(port1): 0x%x\n", tmp1);
-
-	/* Enable CL37 BAM */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD,
-			MDIO_AN_REG_8073_BAM, &val);
+	DP(NETIF_MSG_LINK, "bnx2x_8726_link_reset port %d\n", params->port);
+	/* Set serial boot control for external load */
 	bnx2x_cl45_write(bp, phy,
-			 MDIO_AN_DEVAD,
-			 MDIO_AN_REG_8073_BAM, val | 1);
-
-	if (params->loopback_mode == LOOPBACK_EXT) {
-		bnx2x_807x_force_10G(bp, phy);
-		DP(NETIF_MSG_LINK, "Forced speed 10G on 807X\n");
-		return 0;
-	} else {
-		bnx2x_cl45_write(bp, phy,
-				 MDIO_PMA_DEVAD, MDIO_PMA_REG_BCM_CTRL, 0x0002);
-	}
-	if (phy->req_line_speed != SPEED_AUTO_NEG) {
-		if (phy->req_line_speed == SPEED_10000) {
-			val = (1<<7);
-		} else if (phy->req_line_speed ==  SPEED_2500) {
-			val = (1<<5);
-			/* Note that 2.5G works only
-			when used with 1G advertisment */
-		} else
-			val = (1<<5);
-	} else {
-		val = 0;
-		if (phy->speed_cap_mask &
-			PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
-			val |= (1<<7);
-
-		/* Note that 2.5G works only when
-		used with 1G advertisment */
-		if (phy->speed_cap_mask &
-			(PORT_HW_CFG_SPEED_CAPABILITY_D0_1G |
-			 PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G))
-			val |= (1<<5);
-		DP(NETIF_MSG_LINK, "807x autoneg val = 0x%x\n", val);
-	}
-
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV, val);
-	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_8073_2_5G, &tmp1);
-
-	if (((phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G) &&
-	     (phy->req_line_speed == SPEED_AUTO_NEG)) ||
-	    (phy->req_line_speed == SPEED_2500)) {
-		u16 phy_ver;
-		/* Allow 2.5G for A1 and above */
-		bnx2x_cl45_read(bp, phy,
-				MDIO_PMA_DEVAD, MDIO_PMA_REG_8073_CHIP_REV,
-				&phy_ver);
-		DP(NETIF_MSG_LINK, "Add 2.5G\n");
-		if (phy_ver > 0)
-			tmp1 |= 1;
-		else
-			tmp1 &= 0xfffe;
-	} else {
-		DP(NETIF_MSG_LINK, "Disable 2.5G\n");
-		tmp1 &= 0xfffe;
-	}
-
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_8073_2_5G, tmp1);
-	/* Add support for CL37 (passive mode) II */
-
-	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD, &tmp1);
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CL37_FC_LD,
-			 (tmp1 | ((phy->req_duplex == DUPLEX_FULL) ?
-				  0x20 : 0x40)));
-
-	/* Add support for CL37 (passive mode) III */
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CL37_AN, 0x1000);
-
-	/* The SNR will improve about 2db by changing
-	BW and FEE main tap. Rest commands are executed
-	after link is up*/
-	if (bnx2x_8073_is_snr_needed(bp, phy))
-		bnx2x_cl45_write(bp, phy,
-				 MDIO_PMA_DEVAD, MDIO_PMA_REG_EDC_FFE_MAIN,
-				 0xFB0C);
-
-	/* Enable FEC (Forware Error Correction) Request in the AN */
-	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV2, &tmp1);
-	tmp1 |= (1<<15);
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV2, tmp1);
-
-	bnx2x_ext_phy_set_pause(params, phy, vars);
-
-	/* Restart autoneg */
-	msleep(500);
-	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, 0x1200);
-	DP(NETIF_MSG_LINK, "807x Autoneg Restart: Advertise 1G=%x, 10G=%x\n",
-		   ((val & (1<<5)) > 0), ((val & (1<<7)) > 0));
-	return 0;
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_GEN_CTRL, 0x0001);
 }
 
+/******************************************************************/
+/*			BCM8727 PHY SECTION			  */
+/******************************************************************/
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
 
 static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 				 struct link_params *params,
@@ -3586,7 +4654,6 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 				 0x0008);
 	}
 
-
 	/* Set 2-wire transfer rate of SFP+ module EEPROM
 	 * to 100Khz since some DACs(direct attached cables) do
 	 * not work at 400Khz.
@@ -3613,225 +4680,6 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 	return 0;
 }
 
-static u8 bnx2x_7101_config_init(struct bnx2x_phy *phy,
-				 struct link_params *params,
-				 struct link_vars *vars)
-{
-	u16 fw_ver1, fw_ver2, val;
-	struct bnx2x *bp = params->bp;
-	DP(NETIF_MSG_LINK, "Setting the SFX7101 LASI indication\n");
-
-	/* Restore normal power mode*/
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
-	/* HW reset */
-	bnx2x_ext_phy_hw_reset(bp, params->port);
-	bnx2x_wait_reset_complete(bp, phy);
-
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, 0x1);
-	DP(NETIF_MSG_LINK, "Setting the SFX7101 LED to blink on traffic\n");
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_7107_LED_CNTL, (1<<3));
-
-	bnx2x_ext_phy_set_pause(params, phy, vars);
-	/* Restart autoneg */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, &val);
-	val |= 0x200;
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, val);
-
-	/* Save spirom version */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_7101_VER1, &fw_ver1);
-
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_7101_VER2, &fw_ver2);
-	bnx2x_save_spirom_version(bp, params->port,
-				  (u32)(fw_ver1<<16 | fw_ver2), phy->ver_addr);
-	return 0;
-}
-
-static u8 bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
-				      struct link_params *params,
-				      struct link_vars *vars)
-{
-	struct bnx2x *bp = params->bp;
-	u16 autoneg_val, an_1000_val, an_10_100_val;
-	bnx2x_wait_reset_complete(bp, phy);
-	bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
-		      1 << NIG_LATCH_BC_ENABLE_MI_INT);
-
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x0000);
-	bnx2x_848xx_set_led(bp, phy);
-	/* set 1000 speed advertisement */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD, MDIO_AN_REG_8481_1000T_CTRL,
-			&an_1000_val);
-
-	bnx2x_ext_phy_set_pause(params, phy, vars);
-	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD,
-			MDIO_AN_REG_8481_LEGACY_AN_ADV,
-			&an_10_100_val);
-	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD, MDIO_AN_REG_8481_LEGACY_MII_CTRL,
-			&autoneg_val);
-	/* Disable forced speed */
-	autoneg_val &= ~((1<<6) | (1<<8) | (1<<9) | (1<<12) | (1<<13));
-	an_10_100_val &= ~((1<<5) | (1<<6) | (1<<7) | (1<<8));
-
-	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
-	     (phy->speed_cap_mask &
-	     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) ||
-	    (phy->req_line_speed == SPEED_1000)) {
-		an_1000_val |= (1<<8);
-		autoneg_val |= (1<<9 | 1<<12);
-		if (phy->req_duplex == DUPLEX_FULL)
-			an_1000_val |= (1<<9);
-		DP(NETIF_MSG_LINK, "Advertising 1G\n");
-	} else
-		an_1000_val &= ~((1<<8) | (1<<9));
-
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_AN_DEVAD, MDIO_AN_REG_8481_1000T_CTRL,
-			 an_1000_val);
-
-	/* set 10 speed advertisement */
-	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
-	     (phy->speed_cap_mask &
-	     (PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
-	      PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF)))) {
-		an_10_100_val |= (1<<7);
-		/* Enable autoneg and restart autoneg for legacy speeds */
-		autoneg_val |= (1<<9 | 1<<12);
-
-		if (phy->req_duplex == DUPLEX_FULL)
-			an_10_100_val |= (1<<8);
-		DP(NETIF_MSG_LINK, "Advertising 100M\n");
-	}
-	/* set 10 speed advertisement */
-	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
-	    (phy->speed_cap_mask &
-	  (PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL |
-	   PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF)))) {
-		an_10_100_val |= (1<<5);
-		autoneg_val |= (1<<9 | 1<<12);
-		if (phy->req_duplex == DUPLEX_FULL)
-			an_10_100_val |= (1<<6);
-		DP(NETIF_MSG_LINK, "Advertising 10M\n");
-	}
-
-	/* Only 10/100 are allowed to work in FORCE mode */
-	if (phy->req_line_speed == SPEED_100) {
-		autoneg_val |= (1<<13);
-		/* Enabled AUTO-MDIX when autoneg is disabled */
-		bnx2x_cl45_write(bp, phy,
-				 MDIO_AN_DEVAD, MDIO_AN_REG_8481_AUX_CTRL,
-				 (1<<15 | 1<<9 | 7<<0));
-		DP(NETIF_MSG_LINK, "Setting 100M force\n");
-	}
-	if (phy->req_line_speed == SPEED_10) {
-		/* Enabled AUTO-MDIX when autoneg is disabled */
-		bnx2x_cl45_write(bp, phy,
-				 MDIO_AN_DEVAD, MDIO_AN_REG_8481_AUX_CTRL,
-				 (1<<15 | 1<<9 | 7<<0));
-		DP(NETIF_MSG_LINK, "Setting 10M force\n");
-	}
-
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_AN_DEVAD, MDIO_AN_REG_8481_LEGACY_AN_ADV,
-			 an_10_100_val);
-
-	if (phy->req_duplex == DUPLEX_FULL)
-		autoneg_val |= (1<<8);
-
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_AN_DEVAD,
-			 MDIO_AN_REG_8481_LEGACY_MII_CTRL, autoneg_val);
-
-	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
-	    (phy->speed_cap_mask &
-	     PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) ||
-		(phy->req_line_speed == SPEED_10000)) {
-		DP(NETIF_MSG_LINK, "Advertising 10G\n");
-		/* Restart autoneg for 10G*/
-
-		bnx2x_cl45_write(bp, phy,
-				 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL,
-				 0x3200);
-	} else if (phy->req_line_speed != SPEED_10 &&
-		   phy->req_line_speed != SPEED_100) {
-		bnx2x_cl45_write(bp, phy,
-				 MDIO_AN_DEVAD,
-				 MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
-				 1);
-	}
-	/* Save spirom version */
-	bnx2x_save_848xx_spirom_version(phy, params);
-
-	return 0;
-}
-
-static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
-				  struct link_params *params,
-				  struct link_vars *vars)
-{
-	struct bnx2x *bp = params->bp;
-	u16 temp;
-	msleep(1);
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
-		       MISC_REGISTERS_GPIO_OUTPUT_HIGH,
-		       params->port);
-	msleep(200); /* 100 is not enough */
-
-	/**
-	 * BCM84823 requires that XGXS links up first @ 10G for normal
-	 * behavior
-	 */
-	temp = vars->line_speed;
-	vars->line_speed = SPEED_10000;
-	bnx2x_set_autoneg(phy, params, vars, 0);
-	bnx2x_program_serdes(phy, params, vars);
-	vars->line_speed = temp;
-	return bnx2x_848xx_cmn_config_init(phy, params, vars);
-}
-
-static u8 bnx2x_8481_config_init(struct bnx2x_phy *phy,
-				 struct link_params *params,
-				 struct link_vars *vars)
-{
-	struct bnx2x *bp = params->bp;
-	/* Restore normal power mode*/
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
-
-	/* HW reset */
-	bnx2x_ext_phy_hw_reset(bp, params->port);
-
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 1<<15);
-	return bnx2x_848xx_cmn_config_init(phy, params, vars);
-}
-
-
-static void bnx2x_ext_phy_10G_an_resolve(struct bnx2x *bp,
-				       struct bnx2x_phy *phy,
-				       struct link_vars *vars)
-{
-	u16 val;
-	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD,
-			MDIO_AN_REG_STATUS, &val);
-	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD,
-			MDIO_AN_REG_STATUS, &val);
-	if (val & (1<<5))
-		vars->link_status |= LINK_STATUS_AUTO_NEGOTIATE_COMPLETE;
-	if ((val & (1<<0)) == 0)
-		vars->link_status |= LINK_STATUS_PARALLEL_DETECTION_USED;
-}
 static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 				      struct link_params *params)
 {
@@ -3910,110 +4758,6 @@ static void bnx2x_8727_handle_mod_abs(struct bnx2x_phy *phy,
 	module plugged in/out */
 }
 
-
-static u8 bnx2x_8705_read_status(struct bnx2x_phy *phy,
-				 struct link_params *params,
-				 struct link_vars *vars)
-{
-	u8 link_up = 0;
-	u16 val1, rx_sd;
-	struct bnx2x *bp = params->bp;
-	DP(NETIF_MSG_LINK, "read status 8705\n");
-	bnx2x_cl45_read(bp, phy,
-		      MDIO_WIS_DEVAD, MDIO_WIS_REG_LASI_STATUS, &val1);
-	DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
-
-	bnx2x_cl45_read(bp, phy,
-		      MDIO_WIS_DEVAD, MDIO_WIS_REG_LASI_STATUS, &val1);
-	DP(NETIF_MSG_LINK, "8705 LASI status 0x%x\n", val1);
-
-	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_SD, &rx_sd);
-
-	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD, 0xc809, &val1);
-	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD, 0xc809, &val1);
-
-	DP(NETIF_MSG_LINK, "8705 1.c809 val=0x%x\n", val1);
-	link_up = ((rx_sd & 0x1) && (val1 & (1<<9)) && ((val1 & (1<<8)) == 0));
-	if (link_up) {
-		vars->line_speed = SPEED_10000;
-		bnx2x_ext_phy_resolve_fc(phy, params, vars);
-	}
-	return link_up;
-}
-
-static u8 bnx2x_8706_8726_read_status(struct bnx2x_phy *phy,
-				      struct link_params *params,
-				      struct link_vars *vars)
-{
-	u8 link_up = 0;
-	u16 val1, val2, rx_sd, pcs_status;
-	struct bnx2x *bp = params->bp;
-	DP(NETIF_MSG_LINK, "XGXS 8706/8726\n");
-	/* Clear RX Alarm*/
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM, &val2);
-	/* clear LASI indication*/
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val1);
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val2);
-	DP(NETIF_MSG_LINK, "8706/8726 LASI status 0x%x--> 0x%x\n", val1, val2);
-
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_SD, &rx_sd);
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &pcs_status);
-	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS, &val2);
-	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS, &val2);
-
-	DP(NETIF_MSG_LINK, "8706/8726 rx_sd 0x%x pcs_status 0x%x 1Gbps"
-			" link_status 0x%x\n", rx_sd, pcs_status, val2);
-	/* link is up if both bit 0 of pmd_rx_sd and
-	 * bit 0 of pcs_status are set, or if the autoneg bit
-	 * 1 is set
-	 */
-	link_up = ((rx_sd & pcs_status & 0x1) || (val2 & (1<<1)));
-	if (link_up) {
-		if (val2 & (1<<1))
-			vars->line_speed = SPEED_1000;
-		else
-			vars->line_speed = SPEED_10000;
-		bnx2x_ext_phy_resolve_fc(phy, params, vars);
-	}
-	return link_up;
-}
-static u8 bnx2x_8706_read_status(struct bnx2x_phy *phy,
-				 struct link_params *params,
-				 struct link_vars *vars)
-{
-	return bnx2x_8706_8726_read_status(phy, params, vars);
-}
-
-static u8 bnx2x_8726_read_status(struct bnx2x_phy *phy,
-				 struct link_params *params,
-				 struct link_vars *vars)
-{
-	struct bnx2x *bp = params->bp;
-	u16 val1;
-	u8 link_up = bnx2x_8706_8726_read_status(phy, params, vars);
-	if (link_up) {
-		bnx2x_cl45_read(bp, phy,
-				MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER,
-				&val1);
-		if (val1 & (1<<15)) {
-			DP(NETIF_MSG_LINK, "Tx is disabled\n");
-			link_up = 0;
-			vars->line_speed = 0;
-		}
-	}
-	return link_up;
-}
-
 static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
@@ -4126,184 +4870,275 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 	return link_up;
 }
 
-static void bnx2x_8073_resolve_fc(struct bnx2x_phy *phy,
-				  struct link_params *params,
-				  struct link_vars *vars)
+static void bnx2x_8727_link_reset(struct bnx2x_phy *phy,
+				  struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
-	if (phy->req_line_speed == SPEED_10 ||
-	    phy->req_line_speed == SPEED_100) {
-		vars->flow_ctrl = phy->req_flow_ctrl;
+	/* Disable Transmitter */
+	bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
+}
+
+/******************************************************************/
+/*		BCM8481/BCM84823/BCM84833 PHY SECTION	          */
+/******************************************************************/
+static void bnx2x_save_848xx_spirom_version(struct bnx2x_phy *phy,
+					   struct link_params *params)
+{
+	u16 val, fw_ver1, fw_ver2, cnt;
+	struct bnx2x *bp = params->bp;
+
+	/* For the 32 bits registers in 848xx, access via MDIO2ARM interface.*/
+	/* (1) set register 0xc200_0014(SPI_BRIDGE_CTRL_2) to 0x03000000 */
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819, 0x0014);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A, 0xc200);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81B, 0x0000);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81C, 0x0300);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817, 0x0009);
+
+	for (cnt = 0; cnt < 100; cnt++) {
+		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818, &val);
+		if (val & 1)
+			break;
+		udelay(5);
+	}
+	if (cnt == 100) {
+		DP(NETIF_MSG_LINK, "Unable to read 848xx phy fw version(1)\n");
+		bnx2x_save_spirom_version(bp, params->port, 0,
+					  phy->ver_addr);
 		return;
 	}
 
-	if (bnx2x_ext_phy_resolve_fc(phy, params, vars) &&
-	    (vars->flow_ctrl == BNX2X_FLOW_CTRL_NONE)) {
-		u16 pause_result;
-		u16 ld_pause;		/* local */
-		u16 lp_pause;		/* link partner */
-		bnx2x_cl45_read(bp, phy,
-				MDIO_AN_DEVAD,
-				MDIO_AN_REG_CL37_FC_LD, &ld_pause);
-
-		bnx2x_cl45_read(bp, phy,
-				MDIO_AN_DEVAD,
-				MDIO_AN_REG_CL37_FC_LP, &lp_pause);
-		pause_result = (ld_pause &
-				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) >> 5;
-		pause_result |= (lp_pause &
-				 MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH) >> 7;
 
-		bnx2x_pause_resolve(vars, pause_result);
-		DP(NETIF_MSG_LINK, "Ext PHY CL37 pause result 0x%x\n",
-			   pause_result);
+	/* 2) read register 0xc200_0000 (SPI_FW_STATUS) */
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA819, 0x0000);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA81A, 0xc200);
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, 0xA817, 0x000A);
+	for (cnt = 0; cnt < 100; cnt++) {
+		bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA818, &val);
+		if (val & 1)
+			break;
+		udelay(5);
+	}
+	if (cnt == 100) {
+		DP(NETIF_MSG_LINK, "Unable to read 848xx phy fw version(2)\n");
+		bnx2x_save_spirom_version(bp, params->port, 0,
+					  phy->ver_addr);
+		return;
 	}
+
+	/* lower 16 bits of the register SPI_FW_STATUS */
+	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81B, &fw_ver1);
+	/* upper 16 bits of register SPI_FW_STATUS */
+	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, 0xA81C, &fw_ver2);
+
+	bnx2x_save_spirom_version(bp, params->port, (fw_ver2<<16) | fw_ver1,
+				  phy->ver_addr);
 }
-static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
-				 struct link_params *params,
-				 struct link_vars *vars)
+
+static void bnx2x_848xx_set_led(struct bnx2x *bp,
+				struct bnx2x_phy *phy)
 {
-	struct bnx2x *bp = params->bp;
-	u8 link_up = 0;
-	u16 val1, val2;
-	u16 link_status = 0;
-	u16 an1000_status = 0;
+	u16 val;
 
+	/* PHYC_CTL_LED_CTL */
 	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val1);
+			MDIO_PMA_DEVAD,
+			MDIO_PMA_REG_8481_LINK_SIGNAL, &val);
+	val &= 0xFE00;
+	val |= 0x0092;
 
-	DP(NETIF_MSG_LINK, "8703 LASI status 0x%x\n", val1);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8481_LINK_SIGNAL, val);
 
-	/* clear the interrupt LASI status register */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &val2);
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &val1);
-	DP(NETIF_MSG_LINK, "807x PCS status 0x%x->0x%x\n", val2, val1);
-	/* Clear MSG-OUT */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_M8051_MSGOUT_REG, &val1);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8481_LED1_MASK,
+			 0x80);
 
-	/* Check the LASI */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM, &val2);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8481_LED2_MASK,
+			 0x18);
 
-	DP(NETIF_MSG_LINK, "KR 0x9003 0x%x\n", val2);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_8481_LED3_MASK,
+			 0x0040);
 
-	/* Check the link status */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &val2);
-	DP(NETIF_MSG_LINK, "KR PCS status 0x%x\n", val2);
+	/* 'Interrupt Mask' */
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_AN_DEVAD,
+			 0xFFFB, 0xFFFD);
+}
 
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val2);
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val1);
-	link_up = ((val1 & 4) == 4);
-	DP(NETIF_MSG_LINK, "PMA_REG_STATUS=0x%x\n", val1);
+static u8 bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
+				       struct link_params *params,
+				       struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u16 autoneg_val, an_1000_val, an_10_100_val;
+	/**
+	* This phy uses the NIG latch mechanism since link indication
+	* arrives through its LED4 and not via its LASI signal, so we
+	* get steady signal instead of clear on read
+	*/
+	bnx2x_wait_reset_complete(bp, phy);
+	bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
+		      1 << NIG_LATCH_BC_ENABLE_MI_INT);
 
-	if (link_up &&
-	     ((phy->req_line_speed != SPEED_10000))) {
-		if (bnx2x_8073_xaui_wa(bp, phy) != 0)
-			return 0;
-	}
-	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS, &an1000_status);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x0000);
+
+	bnx2x_848xx_set_led(bp, phy);
+
+	/* set 1000 speed advertisement */
 	bnx2x_cl45_read(bp, phy,
-			MDIO_AN_DEVAD, MDIO_AN_REG_LINK_STATUS, &an1000_status);
+			MDIO_AN_DEVAD, MDIO_AN_REG_8481_1000T_CTRL,
+			&an_1000_val);
 
-	/* Check the link status on 1.1.2 */
+	bnx2x_ext_phy_set_pause(params, phy, vars);
 	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val2);
+			MDIO_AN_DEVAD,
+			MDIO_AN_REG_8481_LEGACY_AN_ADV,
+			&an_10_100_val);
 	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val1);
-	DP(NETIF_MSG_LINK, "KR PMA status 0x%x->0x%x,"
-		   "an_link_status=0x%x\n", val2, val1, an1000_status);
+			MDIO_AN_DEVAD, MDIO_AN_REG_8481_LEGACY_MII_CTRL,
+			&autoneg_val);
+	/* Disable forced speed */
+	autoneg_val &= ~((1<<6) | (1<<8) | (1<<9) | (1<<12) | (1<<13));
+	an_10_100_val &= ~((1<<5) | (1<<6) | (1<<7) | (1<<8));
 
-	link_up = (((val1 & 4) == 4) || (an1000_status & (1<<1)));
-	if (link_up && bnx2x_8073_is_snr_needed(bp, phy)) {
-		/* The SNR will improve about 2dbby
-		changing the BW and FEE main tap.*/
-		/* The 1st write to change FFE main
-		tap is set before restart AN */
-		/* Change PLL Bandwidth in EDC
-		register */
-		bnx2x_cl45_write(bp, phy,
-				 MDIO_PMA_DEVAD, MDIO_PMA_REG_PLL_BANDWIDTH,
-				 0x26BC);
+	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
+	     (phy->speed_cap_mask &
+	     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) ||
+	    (phy->req_line_speed == SPEED_1000)) {
+		an_1000_val |= (1<<8);
+		autoneg_val |= (1<<9 | 1<<12);
+		if (phy->req_duplex == DUPLEX_FULL)
+			an_1000_val |= (1<<9);
+		DP(NETIF_MSG_LINK, "Advertising 1G\n");
+	} else
+		an_1000_val &= ~((1<<8) | (1<<9));
 
-		/* Change CDR Bandwidth in EDC register */
-		bnx2x_cl45_write(bp, phy,
-				 MDIO_PMA_DEVAD, MDIO_PMA_REG_CDR_BANDWIDTH,
-				 0x0333);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_AN_DEVAD, MDIO_AN_REG_8481_1000T_CTRL,
+			 an_1000_val);
+
+	/* set 10 speed advertisement */
+	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
+	     (phy->speed_cap_mask &
+	     (PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
+	      PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF)))) {
+		an_10_100_val |= (1<<7);
+		/* Enable autoneg and restart autoneg for legacy speeds */
+		autoneg_val |= (1<<9 | 1<<12);
+
+		if (phy->req_duplex == DUPLEX_FULL)
+			an_10_100_val |= (1<<8);
+		DP(NETIF_MSG_LINK, "Advertising 100M\n");
+	}
+	/* set 10 speed advertisement */
+	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
+	    (phy->speed_cap_mask &
+	  (PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL |
+	   PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF)))) {
+		an_10_100_val |= (1<<5);
+		autoneg_val |= (1<<9 | 1<<12);
+		if (phy->req_duplex == DUPLEX_FULL)
+			an_10_100_val |= (1<<6);
+		DP(NETIF_MSG_LINK, "Advertising 10M\n");
 	}
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_8073_SPEED_LINK_STATUS,
-			&link_status);
 
-	/* Bits 0..2 --> speed detected, bits 13..15--> link is down */
-	if ((link_status & (1<<2)) && (!(link_status & (1<<15)))) {
-		link_up = 1;
-		vars->line_speed = SPEED_10000;
-		DP(NETIF_MSG_LINK, "port %x: External link up in 10G\n",
-			   params->port);
-	} else if ((link_status & (1<<1)) && (!(link_status & (1<<14)))) {
-		link_up = 1;
-		vars->line_speed = SPEED_2500;
-		DP(NETIF_MSG_LINK, "port %x: External link up in 2.5G\n",
-			   params->port);
-	} else if ((link_status & (1<<0)) && (!(link_status & (1<<13)))) {
-		link_up = 1;
-		vars->line_speed = SPEED_1000;
-		DP(NETIF_MSG_LINK, "port %x: External link up in 1G\n",
-			   params->port);
-	} else {
-		link_up = 0;
-		DP(NETIF_MSG_LINK, "port %x: External link is down\n",
-			   params->port);
+	/* Only 10/100 are allowed to work in FORCE mode */
+	if (phy->req_line_speed == SPEED_100) {
+		autoneg_val |= (1<<13);
+		/* Enabled AUTO-MDIX when autoneg is disabled */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_8481_AUX_CTRL,
+				 (1<<15 | 1<<9 | 7<<0));
+		DP(NETIF_MSG_LINK, "Setting 100M force\n");
+	}
+	if (phy->req_line_speed == SPEED_10) {
+		/* Enabled AUTO-MDIX when autoneg is disabled */
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_8481_AUX_CTRL,
+				 (1<<15 | 1<<9 | 7<<0));
+		DP(NETIF_MSG_LINK, "Setting 10M force\n");
 	}
 
-	if (link_up) {
-		bnx2x_ext_phy_10G_an_resolve(bp, phy, vars);
-		bnx2x_8073_resolve_fc(phy, params, vars);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_AN_DEVAD, MDIO_AN_REG_8481_LEGACY_AN_ADV,
+			 an_10_100_val);
+
+	if (phy->req_duplex == DUPLEX_FULL)
+		autoneg_val |= (1<<8);
+
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_AN_DEVAD,
+			 MDIO_AN_REG_8481_LEGACY_MII_CTRL, autoneg_val);
+
+	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
+	    (phy->speed_cap_mask &
+	     PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) ||
+		(phy->req_line_speed == SPEED_10000)) {
+		DP(NETIF_MSG_LINK, "Advertising 10G\n");
+		/* Restart autoneg for 10G*/
+
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL,
+				 0x3200);
+	} else if (phy->req_line_speed != SPEED_10 &&
+		   phy->req_line_speed != SPEED_100) {
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_AN_DEVAD,
+				 MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
+				 1);
 	}
-	return link_up;
+	/* Save spirom version */
+	bnx2x_save_848xx_spirom_version(phy, params);
+
+	return 0;
 }
 
-static u8 bnx2x_7101_read_status(struct bnx2x_phy *phy,
+static u8 bnx2x_8481_config_init(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u8 link_up;
-	u16 val1, val2;
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val2);
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val1);
-	DP(NETIF_MSG_LINK, "10G-base-T LASI status 0x%x->0x%x\n",
-		   val2, val1);
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val2);
-	bnx2x_cl45_read(bp, phy,
-			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val1);
-	DP(NETIF_MSG_LINK, "10G-base-T PMA status 0x%x->0x%x\n",
-		   val2, val1);
-	link_up = ((val1 & 4) == 4);
-	/* if link is up
-	 * print the AN outcome of the SFX7101 PHY
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
+
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
 	 */
-	if (link_up) {
-		bnx2x_cl45_read(bp, phy,
-				MDIO_AN_DEVAD, MDIO_AN_REG_MASTER_STATUS,
-				&val2);
-		vars->line_speed = SPEED_10000;
-		DP(NETIF_MSG_LINK, "SFX7101 AN status 0x%x->Master=%x\n",
-			   val2, (val2 & (1<<14)));
-		bnx2x_ext_phy_10G_an_resolve(bp, phy, vars);
-		bnx2x_ext_phy_resolve_fc(phy, params, vars);
-	}
-	return link_up;
+	temp = vars->line_speed;
+	vars->line_speed = SPEED_10000;
+	bnx2x_set_autoneg(phy, params, vars, 0);
+	bnx2x_program_serdes(phy, params, vars);
+	vars->line_speed = temp;
+	return bnx2x_848xx_cmn_config_init(phy, params, vars);
 }
 
 static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
@@ -4364,7 +5199,6 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 			DP(NETIF_MSG_LINK, "Link is up in %dMbps,"
 				   " is_duplex_full= %d\n", vars->line_speed,
 				   (vars->duplex == DUPLEX_FULL));
-
 			/* Check legacy speed AN resolution */
 			bnx2x_cl45_read(bp, phy,
 					MDIO_AN_DEVAD,
@@ -4391,192 +5225,6 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 	return link_up;
 }
 
-static void bnx2x_link_int_enable(struct link_params *params)
-{
-	u8 port = params->port;
-	u32 mask;
-	struct bnx2x *bp = params->bp;
-
-	/* setting the status to report on link up
-	   for either XGXS or SerDes */
-
-	if (params->switch_cfg == SWITCH_CFG_10G) {
-		mask = (NIG_MASK_XGXS0_LINK10G |
-			NIG_MASK_XGXS0_LINK_STATUS);
-		DP(NETIF_MSG_LINK, "enabled XGXS interrupt\n");
-		if (!(SINGLE_MEDIA_DIRECT(params)) &&
-			params->phy[INT_PHY].type !=
-				PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) {
-			mask |= NIG_MASK_MI_INT;
-			DP(NETIF_MSG_LINK, "enabled external phy int\n");
-		}
-
-	} else { /* SerDes */
-		mask = NIG_MASK_SERDES0_LINK_STATUS;
-		DP(NETIF_MSG_LINK, "enabled SerDes interrupt\n");
-		if (!(SINGLE_MEDIA_DIRECT(params)) &&
-			params->phy[INT_PHY].type !=
-				PORT_HW_CFG_SERDES_EXT_PHY_TYPE_NOT_CONN) {
-			mask |= NIG_MASK_MI_INT;
-			DP(NETIF_MSG_LINK, "enabled external phy int\n");
-		}
-	}
-	bnx2x_bits_en(bp,
-		      NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
-		      mask);
-
-	DP(NETIF_MSG_LINK, "port %x, is_xgxs %x, int_status 0x%x\n", port,
-		 (params->switch_cfg == SWITCH_CFG_10G),
-		 REG_RD(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4));
-	DP(NETIF_MSG_LINK, " int_mask 0x%x, MI_INT %x, SERDES_LINK %x\n",
-		 REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4),
-		 REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT + port*0x18),
-		 REG_RD(bp, NIG_REG_SERDES0_STATUS_LINK_STATUS+port*0x3c));
-	DP(NETIF_MSG_LINK, " 10G %x, XGXS_LINK %x\n",
-	   REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK10G + port*0x68),
-	   REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK_STATUS + port*0x68));
-}
-
-static void bnx2x_8481_rearm_latch_signal(struct bnx2x *bp, u8 port,
-					u8 is_mi_int)
-{
-	u32 latch_status = 0, is_mi_int_status;
-	/* Disable the MI INT ( external phy int )
-	 * by writing 1 to the status register. Link down indication
-	 * is high-active-signal, so in this case we need to write the
-	 * status to clear the XOR
-	 */
-	/* Read Latched signals */
-	latch_status = REG_RD(bp,
-				  NIG_REG_LATCH_STATUS_0 + port*8);
-	is_mi_int_status = REG_RD(bp,
-				  NIG_REG_STATUS_INTERRUPT_PORT0 + port*4);
-	DP(NETIF_MSG_LINK, "original_signal = 0x%x, nig_status = 0x%x,"
-		     "latch_status = 0x%x\n",
-		 is_mi_int, is_mi_int_status, latch_status);
-	/* Handle only those with latched-signal=up.*/
-	if (latch_status & 1) {
-		/* For all latched-signal=up,Write original_signal to status */
-		if (is_mi_int)
-			bnx2x_bits_en(bp,
-				    NIG_REG_STATUS_INTERRUPT_PORT0
-				    + port*4,
-				    NIG_STATUS_EMAC0_MI_INT);
-		else
-			bnx2x_bits_dis(bp,
-				     NIG_REG_STATUS_INTERRUPT_PORT0
-				     + port*4,
-				     NIG_STATUS_EMAC0_MI_INT);
-		/* For all latched-signal=up : Re-Arm Latch signals */
-		REG_WR(bp, NIG_REG_LATCH_STATUS_0 + port*8,
-			   (latch_status & 0xfffe) | (latch_status & 1));
-	}
-}
-
-/*
- * link management
- */
-static void bnx2x_link_int_ack(struct link_params *params,
-			     struct link_vars *vars, u8 is_10g,
-			     u8 is_mi_int)
-{
-	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
-
-	/* first reset all status
-	 * we assume only one line will be change at a time */
-	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-		     (NIG_STATUS_XGXS0_LINK10G |
-		      NIG_STATUS_XGXS0_LINK_STATUS |
-		      NIG_STATUS_SERDES0_LINK_STATUS));
-	if ((params->phy[EXT_PHY1].type
-		== PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481) ||
-	(params->phy[EXT_PHY1].type
-		== PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823)) {
-		bnx2x_8481_rearm_latch_signal(bp, port, is_mi_int);
-	}
-	if (vars->phy_link_up) {
-		if (is_10g) {
-			/* Disable the 10G link interrupt
-			 * by writing 1 to the status register
-			 */
-			DP(NETIF_MSG_LINK, "10G XGXS phy link up\n");
-			bnx2x_bits_en(bp,
-				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-				      NIG_STATUS_XGXS0_LINK10G);
-
-		} else if (params->switch_cfg == SWITCH_CFG_10G) {
-			/* Disable the link interrupt
-			 * by writing 1 to the relevant lane
-			 * in the status register
-			 */
-			u32 ser_lane = ((params->lane_config &
-				    PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
-				    PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
-
-			DP(NETIF_MSG_LINK, "%d speed XGXS phy link up\n",
-				 vars->line_speed);
-			bnx2x_bits_en(bp,
-				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-				      ((1 << ser_lane) <<
-				       NIG_STATUS_XGXS0_LINK_STATUS_SIZE));
-
-		} else { /* SerDes */
-			DP(NETIF_MSG_LINK, "SerDes phy link up\n");
-			/* Disable the link interrupt
-			 * by writing 1 to the status register
-			 */
-			bnx2x_bits_en(bp,
-				      NIG_REG_STATUS_INTERRUPT_PORT0 + port*4,
-				      NIG_STATUS_SERDES0_LINK_STATUS);
-		}
-
-	}
-}
-
-static u8 bnx2x_7101_format_ver(u32 spirom_ver, u8 *str, u16 *len)
-{
-	if (*len < 5)
-		return -EINVAL;
-	str[0] = (spirom_ver & 0xFF);
-	str[1] = (spirom_ver & 0xFF00) >> 8;
-	str[2] = (spirom_ver & 0xFF0000) >> 16;
-	str[3] = (spirom_ver & 0xFF000000) >> 24;
-	str[4] = '\0';
-	*len -= 5;
-	return 0;
-}
-
-static u8 bnx2x_format_ver(u32 num, u8 *str, u16 *len)
-{
-	u8 *str_ptr = str;
-	u32 mask = 0xf0000000;
-	u8 shift = 8*4;
-	u8 digit;
-	if (*len < 10) {
-		/* Need more than 10chars for this format */
-		*str_ptr = '\0';
-		return -EINVAL;
-	}
-	while (shift > 0) {
-
-		shift -= 4;
-		digit = ((num & mask) >> shift);
-		if (digit < 0xa)
-			*str_ptr = digit + '0';
-		else
-			*str_ptr = digit - 0xa + 'a';
-		str_ptr++;
-		mask = mask >> 4;
-		if (shift == 4*4) {
-			*str_ptr = ':';
-			str_ptr++;
-		}
-	}
-	*str_ptr = '\0';
-	return 0;
-}
-
 static u8 bnx2x_848xx_format_ver(u32 raw_ver, u8 *str, u16 *len)
 {
 	u8 status = 0;
@@ -4586,603 +5234,15 @@ static u8 bnx2x_848xx_format_ver(u32 raw_ver, u8 *str, u16 *len)
 	return status;
 }
 
-static u8 bnx2x_null_format_ver(u32 spirom_ver, u8 *str, u16 *len)
-{
-	str[0] = '\0';
-	(*len)--;
-	return 0;
-}
-u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
-			      u8 *version, u16 len)
-{
-	struct bnx2x *bp;
-	u32 spirom_ver = 0;
-	u8 status = 0;
-	u8 *ver_p = version;
-	if (version == NULL || params == NULL)
-		return -EINVAL;
-	bp = params->bp;
-
-	/* Extract first external phy*/
-	version[0] = '\0';
-	spirom_ver = REG_RD(bp, params->phy[EXT_PHY1].ver_addr);
-
-	if (params->phy[EXT_PHY1].format_fw_ver)
-		status |= params->phy[EXT_PHY1].format_fw_ver(spirom_ver,
-							      ver_p,
-							      &len);
-	return status;
-}
-
-static void bnx2x_set_xgxs_loopback(struct bnx2x_phy *phy,
-				    struct link_params *params)
-{
-	u8 port = params->port;
-	struct bnx2x *bp = params->bp;
-
-	if (phy->req_line_speed != SPEED_1000) {
-		u32 md_devad;
-
-		DP(NETIF_MSG_LINK, "XGXS 10G loopback enable\n");
-
-		/* change the uni_phy_addr in the nig */
-		md_devad = REG_RD(bp, (NIG_REG_XGXS0_CTRL_MD_DEVAD +
-					  port*0x18));
-
-		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18, 0x5);
-
-		bnx2x_cl45_write(bp, phy,
-			       5,
-			       (MDIO_REG_BANK_AER_BLOCK +
-				(MDIO_AER_BLOCK_AER_REG & 0xf)),
-			       0x2800);
-
-		bnx2x_cl45_write(bp, phy,
-			       5,
-			       (MDIO_REG_BANK_CL73_IEEEB0 +
-				(MDIO_CL73_IEEEB0_CL73_AN_CONTROL & 0xf)),
-			       0x6041);
-		msleep(200);
-		/* set aer mmd back */
-		bnx2x_set_aer_mmd(params, phy);
-
-		/* and md_devad */
-		REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18,
-			    md_devad);
-
-	} else {
-		u16 mii_ctrl;
-		DP(NETIF_MSG_LINK, "XGXS 1G loopback enable\n");
-		bnx2x_cl45_read(bp, phy, 5,
-				(MDIO_REG_BANK_COMBO_IEEE0 +
-				(MDIO_COMBO_IEEE0_MII_CONTROL & 0xf)),
-				&mii_ctrl);
-		bnx2x_cl45_write(bp, phy, 5,
-				 (MDIO_REG_BANK_COMBO_IEEE0 +
-				 (MDIO_COMBO_IEEE0_MII_CONTROL & 0xf)),
-				 mii_ctrl |
-				 MDIO_COMBO_IEEO_MII_CONTROL_LOOPBACK);
-	}
-}
-
-static void bnx2x_8726_config_loopback(struct bnx2x_phy *phy,
-				       struct link_params *params)
-{
-	struct bnx2x *bp = params->bp;
-	DP(NETIF_MSG_LINK, "PMA/PMD ext_phy_loopback: 8726\n");
-	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0x0001);
-}
-
-static void bnx2x_7101_config_loopback(struct bnx2x_phy *phy,
-				       struct link_params *params)
-{
-	struct bnx2x *bp = params->bp;
-	/* SFX7101_XGXS_TEST1 */
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_XS_DEVAD, MDIO_XS_SFX7101_XGXS_TEST1, 0x100);
-}
-
-/*
- *------------------------------------------------------------------------
- * bnx2x_override_led_value -
- *
- * Override the led value of the requested led
- *
- *------------------------------------------------------------------------
- */
-u8 bnx2x_override_led_value(struct bnx2x *bp, u8 port,
-			  u32 led_idx, u32 value)
-{
-	u32 reg_val;
-
-	/* If port 0 then use EMAC0, else use EMAC1*/
-	u32 emac_base = (port) ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-
-	DP(NETIF_MSG_LINK,
-		 "bnx2x_override_led_value() port %x led_idx %d value %d\n",
-		 port, led_idx, value);
-
-	switch (led_idx) {
-	case 0: /* 10MB led */
-		/* Read the current value of the LED register in
-		the EMAC block */
-		reg_val = REG_RD(bp, emac_base + EMAC_REG_EMAC_LED);
-		/* Set the OVERRIDE bit to 1 */
-		reg_val |= EMAC_LED_OVERRIDE;
-		/* If value is 1, set the 10M_OVERRIDE bit,
-		otherwise reset it.*/
-		reg_val = (value == 1) ? (reg_val | EMAC_LED_10MB_OVERRIDE) :
-			(reg_val & ~EMAC_LED_10MB_OVERRIDE);
-		REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
-		break;
-	case 1: /*100MB led    */
-		/*Read the current value of the LED register in
-		the EMAC block */
-		reg_val = REG_RD(bp, emac_base + EMAC_REG_EMAC_LED);
-		/*  Set the OVERRIDE bit to 1 */
-		reg_val |= EMAC_LED_OVERRIDE;
-		/*  If value is 1, set the 100M_OVERRIDE bit,
-		otherwise reset it.*/
-		reg_val = (value == 1) ? (reg_val | EMAC_LED_100MB_OVERRIDE) :
-			(reg_val & ~EMAC_LED_100MB_OVERRIDE);
-		REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
-		break;
-	case 2: /* 1000MB led */
-		/* Read the current value of the LED register in the
-		EMAC block */
-		reg_val = REG_RD(bp, emac_base + EMAC_REG_EMAC_LED);
-		/* Set the OVERRIDE bit to 1 */
-		reg_val |= EMAC_LED_OVERRIDE;
-		/* If value is 1, set the 1000M_OVERRIDE bit, otherwise
-		reset it. */
-		reg_val = (value == 1) ? (reg_val | EMAC_LED_1000MB_OVERRIDE) :
-			(reg_val & ~EMAC_LED_1000MB_OVERRIDE);
-		REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
-		break;
-	case 3: /* 2500MB led */
-		/*  Read the current value of the LED register in the
-		EMAC block*/
-		reg_val = REG_RD(bp, emac_base + EMAC_REG_EMAC_LED);
-		/* Set the OVERRIDE bit to 1 */
-		reg_val |= EMAC_LED_OVERRIDE;
-		/*  If value is 1, set the 2500M_OVERRIDE bit, otherwise
-		reset it.*/
-		reg_val = (value == 1) ? (reg_val | EMAC_LED_2500MB_OVERRIDE) :
-			(reg_val & ~EMAC_LED_2500MB_OVERRIDE);
-		REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
-		break;
-	case 4: /*10G led */
-		if (port == 0) {
-			REG_WR(bp, NIG_REG_LED_10G_P0,
-				    value);
-		} else {
-			REG_WR(bp, NIG_REG_LED_10G_P1,
-				    value);
-		}
-		break;
-	case 5: /* TRAFFIC led */
-		/* Find if the traffic control is via BMAC or EMAC */
-		if (port == 0)
-			reg_val = REG_RD(bp, NIG_REG_NIG_EMAC0_EN);
-		else
-			reg_val = REG_RD(bp, NIG_REG_NIG_EMAC1_EN);
-
-		/*  Override the traffic led in the EMAC:*/
-		if (reg_val == 1) {
-			/* Read the current value of the LED register in
-			the EMAC block */
-			reg_val = REG_RD(bp, emac_base +
-					     EMAC_REG_EMAC_LED);
-			/* Set the TRAFFIC_OVERRIDE bit to 1 */
-			reg_val |= EMAC_LED_OVERRIDE;
-			/* If value is 1, set the TRAFFIC bit, otherwise
-			reset it.*/
-			reg_val = (value == 1) ? (reg_val | EMAC_LED_TRAFFIC) :
-				(reg_val & ~EMAC_LED_TRAFFIC);
-			REG_WR(bp, emac_base + EMAC_REG_EMAC_LED, reg_val);
-		} else { /* Override the traffic led in the BMAC: */
-			REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0
-				   + port*4, 1);
-			REG_WR(bp, NIG_REG_LED_CONTROL_TRAFFIC_P0 + port*4,
-				    value);
-		}
-		break;
-	default:
-		DP(NETIF_MSG_LINK,
-			 "bnx2x_override_led_value() unknown led index %d "
-			 "(should be 0-5)\n", led_idx);
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-
-u8 bnx2x_set_led(struct link_params *params, u8 mode, u32 speed)
-{
-	u8 port = params->port;
-	u16 hw_led_mode = params->hw_led_mode;
-	u8 rc = 0;
-	u32 tmp;
-	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-	struct bnx2x *bp = params->bp;
-	DP(NETIF_MSG_LINK, "bnx2x_set_led: port %x, mode %d\n", port, mode);
-	DP(NETIF_MSG_LINK, "speed 0x%x, hw_led_mode 0x%x\n",
-		 speed, hw_led_mode);
-	switch (mode) {
-	case LED_MODE_OFF:
-		REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 0);
-		REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
-			   SHARED_HW_CFG_LED_MAC1);
-
-		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
-		EMAC_WR(bp, EMAC_REG_EMAC_LED, (tmp | EMAC_LED_OVERRIDE));
-		break;
-
-	case LED_MODE_OPER:
-		if (SINGLE_MEDIA_DIRECT(params)) {
-			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4, 0);
-			REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 1);
-		} else {
-			REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
-				   hw_led_mode);
-		}
-
-		REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0 +
-			   port*4, 0);
-		/* Set blinking rate to ~15.9Hz */
-		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_P0 + port*4,
-			   LED_BLINK_RATE_VAL);
-		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_ENA_P0 +
-			   port*4, 1);
-		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
-		EMAC_WR(bp, EMAC_REG_EMAC_LED,
-			    (tmp & (~EMAC_LED_OVERRIDE)));
-
-		if (CHIP_IS_E1(bp) &&
-		    ((speed == SPEED_2500) ||
-		     (speed == SPEED_1000) ||
-		     (speed == SPEED_100) ||
-		     (speed == SPEED_10))) {
-			/* On Everest 1 Ax chip versions for speeds less than
-			10G LED scheme is different */
-			REG_WR(bp, NIG_REG_LED_CONTROL_OVERRIDE_TRAFFIC_P0
-				   + port*4, 1);
-			REG_WR(bp, NIG_REG_LED_CONTROL_TRAFFIC_P0 +
-				   port*4, 0);
-			REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_TRAFFIC_P0 +
-				   port*4, 1);
-		}
-		break;
-
-	default:
-		rc = -EINVAL;
-		DP(NETIF_MSG_LINK, "bnx2x_set_led: Invalid led mode %d\n",
-			 mode);
-		break;
-	}
-	return rc;
-
-}
-
-u8 bnx2x_test_link(struct link_params *params, struct link_vars *vars)
-{
-	struct bnx2x *bp = params->bp;
-	u16 gp_status = 0, phy_index = 0;
-
-	CL45_RD_OVER_CL22(bp, &params->phy[INT_PHY],
-			      MDIO_REG_BANK_GP_STATUS,
-			      MDIO_GP_STATUS_TOP_AN_STATUS1,
-			      &gp_status);
-	/* link is up only if both local phy and external phy are up */
-	if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) {
-		u8 ext_phy_link_up = 1;
-		struct link_vars temp_vars;
-		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
-		      phy_index++) {
-			if (params->phy[phy_index].read_status)
-				ext_phy_link_up &=
-					params->phy[phy_index].read_status(
-						&params->phy[phy_index],
-						params, &temp_vars);
-		}
-		if (ext_phy_link_up)
-			return 0;
-	}
-	return -ESRCH;
-}
-
-static u8 bnx2x_link_initialize(struct link_params *params,
-				struct link_vars *vars)
-{
-	u8 rc = 0;
-	u8 phy_index, non_ext_phy;
-	struct bnx2x *bp = params->bp;
-	/**
-	* In case of external phy existence, the line speed would be the
-	* line speed linked up by the external phy. In case it is direct
-	* only, then the line_speed during initialization will be
-	* equal to the req_line_speed
-	*/
-	vars->line_speed = params->phy[INT_PHY].req_line_speed;
-
-	/**
-	 * Initialize the internal phy in case this is a direct board
-	 * (no external phys), or this board has external phy which requires
-	 * to first.
-	 */
-
-	if (params->phy[INT_PHY].config_init)
-		params->phy[INT_PHY].config_init(
-			&params->phy[INT_PHY],
-			params, vars);
-
-	/* init ext phy and enable link state int */
-	non_ext_phy = (SINGLE_MEDIA_DIRECT(params) ||
-		       (params->loopback_mode == LOOPBACK_XGXS_10));
-
-	if (non_ext_phy ||
-	    (params->phy[EXT_PHY1].flags & FLAGS_INIT_XGXS_FIRST) ||
-	    (params->loopback_mode == LOOPBACK_EXT_PHY)) {
-		struct bnx2x_phy *phy = &params->phy[INT_PHY];
-		if (vars->line_speed == SPEED_AUTO_NEG)
-			bnx2x_set_parallel_detection(phy, params);
-		bnx2x_init_internal_phy(phy, params, vars);
-	}
-
-	/* Init external phy*/
-	if (!non_ext_phy)
-		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
-		      phy_index++) {
-			params->phy[phy_index].config_init(
-				&params->phy[phy_index],
-				params, vars);
-		}
-
-	/* Reset the interrupt indication after phy was initialized */
-	bnx2x_bits_dis(bp, NIG_REG_STATUS_INTERRUPT_PORT0 +
-		       params->port*4,
-		       (NIG_STATUS_XGXS0_LINK10G |
-			NIG_STATUS_XGXS0_LINK_STATUS |
-			NIG_STATUS_SERDES0_LINK_STATUS |
-			NIG_MASK_MI_INT));
-	return rc;
-}
-
-static void set_phy_vars(struct link_params *params)
-{
-	struct bnx2x *bp = params->bp;
-	u8 actual_phy_idx, phy_index;
-
-	for (phy_index = INT_PHY; phy_index < params->num_phys;
-	      phy_index++) {
-
-		actual_phy_idx = phy_index;
-		params->phy[actual_phy_idx].req_flow_ctrl  =
-			params->req_flow_ctrl;
-
-		params->phy[actual_phy_idx].req_line_speed =
-			params->req_line_speed;
-
-		params->phy[actual_phy_idx].speed_cap_mask =
-			params->speed_cap_mask;
-
-		params->phy[actual_phy_idx].req_duplex =
-			params->req_duplex;
-
-		DP(NETIF_MSG_LINK, "req_flow_ctrl %x, req_line_speed %x,"
-			   " speed_cap_mask %x\n",
-			   params->phy[actual_phy_idx].req_flow_ctrl,
-			   params->phy[actual_phy_idx].req_line_speed,
-			   params->phy[actual_phy_idx].speed_cap_mask);
-	}
-}
-
-u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
-{
-	struct bnx2x *bp = params->bp;
-	u32 val;
-
-	DP(NETIF_MSG_LINK, "Phy Initialization started\n");
-	DP(NETIF_MSG_LINK, "req_speed %d, req_flowctrl %d\n",
-		 params->req_line_speed, params->req_flow_ctrl);
-	vars->link_status = 0;
-	vars->phy_link_up = 0;
-	vars->link_up = 0;
-	vars->line_speed = 0;
-	vars->duplex = DUPLEX_FULL;
-	vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-	vars->mac_type = MAC_TYPE_NONE;
-	vars->phy_flags = 0;
-
-	/* disable attentions */
-	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + params->port*4,
-		       (NIG_MASK_XGXS0_LINK_STATUS |
-			NIG_MASK_XGXS0_LINK10G |
-			NIG_MASK_SERDES0_LINK_STATUS |
-			NIG_MASK_MI_INT));
-
-	bnx2x_emac_init(params, vars);
-
-	if (params->num_phys == 0) {
-		DP(NETIF_MSG_LINK, "No phy found for initialization !!\n");
-		return -EINVAL;
-	}
-	set_phy_vars(params);
-
-	DP(NETIF_MSG_LINK, "Num of phys on board: %d\n", params->num_phys);
-	if (CHIP_REV_IS_FPGA(bp)) {
-
-		vars->link_up = 1;
-		vars->line_speed = SPEED_10000;
-		vars->duplex = DUPLEX_FULL;
-		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-		vars->link_status = (LINK_STATUS_LINK_UP | LINK_10GTFD);
-		/* enable on E1.5 FPGA */
-		if (CHIP_IS_E1H(bp)) {
-			vars->flow_ctrl |=
-					(BNX2X_FLOW_CTRL_TX |
-					 BNX2X_FLOW_CTRL_RX);
-			vars->link_status |=
-					(LINK_STATUS_TX_FLOW_CONTROL_ENABLED |
-					 LINK_STATUS_RX_FLOW_CONTROL_ENABLED);
-		}
-
-		bnx2x_emac_enable(params, vars, 0);
-		bnx2x_pbf_update(params, vars->flow_ctrl, vars->line_speed);
-		/* disable drain */
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
-
-		/* update shared memory */
-		bnx2x_update_mng(params, vars->link_status);
-
-		return 0;
-
-	} else
-	if (CHIP_REV_IS_EMUL(bp)) {
-
-		vars->link_up = 1;
-		vars->line_speed = SPEED_10000;
-		vars->duplex = DUPLEX_FULL;
-		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-		vars->link_status = (LINK_STATUS_LINK_UP | LINK_10GTFD);
-
-		bnx2x_bmac_enable(params, vars, 0);
-
-		bnx2x_pbf_update(params, vars->flow_ctrl, vars->line_speed);
-		/* Disable drain */
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE
-				    + params->port*4, 0);
-
-		/* update shared memory */
-		bnx2x_update_mng(params, vars->link_status);
-
-		return 0;
-
-	} else
-	if (params->loopback_mode == LOOPBACK_BMAC) {
-
-		vars->link_up = 1;
-		vars->line_speed = SPEED_10000;
-		vars->duplex = DUPLEX_FULL;
-		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-		vars->mac_type = MAC_TYPE_BMAC;
-
-		vars->phy_flags = PHY_XGXS_FLAG;
-
-		bnx2x_xgxs_deassert(params);
-
-		/* set bmac loopback */
-		bnx2x_bmac_enable(params, vars, 1);
-
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
-		    params->port*4, 0);
-
-	} else if (params->loopback_mode == LOOPBACK_EMAC) {
-
-		vars->link_up = 1;
-		vars->line_speed = SPEED_1000;
-		vars->duplex = DUPLEX_FULL;
-		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-		vars->mac_type = MAC_TYPE_EMAC;
-
-		vars->phy_flags = PHY_XGXS_FLAG;
-
-		bnx2x_xgxs_deassert(params);
-		/* set bmac loopback */
-		bnx2x_emac_enable(params, vars, 1);
-		bnx2x_emac_program(params, vars);
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
-		    params->port*4, 0);
-
-	} else if ((params->loopback_mode == LOOPBACK_XGXS_10) ||
-		   (params->loopback_mode == LOOPBACK_EXT_PHY)) {
-
-		vars->link_up = 1;
-		vars->line_speed = SPEED_10000;
-		vars->duplex = DUPLEX_FULL;
-		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-
-		vars->phy_flags = PHY_XGXS_FLAG;
-
-		val = REG_RD(bp,
-				 NIG_REG_XGXS0_CTRL_PHY_ADDR+
-				 params->port*0x18);
-
-		bnx2x_xgxs_deassert(params);
-		bnx2x_link_initialize(params, vars);
-
-		vars->mac_type = MAC_TYPE_BMAC;
-
-		bnx2x_bmac_enable(params, vars, 0);
-
-		if (params->loopback_mode == LOOPBACK_XGXS_10) {
-			/* set 10G XGXS loopback */
-			params->phy[INT_PHY].config_loopback(
-				&params->phy[INT_PHY],
-				params);
-
-		} else {
-			/* set external phy loopback */
-			u8 phy_index;
-			for (phy_index = EXT_PHY1;
-			      phy_index < params->num_phys; phy_index++) {
-				if (params->phy[phy_index].config_loopback)
-					params->phy[phy_index].config_loopback(
-						&params->phy[phy_index],
-						params);
-			}
-		}
-
-		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
-			    params->port*4, 0);
-
-		bnx2x_set_led(params, LED_MODE_OPER, vars->line_speed);
-	} else
-	/* No loopback */
-	{
-		if (params->switch_cfg == SWITCH_CFG_10G)
-			bnx2x_xgxs_deassert(params);
-		else
-			bnx2x_serdes_deassert(bp, params->port);
-		bnx2x_link_initialize(params, vars);
-		msleep(30);
-		bnx2x_link_int_enable(params);
-	}
-	return 0;
-}
-
-
-static void bnx2x_8726_link_reset(struct bnx2x_phy *phy,
-				  struct link_params *params)
+static void bnx2x_8481_hw_reset(struct bnx2x_phy *phy,
+				struct link_params *params)
 {
-	struct bnx2x *bp = params->bp;
-	DP(NETIF_MSG_LINK, "bnx2x_8726_link_reset port %d\n", params->port);
-	/* Set serial boot control for external load */
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_PMA_DEVAD,
-			 MDIO_PMA_REG_GEN_CTRL, 0x0001);
+	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_1,
+			    MISC_REGISTERS_GPIO_OUTPUT_LOW, 0);
+	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_1,
+			    MISC_REGISTERS_GPIO_OUTPUT_LOW, 1);
 }
 
-static void bnx2x_8727_link_reset(struct bnx2x_phy *phy,
-				  struct link_params *params)
-{
-	struct bnx2x *bp = params->bp;
-	/* Disable Transmitter */
-	bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
-}
-static void bnx2x_8073_link_reset(struct bnx2x_phy *phy,
-				  struct link_params *params)
-{
-	struct bnx2x *bp = params->bp;
-	u8 gpio_port;
-	gpio_port = params->port;
-	DP(NETIF_MSG_LINK, "Setting 8073 port %d into low power mode\n",
-	   gpio_port);
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
-			    gpio_port);
-}
 static void bnx2x_8481_link_reset(struct bnx2x_phy *phy,
 					struct link_params *params)
 {
@@ -5202,385 +5262,131 @@ static void bnx2x_848x3_link_reset(struct bnx2x_phy *phy,
 			    port);
 }
 
-static void bnx2x_common_ext_link_reset(struct bnx2x_phy *phy,
-					struct link_params *params)
+/******************************************************************/
+/*			SFX7101 PHY SECTION			  */
+/******************************************************************/
+static void bnx2x_7101_config_loopback(struct bnx2x_phy *phy,
+				       struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
-	u8 gpio_port;
-	/* HW reset */
-	gpio_port = params->port;
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
-			    gpio_port);
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW,
-			    gpio_port);
-	DP(NETIF_MSG_LINK, "reset external PHY\n");
-}
-
-static void bnx2x_int_link_reset(struct bnx2x_phy *phy,
-				 struct link_params *params)
-{
-	/* reset the SerDes/XGXS */
-	REG_WR(params->bp, GRCBASE_MISC +
-		     MISC_REGISTERS_RESET_REG_3_CLEAR,
-		     (0x1ff << (params->port*16)));
+	/* SFX7101_XGXS_TEST1 */
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_XS_DEVAD, MDIO_XS_SFX7101_XGXS_TEST1, 0x100);
 }
 
-u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
-		  u8 reset_ext_phy)
+static u8 bnx2x_7101_config_init(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
 {
+	u16 fw_ver1, fw_ver2, val;
 	struct bnx2x *bp = params->bp;
-	u8 phy_index, port = params->port;
-	DP(NETIF_MSG_LINK, "Resetting the link of port %d\n", port);
-	/* disable attentions */
-	vars->link_status = 0;
-	bnx2x_update_mng(params, vars->link_status);
-	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
-		     (NIG_MASK_XGXS0_LINK_STATUS |
-		      NIG_MASK_XGXS0_LINK10G |
-		      NIG_MASK_SERDES0_LINK_STATUS |
-		      NIG_MASK_MI_INT));
-
-	/* activate nig drain */
-	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
-
-	/* disable nig egress interface */
-	REG_WR(bp, NIG_REG_BMAC0_OUT_EN + port*4, 0);
-	REG_WR(bp, NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0);
+	DP(NETIF_MSG_LINK, "Setting the SFX7101 LASI indication\n");
 
-	/* Stop BigMac rx */
-	bnx2x_bmac_rx_disable(bp, port);
+	/* Restore normal power mode*/
+	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
+			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
+	/* HW reset */
+	bnx2x_ext_phy_hw_reset(bp, params->port);
+	bnx2x_wait_reset_complete(bp, phy);
 
-	/* disable emac */
-	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, 0x1);
+	DP(NETIF_MSG_LINK, "Setting the SFX7101 LED to blink on traffic\n");
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD, MDIO_PMA_REG_7107_LED_CNTL, (1<<3));
 
-	msleep(10);
-	/* The PHY reset is controled by GPIO 1
-	 * Hold it as vars low
-	 */
-	 /* clear link led */
-	bnx2x_set_led(params, LED_MODE_OFF, 0);
-	if (reset_ext_phy) {
-		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
-		      phy_index++) {
-			if (params->phy[phy_index].link_reset)
-				params->phy[phy_index].link_reset(
-					&params->phy[phy_index],
-					params);
-		}
-	}
+	bnx2x_ext_phy_set_pause(params, phy, vars);
+	/* Restart autoneg */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, &val);
+	val |= 0x200;
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_AN_DEVAD, MDIO_AN_REG_CTRL, val);
 
-	if (params->phy[INT_PHY].link_reset)
-		params->phy[INT_PHY].link_reset(
-			&params->phy[INT_PHY], params);
-	/* reset BigMac */
-	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
-	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+	/* Save spirom version */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_7101_VER1, &fw_ver1);
 
-	/* disable nig ingress interface */
-	REG_WR(bp, NIG_REG_BMAC0_IN_EN + port*4, 0);
-	REG_WR(bp, NIG_REG_EMAC0_IN_EN + port*4, 0);
-	REG_WR(bp, NIG_REG_BMAC0_OUT_EN + port*4, 0);
-	REG_WR(bp, NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0);
-	vars->link_up = 0;
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_7101_VER2, &fw_ver2);
+	bnx2x_save_spirom_version(bp, params->port,
+				  (u32)(fw_ver1<<16 | fw_ver2), phy->ver_addr);
 	return 0;
 }
 
-static u8 bnx2x_update_link_down(struct link_params *params,
-			       struct link_vars *vars)
+static u8 bnx2x_7101_read_status(struct bnx2x_phy *phy,
+				 struct link_params *params,
+				 struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
-
-	DP(NETIF_MSG_LINK, "Port %x: Link is down\n", port);
-	bnx2x_set_led(params, LED_MODE_OFF, 0);
-
-	/* indicate no mac active */
-	vars->mac_type = MAC_TYPE_NONE;
-
-	/* update shared memory */
-	vars->link_status = 0;
-	vars->line_speed = 0;
-	bnx2x_update_mng(params, vars->link_status);
-
-	/* activate nig drain */
-	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
-
-	/* disable emac */
-	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
+	u8 link_up;
+	u16 val1, val2;
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val2);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "10G-base-T LASI status 0x%x->0x%x\n",
+		   val2, val1);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val2);
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_STATUS, &val1);
+	DP(NETIF_MSG_LINK, "10G-base-T PMA status 0x%x->0x%x\n",
+		   val2, val1);
+	link_up = ((val1 & 4) == 4);
+	/* if link is up
+	 * print the AN outcome of the SFX7101 PHY
+	 */
+	if (link_up) {
+		bnx2x_cl45_read(bp, phy,
+				MDIO_AN_DEVAD, MDIO_AN_REG_MASTER_STATUS,
+				&val2);
+		vars->line_speed = SPEED_10000;
+		DP(NETIF_MSG_LINK, "SFX7101 AN status 0x%x->Master=%x\n",
+			   val2, (val2 & (1<<14)));
+		bnx2x_ext_phy_10G_an_resolve(bp, phy, vars);
+		bnx2x_ext_phy_resolve_fc(phy, params, vars);
+	}
+	return link_up;
+}
 
-	msleep(10);
 
-	/* reset BigMac */
-	bnx2x_bmac_rx_disable(bp, params->port);
-	REG_WR(bp, GRCBASE_MISC +
-		   MISC_REGISTERS_RESET_REG_2_CLEAR,
-		   (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
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
 	return 0;
 }
 
-static u8 bnx2x_update_link_up(struct link_params *params,
-			     struct link_vars *vars,
-			     u8 link_10g)
-{
-	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
-	u8 rc = 0;
-
-	vars->link_status |= LINK_STATUS_LINK_UP;
-	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
-		vars->link_status |=
-			LINK_STATUS_TX_FLOW_CONTROL_ENABLED;
-
-	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_RX)
-		vars->link_status |=
-			LINK_STATUS_RX_FLOW_CONTROL_ENABLED;
-	if (link_10g) {
-		bnx2x_bmac_enable(params, vars, 0);
-		bnx2x_set_led(params, LED_MODE_OPER, SPEED_10000);
-	} else {
-		rc = bnx2x_emac_program(params, vars);
-
-		bnx2x_emac_enable(params, vars, 0);
-
-		/* AN complete? */
-		if ((vars->link_status & LINK_STATUS_AUTO_NEGOTIATE_COMPLETE)
-		    && (!(vars->phy_flags & PHY_SGMII_FLAG)) &&
-		    SINGLE_MEDIA_DIRECT(params))
-			bnx2x_set_gmii_tx_driver(params);
-	}
-
-	/* PBF - link up */
-	rc |= bnx2x_pbf_update(params, vars->flow_ctrl,
-			      vars->line_speed);
-
-	/* disable drain */
-	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 0);
-
-	/* update shared memory */
-	bnx2x_update_mng(params, vars->link_status);
-	msleep(20);
-	return rc;
-}
-/**
- * The bnx2x_link_update function should be called upon link
- * interrupt.
- * Link is considered up as follows:
- * - DIRECT_SINGLE_MEDIA - Only XGXS link (internal link) needs
- *   to be up
- * - SINGLE_MEDIA - The link between the 577xx and the external
- *   phy (XGXS) need to up as well as the external link of the
- *   phy (PHY_EXT1)
- * - DUAL_MEDIA - The link between the 577xx and the first
- *   external phy needs to be up, and at least one of the 2
- *   external phy link must be up.
- */
-u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
+void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, struct bnx2x_phy *phy)
 {
-	struct bnx2x *bp = params->bp;
-	struct link_vars phy_vars[MAX_PHYS];
-	u8 port = params->port;
-	u8 link_10g, phy_index;
-	u8 ext_phy_link_up = 0, cur_link_up, rc = 0;
-	u8 is_mi_int = 0;
-	u16 ext_phy_line_speed = 0, prev_line_speed = vars->line_speed;
-	u8 active_external_phy = INT_PHY;
-	vars->link_status = 0;
-	for (phy_index = INT_PHY; phy_index < params->num_phys;
-	      phy_index++) {
-		phy_vars[phy_index].flow_ctrl = 0;
-		phy_vars[phy_index].link_status = 0;
-		phy_vars[phy_index].line_speed = 0;
-		phy_vars[phy_index].duplex = DUPLEX_FULL;
-		phy_vars[phy_index].phy_link_up = 0;
-		phy_vars[phy_index].link_up = 0;
-	}
-
-	DP(NETIF_MSG_LINK, "port %x, XGXS?%x, int_status 0x%x\n",
-		 port, (vars->phy_flags & PHY_XGXS_FLAG),
-		 REG_RD(bp, NIG_REG_STATUS_INTERRUPT_PORT0 + port*4));
-
-	is_mi_int = (u8)(REG_RD(bp, NIG_REG_EMAC0_STATUS_MISC_MI_INT +
-				    port*0x18) > 0);
-	DP(NETIF_MSG_LINK, "int_mask 0x%x MI_INT %x, SERDES_LINK %x\n",
-		 REG_RD(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4),
-		 is_mi_int,
-		 REG_RD(bp,
-			    NIG_REG_SERDES0_STATUS_LINK_STATUS + port*0x3c));
-
-	DP(NETIF_MSG_LINK, " 10G %x, XGXS_LINK %x\n",
-	  REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK10G + port*0x68),
-	  REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK_STATUS + port*0x68));
-
-	/* disable emac */
-	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
-
-	/**
-	* Step 1:
-	* Check external link change only for external phys, and apply
-	* priority selection between them in case the link on both phys
-	* is up. Note that the instead of the common vars, a temporary
-	* vars argument is used since each phy may have different link/
-	* speed/duplex result
-	*/
-	for (phy_index = EXT_PHY1; phy_index < params->num_phys;
-	      phy_index++) {
-		struct bnx2x_phy *phy = &params->phy[phy_index];
-		if (!phy->read_status)
-			continue;
-		/* Read link status and params of this ext phy */
-		cur_link_up = phy->read_status(phy, params,
-					       &phy_vars[phy_index]);
-		if (cur_link_up) {
-			DP(NETIF_MSG_LINK, "phy in index %d link is up\n",
-				   phy_index);
-		} else {
-			DP(NETIF_MSG_LINK, "phy in index %d link is down\n",
-				   phy_index);
-			continue;
-		}
-
-		if (!ext_phy_link_up) {
-			ext_phy_link_up = 1;
-			active_external_phy = phy_index;
-		}
-	}
-	prev_line_speed = vars->line_speed;
-	/**
-	* Step 2:
-	* Read the status of the internal phy. In case of
-	* DIRECT_SINGLE_MEDIA board, this link is the external link,
-	* otherwise this is the link between the 577xx and the first
-	* external phy
-	*/
-	if (params->phy[INT_PHY].read_status)
-		params->phy[INT_PHY].read_status(
-			&params->phy[INT_PHY],
-			params, vars);
-	/**
-	 * The INT_PHY flow control reside in the vars. This include the
-	 * case where the speed or flow control are not set to AUTO.
-	 * Otherwise, the active external phy flow control result is set
-	 * to the vars. The ext_phy_line_speed is needed to check if the
-	 * speed is different between the internal phy and external phy.
-	 * This case may be result of intermediate link speed change.
-	 */
-	if (active_external_phy > INT_PHY) {
-		vars->flow_ctrl = phy_vars[active_external_phy].flow_ctrl;
-		/**
-		 * Link speed is taken from the XGXS. AN and FC result from
-		 * the external phy.
-		 */
-		vars->link_status |= phy_vars[active_external_phy].link_status;
-		ext_phy_line_speed = phy_vars[active_external_phy].line_speed;
-		vars->duplex = phy_vars[active_external_phy].duplex;
-		if (params->phy[active_external_phy].supported &
-		    SUPPORTED_FIBRE)
-			vars->link_status |= LINK_STATUS_SERDES_LINK;
-		DP(NETIF_MSG_LINK, "Active external phy selected: %x\n",
-			   active_external_phy);
-	}
-	DP(NETIF_MSG_LINK, "vars->flow_ctrl = 0x%x, vars->link_status = 0x%x,"
-		   " ext_phy_line_speed = %d\n", vars->flow_ctrl,
-		   vars->link_status, ext_phy_line_speed);
-	/**
-	 * Upon link speed change set the NIG into drain mode. Comes to
-	 * deals with possible FIFO glitch due to clk change when speed
-	 * is decreased without link down indicator
-	 */
-
-	if (vars->phy_link_up) {
-		if (!(SINGLE_MEDIA_DIRECT(params)) && ext_phy_link_up &&
-		    (ext_phy_line_speed != vars->line_speed)) {
-			DP(NETIF_MSG_LINK, "Internal link speed %d is"
-				   " different than the external"
-				   " link speed %d\n", vars->line_speed,
-				   ext_phy_line_speed);
-			vars->phy_link_up = 0;
-		} else if (prev_line_speed != vars->line_speed) {
-			REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE
-				     + params->port*4, 0);
-			msleep(1);
-		}
-	}
+	u16 val, cnt;
 
-	/* anything 10 and over uses the bmac */
-	link_10g = ((vars->line_speed == SPEED_10000) ||
-		    (vars->line_speed == SPEED_12000) ||
-		    (vars->line_speed == SPEED_12500) ||
-		    (vars->line_speed == SPEED_13000) ||
-		    (vars->line_speed == SPEED_15000) ||
-		    (vars->line_speed == SPEED_16000));
+	bnx2x_cl45_read(bp, phy,
+		      MDIO_PMA_DEVAD,
+		      MDIO_PMA_REG_7101_RESET, &val);
 
-	bnx2x_link_int_ack(params, vars, link_10g, is_mi_int);
+	for (cnt = 0; cnt < 10; cnt++) {
+		msleep(50);
+		/* Writes a self-clearing reset */
+		bnx2x_cl45_write(bp, phy,
+			       MDIO_PMA_DEVAD,
+			       MDIO_PMA_REG_7101_RESET,
+			       (val | (1<<15)));
+		/* Wait for clear */
+		bnx2x_cl45_read(bp, phy,
+			      MDIO_PMA_DEVAD,
+			      MDIO_PMA_REG_7101_RESET, &val);
 
-	/**
-	* In case external phy link is up, and internal link is down
-	* (not initialized yet probably after link initialization, it
-	* needs to be initialized.
-	* Note that after link down-up as result of cable plug, the xgxs
-	* link would probably become up again without the need
-	* initialize it
-	*/
-	if (!(SINGLE_MEDIA_DIRECT(params))) {
-		DP(NETIF_MSG_LINK, "ext_phy_link_up = %d, int_link_up = %d,"
-			   " init_preceding = %d\n", ext_phy_link_up,
-			   vars->phy_link_up,
-			   params->phy[EXT_PHY1].flags &
-			   FLAGS_INIT_XGXS_FIRST);
-		if (!(params->phy[EXT_PHY1].flags &
-		      FLAGS_INIT_XGXS_FIRST)
-		    && ext_phy_link_up && !vars->phy_link_up) {
-			vars->line_speed = ext_phy_line_speed;
-			if (vars->line_speed < SPEED_1000)
-				vars->phy_flags |= PHY_SGMII_FLAG;
-			else
-				vars->phy_flags &= ~PHY_SGMII_FLAG;
-			bnx2x_init_internal_phy(&params->phy[INT_PHY],
-						params,
-						vars);
-		}
+		if ((val & (1<<15)) == 0)
+			break;
 	}
-	/**
-	 *  Link is up only if both local phy and external phy (in case of
-	 *  non-direct board) are up
-	 */
-	vars->link_up = (vars->phy_link_up &&
-			 (ext_phy_link_up ||
-			  SINGLE_MEDIA_DIRECT(params)));
-
-	if (vars->link_up)
-		rc = bnx2x_update_link_up(params, vars, link_10g);
-	else
-		rc = bnx2x_update_link_down(params, vars);
-
-	return rc;
-}
-
-static void bnx2x_8481_hw_reset(struct bnx2x_phy *phy,
-				struct link_params *params)
-{
-	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW, 0);
-	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW, 1);
-}
-
-static void bnx2x_8727_hw_reset(struct bnx2x_phy *phy,
-				struct link_params *params) {
-	u32 swap_val, swap_override;
-	u8 port;
-	/**
-	 * The PHY reset is controlled by GPIO 1. Fake the port number
-	 * to cancel the swap done in set_gpio()
-	 */
-	struct bnx2x *bp = params->bp;
-	swap_val = REG_RD(bp, NIG_REG_PORT_SWAP);
-	swap_override = REG_RD(bp, NIG_REG_STRAP_OVERRIDE);
-	port = (swap_val && swap_override) ^ 1;
-	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
-			    MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
 }
 
 static void bnx2x_7101_hw_reset(struct bnx2x_phy *phy,
@@ -5592,6 +5398,7 @@ static void bnx2x_7101_hw_reset(struct bnx2x_phy *phy,
 	bnx2x_set_gpio(params->bp, MISC_REGISTERS_GPIO_1,
 			    MISC_REGISTERS_GPIO_OUTPUT_LOW, params->port);
 }
+
 /******************************************************************/
 /*			STATIC PHY DECLARATION			  */
 /******************************************************************/
@@ -5854,7 +5661,6 @@ static struct bnx2x_phy phy_8727 = {
 	.mdio_ctrl	= 0,
 	.supported	= (SUPPORTED_10000baseT_Full |
 			   SUPPORTED_1000baseT_Full |
-			   SUPPORTED_Autoneg |
 			   SUPPORTED_FIBRE |
 			   SUPPORTED_Pause |
 			   SUPPORTED_Asym_Pause),
@@ -6240,6 +6046,271 @@ u32 bnx2x_supported_attr(struct link_params *params, u8 phy_idx)
 	return 0;
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
+u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u32 val;
+
+	DP(NETIF_MSG_LINK, "Phy Initialization started\n");
+	DP(NETIF_MSG_LINK, "req_speed %d, req_flowctrl %d\n",
+		 params->req_line_speed, params->req_flow_ctrl);
+	vars->link_status = 0;
+	vars->phy_link_up = 0;
+	vars->link_up = 0;
+	vars->line_speed = 0;
+	vars->duplex = DUPLEX_FULL;
+	vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+	vars->mac_type = MAC_TYPE_NONE;
+	vars->phy_flags = 0;
+
+	/* disable attentions */
+	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + params->port*4,
+		       (NIG_MASK_XGXS0_LINK_STATUS |
+			NIG_MASK_XGXS0_LINK10G |
+			NIG_MASK_SERDES0_LINK_STATUS |
+			NIG_MASK_MI_INT));
+
+	bnx2x_emac_init(params, vars);
+
+	if (params->num_phys == 0) {
+		DP(NETIF_MSG_LINK, "No phy found for initialization !!\n");
+		return -EINVAL;
+	}
+	set_phy_vars(params);
+
+	DP(NETIF_MSG_LINK, "Num of phys on board: %d\n", params->num_phys);
+	if (CHIP_REV_IS_FPGA(bp)) {
+
+		vars->link_up = 1;
+		vars->line_speed = SPEED_10000;
+		vars->duplex = DUPLEX_FULL;
+		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+		vars->link_status = (LINK_STATUS_LINK_UP | LINK_10GTFD);
+		/* enable on E1.5 FPGA */
+		if (CHIP_IS_E1H(bp)) {
+			vars->flow_ctrl |=
+					(BNX2X_FLOW_CTRL_TX |
+					 BNX2X_FLOW_CTRL_RX);
+			vars->link_status |=
+					(LINK_STATUS_TX_FLOW_CONTROL_ENABLED |
+					 LINK_STATUS_RX_FLOW_CONTROL_ENABLED);
+		}
+
+		bnx2x_emac_enable(params, vars, 0);
+		bnx2x_pbf_update(params, vars->flow_ctrl, vars->line_speed);
+		/* disable drain */
+		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
+
+		/* update shared memory */
+		bnx2x_update_mng(params, vars->link_status);
+
+		return 0;
+
+	} else
+	if (CHIP_REV_IS_EMUL(bp)) {
+
+		vars->link_up = 1;
+		vars->line_speed = SPEED_10000;
+		vars->duplex = DUPLEX_FULL;
+		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+		vars->link_status = (LINK_STATUS_LINK_UP | LINK_10GTFD);
+
+		bnx2x_bmac_enable(params, vars, 0);
+
+		bnx2x_pbf_update(params, vars->flow_ctrl, vars->line_speed);
+		/* Disable drain */
+		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE
+				    + params->port*4, 0);
+
+		/* update shared memory */
+		bnx2x_update_mng(params, vars->link_status);
+
+		return 0;
+
+	} else
+	if (params->loopback_mode == LOOPBACK_BMAC) {
+
+		vars->link_up = 1;
+		vars->line_speed = SPEED_10000;
+		vars->duplex = DUPLEX_FULL;
+		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+		vars->mac_type = MAC_TYPE_BMAC;
+
+		vars->phy_flags = PHY_XGXS_FLAG;
+
+		bnx2x_xgxs_deassert(params);
+
+		/* set bmac loopback */
+		bnx2x_bmac_enable(params, vars, 1);
+
+		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
+		    params->port*4, 0);
+
+	} else if (params->loopback_mode == LOOPBACK_EMAC) {
+
+		vars->link_up = 1;
+		vars->line_speed = SPEED_1000;
+		vars->duplex = DUPLEX_FULL;
+		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+		vars->mac_type = MAC_TYPE_EMAC;
+
+		vars->phy_flags = PHY_XGXS_FLAG;
+
+		bnx2x_xgxs_deassert(params);
+		/* set bmac loopback */
+		bnx2x_emac_enable(params, vars, 1);
+		bnx2x_emac_program(params, vars);
+		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
+		    params->port*4, 0);
+
+	} else if ((params->loopback_mode == LOOPBACK_XGXS) ||
+		   (params->loopback_mode == LOOPBACK_EXT_PHY)) {
+
+		vars->link_up = 1;
+		vars->line_speed = SPEED_10000;
+		vars->duplex = DUPLEX_FULL;
+		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+
+		vars->phy_flags = PHY_XGXS_FLAG;
+
+		val = REG_RD(bp,
+				 NIG_REG_XGXS0_CTRL_PHY_ADDR+
+				 params->port*0x18);
+
+		bnx2x_xgxs_deassert(params);
+		bnx2x_link_initialize(params, vars);
+
+		vars->mac_type = MAC_TYPE_BMAC;
+
+		bnx2x_bmac_enable(params, vars, 0);
+
+		if (params->loopback_mode == LOOPBACK_XGXS) {
+			/* set 10G XGXS loopback */
+			params->phy[INT_PHY].config_loopback(
+				&params->phy[INT_PHY],
+				params);
+
+		} else {
+			/* set external phy loopback */
+			u8 phy_index;
+			for (phy_index = EXT_PHY1;
+			      phy_index < params->num_phys; phy_index++) {
+				if (params->phy[phy_index].config_loopback)
+					params->phy[phy_index].config_loopback(
+						&params->phy[phy_index],
+						params);
+			}
+		}
+
+		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE +
+			    params->port*4, 0);
+
+		bnx2x_set_led(params, LED_MODE_OPER, vars->line_speed);
+	} else
+	/* No loopback */
+	{
+		if (params->switch_cfg == SWITCH_CFG_10G)
+			bnx2x_xgxs_deassert(params);
+		else
+			bnx2x_serdes_deassert(bp, params->port);
+		bnx2x_link_initialize(params, vars);
+		msleep(30);
+		bnx2x_link_int_enable(params);
+	}
+	return 0;
+}
+u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
+		  u8 reset_ext_phy)
+{
+	struct bnx2x *bp = params->bp;
+	u8 phy_index, port = params->port;
+	DP(NETIF_MSG_LINK, "Resetting the link of port %d\n", port);
+	/* disable attentions */
+	vars->link_status = 0;
+	bnx2x_update_mng(params, vars->link_status);
+	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + port*4,
+		     (NIG_MASK_XGXS0_LINK_STATUS |
+		      NIG_MASK_XGXS0_LINK10G |
+		      NIG_MASK_SERDES0_LINK_STATUS |
+		      NIG_MASK_MI_INT));
+
+	/* activate nig drain */
+	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
+
+	/* disable nig egress interface */
+	REG_WR(bp, NIG_REG_BMAC0_OUT_EN + port*4, 0);
+	REG_WR(bp, NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0);
+
+	/* Stop BigMac rx */
+	bnx2x_bmac_rx_disable(bp, port);
+
+	/* disable emac */
+	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
+
+	msleep(10);
+	/* The PHY reset is controled by GPIO 1
+	 * Hold it as vars low
+	 */
+	 /* clear link led */
+	bnx2x_set_led(params, LED_MODE_OFF, 0);
+	if (reset_ext_phy) {
+		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
+		      phy_index++) {
+			if (params->phy[phy_index].link_reset)
+				params->phy[phy_index].link_reset(
+					&params->phy[phy_index],
+					params);
+		}
+	}
+
+	if (params->phy[INT_PHY].link_reset)
+		params->phy[INT_PHY].link_reset(
+			&params->phy[INT_PHY], params);
+	/* reset BigMac */
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
+	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+
+	/* disable nig ingress interface */
+	REG_WR(bp, NIG_REG_BMAC0_IN_EN + port*4, 0);
+	REG_WR(bp, NIG_REG_EMAC0_IN_EN + port*4, 0);
+	REG_WR(bp, NIG_REG_BMAC0_OUT_EN + port*4, 0);
+	REG_WR(bp, NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0);
+	vars->link_up = 0;
+	return 0;
+}
+
+/****************************************************************************/
+/*				Common function				    */
+/****************************************************************************/
 static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 {
 	struct bnx2x_phy phy[PORT_MAX];
@@ -6348,6 +6419,43 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	return 0;
 }
 
+static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base)
+{
+	u32 val;
+	s8 port;
+	struct bnx2x_phy phy;
+	/* Use port1 because of the static port-swap */
+	/* Enable the module detection interrupt */
+	val = REG_RD(bp, MISC_REG_GPIO_EVENT_EN);
+	val |= ((1<<MISC_REGISTERS_GPIO_3)|
+		(1<<(MISC_REGISTERS_GPIO_3 + MISC_REGISTERS_GPIO_PORT_SHIFT)));
+	REG_WR(bp, MISC_REG_GPIO_EVENT_EN, val);
+
+	bnx2x_ext_phy_hw_reset(bp, 1);
+	msleep(5);
+	for (port = 0; port < PORT_MAX; port++) {
+		/* Extract the ext phy address for the port */
+		if (bnx2x_populate_phy(bp, EXT_PHY1, shmem_base,
+				       port, &phy) !=
+		    0) {
+			DP(NETIF_MSG_LINK, "populate phy failed\n");
+			return -EINVAL;
+		}
+
+		/* Reset phy*/
+		bnx2x_cl45_write(bp, &phy,
+				 MDIO_PMA_DEVAD, MDIO_PMA_REG_GEN_CTRL, 0x0001);
+
+
+		/* Set fault module detected LED on */
+		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
+				  MISC_REGISTERS_GPIO_HIGH,
+				  port);
+	}
+
+	return 0;
+}
+
 static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 {
 	s8 port, first_port, i;
@@ -6420,43 +6528,6 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	return 0;
 }
 
-static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base)
-{
-	u32 val;
-	s8 port;
-	struct bnx2x_phy phy;
-	/* Use port1 because of the static port-swap */
-	/* Enable the module detection interrupt */
-	val = REG_RD(bp, MISC_REG_GPIO_EVENT_EN);
-	val |= ((1<<MISC_REGISTERS_GPIO_3)|
-		(1<<(MISC_REGISTERS_GPIO_3 + MISC_REGISTERS_GPIO_PORT_SHIFT)));
-	REG_WR(bp, MISC_REG_GPIO_EVENT_EN, val);
-
-	bnx2x_ext_phy_hw_reset(bp, 1);
-	msleep(5);
-	for (port = 0; port < PORT_MAX; port++) {
-		/* Extract the ext phy address for the port */
-		if (bnx2x_populate_phy(bp, EXT_PHY1, shmem_base,
-				       port, &phy) !=
-		    0) {
-			DP(NETIF_MSG_LINK, "populate phy failed\n");
-			return -EINVAL;
-		}
-
-		/* Reset phy*/
-		bnx2x_cl45_write(bp, &phy,
-				 MDIO_PMA_DEVAD, MDIO_PMA_REG_GEN_CTRL, 0x0001);
-
-
-		/* Set fault module detected LED on */
-		bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
-				  MISC_REGISTERS_GPIO_HIGH,
-				  port);
-	}
-
-	return 0;
-}
-
 u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 {
 	u8 rc = 0;
@@ -6497,30 +6568,6 @@ u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	return rc;
 }
 
-void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, struct bnx2x_phy *phy)
-{
-	u16 val, cnt;
-
-	bnx2x_cl45_read(bp, phy,
-		      MDIO_PMA_DEVAD,
-		      MDIO_PMA_REG_7101_RESET, &val);
-
-	for (cnt = 0; cnt < 10; cnt++) {
-		msleep(50);
-		/* Writes a self-clearing reset */
-		bnx2x_cl45_write(bp, phy,
-			       MDIO_PMA_DEVAD,
-			       MDIO_PMA_REG_7101_RESET,
-			       (val | (1<<15)));
-		/* Wait for clear */
-		bnx2x_cl45_read(bp, phy,
-			      MDIO_PMA_DEVAD,
-			      MDIO_PMA_REG_7101_RESET, &val);
-
-		if ((val & (1<<15)) == 0)
-			break;
-	}
-}
 
 u8 bnx2x_hw_lock_required(struct bnx2x *bp, u32 shmem_base)
 {
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index 99e1157..35f665f 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -173,7 +173,7 @@ struct link_params {
 #define LOOPBACK_NONE	0
 #define LOOPBACK_EMAC	1
 #define LOOPBACK_BMAC	2
-#define LOOPBACK_XGXS_10	3
+#define LOOPBACK_XGXS		3
 #define LOOPBACK_EXT_PHY	4
 #define LOOPBACK_EXT 	5
 
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 0210dde..30618c7 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1269,7 +1269,7 @@ u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 		bnx2x_acquire_phy_lock(bp);
 
 		if (load_mode == LOAD_DIAG)
-			bp->link_params.loopback_mode = LOOPBACK_XGXS_10;
+			bp->link_params.loopback_mode = LOOPBACK_XGXS;
 
 		rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
 
-- 
1.7.1




