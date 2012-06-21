From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next (v2) 1/6] bnx2x: sfp+ Tx fault detection added
Date: Thu, 21 Jun 2012 08:05:18 +0300
Message-ID: <1340255123-22371-2-git-send-email-yuvalmin@broadcom.com>
References: <1340255123-22371-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, joe@perches.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1154 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754437Ab2FUFHa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jun 2012 01:07:30 -0400
In-Reply-To: <1340255123-22371-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds the ability to identify sfp+ modules' Tx fault, and when such
occur shut down the link.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |    2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |  112 ++++++++++++++++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h |    1 +
 3 files changed, 99 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 6b77630..e7c390c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1150,6 +1150,7 @@ struct drv_port_mb {
 	u32 link_status;
 	/* Driver should update this field on any link change event */
 
+	#define LINK_STATUS_NONE				(0<<0)
 	#define LINK_STATUS_LINK_FLAG_MASK			0x00000001
 	#define LINK_STATUS_LINK_UP				0x00000001
 	#define LINK_STATUS_SPEED_AND_DUPLEX_MASK		0x0000001E
@@ -1207,6 +1208,7 @@ struct drv_port_mb {
 	#define LINK_STATUS_PFC_ENABLED				0x20000000
 
 	#define LINK_STATUS_PHYSICAL_LINK_FLAG			0x40000000
+	#define LINK_STATUS_SFP_TX_FAULT			0x80000000
 
 	u32 port_stx;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 91aa565..9e008e4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -4746,6 +4746,8 @@ void bnx2x_sync_link(struct link_params *params,
 		vars->mac_type = MAC_TYPE_NONE;
 		if (vars->link_status & LINK_STATUS_PHYSICAL_LINK_FLAG)
 			vars->phy_flags |= PHY_HALF_OPEN_CONN_FLAG;
+		if (vars->link_status & LINK_STATUS_SFP_TX_FAULT)
+			vars->phy_flags |= PHY_SFP_TX_FAULT_FLAG;
 	}
 }
 
@@ -12925,30 +12927,41 @@ static void bnx2x_check_over_curr(struct link_params *params,
 		vars->phy_flags &= ~PHY_OVER_CURRENT_FLAG;
 }
 
-static void bnx2x_analyze_link_error(struct link_params *params,
-				     struct link_vars *vars, u32 lss_status,
-				     u8 notify)
+/* Returns 0 if no change occured since last check; 1 otherwise. */
+static u8 bnx2x_analyze_link_error(struct link_params *params,
+				    struct link_vars *vars, u32 status,
+				    u32 phy_flag, u32 link_flag, u8 notify)
 {
 	struct bnx2x *bp = params->bp;
 	/* Compare new value with previous value */
 	u8 led_mode;
-	u32 half_open_conn = (vars->phy_flags & PHY_HALF_OPEN_CONN_FLAG) > 0;
+	u32 old_status = (vars->phy_flags & phy_flag) ? 1 : 0;
 
-	if ((lss_status ^ half_open_conn) == 0)
-		return;
+	if ((status ^ old_status) == 0)
+		return 0;
 
 	/* If values differ */
-	DP(NETIF_MSG_LINK, "Link changed:%x %x->%x\n", vars->link_up,
-		       half_open_conn, lss_status);
+	switch (phy_flag) {
+	case PHY_HALF_OPEN_CONN_FLAG:
+		DP(NETIF_MSG_LINK, "Analyze Remote Fault\n");
+		break;
+	case PHY_SFP_TX_FAULT_FLAG:
+		DP(NETIF_MSG_LINK, "Analyze TX Fault\n");
+		break;
+	default:
+		DP(NETIF_MSG_LINK, "Analyze UNKOWN\n");
+	}
+	DP(NETIF_MSG_LINK, "Link changed:[%x %x]->%x\n", vars->link_up,
+	   old_status, status);
 
 	/* a. Update shmem->link_status accordingly
 	 * b. Update link_vars->link_up
 	 */
-	if (lss_status) {
-		DP(NETIF_MSG_LINK, "Remote Fault detected !!!\n");
+	if (status) {
 		vars->link_status &= ~LINK_STATUS_LINK_UP;
+		vars->link_status |= link_flag;
 		vars->link_up = 0;
-		vars->phy_flags |= PHY_HALF_OPEN_CONN_FLAG;
+		vars->phy_flags |= phy_flag;
 
 		/* activate nig drain */
 		REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4, 1);
@@ -12957,10 +12970,10 @@ static void bnx2x_analyze_link_error(struct link_params *params,
 		 */
 		led_mode = LED_MODE_OFF;
 	} else {
-		DP(NETIF_MSG_LINK, "Remote Fault cleared\n");
 		vars->link_status |= LINK_STATUS_LINK_UP;
+		vars->link_status &= ~link_flag;
 		vars->link_up = 1;
-		vars->phy_flags &= ~PHY_HALF_OPEN_CONN_FLAG;
+		vars->phy_flags &= ~phy_flag;
 		led_mode = LED_MODE_OPER;
 
 		/* Clear nig drain */
@@ -12977,6 +12990,8 @@ static void bnx2x_analyze_link_error(struct link_params *params,
 	vars->periodic_flags |= PERIODIC_FLAGS_LINK_EVENT;
 	if (notify)
 		bnx2x_notify_link_changed(bp);
+
+	return 1;
 }
 
 /******************************************************************************
@@ -13018,7 +13033,9 @@ int bnx2x_check_half_open_conn(struct link_params *params,
 		if (REG_RD(bp, mac_base + XMAC_REG_RX_LSS_STATUS))
 			lss_status = 1;
 
-		bnx2x_analyze_link_error(params, vars, lss_status, notify);
+		bnx2x_analyze_link_error(params, vars, lss_status,
+					 PHY_HALF_OPEN_CONN_FLAG,
+					 LINK_STATUS_NONE, notify);
 	} else if (REG_RD(bp, MISC_REG_RESET_REG_2) &
 		   (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << params->port)) {
 		/* Check E1X / E2 BMAC */
@@ -13035,11 +13052,55 @@ int bnx2x_check_half_open_conn(struct link_params *params,
 		REG_RD_DMAE(bp, mac_base + lss_status_reg, wb_data, 2);
 		lss_status = (wb_data[0] > 0);
 
-		bnx2x_analyze_link_error(params, vars, lss_status, notify);
+		bnx2x_analyze_link_error(params, vars, lss_status,
+					 PHY_HALF_OPEN_CONN_FLAG,
+					 LINK_STATUS_NONE, notify);
 	}
 	return 0;
 }
+static void bnx2x_sfp_tx_fault_detection(struct bnx2x_phy *phy,
+					 struct link_params *params,
+					 struct link_vars *vars)
+{
+	struct bnx2x *bp = params->bp;
+	u32 cfg_pin, value = 0;
+	u8 led_change, port = params->port;
 
+	/* Get The SFP+ TX_Fault controlling pin ([eg]pio) */
+	cfg_pin = (REG_RD(bp, params->shmem_base + offsetof(struct shmem_region,
+			  dev_info.port_hw_config[port].e3_cmn_pin_cfg)) &
+		   PORT_HW_CFG_E3_TX_FAULT_MASK) >>
+		  PORT_HW_CFG_E3_TX_FAULT_SHIFT;
+
+	if (bnx2x_get_cfg_pin(bp, cfg_pin, &value)) {
+		DP(NETIF_MSG_LINK, "Failed to read pin 0x%02x\n", cfg_pin);
+		return;
+	}
+
+	led_change = bnx2x_analyze_link_error(params, vars, value,
+					      PHY_SFP_TX_FAULT_FLAG,
+					      LINK_STATUS_SFP_TX_FAULT, 1);
+
+	if (led_change) {
+		/* Change TX_Fault led, set link status for further syncs */
+		u8 led_mode;
+
+		if (vars->phy_flags & PHY_SFP_TX_FAULT_FLAG) {
+			led_mode = MISC_REGISTERS_GPIO_HIGH;
+			vars->link_status |= LINK_STATUS_SFP_TX_FAULT;
+		} else {
+			led_mode = MISC_REGISTERS_GPIO_LOW;
+			vars->link_status &= ~LINK_STATUS_SFP_TX_FAULT;
+		}
+
+		/* If module is unapproved, led should be on regardless */
+		if (!(phy->flags & FLAGS_SFP_NOT_APPROVED)) {
+			DP(NETIF_MSG_LINK, "Change TX_Fault LED: ->%x\n",
+			   led_mode);
+			bnx2x_set_e3_module_fault_led(params, led_mode);
+		}
+	}
+}
 void bnx2x_period_func(struct link_params *params, struct link_vars *vars)
 {
 	u16 phy_idx;
@@ -13058,7 +13119,26 @@ void bnx2x_period_func(struct link_params *params, struct link_vars *vars)
 		struct bnx2x_phy *phy = &params->phy[INT_PHY];
 		bnx2x_set_aer_mmd(params, phy);
 		bnx2x_check_over_curr(params, vars);
-		bnx2x_warpcore_config_runtime(phy, params, vars);
+		if (vars->rx_tx_asic_rst)
+			bnx2x_warpcore_config_runtime(phy, params, vars);
+
+		if ((REG_RD(bp, params->shmem_base +
+			    offsetof(struct shmem_region, dev_info.
+				port_hw_config[params->port].default_cfg))
+		    & PORT_HW_CFG_NET_SERDES_IF_MASK) ==
+		    PORT_HW_CFG_NET_SERDES_IF_SFI) {
+			if (bnx2x_is_sfp_module_plugged(phy, params)) {
+				bnx2x_sfp_tx_fault_detection(phy, params, vars);
+			} else if (vars->link_status &
+				LINK_STATUS_SFP_TX_FAULT) {
+				/* Clean trail, interrupt corrects the leds */
+				vars->link_status &= ~LINK_STATUS_SFP_TX_FAULT;
+				vars->phy_flags &= ~PHY_SFP_TX_FAULT_FLAG;
+				/* Update link status in the shared memory */
+				bnx2x_update_mng(params, vars->link_status);
+			}
+		}
+
 	}
 
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index e920800..cd1f271 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -307,6 +307,7 @@ struct link_vars {
 #define PHY_PHYSICAL_LINK_FLAG		(1<<2)
 #define PHY_HALF_OPEN_CONN_FLAG		(1<<3)
 #define PHY_OVER_CURRENT_FLAG		(1<<4)
+#define PHY_SFP_TX_FAULT_FLAG		(1<<5)
 
 	u8 mac_type;
 #define MAC_TYPE_NONE		0
-- 
1.7.9.rc2
