From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 03/10] bnx2x: Fix remote fault handling
Date: Wed, 3 Aug 2011 11:59:25 +0300
Message-ID: <1312361965.21665.93.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2501 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753206Ab1HCI7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 04:59:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix couple of issues of remote fault detection and handling:
Link may go down due to remote fault indications during link establishment.
Possible link down after primary function migration.
Remote fault was not detected on 578xx.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_hsi.h  |    2 +
 drivers/net/bnx2x/bnx2x_link.c |  110 ++++++++++++++++++++++++----------------
 drivers/net/bnx2x/bnx2x_link.h |    2 +-
 3 files changed, 69 insertions(+), 45 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index 06727f3..dc24de4 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -1204,6 +1204,8 @@ struct drv_port_mb {
 
 	#define LINK_STATUS_PFC_ENABLED				0x20000000
 
+	#define LINK_STATUS_PHYSICAL_LINK_FLAG			0x40000000
+
 	u32 port_stx;
 
 	u32 stat_nig_timer;
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 0a7091d..8e68e15 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -1745,6 +1745,10 @@ static int bnx2x_emac_enable(struct link_params *params,
 
 	DP(NETIF_MSG_LINK, "enabling EMAC\n");
 
+	/* Disable BMAC */
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
+	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
+
 	/* enable emac and not bmac */
 	REG_WR(bp, NIG_REG_EGRESS_EMAC0_PORT + port*4, 1);
 
@@ -2599,12 +2603,6 @@ static int bnx2x_bmac1_enable(struct link_params *params,
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_LLFC_MSG_FLDS,
 		    wb_data, 2);
 
-	if (vars->phy_flags & PHY_TX_ERROR_CHECK_FLAG) {
-		REG_RD_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_LSS_STATUS,
-			    wb_data, 2);
-		if (wb_data[0] > 0)
-			return -ESRCH;
-	}
 	return 0;
 }
 
@@ -2670,16 +2668,6 @@ static int bnx2x_bmac2_enable(struct link_params *params,
 	udelay(30);
 	bnx2x_update_pfc_bmac2(params, vars, is_lb);
 
-	if (vars->phy_flags & PHY_TX_ERROR_CHECK_FLAG) {
-		REG_RD_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_LSS_STAT,
-			    wb_data, 2);
-		if (wb_data[0] > 0) {
-			DP(NETIF_MSG_LINK, "Got bad LSS status 0x%x\n",
-				       wb_data[0]);
-			return -ESRCH;
-		}
-	}
-
 	return 0;
 }
 
@@ -4369,6 +4357,9 @@ void bnx2x_link_status_update(struct link_params *params,
 
 	vars->link_up = (vars->link_status & LINK_STATUS_LINK_UP);
 	vars->phy_flags = PHY_XGXS_FLAG;
+	if (vars->link_status & LINK_STATUS_PHYSICAL_LINK_FLAG)
+		vars->phy_flags |= PHY_PHYSICAL_LINK_FLAG;
+
 	if (vars->link_up) {
 		DP(NETIF_MSG_LINK, "phy link up\n");
 
@@ -4460,6 +4451,8 @@ void bnx2x_link_status_update(struct link_params *params,
 
 		/* indicate no mac active */
 		vars->mac_type = MAC_TYPE_NONE;
+		if (vars->link_status & LINK_STATUS_PHYSICAL_LINK_FLAG)
+			vars->phy_flags |= PHY_HALF_OPEN_CONN_FLAG;
 	}
 
 	/* Sync media type */
@@ -6176,6 +6169,7 @@ static int bnx2x_update_link_down(struct link_params *params,
 	/* update shared memory */
 	vars->link_status &= ~(LINK_STATUS_SPEED_AND_DUPLEX_MASK |
 			       LINK_STATUS_LINK_UP |
+			       LINK_STATUS_PHYSICAL_LINK_FLAG |
 			       LINK_STATUS_AUTO_NEGOTIATE_COMPLETE |
 			       LINK_STATUS_RX_FLOW_CONTROL_FLAG_MASK |
 			       LINK_STATUS_TX_FLOW_CONTROL_FLAG_MASK |
@@ -6213,7 +6207,8 @@ static int bnx2x_update_link_up(struct link_params *params,
 	u8 port = params->port;
 	int rc = 0;
 
-	vars->link_status |= LINK_STATUS_LINK_UP;
+	vars->link_status |= (LINK_STATUS_LINK_UP |
+			      LINK_STATUS_PHYSICAL_LINK_FLAG);
 	vars->phy_flags |= PHY_PHYSICAL_LINK_FLAG;
 
 	if (vars->flow_ctrl & BNX2X_FLOW_CTRL_TX)
@@ -8132,7 +8127,6 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 				 offsetof(struct shmem_region, dev_info.
 					  port_feature_config[params->port].
 					  config));
-
 		bnx2x_set_gpio_int(bp, gpio_num,
 				   MISC_REGISTERS_GPIO_INT_OUTPUT_SET,
 				   gpio_port);
@@ -8141,8 +8135,9 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 		 * Disable transmit for this module
 		 */
 		phy->media_type = ETH_PHY_NOT_PRESENT;
-		if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
-		    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
+		if (((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
+		     PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER) ||
+		    CHIP_IS_E3(bp))
 			bnx2x_sfp_set_transmitter(params, phy, 0);
 	}
 }
@@ -8244,9 +8239,6 @@ static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
 	u16 cnt, val, tmp1;
 	struct bnx2x *bp = params->bp;
 
-	/* SPF+ PHY: Set flag to check for Tx error */
-	vars->phy_flags = PHY_TX_ERROR_CHECK_FLAG;
-
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_2,
 		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
 	/* HW reset */
@@ -8430,9 +8422,6 @@ static int bnx2x_8726_config_init(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	DP(NETIF_MSG_LINK, "Initializing BCM8726\n");
 
-	/* SPF+ PHY: Set flag to check for Tx error */
-	vars->phy_flags = PHY_TX_ERROR_CHECK_FLAG;
-
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 1<<15);
 	bnx2x_wait_reset_complete(bp, phy, params);
 
@@ -8601,9 +8590,6 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	/* Enable PMD link, MOD_ABS_FLT, and 1G link alarm */
 
-	/* SPF+ PHY: Set flag to check for Tx error */
-	vars->phy_flags = PHY_TX_ERROR_CHECK_FLAG;
-
 	bnx2x_wait_reset_complete(bp, phy, params);
 	rx_alarm_ctrl_val = (1<<2) | (1<<5) ;
 	/* Should be 0x6 to enable XS on Tx side. */
@@ -10619,7 +10605,8 @@ static struct bnx2x_phy phy_warpcore = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= FLAGS_HW_LOCK_REQUIRED,
+	.flags		= (FLAGS_HW_LOCK_REQUIRED |
+			   FLAGS_TX_ERROR_CHECK),
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -10745,7 +10732,8 @@ static struct bnx2x_phy phy_8706 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= FLAGS_INIT_XGXS_FIRST,
+	.flags		= (FLAGS_INIT_XGXS_FIRST |
+			   FLAGS_TX_ERROR_CHECK),
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -10776,7 +10764,8 @@ static struct bnx2x_phy phy_8726 = {
 	.addr		= 0xff,
 	.def_md_devad	= 0,
 	.flags		= (FLAGS_HW_LOCK_REQUIRED |
-			   FLAGS_INIT_XGXS_FIRST),
+			   FLAGS_INIT_XGXS_FIRST |
+			   FLAGS_TX_ERROR_CHECK),
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -10807,7 +10796,8 @@ static struct bnx2x_phy phy_8727 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= FLAGS_FAN_FAILURE_DET_REQ,
+	.flags		= (FLAGS_FAN_FAILURE_DET_REQ |
+			   FLAGS_TX_ERROR_CHECK),
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -12194,10 +12184,6 @@ static void bnx2x_analyze_link_error(struct link_params *params,
 	u8 led_mode;
 	u32 half_open_conn = (vars->phy_flags & PHY_HALF_OPEN_CONN_FLAG) > 0;
 
-	/*DP(NETIF_MSG_LINK, "CHECK LINK: %x half_open:%x-> lss:%x\n",
-		       vars->link_up,
-		       half_open_conn, lss_status);*/
-
 	if ((lss_status ^ half_open_conn) == 0)
 		return;
 
@@ -12210,6 +12196,7 @@ static void bnx2x_analyze_link_error(struct link_params *params,
 	 * b. Update link_vars->link_up
 	 */
 	if (lss_status) {
+		DP(NETIF_MSG_LINK, "Remote Fault detected !!!\n");
 		vars->link_status &= ~LINK_STATUS_LINK_UP;
 		vars->link_up = 0;
 		vars->phy_flags |= PHY_HALF_OPEN_CONN_FLAG;
@@ -12219,6 +12206,7 @@ static void bnx2x_analyze_link_error(struct link_params *params,
 		 */
 		led_mode = LED_MODE_OFF;
 	} else {
+		DP(NETIF_MSG_LINK, "Remote Fault cleared\n");
 		vars->link_status |= LINK_STATUS_LINK_UP;
 		vars->link_up = 1;
 		vars->phy_flags &= ~PHY_HALF_OPEN_CONN_FLAG;
@@ -12235,6 +12223,15 @@ static void bnx2x_analyze_link_error(struct link_params *params,
 	bnx2x_notify_link_changed(bp);
 }
 
+/******************************************************************************
+* Description:
+*	This function checks for half opened connection change indication.
+*	When such change occurs, it calls the bnx2x_analyze_link_error
+*	to check if Remote Fault is set or cleared. Reception of remote fault
+*	status message in the MAC indicates that the peer's MAC has detected
+*	a fault, for example, due to break in the TX side of fiber.
+*
+******************************************************************************/
 static void bnx2x_check_half_open_conn(struct link_params *params,
 				       struct link_vars *vars)
 {
@@ -12245,9 +12242,28 @@ static void bnx2x_check_half_open_conn(struct link_params *params,
 	if ((vars->phy_flags & PHY_PHYSICAL_LINK_FLAG) == 0)
 		return;
 
-	if (!CHIP_IS_E3(bp) &&
+	if (CHIP_IS_E3(bp) &&
 	    (REG_RD(bp, MISC_REG_RESET_REG_2) &
-		   (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << params->port))) {
+	      (MISC_REGISTERS_RESET_REG_2_XMAC))) {
+		/* Check E3 XMAC */
+		/*
+		 * Note that link speed cannot be queried here, since it may be
+		 * zero while link is down. In case UMAC is active, LSS will
+		 * simply not be set
+		 */
+		mac_base = (params->port) ? GRCBASE_XMAC1 : GRCBASE_XMAC0;
+
+		/* Clear stick bits (Requires rising edge) */
+		REG_WR(bp, mac_base + XMAC_REG_CLEAR_RX_LSS_STATUS, 0);
+		REG_WR(bp, mac_base + XMAC_REG_CLEAR_RX_LSS_STATUS,
+		       XMAC_CLEAR_RX_LSS_STATUS_REG_CLEAR_LOCAL_FAULT_STATUS |
+		       XMAC_CLEAR_RX_LSS_STATUS_REG_CLEAR_REMOTE_FAULT_STATUS);
+		if (REG_RD(bp, mac_base + XMAC_REG_RX_LSS_STATUS))
+			lss_status = 1;
+
+		bnx2x_analyze_link_error(params, vars, lss_status);
+	} else if (REG_RD(bp, MISC_REG_RESET_REG_2) &
+		   (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << params->port)) {
 		/* Check E1X / E2 BMAC */
 		u32 lss_status_reg;
 		u32 wb_data[2];
@@ -12269,14 +12285,20 @@ static void bnx2x_check_half_open_conn(struct link_params *params,
 void bnx2x_period_func(struct link_params *params, struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
+	u16 phy_idx;
 	if (!params) {
-		DP(NETIF_MSG_LINK, "Ininitliazed params !\n");
+		DP(NETIF_MSG_LINK, "Uninitialized params !\n");
 		return;
 	}
-	/* DP(NETIF_MSG_LINK, "Periodic called vars->phy_flags 0x%x speed 0x%x
-	 RESET_REG_2 0x%x\n", vars->phy_flags, vars->line_speed,
-	  REG_RD(bp, MISC_REG_RESET_REG_2)); */
-	bnx2x_check_half_open_conn(params, vars);
+
+	for (phy_idx = INT_PHY; phy_idx < MAX_PHYS; phy_idx++) {
+		if (params->phy[phy_idx].flags & FLAGS_TX_ERROR_CHECK) {
+			bnx2x_set_aer_mmd(params, &params->phy[phy_idx]);
+			bnx2x_check_half_open_conn(params, vars);
+			break;
+		}
+	}
+
 	if (CHIP_IS_E3(bp))
 		bnx2x_check_over_curr(params, vars);
 }
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index 6a7708d..7ee6b51 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -145,6 +145,7 @@ struct bnx2x_phy {
 #define FLAGS_SFP_NOT_APPROVED		(1<<7)
 #define FLAGS_MDC_MDIO_WA		(1<<8)
 #define FLAGS_DUMMY_READ		(1<<9)
+#define FLAGS_TX_ERROR_CHECK		(1<<12)
 
 	/* preemphasis values for the rx side */
 	u16 rx_preemphasis[4];
@@ -276,7 +277,6 @@ struct link_vars {
 #define PHY_PHYSICAL_LINK_FLAG		(1<<2)
 #define PHY_HALF_OPEN_CONN_FLAG		(1<<3)
 #define PHY_OVER_CURRENT_FLAG		(1<<4)
-#define PHY_TX_ERROR_CHECK_FLAG		(1<<5)
 
 	u8 mac_type;
 #define MAC_TYPE_NONE		0
-- 
1.7.1









