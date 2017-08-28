From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 11/11] bnxt_en: add code to query TC flower offload stats
Date: Mon, 28 Aug 2017 13:40:35 -0400
Message-ID: <1503942035-24924-12-git-send-email-michael.chan@broadcom.com>
References: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:34627 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751564AbdH1RlE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 13:41:04 -0400
Received: by mail-qk0-f171.google.com with SMTP id a77so5390709qkb.1
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 10:41:04 -0700 (PDT)
In-Reply-To: <1503942035-24924-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>

This patch adds code to implement TC_CLSFLOWER_STATS TC-cmd and the
required FW code to query the stats from the HW.

Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c | 95 ++++++++++++++++++++++++++++
 1 file changed, 95 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
index 5fa0835..ccd699f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
@@ -405,6 +405,81 @@ static int bnxt_hwrm_cfa_flow_alloc(struct bnxt *bp, struct bnxt_tc_flow *flow,
 	return rc;
 }
 
+/* Add val to accum while handling a possible wraparound
+ * of val. Eventhough val is of type u64, its actual width
+ * is denoted by mask and will wrap-around beyond that width.
+ */
+static void accumulate_val(u64 *accum, u64 val, u64 mask)
+{
+#define low_bits(x, mask)		((x) & (mask))
+#define high_bits(x, mask)		((x) & ~(mask))
+	bool wrapped = val < low_bits(*accum, mask);
+
+	*accum = high_bits(*accum, mask) + val;
+	if (wrapped)
+		*accum += (mask + 1);
+}
+
+/* The HW counters' width is much less than 64bits.
+ * Handle possible wrap-around while updating the stat counters
+ */
+static void bnxt_flow_stats_fix_wraparound(struct bnxt_tc_info *tc_info,
+					   struct bnxt_tc_flow_stats *stats,
+					   struct bnxt_tc_flow_stats *hw_stats)
+{
+	accumulate_val(&stats->bytes, hw_stats->bytes, tc_info->bytes_mask);
+	accumulate_val(&stats->packets, hw_stats->packets,
+		       tc_info->packets_mask);
+}
+
+/* Fix possible wraparound of the stats queried from HW, calculate
+ * the delta from prev_stats, and also update the prev_stats.
+ * The HW flow stats are fetched under the hwrm_cmd_lock mutex.
+ * This routine is best called while under the mutex so that the
+ * stats processing happens atomically.
+ */
+static void bnxt_flow_stats_calc(struct bnxt_tc_info *tc_info,
+				 struct bnxt_tc_flow *flow,
+				 struct bnxt_tc_flow_stats *stats)
+{
+	struct bnxt_tc_flow_stats *acc_stats, *prev_stats;
+
+	acc_stats = &flow->stats;
+	bnxt_flow_stats_fix_wraparound(tc_info, acc_stats, stats);
+
+	prev_stats = &flow->prev_stats;
+	stats->bytes = acc_stats->bytes - prev_stats->bytes;
+	stats->packets = acc_stats->packets - prev_stats->packets;
+	*prev_stats = *acc_stats;
+}
+
+static int bnxt_hwrm_cfa_flow_stats_get(struct bnxt *bp,
+					__le16 flow_handle,
+					struct bnxt_tc_flow *flow,
+					struct bnxt_tc_flow_stats *stats)
+{
+	struct hwrm_cfa_flow_stats_output *resp = bp->hwrm_cmd_resp_addr;
+	struct hwrm_cfa_flow_stats_input req = { 0 };
+	int rc;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_CFA_FLOW_STATS, -1, -1);
+	req.num_flows = cpu_to_le16(1);
+	req.flow_handle_0 = flow_handle;
+
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (!rc) {
+		stats->packets = le64_to_cpu(resp->packet_0);
+		stats->bytes = le64_to_cpu(resp->byte_0);
+		bnxt_flow_stats_calc(&bp->tc_info, flow, stats);
+	} else {
+		netdev_info(bp->dev, "error rc=%d", rc);
+	}
+
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return rc;
+}
+
 static int bnxt_tc_put_l2_node(struct bnxt *bp,
 			       struct bnxt_tc_flow_node *flow_node)
 {
@@ -647,6 +722,26 @@ static int bnxt_tc_del_flow(struct bnxt *bp,
 static int bnxt_tc_get_flow_stats(struct bnxt *bp,
 				  struct tc_cls_flower_offload *tc_flow_cmd)
 {
+	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_flow_node *flow_node;
+	struct bnxt_tc_flow_stats stats;
+	int rc;
+
+	flow_node = rhashtable_lookup_fast(&tc_info->flow_table,
+					   &tc_flow_cmd->cookie,
+					   tc_info->flow_ht_params);
+	if (!flow_node) {
+		netdev_info(bp->dev, "Error: no flow_node for cookie %lx",
+			    tc_flow_cmd->cookie);
+		return -1;
+	}
+
+	rc = bnxt_hwrm_cfa_flow_stats_get(bp, flow_node->flow_handle,
+					  &flow_node->flow, &stats);
+	if (rc)
+		return rc;
+
+	tcf_exts_stats_update(tc_flow_cmd->exts, stats.bytes, stats.packets, 0);
 	return 0;
 }
 
-- 
1.8.3.1
