From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2.51 2/5] odp: Allow VLAN actions after MPLS
	actions
Date: Thu, 21 Nov 2013 12:46:43 +0900
Message-ID: <1385005606-30130-3-git-send-email-horms@verge.net.au>
References: <1385005606-30130-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1385005606-30130-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>

OpenFlow 1.1 and 1.2, and 1.3 differ in their handling of MPLS actions in the
presence of VLAN tags. To allow correct behaviour to be committed in
each situation, this patch adds a second round of VLAN tag action
handling to commit_odp_actions(), which occurs after MPLS actions. This
is implemented with two new fields in struct xlate_ctx,
'post_mpls_vlan_tci' and 'next_vlan_tci'.

Any modifications to the VLAN TCI by actions are made to 'next_vlan_tci'.
Initially 'next_vlan_tci' points to 'xin->flow->vlan_tci' so that VLAN
actions are committed before any MPLS actions.  When an MPLS action is
composed 'next_vlan_tci' is updated to point to 'post_mpls_vlan_tci'. This
causes subsequent VLAN actions to be committed after MPLS actions.

Both before and after this patch MPLS LSEs are pushed onto a packet after
any VLAN tags that may be present. This is the behaviour described in
OpenFlow 1.1 and 1.2. OpenFlow 1.3 specifies that MPLS LSEs should be
pushed onto a packet before any VLAN tags that are present. Support
for this will be added by a subsequent patch that makes use of
the infrastructure added by this patch.

Signed-off-by: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

v2.51 [Simon Horman]
* Use OF1.2 for all ovs-ofctl commands. This is a cosmetic change.

v2.49 - v2.50
* No change

v2.48 [Simon Horman]
* Manual rebase for
  - "OF 1.1 set vlan vid/pcp compatibility"
  - "Native Set-Field action"
* Only use OpenFlow1.2 actions in OpenFlow1.2 tests

v2.47
* No change

v2.46 [Simon Horman]
* Updated changelog as it had become out of date

v2.45 [Simon Horman]
* As pointed out by Ben Pfaff and Joe Stringer
  + Update VLAN handling in the presence of MPLS push

    Previously the test for committing ODP VLAN actions after MPLS actions
    was that the VLAN TCI differed before and after the MPLS push action.
    This results in a false negative in some cases including if a VLAN tag
    is pushed after the MPLS push action in such a way that it duplicates
    the VLAN tag present before the MPLS push action.

    This is resolved by ensuring the VLAN_CFI bit of the value used to
    track the desired VLAN TCI after an MPLS push action is zero unless
    VLAN actions should be committed after MPLS actions.

  + Update tests to use ovs-ofctl monitor "-m" to allow full inspection of
    MPLS LSE and VLAN tags present in packets.

v2.44 [Simon Horman]
* Rebase for the following changes:
  f47ea02 ("Set datapath mask bits when setting a flow field.")
  7fdb60a ("Add support for write-actions")
  7358063 ("odp-util: Elaborate the comment for odp_flow_format() function.")
* Correct final_vlan_tci and next_vlan_tci initialisation in xlate_actions__()

v2.43 [Simon Horman]
* As suggested by Ben Pfaff
  Move vlan state into struct xlate_ctx

  1. Add final_vlan_tci member to struct xlate_ctx instead of vlan_tci member
     struct xlate_xin.  This seems to be a better palace for it as it does
     not need to be accessible from the caller.

  2. Move local vlan_tci variable of do_xlate_actions() to be the
     next_vlan_tci member of strict xlate_ctx.  This allows for it to work
     across resubmit actions and goto table instructions.

v2.42
* No change

v2.41 [Joe Stringer via Simon Horman]
* Rework comments to make things a little clearer

v2.40 [Simon Horman]
* Rebase for removal of mpls_depth from struct flow

v2.38 - v2.39
* No change

v2.37
* Rebase

v2.36
* No change

v2.35 [Joe Stringer]
* First post
---
 lib/odp-util.c               |  12 +-
 lib/odp-util.h               |   3 +-
 ofproto/ofproto-dpif-xlate.c | 152 +++++++++++++----
 tests/ofproto-dpif.at        | 389 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 525 insertions(+), 31 deletions(-)

diff --git a/lib/odp-util.c b/lib/odp-util.c
index 62cc638..c5c5e08 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -3606,11 +3606,15 @@ commit_set_pkt_mark_action(const struct flow *flow, struct flow *base,
  * used as part of the action.
  *
  * Returns a reason to force processing the flow's packets into the userspace
- * slow path, if there is one, otherwise 0. */
+ * slow path, if there is one, otherwise 0.
+ *
+ * VLAN actions may be committed twice; If vlan_tci in 'flow' differs from the
+ * one in 'base', then it is committed before MPLS actions. If the VLAN_CFI
+ * bit of 'post_mpls_vlan_tci' is set then it is committed afterwards. */
 enum slow_path_reason
 commit_odp_actions(const struct flow *flow, struct flow *base,
                    struct ofpbuf *odp_actions, struct flow_wildcards *wc,
-                   int *mpls_depth_delta)
+                   int *mpls_depth_delta, ovs_be16 post_mpls_vlan_tci)
 {
     enum slow_path_reason slow;
 
@@ -3623,6 +3627,10 @@ commit_odp_actions(const struct flow *flow, struct flow *base,
      * that it is no longer IP and thus nw and port actions are no longer valid.
      */
     commit_mpls_action(flow, base, odp_actions, wc, mpls_depth_delta);
+    if (post_mpls_vlan_tci & htons(VLAN_CFI)) {
+        base->vlan_tci = htons(0);
+        commit_vlan_action(post_mpls_vlan_tci, base, odp_actions, wc);
+    }
     commit_set_priority_action(flow, base, odp_actions, wc);
     commit_set_pkt_mark_action(flow, base, odp_actions, wc);
 
diff --git a/lib/odp-util.h b/lib/odp-util.h
index 821b2c4..636a3ec 100644
--- a/lib/odp-util.h
+++ b/lib/odp-util.h
@@ -175,7 +175,8 @@ enum slow_path_reason commit_odp_actions(const struct flow *,
                                          struct flow *base,
                                          struct ofpbuf *odp_actions,
                                          struct flow_wildcards *wc,
-                                         int *mpls_depth_delta);
+                                         int *mpls_depth_delta,
+                                         ovs_be16 post_mpls_vlan_tci);
 
 /* ofproto-dpif interface.
  *
diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
index a331c0b..daacee6 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -1,4 +1,4 @@
-/* Copyright (c) 2009, 2010, 2011, 2012, 2013 Nicira, Inc.
+            /* Copyright (c) 2009, 2010, 2011, 2012, 2013 Nicira, Inc.
  *
  * Licensed under the Apache License, Version 2.0 (the "License");
  * you may not use this file except in compliance with the License.
@@ -182,6 +182,37 @@ struct xlate_ctx {
     uint16_t user_cookie_offset;/* Used for user_action_cookie fixup. */
     bool exit;                  /* No further actions should be processed. */
 
+    /* The post MPLS vlan_tci.
+     *
+     * The value of the vlan TCI prior to the translation of an MPLS push
+     * actions should be stored in 'xin->flow->vlan_tci'.
+     *
+     * If an VLAN or set field action is subsequently translated then
+     * 'post_mpls_vlan_tci' is updated as according to the action.
+     *
+     * If the VLAN_CFI bit of 'post_mpls_vlan_tci' is set then VLAN ODP actions
+     * will be committed after any MPLS actions regardless of whether VLAN
+     * actions were also committed before the MPLS actions or not.
+     *
+     * This mechanism allows a VLAN tag to be popped before pushing
+     * an MPLS LSE and then the same VLAN tag pushed after pushing
+     * the MPLS LSE. In this way it is possible to push an MPLS LSE
+     * after an existing VLAN tag. Moreover this mechanism allows
+     * the order in which VLAN tags and MPLS LSEs are pushed. */
+    ovs_be16 post_mpls_vlan_tci;
+
+    /* The next vlan_tci state.
+     *
+     * This field pints to the variable update each time an
+     * action updates the VLAN tci.
+     *
+     * This variable initially points to 'xin->flow->vlan_tci' so that ODP
+     * VLAN actions are committed before any MPLS actions. When an MPLS
+     * action is composed 'next_vlan_tci' is updated to point to
+     * 'post_mpls_vlan_tci'. This causes subsequent VLAN actions to be
+     * committed after MPLS actions. */
+    ovs_be16 *next_vlan_tci;
+
     /* OpenFlow 1.1+ action set.
      *
      * 'action_set' accumulates "struct ofpact"s added by OFPACT_WRITE_ACTIONS.
@@ -1100,11 +1131,38 @@ output_vlan_to_vid(const struct xbundle *out_xbundle, uint16_t vlan)
     }
 }
 
+static bool mpls_actions_xlated(struct xlate_ctx *ctx)
+{
+    return ctx->next_vlan_tci == &ctx->post_mpls_vlan_tci;
+}
+
+static ovs_be16
+vlan_tci_save(struct xlate_ctx *ctx)
+{
+    ovs_be16 orig_tci = ctx->xin->flow.vlan_tci;
+    /* If MPLS actions were executed after vlan actions then
+     * copy the final vlan_tci out and restore the intermediate VLAN state. */
+    if (mpls_actions_xlated(ctx)) {
+        ctx->xin->flow.vlan_tci = *ctx->next_vlan_tci;
+    }
+    return orig_tci;
+}
+
+static void
+vlan_tci_restore(struct xlate_ctx *ctx, ovs_be16 orig_tci)
+{
+    /* If MPLS actions were executed after vlan actions then
+     * copy the final vlan_tci out and restore the intermediate VLAN state. */
+    if (mpls_actions_xlated(ctx)) {
+        ctx->post_mpls_vlan_tci = ctx->xin->flow.vlan_tci;
+        ctx->xin->flow.vlan_tci = orig_tci;
+    }
+}
+
 static void
 output_normal(struct xlate_ctx *ctx, const struct xbundle *out_xbundle,
               uint16_t vlan)
 {
-    ovs_be16 *flow_tci = &ctx->xin->flow.vlan_tci;
     uint16_t vid;
     ovs_be16 tci, old_tci;
     struct xport *xport;
@@ -1129,18 +1187,18 @@ output_normal(struct xlate_ctx *ctx, const struct xbundle *out_xbundle,
         }
     }
 
-    old_tci = *flow_tci;
+    old_tci = *ctx->next_vlan_tci;
     tci = htons(vid);
     if (tci || out_xbundle->use_priority_tags) {
-        tci |= *flow_tci & htons(VLAN_PCP_MASK);
+        tci |= *ctx->next_vlan_tci & htons(VLAN_PCP_MASK);
         if (tci) {
             tci |= htons(VLAN_CFI);
         }
     }
-    *flow_tci = tci;
+    ctx->xin->flow.vlan_tci = *ctx->next_vlan_tci = tci;
 
     compose_output_action(ctx, xport->ofp_port);
-    *flow_tci = old_tci;
+    ctx->xin->flow.vlan_tci = *ctx->next_vlan_tci = old_tci;
 }
 
 /* A VM broadcasts a gratuitous ARP to indicate that it has resumed after
@@ -1373,7 +1431,7 @@ xlate_normal(struct xlate_ctx *ctx)
 
     /* Drop malformed frames. */
     if (flow->dl_type == htons(ETH_TYPE_VLAN) &&
-        !(flow->vlan_tci & htons(VLAN_CFI))) {
+        !(*ctx->next_vlan_tci & htons(VLAN_CFI))) {
         if (ctx->xin->packet != NULL) {
             static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 5);
             VLOG_WARN_RL(&rl, "bridge %s: dropping packet with partial "
@@ -1397,7 +1455,7 @@ xlate_normal(struct xlate_ctx *ctx)
     }
 
     /* Check VLAN. */
-    vid = vlan_tci_to_vid(flow->vlan_tci);
+    vid = vlan_tci_to_vid(*ctx->next_vlan_tci);
     if (!input_vid_is_valid(vid, in_xbundle, ctx->xin->packet != NULL)) {
         xlate_report(ctx, "disallowed VLAN VID for this input port, dropping");
         return;
@@ -1655,7 +1713,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
     const struct xport *xport = get_ofp_port(ctx->xbridge, ofp_port);
     struct flow_wildcards *wc = &ctx->xout->wc;
     struct flow *flow = &ctx->xin->flow;
-    ovs_be16 flow_vlan_tci;
+    ovs_be16 flow_vlan_tci, vlan_tci;
     uint32_t flow_pkt_mark;
     uint8_t flow_nw_tos;
     odp_port_t out_port, odp_port;
@@ -1724,6 +1782,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
     }
 
     flow_vlan_tci = flow->vlan_tci;
+    vlan_tci = *ctx->next_vlan_tci;
     flow_pkt_mark = flow->pkt_mark;
     flow_nw_tos = flow->nw_tos;
 
@@ -1763,12 +1822,13 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
             wc->masks.vlan_tci |= htons(VLAN_VID_MASK | VLAN_CFI);
         }
         vlandev_port = vsp_realdev_to_vlandev(ctx->xbridge->ofproto, ofp_port,
-                                              flow->vlan_tci);
+                                              *ctx->next_vlan_tci);
         if (vlandev_port == ofp_port) {
             out_port = odp_port;
         } else {
             out_port = ofp_port_to_odp_port(ctx->xbridge, vlandev_port);
             flow->vlan_tci = htons(0);
+            ctx->post_mpls_vlan_tci = htons(0);
         }
     }
 
@@ -1776,7 +1836,8 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
         ctx->xout->slow |= commit_odp_actions(flow, &ctx->base_flow,
                                               &ctx->xout->odp_actions,
                                               &ctx->xout->wc,
-                                              &ctx->mpls_depth_delta);
+                                              &ctx->mpls_depth_delta,
+                                              ctx->post_mpls_vlan_tci);
         nl_msg_put_odp_port(&ctx->xout->odp_actions, OVS_ACTION_ATTR_OUTPUT,
                             out_port);
 
@@ -1788,6 +1849,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
  out:
     /* Restore flow */
     flow->vlan_tci = flow_vlan_tci;
+    *ctx->next_vlan_tci = vlan_tci;
     flow->pkt_mark = flow_pkt_mark;
     flow->nw_tos = flow_nw_tos;
 }
@@ -2055,7 +2117,8 @@ execute_controller_action(struct xlate_ctx *ctx, int len,
     ctx->xout->slow |= commit_odp_actions(&ctx->xin->flow, &ctx->base_flow,
                                           &ctx->xout->odp_actions,
                                           &ctx->xout->wc,
-                                          &ctx->mpls_depth_delta);
+                                          &ctx->mpls_depth_delta,
+                                          ctx->post_mpls_vlan_tci);
 
     odp_execute_actions(NULL, packet, &key, ctx->xout->odp_actions.data,
                         ctx->xout->odp_actions.size, NULL, NULL);
@@ -2496,7 +2559,8 @@ xlate_sample_action(struct xlate_ctx *ctx,
   ctx->xout->slow |= commit_odp_actions(&ctx->xin->flow, &ctx->base_flow,
                                         &ctx->xout->odp_actions,
                                         &ctx->xout->wc,
-                                        &ctx->mpls_depth_delta);
+                                        &ctx->mpls_depth_delta,
+                                        ctx->post_mpls_vlan_tci);
 
   compose_flow_sample_cookie(os->probability, os->collector_set_id,
                              os->obs_domain_id, os->obs_point_id, &cookie);
@@ -2589,33 +2653,36 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
         case OFPACT_SET_VLAN_VID:
             wc->masks.vlan_tci |= htons(VLAN_VID_MASK | VLAN_CFI);
-            if (flow->vlan_tci & htons(VLAN_CFI) ||
+            if (*ctx->next_vlan_tci & htons(VLAN_CFI) ||
                 ofpact_get_SET_VLAN_VID(a)->push_vlan_if_needed) {
-                flow->vlan_tci &= ~htons(VLAN_VID_MASK);
-                flow->vlan_tci |= (htons(ofpact_get_SET_VLAN_VID(a)->vlan_vid)
-                                   | htons(VLAN_CFI));
+                uint16_t vlan_vid = ofpact_get_SET_VLAN_VID(a)->vlan_vid;
+
+                *ctx->next_vlan_tci &= ~htons(VLAN_VID_MASK);
+                *ctx->next_vlan_tci |= (htons(vlan_vid) | htons(VLAN_CFI));
             }
             break;
 
         case OFPACT_SET_VLAN_PCP:
             wc->masks.vlan_tci |= htons(VLAN_PCP_MASK | VLAN_CFI);
-            if (flow->vlan_tci & htons(VLAN_CFI) ||
+            if (*ctx->next_vlan_tci & htons(VLAN_CFI) ||
                 ofpact_get_SET_VLAN_PCP(a)->push_vlan_if_needed) {
-                flow->vlan_tci &= ~htons(VLAN_PCP_MASK);
-                flow->vlan_tci |= htons((ofpact_get_SET_VLAN_PCP(a)->vlan_pcp
-                                         << VLAN_PCP_SHIFT) | VLAN_CFI);
+                uint16_t vlan_pcp = ofpact_get_SET_VLAN_PCP(a)->vlan_pcp;
+
+                *ctx->next_vlan_tci &= ~htons(VLAN_PCP_MASK);
+                *ctx->next_vlan_tci |= htons((vlan_pcp << VLAN_PCP_SHIFT) |
+                                             VLAN_CFI);
             }
             break;
 
         case OFPACT_STRIP_VLAN:
             memset(&wc->masks.vlan_tci, 0xff, sizeof wc->masks.vlan_tci);
-            flow->vlan_tci = htons(0);
+            *ctx->next_vlan_tci = htons(0);
             break;
 
         case OFPACT_PUSH_VLAN:
             /* XXX 802.1AD(QinQ) */
             memset(&wc->masks.vlan_tci, 0xff, sizeof wc->masks.vlan_tci);
-            flow->vlan_tci = htons(VLAN_CFI);
+            *ctx->next_vlan_tci = htons(VLAN_CFI);
             break;
 
         case OFPACT_SET_ETH_SRC:
@@ -2697,13 +2764,19 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
             flow->skb_priority = ctx->orig_skb_priority;
             break;
 
-        case OFPACT_REG_MOVE:
+        case OFPACT_REG_MOVE: {
+            ovs_be16 orig_tci = flow->vlan_tci;
             nxm_execute_reg_move(ofpact_get_REG_MOVE(a), flow, wc);
+            vlan_tci_restore(ctx, orig_tci);
             break;
+        }
 
-        case OFPACT_REG_LOAD:
+        case OFPACT_REG_LOAD: {
+            ovs_be16 orig_tci = vlan_tci_save(ctx);
             nxm_execute_reg_load(ofpact_get_REG_LOAD(a), flow, wc);
+            vlan_tci_restore(ctx, orig_tci);
             break;
+        }
 
         case OFPACT_SET_FIELD:
             set_field = ofpact_get_SET_FIELD(a);
@@ -2712,28 +2785,49 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
             /* Set field action only ever overwrites packet's outermost
              * applicable header fields.  Do nothing if no header exists. */
-            if ((mf->id != MFF_VLAN_VID || flow->vlan_tci & htons(VLAN_CFI))
+            if ((mf->id != MFF_VLAN_VID ||
+                 *ctx->next_vlan_tci & htons(VLAN_CFI))
                 && ((mf->id != MFF_MPLS_LABEL && mf->id != MFF_MPLS_TC)
                     || flow->mpls_lse)) {
+                ovs_be16 orig_tci = vlan_tci_save(ctx);
                 mf_set_flow_value(mf, &set_field->value, flow);
+                vlan_tci_restore(ctx, orig_tci);
             }
             break;
 
-        case OFPACT_STACK_PUSH:
+        case OFPACT_STACK_PUSH: {
+            ovs_be16 orig_tci = vlan_tci_save(ctx);
             nxm_execute_stack_push(ofpact_get_STACK_PUSH(a), flow, wc,
                                    &ctx->stack);
+            vlan_tci_restore(ctx, orig_tci);
             break;
+        }
 
-        case OFPACT_STACK_POP:
+        case OFPACT_STACK_POP: {
+            ovs_be16 orig_tci = vlan_tci_save(ctx);
             nxm_execute_stack_pop(ofpact_get_STACK_POP(a), flow, wc,
                                   &ctx->stack);
+            vlan_tci_restore(ctx, orig_tci);
             break;
+        }
 
         case OFPACT_PUSH_MPLS:
             if (compose_mpls_push_action(ctx,
                                          ofpact_get_PUSH_MPLS(a)->ethertype)) {
                 return;
             }
+
+            /* Save and pop any existing VLAN tags. They will be pushed
+             * back onto the packet after pushing the MPLS LSE. The overall
+             * effect is to push the MPLS LSE after any VLAN tags that may
+             * be present. This is the behaviour described for OpenFlow 1.1
+             * and 1.2. This code needs to be enhanced to make this
+             * conditional to also and support pushing the MPLS LSE before
+             * any VLAN tags that may be present, the behaviour described
+             * for OpenFlow 1.3. */
+            ctx->post_mpls_vlan_tci = *ctx->next_vlan_tci;
+            flow->vlan_tci = htons(0);
+            ctx->next_vlan_tci = &ctx->post_mpls_vlan_tci;
             break;
 
         case OFPACT_POP_MPLS:
@@ -3087,6 +3181,8 @@ xlate_actions__(struct xlate_in *xin, struct xlate_out *xout)
     ctx.table_id = 0;
     ctx.exit = false;
     ctx.mpls_depth_delta = 0;
+    ctx.post_mpls_vlan_tci = htons(0);
+    ctx.next_vlan_tci = &ctx.xin->flow.vlan_tci;
 
     if (!xin->ofpacts && !ctx.rule) {
         rule_dpif_lookup(ctx.xbridge->ofproto, flow, wc, &rule);
diff --git a/tests/ofproto-dpif.at b/tests/ofproto-dpif.at
index b78e156..9becf05 100644
--- a/tests/ofproto-dpif.at
+++ b/tests/ofproto-dpif.at
@@ -1063,6 +1063,395 @@ done
 OVS_VSWITCHD_STOP
 AT_CLEANUP
 
+AT_SETUP([ofproto-dpif - OF1.2 VLAN+MPLS handling])
+OVS_VSWITCHD_START([dnl
+   add-port br0 p1 -- set Interface p1 type=dummy
+])
+ON_EXIT([kill `cat ovs-ofctl.pid`])
+
+AT_CAPTURE_FILE([ofctl_monitor.log])
+AT_DATA([flows.txt], [dnl
+cookie=0xa dl_src=40:44:44:44:54:50 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],push_vlan:0x8100,set_vlan_vid:99,set_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:54:51 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],push_vlan:0x8100,set_vlan_vid:99,set_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:54:52 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:54:53 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:54:54 actions=push_vlan:0x8100,set_vlan_vid:99,set_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],controller
+cookie=0xa dl_src=40:44:44:44:54:55 actions=push_vlan:0x8100,set_vlan_vid:99,set_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],controller
+cookie=0xa dl_src=40:44:44:44:54:56 actions=push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],controller
+cookie=0xa dl_src=40:44:44:44:54:57 actions=push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],controller
+cookie=0xa dl_src=40:44:44:44:54:58,vlan_tci=0x1000/0x1000 actions=load:99->OXM_OF_VLAN_VID[[]],set_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],controller
+cookie=0xa dl_src=40:44:44:44:54:59,vlan_tci=0x1000/0x1000 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],set_vlan_pcp:1,load:99->OXM_OF_VLAN_VID[[]],controller
+])
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 add-flows br0 flows.txt])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we see
+dnl both of these in the final flow
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:50,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([ovs-appctl -t ovs-ofctl exit])
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.2): total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 50 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 50 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 50 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be stripped
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:51,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 51 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 51 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 51 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we see
+dnl both of these in the final flow
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:52,dst=52:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([ovs-appctl -t ovs-ofctl exit])
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.2): total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:52,dl_dst=52:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  52 54 00 00 00 07 40 44-44 44 54 52 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:52,dl_dst=52:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  52 54 00 00 00 07 40 44-44 44 54 52 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:52,dl_dst=52:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  52 54 00 00 00 07 40 44-44 44 54 52 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be stripped
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:53,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:53,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 53 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:53,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 53 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:53,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 53 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the VLAN tag before pushing a MPLS tag, but these
+dnl actions are reordered, so we see both of these in the final flow.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:54,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.2): total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:54,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 54 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:54,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 54 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:54,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 54 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be stripped
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:55,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:55,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 55 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:55,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 55 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:55,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 55 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the VLAN tag before pushing a MPLS tag, but these
+dnl actions are reordered, so we see both of these in the final flow.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:56,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.2): total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:56,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 56 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:56,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 56 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:56,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 56 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be stripped
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 monitor br0 -m 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:57,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:57,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 57 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:57,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 57 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:57,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 57 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be stripped
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:58,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:58,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 58 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:58,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 58 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:58,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 58 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be modified
+dnl before we push MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:59,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log | ofctl_strip], [0], [dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:59,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 59 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:59,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 59 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+OFPT_PACKET_IN (OF1.2): total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:59,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 59 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+])
+
+AT_CHECK([ovs-appctl time/warp 5000], [0], [ignore])
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 dump-flows br0 | ofctl_strip | sort], [0], [dnl
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:50 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],push_vlan:0x8100,set_field:4195->vlan_vid,set_field:1->vlan_pcp,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:51 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],push_vlan:0x8100,set_field:4195->vlan_vid,set_field:1->vlan_pcp,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:52 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:53 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:54 actions=push_vlan:0x8100,set_field:4195->vlan_vid,set_field:1->vlan_pcp,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:55 actions=push_vlan:0x8100,set_field:4195->vlan_vid,set_field:1->vlan_pcp,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:56 actions=push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:57 actions=push_vlan:0x8100,load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, vlan_tci=0x1000/0x1000,dl_src=40:44:44:44:54:58 actions=load:0x63->OXM_OF_VLAN_VID[[]],set_field:1->vlan_pcp,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, vlan_tci=0x1000/0x1000,dl_src=40:44:44:44:54:59 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],set_field:1->vlan_pcp,load:0x63->OXM_OF_VLAN_VID[[]],CONTROLLER:65535
+OFPST_FLOW reply (OF1.2):
+])
+
+OVS_VSWITCHD_STOP
+AT_CLEANUP
+
 AT_SETUP([ofproto-dpif - fragment handling])
 OVS_VSWITCHD_START
 ADD_OF_PORTS([br0], [1], [2], [3], [4], [5], [6], [90])
-- 
1.8.4
