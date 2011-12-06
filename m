From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/4 v2] bnx2x: add fcoe statistics
Date: Mon, 5 Dec 2011 23:52:23 -0800
Message-ID: <1323157945-28333-2-git-send-email-mchan@broadcom.com>
References: <1323157945-28333-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, barak@broadcom.com, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3016 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932923Ab1LFHq6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 02:46:58 -0500
In-Reply-To: <1323157945-28333-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowski <barak@broadcom.com>

Add FCoE statistics support for FCoE capable devices.

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |    5 ++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h   |   56 ++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |   38 +++++++-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |   44 ++++++++++++++++-
 4 files changed, 120 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 32af052..40cfce0 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1128,18 +1128,21 @@ enum {
 enum {
 	BNX2X_PORT_QUERY_IDX,
 	BNX2X_PF_QUERY_IDX,
+	BNX2X_FCOE_QUERY_IDX,
 	BNX2X_FIRST_QUEUE_QUERY_IDX,
 };
 
 struct bnx2x_fw_stats_req {
 	struct stats_query_header hdr;
-	struct stats_query_entry query[STATS_QUERY_CMD_COUNT];
+	struct stats_query_entry query[FP_SB_MAX_E1x+
+		BNX2X_FIRST_QUEUE_QUERY_IDX];
 };
 
 struct bnx2x_fw_stats_data {
 	struct stats_counter	storm_counters;
 	struct per_port_stats	port;
 	struct per_pf_stats	pf;
+	struct fcoe_statistics_params	fcoe;
 	struct per_queue_stats  queue_stats[1];
 };
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 79b6e43..d9f07cb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -4166,8 +4166,62 @@ struct ustorm_eth_rx_producers {
 
 
 /*
- * cfc delete event data
+ * FCoE RX statistics parameters section#0
+ */
+struct fcoe_rx_stat_params_section0 {
+	__le32 fcoe_rx_pkt_cnt;
+	__le32 fcoe_rx_byte_cnt;
+};
+
+
+/*
+ * FCoE RX statistics parameters section#1
+ */
+struct fcoe_rx_stat_params_section1 {
+	__le32 fcoe_ver_cnt;
+	__le32 fcoe_rx_drop_pkt_cnt;
+};
+
+
+/*
+ * FCoE RX statistics parameters section#2
  */
+struct fcoe_rx_stat_params_section2 {
+	__le32 fc_crc_cnt;
+	__le32 eofa_del_cnt;
+	__le32 miss_frame_cnt;
+	__le32 seq_timeout_cnt;
+	__le32 drop_seq_cnt;
+	__le32 fcoe_rx_drop_pkt_cnt;
+	__le32 fcp_rx_pkt_cnt;
+	__le32 reserved0;
+};
+
+
+/*
+ * FCoE TX statistics parameters
+ */
+struct fcoe_tx_stat_params {
+	__le32 fcoe_tx_pkt_cnt;
+	__le32 fcoe_tx_byte_cnt;
+	__le32 fcp_tx_pkt_cnt;
+	__le32 reserved0;
+};
+
+/*
+ * FCoE statistics parameters
+ */
+struct fcoe_statistics_params {
+	struct fcoe_tx_stat_params tx_stat;
+	struct fcoe_rx_stat_params_section0 rx_stat0;
+	struct fcoe_rx_stat_params_section1 rx_stat1;
+	struct fcoe_rx_stat_params_section2 rx_stat2;
+};
+
+
+/*
+ * cfc delete event data
+*/
 struct cfc_del_event_data {
 	u32 cid;
 	u32 reserved0;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 052ab99..552c564 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2624,15 +2624,6 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command, u32 param)
 	return rc;
 }
 
-static u8 stat_counter_valid(struct bnx2x *bp, struct bnx2x_fastpath *fp)
-{
-#ifdef BCM_CNIC
-	/* Statistics are not supported for CNIC Clients at the moment */
-	if (IS_FCOE_FP(fp))
-		return false;
-#endif
-	return true;
-}
 
 void bnx2x_func_init(struct bnx2x *bp, struct bnx2x_func_init_params *p)
 {
@@ -2676,11 +2667,11 @@ static inline unsigned long bnx2x_get_common_flags(struct bnx2x *bp,
 	 *  parent connection). The statistics are zeroed when the parent
 	 *  connection is initialized.
 	 */
-	if (stat_counter_valid(bp, fp)) {
-		__set_bit(BNX2X_Q_FLG_STATS, &flags);
-		if (zero_stats)
-			__set_bit(BNX2X_Q_FLG_ZERO_STATS, &flags);
-	}
+
+	__set_bit(BNX2X_Q_FLG_STATS, &flags);
+	if (zero_stats)
+		__set_bit(BNX2X_Q_FLG_ZERO_STATS, &flags);
+
 
 	return flags;
 }
@@ -6848,13 +6839,16 @@ void bnx2x_free_mem(struct bnx2x *bp)
 static inline int bnx2x_alloc_fw_stats_mem(struct bnx2x *bp)
 {
 	int num_groups;
+	int is_fcoe_stats = NO_FCOE(bp) ? 0 : 1;
 
-	/* number of eth_queues */
-	u8 num_queue_stats = BNX2X_NUM_ETH_QUEUES(bp);
+	/* number of queues for statistics is number of eth queues + FCoE */
+	u8 num_queue_stats = BNX2X_NUM_ETH_QUEUES(bp) + is_fcoe_stats;
 
 	/* Total number of FW statistics requests =
-	 * 1 for port stats + 1 for PF stats + num_eth_queues */
-	bp->fw_stats_num = 2 + num_queue_stats;
+	 * 1 for port stats + 1 for PF stats + potential 1 for FCoE stats +
+	 * num of queues
+	 */
+	bp->fw_stats_num = 2 + is_fcoe_stats + num_queue_stats;
 
 
 	/* Request is built from stats_query_header and an array of
@@ -6862,8 +6856,8 @@ static inline int bnx2x_alloc_fw_stats_mem(struct bnx2x *bp)
 	 * STATS_QUERY_CMD_COUNT rules. The real number or requests is
 	 * configured in the stats_query_header.
 	 */
-	num_groups = (2 + num_queue_stats) / STATS_QUERY_CMD_COUNT +
-		(((2 + num_queue_stats) % STATS_QUERY_CMD_COUNT) ? 1 : 0);
+	num_groups = ((bp->fw_stats_num) / STATS_QUERY_CMD_COUNT) +
+		     (((bp->fw_stats_num) % STATS_QUERY_CMD_COUNT) ? 1 : 0);
 
 	bp->fw_stats_req_sz = sizeof(struct stats_query_header) +
 			num_groups * sizeof(struct stats_query_cmd_group);
@@ -6872,9 +6866,13 @@ static inline int bnx2x_alloc_fw_stats_mem(struct bnx2x *bp)
 	 *
 	 * stats_counter holds per-STORM counters that are incremented
 	 * when STORM has finished with the current request.
+	 *
+	 * memory for FCoE offloaded statistics are counted anyway,
+	 * even if they will not be sent.
 	 */
 	bp->fw_stats_data_sz = sizeof(struct per_port_stats) +
 		sizeof(struct per_pf_stats) +
+		sizeof(struct fcoe_statistics_params) +
 		sizeof(struct per_queue_stats) * num_queue_stats +
 		sizeof(struct stats_counter);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index c943545..41a33ce 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1501,6 +1501,7 @@ static void bnx2x_func_stats_base_update(struct bnx2x *bp)
 static inline void bnx2x_prep_fw_stats_req(struct bnx2x *bp)
 {
 	int i;
+	int first_queue_query_index;
 	struct stats_query_header *stats_hdr = &bp->fw_stats_req->hdr;
 
 	dma_addr_t cur_data_offset;
@@ -1556,14 +1557,40 @@ static inline void bnx2x_prep_fw_stats_req(struct bnx2x *bp)
 	cur_query_entry->address.hi = cpu_to_le32(U64_HI(cur_data_offset));
 	cur_query_entry->address.lo = cpu_to_le32(U64_LO(cur_data_offset));
 
+	/**** FCoE FW statistics data ****/
+	if (!NO_FCOE(bp)) {
+		cur_data_offset = bp->fw_stats_data_mapping +
+			offsetof(struct bnx2x_fw_stats_data, fcoe);
+
+		cur_query_entry =
+			&bp->fw_stats_req->query[BNX2X_FCOE_QUERY_IDX];
+
+		cur_query_entry->kind = STATS_TYPE_FCOE;
+		/* For FCoE query index is a DONT CARE */
+		cur_query_entry->index = BP_PORT(bp);
+		cur_query_entry->funcID = cpu_to_le16(BP_FUNC(bp));
+		cur_query_entry->address.hi =
+			cpu_to_le32(U64_HI(cur_data_offset));
+		cur_query_entry->address.lo =
+			cpu_to_le32(U64_LO(cur_data_offset));
+	}
+
 	/**** Clients' queries ****/
 	cur_data_offset = bp->fw_stats_data_mapping +
 		offsetof(struct bnx2x_fw_stats_data, queue_stats);
 
+	/* first queue query index depends whether FCoE offloaded request will
+	 * be included in the ramrod
+	 */
+	if (!NO_FCOE(bp))
+		first_queue_query_index = BNX2X_FIRST_QUEUE_QUERY_IDX;
+	else
+		first_queue_query_index = BNX2X_FIRST_QUEUE_QUERY_IDX - 1;
+
 	for_each_eth_queue(bp, i) {
 		cur_query_entry =
 			&bp->fw_stats_req->
-					query[BNX2X_FIRST_QUEUE_QUERY_IDX + i];
+					query[first_queue_query_index + i];
 
 		cur_query_entry->kind = STATS_TYPE_QUEUE;
 		cur_query_entry->index = bnx2x_stats_id(&bp->fp[i]);
@@ -1575,6 +1602,21 @@ static inline void bnx2x_prep_fw_stats_req(struct bnx2x *bp)
 
 		cur_data_offset += sizeof(struct per_queue_stats);
 	}
+
+	/* add FCoE queue query if needed */
+	if (!NO_FCOE(bp)) {
+		cur_query_entry =
+			&bp->fw_stats_req->
+					query[first_queue_query_index + i];
+
+		cur_query_entry->kind = STATS_TYPE_QUEUE;
+		cur_query_entry->index = bnx2x_stats_id(&bp->fp[FCOE_IDX]);
+		cur_query_entry->funcID = cpu_to_le16(BP_FUNC(bp));
+		cur_query_entry->address.hi =
+			cpu_to_le32(U64_HI(cur_data_offset));
+		cur_query_entry->address.lo =
+			cpu_to_le32(U64_LO(cur_data_offset));
+	}
 }
 
 void bnx2x_stats_init(struct bnx2x *bp)
-- 
1.7.1
