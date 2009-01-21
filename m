From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH 1/9] bnx2x: remove a few trivial macros
Date: Tue, 20 Jan 2009 21:50:46 -0800
Message-ID: <1232517046.9701.19.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:24781 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbZAUFuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 00:50:50 -0500
Received: by wf-out-1314.google.com with SMTP id 27so4192261wfd.4
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 21:50:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Eilon, after this series, sparse with endian-checking at least gets through a
compile without hitting too many errors, patch 9 is a functional change
and may have exposed an endian bug in the driver....but I had to get through
the other 8 to see it ;-)

patches 1-8 shouldn't change any behavior...if it does it wasn't intentional.

 drivers/net/bnx2x.h      |    4 ---
 drivers/net/bnx2x_main.c |   62 +++++++++++++++++++++++-----------------------
 2 files changed, 31 insertions(+), 35 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 15a5cf0..7bda49d 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -228,10 +228,6 @@ struct bnx2x_fastpath {
 	u8			index;	/* number in fp array */
 	u8			cl_id;	/* eth client id */
 	u8			sb_id;	/* status block number in HW */
-#define FP_IDX(fp)			(fp->index)
-#define FP_CL_ID(fp)			(fp->cl_id)
-#define BP_CL_ID(bp)			(bp->fp[0].cl_id)
-#define FP_SB_ID(fp)			(fp->sb_id)
 #define CNIC_SB_ID			0
 
 	u16			tx_pkt_prod;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 074374f..897f370 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -906,12 +906,12 @@ static void bnx2x_sp_event(struct bnx2x_fastpath *fp,
 
 	DP(BNX2X_MSG_SP,
 	   "fp %d  cid %d  got ramrod #%d  state is %x  type is %d\n",
-	   FP_IDX(fp), cid, command, bp->state,
+	   fp->index, cid, command, bp->state,
 	   rr_cqe->ramrod_cqe.ramrod_type);
 
 	bp->spq_left++;
 
-	if (FP_IDX(fp)) {
+	if (fp->index) {
 		switch (command | fp->state) {
 		case (RAMROD_CMD_ID_ETH_CLIENT_SETUP |
 						BNX2X_FP_STATE_OPENING):
@@ -1389,7 +1389,7 @@ static inline void bnx2x_update_rx_prod(struct bnx2x *bp,
 
 	for (i = 0; i < sizeof(struct tstorm_eth_rx_producers)/4; i++)
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_RX_PRODS_OFFSET(BP_PORT(bp), FP_CL_ID(fp)) + i*4,
+		       TSTORM_RX_PRODS_OFFSET(BP_PORT(bp), fp->cl_id) + i*4,
 		       ((u32 *)&rx_prods)[i]);
 
 	mmiowb(); /* keep prod updates ordered */
@@ -1430,7 +1430,7 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 
 	DP(NETIF_MSG_RX_STATUS,
 	   "queue[%d]:  hw_comp_cons %u  sw_comp_cons %u\n",
-	   FP_IDX(fp), hw_comp_cons, sw_comp_cons);
+	   fp->index, hw_comp_cons, sw_comp_cons);
 
 	while (sw_comp_cons != hw_comp_cons) {
 		struct sw_rx_bd *rx_buf = NULL;
@@ -1625,7 +1625,7 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 {
 	struct bnx2x_fastpath *fp = fp_cookie;
 	struct bnx2x *bp = fp->bp;
-	int index = FP_IDX(fp);
+	int index = fp->index;
 
 	/* Return here if interrupt is disabled */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
@@ -1634,8 +1634,8 @@ static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
 	}
 
 	DP(BNX2X_MSG_FP, "got an MSI-X interrupt on IDX:SB [%d:%d]\n",
-	   index, FP_SB_ID(fp));
-	bnx2x_ack_sb(bp, FP_SB_ID(fp), USTORM_ID, 0, IGU_INT_DISABLE, 0);
+	   index, fp->sb_id);
+	bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID, 0, IGU_INT_DISABLE, 0);
 
 #ifdef BNX2X_STOP_ON_ERROR
 	if (unlikely(bp->panic))
@@ -3036,7 +3036,7 @@ static void bnx2x_storm_stats_post(struct bnx2x *bp)
 
 		ramrod_data.drv_counter = bp->stats_counter++;
 		ramrod_data.collect_port_1b = bp->port.pmf ? 1 : 0;
-		ramrod_data.ctr_id_vector = (1 << BP_CL_ID(bp));
+		ramrod_data.ctr_id_vector = (1 << bp->fp->cl_id);
 
 		rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_STAT_QUERY, 0,
 				   ((u32 *)&ramrod_data)[1],
@@ -3593,7 +3593,7 @@ static int bnx2x_hw_stats_update(struct bnx2x *bp)
 static int bnx2x_storm_stats_update(struct bnx2x *bp)
 {
 	struct eth_stats_query *stats = bnx2x_sp(bp, fw_stats);
-	int cl_id = BP_CL_ID(bp);
+	int cl_id = bp->fp->cl_id;
 	struct tstorm_per_port_stats *tport =
 				&stats->tstorm_common.port_statistics;
 	struct tstorm_per_client_stats *tclient =
@@ -4479,7 +4479,7 @@ static void bnx2x_init_context(struct bnx2x *bp)
 	for_each_queue(bp, i) {
 		struct eth_context *context = bnx2x_sp(bp, context[i].eth);
 		struct bnx2x_fastpath *fp = &bp->fp[i];
-		u8 sb_id = FP_SB_ID(fp);
+		u8 sb_id = fp->sb_id;
 
 		context->xstorm_st_context.tx_bd_page_base_hi =
 						U64_HI(fp->tx_desc_mapping);
@@ -4489,12 +4489,12 @@ static void bnx2x_init_context(struct bnx2x *bp)
 						U64_HI(fp->tx_prods_mapping);
 		context->xstorm_st_context.db_data_addr_lo =
 						U64_LO(fp->tx_prods_mapping);
-		context->xstorm_st_context.statistics_data = (BP_CL_ID(bp) |
+		context->xstorm_st_context.statistics_data = (bp->fp->cl_id |
 				XSTORM_ETH_ST_CONTEXT_STATISTICS_ENABLE);
 
 		context->ustorm_st_context.common.sb_index_numbers =
 						BNX2X_RX_SB_INDEX_NUM;
-		context->ustorm_st_context.common.clientId = FP_CL_ID(fp);
+		context->ustorm_st_context.common.clientId = fp->cl_id;
 		context->ustorm_st_context.common.status_block_id = sb_id;
 		context->ustorm_st_context.common.flags =
 			USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_MC_ALIGNMENT;
@@ -4545,7 +4545,7 @@ static void bnx2x_init_ind_table(struct bnx2x *bp)
 	for (i = 0; i < TSTORM_INDIRECTION_TABLE_SIZE; i++)
 		REG_WR8(bp, BAR_TSTRORM_INTMEM +
 			TSTORM_INDIRECTION_TABLE_OFFSET(func) + i,
-			BP_CL_ID(bp) + (i % bp->num_queues));
+			bp->fp->cl_id + (i % bp->num_queues));
 }
 
 static void bnx2x_set_client_config(struct bnx2x *bp)
@@ -4555,7 +4555,7 @@ static void bnx2x_set_client_config(struct bnx2x *bp)
 	int i;
 
 	tstorm_client.mtu = bp->dev->mtu;
-	tstorm_client.statistics_counter_id = BP_CL_ID(bp);
+	tstorm_client.statistics_counter_id = bp->fp->cl_id;
 	tstorm_client.config_flags =
 				TSTORM_ETH_CLIENT_CONFIG_STATSITICS_ENABLE;
 #ifdef BCM_VLAN
@@ -4695,13 +4695,13 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 	/* reset xstorm per client statistics */
 	for (i = 0; i < sizeof(struct xstorm_per_client_stats) / 4; i++) {
 		REG_WR(bp, BAR_XSTRORM_INTMEM +
-		       XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, BP_CL_ID(bp)) +
+		       XSTORM_PER_COUNTER_ID_STATS_OFFSET(port, bp->fp->cl_id) +
 		       i*4, 0);
 	}
 	/* reset tstorm per client statistics */
 	for (i = 0; i < sizeof(struct tstorm_per_client_stats) / 4; i++) {
 		REG_WR(bp, BAR_TSTRORM_INTMEM +
-		       TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, BP_CL_ID(bp)) +
+		       TSTORM_PER_COUNTER_ID_STATS_OFFSET(port, bp->fp->cl_id) +
 		       i*4, 0);
 	}
 
@@ -4760,14 +4760,14 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_CQE_PAGE_BASE_OFFSET(port, FP_CL_ID(fp)),
+		       USTORM_CQE_PAGE_BASE_OFFSET(port, fp->cl_id),
 		       U64_LO(fp->rx_comp_mapping));
 		REG_WR(bp, BAR_USTRORM_INTMEM +
-		       USTORM_CQE_PAGE_BASE_OFFSET(port, FP_CL_ID(fp)) + 4,
+		       USTORM_CQE_PAGE_BASE_OFFSET(port, fp->cl_id) + 4,
 		       U64_HI(fp->rx_comp_mapping));
 
 		REG_WR16(bp, BAR_USTRORM_INTMEM +
-			 USTORM_MAX_AGG_SIZE_OFFSET(port, FP_CL_ID(fp)),
+			 USTORM_MAX_AGG_SIZE_OFFSET(port, fp->cl_id),
 			 max_agg_size);
 	}
 }
@@ -4807,9 +4807,9 @@ static void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 		fp->sb_id = fp->cl_id;
 		DP(NETIF_MSG_IFUP,
 		   "bnx2x_init_sb(%p,%p) index %d  cl_id %d  sb %d\n",
-		   bp, fp->status_blk, i, FP_CL_ID(fp), FP_SB_ID(fp));
+		   bp, fp->status_blk, i, fp->cl_id, fp->sb_id);
 		bnx2x_init_sb(bp, fp->status_blk, fp->status_blk_mapping,
-			      FP_SB_ID(fp));
+			      fp->sb_id);
 		bnx2x_update_fpsb_idx(fp);
 	}
 
@@ -6156,7 +6156,7 @@ static void bnx2x_set_mac_addr_e1(struct bnx2x *bp, int set)
 	 */
 	config->hdr.length_6b = 2;
 	config->hdr.offset = port ? 32 : 0;
-	config->hdr.client_id = BP_CL_ID(bp);
+	config->hdr.client_id = bp->fp->cl_id;
 	config->hdr.reserved1 = 0;
 
 	/* primary MAC */
@@ -6214,7 +6214,7 @@ static void bnx2x_set_mac_addr_e1h(struct bnx2x *bp, int set)
 	 */
 	config->hdr.length_6b = 1;
 	config->hdr.offset = BP_FUNC(bp);
-	config->hdr.client_id = BP_CL_ID(bp);
+	config->hdr.client_id = bp->fp->cl_id;
 	config->hdr.reserved1 = 0;
 
 	/* primary MAC */
@@ -6558,7 +6558,7 @@ static int bnx2x_stop_leading(struct bnx2x *bp)
 
 	/* Send HALT ramrod */
 	bp->fp[0].state = BNX2X_FP_STATE_HALTING;
-	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, 0, 0, BP_CL_ID(bp), 0);
+	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_HALT, 0, 0, bp->fp->cl_id, 0);
 
 	/* Wait for completion */
 	rc = bnx2x_wait_ramrod(bp, BNX2X_FP_STATE_HALTED, 0,
@@ -6739,7 +6739,7 @@ static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 			config->hdr.offset = BNX2X_MAX_EMUL_MULTI*(1 + port);
 		else
 			config->hdr.offset = BNX2X_MAX_MULTICAST*(1 + port);
-		config->hdr.client_id = BP_CL_ID(bp);
+		config->hdr.client_id = bp->fp->cl_id;
 		config->hdr.reserved1 = 0;
 
 		bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
@@ -8779,7 +8779,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
 	fp->hw_tx_prods->packets_prod =
 		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
-	DOORBELL(bp, FP_IDX(fp), 0);
+	DOORBELL(bp, fp->index, 0);
 
 	mmiowb();
 
@@ -8928,7 +8928,7 @@ static int bnx2x_test_intr(struct bnx2x *bp)
 		config->hdr.offset = (BP_PORT(bp) ? 32 : 0);
 	else
 		config->hdr.offset = BP_FUNC(bp);
-	config->hdr.client_id = BP_CL_ID(bp);
+	config->hdr.client_id = bp->fp->cl_id;
 	config->hdr.reserved1 = 0;
 
 	rc = bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
@@ -9341,9 +9341,9 @@ poll_panic:
 #endif
 		netif_rx_complete(napi);
 
-		bnx2x_ack_sb(bp, FP_SB_ID(fp), USTORM_ID,
+		bnx2x_ack_sb(bp, fp->sb_id, USTORM_ID,
 			     le16_to_cpu(fp->fp_u_idx), IGU_INT_NOP, 1);
-		bnx2x_ack_sb(bp, FP_SB_ID(fp), CSTORM_ID,
+		bnx2x_ack_sb(bp, fp->sb_id, CSTORM_ID,
 			     le16_to_cpu(fp->fp_c_idx), IGU_INT_ENABLE, 1);
 	}
 	return work_done;
@@ -9779,7 +9779,7 @@ static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	mb(); /* FW restriction: must not reorder writing nbd and packets */
 	fp->hw_tx_prods->packets_prod =
 		cpu_to_le32(le32_to_cpu(fp->hw_tx_prods->packets_prod) + 1);
-	DOORBELL(bp, FP_IDX(fp), 0);
+	DOORBELL(bp, fp->index, 0);
 
 	mmiowb();
 
@@ -9904,7 +9904,7 @@ static void bnx2x_set_rx_mode(struct net_device *dev)
 
 			config->hdr.length_6b = i;
 			config->hdr.offset = offset;
-			config->hdr.client_id = BP_CL_ID(bp);
+			config->hdr.client_id = bp->fp->cl_id;
 			config->hdr.reserved1 = 0;
 
 			bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_SET_MAC, 0,
-- 
1.6.1.249.g455e5


