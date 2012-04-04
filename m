From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 5/10] bnx2x: Add remote-fault link detection
Date: Wed, 4 Apr 2012 07:41:27 +0300
Message-ID: <1333514492-20425-6-git-send-email-yuvalmin@broadcom.com>
References: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yaniv Rosner" <yaniv.rosner@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4898 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752213Ab2DDEr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 00:47:28 -0400
In-Reply-To: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yaniv.rosner@broadcom.com>

Restore remote-faule detection, which periodically checks for
remote-fault on the MAC layer. In case physical link appear to be
up but fault is set, it will provide a link down indication, and
when the fault is cleared, it will indicate link up again.

Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   69 ++++++++++++++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h |    3 +
 2 files changed, 53 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index beb4cdb..4df6199 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -6440,7 +6440,6 @@ static int bnx2x_link_initialize(struct link_params *params,
 			NIG_STATUS_XGXS0_LINK_STATUS |
 			NIG_STATUS_SERDES0_LINK_STATUS |
 			NIG_MASK_MI_INT));
-	bnx2x_update_mng(params, vars->link_status);
 	return rc;
 }
 
@@ -6525,7 +6524,7 @@ static int bnx2x_update_link_up(struct link_params *params,
 				u8 link_10g)
 {
 	struct bnx2x *bp = params->bp;
-	u8 port = params->port;
+	u8 phy_idx, port = params->port;
 	int rc = 0;
 
 	vars->link_status |= (LINK_STATUS_LINK_UP |
@@ -6589,6 +6588,14 @@ static int bnx2x_update_link_up(struct link_params *params,
 
 	/* update shared memory */
 	bnx2x_update_mng(params, vars->link_status);
+
+	/* Check remote fault */
+	for (phy_idx = INT_PHY; phy_idx < MAX_PHYS; phy_idx++) {
+		if (params->phy[phy_idx].flags & FLAGS_TX_ERROR_CHECK) {
+			bnx2x_check_half_open_conn(params, vars, 0);
+			break;
+		}
+	}
 	msleep(20);
 	return rc;
 }
@@ -11028,7 +11035,8 @@ static struct bnx2x_phy phy_warpcore = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= FLAGS_HW_LOCK_REQUIRED,
+	.flags		= (FLAGS_HW_LOCK_REQUIRED |
+			   FLAGS_TX_ERROR_CHECK),
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -11185,7 +11193,8 @@ static struct bnx2x_phy phy_8726 = {
 	.addr		= 0xff,
 	.def_md_devad	= 0,
 	.flags		= (FLAGS_HW_LOCK_REQUIRED |
-			   FLAGS_INIT_XGXS_FIRST),
+			   FLAGS_INIT_XGXS_FIRST |
+			   FLAGS_TX_ERROR_CHECK),
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -11216,7 +11225,8 @@ static struct bnx2x_phy phy_8727 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= FLAGS_FAN_FAILURE_DET_REQ,
+	.flags		= (FLAGS_FAN_FAILURE_DET_REQ |
+			   FLAGS_TX_ERROR_CHECK),
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -11281,8 +11291,9 @@ static struct bnx2x_phy phy_84823 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= FLAGS_FAN_FAILURE_DET_REQ |
-			  FLAGS_REARM_LATCH_SIGNAL,
+	.flags		= (FLAGS_FAN_FAILURE_DET_REQ |
+			   FLAGS_REARM_LATCH_SIGNAL |
+			   FLAGS_TX_ERROR_CHECK),
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -11317,8 +11328,9 @@ static struct bnx2x_phy phy_84833 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833,
 	.addr		= 0xff,
 	.def_md_devad	= 0,
-	.flags		= FLAGS_FAN_FAILURE_DET_REQ |
-			    FLAGS_REARM_LATCH_SIGNAL,
+	.flags		= (FLAGS_FAN_FAILURE_DET_REQ |
+			   FLAGS_REARM_LATCH_SIGNAL |
+			   FLAGS_TX_ERROR_CHECK),
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
@@ -11863,6 +11875,10 @@ int bnx2x_phy_probe(struct link_params *params)
 		if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN)
 			break;
 
+		if (params->feature_config_flags &
+		    FEATURE_CONFIG_DISABLE_REMOTE_FAULT_DET)
+			phy->flags &= ~FLAGS_TX_ERROR_CHECK;
+
 		sync_offset = params->shmem_base +
 			offsetof(struct shmem_region,
 			dev_info.port_hw_config[params->port].media_type);
@@ -12086,6 +12102,7 @@ int bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		bnx2x_link_int_enable(params);
 		break;
 	}
+	bnx2x_update_mng(params, vars->link_status);
 	return 0;
 }
 
@@ -12703,7 +12720,8 @@ static void bnx2x_check_over_curr(struct link_params *params,
 }
 
 static void bnx2x_analyze_link_error(struct link_params *params,
-				     struct link_vars *vars, u32 lss_status)
+				     struct link_vars *vars, u32 lss_status,
+				     u8 notify)
 {
 	struct bnx2x *bp = params->bp;
 	/* Compare new value with previous value */
@@ -12726,6 +12744,9 @@ static void bnx2x_analyze_link_error(struct link_params *params,
 		vars->link_status &= ~LINK_STATUS_LINK_UP;
 		vars->link_up = 0;
 		vars->phy_flags |= PHY_HALF_OPEN_CONN_FLAG;
+
+		/* activate nig drain */
+		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 1);
 		/*
 		 * Set LED mode to off since the PHY doesn't know about these
 		 * errors
@@ -12737,7 +12758,11 @@ static void bnx2x_analyze_link_error(struct link_params *params,
 		vars->link_up = 1;
 		vars->phy_flags &= ~PHY_HALF_OPEN_CONN_FLAG;
 		led_mode = LED_MODE_OPER;
+
+		/* Clear nig drain */
+		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 0);
 	}
+	bnx2x_sync_link(params, vars);
 	/* Update the LED according to the link state */
 	bnx2x_set_led(params, vars, led_mode, SPEED_10000);
 
@@ -12746,7 +12771,8 @@ static void bnx2x_analyze_link_error(struct link_params *params,
 
 	/* C. Trigger General Attention */
 	vars->periodic_flags |= PERIODIC_FLAGS_LINK_EVENT;
-	bnx2x_notify_link_changed(bp);
+	if (notify)
+		bnx2x_notify_link_changed(bp);
 }
 
 /******************************************************************************
@@ -12758,15 +12784,17 @@ static void bnx2x_analyze_link_error(struct link_params *params,
 *	a fault, for example, due to break in the TX side of fiber.
 *
 ******************************************************************************/
-static void bnx2x_check_half_open_conn(struct link_params *params,
-				       struct link_vars *vars)
+int bnx2x_check_half_open_conn(struct link_params *params,
+				struct link_vars *vars,
+				u8 notify)
 {
 	struct bnx2x *bp = params->bp;
 	u32 lss_status = 0;
 	u32 mac_base;
 	/* In case link status is physically up @ 10G do */
-	if ((vars->phy_flags & PHY_PHYSICAL_LINK_FLAG) == 0)
-		return;
+	if (((vars->phy_flags & PHY_PHYSICAL_LINK_FLAG) == 0) ||
+	    (REG_RD(bp, NIG_REG_EGRESS_EMAC0_PORT + params->port*4)))
+		return 0;
 
 	if (CHIP_IS_E3(bp) &&
 	    (REG_RD(bp, MISC_REG_RESET_REG_2) &
@@ -12787,7 +12815,7 @@ static void bnx2x_check_half_open_conn(struct link_params *params,
 		if (REG_RD(bp, mac_base + XMAC_REG_RX_LSS_STATUS))
 			lss_status = 1;
 
-		bnx2x_analyze_link_error(params, vars, lss_status);
+		bnx2x_analyze_link_error(params, vars, lss_status, notify);
 	} else if (REG_RD(bp, MISC_REG_RESET_REG_2) &
 		   (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << params->port)) {
 		/* Check E1X / E2 BMAC */
@@ -12804,18 +12832,21 @@ static void bnx2x_check_half_open_conn(struct link_params *params,
 		REG_RD_DMAE(bp, mac_base + lss_status_reg, wb_data, 2);
 		lss_status = (wb_data[0] > 0);
 
-		bnx2x_analyze_link_error(params, vars, lss_status);
+		bnx2x_analyze_link_error(params, vars, lss_status, notify);
 	}
+	return 0;
 }
 
 void bnx2x_period_func(struct link_params *params, struct link_vars *vars)
 {
-	struct bnx2x *bp = params->bp;
 	u16 phy_idx;
+	struct bnx2x *bp = params->bp;
 	for (phy_idx = INT_PHY; phy_idx < MAX_PHYS; phy_idx++) {
 		if (params->phy[phy_idx].flags & FLAGS_TX_ERROR_CHECK) {
 			bnx2x_set_aer_mmd(params, &params->phy[phy_idx]);
-			bnx2x_check_half_open_conn(params, vars);
+			if (bnx2x_check_half_open_conn(params, vars, 1) !=
+			    0)
+				DP(NETIF_MSG_LINK, "Fault detection failed\n");
 			break;
 		}
 	}
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 7ba557a..9e2eed8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -254,6 +254,7 @@ struct link_params {
 #define FEATURE_CONFIG_BC_SUPPORTS_DUAL_PHY_OPT_MDL_VRFY	(1<<3)
 #define FEATURE_CONFIG_AUTOGREEEN_ENABLED			(1<<9)
 #define FEATURE_CONFIG_BC_SUPPORTS_SFP_TX_DISABLED		(1<<10)
+#define FEATURE_CONFIG_DISABLE_REMOTE_FAULT_DET		(1<<11)
 	/* Will be populated during common init */
 	struct bnx2x_phy phy[MAX_PHYS];
 
@@ -493,4 +494,6 @@ int bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 
 void bnx2x_period_func(struct link_params *params, struct link_vars *vars);
 
+int bnx2x_check_half_open_conn(struct link_params *params,
+			       struct link_vars *vars, u8 notify);
 #endif /* BNX2X_LINK_H */
-- 
1.7.9.rc2
