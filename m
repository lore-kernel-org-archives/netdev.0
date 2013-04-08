From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 3/4] Allow recirculation without facets
Date: Mon,  8 Apr 2013 15:43:50 +0900
Message-ID: <1365403431-18102-4-git-send-email-horms@verge.net.au>
References: <1365403431-18102-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55735 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762678Ab3DHGn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 02:43:56 -0400
In-Reply-To: <1365403431-18102-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This covers the following cases:

* Handle flow miss without facet
  - Previously the use of facets was forced if there was
    any chance of a recirculation action. That is, for
    all flows misses of MPLS packets.
* Packet Out

Signed-off-by: Simon Horman <horms@verge.net.au>

---

This patch depends on the patch "Move execute_set_action to lib/odp-util.c"

v5
* Use RECIRCULATION_ID_DUMMY

rfc4
* Initial post
---
 ofproto/ofproto-dpif.c |  132 ++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 111 insertions(+), 21 deletions(-)

diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index 5129da1..67121f2 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -3571,6 +3571,64 @@ flow_miss_find(struct hmap *todo, const struct ofproto_dpif *ofproto,
     return NULL;
 }
 
+static void
+execute_actions_for_recircualtion(struct ofpbuf *packet,
+                                  const struct nlattr *actions,
+                                  size_t actions_len, uint32_t *skb_mark)
+{
+    const struct nlattr *a;
+    unsigned int left;
+
+    NL_ATTR_FOR_EACH_UNSAFE (a, left, actions, actions_len) {
+        int type = nl_attr_type(a);
+
+        switch ((enum ovs_action_attr) type) {
+
+        case OVS_ACTION_ATTR_PUSH_VLAN: {
+            const struct ovs_action_push_vlan *vlan = nl_attr_get(a);
+            eth_push_vlan(packet, vlan->vlan_tci);
+            break;
+        }
+
+        case OVS_ACTION_ATTR_POP_VLAN:
+            eth_pop_vlan(packet);
+            break;
+
+        case OVS_ACTION_ATTR_PUSH_MPLS: {
+            const struct ovs_action_push_mpls *mpls = nl_attr_get(a);
+            push_mpls(packet, mpls->mpls_ethertype, mpls->mpls_lse);
+            break;
+         }
+
+        case OVS_ACTION_ATTR_POP_MPLS:
+            pop_mpls(packet, nl_attr_get_be16(a));
+            break;
+
+        case OVS_ACTION_ATTR_SET:
+            execute_set_action(packet, nl_attr_get(a), skb_mark);
+            break;
+
+        case OVS_ACTION_ATTR_RECIRCULATE:
+            if (packet->l2) {
+                ofpbuf_push_uninit(packet, (char *)packet->l2 -
+                                   (char *)packet->data);
+            }
+            return;
+
+        case OVS_ACTION_ATTR_OUTPUT:
+        case OVS_ACTION_ATTR_USERSPACE:
+        case OVS_ACTION_ATTR_SAMPLE:
+        case OVS_ACTION_ATTR_UNSPEC:
+        case __OVS_ACTION_ATTR_MAX:
+            NOT_REACHED();
+        }
+    }
+
+    /* There should always be a OVS_ACTION_ATTR_RECIRCULATE present
+     * in actions if this function is called */
+    NOT_REACHED();
+}
+
 /* Partially Initializes 'op' as an "execute" operation for 'miss' and
  * 'packet'.  The caller must initialize op->actions and op->actions_len.  If
  * 'miss' is associated with a subfacet the caller must also initialize the
@@ -3632,15 +3690,6 @@ static bool
 flow_miss_should_make_facet(struct ofproto_dpif *ofproto,
                             struct flow_miss *miss, uint32_t hash)
 {
-    /* A facet is currently required to handle recirculation.
-     * There currently isn't a good way to detect if recirculation will
-     * occur or not. So in the mean time assume that it can't occur
-     * for non-MPLS packets and it may occur for MPLS packets
-     */
-    if (eth_type_mpls(miss->flow.dl_type)) {
-        return true;
-    }
-
     if (!ofproto->governor) {
         size_t n_subfacets;
 
@@ -3656,6 +3705,50 @@ flow_miss_should_make_facet(struct ofproto_dpif *ofproto,
                                         list_size(&miss->packets));
 }
 
+static const struct flow *
+xlate_with_recirculate(struct ofproto_dpif *ofproto, struct rule_dpif *rule,
+                       const struct flow *flow, struct flow *flow_storage,
+                       const struct initial_vals *initial_vals,
+                       const struct ofpact *ofpacts, size_t ofpacts_len,
+                       struct ofpbuf *odp_actions,
+                       struct dpif_flow_stats *stats, struct ofpbuf *packet)
+{
+    struct initial_vals initial_vals_ = *initial_vals;
+
+    while (1) {
+        struct action_xlate_ctx ctx;
+        uint32_t skb_mark = flow->skb_mark;
+
+        ofpbuf_clear(odp_actions);
+        action_xlate_ctx_init(&ctx, ofproto, flow, &initial_vals_,
+                              rule, stats->tcp_flags, packet,
+                              RECIRCULATION_ID_DUMMY);
+        ctx.resubmit_stats = stats;
+        xlate_actions(&ctx, ofpacts, ofpacts_len, odp_actions);
+
+        if (!ctx.recircualted) {
+            break;
+        }
+
+        /* Update the packet */
+        execute_actions_for_recircualtion(packet, odp_actions->data,
+                                          odp_actions->size, &skb_mark);
+        ofpbuf_clear(odp_actions);
+
+        /* Replace the flow */
+        flow_extract(packet, flow->skb_priority, skb_mark,
+                     NULL, flow->in_port, flow_storage);
+        flow = flow_storage;
+        initial_vals_.vlan_tci = flow->vlan_tci;
+        initial_vals_.tunnel_ip_tos = flow->tunnel.ip_tos;
+
+        ofpacts = ofpact_end(ofpacts, ctx.ofpacts_len);
+        ofpacts_len -= ctx.ofpacts_len;
+    }
+
+    return flow;
+}
+
 /* Handles 'miss', which matches 'rule', without creating a facet or subfacet
  * or creating any datapath flow.  May add an "execute" operation to 'ops' and
  * increment '*n_ops'. */
@@ -3666,8 +3759,8 @@ handle_flow_miss_without_facet(struct flow_miss *miss, struct rule_dpif *rule,
 {
     struct ofproto_dpif *ofproto = ofproto_dpif_cast(rule->up.ofproto);
     long long int now = time_msec();
-    struct action_xlate_ctx ctx;
     struct ofpbuf *packet;
+    struct flow flow_storage;
 
     LIST_FOR_EACH (packet, list_node, &miss->packets) {
         struct flow_miss_op *op = &ops[*n_ops];
@@ -3681,11 +3774,9 @@ handle_flow_miss_without_facet(struct flow_miss *miss, struct rule_dpif *rule,
         dpif_flow_stats_extract(&miss->flow, packet, now, &stats);
         rule_credit_stats(rule, &stats);
 
-        action_xlate_ctx_init(&ctx, ofproto, &miss->flow,
-                              &miss->initial_vals, rule, 0, packet,
-                              RECIRCULATION_ID_DUMMY);
-        ctx.resubmit_stats = &stats;
-        xlate_actions(&ctx, ofpacts, ofpacts_len, &odp_actions);
+        xlate_with_recirculate(ofproto, rule, &miss->flow, &flow_storage,
+                               &miss->initial_vals, ofpacts, ofpacts_len,
+                               &odp_actions, &stats, packet);
 
         if (odp_actions.size) {
             struct dpif_execute *execute = &op->dpif_op.u.execute;
@@ -7937,10 +8028,10 @@ packet_out(struct ofproto *ofproto_, struct ofpbuf *packet,
     struct initial_vals initial_vals;
     struct odputil_keybuf keybuf;
     struct dpif_flow_stats stats;
+    struct flow flow_storage;
 
     struct ofpbuf key;
 
-    struct action_xlate_ctx ctx;
     uint64_t odp_actions_stub[1024 / 8];
     struct ofpbuf odp_actions;
 
@@ -7952,14 +8043,13 @@ packet_out(struct ofproto *ofproto_, struct ofpbuf *packet,
 
     initial_vals.vlan_tci = flow->vlan_tci;
     initial_vals.tunnel_ip_tos = 0;
-    action_xlate_ctx_init(&ctx, ofproto, flow, &initial_vals, NULL,
-                          packet_get_tcp_flags(packet, flow), packet,
-                          RECIRCULATION_ID_DUMMY);
-    ctx.resubmit_stats = &stats;
 
     ofpbuf_use_stub(&odp_actions,
                     odp_actions_stub, sizeof odp_actions_stub);
-    xlate_actions(&ctx, ofpacts, ofpacts_len, &odp_actions);
+    flow = xlate_with_recirculate(ofproto, NULL, flow, &flow_storage,
+                                  &initial_vals, ofpacts, ofpacts_len,
+                                  &odp_actions, &stats, packet);
+
     dpif_execute(ofproto->backer->dpif, key.data, key.size,
                  odp_actions.data, odp_actions.size, packet);
     ofpbuf_uninit(&odp_actions);
-- 
1.7.10.4
