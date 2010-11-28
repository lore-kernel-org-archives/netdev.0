From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: Add Nic partitioning mode (57712
 devices)
Date: Mon, 29 Nov 2010 00:09:37 +0200
Message-ID: <1290982177.6066.3.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2978 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752088Ab0K1WVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Nov 2010 17:21:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NIC partitioning is another flavor of multi function - having few
PCI functions share the same physical port. Unlike the currently
supported mode of multi-function which depends on the switch
configuration and uses outer-VLAN, the NPAR mode is switch independent
and uses the MAC addresses to distribute incoming packets to the different
functions. This patch adds the specific HW setting of the NPAR mode
and some distinctions between switch dependent (SD) and
switch independent (SI) multi-function (MF) modes where the configuration
is not the same.

Advance driver version to 1.60.00-6

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h         |   11 +-
 drivers/net/bnx2x/bnx2x_cmn.c     |   34 +++-
 drivers/net/bnx2x/bnx2x_cmn.h     |   10 +
 drivers/net/bnx2x/bnx2x_ethtool.c |   58 +++++--
 drivers/net/bnx2x/bnx2x_hsi.h     |   42 +++++-
 drivers/net/bnx2x/bnx2x_main.c    |  336 +++++++++++++++++++++++++++++--------
 drivers/net/bnx2x/bnx2x_reg.h     |    5 +
 7 files changed, 400 insertions(+), 96 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 342ab58..cfc25cf 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -20,8 +20,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.60.00-5"
-#define DRV_MODULE_RELDATE      "2010/11/24"
+#define DRV_MODULE_VERSION      "1.60.00-6"
+#define DRV_MODULE_RELDATE      "2010/11/29"
 #define BNX2X_BC_VER            0x040200
 
 #define BNX2X_MULTI_QUEUE
@@ -671,6 +671,10 @@ enum {
 	CAM_ISCSI_ETH_LINE,
 	CAM_MAX_PF_LINE = CAM_ISCSI_ETH_LINE
 };
+/* number of MACs per function in NIG memory - used for SI mode */
+#define NIG_LLH_FUNC_MEM_SIZE		16
+/* number of entries in NIG_REG_LLHX_FUNC_MEM */
+#define NIG_LLH_FUNC_MEM_MAX_OFFSET	8
 
 #define BNX2X_VF_ID_INVALID	0xFF
 
@@ -967,6 +971,8 @@ struct bnx2x {
 	u16			mf_ov;
 	u8			mf_mode;
 #define IS_MF(bp)		(bp->mf_mode != 0)
+#define IS_MF_SI(bp)		(bp->mf_mode == MULTI_FUNCTION_SI)
+#define IS_MF_SD(bp)		(bp->mf_mode == MULTI_FUNCTION_SD)
 
 	u8			wol;
 
@@ -1010,6 +1016,7 @@ struct bnx2x {
 #define BNX2X_ACCEPT_ALL_UNICAST	0x0004
 #define BNX2X_ACCEPT_ALL_MULTICAST	0x0008
 #define BNX2X_ACCEPT_BROADCAST		0x0010
+#define BNX2X_ACCEPT_UNMATCHED_UCAST	0x0020
 #define BNX2X_PROMISCUOUS_MODE		0x10000
 
 	u32			rx_mode;
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 94d5f59..d32e951 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -698,6 +698,29 @@ void bnx2x_release_phy_lock(struct bnx2x *bp)
 	mutex_unlock(&bp->port.phy_mutex);
 }
 
+/* calculates MF speed according to current linespeed and MF configuration */
+u16 bnx2x_get_mf_speed(struct bnx2x *bp)
+{
+	u16 line_speed = bp->link_vars.line_speed;
+	if (IS_MF(bp)) {
+		u16 maxCfg = (bp->mf_config[BP_VN(bp)] &
+						FUNC_MF_CFG_MAX_BW_MASK) >>
+						FUNC_MF_CFG_MAX_BW_SHIFT;
+		/* Calculate the current MAX line speed limit for the DCC
+		 * capable devices
+		 */
+		if (IS_MF_SD(bp)) {
+			u16 vn_max_rate = maxCfg * 100;
+
+			if (vn_max_rate < line_speed)
+				line_speed = vn_max_rate;
+		} else /* IS_MF_SI(bp)) */
+			line_speed = (line_speed * maxCfg) / 100;
+	}
+
+	return line_speed;
+}
+
 void bnx2x_link_report(struct bnx2x *bp)
 {
 	if (bp->flags & MF_FUNC_DIS) {
@@ -713,17 +736,8 @@ void bnx2x_link_report(struct bnx2x *bp)
 			netif_carrier_on(bp->dev);
 		netdev_info(bp->dev, "NIC Link is Up, ");
 
-		line_speed = bp->link_vars.line_speed;
-		if (IS_MF(bp)) {
-			u16 vn_max_rate;
+		line_speed = bnx2x_get_mf_speed(bp);
 
-			vn_max_rate =
-				((bp->mf_config[BP_VN(bp)] &
-				  FUNC_MF_CFG_MAX_BW_MASK) >>
-						FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
-			if (vn_max_rate < line_speed)
-				line_speed = vn_max_rate;
-		}
 		pr_cont("%d Mbps ", line_speed);
 
 		if (bp->link_vars.duplex == DUPLEX_FULL)
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 6b28739..cb8f2a0 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -73,6 +73,16 @@ void bnx2x__link_status_update(struct bnx2x *bp);
 void bnx2x_link_report(struct bnx2x *bp);
 
 /**
+ * calculates MF speed according to current linespeed and MF
+ * configuration
+ *
+ * @param bp
+ *
+ * @return u16
+ */
+u16 bnx2x_get_mf_speed(struct bnx2x *bp);
+
+/**
  * MSI-X slowpath interrupt handler
  *
  * @param irq
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 0301278..bd94827 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -45,14 +45,9 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->speed = bp->link_params.req_line_speed[cfg_idx];
 		cmd->duplex = bp->link_params.req_duplex[cfg_idx];
 	}
-	if (IS_MF(bp)) {
-		u16 vn_max_rate = ((bp->mf_config[BP_VN(bp)] &
-			FUNC_MF_CFG_MAX_BW_MASK) >> FUNC_MF_CFG_MAX_BW_SHIFT) *
-			100;
 
-		if (vn_max_rate < cmd->speed)
-			cmd->speed = vn_max_rate;
-	}
+	if (IS_MF(bp))
+		cmd->speed = bnx2x_get_mf_speed(bp);
 
 	if (bp->port.supported[cfg_idx] & SUPPORTED_TP)
 		cmd->port = PORT_TP;
@@ -87,18 +82,57 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	u32 advertising, cfg_idx, old_multi_phy_config, new_multi_phy_config;
+	u32 speed;
 
-	if (IS_MF(bp))
+	if (IS_MF_SD(bp))
 		return 0;
 
 	DP(NETIF_MSG_LINK, "ethtool_cmd: cmd %d\n"
-	   DP_LEVEL "  supported 0x%x  advertising 0x%x  speed %d\n"
-	   DP_LEVEL "  duplex %d  port %d  phy_address %d  transceiver %d\n"
-	   DP_LEVEL "  autoneg %d  maxtxpkt %d  maxrxpkt %d\n",
+	   "  supported 0x%x  advertising 0x%x  speed %d speed_hi %d\n"
+	   "  duplex %d  port %d  phy_address %d  transceiver %d\n"
+	   "  autoneg %d  maxtxpkt %d  maxrxpkt %d\n",
 	   cmd->cmd, cmd->supported, cmd->advertising, cmd->speed,
+	   cmd->speed_hi,
 	   cmd->duplex, cmd->port, cmd->phy_address, cmd->transceiver,
 	   cmd->autoneg, cmd->maxtxpkt, cmd->maxrxpkt);
 
+	speed = cmd->speed;
+	speed |= (cmd->speed_hi << 16);
+
+	if (IS_MF_SI(bp)) {
+		u32 param = 0;
+		u32 line_speed = bp->link_vars.line_speed;
+
+		/* use 10G if no link detected */
+		if (!line_speed)
+			line_speed = 10000;
+
+		if (bp->common.bc_ver < REQ_BC_VER_4_SET_MF_BW) {
+			BNX2X_DEV_INFO("To set speed BC %X or higher "
+				       "is required, please upgrade BC\n",
+				       REQ_BC_VER_4_SET_MF_BW);
+			return -EINVAL;
+		}
+		if (line_speed < speed) {
+			BNX2X_DEV_INFO("New speed should be less or equal "
+				       "to actual line speed\n");
+			return -EINVAL;
+		}
+		/* load old values */
+		param = bp->mf_config[BP_VN(bp)];
+
+		/* leave only MIN value */
+		param &= FUNC_MF_CFG_MIN_BW_MASK;
+
+		/* set new MAX value */
+		param |= (((speed * 100) / line_speed)
+				 << FUNC_MF_CFG_MAX_BW_SHIFT)
+				  & FUNC_MF_CFG_MAX_BW_MASK;
+
+		bnx2x_fw_command(bp, DRV_MSG_CODE_SET_MF_BW, param);
+		return 0;
+	}
+
 	cfg_idx = bnx2x_get_link_cfg_idx(bp);
 	old_multi_phy_config = bp->link_params.multi_phy_config;
 	switch (cmd->port) {
@@ -168,8 +202,6 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	} else { /* forced speed */
 		/* advertise the requested speed and duplex if supported */
-		u32 speed = cmd->speed;
-		speed |= (cmd->speed_hi << 16);
 		switch (speed) {
 		case SPEED_10:
 			if (cmd->duplex == DUPLEX_FULL) {
diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index 4cfd4e9..6555c47 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -434,7 +434,12 @@ struct shared_feat_cfg {				 /* NVRAM Offset */
 #define SHARED_FEAT_CFG_OVERRIDE_PREEMPHASIS_CFG_DISABLED     0x00000000
 #define SHARED_FEAT_CFG_OVERRIDE_PREEMPHASIS_CFG_ENABLED      0x00000002
 
-#define SHARED_FEATURE_MF_MODE_DISABLED 	    0x00000100
+#define SHARED_FEAT_CFG_FORCE_SF_MODE_MASK		      0x00000700
+#define SHARED_FEAT_CFG_FORCE_SF_MODE_SHIFT		      8
+#define SHARED_FEAT_CFG_FORCE_SF_MODE_MF_ALLOWED	      0x00000000
+#define SHARED_FEAT_CFG_FORCE_SF_MODE_FORCED_SF		      0x00000100
+#define SHARED_FEAT_CFG_FORCE_SF_MODE_SPIO4		      0x00000200
+#define SHARED_FEAT_CFG_FORCE_SF_MODE_SWITCH_INDEPT	      0x00000300
 
 };
 
@@ -815,6 +820,9 @@ struct drv_func_mb {
 #define DRV_MSG_CODE_VRFY_SPECIFIC_PHY_OPT_MDL	    0xa1000000
 #define REQ_BC_VER_4_VRFY_SPECIFIC_PHY_OPT_MDL	    0x00050234
 
+#define DRV_MSG_CODE_SET_MF_BW				0xe0000000
+#define REQ_BC_VER_4_SET_MF_BW				0x00060202
+#define DRV_MSG_CODE_SET_MF_BW_ACK			0xe1000000
 #define BIOS_MSG_CODE_LIC_CHALLENGE			0xff010000
 #define BIOS_MSG_CODE_LIC_RESPONSE			0xff020000
 #define BIOS_MSG_CODE_VIRT_MAC_PRIM			0xff030000
@@ -888,6 +896,7 @@ struct drv_func_mb {
 
 	u32 drv_status;
 #define DRV_STATUS_PMF					0x00000001
+#define DRV_STATUS_SET_MF_BW				0x00000004
 
 #define DRV_STATUS_DCC_EVENT_MASK			0x0000ff00
 #define DRV_STATUS_DCC_DISABLE_ENABLE_PF		0x00000100
@@ -988,12 +997,43 @@ struct func_mf_cfg {
 
 };
 
+/* This structure is not applicable and should not be accessed on 57711 */
+struct func_ext_cfg {
+	u32 func_cfg;
+#define MACP_FUNC_CFG_FLAGS_MASK			      0x000000FF
+#define MACP_FUNC_CFG_FLAGS_SHIFT			      0
+#define MACP_FUNC_CFG_FLAGS_ENABLED			      0x00000001
+#define MACP_FUNC_CFG_FLAGS_ETHERNET			      0x00000002
+#define MACP_FUNC_CFG_FLAGS_ISCSI_OFFLOAD		      0x00000004
+#define MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD		      0x00000008
+
+	u32 iscsi_mac_addr_upper;
+	u32 iscsi_mac_addr_lower;
+
+	u32 fcoe_mac_addr_upper;
+	u32 fcoe_mac_addr_lower;
+
+	u32 fcoe_wwn_port_name_upper;
+	u32 fcoe_wwn_port_name_lower;
+
+	u32 fcoe_wwn_node_name_upper;
+	u32 fcoe_wwn_node_name_lower;
+
+	u32 preserve_data;
+#define MF_FUNC_CFG_PRESERVE_L2_MAC			     (1<<0)
+#define MF_FUNC_CFG_PRESERVE_ISCSI_MAC			     (1<<1)
+#define MF_FUNC_CFG_PRESERVE_FCOE_MAC			     (1<<2)
+#define MF_FUNC_CFG_PRESERVE_FCOE_WWN_P			     (1<<3)
+#define MF_FUNC_CFG_PRESERVE_FCOE_WWN_N			     (1<<4)
+};
+
 struct mf_cfg {
 
 	struct shared_mf_cfg	shared_mf_config;
 	struct port_mf_cfg	port_mf_config[PORT_MAX];
 	struct func_mf_cfg	func_mf_config[E1H_FUNC_MAX];
 
+	struct func_ext_cfg func_ext_config[E1H_FUNC_MAX];
 };
 
 
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index f53edfd..1552fc3 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2026,13 +2026,28 @@ static int bnx2x_get_cmng_fns_mode(struct bnx2x *bp)
 
 static void bnx2x_read_mf_cfg(struct bnx2x *bp)
 {
-	int vn;
+	int vn, n = (CHIP_MODE_IS_4_PORT(bp) ? 2 : 1);
 
 	if (BP_NOMCP(bp))
 		return; /* what should be the default bvalue in this case */
 
+	/* For 2 port configuration the absolute function number formula
+	 * is:
+	 *      abs_func = 2 * vn + BP_PORT + BP_PATH
+	 *
+	 *      and there are 4 functions per port
+	 *
+	 * For 4 port configuration it is
+	 *      abs_func = 4 * vn + 2 * BP_PORT + BP_PATH
+	 *
+	 *      and there are 2 functions per port
+	 */
 	for (vn = VN_0; vn < E1HVN_MAX; vn++) {
-		int /*abs*/func = 2*vn + BP_PORT(bp);
+		int /*abs*/func = n * (2 * vn + BP_PORT(bp)) + BP_PATH(bp);
+
+		if (func >= E1H_FUNC_MAX)
+			break;
+
 		bp->mf_config[vn] =
 			MF_CFG_RD(bp, func_mf_config[func].config);
 	}
@@ -2248,10 +2263,21 @@ static void bnx2x_rxq_set_mac_filters(struct bnx2x *bp, u16 cl_id, u32 filters)
 	u8 accp_all_ucast = 0, accp_all_bcast = 0, accp_all_mcast = 0;
 	u8 unmatched_unicast = 0;
 
+	if (filters & BNX2X_ACCEPT_UNMATCHED_UCAST)
+		unmatched_unicast = 1;
+
 	if (filters & BNX2X_PROMISCUOUS_MODE) {
 		/* promiscious - accept all, drop none */
 		drop_all_ucast = drop_all_bcast = drop_all_mcast = 0;
 		accp_all_ucast = accp_all_bcast = accp_all_mcast = 1;
+		if (IS_MF_SI(bp)) {
+			/*
+			 * SI mode defines to accept in promiscuos mode
+			 * only unmatched packets
+			 */
+			unmatched_unicast = 1;
+			accp_all_ucast = 0;
+		}
 	}
 	if (filters & BNX2X_ACCEPT_UNICAST) {
 		/* accept matched ucast */
@@ -2260,6 +2286,11 @@ static void bnx2x_rxq_set_mac_filters(struct bnx2x *bp, u16 cl_id, u32 filters)
 	if (filters & BNX2X_ACCEPT_MULTICAST) {
 		/* accept matched mcast */
 		drop_all_mcast = 0;
+		if (IS_MF_SI(bp))
+			/* since mcast addresses won't arrive with ovlan,
+			 * fw needs to accept all of them in
+			 * switch-independent mode */
+			accp_all_mcast = 1;
 	}
 	if (filters & BNX2X_ACCEPT_ALL_UNICAST) {
 		/* accept all mcast */
@@ -2372,7 +2403,7 @@ static inline u16 bnx2x_get_cl_flags(struct bnx2x *bp,
 	/* calculate queue flags */
 	flags |= QUEUE_FLG_CACHE_ALIGN;
 	flags |= QUEUE_FLG_HC;
-	flags |= IS_MF(bp) ? QUEUE_FLG_OV : 0;
+	flags |= IS_MF_SD(bp) ? QUEUE_FLG_OV : 0;
 
 	flags |= QUEUE_FLG_VLAN;
 	DP(NETIF_MSG_IFUP, "vlan removal enabled\n");
@@ -2573,6 +2604,26 @@ static void bnx2x_e1h_enable(struct bnx2x *bp)
 	 */
 }
 
+/* called due to MCP event (on pmf):
+ *	reread new bandwidth configuration
+ *	configure FW
+ *	notify others function about the change
+ */
+static inline void bnx2x_config_mf_bw(struct bnx2x *bp)
+{
+	if (bp->link_vars.link_up) {
+		bnx2x_cmng_fns_init(bp, true, CMNG_FNS_MINMAX);
+		bnx2x_link_sync_notify(bp);
+	}
+	storm_memset_cmng(bp, &bp->cmng, BP_PORT(bp));
+}
+
+static inline void bnx2x_set_mf_bw(struct bnx2x *bp)
+{
+	bnx2x_config_mf_bw(bp);
+	bnx2x_fw_command(bp, DRV_MSG_CODE_SET_MF_BW_ACK, 0);
+}
+
 static void bnx2x_dcc_event(struct bnx2x *bp, u32 dcc_event)
 {
 	DP(BNX2X_MSG_MCP, "dcc_event 0x%x\n", dcc_event);
@@ -2598,10 +2649,7 @@ static void bnx2x_dcc_event(struct bnx2x *bp, u32 dcc_event)
 		dcc_event &= ~DRV_STATUS_DCC_DISABLE_ENABLE_PF;
 	}
 	if (dcc_event & DRV_STATUS_DCC_BANDWIDTH_ALLOCATION) {
-
-		bnx2x_cmng_fns_init(bp, true, CMNG_FNS_MINMAX);
-		bnx2x_link_sync_notify(bp);
-		storm_memset_cmng(bp, &bp->cmng, BP_PORT(bp));
+		bnx2x_config_mf_bw(bp);
 		dcc_event &= ~DRV_STATUS_DCC_BANDWIDTH_ALLOCATION;
 	}
 
@@ -3022,6 +3070,10 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 			if (val & DRV_STATUS_DCC_EVENT_MASK)
 				bnx2x_dcc_event(bp,
 					    (val & DRV_STATUS_DCC_EVENT_MASK));
+
+			if (val & DRV_STATUS_SET_MF_BW)
+				bnx2x_set_mf_bw(bp);
+
 			bnx2x__link_status_update(bp);
 			if ((bp->port.pmf == 0) && (val & DRV_STATUS_PMF))
 				bnx2x_pmf_update(bp);
@@ -4232,6 +4284,15 @@ static void bnx2x_init_internal_common(struct bnx2x *bp)
 			bp->mf_mode);
 	}
 
+	if (IS_MF_SI(bp))
+		/*
+		 * In switch independent mode, the TSTORM needs to accept
+		 * packets that failed classification, since approximate match
+		 * mac addresses aren't written to NIG LLH
+		 */
+		REG_WR8(bp, BAR_TSTRORM_INTMEM +
+			    TSTORM_ACCEPT_CLASSIFY_FAILED_OFFSET, 2);
+
 	/* Zero this manually as its initialization is
 	   currently missing in the initTool */
 	for (i = 0; i < (USTORM_AGG_DATA_SIZE >> 2); i++)
@@ -5048,12 +5109,12 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 	REG_WR(bp, PRS_REG_NIC_MODE, 1);
 #endif
 	if (!CHIP_IS_E1(bp))
-		REG_WR(bp, PRS_REG_E1HOV_MODE, IS_MF(bp));
+		REG_WR(bp, PRS_REG_E1HOV_MODE, IS_MF_SD(bp));
 
 	if (CHIP_IS_E2(bp)) {
 		/* Bit-map indicating which L2 hdrs may appear after the
 		   basic Ethernet header */
-		int has_ovlan = IS_MF(bp);
+		int has_ovlan = IS_MF_SD(bp);
 		REG_WR(bp, PRS_REG_HDRS_AFTER_BASIC, (has_ovlan ? 7 : 6));
 		REG_WR(bp, PRS_REG_MUST_HAVE_HDRS, (has_ovlan ? 1 : 0));
 	}
@@ -5087,7 +5148,7 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 	bnx2x_init_block(bp, PBF_BLOCK, COMMON_STAGE);
 
 	if (CHIP_IS_E2(bp)) {
-		int has_ovlan = IS_MF(bp);
+		int has_ovlan = IS_MF_SD(bp);
 		REG_WR(bp, PBF_REG_HDRS_AFTER_BASIC, (has_ovlan ? 7 : 6));
 		REG_WR(bp, PBF_REG_MUST_HAVE_HDRS, (has_ovlan ? 1 : 0));
 	}
@@ -5164,12 +5225,12 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 	bnx2x_init_block(bp, NIG_BLOCK, COMMON_STAGE);
 	if (!CHIP_IS_E1(bp)) {
 		REG_WR(bp, NIG_REG_LLH_MF_MODE, IS_MF(bp));
-		REG_WR(bp, NIG_REG_LLH_E1HOV_MODE, IS_MF(bp));
+		REG_WR(bp, NIG_REG_LLH_E1HOV_MODE, IS_MF_SD(bp));
 	}
 	if (CHIP_IS_E2(bp)) {
 		/* Bit-map indicating which L2 hdrs may appear after the
 		   basic Ethernet header */
-		REG_WR(bp, NIG_REG_P0_HDRS_AFTER_BASIC, (IS_MF(bp) ? 7 : 6));
+		REG_WR(bp, NIG_REG_P0_HDRS_AFTER_BASIC, (IS_MF_SD(bp) ? 7 : 6));
 	}
 
 	if (CHIP_REV_IS_SLOW(bp))
@@ -5386,7 +5447,7 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 	if (!CHIP_IS_E1(bp)) {
 		/* 0x2 disable mf_ov, 0x1 enable */
 		REG_WR(bp, NIG_REG_LLH0_BRB1_DRV_MASK_MF + port*4,
-		       (IS_MF(bp) ? 0x1 : 0x2));
+		       (IS_MF_SD(bp) ? 0x1 : 0x2));
 
 		if (CHIP_IS_E2(bp)) {
 			val = 0;
@@ -6170,6 +6231,70 @@ static u8 bnx2x_e1h_cam_offset(struct bnx2x *bp, u8 rel_offset)
 		return BP_VN(bp) * 32  + rel_offset;
 }
 
+/**
+ *  LLH CAM line allocations: currently only iSCSI and ETH macs are
+ *  relevant. In addition, current implementation is tuned for a
+ *  single ETH MAC.
+ *
+ *  When multiple unicast ETH MACs PF configuration in switch
+ *  independent mode is required (NetQ, multiple netdev MACs,
+ *  etc.), consider better utilisation of 16 per function MAC
+ *  entries in the LLH memory.
+ */
+enum {
+	LLH_CAM_ISCSI_ETH_LINE = 0,
+	LLH_CAM_ETH_LINE,
+	LLH_CAM_MAX_PF_LINE = NIG_REG_LLH1_FUNC_MEM_SIZE
+};
+
+static void bnx2x_set_mac_in_nig(struct bnx2x *bp,
+			  int set,
+			  unsigned char *dev_addr,
+			  int index)
+{
+	u32 wb_data[2];
+	u32 mem_offset, ena_offset, mem_index;
+	/**
+	 * indexes mapping:
+	 * 0..7 - goes to MEM
+	 * 8..15 - goes to MEM2
+	 */
+
+	if (!IS_MF_SI(bp) || index > LLH_CAM_MAX_PF_LINE)
+		return;
+
+	/* calculate memory start offset according to the mapping
+	 * and index in the memory */
+	if (index < NIG_LLH_FUNC_MEM_MAX_OFFSET) {
+		mem_offset = BP_PORT(bp) ? NIG_REG_LLH1_FUNC_MEM :
+					   NIG_REG_LLH0_FUNC_MEM;
+		ena_offset = BP_PORT(bp) ? NIG_REG_LLH1_FUNC_MEM_ENABLE :
+					   NIG_REG_LLH0_FUNC_MEM_ENABLE;
+		mem_index = index;
+	} else {
+		mem_offset = BP_PORT(bp) ? NIG_REG_P1_LLH_FUNC_MEM2 :
+					   NIG_REG_P0_LLH_FUNC_MEM2;
+		ena_offset = BP_PORT(bp) ? NIG_REG_P1_LLH_FUNC_MEM2_ENABLE :
+					   NIG_REG_P0_LLH_FUNC_MEM2_ENABLE;
+		mem_index = index - NIG_LLH_FUNC_MEM_MAX_OFFSET;
+	}
+
+	if (set) {
+		/* LLH_FUNC_MEM is a u64 WB register */
+		mem_offset += 8*mem_index;
+
+		wb_data[0] = ((dev_addr[2] << 24) | (dev_addr[3] << 16) |
+			      (dev_addr[4] <<  8) |  dev_addr[5]);
+		wb_data[1] = ((dev_addr[0] <<  8) |  dev_addr[1]);
+
+		REG_WR_DMAE(bp, mem_offset, wb_data, 2);
+	}
+
+	/* enable/disable the entry */
+	REG_WR(bp, ena_offset + 4*mem_index, set);
+
+}
+
 void bnx2x_set_eth_mac(struct bnx2x *bp, int set)
 {
 	u8 cam_offset = (CHIP_IS_E1(bp) ? (BP_PORT(bp) ? 32 : 0) :
@@ -6179,6 +6304,8 @@ void bnx2x_set_eth_mac(struct bnx2x *bp, int set)
 	bnx2x_set_mac_addr_gen(bp, set, bp->dev->dev_addr,
 			       (1 << bp->fp->cl_id), cam_offset , 0);
 
+	bnx2x_set_mac_in_nig(bp, set, bp->dev->dev_addr, LLH_CAM_ETH_LINE);
+
 	if (CHIP_IS_E1(bp)) {
 		/* broadcast MAC */
 		u8 bcast[ETH_ALEN] = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
@@ -6289,6 +6416,8 @@ static int bnx2x_set_iscsi_eth_mac_addr(struct bnx2x *bp, int set)
 	/* Send a SET_MAC ramrod */
 	bnx2x_set_mac_addr_gen(bp, set, bp->iscsi_mac, cl_bit_vec,
 			       cam_offset, 0);
+
+	bnx2x_set_mac_in_nig(bp, set, bp->iscsi_mac, LLH_CAM_ISCSI_ETH_LINE);
 	return 0;
 }
 #endif
@@ -8076,7 +8205,6 @@ static void __devinit bnx2x_set_mac_buf(u8 *mac_buf, u32 mac_lo, u16 mac_hi)
 static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
-	u32 val, val2;
 	u32 config;
 	u32 ext_phy_type, ext_phy_config;
 
@@ -8135,25 +8263,62 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 		 (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN))
 		bp->mdio.prtad =
 			XGXS_EXT_PHY_ADDR(ext_phy_config);
+}
 
-	val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_upper);
-	val = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_lower);
-	bnx2x_set_mac_buf(bp->dev->dev_addr, val, val2);
-	memcpy(bp->link_params.mac_addr, bp->dev->dev_addr, ETH_ALEN);
-	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
+static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
+{
+	u32 val, val2;
+	int func = BP_ABS_FUNC(bp);
+	int port = BP_PORT(bp);
+
+	if (BP_NOMCP(bp)) {
+		BNX2X_ERROR("warning: random MAC workaround active\n");
+		random_ether_addr(bp->dev->dev_addr);
+	} else if (IS_MF(bp)) {
+		val2 = MF_CFG_RD(bp, func_mf_config[func].mac_upper);
+		val = MF_CFG_RD(bp, func_mf_config[func].mac_lower);
+		if ((val2 != FUNC_MF_CFG_UPPERMAC_DEFAULT) &&
+		    (val != FUNC_MF_CFG_LOWERMAC_DEFAULT))
+			bnx2x_set_mac_buf(bp->dev->dev_addr, val, val2);
 
 #ifdef BCM_CNIC
-	val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].iscsi_mac_upper);
-	val = SHMEM_RD(bp, dev_info.port_hw_config[port].iscsi_mac_lower);
-	bnx2x_set_mac_buf(bp->iscsi_mac, val, val2);
+		/* iSCSI NPAR MAC */
+		if (IS_MF_SI(bp)) {
+			u32 cfg = MF_CFG_RD(bp, func_ext_config[func].func_cfg);
+			if (cfg & MACP_FUNC_CFG_FLAGS_ISCSI_OFFLOAD) {
+				val2 = MF_CFG_RD(bp, func_ext_config[func].
+						     iscsi_mac_addr_upper);
+				val = MF_CFG_RD(bp, func_ext_config[func].
+						    iscsi_mac_addr_lower);
+				bnx2x_set_mac_buf(bp->iscsi_mac, val, val2);
+			}
+		}
 #endif
+	} else {
+		/* in SF read MACs from port configuration */
+		val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_upper);
+		val = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_lower);
+		bnx2x_set_mac_buf(bp->dev->dev_addr, val, val2);
+
+#ifdef BCM_CNIC
+		val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].
+				    iscsi_mac_upper);
+		val = SHMEM_RD(bp, dev_info.port_hw_config[port].
+				   iscsi_mac_lower);
+		bnx2x_set_mac_buf(bp->iscsi_mac, val, val2);
+#endif
+	}
+
+	memcpy(bp->link_params.mac_addr, bp->dev->dev_addr, ETH_ALEN);
+	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
+
 }
 
 static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 {
-	int func = BP_ABS_FUNC(bp);
-	int vn;
-	u32 val, val2;
+	int /*abs*/func = BP_ABS_FUNC(bp);
+	int vn, port;
+	u32 val = 0;
 	int rc = 0;
 
 	bnx2x_get_common_hwinfo(bp);
@@ -8186,44 +8351,99 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 	bp->mf_ov = 0;
 	bp->mf_mode = 0;
 	vn = BP_E1HVN(bp);
+	port = BP_PORT(bp);
+
 	if (!CHIP_IS_E1(bp) && !BP_NOMCP(bp)) {
+		DP(NETIF_MSG_PROBE,
+			    "shmem2base 0x%x, size %d, mfcfg offset %d\n",
+			    bp->common.shmem2_base, SHMEM2_RD(bp, size),
+			    (u32)offsetof(struct shmem2_region, mf_cfg_addr));
 		if (SHMEM2_HAS(bp, mf_cfg_addr))
 			bp->common.mf_cfg_base = SHMEM2_RD(bp, mf_cfg_addr);
 		else
 			bp->common.mf_cfg_base = bp->common.shmem_base +
 				offsetof(struct shmem_region, func_mb) +
 				E1H_FUNC_MAX * sizeof(struct drv_func_mb);
-		bp->mf_config[vn] =
-			MF_CFG_RD(bp, func_mf_config[func].config);
+		/*
+		 * get mf configuration:
+		 * 1. existance of MF configuration
+		 * 2. MAC address must be legal (check only upper bytes)
+		 *    for  Switch-Independent mode;
+		 *    OVLAN must be legal for Switch-Dependent mode
+		 * 3. SF_MODE configures specific MF mode
+		 */
+		if (bp->common.mf_cfg_base != SHMEM_MF_CFG_ADDR_NONE) {
+			/* get mf configuration */
+			val = SHMEM_RD(bp,
+				       dev_info.shared_feature_config.config);
+			val &= SHARED_FEAT_CFG_FORCE_SF_MODE_MASK;
+
+			switch (val) {
+			case SHARED_FEAT_CFG_FORCE_SF_MODE_SWITCH_INDEPT:
+				val = MF_CFG_RD(bp, func_mf_config[func].
+						mac_upper);
+				/* check for legal mac (upper bytes)*/
+				if (val != 0xffff) {
+					bp->mf_mode = MULTI_FUNCTION_SI;
+					bp->mf_config[vn] = MF_CFG_RD(bp,
+						   func_mf_config[func].config);
+				} else
+					DP(NETIF_MSG_PROBE, "illegal MAC "
+							    "address for SI\n");
+				break;
+			case SHARED_FEAT_CFG_FORCE_SF_MODE_MF_ALLOWED:
+				/* get OV configuration */
+				val = MF_CFG_RD(bp,
+					func_mf_config[FUNC_0].e1hov_tag);
+				val &= FUNC_MF_CFG_E1HOV_TAG_MASK;
+
+				if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
+					bp->mf_mode = MULTI_FUNCTION_SD;
+					bp->mf_config[vn] = MF_CFG_RD(bp,
+						func_mf_config[func].config);
+				} else
+					DP(NETIF_MSG_PROBE, "illegal OV for "
+							    "SD\n");
+				break;
+			default:
+				/* Unknown configuration: reset mf_config */
+				bp->mf_config[vn] = 0;
+				DP(NETIF_MSG_PROBE, "Unkown MF mode 0x%x\n",
+				   val);
+			}
+		}
 
-		val = (MF_CFG_RD(bp, func_mf_config[FUNC_0].e1hov_tag) &
-		       FUNC_MF_CFG_E1HOV_TAG_MASK);
-		if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT)
-			bp->mf_mode = 1;
 		BNX2X_DEV_INFO("%s function mode\n",
 			       IS_MF(bp) ? "multi" : "single");
 
-		if (IS_MF(bp)) {
-			val = (MF_CFG_RD(bp, func_mf_config[func].
-								e1hov_tag) &
-			       FUNC_MF_CFG_E1HOV_TAG_MASK);
+		switch (bp->mf_mode) {
+		case MULTI_FUNCTION_SD:
+			val = MF_CFG_RD(bp, func_mf_config[func].e1hov_tag) &
+			      FUNC_MF_CFG_E1HOV_TAG_MASK;
 			if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
 				bp->mf_ov = val;
-				BNX2X_DEV_INFO("MF OV for func %d is %d "
-					       "(0x%04x)\n",
-					       func, bp->mf_ov, bp->mf_ov);
+				BNX2X_DEV_INFO("MF OV for func %d is %d"
+					       " (0x%04x)\n", func,
+					       bp->mf_ov, bp->mf_ov);
 			} else {
-				BNX2X_ERROR("No valid MF OV for func %d,"
-					    "  aborting\n", func);
+				BNX2X_ERR("No valid MF OV for func %d,"
+					  "  aborting\n", func);
 				rc = -EPERM;
 			}
-		} else {
-			if (BP_VN(bp)) {
-				BNX2X_ERROR("VN %d in single function mode,"
-					    "  aborting\n", BP_E1HVN(bp));
+			break;
+		case MULTI_FUNCTION_SI:
+			BNX2X_DEV_INFO("func %d is in MF "
+				       "switch-independent mode\n", func);
+			break;
+		default:
+			if (vn) {
+				BNX2X_ERR("VN %d in single function mode,"
+					  "  aborting\n", vn);
 				rc = -EPERM;
 			}
+			break;
 		}
+
 	}
 
 	/* adjust igu_sb_cnt to MF for E1x */
@@ -8248,32 +8468,8 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 		BNX2X_DEV_INFO("fw_seq 0x%08x\n", bp->fw_seq);
 	}
 
-	if (IS_MF(bp)) {
-		val2 = MF_CFG_RD(bp, func_mf_config[func].mac_upper);
-		val = MF_CFG_RD(bp,  func_mf_config[func].mac_lower);
-		if ((val2 != FUNC_MF_CFG_UPPERMAC_DEFAULT) &&
-		    (val != FUNC_MF_CFG_LOWERMAC_DEFAULT)) {
-			bp->dev->dev_addr[0] = (u8)(val2 >> 8 & 0xff);
-			bp->dev->dev_addr[1] = (u8)(val2 & 0xff);
-			bp->dev->dev_addr[2] = (u8)(val >> 24 & 0xff);
-			bp->dev->dev_addr[3] = (u8)(val >> 16 & 0xff);
-			bp->dev->dev_addr[4] = (u8)(val >> 8  & 0xff);
-			bp->dev->dev_addr[5] = (u8)(val & 0xff);
-			memcpy(bp->link_params.mac_addr, bp->dev->dev_addr,
-			       ETH_ALEN);
-			memcpy(bp->dev->perm_addr, bp->dev->dev_addr,
-			       ETH_ALEN);
-		}
-
-		return rc;
-	}
-
-	if (BP_NOMCP(bp)) {
-		/* only supposed to happen on emulation/FPGA */
-		BNX2X_ERROR("warning: random MAC workaround active\n");
-		random_ether_addr(bp->dev->dev_addr);
-		memcpy(bp->dev->perm_addr, bp->dev->dev_addr, ETH_ALEN);
-	}
+	/* Get MAC addresses */
+	bnx2x_get_mac_hwinfo(bp);
 
 	return rc;
 }
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 1cefe48..64bdda1 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -1774,6 +1774,8 @@
 /* [RW 8] event id for llh0 */
 #define NIG_REG_LLH0_EVENT_ID					 0x10084
 #define NIG_REG_LLH0_FUNC_EN					 0x160fc
+#define NIG_REG_LLH0_FUNC_MEM					 0x16180
+#define NIG_REG_LLH0_FUNC_MEM_ENABLE				 0x16140
 #define NIG_REG_LLH0_FUNC_VLAN_ID				 0x16100
 /* [RW 1] Determine the IP version to look for in
    ~nig_registers_llh0_dest_ip_0.llh0_dest_ip_0. 0 - IPv6; 1-IPv4 */
@@ -1797,6 +1799,9 @@
 #define NIG_REG_LLH1_ERROR_MASK 				 0x10090
 /* [RW 8] event id for llh1 */
 #define NIG_REG_LLH1_EVENT_ID					 0x10088
+#define NIG_REG_LLH1_FUNC_MEM					 0x161c0
+#define NIG_REG_LLH1_FUNC_MEM_ENABLE				 0x16160
+#define NIG_REG_LLH1_FUNC_MEM_SIZE				 16
 /* [RW 8] init credit counter for port1 in LLH */
 #define NIG_REG_LLH1_XCM_INIT_CREDIT				 0x10564
 #define NIG_REG_LLH1_XCM_MASK					 0x10134
-- 
1.7.1




