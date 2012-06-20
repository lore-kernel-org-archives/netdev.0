From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 2/6] bnx2x: link cleanup
Date: Wed, 20 Jun 2012 11:49:31 +0300
Message-ID: <1340182175-916-3-git-send-email-yuvalmin@broadcom.com>
References: <1340182175-916-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1959 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755667Ab2FTIvw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:51:52 -0400
In-Reply-To: <1340182175-916-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does several things:
 1. Add static to function when possible.
 2. Correct comments.
 3. Change msleep(1) --> usleep_range(1000, 1000)
 4. Remove dead code.
 5. Change 'if(rc != 0)' --> if(rc)

Most of these changes are purely semantic.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Yaniv Rosner <yaniv.rosner@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |  309 +++++++++++-----------
 1 files changed, 152 insertions(+), 157 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 9e008e4..121275e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -284,7 +284,6 @@
 #define ETS_E3B0_PBF_MIN_W_VAL				(10000)
 
 #define MAX_PACKET_SIZE					(9700)
-#define WC_UC_TIMEOUT					100
 #define MAX_KR_LINK_RETRY				4
 
 /**********************************************************/
@@ -1880,11 +1879,6 @@ static int bnx2x_emac_enable(struct link_params *params,
 	bnx2x_bits_en(bp, emac_base + EMAC_REG_EMAC_TX_MODE,
 		      EMAC_TX_MODE_RESET);
 
-	if (CHIP_REV_IS_SLOW(bp)) {
-		/* config GMII mode */
-		val = REG_RD(bp, emac_base + EMAC_REG_EMAC_MODE);
-		EMAC_WR(bp, EMAC_REG_EMAC_MODE, (val | EMAC_MODE_PORT_GMII));
-	} else { /* ASIC */
 		/* pause enable/disable */
 		bnx2x_bits_dis(bp, emac_base + EMAC_REG_EMAC_RX_MODE,
 			       EMAC_RX_MODE_FLOW_EN);
@@ -1907,7 +1901,6 @@ static int bnx2x_emac_enable(struct link_params *params,
 		} else
 			bnx2x_bits_en(bp, emac_base + EMAC_REG_EMAC_TX_MODE,
 				      EMAC_TX_MODE_FLOW_EN);
-	}
 
 	/* KEEP_VLAN_TAG, promiscuous */
 	val = REG_RD(bp, emac_base + EMAC_REG_EMAC_RX_MODE);
@@ -1946,23 +1939,23 @@ static int bnx2x_emac_enable(struct link_params *params,
 		val &= ~0x810;
 	EMAC_WR(bp, EMAC_REG_EMAC_MODE, val);
 
-	/* enable emac */
+	/* Enable emac */
 	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 1);
 
-	/* enable emac for jumbo packets */
+	/* Enable emac for jumbo packets */
 	EMAC_WR(bp, EMAC_REG_EMAC_RX_MTU_SIZE,
 		(EMAC_RX_MTU_SIZE_JUMBO_ENA |
 		 (ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD)));
 
-	/* strip CRC */
+	/* Strip CRC */
 	REG_WR(bp, NIG_REG_NIG_INGRESS_EMAC0_NO_CRC + port*4, 0x1);
 
-	/* disable the NIG in/out to the bmac */
+	/* Disable the NIG in/out to the bmac */
 	REG_WR(bp, NIG_REG_BMAC0_IN_EN + port*4, 0x0);
 	REG_WR(bp, NIG_REG_BMAC0_PAUSE_OUT_EN + port*4, 0x0);
 	REG_WR(bp, NIG_REG_BMAC0_OUT_EN + port*4, 0x0);
 
-	/* enable the NIG in/out to the emac */
+	/* Enable the NIG in/out to the emac */
 	REG_WR(bp, NIG_REG_EMAC0_IN_EN + port*4, 0x1);
 	val = 0;
 	if ((params->feature_config_flags &
@@ -1997,7 +1990,7 @@ static void bnx2x_update_pfc_bmac1(struct link_params *params,
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_CONTROL, wb_data, 2);
 
-	/* tx control */
+	/* TX control */
 	val = 0xc0;
 	if (!(params->feature_config_flags &
 	      FEATURE_CONFIG_PFC_ENABLED) &&
@@ -2057,7 +2050,7 @@ static void bnx2x_update_pfc_bmac2(struct link_params *params,
 		wb_data[0] &= ~(1<<2);
 	} else {
 		DP(NETIF_MSG_LINK, "PFC is disabled\n");
-		/* disable PFC RX & TX & STATS and set 8 COS */
+		/* Disable PFC RX & TX & STATS and set 8 COS */
 		wb_data[0] = 0x8;
 		wb_data[1] = 0;
 	}
@@ -2151,7 +2144,7 @@ static int bnx2x_pfc_brb_get_config_params(
 			PFC_E2_BRB_MAC_FULL_XOFF_THR_PAUSE;
 		config_val->pauseable_th.full_xon =
 			PFC_E2_BRB_MAC_FULL_XON_THR_PAUSE;
-		/* non pause able*/
+		/* Non pause able*/
 		config_val->non_pauseable_th.pause_xoff =
 			PFC_E2_BRB_MAC_PAUSE_XOFF_THR_NON_PAUSE;
 		config_val->non_pauseable_th.pause_xon =
@@ -2179,7 +2172,7 @@ static int bnx2x_pfc_brb_get_config_params(
 			PFC_E3A0_BRB_MAC_FULL_XOFF_THR_PAUSE;
 		config_val->pauseable_th.full_xon =
 			PFC_E3A0_BRB_MAC_FULL_XON_THR_PAUSE;
-		/* non pause able*/
+		/* Non pause able*/
 		config_val->non_pauseable_th.pause_xoff =
 			PFC_E3A0_BRB_MAC_PAUSE_XOFF_THR_NON_PAUSE;
 		config_val->non_pauseable_th.pause_xon =
@@ -2209,7 +2202,7 @@ static int bnx2x_pfc_brb_get_config_params(
 				PFC_E3B0_4P_BRB_MAC_FULL_XOFF_THR_PAUSE;
 			config_val->pauseable_th.full_xon =
 				PFC_E3B0_4P_BRB_MAC_FULL_XON_THR_PAUSE;
-			/* non pause able*/
+			/* Non pause able*/
 			config_val->non_pauseable_th.pause_xoff =
 			PFC_E3B0_4P_BRB_MAC_PAUSE_XOFF_THR_NON_PAUSE;
 			config_val->non_pauseable_th.pause_xon =
@@ -2227,7 +2220,7 @@ static int bnx2x_pfc_brb_get_config_params(
 				PFC_E3B0_2P_BRB_MAC_FULL_XOFF_THR_PAUSE;
 			config_val->pauseable_th.full_xon =
 				PFC_E3B0_2P_BRB_MAC_FULL_XON_THR_PAUSE;
-			/* non pause able*/
+			/* Non pause able*/
 			config_val->non_pauseable_th.pause_xoff =
 				PFC_E3B0_2P_BRB_MAC_PAUSE_XOFF_THR_NON_PAUSE;
 			config_val->non_pauseable_th.pause_xon =
@@ -2284,7 +2277,7 @@ static void bnx2x_pfc_brb_get_e3b0_config_params(
 
 			if (pfc_params->cos0_pauseable !=
 				pfc_params->cos1_pauseable) {
-				/* nonpauseable= Lossy + pauseable = Lossless*/
+				/* Nonpauseable= Lossy + pauseable = Lossless*/
 				e3b0_val->lb_guarantied =
 					PFC_E3B0_2P_MIX_PAUSE_LB_GUART;
 				e3b0_val->mac_0_class_t_guarantied =
@@ -2483,9 +2476,9 @@ static int bnx2x_update_pfc_brb(struct link_params *params,
 *  This function is needed because NIG ARB_CREDIT_WEIGHT_X are
 *  not continues and ARB_CREDIT_WEIGHT_0 + offset is suitable.
 ******************************************************************************/
-int bnx2x_pfc_nig_rx_priority_mask(struct bnx2x *bp,
-					      u8 cos_entry,
-					      u32 priority_mask, u8 port)
+static int bnx2x_pfc_nig_rx_priority_mask(struct bnx2x *bp,
+					   u8 cos_entry,
+					   u32 priority_mask, u8 port)
 {
 	u32 nig_reg_rx_priority_mask_add = 0;
 
@@ -2612,7 +2605,7 @@ static void bnx2x_update_pfc_nig(struct link_params *params,
 	REG_WR(bp, port ? NIG_REG_LLFC_EGRESS_SRC_ENABLE_1 :
 	       NIG_REG_LLFC_EGRESS_SRC_ENABLE_0, 0x7);
 
-	/* output enable for RX_XCM # IF */
+	/* Output enable for RX_XCM # IF */
 	REG_WR(bp, port ? NIG_REG_XCM1_OUT_EN :
 	       NIG_REG_XCM0_OUT_EN, xcm_out_en);
 
@@ -2661,10 +2654,10 @@ int bnx2x_update_pfc(struct link_params *params,
 
 	bnx2x_update_mng(params, vars->link_status);
 
-	/* update NIG params */
+	/* Update NIG params */
 	bnx2x_update_pfc_nig(params, vars, pfc_params);
 
-	/* update BRB params */
+	/* Update BRB params */
 	bnx2x_status = bnx2x_update_pfc_brb(params, vars, pfc_params);
 	if (bnx2x_status)
 		return bnx2x_status;
@@ -2719,7 +2712,7 @@ static int bnx2x_bmac1_enable(struct link_params *params,
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_XGXS_CONTROL,
 		    wb_data, 2);
 
-	/* tx MAC SA */
+	/* TX MAC SA */
 	wb_data[0] = ((params->mac_addr[2] << 24) |
 		       (params->mac_addr[3] << 16) |
 		       (params->mac_addr[4] << 8) |
@@ -2728,7 +2721,7 @@ static int bnx2x_bmac1_enable(struct link_params *params,
 			params->mac_addr[1]);
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_SOURCE_ADDR, wb_data, 2);
 
-	/* mac control */
+	/* MAC control */
 	val = 0x3;
 	if (is_lb) {
 		val |= 0x4;
@@ -2738,24 +2731,24 @@ static int bnx2x_bmac1_enable(struct link_params *params,
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_BMAC_CONTROL, wb_data, 2);
 
-	/* set rx mtu */
+	/* Set rx mtu */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_MAX_SIZE, wb_data, 2);
 
 	bnx2x_update_pfc_bmac1(params, vars);
 
-	/* set tx mtu */
+	/* Set tx mtu */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_TX_MAX_SIZE, wb_data, 2);
 
-	/* set cnt max size */
+	/* Set cnt max size */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_CNT_MAX_SIZE, wb_data, 2);
 
-	/* configure safc */
+	/* Configure SAFC */
 	wb_data[0] = 0x1000200;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC_REGISTER_RX_LLFC_MSG_FLDS,
@@ -2789,7 +2782,7 @@ static int bnx2x_bmac2_enable(struct link_params *params,
 
 	udelay(30);
 
-	/* tx MAC SA */
+	/* TX MAC SA */
 	wb_data[0] = ((params->mac_addr[2] << 24) |
 		       (params->mac_addr[3] << 16) |
 		       (params->mac_addr[4] << 8) |
@@ -2808,18 +2801,18 @@ static int bnx2x_bmac2_enable(struct link_params *params,
 		    wb_data, 2);
 	udelay(30);
 
-	/* set rx mtu */
+	/* Set RX MTU */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_RX_MAX_SIZE, wb_data, 2);
 	udelay(30);
 
-	/* set tx mtu */
+	/* Set TX MTU */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_TX_MAX_SIZE, wb_data, 2);
 	udelay(30);
-	/* set cnt max size */
+	/* Set cnt max size */
 	wb_data[0] = ETH_MAX_JUMBO_PACKET_SIZE + ETH_OVREHEAD - 2;
 	wb_data[1] = 0;
 	REG_WR_DMAE(bp, bmac_addr + BIGMAC2_REGISTER_CNT_MAX_SIZE, wb_data, 2);
@@ -2837,15 +2830,15 @@ static int bnx2x_bmac_enable(struct link_params *params,
 	u8 port = params->port;
 	struct bnx2x *bp = params->bp;
 	u32 val;
-	/* reset and unreset the BigMac */
+	/* Reset and unreset the BigMac */
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
 	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
-	msleep(1);
+	usleep_range(1000, 1000);
 
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET,
 	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
 
-	/* enable access for bmac registers */
+	/* Enable access for bmac registers */
 	REG_WR(bp, NIG_REG_BMAC0_REGS_OUT_EN + port*4, 0x1);
 
 	/* Enable BMAC according to BMAC type*/
@@ -2903,7 +2896,7 @@ static void bnx2x_bmac_rx_disable(struct bnx2x *bp, u8 port)
 					BIGMAC_REGISTER_BMAC_CONTROL,
 					wb_data, 2);
 		}
-		msleep(1);
+		usleep_range(1000, 1000);
 	}
 }
 
@@ -2915,10 +2908,10 @@ static int bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 	u32 init_crd, crd;
 	u32 count = 1000;
 
-	/* disable port */
+	/* Disable port */
 	REG_WR(bp, PBF_REG_DISABLE_NEW_TASK_PROC_P0 + port*4, 0x1);
 
-	/* wait for init credit */
+	/* Wait for init credit */
 	init_crd = REG_RD(bp, PBF_REG_P0_INIT_CRD + port*4);
 	crd = REG_RD(bp, PBF_REG_P0_CREDIT + port*8);
 	DP(NETIF_MSG_LINK, "init_crd 0x%x  crd 0x%x\n", init_crd, crd);
@@ -2942,18 +2935,18 @@ static int bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 	    line_speed == SPEED_1000 ||
 	    line_speed == SPEED_2500) {
 		REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + port*4, 1);
-		/* update threshold */
+		/* Update threshold */
 		REG_WR(bp, PBF_REG_P0_ARB_THRSH + port*4, 0);
-		/* update init credit */
+		/* Update init credit */
 		init_crd = 778;		/* (800-18-4) */
 
 	} else {
 		u32 thresh = (ETH_MAX_JUMBO_PACKET_SIZE +
 			      ETH_OVREHEAD)/16;
 		REG_WR(bp, PBF_REG_P0_PAUSE_ENABLE + port*4, 0);
-		/* update threshold */
+		/* Update threshold */
 		REG_WR(bp, PBF_REG_P0_ARB_THRSH + port*4, thresh);
-		/* update init credit */
+		/* Update init credit */
 		switch (line_speed) {
 		case SPEED_10000:
 			init_crd = thresh + 553 - 22;
@@ -2968,12 +2961,12 @@ static int bnx2x_pbf_update(struct link_params *params, u32 flow_ctrl,
 	DP(NETIF_MSG_LINK, "PBF updated to speed %d credit %d\n",
 		 line_speed, init_crd);
 
-	/* probe the credit changes */
+	/* Probe the credit changes */
 	REG_WR(bp, PBF_REG_INIT_P0 + port*4, 0x1);
 	msleep(5);
 	REG_WR(bp, PBF_REG_INIT_P0 + port*4, 0x0);
 
-	/* enable port */
+	/* Enable port */
 	REG_WR(bp, PBF_REG_DISABLE_NEW_TASK_PROC_P0 + port*4, 0x0);
 	return 0;
 }
@@ -3040,7 +3033,7 @@ static int bnx2x_cl22_write(struct bnx2x *bp,
 	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE,
 	       mode & ~EMAC_MDIO_MODE_CLAUSE_45);
 
-	/* address */
+	/* Address */
 	tmp = ((phy->addr << 21) | (reg << 16) | val |
 	       EMAC_MDIO_COMM_COMMAND_WRITE_22 |
 	       EMAC_MDIO_COMM_START_BUSY);
@@ -3076,7 +3069,7 @@ static int bnx2x_cl22_read(struct bnx2x *bp,
 	REG_WR(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_MODE,
 	       mode & ~EMAC_MDIO_MODE_CLAUSE_45);
 
-	/* address */
+	/* Address */
 	val = ((phy->addr << 21) | (reg << 16) |
 	       EMAC_MDIO_COMM_COMMAND_READ_22 |
 	       EMAC_MDIO_COMM_START_BUSY);
@@ -3114,7 +3107,7 @@ static int bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
 	if (phy->flags & FLAGS_MDC_MDIO_WA_B0)
 		bnx2x_bits_en(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_STATUS,
 			      EMAC_MDIO_STATUS_10MB);
-	/* address */
+	/* Address */
 	val = ((phy->addr << 21) | (devad << 16) | reg |
 	       EMAC_MDIO_COMM_COMMAND_ADDRESS |
 	       EMAC_MDIO_COMM_START_BUSY);
@@ -3135,7 +3128,7 @@ static int bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
 		*ret_val = 0;
 		rc = -EFAULT;
 	} else {
-		/* data */
+		/* Data */
 		val = ((phy->addr << 21) | (devad << 16) |
 		       EMAC_MDIO_COMM_COMMAND_READ_45 |
 		       EMAC_MDIO_COMM_START_BUSY);
@@ -3183,7 +3176,7 @@ static int bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
 		bnx2x_bits_en(bp, phy->mdio_ctrl + EMAC_REG_EMAC_MDIO_STATUS,
 			      EMAC_MDIO_STATUS_10MB);
 
-	/* address */
+	/* Address */
 	tmp = ((phy->addr << 21) | (devad << 16) | reg |
 	       EMAC_MDIO_COMM_COMMAND_ADDRESS |
 	       EMAC_MDIO_COMM_START_BUSY);
@@ -3203,7 +3196,7 @@ static int bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
 		netdev_err(bp->dev,  "MDC/MDIO access timeout\n");
 		rc = -EFAULT;
 	} else {
-		/* data */
+		/* Data */
 		tmp = ((phy->addr << 21) | (devad << 16) | val |
 		       EMAC_MDIO_COMM_COMMAND_WRITE_45 |
 		       EMAC_MDIO_COMM_START_BUSY);
@@ -3293,23 +3286,23 @@ static int bnx2x_bsc_read(struct link_params *params,
 
 	xfer_cnt = 16 - lc_addr;
 
-	/* enable the engine */
+	/* Enable the engine */
 	val = REG_RD(bp, MCP_REG_MCPR_IMC_COMMAND);
 	val |= MCPR_IMC_COMMAND_ENABLE;
 	REG_WR(bp, MCP_REG_MCPR_IMC_COMMAND, val);
 
-	/* program slave device ID */
+	/* Program slave device ID */
 	val = (sl_devid << 16) | sl_addr;
 	REG_WR(bp, MCP_REG_MCPR_IMC_SLAVE_CONTROL, val);
 
-	/* start xfer with 0 byte to update the address pointer ???*/
+	/* Start xfer with 0 byte to update the address pointer ???*/
 	val = (MCPR_IMC_COMMAND_ENABLE) |
 	      (MCPR_IMC_COMMAND_WRITE_OP <<
 		MCPR_IMC_COMMAND_OPERATION_BITSHIFT) |
 		(lc_addr << MCPR_IMC_COMMAND_TRANSFER_ADDRESS_BITSHIFT) | (0);
 	REG_WR(bp, MCP_REG_MCPR_IMC_COMMAND, val);
 
-	/* poll for completion */
+	/* Poll for completion */
 	i = 0;
 	val = REG_RD(bp, MCP_REG_MCPR_IMC_COMMAND);
 	while (((val >> MCPR_IMC_COMMAND_IMC_STATUS_BITSHIFT) & 0x3) != 1) {
@@ -3325,7 +3318,7 @@ static int bnx2x_bsc_read(struct link_params *params,
 	if (rc == -EFAULT)
 		return rc;
 
-	/* start xfer with read op */
+	/* Start xfer with read op */
 	val = (MCPR_IMC_COMMAND_ENABLE) |
 		(MCPR_IMC_COMMAND_READ_OP <<
 		MCPR_IMC_COMMAND_OPERATION_BITSHIFT) |
@@ -3333,7 +3326,7 @@ static int bnx2x_bsc_read(struct link_params *params,
 		  (xfer_cnt);
 	REG_WR(bp, MCP_REG_MCPR_IMC_COMMAND, val);
 
-	/* poll for completion */
+	/* Poll for completion */
 	i = 0;
 	val = REG_RD(bp, MCP_REG_MCPR_IMC_COMMAND);
 	while (((val >> MCPR_IMC_COMMAND_IMC_STATUS_BITSHIFT) & 0x3) != 1) {
@@ -3436,7 +3429,7 @@ static u8 bnx2x_get_warpcore_lane(struct bnx2x_phy *phy,
 			port = port ^ 1;
 
 		lane = (port<<1) + path;
-	} else { /* two port mode - no port swap */
+	} else { /* Two port mode - no port swap */
 
 		/* Figure out path swap value */
 		path_swap_ovr =
@@ -3514,7 +3507,7 @@ static void bnx2x_serdes_deassert(struct bnx2x *bp, u8 port)
 
 	val = SERDES_RESET_BITS << (port*16);
 
-	/* reset and unreset the SerDes/XGXS */
+	/* Reset and unreset the SerDes/XGXS */
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR, val);
 	udelay(500);
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET, val);
@@ -3535,7 +3528,7 @@ static void bnx2x_xgxs_deassert(struct link_params *params)
 
 	val = XGXS_RESET_BITS << (port*16);
 
-	/* reset and unreset the SerDes/XGXS */
+	/* Reset and unreset the SerDes/XGXS */
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR, val);
 	udelay(500);
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_SET, val);
@@ -3627,7 +3620,7 @@ static void bnx2x_ext_phy_set_pause(struct link_params *params,
 {
 	u16 val;
 	struct bnx2x *bp = params->bp;
-	/* read modify write pause advertizing */
+	/* Read modify write pause advertizing */
 	bnx2x_cl45_read(bp, phy, MDIO_AN_DEVAD, MDIO_AN_REG_ADV_PAUSE, &val);
 
 	val &= ~MDIO_AN_REG_ADV_PAUSE_BOTH;
@@ -3945,7 +3938,7 @@ static void bnx2x_warpcore_set_10G_KR(struct bnx2x_phy *phy,
 	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
 				 MDIO_WC_REG_RX66_CONTROL, 0xF9);
 
-	/* set and clear loopback to cause a reset to 64/66 decoder */
+	/* Set and clear loopback to cause a reset to 64/66 decoder */
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 			 MDIO_WC_REG_IEEE0BLK_MIICNTL, 0x4000);
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
@@ -4373,7 +4366,7 @@ static void bnx2x_warpcore_config_runtime(struct bnx2x_phy *phy,
 	if (!vars->turn_to_run_wc_rt)
 		return;
 
-	/* return if there is no link partner */
+	/* Return if there is no link partner */
 	if (!(bnx2x_warpcore_get_sigdet(phy, params))) {
 		DP(NETIF_MSG_LINK, "bnx2x_warpcore_get_sigdet false\n");
 		return;
@@ -4407,7 +4400,7 @@ static void bnx2x_warpcore_config_runtime(struct bnx2x_phy *phy,
 				bnx2x_warpcore_reset_lane(bp, phy, 1);
 				bnx2x_warpcore_reset_lane(bp, phy, 0);
 
-				/* restart Autoneg */
+				/* Restart Autoneg */
 				bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
 					MDIO_WC_REG_IEEE0BLK_MIICNTL, 0x1200);
 
@@ -4645,8 +4638,9 @@ static void bnx2x_set_warpcore_loopback(struct bnx2x_phy *phy,
 }
 
 
-void bnx2x_sync_link(struct link_params *params,
-			   struct link_vars *vars)
+
+static void bnx2x_sync_link(struct link_params *params,
+			     struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u8 link_10g_plus;
@@ -4719,7 +4713,7 @@ void bnx2x_sync_link(struct link_params *params,
 		    USES_WARPCORE(bp) &&
 		    (vars->line_speed == SPEED_1000))
 			vars->phy_flags |= PHY_SGMII_FLAG;
-		/* anything 10 and over uses the bmac */
+		/* Anything 10 and over uses the bmac */
 		link_10g_plus = (vars->line_speed >= SPEED_10000);
 
 		if (link_10g_plus) {
@@ -4733,7 +4727,7 @@ void bnx2x_sync_link(struct link_params *params,
 			else
 				vars->mac_type = MAC_TYPE_EMAC;
 		}
-	} else { /* link down */
+	} else { /* Link down */
 		DP(NETIF_MSG_LINK, "phy link down\n");
 
 		vars->phy_link_up = 0;
@@ -4742,7 +4736,7 @@ void bnx2x_sync_link(struct link_params *params,
 		vars->duplex = DUPLEX_FULL;
 		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
 
-		/* indicate no mac active */
+		/* Indicate no mac active */
 		vars->mac_type = MAC_TYPE_NONE;
 		if (vars->link_status & LINK_STATUS_PHYSICAL_LINK_FLAG)
 			vars->phy_flags |= PHY_HALF_OPEN_CONN_FLAG;
@@ -4813,7 +4807,7 @@ static void bnx2x_set_master_ln(struct link_params *params,
 		     PORT_HW_CFG_LANE_SWAP_CFG_MASTER_MASK) >>
 		    PORT_HW_CFG_LANE_SWAP_CFG_MASTER_SHIFT);
 
-	/* set the master_ln for AN */
+	/* Set the master_ln for AN */
 	CL22_RD_OVER_CL45(bp, phy,
 			  MDIO_REG_BANK_XGXS_BLOCK2,
 			  MDIO_XGXS_BLOCK2_TEST_MODE_LANE,
@@ -4836,7 +4830,7 @@ static int bnx2x_reset_unicore(struct link_params *params,
 			  MDIO_REG_BANK_COMBO_IEEE0,
 			  MDIO_COMBO_IEEE0_MII_CONTROL, &mii_control);
 
-	/* reset the unicore */
+	/* Reset the unicore */
 	CL22_WR_OVER_CL45(bp, phy,
 			  MDIO_REG_BANK_COMBO_IEEE0,
 			  MDIO_COMBO_IEEE0_MII_CONTROL,
@@ -4845,11 +4839,11 @@ static int bnx2x_reset_unicore(struct link_params *params,
 	if (set_serdes)
 		bnx2x_set_serdes_access(bp, params->port);
 
-	/* wait for the reset to self clear */
+	/* Wait for the reset to self clear */
 	for (i = 0; i < MDIO_ACCESS_TIMEOUT; i++) {
 		udelay(5);
 
-		/* the reset erased the previous bank value */
+		/* The reset erased the previous bank value */
 		CL22_RD_OVER_CL45(bp, phy,
 				  MDIO_REG_BANK_COMBO_IEEE0,
 				  MDIO_COMBO_IEEE0_MII_CONTROL,
@@ -5067,7 +5061,7 @@ static void bnx2x_set_autoneg(struct bnx2x_phy *phy,
 			  MDIO_CL73_IEEEB0_CL73_AN_CONTROL, reg_val);
 }
 
-/* program SerDes, forced speed */
+/* Program SerDes, forced speed */
 static void bnx2x_program_serdes(struct bnx2x_phy *phy,
 				 struct link_params *params,
 				 struct link_vars *vars)
@@ -5075,7 +5069,7 @@ static void bnx2x_program_serdes(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 reg_val;
 
-	/* program duplex, disable autoneg and sgmii*/
+	/* Program duplex, disable autoneg and sgmii*/
 	CL22_RD_OVER_CL45(bp, phy,
 			  MDIO_REG_BANK_COMBO_IEEE0,
 			  MDIO_COMBO_IEEE0_MII_CONTROL, &reg_val);
@@ -5094,7 +5088,7 @@ static void bnx2x_program_serdes(struct bnx2x_phy *phy,
 	CL22_RD_OVER_CL45(bp, phy,
 			  MDIO_REG_BANK_SERDES_DIGITAL,
 			  MDIO_SERDES_DIGITAL_MISC1, &reg_val);
-	/* clearing the speed value before setting the right speed */
+	/* Clearing the speed value before setting the right speed */
 	DP(NETIF_MSG_LINK, "MDIO_REG_BANK_SERDES_DIGITAL = 0x%x\n", reg_val);
 
 	reg_val &= ~(MDIO_SERDES_DIGITAL_MISC1_FORCE_SPEED_MASK |
@@ -5123,7 +5117,7 @@ static void bnx2x_set_brcm_cl37_advertisement(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 val = 0;
 
-	/* set extended capabilities */
+	/* Set extended capabilities */
 	if (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G)
 		val |= MDIO_OVER_1G_UP1_2_5G;
 	if (phy->speed_cap_mask & PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)
@@ -5143,7 +5137,7 @@ static void bnx2x_set_ieee_aneg_advertisement(struct bnx2x_phy *phy,
 {
 	struct bnx2x *bp = params->bp;
 	u16 val;
-	/* for AN, we are always publishing full duplex */
+	/* For AN, we are always publishing full duplex */
 
 	CL22_WR_OVER_CL45(bp, phy,
 			  MDIO_REG_BANK_COMBO_IEEE0,
@@ -5205,14 +5199,14 @@ static void bnx2x_initialize_sgmii_process(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 control1;
 
-	/* in SGMII mode, the unicore is always slave */
+	/* In SGMII mode, the unicore is always slave */
 
 	CL22_RD_OVER_CL45(bp, phy,
 			  MDIO_REG_BANK_SERDES_DIGITAL,
 			  MDIO_SERDES_DIGITAL_A_1000X_CONTROL1,
 			  &control1);
 	control1 |= MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_INVERT_SIGNAL_DETECT;
-	/* set sgmii mode (and not fiber) */
+	/* Set sgmii mode (and not fiber) */
 	control1 &= ~(MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_FIBER_MODE |
 		      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_AUTODET |
 		      MDIO_SERDES_DIGITAL_A_1000X_CONTROL1_MSTR_MODE);
@@ -5221,9 +5215,9 @@ static void bnx2x_initialize_sgmii_process(struct bnx2x_phy *phy,
 			  MDIO_SERDES_DIGITAL_A_1000X_CONTROL1,
 			  control1);
 
-	/* if forced speed */
+	/* If forced speed */
 	if (!(vars->line_speed == SPEED_AUTO_NEG)) {
-		/* set speed, disable autoneg */
+		/* Set speed, disable autoneg */
 		u16 mii_control;
 
 		CL22_RD_OVER_CL45(bp, phy,
@@ -5244,16 +5238,16 @@ static void bnx2x_initialize_sgmii_process(struct bnx2x_phy *phy,
 				MDIO_COMBO_IEEO_MII_CONTROL_MAN_SGMII_SP_1000;
 			break;
 		case SPEED_10:
-			/* there is nothing to set for 10M */
+			/* There is nothing to set for 10M */
 			break;
 		default:
-			/* invalid speed for SGMII */
+			/* Invalid speed for SGMII */
 			DP(NETIF_MSG_LINK, "Invalid line_speed 0x%x\n",
 				  vars->line_speed);
 			break;
 		}
 
-		/* setting the full duplex */
+		/* Setting the full duplex */
 		if (phy->req_duplex == DUPLEX_FULL)
 			mii_control |=
 				MDIO_COMBO_IEEO_MII_CONTROL_FULL_DUPLEX;
@@ -5263,7 +5257,7 @@ static void bnx2x_initialize_sgmii_process(struct bnx2x_phy *phy,
 				  mii_control);
 
 	} else { /* AN mode */
-		/* enable and restart AN */
+		/* Enable and restart AN */
 		bnx2x_restart_autoneg(phy, params, 0);
 	}
 }
@@ -5359,7 +5353,7 @@ static void bnx2x_flow_ctrl_resolve(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
 
-	/* resolve from gp_status in case of AN complete and not sgmii */
+	/* Resolve from gp_status in case of AN complete and not sgmii */
 	if (phy->req_flow_ctrl != BNX2X_FLOW_CTRL_AUTO) {
 		/* Update the advertised flow-controled of LD/LP in AN */
 		if (phy->req_line_speed == SPEED_AUTO_NEG)
@@ -5583,7 +5577,7 @@ static int bnx2x_link_settings_status(struct bnx2x_phy *phy,
 				bnx2x_xgxs_an_resolve(phy, params, vars,
 						      gp_status);
 		}
-	} else { /* link_down */
+	} else { /* Link_down */
 		if ((phy->req_line_speed == SPEED_AUTO_NEG) &&
 		    SINGLE_MEDIA_DIRECT(params)) {
 			/* Check signal is detected */
@@ -5732,12 +5726,12 @@ static void bnx2x_set_gmii_tx_driver(struct link_params *params)
 	u16 tx_driver;
 	u16 bank;
 
-	/* read precomp */
+	/* Read precomp */
 	CL22_RD_OVER_CL45(bp, phy,
 			  MDIO_REG_BANK_OVER_1G,
 			  MDIO_OVER_1G_LP_UP2, &lp_up2);
 
-	/* bits [10:7] at lp_up2, positioned at [15:12] */
+	/* Bits [10:7] at lp_up2, positioned at [15:12] */
 	lp_up2 = (((lp_up2 & MDIO_OVER_1G_LP_UP2_PREEMPHASIS_MASK) >>
 		   MDIO_OVER_1G_LP_UP2_PREEMPHASIS_SHIFT) <<
 		  MDIO_TX0_TX_DRIVER_PREEMPHASIS_SHIFT);
@@ -5751,7 +5745,7 @@ static void bnx2x_set_gmii_tx_driver(struct link_params *params)
 				  bank,
 				  MDIO_TX0_TX_DRIVER, &tx_driver);
 
-		/* replace tx_driver bits [15:12] */
+		/* Replace tx_driver bits [15:12] */
 		if (lp_up2 !=
 		    (tx_driver & MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK)) {
 			tx_driver &= ~MDIO_TX0_TX_DRIVER_PREEMPHASIS_MASK;
@@ -5847,16 +5841,16 @@ static void bnx2x_xgxs_config_init(struct bnx2x_phy *phy,
 		     FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED))
 			bnx2x_set_preemphasis(phy, params);
 
-		/* forced speed requested? */
+		/* Forced speed requested? */
 		if (vars->line_speed != SPEED_AUTO_NEG ||
 		    (SINGLE_MEDIA_DIRECT(params) &&
 		     params->loopback_mode == LOOPBACK_EXT)) {
 			DP(NETIF_MSG_LINK, "not SGMII, no AN\n");
 
-			/* disable autoneg */
+			/* Disable autoneg */
 			bnx2x_set_autoneg(phy, params, vars, 0);
 
-			/* program speed and duplex */
+			/* Program speed and duplex */
 			bnx2x_program_serdes(phy, params, vars);
 
 		} else { /* AN_mode */
@@ -5865,14 +5859,14 @@ static void bnx2x_xgxs_config_init(struct bnx2x_phy *phy,
 			/* AN enabled */
 			bnx2x_set_brcm_cl37_advertisement(phy, params);
 
-			/* program duplex & pause advertisement (for aneg) */
+			/* Program duplex & pause advertisement (for aneg) */
 			bnx2x_set_ieee_aneg_advertisement(phy, params,
 							  vars->ieee_fc);
 
-			/* enable autoneg */
+			/* Enable autoneg */
 			bnx2x_set_autoneg(phy, params, vars, enable_cl73);
 
-			/* enable and restart AN */
+			/* Enable and restart AN */
 			bnx2x_restart_autoneg(phy, params, enable_cl73);
 		}
 
@@ -5908,12 +5902,12 @@ static int bnx2x_prepare_xgxs(struct bnx2x_phy *phy,
 		bnx2x_set_master_ln(params, phy);
 
 	rc = bnx2x_reset_unicore(params, phy, 0);
-	/* reset the SerDes and wait for reset bit return low */
-	if (rc != 0)
+	/* Reset the SerDes and wait for reset bit return low */
+	if (rc)
 		return rc;
 
 	bnx2x_set_aer_mmd(params, phy);
-	/* setting the masterLn_def again after the reset */
+	/* Setting the masterLn_def again after the reset */
 	if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT) {
 		bnx2x_set_master_ln(params, phy);
 		bnx2x_set_swap_lanes(params, phy);
@@ -5938,7 +5932,7 @@ static u16 bnx2x_wait_reset_complete(struct bnx2x *bp,
 				MDIO_PMA_REG_CTRL, &ctrl);
 		if (!(ctrl & (1<<15)))
 			break;
-		msleep(1);
+		usleep_range(1000, 1000);
 	}
 
 	if (cnt == 1000)
@@ -6169,7 +6163,7 @@ static void bnx2x_set_xgxs_loopback(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK, "XGXS 10G loopback enable\n");
 
 		if (!CHIP_IS_E3(bp)) {
-			/* change the uni_phy_addr in the nig */
+			/* Change the uni_phy_addr in the nig */
 			md_devad = REG_RD(bp, (NIG_REG_XGXS0_CTRL_MD_DEVAD +
 					       port*0x18));
 
@@ -6189,11 +6183,11 @@ static void bnx2x_set_xgxs_loopback(struct bnx2x_phy *phy,
 				  (MDIO_CL73_IEEEB0_CL73_AN_CONTROL & 0xf)),
 				 0x6041);
 		msleep(200);
-		/* set aer mmd back */
+		/* Set aer mmd back */
 		bnx2x_set_aer_mmd(params, phy);
 
 		if (!CHIP_IS_E3(bp)) {
-			/* and md_devad */
+			/* And md_devad */
 			REG_WR(bp, NIG_REG_XGXS0_CTRL_MD_DEVAD + port*0x18,
 			       md_devad);
 		}
@@ -6390,7 +6384,7 @@ int bnx2x_test_link(struct link_params *params, struct link_vars *vars,
 			  MDIO_REG_BANK_GP_STATUS,
 			  MDIO_GP_STATUS_TOP_AN_STATUS1,
 			  &gp_status);
-	/* link is up only if both local phy and external phy are up */
+	/* Link is up only if both local phy and external phy are up */
 	if (!(gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS))
 		return -ESRCH;
 	}
@@ -6512,7 +6506,7 @@ static int bnx2x_link_initialize(struct link_params *params,
 static void bnx2x_int_link_reset(struct bnx2x_phy *phy,
 				 struct link_params *params)
 {
-	/* reset the SerDes/XGXS */
+	/* Reset the SerDes/XGXS */
 	REG_WR(params->bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_3_CLEAR,
 	       (0x1ff << (params->port*16)));
 }
@@ -6545,10 +6539,10 @@ static int bnx2x_update_link_down(struct link_params *params,
 	DP(NETIF_MSG_LINK, "Port %x: Link is down\n", port);
 	bnx2x_set_led(params, vars, LED_MODE_OFF, 0);
 	vars->phy_flags &= ~PHY_PHYSICAL_LINK_FLAG;
-	/* indicate no mac active */
+	/* Indicate no mac active */
 	vars->mac_type = MAC_TYPE_NONE;
 
-	/* update shared memory */
+	/* Update shared memory */
 	vars->link_status &= ~(LINK_STATUS_SPEED_AND_DUPLEX_MASK |
 			       LINK_STATUS_LINK_UP |
 			       LINK_STATUS_PHYSICAL_LINK_FLAG |
@@ -6561,15 +6555,15 @@ static int bnx2x_update_link_down(struct link_params *params,
 	vars->line_speed = 0;
 	bnx2x_update_mng(params, vars->link_status);
 
-	/* activate nig drain */
+	/* Activate nig drain */
 	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
 
-	/* disable emac */
+	/* Disable emac */
 	if (!CHIP_IS_E3(bp))
 		REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
 
 	msleep(10);
-	/* reset BigMac/Xmac */
+	/* Reset BigMac/Xmac */
 	if (CHIP_IS_E1x(bp) ||
 	    CHIP_IS_E2(bp)) {
 		bnx2x_bmac_rx_disable(bp, params->port);
@@ -6578,6 +6572,7 @@ static int bnx2x_update_link_down(struct link_params *params,
 	       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
 	}
 	if (CHIP_IS_E3(bp)) {
+		/* Prevent LPI Generation by chip */
 		REG_WR(bp, MISC_REG_CPMU_LP_FW_ENABLE_P0 + (params->port << 2),
 		       0);
 		REG_WR(bp, MISC_REG_CPMU_LP_DR_ENABLE, 0);
@@ -6668,10 +6663,10 @@ static int bnx2x_update_link_up(struct link_params *params,
 		rc |= bnx2x_pbf_update(params, vars->flow_ctrl,
 				       vars->line_speed);
 
-	/* disable drain */
+	/* Disable drain */
 	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 0);
 
-	/* update shared memory */
+	/* Update shared memory */
 	bnx2x_update_mng(params, vars->link_status);
 	bnx2x_update_mng_eee(params, vars->eee_status);
 	/* Check remote fault */
@@ -6739,7 +6734,7 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 	  REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK10G + port*0x68),
 	  REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK_STATUS + port*0x68));
 
-	/* disable emac */
+	/* Disable emac */
 	if (!CHIP_IS_E3(bp))
 		REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
 
@@ -6884,11 +6879,11 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 		} else if (prev_line_speed != vars->line_speed) {
 			REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + params->port*4,
 			       0);
-			msleep(1);
+			usleep_range(1000, 1000);
 		}
 	}
 
-	/* anything 10 and over uses the bmac */
+	/* Anything 10 and over uses the bmac */
 	link_10g_plus = (vars->line_speed >= SPEED_10000);
 
 	bnx2x_link_int_ack(params, vars, link_10g_plus);
@@ -6954,7 +6949,7 @@ void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port)
 {
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
 		       MISC_REGISTERS_GPIO_OUTPUT_LOW, port);
-	msleep(1);
+	usleep_range(1000, 1000);
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
 		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, port);
 }
@@ -7051,7 +7046,7 @@ static int bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
 			 MDIO_PMA_REG_GEN_CTRL,
 			 0x0001);
 
-	/* ucode reboot and rst */
+	/* Ucode reboot and rst */
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD,
 			 MDIO_PMA_REG_GEN_CTRL,
@@ -7095,7 +7090,7 @@ static int bnx2x_8073_8727_external_rom_boot(struct bnx2x *bp,
 				MDIO_PMA_DEVAD,
 				MDIO_PMA_REG_M8051_MSGOUT_REG, &fw_msgout);
 
-		msleep(1);
+		usleep_range(1000, 1000);
 	} while (fw_ver1 == 0 || fw_ver1 == 0x4321 ||
 			((fw_msgout & 0xff) != 0x03 && (phy->type ==
 			PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073)));
@@ -7267,7 +7262,7 @@ static int bnx2x_8073_config_init(struct bnx2x_phy *phy,
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_1,
 		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, gpio_port);
 
-	/* enable LASI */
+	/* Enable LASI */
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_LASI_RXCTRL, (1<<2));
 	bnx2x_cl45_write(bp, phy,
@@ -7415,7 +7410,7 @@ static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
 
 	DP(NETIF_MSG_LINK, "8703 LASI status 0x%x\n", val1);
 
-	/* clear the interrupt LASI status register */
+	/* Clear the interrupt LASI status register */
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PCS_DEVAD, MDIO_PCS_REG_STATUS, &val2);
 	bnx2x_cl45_read(bp, phy,
@@ -7794,7 +7789,7 @@ static int bnx2x_8726_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 		if ((val & MDIO_PMA_REG_SFP_TWO_WIRE_CTRL_STATUS_MASK) ==
 		    MDIO_PMA_REG_SFP_TWO_WIRE_STATUS_IDLE)
 			return 0;
-		msleep(1);
+		usleep_range(1000, 1000);
 	}
 	return -EINVAL;
 }
@@ -7876,7 +7871,7 @@ static int bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 	/* Wait appropriate time for two-wire command to finish before
 	 * polling the status register
 	 */
-	msleep(1);
+	usleep_range(1000, 1000);
 
 	/* Wait up to 500us for command complete status */
 	for (i = 0; i < 100; i++) {
@@ -7912,7 +7907,7 @@ static int bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 		if ((val & MDIO_PMA_REG_SFP_TWO_WIRE_CTRL_STATUS_MASK) ==
 		    MDIO_PMA_REG_SFP_TWO_WIRE_STATUS_IDLE)
 			return 0;
-		msleep(1);
+		usleep_range(1000, 1000);
 	}
 
 	return -EINVAL;
@@ -8091,7 +8086,7 @@ static int bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 		return 0;
 	}
 
-	/* format the warning message */
+	/* Format the warning message */
 	if (bnx2x_read_sfp_module_eeprom(phy,
 					 params,
 					 SFP_EEPROM_VENDOR_NAME_ADDR,
@@ -8472,7 +8467,7 @@ int bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK, "Failed to get valid module type\n");
 		return -EINVAL;
 	} else if (bnx2x_verify_sfp_module(phy, params) != 0) {
-		/* check SFP+ module compatibility */
+		/* Check SFP+ module compatibility */
 		DP(NETIF_MSG_LINK, "Module verification failed!!\n");
 		rc = -EINVAL;
 		/* Turn on fault module-detected led */
@@ -8603,7 +8598,7 @@ static u8 bnx2x_8706_8726_read_status(struct bnx2x_phy *phy,
 	bnx2x_sfp_mask_fault(bp, phy, MDIO_PMA_LASI_TXSTAT,
 			     MDIO_PMA_LASI_TXCTRL);
 
-	/* clear LASI indication*/
+	/* Clear LASI indication*/
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD, MDIO_PMA_LASI_STAT, &val1);
 	bnx2x_cl45_read(bp, phy,
@@ -8800,7 +8795,7 @@ static void bnx2x_8726_external_rom_boot(struct bnx2x_phy *phy,
 			 MDIO_PMA_REG_GEN_CTRL,
 			 MDIO_PMA_REG_GEN_CTRL_ROM_RESET_INTERNAL_MP);
 
-	/* wait for 150ms for microcode load */
+	/* Wait for 150ms for microcode load */
 	msleep(150);
 
 	/* Disable serial boot control, tristates pins SS_N, SCK, MOSI, MISO */
@@ -9011,7 +9006,7 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 	lasi_ctrl_val = 0x0006;
 
 	DP(NETIF_MSG_LINK, "Initializing BCM8727\n");
-	/* enable LASI */
+	/* Enable LASI */
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_LASI_RXCTRL,
 			 rx_alarm_ctrl_val);
@@ -9733,7 +9728,7 @@ static int bnx2x_84833_cmd_hdlr(struct bnx2x_phy *phy,
 				MDIO_84833_CMD_HDLR_STATUS, &val);
 		if (val == PHY84833_STATUS_CMD_OPEN_FOR_CMDS)
 			break;
-		msleep(1);
+		usleep_range(1000, 1000);
 	}
 	if (idx >= PHY84833_CMDHDLR_WAIT) {
 		DP(NETIF_MSG_LINK, "FW cmd: FW not ready.\n");
@@ -9754,7 +9749,7 @@ static int bnx2x_84833_cmd_hdlr(struct bnx2x_phy *phy,
 		if ((val == PHY84833_STATUS_CMD_COMPLETE_PASS) ||
 			(val == PHY84833_STATUS_CMD_COMPLETE_ERROR))
 			break;
-		msleep(1);
+		usleep_range(1000, 1000);
 	}
 	if ((idx >= PHY84833_CMDHDLR_WAIT) ||
 		(val == PHY84833_STATUS_CMD_COMPLETE_ERROR)) {
@@ -9924,7 +9919,7 @@ static int bnx2x_8483x_disable_eee(struct bnx2x_phy *phy,
 	/* Prevent Phy from working in EEE and advertising it */
 	rc = bnx2x_84833_cmd_hdlr(phy, params,
 		PHY84833_CMD_SET_EEE_MODE, &cmd_args, 1);
-	if (rc != 0) {
+	if (rc) {
 		DP(NETIF_MSG_LINK, "EEE disable failed.\n");
 		return rc;
 	}
@@ -9947,7 +9942,7 @@ static int bnx2x_8483x_enable_eee(struct bnx2x_phy *phy,
 
 	rc = bnx2x_84833_cmd_hdlr(phy, params,
 		PHY84833_CMD_SET_EEE_MODE, &cmd_args, 1);
-	if (rc != 0) {
+	if (rc) {
 		DP(NETIF_MSG_LINK, "EEE enable failed.\n");
 		return rc;
 	}
@@ -9975,7 +9970,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	u16 cmd_args[PHY84833_CMDHDLR_MAX_ARGS];
 	int rc = 0;
 
-	msleep(1);
+	usleep_range(1000, 1000);
 
 	if (!(CHIP_IS_E1(bp)))
 		port = BP_PATH(bp);
@@ -10064,7 +10059,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 		rc = bnx2x_84833_cmd_hdlr(phy, params,
 			PHY84833_CMD_SET_EEE_MODE, cmd_args,
 			PHY84833_CMDHDLR_MAX_ARGS);
-		if (rc != 0)
+		if (rc)
 			DP(NETIF_MSG_LINK, "Cfg AutogrEEEn failed.\n");
 	}
 	if (initialize)
@@ -10108,7 +10103,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 			vars->eee_status &= ~SHMEM_EEE_REQUESTED_BIT;
 
 		rc = bnx2x_8483x_eee_timers(params, vars);
-		if (rc != 0) {
+		if (rc) {
 			DP(NETIF_MSG_LINK, "Failed to configure EEE timers\n");
 			bnx2x_8483x_disable_eee(phy, params, vars);
 			return rc;
@@ -10121,7 +10116,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 			rc = bnx2x_8483x_enable_eee(phy, params, vars);
 		else
 			rc = bnx2x_8483x_disable_eee(phy, params, vars);
-		if (rc != 0) {
+		if (rc) {
 			DP(NETIF_MSG_LINK, "Failed to set EEE advertisment\n");
 			return rc;
 		}
@@ -10222,7 +10217,7 @@ static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
 		}
 	}
 	if (link_up) {
-		DP(NETIF_MSG_LINK, "BCM84823: link speed is %d\n",
+		DP(NETIF_MSG_LINK, "BCM848x3: link speed is %d\n",
 			   vars->line_speed);
 		bnx2x_ext_phy_resolve_fc(phy, params, vars);
 
@@ -10633,7 +10628,7 @@ static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 			MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH)
 		fc_val |= MDIO_AN_REG_ADV_PAUSE_PAUSE;
 
-	/* read all advertisement */
+	/* Read all advertisement */
 	bnx2x_cl22_read(bp, phy,
 			0x09,
 			&an_1000_val);
@@ -10670,7 +10665,7 @@ static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 			0x09,
 			&an_1000_val);
 
-	/* set 100 speed advertisement */
+	/* Set 100 speed advertisement */
 	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
 			(phy->speed_cap_mask &
 			(PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
@@ -10684,7 +10679,7 @@ static int bnx2x_54618se_config_init(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK, "Advertising 100M\n");
 	}
 
-	/* set 10 speed advertisement */
+	/* Set 10 speed advertisement */
 	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
 			(phy->speed_cap_mask &
 			(PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL |
@@ -11050,7 +11045,7 @@ static u8 bnx2x_7101_read_status(struct bnx2x_phy *phy,
 	DP(NETIF_MSG_LINK, "10G-base-T PMA status 0x%x->0x%x\n",
 		   val2, val1);
 	link_up = ((val1 & 4) == 4);
-	/* if link is up print the AN outcome of the SFX7101 PHY */
+	/* If link is up print the AN outcome of the SFX7101 PHY */
 	if (link_up) {
 		bnx2x_cl45_read(bp, phy,
 				MDIO_AN_DEVAD, MDIO_AN_REG_MASTER_STATUS,
@@ -11062,7 +11057,7 @@ static u8 bnx2x_7101_read_status(struct bnx2x_phy *phy,
 		bnx2x_ext_phy_10G_an_resolve(bp, phy, vars);
 		bnx2x_ext_phy_resolve_fc(phy, params, vars);
 
-		/* read LP advertised speeds */
+		/* Read LP advertised speeds */
 		if (val2 & (1<<11))
 			vars->link_status |=
 				LINK_STATUS_LINK_PARTNER_10GXFD_CAPABLE;
@@ -12260,7 +12255,7 @@ int bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 	vars->mac_type = MAC_TYPE_NONE;
 	vars->phy_flags = 0;
 
-	/* disable attentions */
+	/* Disable attentions */
 	bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 + params->port*4,
 		       (NIG_MASK_XGXS0_LINK_STATUS |
 			NIG_MASK_XGXS0_LINK10G |
@@ -12320,7 +12315,7 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	struct bnx2x *bp = params->bp;
 	u8 phy_index, port = params->port, clear_latch_ind = 0;
 	DP(NETIF_MSG_LINK, "Resetting the link of port %d\n", port);
-	/* disable attentions */
+	/* Disable attentions */
 	vars->link_status = 0;
 	bnx2x_update_mng(params, vars->link_status);
 	vars->eee_status &= ~(SHMEM_EEE_LP_ADV_STATUS_MASK |
@@ -12332,10 +12327,10 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 			NIG_MASK_SERDES0_LINK_STATUS |
 			NIG_MASK_MI_INT));
 
-	/* activate nig drain */
+	/* Activate nig drain */
 	REG_WR(bp, NIG_REG_EGRESS_DRAIN0_MODE + port*4, 1);
 
-	/* disable nig egress interface */
+	/* Disable nig egress interface */
 	if (!CHIP_IS_E3(bp)) {
 		REG_WR(bp, NIG_REG_BMAC0_OUT_EN + port*4, 0);
 		REG_WR(bp, NIG_REG_EGRESS_EMAC0_OUT_EN + port*4, 0);
@@ -12348,7 +12343,7 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 		bnx2x_xmac_disable(params);
 		bnx2x_umac_disable(params);
 	}
-	/* disable emac */
+	/* Disable emac */
 	if (!CHIP_IS_E3(bp))
 		REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 0);
 
@@ -12356,7 +12351,7 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 	/* The PHY reset is controlled by GPIO 1
 	 * Hold it as vars low
 	 */
-	 /* clear link led */
+	 /* Clear link led */
 	bnx2x_set_mdio_clk(bp, params->chip_id, port);
 	bnx2x_set_led(params, vars, LED_MODE_OFF, 0);
 
@@ -12386,9 +12381,9 @@ int bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 		params->phy[INT_PHY].link_reset(
 			&params->phy[INT_PHY], params);
 
-	/* disable nig ingress interface */
+	/* Disable nig ingress interface */
 	if (!CHIP_IS_E3(bp)) {
-		/* reset BigMac */
+		/* Reset BigMac */
 		REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
 		       (MISC_REGISTERS_RESET_REG_2_RST_BMAC0 << port));
 		REG_WR(bp, NIG_REG_BMAC0_IN_EN + port*4, 0);
@@ -12445,7 +12440,7 @@ static int bnx2x_8073_common_init_phy(struct bnx2x *bp,
 			DP(NETIF_MSG_LINK, "populate_phy failed\n");
 			return -EINVAL;
 		}
-		/* disable attentions */
+		/* Disable attentions */
 		bnx2x_bits_dis(bp, NIG_REG_MASK_INTERRUPT_PORT0 +
 			       port_of_path*4,
 			       (NIG_MASK_XGXS0_LINK_STATUS |
@@ -12658,7 +12653,7 @@ static int bnx2x_8727_common_init_phy(struct bnx2x *bp,
 	/* Initiate PHY reset*/
 	bnx2x_set_gpio(bp, reset_gpio, MISC_REGISTERS_GPIO_OUTPUT_LOW,
 		       port);
-	msleep(1);
+	usleep_range(1000, 1000);
 	bnx2x_set_gpio(bp, reset_gpio, MISC_REGISTERS_GPIO_OUTPUT_HIGH,
 		       port);
 
@@ -12756,7 +12751,7 @@ static int bnx2x_84833_pre_init_phy(struct bnx2x *bp,
 				MDIO_PMA_REG_CTRL, &val);
 		if (!(val & (1<<15)))
 			break;
-		msleep(1);
+		usleep_range(1000, 1000);
 	}
 	if (cnt >= 1500) {
 		DP(NETIF_MSG_LINK, "84833 reset timeout\n");
@@ -12846,7 +12841,7 @@ static int bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base_path[],
 		break;
 	}
 
-	if (rc != 0)
+	if (rc)
 		netdev_err(bp->dev,  "Warning: PHY was not initialized,"
 				      " Port %d\n",
 			 0);
-- 
1.7.9.rc2
