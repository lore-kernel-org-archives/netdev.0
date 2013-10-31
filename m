From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.47 1/4] odp: Allow VLAN actions after MPLS actions
Date: Thu, 31 Oct 2013 16:16:29 +0900
Message-ID: <1383203792-9774-2-git-send-email-horms@verge.net.au>
References: <1383203792-9774-1-git-send-email-horms@verge.net.au>
Cc: Pravin B Shelar <pshelar@nicira.com>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:37966 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182Ab3JaHQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 03:16:37 -0400
In-Reply-To: <1383203792-9774-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@wand.net.nz>

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

Signed-off-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

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

v2.5 [Joe Stringer]
* First post
---
 lib/odp-util.c               |  12 +-
 lib/odp-util.h               |   3 +-
 ofproto/ofproto-dpif-xlate.c | 136 ++++++++++++---
 tests/ofproto-dpif.at        | 389 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 514 insertions(+), 26 deletions(-)

diff --git a/lib/odp-util.c b/lib/odp-util.c
index 6ac3853..66ceca4 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -3675,11 +3675,15 @@ commit_set_pkt_mark_action(const struct flow *flow, struct flow *base,
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
 
@@ -3692,6 +3696,10 @@ commit_odp_actions(const struct flow *flow, struct flow *base,
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
index 48d078d..18bd4e9 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -180,6 +180,37 @@ struct xlate_ctx {
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
@@ -996,11 +1027,38 @@ output_vlan_to_vid(const struct xbundle *out_xbundle, uint16_t vlan)
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
@@ -1025,18 +1083,18 @@ output_normal(struct xlate_ctx *ctx, const struct xbundle *out_xbundle,
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
@@ -1269,7 +1327,7 @@ xlate_normal(struct xlate_ctx *ctx)
 
     /* Drop malformed frames. */
     if (flow->dl_type == htons(ETH_TYPE_VLAN) &&
-        !(flow->vlan_tci & htons(VLAN_CFI))) {
+        !(*ctx->next_vlan_tci & htons(VLAN_CFI))) {
         if (ctx->xin->packet != NULL) {
             static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 5);
             VLOG_WARN_RL(&rl, "bridge %s: dropping packet with partial "
@@ -1293,7 +1351,7 @@ xlate_normal(struct xlate_ctx *ctx)
     }
 
     /* Check VLAN. */
-    vid = vlan_tci_to_vid(flow->vlan_tci);
+    vid = vlan_tci_to_vid(*ctx->next_vlan_tci);
     if (!input_vid_is_valid(vid, in_xbundle, ctx->xin->packet != NULL)) {
         xlate_report(ctx, "disallowed VLAN VID for this input port, dropping");
         return;
@@ -1551,7 +1609,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
     const struct xport *xport = get_ofp_port(ctx->xbridge, ofp_port);
     struct flow_wildcards *wc = &ctx->xout->wc;
     struct flow *flow = &ctx->xin->flow;
-    ovs_be16 flow_vlan_tci;
+    ovs_be16 flow_vlan_tci, vlan_tci;
     uint32_t flow_pkt_mark;
     uint8_t flow_nw_tos;
     odp_port_t out_port, odp_port;
@@ -1620,6 +1678,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
     }
 
     flow_vlan_tci = flow->vlan_tci;
+    vlan_tci = *ctx->next_vlan_tci;
     flow_pkt_mark = flow->pkt_mark;
     flow_nw_tos = flow->nw_tos;
 
@@ -1659,12 +1718,13 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
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
 
@@ -1672,7 +1732,8 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
         ctx->xout->slow |= commit_odp_actions(flow, &ctx->base_flow,
                                               &ctx->xout->odp_actions,
                                               &ctx->xout->wc,
-                                              &ctx->mpls_depth_delta);
+                                              &ctx->mpls_depth_delta,
+                                              ctx->post_mpls_vlan_tci);
         nl_msg_put_odp_port(&ctx->xout->odp_actions, OVS_ACTION_ATTR_OUTPUT,
                             out_port);
 
@@ -1684,6 +1745,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
  out:
     /* Restore flow */
     flow->vlan_tci = flow_vlan_tci;
+    *ctx->next_vlan_tci = vlan_tci;
     flow->pkt_mark = flow_pkt_mark;
     flow->nw_tos = flow_nw_tos;
 }
@@ -1838,7 +1900,8 @@ execute_controller_action(struct xlate_ctx *ctx, int len,
     ctx->xout->slow |= commit_odp_actions(&ctx->xin->flow, &ctx->base_flow,
                                           &ctx->xout->odp_actions,
                                           &ctx->xout->wc,
-                                          &ctx->mpls_depth_delta);
+                                          &ctx->mpls_depth_delta,
+                                          ctx->post_mpls_vlan_tci);
 
     odp_execute_actions(NULL, packet, &key, ctx->xout->odp_actions.data,
                         ctx->xout->odp_actions.size, NULL, NULL);
@@ -2231,7 +2294,8 @@ xlate_sample_action(struct xlate_ctx *ctx,
   ctx->xout->slow |= commit_odp_actions(&ctx->xin->flow, &ctx->base_flow,
                                         &ctx->xout->odp_actions,
                                         &ctx->xout->wc,
-                                        &ctx->mpls_depth_delta);
+                                        &ctx->mpls_depth_delta,
+                                        ctx->post_mpls_vlan_tci);
 
   compose_flow_sample_cookie(os->probability, os->collector_set_id,
                              os->obs_domain_id, os->obs_point_id, &cookie);
@@ -2320,28 +2384,28 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
         case OFPACT_SET_VLAN_VID:
             wc->masks.vlan_tci |= htons(VLAN_VID_MASK | VLAN_CFI);
-            flow->vlan_tci &= ~htons(VLAN_VID_MASK);
-            flow->vlan_tci |= (htons(ofpact_get_SET_VLAN_VID(a)->vlan_vid)
-                               | htons(VLAN_CFI));
+            *ctx->next_vlan_tci &= ~htons(VLAN_VID_MASK);
+            *ctx->next_vlan_tci |= (htons(ofpact_get_SET_VLAN_VID(a)->vlan_vid)
+                          | htons(VLAN_CFI));
             break;
 
         case OFPACT_SET_VLAN_PCP:
             wc->masks.vlan_tci |= htons(VLAN_PCP_MASK | VLAN_CFI);
-            flow->vlan_tci &= ~htons(VLAN_PCP_MASK);
-            flow->vlan_tci |=
+            *ctx->next_vlan_tci &= ~htons(VLAN_PCP_MASK);
+            *ctx->next_vlan_tci |=
                 htons((ofpact_get_SET_VLAN_PCP(a)->vlan_pcp << VLAN_PCP_SHIFT)
                       | VLAN_CFI);
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
@@ -2423,29 +2487,53 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
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
@@ -2786,6 +2874,8 @@ xlate_actions__(struct xlate_in *xin, struct xlate_out *xout)
     ctx.table_id = 0;
     ctx.exit = false;
     ctx.mpls_depth_delta = 0;
+    ctx.post_mpls_vlan_tci = htons(0);
+    ctx.next_vlan_tci = &ctx.xin->flow.vlan_tci;
 
     if (!xin->ofpacts && !ctx.rule) {
         rule_dpif_lookup(ctx.xbridge->ofproto, flow, wc, &rule);
diff --git a/tests/ofproto-dpif.at b/tests/ofproto-dpif.at
index 9e0ea4b..3ced7db 100644
--- a/tests/ofproto-dpif.at
+++ b/tests/ofproto-dpif.at
@@ -965,6 +965,395 @@ done
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
+cookie=0xa dl_src=40:44:44:44:54:50 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],push_vlan:0x8100,mod_vlan_vid:99,mod_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:54:51 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],push_vlan:0x8100,mod_vlan_vid:99,mod_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:54:52 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:54:53 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,controller
+cookie=0xa dl_src=40:44:44:44:54:54 actions=push_vlan:0x8100,mod_vlan_vid:99,mod_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],controller
+cookie=0xa dl_src=40:44:44:44:54:55 actions=push_vlan:0x8100,mod_vlan_vid:99,mod_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],controller
+cookie=0xa dl_src=40:44:44:44:54:56 actions=push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],controller
+cookie=0xa dl_src=40:44:44:44:54:57 actions=push_vlan:0x8100,load:99->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],controller
+cookie=0xa dl_src=40:44:44:44:54:58 actions=load:99->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],controller
+cookie=0xa dl_src=40:44:44:44:54:59 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],mod_vlan_pcp:1,load:99->OXM_OF_VLAN_VID[[]],controller
+])
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 add-flows br0 flows.txt])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we see
+dnl both of these in the final flow
+AT_CHECK([ovs-ofctl monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:50,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([ovs-appctl -t ovs-ofctl exit])
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 50 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 50 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
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
+AT_CHECK([ovs-ofctl monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:51,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 51 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 51 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
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
+AT_CHECK([ovs-ofctl monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:52,dst=52:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([ovs-appctl -t ovs-ofctl exit])
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:52,dl_dst=52:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  52 54 00 00 00 07 40 44-44 44 54 52 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:52,dl_dst=52:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  52 54 00 00 00 07 40 44-44 44 54 52 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
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
+AT_CHECK([ovs-ofctl monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:53,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:53,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 53 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:53,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 53 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
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
+AT_CHECK([ovs-ofctl monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:54,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:54,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 54 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:54,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 54 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
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
+AT_CHECK([ovs-ofctl monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:55,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:55,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 55 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:55,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 55 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
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
+AT_CHECK([ovs-ofctl monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:56,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:56,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 56 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:56,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 56 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+00000040  00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
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
+AT_CHECK([ovs-ofctl monitor br0 -m 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:57,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:57,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 57 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:57,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 57 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
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
+AT_CHECK([ovs-ofctl monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:58,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:58,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 58 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:58,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 58 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
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
+AT_CHECK([ovs-ofctl monitor br0 65534 -m -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:59,dst=50:54:00:00:00:07),eth_type(0x8100),vlan(vid=88,pcp=7),encap(eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no))'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:59,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 59 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:59,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 59 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:59,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+00000000  50 54 00 00 00 07 40 44-44 44 54 59 81 00 20 63
+00000010  88 47 00 00 a1 40 45 00-00 28 00 00 00 00 40 06
+00000020  f9 7c c0 a8 00 01 c0 a8-00 02 00 00 00 00 00 00
+00000030  00 00 00 00 00 00 50 00-00 00 00 00 00 00 00 00
+])
+
+AT_CHECK([ovs-appctl time/warp 5000], [0], [ignore])
+AT_CHECK([ovs-ofctl dump-flows br0 | ofctl_strip | sort], [0], [dnl
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:50 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],mod_vlan_vid:99,mod_vlan_pcp:1,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:51 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],mod_vlan_vid:99,mod_vlan_pcp:1,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:52 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x63->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:53 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x63->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:54 actions=mod_vlan_vid:99,mod_vlan_pcp:1,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:55 actions=mod_vlan_vid:99,mod_vlan_pcp:1,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:56 actions=load:0x63->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:57 actions=load:0x63->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:58 actions=load:0x63->OXM_OF_VLAN_VID[[]],mod_vlan_pcp:1,push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:54:59 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],mod_vlan_pcp:1,load:0x63->OXM_OF_VLAN_VID[[]],CONTROLLER:65535
+NXST_FLOW reply:
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
