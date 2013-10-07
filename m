From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2.42 1/5] odp: Allow VLAN actions after MPLS actions
Date: Mon, 7 Oct 2013 15:34:47 +0900
Message-ID: <20131007063447.GF19926@verge.net.au>
References: <1380874200-8981-1-git-send-email-horms@verge.net.au>
 <1380874200-8981-2-git-send-email-horms@verge.net.au>
 <20131004162133.GG29572@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49289 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988Ab3JGGev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 02:34:51 -0400
Content-Disposition: inline
In-Reply-To: <20131004162133.GG29572@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 04, 2013 at 09:21:33AM -0700, Ben Pfaff wrote:
> On Fri, Oct 04, 2013 at 05:09:56PM +0900, Simon Horman wrote:
> > From: Joe Stringer <joe@wand.net.nz>
> > 
> > OpenFlow 1.1 and 1.2, and 1.3 differ in their handling of MPLS actions in the
> > presence of VLAN tags. To allow correct behaviour to be committed in
> > each situation, this patch adds a second round of VLAN tag action
> > handling to commit_odp_actions(), which occurs after MPLS actions. This
> > is implemented with a new field in 'struct xlate_in' called 'vlan_tci'.
> > 
> > When an push_mpls action is composed, the flow's current VLAN state is
> > stored into xin->vlan_tci, and flow->vlan_tci is set to 0 (pop_vlan). If
> > a VLAN tag is present, it is stripped; if not, then there is no change.
> > Any later modifications to the VLAN state is written to xin->vlan_tci.
> > When committing the actions, flow->vlan_tci is used before MPLS actions,
> > and xin->vlan_tci is used afterwards. This retains the current datapath
> > behaviour, but allows VLAN actions to be applied in a more flexible
> > manner.
> > 
> > Both before and after this patch MPLS LSEs are pushed onto a packet after
> > any VLAN tags that may be present. This is the behaviour described in
> > OpenFlow 1.1 and 1.2. OpenFlow 1.3 specifies that MPLS LSEs should be
> > pushed onto a packet before any VLAN tags that are present. Support
> > for this will be added by a subsequent patch that makes use of
> > the infrastructure added by this patch.
> > 
> > Signed-off-by: Joe Stringer <joe@wand.net.nz>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> 
> I noticed a couple more minor points.
> 
> First, it seems to me that the "vlan_tci" member that this adds to
> xlate_in could go in xlate_ctx just as well.  I would prefer that,
> because (as far as I can tell) there is no reason for the client to use
> any value other than flow->vlan_tci here, and putting it in xlate_ctx
> hides it from the client.

Thanks. Yes I agree that is a good idea.

> Thanks for rearranging the code and updating the comment in
> do_xlate_actions().  It makes the operation clearer.  But now that it's
> clear I have an additional question.  Does it really make sense to have
> 'vlan_tci' as only a local variable in do_xlate_actions()?  Presumably,
> MPLS and VLANs should interact the same way regardless of whether they
> are separated by resubmits or goto_tables.  That is, I suspect that this
> is xlate_ctx state, not local state.

Agreed.

What I have done is to make an incremental patch which:

1. Moves the 'vlan_tci' member of strict xlate_in to
   be the 'final_vlan_tci' member of struct xlate_ctx.

2. Moves the 'vlan_tci' local variable of do_xlate_actions()
   to be the 'next_vlan_tci' member of struct xlate_ctx.

3. Restructures the comments surrounding the logic of the vlan_tci
   code that this patch adds mostly as comments for the new
   members of struct xlate_ctx. I hope things are (still?) clear.

For reference, the incremental patch I have so far is as follows.
I will squash it into this patch before reposting this series.

commit d57735cec0d3e53c7479725ae1cf825563902c30
Author: Simon Horman <horms@verge.net.au>
Date:   Mon Oct 7 14:30:28 2013 +0900

    Move vlan state into struct xlate_ctx
    
    1. Add final_vlan_tci member to struct xlate_ctx instead of vlan_tci member
       struct xlate_xin.  This seems to be a better palace for it as it does
       not need to be accessible from the caller.
    
    2. Move local vlan_tci variable of do_xlate_actions() to be the
       next_vlan_tci member of strict xlate_ctx.  This allows for it to work
       across resubmit actions and goto table instructions.
    
    As suggested by Ben Pfaff

diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
index 2afd760..845c6fe 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -172,6 +172,37 @@ struct xlate_ctx {
     odp_port_t sflow_odp_port;  /* Output port for composing sFlow action. */
     uint16_t user_cookie_offset;/* Used for user_action_cookie fixup. */
     bool exit;                  /* No further actions should be processed. */
+
+    /* The final vlan_tci state.
+     *
+     * The value of the vlan TCI prior to the committing of ODP MPLS
+     * actions should be stored in 'xin->flow->vlan_tci'.
+     *
+     * The final value of the VLAN TCI should be stored in 'vlan_tci'. And
+     * is if the value of 'vlan_tci' and 'xin->flow->vlan_tci' differ then
+     * VLAN ODP actions will be committed after any MPLS actions regardless
+     * of whether VLAN actions were also committed before the MPLS actions or
+     * not.
+     *
+     * This mechanism allows a VLAN tag to be popped before pushing
+     * an MPLS LSE and then the same VLAN tag pushed after pushing
+     * the MPLS LSE. In this way it is possible to push an MPLS LSE
+     * before an existing VLAN tag. Moreover this mechanism allows
+     * the order in which VLAN tags and MPLS LSEs are pushed. */
+    ovs_be16 final_vlan_tci;
+
+    /* The next vlan_tci state.
+     *
+     * This value this variable points to updated each time an
+     * action updates the VLAN tci.
+     *
+     * This variable initially points to 'xin->flow->vlan_tci' so that ODP
+     * VLAN actions are committed before any MPLS actions. When an MPLS
+     * action is composed 'next_vlan_tci' is updated to point to
+     * 'final_vlan_tci'. This causes subsequent VLAN actions to be
+     * committed after MPLS actions. */
+    ovs_be16 *next_vlan_tci;
+
 };
 
 /* A controller may use OFPP_NONE as the ingress port to indicate that
@@ -982,7 +1013,7 @@ static void
 output_normal(struct xlate_ctx *ctx, const struct xbundle *out_xbundle,
               uint16_t vlan)
 {
-    ovs_be16 *flow_tci = &ctx->xin->vlan_tci;
+    ovs_be16 *flow_tci = &ctx->final_vlan_tci;
     uint16_t vid;
     ovs_be16 tci, old_tci;
     struct xport *xport;
@@ -1258,7 +1289,7 @@ xlate_normal(struct xlate_ctx *ctx)
 
     /* Drop malformed frames. */
     if (flow->dl_type == htons(ETH_TYPE_VLAN) &&
-        !(ctx->xin->vlan_tci & htons(VLAN_CFI))) {
+        !(ctx->final_vlan_tci & htons(VLAN_CFI))) {
         if (ctx->xin->packet != NULL) {
             static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 5);
             VLOG_WARN_RL(&rl, "bridge %s: dropping packet with partial "
@@ -1282,7 +1313,7 @@ xlate_normal(struct xlate_ctx *ctx)
     }
 
     /* Check VLAN. */
-    vid = vlan_tci_to_vid(ctx->xin->vlan_tci);
+    vid = vlan_tci_to_vid(ctx->final_vlan_tci);
     if (!input_vid_is_valid(vid, in_xbundle, ctx->xin->packet != NULL)) {
         xlate_report(ctx, "disallowed VLAN VID for this input port, dropping");
         return;
@@ -1540,7 +1571,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
     const struct xport *xport = get_ofp_port(ctx->xbridge, ofp_port);
     struct flow_wildcards *wc = &ctx->xout->wc;
     struct flow *flow = &ctx->xin->flow;
-    ovs_be16 flow_vlan_tci, xin_vlan_tci;
+    ovs_be16 flow_vlan_tci, vlan_tci;
     uint32_t flow_pkt_mark;
     uint8_t flow_nw_tos;
     odp_port_t out_port, odp_port;
@@ -1609,7 +1640,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
     }
 
     flow_vlan_tci = flow->vlan_tci;
-    xin_vlan_tci = ctx->xin->vlan_tci;
+    vlan_tci = ctx->final_vlan_tci;
     flow_pkt_mark = flow->pkt_mark;
     flow_nw_tos = flow->nw_tos;
 
@@ -1649,20 +1680,20 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
             wc->masks.vlan_tci |= htons(VLAN_VID_MASK | VLAN_CFI);
         }
         vlandev_port = vsp_realdev_to_vlandev(ctx->xbridge->ofproto, ofp_port,
-                                              ctx->xin->vlan_tci);
+                                              ctx->final_vlan_tci);
         if (vlandev_port == ofp_port) {
             out_port = odp_port;
         } else {
             out_port = ofp_port_to_odp_port(ctx->xbridge, vlandev_port);
             flow->vlan_tci = htons(0);
-            ctx->xin->vlan_tci = htons(0);
+            ctx->final_vlan_tci = htons(0);
         }
     }
 
     if (out_port != ODPP_NONE) {
         commit_odp_actions(flow, &ctx->base_flow,
                            &ctx->xout->odp_actions, &ctx->xout->wc,
-                           &ctx->mpls_depth_delta, ctx->xin->vlan_tci);
+                           &ctx->mpls_depth_delta, ctx->final_vlan_tci);
         nl_msg_put_odp_port(&ctx->xout->odp_actions, OVS_ACTION_ATTR_OUTPUT,
                             out_port);
 
@@ -1674,7 +1705,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
  out:
     /* Restore flow */
     flow->vlan_tci = flow_vlan_tci;
-    ctx->xin->vlan_tci = xin_vlan_tci;
+    ctx->final_vlan_tci = vlan_tci;
     flow->pkt_mark = flow_pkt_mark;
     flow->nw_tos = flow_nw_tos;
 }
@@ -1819,7 +1850,7 @@ execute_controller_action(struct xlate_ctx *ctx, int len,
 
     commit_odp_actions(&ctx->xin->flow, &ctx->base_flow,
                        &ctx->xout->odp_actions, &ctx->xout->wc,
-                       &ctx->mpls_depth_delta, ctx->xin->vlan_tci);
+                       &ctx->mpls_depth_delta, ctx->final_vlan_tci);
 
     odp_execute_actions(NULL, packet, &key, ctx->xout->odp_actions.data,
                         ctx->xout->odp_actions.size, NULL, NULL);
@@ -2207,7 +2238,7 @@ xlate_sample_action(struct xlate_ctx *ctx,
 
   commit_odp_actions(&ctx->xin->flow, &ctx->base_flow,
                      &ctx->xout->odp_actions, &ctx->xout->wc,
-                     &ctx->mpls_depth_delta, ctx->xin->vlan_tci);
+                     &ctx->mpls_depth_delta, ctx->final_vlan_tci);
 
   compose_flow_sample_cookie(os->probability, os->collector_set_id,
                              os->obs_domain_id, os->obs_point_id, &cookie);
@@ -2236,13 +2267,14 @@ may_receive(const struct xport *xport, struct xlate_ctx *ctx)
 }
 
 static void
-vlan_tci_restore(struct xlate_in *xin, ovs_be16 *tci_ptr, ovs_be16 orig_tci)
+vlan_tci_restore(struct xlate_ctx *ctx, ovs_be16 orig_tci)
 {
     /* If MPLS actions were executed after vlan actions then
      * copy the final vlan_tci out and restore the intermediate VLAN state. */
-    if (xin->flow.vlan_tci != orig_tci && tci_ptr == &xin->vlan_tci) {
-        xin->vlan_tci = xin->flow.vlan_tci;
-        xin->flow.vlan_tci = orig_tci;
+    if (ctx->xin->flow.vlan_tci != orig_tci &&
+        ctx->next_vlan_tci == &ctx->final_vlan_tci) {
+        ctx->final_vlan_tci = ctx->xin->flow.vlan_tci;
+        ctx->xin->flow.vlan_tci = orig_tci;
     }
 }
 
@@ -2252,19 +2284,8 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 {
     struct flow_wildcards *wc = &ctx->xout->wc;
     struct flow *flow = &ctx->xin->flow;
-    ovs_be16 *vlan_tci;
     const struct ofpact *a;
 
-
-    /* VLAN actions are stored in '*vlan_tci'. This variable initially
-     * points to 'xin->flow->vlan_tci', so that VLAN actions are applied
-     * before any MPLS actions. When an MPLS action is translated,
-     * 'vlan_tci' is updated to point to 'xin->vlan_tci'. This causes later
-     * VLAN actions to be applied after MPLS actions.  For each iteration
-     * of the loop 'xin->vlan_tci' is updated to reflect the final VLAN
-     * state of the flow. */
-    vlan_tci = &ctx->xin->flow.vlan_tci;
-
     OFPACT_FOR_EACH (a, ofpacts, ofpacts_len) {
         struct ofpact_controller *controller;
         const struct ofpact_metadata *metadata;
@@ -2274,7 +2295,7 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
         }
 
         /* Update the final vlan state to match the current state. */
-        ctx->xin->vlan_tci = *vlan_tci;
+        ctx->final_vlan_tci = *ctx->next_vlan_tci;
 
         switch (a->type) {
         case OFPACT_OUTPUT:
@@ -2299,28 +2320,28 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
         case OFPACT_SET_VLAN_VID:
             wc->masks.vlan_tci |= htons(VLAN_VID_MASK | VLAN_CFI);
-            *vlan_tci &= ~htons(VLAN_VID_MASK);
-            *vlan_tci |= (htons(ofpact_get_SET_VLAN_VID(a)->vlan_vid)
+            *ctx->next_vlan_tci &= ~htons(VLAN_VID_MASK);
+            *ctx->next_vlan_tci |= (htons(ofpact_get_SET_VLAN_VID(a)->vlan_vid)
                           | htons(VLAN_CFI));
             break;
 
         case OFPACT_SET_VLAN_PCP:
             wc->masks.vlan_tci |= htons(VLAN_VID_MASK | VLAN_CFI);
-            *vlan_tci &= ~htons(VLAN_PCP_MASK);
-            *vlan_tci |=
+            *ctx->next_vlan_tci &= ~htons(VLAN_PCP_MASK);
+            *ctx->next_vlan_tci |=
                 htons((ofpact_get_SET_VLAN_PCP(a)->vlan_pcp << VLAN_PCP_SHIFT)
                       | VLAN_CFI);
             break;
 
         case OFPACT_STRIP_VLAN:
             memset(&wc->masks.vlan_tci, 0xff, sizeof wc->masks.vlan_tci);
-            *vlan_tci = htons(0);
+            *ctx->next_vlan_tci = htons(0);
             break;
 
         case OFPACT_PUSH_VLAN:
             /* XXX 802.1AD(QinQ) */
             memset(&wc->masks.vlan_tci, 0xff, sizeof wc->masks.vlan_tci);
-            *vlan_tci = htons(VLAN_CFI);
+            *ctx->next_vlan_tci = htons(VLAN_CFI);
             break;
 
         case OFPACT_SET_ETH_SRC:
@@ -2391,20 +2412,20 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
         case OFPACT_REG_MOVE: {
             ovs_be16 orig_tci = flow->vlan_tci;
             nxm_execute_reg_move(ofpact_get_REG_MOVE(a), flow, wc);
-            vlan_tci_restore(ctx->xin, vlan_tci, orig_tci);
+            vlan_tci_restore(ctx, orig_tci);
             break;
         }
 
         case OFPACT_REG_LOAD: {
             ovs_be16 orig_tci = flow->vlan_tci;
             nxm_execute_reg_load(ofpact_get_REG_LOAD(a), flow);
-            vlan_tci_restore(ctx->xin, vlan_tci, orig_tci);
+            vlan_tci_restore(ctx, orig_tci);
             break;
         }
 
         case OFPACT_STACK_PUSH: {
             ovs_be16 orig_tci = flow->vlan_tci;
-            flow->vlan_tci = *vlan_tci;
+            flow->vlan_tci = *ctx->next_vlan_tci;
             nxm_execute_stack_push(ofpact_get_STACK_PUSH(a), flow, wc,
                                    &ctx->stack);
             flow->vlan_tci = orig_tci;
@@ -2415,7 +2436,7 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
             ovs_be16 orig_tci = flow->vlan_tci;
             nxm_execute_stack_pop(ofpact_get_STACK_POP(a), flow, wc,
                                   &ctx->stack);
-            vlan_tci_restore(ctx->xin, vlan_tci, orig_tci);
+            vlan_tci_restore(ctx, orig_tci);
             break;
         }
 
@@ -2433,11 +2454,11 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
              * Do not save and therefore pop the VLAN tags if the MPLS LSE
              * should be pushed before any VLAN tags that are present.
              * This is the behaviour described for OpenFlow 1.3. */
-            ctx->xin->vlan_tci = *vlan_tci;
+            ctx->final_vlan_tci = *ctx->next_vlan_tci;
             if (!oam->mpls_before_vlan) {
                 flow->vlan_tci = htons(0);
             }
-            vlan_tci = &ctx->xin->vlan_tci;
+            ctx->next_vlan_tci = &ctx->final_vlan_tci;
             break;
         }
 
@@ -2540,7 +2561,6 @@ xlate_in_init(struct xlate_in *xin, struct ofproto_dpif *ofproto,
 {
     xin->ofproto = ofproto;
     xin->flow = *flow;
-    xin->vlan_tci = flow->vlan_tci;
     xin->packet = packet;
     xin->may_learn = packet != NULL;
     xin->rule = rule;
@@ -2770,6 +2790,8 @@ xlate_actions(struct xlate_in *xin, struct xlate_out *xout)
     ctx.table_id = 0;
     ctx.exit = false;
     ctx.mpls_depth_delta = 0;
+    ctx.final_vlan_tci = ctx->xin->flow.vlan_tci;
+    ctx.next_vlan_tci = &ctx->xin->flow.vlan_tci;
 
     if (xin->ofpacts) {
         ofpacts = xin->ofpacts;
diff --git a/ofproto/ofproto-dpif-xlate.h b/ofproto/ofproto-dpif-xlate.h
index 54fd36d..6403f50 100644
--- a/ofproto/ofproto-dpif-xlate.h
+++ b/ofproto/ofproto-dpif-xlate.h
@@ -60,11 +60,6 @@ struct xlate_in {
      * this flow when actions change header fields. */
     struct flow flow;
 
-    /* If MPLS and VLAN actions were both present in the translation, and VLAN
-     * actions should occur after the MPLS actions, then this field is used
-     * to store the final vlan_tci state. */
-    ovs_be16 vlan_tci;
-
     /* The packet corresponding to 'flow', or a null pointer if we are
      * revalidating without a packet to refer to. */
     const struct ofpbuf *packet;
