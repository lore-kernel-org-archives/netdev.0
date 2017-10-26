From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 14/14] bnxt_en: alloc tc_info{} struct only when tc flower is enabled
Date: Thu, 26 Oct 2017 11:51:32 -0400
Message-ID: <1509033092-1887-15-git-send-email-michael.chan@broadcom.com>
References: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:45934 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932460AbdJZPwB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 11:52:01 -0400
Received: by mail-qt0-f193.google.com with SMTP id p1so4883883qtg.2
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 08:52:00 -0700 (PDT)
In-Reply-To: <1509033092-1887-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>

TC flower is not enabled on VFs and when there's no FW support.
Alloc the tc_info{} struct at init time only when TC flower is being
enabled.

Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c  | 47 ++++++++++++++++-----------
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h  |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c |  3 ++
 5 files changed, 34 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index bbf6da3..5ce9506 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7347,7 +7347,7 @@ static int bnxt_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
 {
 	struct bnxt *bp = cb_priv;
 
-	if (BNXT_VF(bp))
+	if (!bnxt_tc_flower_enabled(bp))
 		return -EOPNOTSUPP;
 
 	switch (type) {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index b8343ee..5359a1f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1346,7 +1346,7 @@ struct bnxt {
 	enum devlink_eswitch_mode eswitch_mode;
 	struct bnxt_vf_rep	**vf_reps; /* array of vf-rep ptrs */
 	u16			*cfa_code_map; /* cfa_code -> vf_idx map */
-	struct bnxt_tc_info	tc_info;
+	struct bnxt_tc_info	*tc_info;
 };
 
 #define BNXT_RX_STATS_OFFSET(counter)			\
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
index 71828a5..798d139 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
@@ -658,7 +658,7 @@ static int bnxt_tc_put_l2_node(struct bnxt *bp,
 			       struct bnxt_tc_flow_node *flow_node)
 {
 	struct bnxt_tc_l2_node *l2_node = flow_node->l2_node;
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	int rc;
 
 	/* remove flow_node from the L2 shared flow list */
@@ -714,7 +714,7 @@ static int bnxt_tc_put_l2_node(struct bnxt *bp,
 			    struct bnxt_tc_flow_node *flow_node,
 			    __le16 *ref_flow_handle)
 {
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	struct bnxt_tc_flow_node *ref_flow_node;
 	struct bnxt_tc_l2_node *l2_node;
 
@@ -829,7 +829,7 @@ static int bnxt_tc_get_ref_decap_handle(struct bnxt *bp,
 					struct bnxt_tc_flow_node *flow_node,
 					__le32 *ref_decap_handle)
 {
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	struct bnxt_tc_flow_node *ref_flow_node;
 	struct bnxt_tc_l2_node *decap_l2_node;
 
@@ -867,7 +867,7 @@ static void bnxt_tc_put_decap_l2_node(struct bnxt *bp,
 				      struct bnxt_tc_flow_node *flow_node)
 {
 	struct bnxt_tc_l2_node *decap_l2_node = flow_node->decap_l2_node;
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	int rc;
 
 	/* remove flow_node from the decap L2 sharing flow list */
@@ -886,7 +886,7 @@ static void bnxt_tc_put_decap_handle(struct bnxt *bp,
 				     struct bnxt_tc_flow_node *flow_node)
 {
 	__le32 decap_handle = flow_node->decap_node->tunnel_handle;
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	int rc;
 
 	if (flow_node->decap_l2_node)
@@ -973,7 +973,7 @@ static int bnxt_tc_get_decap_handle(struct bnxt *bp, struct bnxt_tc_flow *flow,
 				    __le32 *decap_filter_handle)
 {
 	struct ip_tunnel_key *decap_key = &flow->tun_key;
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	struct bnxt_tc_l2_key l2_info = { {0} };
 	struct bnxt_tc_tunnel_node *decap_node;
 	struct ip_tunnel_key tun_key = { 0 };
@@ -1051,7 +1051,7 @@ static void bnxt_tc_put_encap_handle(struct bnxt *bp,
 				     struct bnxt_tc_tunnel_node *encap_node)
 {
 	__le32 encap_handle = encap_node->tunnel_handle;
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	int rc;
 
 	rc = bnxt_tc_put_tunnel_node(bp, &tc_info->encap_table,
@@ -1070,7 +1070,7 @@ static int bnxt_tc_get_encap_handle(struct bnxt *bp, struct bnxt_tc_flow *flow,
 				    __le32 *encap_handle)
 {
 	struct ip_tunnel_key *encap_key = &flow->actions.tun_encap_key;
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	struct bnxt_tc_tunnel_node *encap_node;
 	int rc;
 
@@ -1137,7 +1137,7 @@ static int bnxt_tc_get_tunnel_handle(struct bnxt *bp,
 static int __bnxt_tc_del_flow(struct bnxt *bp,
 			      struct bnxt_tc_flow_node *flow_node)
 {
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	int rc;
 
 	/* send HWRM cmd to free the flow-id */
@@ -1180,7 +1180,7 @@ static int bnxt_tc_add_flow(struct bnxt *bp, u16 src_fid,
 			    struct tc_cls_flower_offload *tc_flow_cmd)
 {
 	struct bnxt_tc_flow_node *new_node, *old_node;
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	struct bnxt_tc_flow *flow;
 	__le32 tunnel_handle = 0;
 	__le16 ref_flow_handle;
@@ -1261,7 +1261,7 @@ static int bnxt_tc_add_flow(struct bnxt *bp, u16 src_fid,
 static int bnxt_tc_del_flow(struct bnxt *bp,
 			    struct tc_cls_flower_offload *tc_flow_cmd)
 {
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	struct bnxt_tc_flow_node *flow_node;
 
 	flow_node = rhashtable_lookup_fast(&tc_info->flow_table,
@@ -1280,7 +1280,7 @@ static int bnxt_tc_get_flow_stats(struct bnxt *bp,
 				  struct tc_cls_flower_offload *tc_flow_cmd)
 {
 	struct bnxt_tc_flow_stats stats, *curr_stats, *prev_stats;
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	struct bnxt_tc_flow_node *flow_node;
 	struct bnxt_tc_flow *flow;
 	unsigned long lastused;
@@ -1378,7 +1378,7 @@ static void bnxt_flow_stats_accum(struct bnxt_tc_info *tc_info,
 bnxt_tc_flow_stats_batch_update(struct bnxt *bp, int num_flows,
 				struct bnxt_tc_stats_batch stats_batch[])
 {
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	int rc, i;
 
 	rc = bnxt_hwrm_cfa_flow_stats_get(bp, num_flows, stats_batch);
@@ -1405,7 +1405,7 @@ static void bnxt_flow_stats_accum(struct bnxt_tc_info *tc_info,
 			      struct bnxt_tc_stats_batch stats_batch[],
 			      int *num_flows)
 {
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	struct rhashtable_iter *iter = &tc_info->iter;
 	void *flow_node;
 	int rc, i;
@@ -1443,7 +1443,7 @@ static void bnxt_flow_stats_accum(struct bnxt_tc_info *tc_info,
 
 void bnxt_tc_flow_stats_work(struct bnxt *bp)
 {
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 	int num_flows, rc;
 
 	num_flows = atomic_read(&tc_info->flow_table.nelems);
@@ -1528,7 +1528,7 @@ int bnxt_tc_setup_flower(struct bnxt *bp, u16 src_fid,
 
 int bnxt_init_tc(struct bnxt *bp)
 {
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info;
 	int rc;
 
 	if (bp->hwrm_spec_code < 0x10803) {
@@ -1536,6 +1536,10 @@ int bnxt_init_tc(struct bnxt *bp)
 			    "Firmware does not support TC flower offload.\n");
 		return -ENOTSUPP;
 	}
+
+	tc_info = kzalloc(sizeof(*tc_info), GFP_KERNEL);
+	if (!tc_info)
+		return -ENOMEM;
 	mutex_init(&tc_info->lock);
 
 	/* Counter widths are programmed by FW */
@@ -1545,7 +1549,7 @@ int bnxt_init_tc(struct bnxt *bp)
 	tc_info->flow_ht_params = bnxt_tc_flow_ht_params;
 	rc = rhashtable_init(&tc_info->flow_table, &tc_info->flow_ht_params);
 	if (rc)
-		return rc;
+		goto free_tc_info;
 
 	tc_info->l2_ht_params = bnxt_tc_l2_ht_params;
 	rc = rhashtable_init(&tc_info->l2_table, &tc_info->l2_ht_params);
@@ -1573,6 +1577,7 @@ int bnxt_init_tc(struct bnxt *bp)
 	tc_info->enabled = true;
 	bp->dev->hw_features |= NETIF_F_HW_TC;
 	bp->dev->features |= NETIF_F_HW_TC;
+	bp->tc_info = tc_info;
 	return 0;
 
 destroy_decap_table:
@@ -1583,14 +1588,16 @@ int bnxt_init_tc(struct bnxt *bp)
 	rhashtable_destroy(&tc_info->l2_table);
 destroy_flow_table:
 	rhashtable_destroy(&tc_info->flow_table);
+free_tc_info:
+	kfree(tc_info);
 	return rc;
 }
 
 void bnxt_shutdown_tc(struct bnxt *bp)
 {
-	struct bnxt_tc_info *tc_info = &bp->tc_info;
+	struct bnxt_tc_info *tc_info = bp->tc_info;
 
-	if (!tc_info->enabled)
+	if (!bnxt_tc_flower_enabled(bp))
 		return;
 
 	rhashtable_destroy(&tc_info->flow_table);
@@ -1598,4 +1605,6 @@ void bnxt_shutdown_tc(struct bnxt *bp)
 	rhashtable_destroy(&tc_info->decap_l2_table);
 	rhashtable_destroy(&tc_info->decap_table);
 	rhashtable_destroy(&tc_info->encap_table);
+	kfree(tc_info);
+	bp->tc_info = NULL;
 }
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h
index 404f98d..97e09a8 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.h
@@ -198,7 +198,7 @@ int bnxt_tc_setup_flower(struct bnxt *bp, u16 src_fid,
 
 static inline bool bnxt_tc_flower_enabled(struct bnxt *bp)
 {
-	return bp->tc_info.enabled;
+	return bp->tc_info && bp->tc_info->enabled;
 }
 
 #else /* CONFIG_BNXT_FLOWER_OFFLOAD */
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index 4ae9359..c1761ed 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -124,6 +124,9 @@ static int bnxt_vf_rep_setup_tc_block_cb(enum tc_setup_type type,
 	struct bnxt *bp = vf_rep->bp;
 	int vf_fid = bp->pf.vf[vf_rep->vf_idx].fw_fid;
 
+	if (!bnxt_tc_flower_enabled(vf_rep->bp))
+		return -EOPNOTSUPP;
+
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
 		return bnxt_tc_setup_flower(bp, vf_fid, type_data);
-- 
1.8.3.1
