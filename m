From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC repost 7/8] ofproto: translate datapath select group action
Date: Thu, 18 Sep 2014 10:55:10 +0900
Message-ID: <1411005311-11752-8-git-send-email-simon.horman@netronome.com>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Cc: Pravin Shelar <pshelar@nicira.com>, Jesse Gross <jesse@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:54676 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757052AbaIRB55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 21:57:57 -0400
Received: by mail-pa0-f43.google.com with SMTP id fa1so354824pad.2
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 18:57:57 -0700 (PDT)
In-Reply-To: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This add support for the select group action to ovs-vswtichd.

This new feature is currently disabled in xlate_select_group()
because ctx->xbridge->dp_select_group is always false.

This patch is a prototype and has several limitations:

* It assumes that no actions follow a select group action
  because the resulting packet after a select group action may
  differ depending on the bucket used. It may be possible
  to address this problem using recirculation. Or to not use
  the datapath select group in such situations. In any case
  this patch does not solve this problem or even prevent it
  from occurring.

* If recirculation occurs inside more than one bucket then
  it seems that separate recirculation ids would be required
  for each occurrence. This patch does not solve this problem or even
  prevent it from occurring.

* No attempt is made to handle per-bucket statistics.
  This would most likely require further datapath modifications.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 ofproto/ofproto-dpif-xlate.c | 108 ++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 107 insertions(+), 1 deletion(-)

diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
index 6e33a27..b08a821 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -103,6 +103,9 @@ struct xbridge {
      * False if the datapath supports only 8-byte (or shorter) userdata. */
     bool variable_length_userdata;
 
+    /* True if datapath supports select group action */
+    bool dp_select_group;
+
     /* Number of MPLS label stack entries that the datapath supports
      * in matches. */
     size_t max_mpls_depth;
@@ -329,6 +332,9 @@ static void xlate_report(struct xlate_ctx *, const char *);
 static void xlate_table_action(struct xlate_ctx *, ofp_port_t in_port,
                                uint8_t table_id, bool may_packet_in,
                                bool honor_table_miss);
+static void xlate_group_stats(struct xlate_ctx *, struct group_dpif *,
+                              struct ofputil_bucket *);
+static void xlate_group_bucket(struct xlate_ctx *, struct ofputil_bucket *);
 static bool input_vid_is_valid(uint16_t vid, struct xbundle *, bool warn);
 static uint16_t input_vid_to_vlan(const struct xbundle *, uint16_t vid);
 static void output_normal(struct xlate_ctx *, const struct xbundle *,
@@ -2353,6 +2359,61 @@ fix_sflow_action(struct xlate_ctx *ctx)
                          ctx->sflow_odp_port, ctx->sflow_n_outputs, cookie);
 }
 
+/* Compose bucket for SELECT_GROUP action. */
+static void
+compose_bucket_action(struct xlate_ctx *ctx, struct group_dpif *group,
+                      struct ofputil_bucket *bucket)
+{
+    size_t bucket_offset, actions_offset;
+    struct ofpbuf *odp_actions = ctx->xout->odp_actions;
+
+    bucket_offset = nl_msg_start_nested(odp_actions,
+                                        OVS_SELECT_GROUP_ATTR_BUCKET);
+
+    nl_msg_put_u16(odp_actions, OVS_BUCKET_ATTR_WEIGHT, bucket->weight);
+
+    actions_offset = nl_msg_start_nested(odp_actions, OVS_BUCKET_ATTR_ACTIONS);
+
+    xlate_group_bucket(ctx, bucket);
+    xlate_group_stats(ctx, group, bucket);
+
+    nl_msg_end_nested(odp_actions, actions_offset);
+    nl_msg_end_nested(odp_actions, bucket_offset);
+
+    ctx->xout->slow |= commit_odp_actions(&ctx->xin->flow, &ctx->base_flow,
+                                          odp_actions, &ctx->xout->wc);
+}
+
+/* Compose SELECT_GROUP action.
+ * May be called multiple times to add multiple buckets.
+ * The first call should pass SIZE_MAX as the value for offset_
+ * and subsequent calls should pass returned by the previous call.
+ * The last call should pass NULL as the bucket parameter
+ * and previous calls should pass a valid bucket to add to the
+ * select group. */
+static size_t
+compose_select_group_action(struct xlate_ctx *ctx, struct group_dpif *group,
+                            struct ofputil_bucket *bucket,
+                            const size_t offset_)
+{
+    size_t offset = offset_;
+
+    if (bucket != NULL) {
+        if (offset == SIZE_MAX) {
+            offset = nl_msg_start_nested(ctx->xout->odp_actions,
+                                         OVS_ACTION_ATTR_SELECT_GROUP);
+        }
+
+        compose_bucket_action(ctx, group, bucket);
+    } else {
+        if (offset != SIZE_MAX) {
+            nl_msg_end_nested(ctx->xout->odp_actions, offset);
+        }
+    }
+
+    return offset;
+}
+
 static enum slow_path_reason
 process_special(struct xlate_ctx *ctx, const struct flow *flow,
                 const struct xport *xport, const struct ofpbuf *packet)
@@ -2775,7 +2836,40 @@ xlate_ff_group(struct xlate_ctx *ctx, struct group_dpif *group)
 }
 
 static void
-xlate_select_group(struct xlate_ctx *ctx, struct group_dpif *group)
+xlate_select_group_datapath(struct xlate_ctx *ctx, struct group_dpif *group)
+{
+    struct flow_wildcards *wc = &ctx->xout->wc;
+    struct ofputil_bucket *bucket;
+    const struct list *buckets;
+    struct flow old_flow = ctx->xin->flow;
+    size_t offset = SIZE_MAX;
+
+    group_dpif_get_buckets(group, &buckets);
+    LIST_FOR_EACH (bucket, list_node, buckets) {
+        if (bucket_is_alive(ctx, bucket, 0)) {
+            offset = compose_select_group_action(ctx, group, bucket, offset);
+
+            /* Roll back flow to previous state.
+             *
+             * This allows composition of the actions for subsequent
+             * buckets in such a way that they apply to the state of the
+             * packet present before the select group action.
+             *
+             * XXX: Assumes no actions follow the select group action.
+             * Handle with recirculation?
+             */
+            ctx->xin->flow = old_flow;
+        }
+    }
+
+    if (offset != SIZE_MAX) {
+        memset(&wc->masks.dl_dst, 0xff, sizeof wc->masks.dl_dst);
+        compose_select_group_action(ctx, group, NULL, offset);
+    }
+}
+
+static void
+xlate_select_group_userspace(struct xlate_ctx *ctx, struct group_dpif *group)
 {
     struct flow_wildcards *wc = &ctx->xout->wc;
     struct ofputil_bucket *bucket;
@@ -2800,6 +2894,16 @@ xlate_select_group(struct xlate_ctx *ctx, struct group_dpif *group)
 }
 
 static void
+xlate_select_group(struct xlate_ctx *ctx, struct group_dpif *group)
+{
+    if (ctx->xbridge->dp_select_group) {
+        xlate_select_group_datapath(ctx, group);
+    } else {
+        xlate_select_group_userspace(ctx, group);
+    }
+}
+
+static void
 xlate_group_action__(struct xlate_ctx *ctx, struct group_dpif *group)
 {
     ctx->in_group = true;
@@ -2990,6 +3094,8 @@ compose_recirculate_action(struct xlate_ctx *ctx,
     ofpacts_len = ofpacts_base_len -
         ((uint8_t *)ofpact_current - (uint8_t *)ofpacts_base);
 
+    /* XXX: If recirculation occurs inside buckets of a select group action
+     * then multiple recirculation ids may be required. */
     if (ctx->rule) {
         id = rule_dpif_get_recirc_id(ctx->rule);
     } else {
-- 
2.0.1
