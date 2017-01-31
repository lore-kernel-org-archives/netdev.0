From: Andy Zhou <azhou@ovn.org>
Subject: [userspace meter v3 4/5] ofproto: Meter translation.
Date: Mon, 30 Jan 2017 22:39:59 -0800
Message-ID: <1485844800-2873-5-git-send-email-azhou@ovn.org>
References: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Jarno Rajahalme <jarno@ovn.org>,
        Andy Zhou <azhou@ovn.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35396 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750808AbdAaHBo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 02:01:44 -0500
Received: by mail-pf0-f193.google.com with SMTP id f144so26355975pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 23:01:39 -0800 (PST)
In-Reply-To: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>

Translate OpenFlow METER instructions to datapath meter actions.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 include/openvswitch/ofp-actions.h |  1 +
 lib/dpif.c                        | 40 +++++++++++++++++++++++++-------
 lib/ofp-actions.c                 |  1 +
 ofproto/ofproto-dpif-xlate.c      | 11 ++++++++-
 ofproto/ofproto.c                 | 49 ++++++++++++++++++++++-----------------
 5 files changed, 72 insertions(+), 30 deletions(-)

diff --git a/include/openvswitch/ofp-actions.h b/include/openvswitch/ofp-actions.h
index 8ca787a..e269901 100644
--- a/include/openvswitch/ofp-actions.h
+++ b/include/openvswitch/ofp-actions.h
@@ -532,6 +532,7 @@ struct ofpact_metadata {
 struct ofpact_meter {
     struct ofpact ofpact;
     uint32_t meter_id;
+    uint32_t provider_meter_id;
 };
 
 /* OFPACT_WRITE_ACTIONS, OFPACT_CLONE.
diff --git a/lib/dpif.c b/lib/dpif.c
index 4e9476c..cc49d94 100644
--- a/lib/dpif.c
+++ b/lib/dpif.c
@@ -1104,6 +1104,7 @@ struct dpif_execute_helper_aux {
     struct dpif *dpif;
     const struct flow *flow;
     int error;
+    const struct nlattr *meter_action; /* Non-NULL, if have a meter action. */
 };
 
 /* This is called for actions that need the context of the datapath to be
@@ -1119,6 +1120,13 @@ dpif_execute_helper_cb(void *aux_, struct dp_packet_batch *packets_,
     ovs_assert(packets_->count == 1);
 
     switch ((enum ovs_action_attr)type) {
+    case OVS_ACTION_ATTR_METER:
+        /* Maintain a pointer to the first meter action seen. */
+        if (!aux->meter_action) {
+            aux->meter_action = action;
+        }
+	break;
+
     case OVS_ACTION_ATTR_CT:
     case OVS_ACTION_ATTR_OUTPUT:
     case OVS_ACTION_ATTR_TUNNEL_PUSH:
@@ -1129,15 +1137,29 @@ dpif_execute_helper_cb(void *aux_, struct dp_packet_batch *packets_,
         struct ofpbuf execute_actions;
         uint64_t stub[256 / 8];
         struct pkt_metadata *md = &packet->md;
-        bool dst_set;
 
-        dst_set = flow_tnl_dst_is_set(&md->tunnel);
-        if (dst_set) {
+        if (flow_tnl_dst_is_set(&md->tunnel) || aux->meter_action) {
+            ofpbuf_use_stub(&execute_actions, stub, sizeof stub);
+
+            if (aux->meter_action) {
+                const struct nlattr *a = aux->meter_action;
+
+                do {
+                    ofpbuf_put(&execute_actions, a, NLA_ALIGN(a->nla_len));
+                    /* Find next meter action before 'action', if any. */
+                    do {
+                        a = nl_attr_next(a);
+                    } while (a != action &&
+                             nl_attr_type(a) != OVS_ACTION_ATTR_METER);
+                } while (a != action);
+            }
+
             /* The Linux kernel datapath throws away the tunnel information
              * that we supply as metadata.  We have to use a "set" action to
              * supply it. */
-            ofpbuf_use_stub(&execute_actions, stub, sizeof stub);
-            odp_put_tunnel_action(&md->tunnel, &execute_actions);
+            if (md->tunnel.ip_dst) {
+                odp_put_tunnel_action(&md->tunnel, &execute_actions);
+            }
             ofpbuf_put(&execute_actions, action, NLA_ALIGN(action->nla_len));
 
             execute.actions = execute_actions.data;
@@ -1170,14 +1192,16 @@ dpif_execute_helper_cb(void *aux_, struct dp_packet_batch *packets_,
 
         dp_packet_delete(clone);
 
-        if (dst_set) {
+        if (flow_tnl_dst_is_set(&md->tunnel) || aux->meter_action) {
             ofpbuf_uninit(&execute_actions);
+
+            /* Do not re-use the same meters for later output actions. */
+            aux->meter_action = NULL;
         }
         break;
     }
 
     case OVS_ACTION_ATTR_HASH:
-    case OVS_ACTION_ATTR_METER:
     case OVS_ACTION_ATTR_PUSH_VLAN:
     case OVS_ACTION_ATTR_POP_VLAN:
     case OVS_ACTION_ATTR_PUSH_MPLS:
@@ -1201,7 +1225,7 @@ dpif_execute_helper_cb(void *aux_, struct dp_packet_batch *packets_,
 static int
 dpif_execute_with_help(struct dpif *dpif, struct dpif_execute *execute)
 {
-    struct dpif_execute_helper_aux aux = {dpif, execute->flow, 0};
+    struct dpif_execute_helper_aux aux = {dpif, execute->flow, 0, NULL};
     struct dp_packet_batch pb;
 
     COVERAGE_INC(dpif_execute_with_help);
diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
index cf1ad0f..733b2c5 100644
--- a/lib/ofp-actions.c
+++ b/lib/ofp-actions.c
@@ -6868,6 +6868,7 @@ ofpacts_pull_openflow_instructions(struct ofpbuf *openflow,
 
         om = ofpact_put_METER(ofpacts);
         om->meter_id = ntohl(oim->meter_id);
+        om->provider_meter_id = UINT32_MAX; /* No provider meter ID. */
     }
     if (insts[OVSINST_OFPIT11_APPLY_ACTIONS]) {
         const struct ofp_action_header *actions;
diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
index 48b27a6..166e236 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -4579,6 +4579,15 @@ xlate_clone(struct xlate_ctx *ctx, const struct ofpact_nest *oc)
     ctx->was_mpls = old_was_mpls;
 }
 
+static void
+xlate_meter_action(struct xlate_ctx *ctx, const struct ofpact_meter *meter)
+{
+    if (meter->provider_meter_id != UINT32_MAX) {
+        nl_msg_put_u32(ctx->odp_actions, OVS_ACTION_ATTR_METER,
+                       meter->provider_meter_id);
+    }
+}
+
 static bool
 may_receive(const struct xport *xport, struct xlate_ctx *ctx)
 {
@@ -5388,7 +5397,7 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
             break;
 
         case OFPACT_METER:
-            /* Not implemented yet. */
+            xlate_meter_action(ctx, ofpact_get_METER(a));
             break;
 
         case OFPACT_GOTO_TABLE: {
diff --git a/ofproto/ofproto.c b/ofproto/ofproto.c
index 49652d7..f5fa897 100644
--- a/ofproto/ofproto.c
+++ b/ofproto/ofproto.c
@@ -2989,8 +2989,8 @@ remove_groups_rcu(struct ofgroup **groups)
     free(groups);
 }
 
-static uint32_t get_provider_meter_id(const struct ofproto *,
-                                      uint32_t of_meter_id);
+static bool ofproto_fix_meter_action(const struct ofproto *,
+                                     struct ofpact_meter *);
 
 /* Creates and returns a new 'struct rule_actions', whose actions are a copy
  * of from the 'ofpacts_len' bytes of 'ofpacts'. */
@@ -3383,6 +3383,7 @@ reject_slave_controller(struct ofconn *ofconn)
  * for 'ofproto':
  *
  *    - If they use a meter, then 'ofproto' has that meter configured.
+ *      Updates the meter action with ofproto's datapath's provider_meter_id.
  *
  *    - If they use any groups, then 'ofproto' has that group configured.
  *
@@ -3392,18 +3393,17 @@ reject_slave_controller(struct ofconn *ofconn)
 enum ofperr
 ofproto_check_ofpacts(struct ofproto *ofproto,
                       const struct ofpact ofpacts[], size_t ofpacts_len)
-    OVS_REQUIRES(ofproto_mutex)
 {
-    uint32_t mid;
+    const struct ofpact *a;
 
-    mid = ofpacts_get_meter(ofpacts, ofpacts_len);
-    if (mid && get_provider_meter_id(ofproto, mid) == UINT32_MAX) {
-        return OFPERR_OFPMMFC_INVALID_METER;
-    }
+    OFPACT_FOR_EACH (a, ofpacts, ofpacts_len) {
+        if (a->type == OFPACT_METER &&
+            !ofproto_fix_meter_action(ofproto, ofpact_get_METER(a))) {
+            return OFPERR_OFPMMFC_INVALID_METER;
+        }
 
-    const struct ofpact_group *a;
-    OFPACT_FOR_EACH_TYPE_FLATTENED (a, GROUP, ofpacts, ofpacts_len) {
-        if (!ofproto_group_exists(ofproto, a->group_id)) {
+        if (a->type == OFPACT_GROUP
+            && !ofproto_group_exists(ofproto, ofpact_get_GROUP(a)->group_id)) {
             return OFPERR_OFPBAC_BAD_OUT_GROUP;
         }
     }
@@ -6133,20 +6133,27 @@ struct meter {
 };
 
 /*
- * This is used in instruction validation at flow set-up time,
- * as flows may not use non-existing meters.
- * Return value of UINT32_MAX signifies an invalid meter.
+ * This is used in instruction validation at flow set-up time, to map
+ * the OpenFlow meter ID to the corresponding datapath provider meter
+ * ID.  If either does not exist, returns false.  Otherwise updates
+ * the meter action and returns true.
  */
-static uint32_t
-get_provider_meter_id(const struct ofproto *ofproto, uint32_t of_meter_id)
+static bool
+ofproto_fix_meter_action(const struct ofproto *ofproto,
+                         struct ofpact_meter *ma)
 {
-    if (of_meter_id && of_meter_id <= ofproto->meter_features.max_meters) {
-        const struct meter *meter = ofproto->meters[of_meter_id];
-        if (meter) {
-            return meter->provider_meter_id.uint32;
+    if (ma->meter_id && ma->meter_id <= ofproto->meter_features.max_meters) {
+        const struct meter *meter = ofproto->meters[ma->meter_id];
+
+        if (meter && meter->provider_meter_id.uint32 != UINT32_MAX) {
+            /* Update the action with the provider's meter ID, so that we
+             * do not need any synchronization between ofproto_dpif_xlate
+             * and ofproto for meter table access. */
+            ma->provider_meter_id = meter->provider_meter_id.uint32;
+            return true;
         }
     }
-    return UINT32_MAX;
+    return false;
 }
 
 /* Finds the meter invoked by 'rule''s actions and adds 'rule' to the meter's
-- 
1.9.1
