From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 14/36] bnx2x: Reporting host statistics to management
 FW
Date: Wed, 12 Aug 2009 21:23:17 +0300
Message-ID: <1250101397.27379.166.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4884 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751444AbZHLSYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:24:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is required for NCSI statistics

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    1 +
 drivers/net/bnx2x_main.c |  228 +++++++++++++++++++++++++++++++++++-----------
 2 files changed, 176 insertions(+), 53 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 903c89d..1d0b727 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -777,6 +777,7 @@ struct bnx2x_slowpath {
 	struct nig_stats		nig_stats;
 	struct host_port_stats		port_stats;
 	struct host_func_stats		func_stats;
+	struct host_func_stats		func_stats_base;
 
 	u32				wb_comp;
 	u32				wb_data[4];
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 06b250b..e6fde5e 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -3364,53 +3364,6 @@ static void bnx2x_storm_stats_post(struct bnx2x *bp)
 	}
 }
 
-static void bnx2x_stats_init(struct bnx2x *bp)
-{
-	int port = BP_PORT(bp);
-	int i;
-
-	bp->stats_pending = 0;
-	bp->executer_idx = 0;
-	bp->stats_counter = 0;
-
-	/* port stats */
-	if (!BP_NOMCP(bp))
-		bp->port.port_stx = SHMEM_RD(bp, port_mb[port].port_stx);
-	else
-		bp->port.port_stx = 0;
-	DP(BNX2X_MSG_STATS, "port_stx 0x%x\n", bp->port.port_stx);
-
-	memset(&(bp->port.old_nig_stats), 0, sizeof(struct nig_stats));
-	bp->port.old_nig_stats.brb_discard =
-			REG_RD(bp, NIG_REG_STAT0_BRB_DISCARD + port*0x38);
-	bp->port.old_nig_stats.brb_truncate =
-			REG_RD(bp, NIG_REG_STAT0_BRB_TRUNCATE + port*0x38);
-	REG_RD_DMAE(bp, NIG_REG_STAT0_EGRESS_MAC_PKT0 + port*0x50,
-		    &(bp->port.old_nig_stats.egress_mac_pkt0_lo), 2);
-	REG_RD_DMAE(bp, NIG_REG_STAT0_EGRESS_MAC_PKT1 + port*0x50,
-		    &(bp->port.old_nig_stats.egress_mac_pkt1_lo), 2);
-
-	/* function stats */
-	for_each_queue(bp, i) {
-		struct bnx2x_fastpath *fp = &bp->fp[i];
-
-		memset(&fp->old_tclient, 0,
-		       sizeof(struct tstorm_per_client_stats));
-		memset(&fp->old_uclient, 0,
-		       sizeof(struct ustorm_per_client_stats));
-		memset(&fp->old_xclient, 0,
-		       sizeof(struct xstorm_per_client_stats));
-		memset(&fp->eth_q_stats, 0, sizeof(struct bnx2x_eth_q_stats));
-	}
-
-	memset(&bp->dev->stats, 0, sizeof(struct net_device_stats));
-	memset(&bp->eth_stats, 0, sizeof(struct bnx2x_eth_stats));
-
-	bp->stats_state = STATS_STATE_DISABLED;
-	if (IS_E1HMF(bp) && bp->port.pmf && bp->port.port_stx)
-		bnx2x_stats_handle(bp, STATS_EVENT_PMF);
-}
-
 static void bnx2x_hw_stats_post(struct bnx2x *bp)
 {
 	struct dmae_command *dmae = &bp->stats_dmae;
@@ -3971,7 +3924,8 @@ static int bnx2x_storm_stats_update(struct bnx2x *bp)
 	struct bnx2x_eth_stats *estats = &bp->eth_stats;
 	int i;
 
-	memset(&(fstats->total_bytes_received_hi), 0,
+	memcpy(&(fstats->total_bytes_received_hi),
+	       &(bnx2x_sp(bp, func_stats_base)->total_bytes_received_hi),
 	       sizeof(struct host_func_stats) - 2*sizeof(u32));
 	estats->error_bytes_received_hi = 0;
 	estats->error_bytes_received_lo = 0;
@@ -4450,6 +4404,173 @@ static void bnx2x_stats_handle(struct bnx2x *bp, enum bnx2x_stats_event event)
 		   state, event, bp->stats_state);
 }
 
+static void bnx2x_port_stats_base_init(struct bnx2x *bp)
+{
+	struct dmae_command *dmae;
+	u32 *stats_comp = bnx2x_sp(bp, stats_comp);
+
+	/* sanity */
+	if (!bp->port.pmf || !bp->port.port_stx) {
+		BNX2X_ERR("BUG!\n");
+		return;
+	}
+
+	bp->executer_idx = 0;
+
+	dmae = bnx2x_sp(bp, dmae[bp->executer_idx++]);
+	dmae->opcode = (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
+			DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
+			DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
+#ifdef __BIG_ENDIAN
+			DMAE_CMD_ENDIANITY_B_DW_SWAP |
+#else
+			DMAE_CMD_ENDIANITY_DW_SWAP |
+#endif
+			(BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+			(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+	dmae->src_addr_lo = U64_LO(bnx2x_sp_mapping(bp, port_stats));
+	dmae->src_addr_hi = U64_HI(bnx2x_sp_mapping(bp, port_stats));
+	dmae->dst_addr_lo = bp->port.port_stx >> 2;
+	dmae->dst_addr_hi = 0;
+	dmae->len = sizeof(struct host_port_stats) >> 2;
+	dmae->comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, stats_comp));
+	dmae->comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, stats_comp));
+	dmae->comp_val = DMAE_COMP_VAL;
+
+	*stats_comp = 0;
+	bnx2x_hw_stats_post(bp);
+	bnx2x_stats_comp(bp);
+}
+
+static void bnx2x_func_stats_base_init(struct bnx2x *bp)
+{
+	int vn, vn_max = IS_E1HMF(bp) ? E1HVN_MAX : E1VN_MAX;
+	int port = BP_PORT(bp);
+	int func;
+	u32 func_stx;
+
+	/* sanity */
+	if (!bp->port.pmf || !bp->func_stx) {
+		BNX2X_ERR("BUG!\n");
+		return;
+	}
+
+	/* save our func_stx */
+	func_stx = bp->func_stx;
+
+	for (vn = VN_0; vn < vn_max; vn++) {
+		func = 2*vn + port;
+
+		bp->func_stx = SHMEM_RD(bp, func_mb[func].fw_mb_param);
+		bnx2x_func_stats_init(bp);
+		bnx2x_hw_stats_post(bp);
+		bnx2x_stats_comp(bp);
+	}
+
+	/* restore our func_stx */
+	bp->func_stx = func_stx;
+}
+
+static void bnx2x_func_stats_base_update(struct bnx2x *bp)
+{
+	struct dmae_command *dmae = &bp->stats_dmae;
+	u32 *stats_comp = bnx2x_sp(bp, stats_comp);
+
+	/* sanity */
+	if (!bp->func_stx) {
+		BNX2X_ERR("BUG!\n");
+		return;
+	}
+
+	bp->executer_idx = 0;
+	memset(dmae, 0, sizeof(struct dmae_command));
+
+	dmae->opcode = (DMAE_CMD_SRC_GRC | DMAE_CMD_DST_PCI |
+			DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
+			DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
+#ifdef __BIG_ENDIAN
+			DMAE_CMD_ENDIANITY_B_DW_SWAP |
+#else
+			DMAE_CMD_ENDIANITY_DW_SWAP |
+#endif
+			(BP_PORT(bp) ? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0) |
+			(BP_E1HVN(bp) << DMAE_CMD_E1HVN_SHIFT));
+	dmae->src_addr_lo = bp->func_stx >> 2;
+	dmae->src_addr_hi = 0;
+	dmae->dst_addr_lo = U64_LO(bnx2x_sp_mapping(bp, func_stats_base));
+	dmae->dst_addr_hi = U64_HI(bnx2x_sp_mapping(bp, func_stats_base));
+	dmae->len = sizeof(struct host_func_stats) >> 2;
+	dmae->comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, stats_comp));
+	dmae->comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, stats_comp));
+	dmae->comp_val = DMAE_COMP_VAL;
+
+	*stats_comp = 0;
+	bnx2x_hw_stats_post(bp);
+	bnx2x_stats_comp(bp);
+}
+
+static void bnx2x_stats_init(struct bnx2x *bp)
+{
+	int port = BP_PORT(bp);
+	int func = BP_FUNC(bp);
+	int i;
+
+	bp->stats_pending = 0;
+	bp->executer_idx = 0;
+	bp->stats_counter = 0;
+
+	/* port and func stats for management */
+	if (!BP_NOMCP(bp)) {
+		bp->port.port_stx = SHMEM_RD(bp, port_mb[port].port_stx);
+		bp->func_stx = SHMEM_RD(bp, func_mb[func].fw_mb_param);
+
+	} else {
+		bp->port.port_stx = 0;
+		bp->func_stx = 0;
+	}
+	DP(BNX2X_MSG_STATS, "port_stx 0x%x  func_stx 0x%x\n",
+	   bp->port.port_stx, bp->func_stx);
+
+	/* port stats */
+	memset(&(bp->port.old_nig_stats), 0, sizeof(struct nig_stats));
+	bp->port.old_nig_stats.brb_discard =
+			REG_RD(bp, NIG_REG_STAT0_BRB_DISCARD + port*0x38);
+	bp->port.old_nig_stats.brb_truncate =
+			REG_RD(bp, NIG_REG_STAT0_BRB_TRUNCATE + port*0x38);
+	REG_RD_DMAE(bp, NIG_REG_STAT0_EGRESS_MAC_PKT0 + port*0x50,
+		    &(bp->port.old_nig_stats.egress_mac_pkt0_lo), 2);
+	REG_RD_DMAE(bp, NIG_REG_STAT0_EGRESS_MAC_PKT1 + port*0x50,
+		    &(bp->port.old_nig_stats.egress_mac_pkt1_lo), 2);
+
+	/* function stats */
+	for_each_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+
+		memset(&fp->old_tclient, 0,
+		       sizeof(struct tstorm_per_client_stats));
+		memset(&fp->old_uclient, 0,
+		       sizeof(struct ustorm_per_client_stats));
+		memset(&fp->old_xclient, 0,
+		       sizeof(struct xstorm_per_client_stats));
+		memset(&fp->eth_q_stats, 0, sizeof(struct bnx2x_eth_q_stats));
+	}
+
+	memset(&bp->dev->stats, 0, sizeof(struct net_device_stats));
+	memset(&bp->eth_stats, 0, sizeof(struct bnx2x_eth_stats));
+
+	bp->stats_state = STATS_STATE_DISABLED;
+
+	if (bp->port.pmf) {
+		if (bp->port.port_stx)
+			bnx2x_port_stats_base_init(bp);
+
+		if (bp->func_stx)
+			bnx2x_func_stats_base_init(bp);
+
+	} else if (bp->func_stx)
+		bnx2x_func_stats_base_update(bp);
+}
+
 static void bnx2x_timer(unsigned long data)
 {
 	struct bnx2x *bp = (struct bnx2x *) data;
@@ -4932,6 +5053,10 @@ static void bnx2x_init_tx_ring(struct bnx2x *bp)
 		fp->tx_cons_sb = BNX2X_TX_SB_INDEX;
 		fp->tx_pkt = 0;
 	}
+
+	/* clean tx statistics */
+	for_each_rx_queue(bp, i)
+		bnx2x_fp(bp, i, tx_pkt) = 0;
 }
 
 static void bnx2x_init_sp_ring(struct bnx2x *bp)
@@ -6411,11 +6536,8 @@ static int bnx2x_init_hw(struct bnx2x *bp, u32 load_code)
 		bp->fw_drv_pulse_wr_seq =
 				(SHMEM_RD(bp, func_mb[func].drv_pulse_mb) &
 				 DRV_PULSE_SEQ_MASK);
-		bp->func_stx = SHMEM_RD(bp, func_mb[func].fw_mb_param);
-		DP(BNX2X_MSG_MCP, "drv_pulse 0x%x  func_stx 0x%x\n",
-		   bp->fw_drv_pulse_wr_seq, bp->func_stx);
-	} else
-		bp->func_stx = 0;
+		DP(BNX2X_MSG_MCP, "drv_pulse 0x%x\n", bp->fw_drv_pulse_wr_seq);
+	}
 
 	/* this needs to be done before gunzip end */
 	bnx2x_zero_def_sb(bp);
-- 
1.5.4.3




