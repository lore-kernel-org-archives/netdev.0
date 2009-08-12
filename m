From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 04/36] bnx2x: Supporting Device Control Channel
Date: Wed, 12 Aug 2009 21:22:08 +0300
Message-ID: <1250101328.27379.155.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4825 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752635AbZHLSXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:23:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In multi-function mode, the FW can receive special management control commands
to set the Min/Max BW and the the function link state

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    6 +
 drivers/net/bnx2x_hsi.h  |   34 +++++-
 drivers/net/bnx2x_main.c |  325 +++++++++++++++++++++++++++++++++-------------
 3 files changed, 268 insertions(+), 97 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 16ccba8..5864ae2 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -128,6 +128,11 @@
 #define SHMEM_RD(bp, field)		REG_RD(bp, SHMEM_ADDR(bp, field))
 #define SHMEM_WR(bp, field, val)	REG_WR(bp, SHMEM_ADDR(bp, field), val)
 
+#define SHMEM2_ADDR(bp, field)		(bp->common.shmem2_base + \
+					 offsetof(struct shmem2_region, field))
+#define SHMEM2_RD(bp, field)		REG_RD(bp, SHMEM2_ADDR(bp, field))
+#define SHMEM2_WR(bp, field, val)	REG_WR(bp, SHMEM2_ADDR(bp, field), val)
+
 #define EMAC_RD(bp, reg)		REG_RD(bp, emac_base + reg)
 #define EMAC_WR(bp, reg, val)		REG_WR(bp, emac_base + reg, val)
 
@@ -535,6 +540,7 @@ struct bnx2x_common {
 #define NVRAM_PAGE_SIZE			256
 
 	u32			shmem_base;
+	u32			shmem2_base;
 
 	u32			hw_config;
 
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index da62cc5..8e2261f 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -658,6 +658,8 @@ struct drv_func_mb {
 #define DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS 		0x20010000
 #define DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP 		0x20020000
 #define DRV_MSG_CODE_UNLOAD_DONE			0x21000000
+#define DRV_MSG_CODE_DCC_OK				0x30000000
+#define DRV_MSG_CODE_DCC_FAILURE			0x31000000
 #define DRV_MSG_CODE_DIAG_ENTER_REQ			0x50000000
 #define DRV_MSG_CODE_DIAG_EXIT_REQ			0x60000000
 #define DRV_MSG_CODE_VALIDATE_KEY			0x70000000
@@ -692,6 +694,7 @@ struct drv_func_mb {
 #define FW_MSG_CODE_DRV_UNLOAD_PORT			0x20110000
 #define FW_MSG_CODE_DRV_UNLOAD_FUNCTION 		0x20120000
 #define FW_MSG_CODE_DRV_UNLOAD_DONE			0x21100000
+#define FW_MSG_CODE_DCC_DONE				0x30100000
 #define FW_MSG_CODE_DIAG_ENTER_DONE			0x50100000
 #define FW_MSG_CODE_DIAG_REFUSE 			0x50200000
 #define FW_MSG_CODE_DIAG_EXIT_DONE			0x60100000
@@ -742,6 +745,14 @@ struct drv_func_mb {
 	u32 drv_status;
 #define DRV_STATUS_PMF					0x00000001
 
+#define DRV_STATUS_DCC_EVENT_MASK			0x0000ff00
+#define DRV_STATUS_DCC_DISABLE_ENABLE_PF		0x00000100
+#define DRV_STATUS_DCC_BANDWIDTH_ALLOCATION		0x00000200
+#define DRV_STATUS_DCC_CHANGE_MAC_ADDRESS		0x00000400
+#define DRV_STATUS_DCC_RESERVED1			0x00000800
+#define DRV_STATUS_DCC_SET_PROTOCOL			0x00001000
+#define DRV_STATUS_DCC_SET_PRIORITY			0x00002000
+
 	u32 virt_mac_upper;
 #define VIRT_MAC_SIGN_MASK				0xffff0000
 #define VIRT_MAC_SIGNATURE				0x564d0000
@@ -778,10 +789,9 @@ struct shared_mf_cfg {
 struct port_mf_cfg {
 
 	u32 dynamic_cfg;	/* device control channel */
-#define PORT_MF_CFG_OUTER_VLAN_TAG_MASK 	    0x0000ffff
-#define PORT_MF_CFG_OUTER_VLAN_TAG_SHIFT	    0
-#define PORT_MF_CFG_DYNAMIC_CFG_ENABLED 	    0x00010000
-#define PORT_MF_CFG_DYNAMIC_CFG_DEFAULT 	    0x00000000
+#define PORT_MF_CFG_E1HOV_TAG_MASK		    0x0000ffff
+#define PORT_MF_CFG_E1HOV_TAG_SHIFT		    0
+#define PORT_MF_CFG_E1HOV_TAG_DEFAULT		    PORT_MF_CFG_E1HOV_TAG_MASK
 
 	u32 reserved[3];
 
@@ -885,6 +895,22 @@ struct shmem_region {			       /*   SharedMem Offset (size) */
 };						       /* 0x6dc */
 
 
+struct shmem2_region {
+
+	u32			size;
+
+	u32			dcc_support;
+#define SHMEM_DCC_SUPPORT_NONE			    0x00000000
+#define SHMEM_DCC_SUPPORT_DISABLE_ENABLE_PF_TLV     0x00000001
+#define SHMEM_DCC_SUPPORT_BANDWIDTH_ALLOCATION_TLV  0x00000004
+#define SHMEM_DCC_SUPPORT_CHANGE_MAC_ADDRESS_TLV    0x00000008
+#define SHMEM_DCC_SUPPORT_SET_PROTOCOL_TLV	    0x00000040
+#define SHMEM_DCC_SUPPORT_SET_PRIORITY_TLV	    0x00000080
+#define SHMEM_DCC_SUPPORT_DEFAULT		    SHMEM_DCC_SUPPORT_NONE
+
+};
+
+
 struct emac_stats {
     u32     rx_stat_ifhcinoctets;
     u32     rx_stat_ifhcinbadoctets;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 76b7fac..442ba61 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2103,6 +2103,12 @@ static void bnx2x_calc_fc_adv(struct bnx2x *bp)
 
 static void bnx2x_link_report(struct bnx2x *bp)
 {
+	if (bp->state == BNX2X_STATE_DISABLED) {
+		netif_carrier_off(bp->dev);
+		printk(KERN_ERR PFX "%s NIC Link is Down\n", bp->dev->name);
+		return;
+	}
+
 	if (bp->link_vars.link_up) {
 		if (bp->state == BNX2X_STATE_OPEN)
 			netif_carrier_on(bp->dev);
@@ -2239,6 +2245,46 @@ static void bnx2x_init_port_minmax(struct bnx2x *bp)
 	bp->cmng.fair_vars.fairness_timeout = fair_periodic_timeout_usec / 4;
 }
 
+/* Calculates the sum of vn_min_rates.
+   It's needed for further normalizing of the min_rates.
+   Returns:
+     sum of vn_min_rates.
+       or
+     0 - if all the min_rates are 0.
+     In the later case fainess algorithm should be deactivated.
+     If not all min_rates are zero then those that are zeroes will be set to 1.
+ */
+static void bnx2x_calc_vn_weight_sum(struct bnx2x *bp)
+{
+	int all_zero = 1;
+	int port = BP_PORT(bp);
+	int vn;
+
+	bp->vn_weight_sum = 0;
+	for (vn = VN_0; vn < E1HVN_MAX; vn++) {
+		int func = 2*vn + port;
+		u32 vn_cfg = SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
+		u32 vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
+				   FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
+
+		/* Skip hidden vns */
+		if (vn_cfg & FUNC_MF_CFG_FUNC_HIDE)
+			continue;
+
+		/* If min rate is zero - set it to 1 */
+		if (!vn_min_rate)
+			vn_min_rate = DEF_MIN_RATE;
+		else
+			all_zero = 0;
+
+		bp->vn_weight_sum += vn_min_rate;
+	}
+
+	/* ... only if all min rates are zeros - disable fairness */
+	if (all_zero)
+		bp->vn_weight_sum = 0;
+}
+
 static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func)
 {
 	struct rate_shaping_vars_per_vn m_rs_vn;
@@ -2382,6 +2428,8 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 
 static void bnx2x__link_status_update(struct bnx2x *bp)
 {
+	int func = BP_FUNC(bp);
+
 	if (bp->state != BNX2X_STATE_OPEN)
 		return;
 
@@ -2392,6 +2440,9 @@ static void bnx2x__link_status_update(struct bnx2x *bp)
 	else
 		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
+	bp->mf_config = SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
+	bnx2x_calc_vn_weight_sum(bp);
+
 	/* indicate link status */
 	bnx2x_link_report(bp);
 }
@@ -2420,6 +2471,152 @@ static void bnx2x_pmf_update(struct bnx2x *bp)
  * General service functions
  */
 
+/* send the MCP a request, block until there is a reply */
+u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
+{
+	int func = BP_FUNC(bp);
+	u32 seq = ++bp->fw_seq;
+	u32 rc = 0;
+	u32 cnt = 1;
+	u8 delay = CHIP_REV_IS_SLOW(bp) ? 100 : 10;
+
+	SHMEM_WR(bp, func_mb[func].drv_mb_header, (command | seq));
+	DP(BNX2X_MSG_MCP, "wrote command (%x) to FW MB\n", (command | seq));
+
+	do {
+		/* let the FW do it's magic ... */
+		msleep(delay);
+
+		rc = SHMEM_RD(bp, func_mb[func].fw_mb_header);
+
+		/* Give the FW up to 2 second (200*10ms) */
+	} while ((seq != (rc & FW_MSG_SEQ_NUMBER_MASK)) && (cnt++ < 200));
+
+	DP(BNX2X_MSG_MCP, "[after %d ms] read (%x) seq is (%x) from FW MB\n",
+	   cnt*delay, rc, seq);
+
+	/* is this a reply to our command? */
+	if (seq == (rc & FW_MSG_SEQ_NUMBER_MASK))
+		rc &= FW_MSG_CODE_MASK;
+	else {
+		/* FW BUG! */
+		BNX2X_ERR("FW failed to respond!\n");
+		bnx2x_fw_dump(bp);
+		rc = 0;
+	}
+
+	return rc;
+}
+
+static void bnx2x_set_storm_rx_mode(struct bnx2x *bp);
+static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp, int set);
+static void bnx2x_set_rx_mode(struct net_device *dev);
+
+static void bnx2x_e1h_disable(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+	int i;
+
+	bp->rx_mode = BNX2X_RX_MODE_NONE;
+	bnx2x_set_storm_rx_mode(bp);
+
+	netif_tx_disable(bp->dev);
+	bp->dev->trans_start = jiffies;	/* prevent tx timeout */
+
+	REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 0);
+
+	bnx2x_set_mac_addr_e1h(bp, 0);
+
+	for (i = 0; i < MC_HASH_SIZE; i++)
+		REG_WR(bp, MC_HASH_OFFSET(bp, i), 0);
+
+	netif_carrier_off(bp->dev);
+}
+
+static void bnx2x_e1h_enable(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+
+	REG_WR(bp, NIG_REG_LLH0_FUNC_EN + port*8, 1);
+
+	bnx2x_set_mac_addr_e1h(bp, 1);
+
+	/* Tx queue should be only reenabled */
+	netif_tx_wake_all_queues(bp->dev);
+
+	/* Initialize the receive filter. */
+	bnx2x_set_rx_mode(bp->dev);
+}
+
+static void bnx2x_update_min_max(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+	int vn, i;
+
+	/* Init rate shaping and fairness contexts */
+	bnx2x_init_port_minmax(bp);
+
+	bnx2x_calc_vn_weight_sum(bp);
+
+	for (vn = VN_0; vn < E1HVN_MAX; vn++)
+		bnx2x_init_vn_minmax(bp, 2*vn + port);
+
+	if (bp->port.pmf) {
+		int func;
+
+		/* Set the attention towards other drivers on the same port */
+		for (vn = VN_0; vn < E1HVN_MAX; vn++) {
+			if (vn == BP_E1HVN(bp))
+				continue;
+
+			func = ((vn << 1) | port);
+			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_0 +
+			       (LINK_SYNC_ATTENTION_BIT_FUNC_0 + func)*4, 1);
+		}
+
+		/* Store it to internal memory */
+		for (i = 0; i < sizeof(struct cmng_struct_per_port) / 4; i++)
+			REG_WR(bp, BAR_XSTRORM_INTMEM +
+			       XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) + i*4,
+			       ((u32 *)(&bp->cmng))[i]);
+	}
+}
+
+static void bnx2x_dcc_event(struct bnx2x *bp, u32 dcc_event)
+{
+	int func = BP_FUNC(bp);
+
+	DP(BNX2X_MSG_MCP, "dcc_event 0x%x\n", dcc_event);
+	bp->mf_config = SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
+
+	if (dcc_event & DRV_STATUS_DCC_DISABLE_ENABLE_PF) {
+
+		if (bp->mf_config & FUNC_MF_CFG_FUNC_DISABLED) {
+			DP(NETIF_MSG_IFDOWN, "mf_cfg function disabled\n");
+			bp->state = BNX2X_STATE_DISABLED;
+
+			bnx2x_e1h_disable(bp);
+		} else {
+			DP(NETIF_MSG_IFUP, "mf_cfg function enabled\n");
+			bp->state = BNX2X_STATE_OPEN;
+
+			bnx2x_e1h_enable(bp);
+		}
+		dcc_event &= ~DRV_STATUS_DCC_DISABLE_ENABLE_PF;
+	}
+	if (dcc_event & DRV_STATUS_DCC_BANDWIDTH_ALLOCATION) {
+
+		bnx2x_update_min_max(bp);
+		dcc_event &= ~DRV_STATUS_DCC_BANDWIDTH_ALLOCATION;
+	}
+
+	/* Report results to MCP */
+	if (dcc_event)
+		bnx2x_fw_command(bp, DRV_MSG_CODE_DCC_FAILURE);
+	else
+		bnx2x_fw_command(bp, DRV_MSG_CODE_DCC_OK);
+}
+
 /* the slow path queue is odd since completions arrive on the fastpath ring */
 static int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 			 u32 data_hi, u32 data_lo, int common)
@@ -2805,9 +3002,12 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 			int func = BP_FUNC(bp);
 
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_12 + func*4, 0);
+			val = SHMEM_RD(bp, func_mb[func].drv_status);
+			if (val & DRV_STATUS_DCC_EVENT_MASK)
+				bnx2x_dcc_event(bp,
+					    (val & DRV_STATUS_DCC_EVENT_MASK));
 			bnx2x__link_status_update(bp);
-			if (SHMEM_RD(bp, func_mb[func].drv_status) &
-							DRV_STATUS_PMF)
+			if ((bp->port.pmf == 0) && (val & DRV_STATUS_PMF))
 				bnx2x_pmf_update(bp);
 
 		} else if (attn & BNX2X_MC_ASSERT_BITS) {
@@ -4967,47 +5167,6 @@ static void bnx2x_init_internal_port(struct bnx2x *bp)
 	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_HC_BTR_OFFSET(port), BNX2X_BTR);
 }
 
-/* Calculates the sum of vn_min_rates.
-   It's needed for further normalizing of the min_rates.
-   Returns:
-     sum of vn_min_rates.
-       or
-     0 - if all the min_rates are 0.
-     In the later case fainess algorithm should be deactivated.
-     If not all min_rates are zero then those that are zeroes will be set to 1.
- */
-static void bnx2x_calc_vn_weight_sum(struct bnx2x *bp)
-{
-	int all_zero = 1;
-	int port = BP_PORT(bp);
-	int vn;
-
-	bp->vn_weight_sum = 0;
-	for (vn = VN_0; vn < E1HVN_MAX; vn++) {
-		int func = 2*vn + port;
-		u32 vn_cfg =
-			SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
-		u32 vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
-				   FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
-
-		/* Skip hidden vns */
-		if (vn_cfg & FUNC_MF_CFG_FUNC_HIDE)
-			continue;
-
-		/* If min rate is zero - set it to 1 */
-		if (!vn_min_rate)
-			vn_min_rate = DEF_MIN_RATE;
-		else
-			all_zero = 0;
-
-		bp->vn_weight_sum += vn_min_rate;
-	}
-
-	/* ... only if all min rates are zeros - disable fairness */
-	if (all_zero)
-		bp->vn_weight_sum = 0;
-}
-
 static void bnx2x_init_internal_func(struct bnx2x *bp)
 {
 	struct tstorm_eth_function_common_config tstorm_config = {0};
@@ -6271,44 +6430,6 @@ init_hw_err:
 	return rc;
 }
 
-/* send the MCP a request, block until there is a reply */
-u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
-{
-	int func = BP_FUNC(bp);
-	u32 seq = ++bp->fw_seq;
-	u32 rc = 0;
-	u32 cnt = 1;
-	u8 delay = CHIP_REV_IS_SLOW(bp) ? 100 : 10;
-
-	SHMEM_WR(bp, func_mb[func].drv_mb_header, (command | seq));
-	DP(BNX2X_MSG_MCP, "wrote command (%x) to FW MB\n", (command | seq));
-
-	do {
-		/* let the FW do it's magic ... */
-		msleep(delay);
-
-		rc = SHMEM_RD(bp, func_mb[func].fw_mb_header);
-
-		/* Give the FW up to 2 second (200*10ms) */
-	} while ((seq != (rc & FW_MSG_SEQ_NUMBER_MASK)) && (cnt++ < 200));
-
-	DP(BNX2X_MSG_MCP, "[after %d ms] read (%x) seq is (%x) from FW MB\n",
-	   cnt*delay, rc, seq);
-
-	/* is this a reply to our command? */
-	if (seq == (rc & FW_MSG_SEQ_NUMBER_MASK)) {
-		rc &= FW_MSG_CODE_MASK;
-
-	} else {
-		/* FW BUG! */
-		BNX2X_ERR("FW failed to respond!\n");
-		bnx2x_fw_dump(bp);
-		rc = 0;
-	}
-
-	return rc;
-}
-
 static void bnx2x_free_mem(struct bnx2x *bp)
 {
 
@@ -6995,7 +7116,6 @@ static int bnx2x_set_int_mode(struct bnx2x *bp)
 	return rc;
 }
 
-static void bnx2x_set_rx_mode(struct net_device *dev);
 
 /* must be called with rtnl_lock */
 static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
@@ -7102,6 +7222,12 @@ static int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	/* Setup NIC internals and enable interrupts */
 	bnx2x_nic_init(bp, load_code);
 
+	if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) &&
+	    (bp->common.shmem2_base))
+		SHMEM2_WR(bp, dcc_support,
+			  (SHMEM_DCC_SUPPORT_DISABLE_ENABLE_PF_TLV |
+			   SHMEM_DCC_SUPPORT_BANDWIDTH_ALLOCATION_TLV));
+
 	/* Send LOAD_DONE command to MCP */
 	if (!BP_NOMCP(bp)) {
 		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
@@ -7734,8 +7860,10 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 		       bp->common.flash_size, bp->common.flash_size);
 
 	bp->common.shmem_base = REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
+	bp->common.shmem2_base = REG_RD(bp, MISC_REG_GENERIC_CR_0);
 	bp->link_params.shmem_base = bp->common.shmem_base;
-	BNX2X_DEV_INFO("shmem offset is 0x%x\n", bp->common.shmem_base);
+	BNX2X_DEV_INFO("shmem offset 0x%x  shmem2 offset 0x%x\n",
+		       bp->common.shmem_base, bp->common.shmem2_base);
 
 	if (!bp->common.shmem_base ||
 	    (bp->common.shmem_base < 0xA0000) ||
@@ -8289,22 +8417,33 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 		bp->mf_config =
 			SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
 
-		val = (SHMEM_RD(bp, mf_cfg.func_mf_config[func].e1hov_tag) &
+		val = (SHMEM_RD(bp, mf_cfg.func_mf_config[FUNC_0].e1hov_tag) &
 		       FUNC_MF_CFG_E1HOV_TAG_MASK);
-		if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
-
-			bp->e1hov = val;
+		if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT)
 			bp->e1hmf = 1;
-			BNX2X_DEV_INFO("MF mode  E1HOV for func %d is %d "
-				       "(0x%04x)\n",
-				       func, bp->e1hov, bp->e1hov);
-		} else {
-			BNX2X_DEV_INFO("single function mode\n");
-			if (BP_E1HVN(bp)) {
+		BNX2X_DEV_INFO("%s function mode\n",
+			       IS_E1HMF(bp) ? "multi" : "single");
+
+		if (IS_E1HMF(bp)) {
+			val = (SHMEM_RD(bp, mf_cfg.func_mf_config[func].
+								e1hov_tag) &
+			       FUNC_MF_CFG_E1HOV_TAG_MASK);
+			if (val != FUNC_MF_CFG_E1HOV_TAG_DEFAULT) {
+				bp->e1hov = val;
+				BNX2X_DEV_INFO("E1HOV for func %d is %d "
+					       "(0x%04x)\n",
+					       func, bp->e1hov, bp->e1hov);
+			} else {
 				BNX2X_ERR("!!!  No valid E1HOV for func %d,"
 					  "  aborting\n", func);
 				rc = -EPERM;
 			}
+		} else {
+			if (BP_E1HVN(bp)) {
+				BNX2X_ERR("!!!  VN %d in single function mode,"
+					  "  aborting\n", BP_E1HVN(bp));
+				rc = -EPERM;
+			}
 		}
 	}
 
-- 
1.5.4.3




