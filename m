From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.43 1/5] odp: Allow VLAN actions after MPLS actions
Date: Mon,  7 Oct 2013 17:00:43 +0900
Message-ID: <1381132847-12589-2-git-send-email-horms@verge.net.au>
References: <1381132847-12589-1-git-send-email-horms@verge.net.au>
Cc: Pravin B Shelar <pshelar@nicira.com>, Ravi K <rkerur@gmail.com>,
	Isaku Yamahata <yamahata@valinux.co.jp>,
	Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39525 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754152Ab3JGIAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 04:00:52 -0400
In-Reply-To: <1381132847-12589-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@wand.net.nz>

OpenFlow 1.1 and 1.2, and 1.3 differ in their handling of MPLS actions in the
presence of VLAN tags. To allow correct behaviour to be committed in
each situation, this patch adds a second round of VLAN tag action
handling to commit_odp_actions(), which occurs after MPLS actions. This
is implemented with a new field in 'struct xlate_in' called 'vlan_tci'.

When an push_mpls action is composed, the flow's current VLAN state is
stored into xin->vlan_tci, and flow->vlan_tci is set to 0 (pop_vlan). If
a VLAN tag is present, it is stripped; if not, then there is no change.
Any later modifications to the VLAN state is written to xin->vlan_tci.
When committing the actions, flow->vlan_tci is used before MPLS actions,
and xin->vlan_tci is used afterwards. This retains the current datapath
behaviour, but allows VLAN actions to be applied in a more flexible
manner.

Both before and after this patch MPLS LSEs are pushed onto a packet after
any VLAN tags that may be present. This is the behaviour described in
OpenFlow 1.1 and 1.2. OpenFlow 1.3 specifies that MPLS LSEs should be
pushed onto a packet before any VLAN tags that are present. Support
for this will be added by a subsequent patch that makes use of
the infrastructure added by this patch.

Signed-off-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

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
 lib/odp-util.c               |   9 +-
 lib/odp-util.h               |   2 +-
 ofproto/ofproto-dpif-xlate.c | 123 ++++++++++++++++++++-----
 tests/ofproto-dpif.at        | 209 +++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 320 insertions(+), 23 deletions(-)

diff --git a/lib/odp-util.c b/lib/odp-util.c
index 5c7ccfb..4028167 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -3600,11 +3600,15 @@ commit_set_pkt_mark_action(const struct flow *flow, struct flow *base,
  * key from 'base' into 'flow', and then changes 'base' the same way.  Does not
  * commit set_tunnel actions.  Users should call commit_odp_tunnel_action()
  * in addition to this function if needed.  Sets fields in 'wc' that are
- * used as part of the action. */
+ * used as part of the action.
+ *
+ * VLAN actions may be committed twice; If vlan_tci in 'flow' differs from the
+ * one in 'base', then it is committed before MPLS actions. If 'final_vlan_tci'
+ * differs from 'flow->vlan_tci', it is committed afterwards. */
 void
 commit_odp_actions(const struct flow *flow, struct flow *base,
                    struct ofpbuf *odp_actions, struct flow_wildcards *wc,
-                   int *mpls_depth_delta)
+                   int *mpls_depth_delta, ovs_be16 final_vlan_tci)
 {
     commit_set_ether_addr_action(flow, base, odp_actions, wc);
     commit_vlan_action(flow->vlan_tci, base, odp_actions, wc);
@@ -3615,6 +3619,7 @@ commit_odp_actions(const struct flow *flow, struct flow *base,
      * that it is no longer IP and thus nw and port actions are no longer valid.
      */
     commit_mpls_action(flow, base, odp_actions, wc, mpls_depth_delta);
+    commit_vlan_action(final_vlan_tci, base, odp_actions, wc);
     commit_set_priority_action(flow, base, odp_actions, wc);
     commit_set_pkt_mark_action(flow, base, odp_actions, wc);
 }
diff --git a/lib/odp-util.h b/lib/odp-util.h
index 2712cb0..a7bca43 100644
--- a/lib/odp-util.h
+++ b/lib/odp-util.h
@@ -143,7 +143,7 @@ void commit_odp_tunnel_action(const struct flow *, struct flow *base,
                               struct ofpbuf *odp_actions);
 void commit_odp_actions(const struct flow *, struct flow *base,
                         struct ofpbuf *odp_actions, struct flow_wildcards *wc,
-                        int *mpls_depth_delta);
+                        int *mpls_depth_delta, ovs_be16 final_vlan_tci);
 
 /* ofproto-dpif interface.
  *
diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
index 930abc3..eb06d8c 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -179,6 +179,37 @@ struct xlate_ctx {
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
+     * after an existing VLAN tag. Moreover this mechanism allows
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
@@ -989,10 +1020,11 @@ static void
 output_normal(struct xlate_ctx *ctx, const struct xbundle *out_xbundle,
               uint16_t vlan)
 {
-    ovs_be16 *flow_tci = &ctx->xin->flow.vlan_tci;
+    ovs_be16 *flow_tci = &ctx->final_vlan_tci;
     uint16_t vid;
     ovs_be16 tci, old_tci;
     struct xport *xport;
+    bool flow_tci_equal_to_xin = (*flow_tci == ctx->xin->flow.vlan_tci);
 
     vid = output_vlan_to_vid(out_xbundle, vlan);
     if (list_is_empty(&out_xbundle->xports)) {
@@ -1023,9 +1055,15 @@ output_normal(struct xlate_ctx *ctx, const struct xbundle *out_xbundle,
         }
     }
     *flow_tci = tci;
+    if (flow_tci_equal_to_xin) {
+        ctx->xin->flow.vlan_tci = tci;
+    }
 
     compose_output_action(ctx, xport->ofp_port);
     *flow_tci = old_tci;
+    if (flow_tci_equal_to_xin) {
+        ctx->xin->flow.vlan_tci = old_tci;
+    }
 }
 
 /* A VM broadcasts a gratuitous ARP to indicate that it has resumed after
@@ -1258,7 +1296,7 @@ xlate_normal(struct xlate_ctx *ctx)
 
     /* Drop malformed frames. */
     if (flow->dl_type == htons(ETH_TYPE_VLAN) &&
-        !(flow->vlan_tci & htons(VLAN_CFI))) {
+        !(ctx->final_vlan_tci & htons(VLAN_CFI))) {
         if (ctx->xin->packet != NULL) {
             static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 5);
             VLOG_WARN_RL(&rl, "bridge %s: dropping packet with partial "
@@ -1282,7 +1320,7 @@ xlate_normal(struct xlate_ctx *ctx)
     }
 
     /* Check VLAN. */
-    vid = vlan_tci_to_vid(flow->vlan_tci);
+    vid = vlan_tci_to_vid(ctx->final_vlan_tci);
     if (!input_vid_is_valid(vid, in_xbundle, ctx->xin->packet != NULL)) {
         xlate_report(ctx, "disallowed VLAN VID for this input port, dropping");
         return;
@@ -1540,7 +1578,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
     const struct xport *xport = get_ofp_port(ctx->xbridge, ofp_port);
     struct flow_wildcards *wc = &ctx->xout->wc;
     struct flow *flow = &ctx->xin->flow;
-    ovs_be16 flow_vlan_tci;
+    ovs_be16 flow_vlan_tci, vlan_tci;
     uint32_t flow_pkt_mark;
     uint8_t flow_nw_tos;
     odp_port_t out_port, odp_port;
@@ -1609,6 +1647,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
     }
 
     flow_vlan_tci = flow->vlan_tci;
+    vlan_tci = ctx->final_vlan_tci;
     flow_pkt_mark = flow->pkt_mark;
     flow_nw_tos = flow->nw_tos;
 
@@ -1648,19 +1687,20 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
             wc->masks.vlan_tci |= htons(VLAN_VID_MASK | VLAN_CFI);
         }
         vlandev_port = vsp_realdev_to_vlandev(ctx->xbridge->ofproto, ofp_port,
-                                              flow->vlan_tci);
+                                              ctx->final_vlan_tci);
         if (vlandev_port == ofp_port) {
             out_port = odp_port;
         } else {
             out_port = ofp_port_to_odp_port(ctx->xbridge, vlandev_port);
             flow->vlan_tci = htons(0);
+            ctx->final_vlan_tci = htons(0);
         }
     }
 
     if (out_port != ODPP_NONE) {
         commit_odp_actions(flow, &ctx->base_flow,
                            &ctx->xout->odp_actions, &ctx->xout->wc,
-                           &ctx->mpls_depth_delta);
+                           &ctx->mpls_depth_delta, ctx->final_vlan_tci);
         nl_msg_put_odp_port(&ctx->xout->odp_actions, OVS_ACTION_ATTR_OUTPUT,
                             out_port);
 
@@ -1672,6 +1712,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
  out:
     /* Restore flow */
     flow->vlan_tci = flow_vlan_tci;
+    ctx->final_vlan_tci = vlan_tci;
     flow->pkt_mark = flow_pkt_mark;
     flow->nw_tos = flow_nw_tos;
 }
@@ -1826,7 +1867,7 @@ execute_controller_action(struct xlate_ctx *ctx, int len,
 
     commit_odp_actions(&ctx->xin->flow, &ctx->base_flow,
                        &ctx->xout->odp_actions, &ctx->xout->wc,
-                       &ctx->mpls_depth_delta);
+                       &ctx->mpls_depth_delta, ctx->final_vlan_tci);
 
     odp_execute_actions(NULL, packet, &key, ctx->xout->odp_actions.data,
                         ctx->xout->odp_actions.size, NULL, NULL);
@@ -2214,7 +2255,7 @@ xlate_sample_action(struct xlate_ctx *ctx,
 
   commit_odp_actions(&ctx->xin->flow, &ctx->base_flow,
                      &ctx->xout->odp_actions, &ctx->xout->wc,
-                     &ctx->mpls_depth_delta);
+                     &ctx->mpls_depth_delta, ctx->final_vlan_tci);
 
   compose_flow_sample_cookie(os->probability, os->collector_set_id,
                              os->obs_domain_id, os->obs_point_id, &cookie);
@@ -2243,6 +2284,18 @@ may_receive(const struct xport *xport, struct xlate_ctx *ctx)
 }
 
 static void
+vlan_tci_restore(struct xlate_ctx *ctx, ovs_be16 orig_tci)
+{
+    /* If MPLS actions were executed after vlan actions then
+     * copy the final vlan_tci out and restore the intermediate VLAN state. */
+    if (ctx->xin->flow.vlan_tci != orig_tci &&
+        ctx->next_vlan_tci == &ctx->final_vlan_tci) {
+        ctx->final_vlan_tci = ctx->xin->flow.vlan_tci;
+        ctx->xin->flow.vlan_tci = orig_tci;
+    }
+}
+
+static void
 do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
                  struct xlate_ctx *ctx)
 {
@@ -2258,6 +2311,9 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
             break;
         }
 
+        /* Update the final vlan state to match the current state. */
+        ctx->final_vlan_tci = *ctx->next_vlan_tci;
+
         switch (a->type) {
         case OFPACT_OUTPUT:
             xlate_output_action(ctx, ofpact_get_OUTPUT(a)->port,
@@ -2281,28 +2337,28 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
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
-            wc->masks.vlan_tci |= htons(VLAN_PCP_MASK | VLAN_CFI);
-            flow->vlan_tci &= ~htons(VLAN_PCP_MASK);
-            flow->vlan_tci |=
+            wc->masks.vlan_tci |= htons(VLAN_VID_MASK | VLAN_CFI);
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
@@ -2370,29 +2426,54 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
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
+            ovs_be16 orig_tci = flow->vlan_tci;
             nxm_execute_reg_load(ofpact_get_REG_LOAD(a), flow);
+            vlan_tci_restore(ctx, orig_tci);
             break;
+        }
 
-        case OFPACT_STACK_PUSH:
+        case OFPACT_STACK_PUSH: {
+            ovs_be16 orig_tci = flow->vlan_tci;
+            flow->vlan_tci = *ctx->next_vlan_tci;
             nxm_execute_stack_push(ofpact_get_STACK_PUSH(a), flow, wc,
                                    &ctx->stack);
+            flow->vlan_tci = orig_tci;
             break;
+        }
 
-        case OFPACT_STACK_POP:
+        case OFPACT_STACK_POP: {
+            ovs_be16 orig_tci = flow->vlan_tci;
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
+            ctx->final_vlan_tci = *ctx->next_vlan_tci;
+            flow->vlan_tci = htons(0);
+            ctx->next_vlan_tci = &ctx->final_vlan_tci;
             break;
 
         case OFPACT_POP_MPLS:
@@ -2724,6 +2805,8 @@ xlate_actions(struct xlate_in *xin, struct xlate_out *xout)
     ctx.table_id = 0;
     ctx.exit = false;
     ctx.mpls_depth_delta = 0;
+    ctx.final_vlan_tci = ctx->xin->flow.vlan_tci;
+    ctx.next_vlan_tci = &ctx->xin->flow.vlan_tci;
 
     if (xin->ofpacts) {
         ofpacts = xin->ofpacts;
diff --git a/tests/ofproto-dpif.at b/tests/ofproto-dpif.at
index b706373..06d978a 100644
--- a/tests/ofproto-dpif.at
+++ b/tests/ofproto-dpif.at
@@ -869,6 +869,215 @@ done
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
+])
+AT_CHECK([ovs-ofctl --protocols=OpenFlow12 add-flows br0 flows.txt])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we see
+dnl both of these in the final flow
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:50,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([ovs-appctl -t ovs-ofctl exit])
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:50,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be stripped
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
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
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:51,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the MPLS tag before pushing a VLAN tag, so we see
+dnl both of these in the final flow
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:52,dst=52:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
+done
+OVS_WAIT_UNTIL([ovs-appctl -t ovs-ofctl exit])
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:52,dl_dst=52:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:52,dl_dst=52:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:52,dl_dst=52:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be stripped
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
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
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:53,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:53,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the VLAN tag before pushing a MPLS tag, but these
+dnl actions are reordered, so we see both of these in the final flow.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
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
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:54,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:54,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be stripped
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
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
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:55,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:55,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, we push the VLAN tag before pushing a MPLS tag, but these
+dnl actions are reordered, so we see both of these in the final flow.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
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
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:56,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:56,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS controller action.
+dnl In this test, the input packet in vlan-tagged, which should be stripped
+dnl before we push the MPLS and VLAN tags.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
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
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:57,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mpls,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:54:57,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=0,mpls_ttl=64,mpls_bos=1
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
