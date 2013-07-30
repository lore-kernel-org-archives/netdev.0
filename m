From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v16 2/4] Allow multiple levels of MPLS push and pop
Date: Tue, 30 Jul 2013 10:14:31 +0900
Message-ID: <1375146873-3192-3-git-send-email-horms@verge.net.au>
References: <1375146873-3192-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39570 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab3G3BPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 21:15:36 -0400
In-Reply-To: <1375146873-3192-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also:
* Remove mpls_depth from struct flow,
  This value really has not place in the flow which otherwise
  only knows about the top-most LSE.
  Instead track depth changes during execution.
* Allow MPLS pop to MPLS. That is, popping the top-most LSE of
  an MPLS stack of depth greater than one.

This patch relies on recirculation to update packets to allow
combinations of push and pop actions using a flow which only
knows about the top-most LSE.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

--

v16
* Separate controller and MPLS tests
  - MPLS adds a number of tests and there are already a number
    of controller tests. It seems to make sense to separate them.

v15
* No change

v14
* Recirculate on more than one pop otherwise intermediate eth type is lost
* Refactor commit_mpls_*actions to call commit_recirculate() directly,
  simplifying their caller.
* Fix compiler warnings

v13
* Rebase for megaflow changes: very extensive rebase

v12
* Ensure pre_push_mpls_lse is never used uninitialised in do_xlate_actions()

v11
* Include with recirculation patch-set

* Call peek_recirculation_id() in flow_miss_should_make_facet()
  regardless of dl_type as recirculation can occur on non-MPLS
  packets if there is more than one push_mpls action.
  As observed by Joe Stringer

v2 - v10
* Not posted
---
 lib/flow.c                   |   6 +-
 lib/flow.h                   |   9 +-
 lib/match.c                  |   2 +-
 lib/nx-match.c               |   2 +-
 lib/odp-util.c               |  52 +++---
 lib/odp-util.h               |   4 +-
 lib/ofp-actions.c            |   6 -
 lib/ofp-util.c               |   5 +-
 lib/packets.c                |  33 +---
 lib/packets.h                |   2 -
 ofproto/ofproto-dpif-xlate.c | 134 ++++++++++---
 tests/ofproto-dpif.at        | 433 ++++++++++++++++++++++++++++++++++++++++++-
 tests/test-bundle.c          |   1 -
 tests/test-multipath.c       |   1 -
 utilities/ovs-dpctl.c        |   2 +-
 utilities/ovs-ofctl.8.in     |  20 +-
 16 files changed, 581 insertions(+), 131 deletions(-)

diff --git a/lib/flow.c b/lib/flow.c
index 3dc4489..4521e00 100644
--- a/lib/flow.c
+++ b/lib/flow.c
@@ -97,9 +97,11 @@ static void
 parse_mpls(struct ofpbuf *b, struct flow *flow)
 {
     struct mpls_hdr *mh;
+    bool top = true;
 
     while ((mh = ofpbuf_try_pull(b, sizeof *mh))) {
-        if (flow->mpls_depth++ == 0) {
+        if (top) {
+            top = false;
             flow->mpls_lse = mh->mpls_lse;
         }
         if (mh->mpls_lse & htonl(MPLS_BOS_MASK)) {
@@ -493,7 +495,7 @@ flow_zero_wildcards(struct flow *flow, const struct flow_wildcards *wildcards)
 void
 flow_get_metadata(const struct flow *flow, struct flow_metadata *fmd)
 {
-    BUILD_ASSERT_DECL(FLOW_WC_SEQ == 20);
+    BUILD_ASSERT_DECL(FLOW_WC_SEQ == 21);
 
     fmd->tun_id = flow->tunnel.tun_id;
     fmd->tun_src = flow->tunnel.ip_src;
diff --git a/lib/flow.h b/lib/flow.h
index 55ccccf..fd3a9f1 100644
--- a/lib/flow.h
+++ b/lib/flow.h
@@ -36,7 +36,7 @@ struct ofpbuf;
 /* This sequence number should be incremented whenever anything involving flows
  * or the wildcarding of flows changes.  This will cause build assertion
  * failures in places which likely need to be updated. */
-#define FLOW_WC_SEQ 20
+#define FLOW_WC_SEQ 21
 
 #define FLOW_N_REGS 8
 BUILD_ASSERT_DECL(FLOW_N_REGS <= NXM_NX_MAX_REGS);
@@ -98,7 +98,6 @@ struct flow {
     union flow_in_port in_port; /* Input port.*/
     uint32_t skb_mark;          /* Packet mark. */
     ovs_be32 mpls_lse;          /* MPLS label stack entry. */
-    uint16_t mpls_depth;        /* Depth of MPLS stack. */
     ovs_be16 vlan_tci;          /* If 802.1Q, TCI | VLAN_CFI; otherwise 0. */
     ovs_be16 dl_type;           /* Ethernet frame type. */
     ovs_be16 tp_src;            /* TCP/UDP source port. */
@@ -111,15 +110,15 @@ struct flow {
     uint8_t arp_tha[6];         /* ARP/ND target hardware address. */
     uint8_t nw_ttl;             /* IP TTL/Hop Limit. */
     uint8_t nw_frag;            /* FLOW_FRAG_* flags. */
-    uint8_t zeros[6];
+    uint8_t zeros[0];
 };
 BUILD_ASSERT_DECL(sizeof(struct flow) % 4 == 0);
 
 #define FLOW_U32S (sizeof(struct flow) / 4)
 
 /* Remember to update FLOW_WC_SEQ when changing 'struct flow'. */
-BUILD_ASSERT_DECL(sizeof(struct flow) == sizeof(struct flow_tnl) + 160 &&
-                  FLOW_WC_SEQ == 20);
+BUILD_ASSERT_DECL(sizeof(struct flow) == sizeof(struct flow_tnl) + 152 &&
+                  FLOW_WC_SEQ == 21);
 
 /* Represents the metadata fields of struct flow. */
 struct flow_metadata {
diff --git a/lib/match.c b/lib/match.c
index 91c05a7..d979623 100644
--- a/lib/match.c
+++ b/lib/match.c
@@ -830,7 +830,7 @@ match_format(const struct match *match, struct ds *s, unsigned int priority)
 
     int i;
 
-    BUILD_ASSERT_DECL(FLOW_WC_SEQ == 20);
+    BUILD_ASSERT_DECL(FLOW_WC_SEQ == 21);
 
     if (priority != OFP_DEFAULT_PRIORITY) {
         ds_put_format(s, "priority=%u,", priority);
diff --git a/lib/nx-match.c b/lib/nx-match.c
index bdb3a2b..1481567 100644
--- a/lib/nx-match.c
+++ b/lib/nx-match.c
@@ -565,7 +565,7 @@ nx_put_raw(struct ofpbuf *b, bool oxm, const struct match *match,
     int match_len;
     int i;
 
-    BUILD_ASSERT_DECL(FLOW_WC_SEQ == 20);
+    BUILD_ASSERT_DECL(FLOW_WC_SEQ == 21);
 
     /* Metadata. */
     if (match->wc.masks.in_port.ofp_port) {
diff --git a/lib/odp-util.c b/lib/odp-util.c
index 1e40451..80ee34d 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -2421,9 +2421,7 @@ odp_flow_key_from_flow__(struct ofpbuf *buf, const struct flow *data,
         arp_key->arp_op = htons(data->nw_proto);
         memcpy(arp_key->arp_sha, data->arp_sha, ETH_ADDR_LEN);
         memcpy(arp_key->arp_tha, data->arp_tha, ETH_ADDR_LEN);
-    }
-
-    if (flow->mpls_depth) {
+    } else if (eth_type_mpls(flow->dl_type)) {
         struct ovs_key_mpls *mpls_key;
 
         mpls_key = nl_msg_put_unspec_uninit(buf, OVS_KEY_ATTR_MPLS,
@@ -2688,7 +2686,6 @@ parse_l2_5_onward(const struct nlattr *attrs[OVS_KEY_ATTR_MAX + 1],
             return ODP_FIT_TOO_LITTLE;
         }
         flow->mpls_lse = nl_attr_get_be32(attrs[OVS_KEY_ATTR_MPLS]);
-        flow->mpls_depth++;
     } else if (flow->dl_type == htons(ETH_TYPE_IP)) {
         expected_attrs |= UINT64_C(1) << OVS_KEY_ATTR_IPV4;
         if (present_attrs & (UINT64_C(1) << OVS_KEY_ATTR_IPV4)) {
@@ -3104,31 +3101,29 @@ commit_vlan_action(ovs_be16 vlan_tci, struct flow *base,
 
 static void
 commit_mpls_action(const struct flow *flow, struct flow *base,
-                   struct ofpbuf *odp_actions, struct flow_wildcards *wc)
+                   int *mpls_depth_delta, struct ofpbuf *odp_actions,
+                   struct flow_wildcards *wc)
 {
-    if (flow->mpls_lse == base->mpls_lse &&
-        flow->mpls_depth == base->mpls_depth) {
+    if (flow->mpls_lse == base->mpls_lse && !*mpls_depth_delta) {
         return;
     }
 
     memset(&wc->masks.mpls_lse, 0xff, sizeof wc->masks.mpls_lse);
 
-    if (flow->mpls_depth < base->mpls_depth) {
-        if (base->mpls_depth - flow->mpls_depth > 1) {
-            static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(10, 10);
-            VLOG_WARN_RL(&rl, "Multiple mpls_pop actions reduced to "
-                         " a single mpls_pop action");
-        }
-
-        nl_msg_put_be16(odp_actions, OVS_ACTION_ATTR_POP_MPLS, flow->dl_type);
-    } else if (flow->mpls_depth > base->mpls_depth) {
-        struct ovs_action_push_mpls *mpls;
+    if (*mpls_depth_delta == 0) {
+        struct ovs_key_mpls mpls_key;
 
-        if (flow->mpls_depth - base->mpls_depth > 1) {
-            static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(10, 10);
-            VLOG_WARN_RL(&rl, "Multiple mpls_push actions reduced to "
-                         " a single mpls_push action");
+        mpls_key.mpls_lse = flow->mpls_lse;
+        commit_set_action(odp_actions, OVS_KEY_ATTR_MPLS,
+                          &mpls_key, sizeof(mpls_key));
+    } else if (*mpls_depth_delta == -1) {
+        int i;
+        for (i = *mpls_depth_delta; i < 0; i ++) {
+            nl_msg_put_be16(odp_actions, OVS_ACTION_ATTR_POP_MPLS,
+                            flow->dl_type);
         }
+    } else if (*mpls_depth_delta == 1) {
+        struct ovs_action_push_mpls *mpls;
 
         mpls = nl_msg_put_unspec_uninit(odp_actions, OVS_ACTION_ATTR_PUSH_MPLS,
                                         sizeof *mpls);
@@ -3136,16 +3131,13 @@ commit_mpls_action(const struct flow *flow, struct flow *base,
         mpls->mpls_ethertype = flow->dl_type;
         mpls->mpls_lse = flow->mpls_lse;
     } else {
-        struct ovs_key_mpls mpls_key;
-
-        mpls_key.mpls_lse = flow->mpls_lse;
-        commit_set_action(odp_actions, OVS_KEY_ATTR_MPLS,
-                          &mpls_key, sizeof(mpls_key));
+        /* Recirculation must occur for more than one push */
+        NOT_REACHED();
     }
 
     base->dl_type = flow->dl_type;
     base->mpls_lse = flow->mpls_lse;
-    base->mpls_depth = flow->mpls_depth;
+    *mpls_depth_delta = 0;
 }
 
 static void
@@ -3312,8 +3304,8 @@ commit_set_skb_mark_action(const struct flow *flow, struct flow *base,
  * differs from 'flow->vlan_tci', it is committed afterwards. */
 void
 commit_odp_actions(const struct flow *flow, struct flow *base,
-                   struct ofpbuf *odp_actions, struct flow_wildcards *wc,
-                   ovs_be16 final_vlan_tci)
+                   int *mpls_depth_delta, struct ofpbuf *odp_actions,
+                   struct flow_wildcards *wc, ovs_be16 final_vlan_tci)
 {
     commit_set_ether_addr_action(flow, base, odp_actions, wc);
     commit_vlan_action(flow->vlan_tci, base, odp_actions, wc);
@@ -3323,7 +3315,7 @@ commit_odp_actions(const struct flow *flow, struct flow *base,
      * actions. This is because committing MPLS actions may alter a packet so
      * that it is no longer IP and thus nw and port actions are no longer valid.
      */
-    commit_mpls_action(flow, base, odp_actions, wc);
+    commit_mpls_action(flow, base, mpls_depth_delta, odp_actions, wc);
     commit_vlan_action(final_vlan_tci, base, odp_actions, wc);
     commit_set_priority_action(flow, base, odp_actions, wc);
     commit_set_skb_mark_action(flow, base, odp_actions, wc);
diff --git a/lib/odp-util.h b/lib/odp-util.h
index 6b3977f..6f72517 100644
--- a/lib/odp-util.h
+++ b/lib/odp-util.h
@@ -128,8 +128,8 @@ void commit_odp_tunnel_action(const struct flow *, struct flow *base,
                               struct ofpbuf *odp_actions);
 void commit_odp_recirculate_action(struct ofpbuf *odp_actions);
 void commit_odp_actions(const struct flow *, struct flow *base,
-                        struct ofpbuf *odp_actions, struct flow_wildcards *wc,
-                        ovs_be16 final_vlan_tci);
+                        int *mpls_depth_delta, struct ofpbuf *odp_actions,
+                        struct flow_wildcards *wc, ovs_be16 final_vlan_tci);
 
 /* ofproto-dpif interface.
  *
diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
index 454b9a1..5111a23 100644
--- a/lib/ofp-actions.c
+++ b/lib/ofp-actions.c
@@ -450,9 +450,6 @@ ofpact_from_nxast(const union ofp_action *a, enum ofputil_action_code code,
 
     case OFPUTIL_NXAST_POP_MPLS: {
         struct nx_action_pop_mpls *nxapm = (struct nx_action_pop_mpls *)a;
-        if (eth_type_mpls(nxapm->ethertype)) {
-            return OFPERR_OFPBAC_BAD_ARGUMENT;
-        }
         ofpact_put_POP_MPLS(out)->ethertype = nxapm->ethertype;
         break;
     }
@@ -856,9 +853,6 @@ ofpact_from_openflow11(const union ofp_action *a, struct ofpbuf *out)
 
     case OFPUTIL_OFPAT11_POP_MPLS: {
         struct ofp11_action_pop_mpls *oapm = (struct ofp11_action_pop_mpls *)a;
-        if (eth_type_mpls(oapm->ethertype)) {
-            return OFPERR_OFPBAC_BAD_ARGUMENT;
-        }
         ofpact_put_POP_MPLS(out)->ethertype = oapm->ethertype;
         break;
     }
diff --git a/lib/ofp-util.c b/lib/ofp-util.c
index 9d3bcb7..c1d5051 100644
--- a/lib/ofp-util.c
+++ b/lib/ofp-util.c
@@ -84,7 +84,7 @@ ofputil_netmask_to_wcbits(ovs_be32 netmask)
 void
 ofputil_wildcard_from_ofpfw10(uint32_t ofpfw, struct flow_wildcards *wc)
 {
-    BUILD_ASSERT_DECL(FLOW_WC_SEQ == 20);
+    BUILD_ASSERT_DECL(FLOW_WC_SEQ == 21);
 
     /* Initialize most of wc. */
     flow_wildcards_init_catchall(wc);
@@ -1126,7 +1126,7 @@ ofputil_usable_protocols(const struct match *match)
 {
     const struct flow_wildcards *wc = &match->wc;
 
-    BUILD_ASSERT_DECL(FLOW_WC_SEQ == 20);
+    BUILD_ASSERT_DECL(FLOW_WC_SEQ == 21);
 
     /* These tunnel params can't be sent in a flow_mod */
     if (wc->masks.tunnel.ip_ttl
@@ -4882,7 +4882,6 @@ ofputil_normalize_match__(struct match *match, bool may_log)
     }
     if (!(may_match & MAY_MPLS)) {
         wc.masks.mpls_lse = htonl(0);
-        wc.masks.mpls_depth = 0;
     }
 
     /* Log any changes. */
diff --git a/lib/packets.c b/lib/packets.c
index 54a3b20..ad2c7c1 100644
--- a/lib/packets.c
+++ b/lib/packets.c
@@ -216,32 +216,6 @@ eth_pop_vlan(struct ofpbuf *packet)
     }
 }
 
-/* Return depth of mpls stack.
- *
- * 'packet->l2_5' should initially point to 'packet''s outer-most MPLS header
- * or may be NULL if there are no MPLS headers. */
-uint16_t
-eth_mpls_depth(const struct ofpbuf *packet)
-{
-    struct mpls_hdr *mh = packet->l2_5;
-    uint16_t depth;
-
-    if (!mh) {
-        return 0;
-    }
-
-    depth = 0;
-    while (packet->size >= ((char *)mh - (char *)packet->data) + sizeof *mh) {
-        depth++;
-        if (mh->mpls_lse & htonl(MPLS_BOS_MASK)) {
-            break;
-        }
-        mh++;
-    }
-
-    return depth;
-}
-
 /* Set ethertype of the packet. */
 void
 set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type, bool inner)
@@ -350,13 +324,10 @@ push_mpls(struct ofpbuf *packet, ovs_be16 ethtype, ovs_be32 lse)
 {
     struct mpls_hdr mh;
 
-    if (!eth_type_mpls(ethtype)) {
-        return;
-    }
+    set_ethertype(packet, ethtype, false);
 
     if (!is_mpls(packet)) {
-        /* Set ethtype and MPLS label stack entry. */
-        set_ethertype(packet, ethtype, false);
+        /* Set MPLS label stack entry. */
         packet->l2_5 = (char*)packet->l2 + ETH_HEADER_LEN;
     }
 
diff --git a/lib/packets.h b/lib/packets.h
index 923fd53..23471b5 100644
--- a/lib/packets.h
+++ b/lib/packets.h
@@ -140,8 +140,6 @@ void compose_rarp(struct ofpbuf *, const uint8_t eth_src[ETH_ADDR_LEN]);
 void eth_push_vlan(struct ofpbuf *, ovs_be16 tci);
 void eth_pop_vlan(struct ofpbuf *);
 
-uint16_t eth_mpls_depth(const struct ofpbuf *packet);
-
 void set_ethertype(struct ofpbuf *packet, ovs_be16 eth_type, bool inner);
 
 const char *eth_from_hex(const char *hex, struct ofpbuf **packetp);
diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
index c9145b5..6bd163d 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -152,6 +152,13 @@ struct xlate_ctx {
                                  * offset into ofpacts for calls to
                                  * xlate_actions on recirculated packets */
 
+
+    int mpls_depth_delta;       /* Delta of the mpls stack depth since
+                                 * actions were last committed.
+                                 * Must be between -1 and 1 inclusive.
+                                 * Multiple push/pop actions
+                                 * are handled using recirculation */
+
     int recurse;                /* Recursion level, via xlate_table_action. */
     bool max_resubmit_trigger;  /* Recursed too deeply during translation. */
     uint32_t orig_skb_priority; /* Priority when packet arrived. */
@@ -1245,7 +1252,7 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
 
     /* If 'struct flow' gets additional metadata, we'll need to zero it out
      * before traversing a patch port. */
-    BUILD_ASSERT_DECL(FLOW_WC_SEQ == 20);
+    BUILD_ASSERT_DECL(FLOW_WC_SEQ == 21);
 
     if (!xport) {
         xlate_report(ctx, "Nonexistent output port");
@@ -1359,8 +1366,9 @@ compose_output_action__(struct xlate_ctx *ctx, ofp_port_t ofp_port,
     }
 
     if (out_port != ODPP_NONE) {
-        commit_odp_actions(flow, &ctx->base_flow, &ctx->xout->odp_actions,
-                           &ctx->xout->wc, ctx->xin->vlan_tci);
+        commit_odp_actions(flow, &ctx->base_flow, &ctx->mpls_depth_delta,
+                           &ctx->xout->odp_actions,  &ctx->xout->wc,
+                           ctx->xin->vlan_tci);
         nl_msg_put_odp_port(&ctx->xout->odp_actions, OVS_ACTION_ATTR_OUTPUT,
                             out_port);
 
@@ -1516,8 +1524,8 @@ execute_controller_action(struct xlate_ctx *ctx, int len,
     memset(&key.tunnel, 0, sizeof key.tunnel);
 
     commit_odp_actions(&ctx->xin->flow, &ctx->base_flow,
-                       &ctx->xout->odp_actions, &ctx->xout->wc,
-                       ctx->xin->vlan_tci);
+                       &ctx->mpls_depth_delta, &ctx->xout->odp_actions,
+                       &ctx->xout->wc, ctx->xin->vlan_tci);
 
     odp_execute_actions(NULL, packet, &key, ctx->xout->odp_actions.data,
                         ctx->xout->odp_actions.size, NULL, NULL);
@@ -1554,20 +1562,41 @@ compose_recirculate_action(struct xlate_ctx *ctx)
     memset(&wc->masks.skb_mark, 0xff, sizeof wc->masks.skb_mark);
 }
 
-static void
-compose_mpls_push_action(struct xlate_ctx *ctx, ovs_be16 eth_type)
+static bool
+compose_mpls_push_action(struct xlate_ctx *ctx, ovs_be16 eth_type,
+                         ovs_be32 *pre_push_mpls_lse)
 {
     struct flow_wildcards *wc = &ctx->xout->wc;
     struct flow *flow = &ctx->xin->flow;
 
     ovs_assert(eth_type_mpls(eth_type));
 
+    /* If mpls_depth_delta is negative then an MPLS POP action has been
+     * composed and the resulting MPLS label stack is unknown.  This means
+     * an MPLS PUSH action can't be composed as it needs to know either the
+     * top-most MPLS LSE to use as a template for the new MPLS LSE, or that
+     * there is no MPLS label stack present.  Thus, recirculate.
+     *
+     * If mpls_depth_delta is positive then an MPLS PUSH action has been
+     * composed. Recirculate to effect that MPLS PUSH action before adding
+     * another MPLS PUSH action as as there is only one MPLS LSE and
+     * ether type in the flow.
+     *
+     * If the MPLS LSE of the flow and base_flow differ then the MPLS LSE
+     * has been updated.  Recirculate to effect the updates before adding
+     * an MPLS PUSH action as there is only one MPLS LSE in the flow. */
+    if (ctx->mpls_depth_delta ||
+        ctx->xin->flow.mpls_lse != ctx->base_flow.mpls_lse) {
+        compose_recirculate_action(ctx);
+        return true;
+    }
+
     memset(&wc->masks.mpls_lse, 0xff, sizeof wc->masks.mpls_lse);
-    memset(&wc->masks.mpls_depth, 0xff, sizeof wc->masks.mpls_depth);
 
-    if (flow->mpls_depth) {
+    *pre_push_mpls_lse = ctx->xin->flow.mpls_lse;
+
+    if (eth_type_mpls(ctx->xin->flow.dl_type)) {
         flow->mpls_lse &= ~htonl(MPLS_BOS_MASK);
-        flow->mpls_depth++;
     } else {
         ovs_be32 label;
         uint8_t tc, ttl;
@@ -1582,30 +1611,48 @@ compose_mpls_push_action(struct xlate_ctx *ctx, ovs_be16 eth_type)
         tc = (flow->nw_tos & IP_DSCP_MASK) >> 2;
         ttl = flow->nw_ttl ? flow->nw_ttl : 0x40;
         flow->mpls_lse = set_mpls_lse_values(ttl, tc, 1, label);
-        flow->mpls_depth = 1;
     }
     flow->dl_type = eth_type;
+    ctx->mpls_depth_delta++;
+
+    return false;
 }
 
-static void
-compose_mpls_pop_action(struct xlate_ctx *ctx, ovs_be16 eth_type)
+static bool
+compose_mpls_pop_action(struct xlate_ctx *ctx, ovs_be16 eth_type,
+                        ovs_be32 pre_push_mpls_lse)
 {
     struct flow_wildcards *wc = &ctx->xout->wc;
-    struct flow *flow = &ctx->xin->flow;
 
-    ovs_assert(eth_type_mpls(ctx->xin->flow.dl_type));
-    ovs_assert(!eth_type_mpls(eth_type));
+    /* Stop processing if there is no MPLS label stack to pop */
+    if (!eth_type_mpls(ctx->xin->flow.dl_type)) {
+        return true;
+    }
+
+    /* If mpls_depth_delta is negative then an MPLS POP action has been
+     * composed.  Recirculate to effect that MPLS POP action before adding
+     * another MPLS POP action as as there is only one ether type in the
+     * flow. */
+    if (ctx->mpls_depth_delta < 0) {
+        compose_recirculate_action(ctx);
+        return true;
+    }
 
     memset(&wc->masks.mpls_lse, 0xff, sizeof wc->masks.mpls_lse);
-    memset(&wc->masks.mpls_depth, 0xff, sizeof wc->masks.mpls_depth);
 
-    if (flow->mpls_depth) {
-        flow->mpls_depth--;
-        flow->mpls_lse = htonl(0);
-        if (!flow->mpls_depth) {
-            flow->dl_type = eth_type;
-        }
+    /* If mpls_depth_delta is positive then an MPLS PUSH action has been
+     * executed and the previous MPLS LSE saved in pre_push_mpls_lse. The
+     * flow's MPLS LSE should be restored to that value to allow any
+     * subsequent actions that update of the LSE to be executed correctly.
+     */
+    if (ctx->mpls_depth_delta > 0) {
+        ctx->xin->flow.mpls_lse = pre_push_mpls_lse;
     }
+
+    ctx->xin->flow.dl_type = eth_type;
+    ctx->mpls_depth_delta--;
+
+    return false;
 }
 
 static bool
@@ -1637,6 +1684,15 @@ compose_dec_ttl(struct xlate_ctx *ctx, struct ofpact_cnt_ids *ids)
 static bool
 compose_set_mpls_ttl_action(struct xlate_ctx *ctx, uint8_t ttl)
 {
+    /* If mpls_depth_delta is negative then an MPLS POP action has been
+     * executed and the resulting MPLS label stack is unknown.  This means
+     * a SET MPLS TTL push action can't be executed as it needs to manipulate
+     * the top-most MPLS LSE. Thus, recirculate. */
+    if (ctx->mpls_depth_delta < 0) {
+        compose_recirculate_action(ctx);
+        return true;
+    }
+
     if (!eth_type_mpls(ctx->xin->flow.dl_type)) {
         return true;
     }
@@ -1652,6 +1708,15 @@ compose_dec_mpls_ttl_action(struct xlate_ctx *ctx)
     uint8_t ttl = mpls_lse_to_ttl(flow->mpls_lse);
     struct flow_wildcards *wc = &ctx->xout->wc;
 
+    /* If mpls_depth_delta is negative then an MPLS POP action has been
+     * executed and the resulting MPLS label stack is unknown.  This means
+     * a DEC MPLS TTL push action can't be executed as it needs to manipulate
+     * the top-most MPLS LSE. Thus, recirculate. */
+    if (ctx->mpls_depth_delta < 0) {
+        compose_recirculate_action(ctx);
+        return true;
+    }
+
     memset(&wc->masks.mpls_lse, 0xff, sizeof wc->masks.mpls_lse);
 
     if (!eth_type_mpls(flow->dl_type)) {
@@ -1891,7 +1956,8 @@ xlate_sample_action(struct xlate_ctx *ctx,
    * the same percentage. */
   uint32_t probability = (os->probability << 16) | os->probability;
 
-  commit_odp_actions(&ctx->xin->flow, &ctx->base_flow, &ctx->xout->odp_actions,
+  commit_odp_actions(&ctx->xin->flow, &ctx->base_flow,
+                     &ctx->mpls_depth_delta, &ctx->xout->odp_actions,
                      &ctx->xout->wc, ctx->xin->vlan_tci);
 
   compose_flow_sample_cookie(os->probability, os->collector_set_id,
@@ -1966,6 +2032,7 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
     bool was_evictable = true;
     bool may_xlate_l3_actions = true;
     const struct ofpact *a;
+    ovs_be32 pre_push_mpls_lse = ctx->xin->flow.mpls_lse;
 
     if (ctx->rule) {
         /* Don't let the rule we're working on get evicted underneath us. */
@@ -2155,7 +2222,11 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
         }
 
         case OFPACT_PUSH_MPLS:
-            compose_mpls_push_action(ctx, ofpact_get_PUSH_MPLS(a)->ethertype);
+            if (compose_mpls_push_action(ctx,
+                                         ofpact_get_PUSH_MPLS(a)->ethertype,
+                                         &pre_push_mpls_lse)) {
+                goto out;
+            }
 
             /* Save and pop any existing VLAN tags if running in OF1.2 mode. */
             ctx->xin->vlan_tci = *vlan_tci;
@@ -2167,11 +2238,12 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
             break;
 
         case OFPACT_POP_MPLS:
-            compose_mpls_pop_action(ctx, ofpact_get_POP_MPLS(a)->ethertype);
-            if (ctx->xin->flow.dl_type == htons(ETH_TYPE_IP) ||
-                ctx->xin->flow.dl_type == htons(ETH_TYPE_IPV6)) {
-                may_xlate_l3_actions = false;
+            if (compose_mpls_pop_action(ctx,
+                                        ofpact_get_POP_MPLS(a)->ethertype,
+                                        pre_push_mpls_lse)) {
+                goto out;
             }
+            may_xlate_l3_actions = false;
             break;
 
         case OFPACT_SET_MPLS_TTL:
@@ -2201,11 +2273,11 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
             break;
 
         case OFPACT_MULTIPATH:
-            multipath_execute(ofpact_get_MULTIPATH(a), flow, wc);
             if (!may_xlate_l3_actions) {
                 compose_recirculate_action(ctx);
                 goto out;
             }
+            multipath_execute(ofpact_get_MULTIPATH(a), flow, wc);
             break;
 
         case OFPACT_BUNDLE:
@@ -2490,6 +2562,7 @@ xlate_actions(struct xlate_in *xin, struct xlate_out *xout)
     ctx.orig_skb_priority = flow->skb_priority;
     ctx.table_id = 0;
     ctx.exit = false;
+    ctx.mpls_depth_delta = 0;
 
     if (xin->ofpacts) {
         ofpacts = xin->ofpacts;
@@ -2555,6 +2628,7 @@ xlate_actions(struct xlate_in *xin, struct xlate_out *xout)
             do_xlate_actions(ofpacts, ofpacts_len, &ctx);
             if (ctx.xin->recirculated) {
                 commit_odp_actions(&ctx.xin->flow, &ctx.base_flow,
+                                   &ctx.mpls_depth_delta,
                                    &ctx.xout->odp_actions, &ctx.xout->wc,
                                    ctx.xin->vlan_tci);
                 commit_odp_recirculate_action(&ctx.xout->odp_actions);
diff --git a/tests/ofproto-dpif.at b/tests/ofproto-dpif.at
index 5bf157d..dded496 100644
--- a/tests/ofproto-dpif.at
+++ b/tests/ofproto-dpif.at
@@ -530,6 +530,8 @@ cookie=0xa dl_src=40:44:44:44:44:45 actions=push_mpls:0x8847,load:10->OXM_OF_MPL
 cookie=0xa dl_src=40:44:44:44:44:46 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],set_mpls_ttl(10),controller
 cookie=0xa dl_src=40:44:44:44:44:47 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],dec_mpls_ttl,set_mpls_ttl(10),controller
 cookie=0xa dl_src=40:44:44:44:44:48 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],set_mpls_ttl(10),dec_mpls_ttl,controller
+cookie=0xa mpls,dl_src=40:44:44:44:44:49 actions=push_mpls:0x8848,CONTROLLER:65535
+
 cookie=0xd dl_src=60:66:66:66:00:01 actions=pop_mpls:0x0800,dec_ttl,controller
 cookie=0xd dl_src=60:66:66:66:00:02 actions=pop_mpls:0x0800,load:0xa000001->OXM_OF_IPV4_DST[[]],controller
 cookie=0xd dl_src=60:66:66:66:00:03 actions=pop_mpls:0x0800,move:OXM_OF_IPV4_DST[[]]->OXM_OF_IPV4_SRC[[]],controller
@@ -537,6 +539,26 @@ cookie=0xd dl_src=60:66:66:66:00:04 actions=pop_mpls:0x0800,push:OXM_OF_IPV4_DST
 cookie=0xd dl_src=60:66:66:66:00:05 actions=pop_mpls:0x0800,multipath(eth_src,50,modulo_n,256,0,OXM_OF_IPV4_SRC[[0..7]]),controller
 cookie=0xd dl_src=60:66:66:66:00:06 actions=pop_mpls:0x0800,bundle_load(eth_src,50,hrw,ofport,OXM_OF_IPV4_SRC[[0..15]],slaves:1,2),controller
 cookie=0xd dl_src=60:66:66:66:00:07 actions=pop_mpls:0x0800,learn(table=1,hard_timeout=60,eth_type=0x800,nw_proto=6,OXM_OF_IPV4_SRC[[]]=OXM_OF_IPV4_DST[[]]),controller
+
+cookie=0xd dl_src=60:66:66:66:01:00 actions=pop_mpls:0x8848,controller
+cookie=0xd dl_src=60:66:66:66:01:01 actions=pop_mpls:0x8847,dec_mpls_ttl,controller
+cookie=0xd dl_src=60:66:66:66:01:02 actions=pop_mpls:0x8848,load:3->OXM_OF_MPLS_TC[[]],controller
+
+cookie=0xd dl_src=60:66:66:66:02:00 actions=pop_mpls:0x8847,pop_mpls:0x0800,controller
+cookie=0xd dl_src=60:66:66:66:02:01 actions=pop_mpls:0x8848,pop_mpls:0x0800,dec_ttl,controller
+cookie=0xd dl_src=60:66:66:66:02:10 actions=pop_mpls:0x8847,dec_mpls_ttl,pop_mpls:0x0800,dec_ttl,controller
+
+cookie=0xd dl_src=60:66:66:66:03:00 actions=pop_mpls:0x8848,pop_mpls:0x8848,controller
+cookie=0xd dl_src=60:66:66:66:03:01 actions=pop_mpls:0x8847,pop_mpls:0x8847,dec_mpls_ttl,controller
+cookie=0xd dl_src=60:66:66:66:03:10 actions=pop_mpls:0x8848,dec_mpls_ttl,pop_mpls:0x8848,dec_mpls_ttl,controller
+
+cookie=0xd dl_src=60:66:66:66:04:00 actions=pop_mpls:0x0800,push_mpls:0x8847,controller
+cookie=0xd dl_src=60:66:66:66:04:01 actions=pop_mpls:0x0800,push_mpls:0x8848,dec_mpls_ttl,controller
+cookie=0xd dl_src=60:66:66:66:04:10 actions=pop_mpls:0x0800,dec_ttl,push_mpls:0x8848,dec_mpls_ttl,controller
+
+cookie=0xd dl_src=60:66:66:66:05:00 actions=push_mpls:0x8848,pop_mpls:0x8847,controller
+cookie=0xd dl_src=60:66:66:66:05:01 actions=push_mpls:0x8847,pop_mpls:0x8848,dec_mpls_ttl,controller
+cookie=0xd dl_src=60:66:66:66:05:10 actions=push_mpls:0x8848,dec_mpls_ttl,pop_mpls:0x8847,dec_mpls_ttl,controller
 ])
 AT_CHECK([ovs-ofctl add-flows br0 flows.txt])
 
@@ -570,7 +592,6 @@ for i in 1 2 3; do
 done
 OVS_WAIT_UNTIL([ovs-appctl -t ovs-ofctl exit])
 AT_CHECK([cat ofctl_monitor.log], [0], [dnl
-
 NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
 mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:44:43,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=0
 dnl
@@ -681,6 +702,26 @@ NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len
 mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:44:48,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=9,mpls_bos=1
 ])
 
+dnl Modified MPLS controller action.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:44:49,dst=50:54:00:00:00:07),eth_type(0x8847),mpls(label=10,tc=3,ttl=64,bos=1)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:44:49,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=0
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:44:49,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=0
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:44:49,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=0
+])
+
 dnl Modified MPLS pop action.
 dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
 dnl 60:66:66:66:00:01 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8847), length 62: MPLS (label 20, exp 0, [S], ttl 32)
@@ -849,7 +890,379 @@ NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len
 tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:07,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7744
 ])
 
-AT_CHECK([ovs-appctl time/warp 10000], [0], [ignore])
+dnl Modified MPLS pop action.
+dnl The input is a frame with two MPLS label stack entries which tcpdump -vve shows as:
+dnl 60:66:66:66:01:00 > 50:54:00:00:00:07, ethertype MPLS multicast (0x8848), length 66: MPLS (label 20, exp 0, ttl 32)
+dnl		(label 20, exp 0, [S], ttl 31)
+dnl		(tos 0x0, ttl 254, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl        192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x7744 (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 01 00 88 48 00 01 40 20 00 01 41 1f 45 00 00 2c 00 00 00 00 ff 06 3b 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:01:00,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=31,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:01:00,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=31,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:01:00,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=31,mpls_bos=1
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with two MPLS label stack entries which tcpdump -vve shows as:
+dnl 60:66:66:66:01:01 > 50:54:00:00:00:07, ethertype MPLS multicast (0x8847), length 66: MPLS (label 20, exp 0, ttl 32)
+dnl		(label 20, exp 0, [S], ttl 31)
+dnl		(tos 0x0, ttl 254, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl        192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x7744 (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 01 01 88 47 00 01 40 20 00 01 41 1f 45 00 00 2c 00 00 00 00 ff 06 3b 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:01:01,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=30,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:01:01,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=30,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:01:01,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=30,mpls_bos=1
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with two MPLS label stack entries which tcpdump -vve shows as:
+dnl 60:66:66:66:01:02 > 50:54:00:00:00:07, ethertype MPLS multicast (0x8848), length 66: MPLS (label 20, exp 0, ttl 32)
+dnl		(label 20, exp 0, [S], ttl 31)
+dnl		(tos 0x0, ttl 254, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl        192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x7744 (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 01 02 88 48 00 01 40 20 00 01 41 1f 45 00 00 2c 00 00 00 00 ff 06 3b 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:01:02,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=3,mpls_ttl=31,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:01:02,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=3,mpls_ttl=31,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:01:02,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=3,mpls_ttl=31,mpls_bos=1
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with two MPLS label stack entries which tcpdump -vve shows as:
+dnl 60:66:66:66:01:01 > 50:54:00:00:02:00, ethertype MPLS multicast (0x8847), length 66: MPLS (label 20, exp 0, ttl 32)
+dnl		(label 20, exp 0, [S], ttl 31)
+dnl		(tos 0x0, ttl 254, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl        192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x7744 (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 02 00 88 47 00 01 40 20 00 01 41 1f 45 00 00 2c 00 00 00 00 ff 06 3b 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:02:00,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7744
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:02:00,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7744
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:02:00,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7744
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with two MPLS label stack entries which tcpdump -vve shows as:
+dnl 60:66:66:66:01:01 > 50:54:00:00:02:01, ethertype MPLS multicast (0x8848), length 66: MPLS (label 20, exp 0, ttl 32)
+dnl		(label 20, exp 0, [S], ttl 31)
+dnl		(tos 0x0, ttl 254, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl        192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x7744 (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 02 01 88 48 00 01 40 20 00 01 41 1f 45 00 00 2c 00 00 00 00 ff 06 3b 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:02:01,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=254,tp_src=80,tp_dst=0 tcp_csum:7744
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:02:01,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=254,tp_src=80,tp_dst=0 tcp_csum:7744
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:02:01,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=254,tp_src=80,tp_dst=0 tcp_csum:7744
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with two MPLS label stack entries which tcpdump -vve shows as:
+dnl 60:66:66:66:01:01 > 50:54:00:00:02:10, ethertype MPLS multicast (0x8847), length 66: MPLS (label 20, exp 0, ttl 32)
+dnl		(label 20, exp 0, [S], ttl 31)
+dnl		(tos 0x0, ttl 254, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl        192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x7744 (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 02 10 88 47 00 01 40 20 00 01 41 1f 45 00 00 2c 00 00 00 00 ff 06 3b 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:02:10,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=254,tp_src=80,tp_dst=0 tcp_csum:7744
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:02:10,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=254,tp_src=80,tp_dst=0 tcp_csum:7744
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:02:10,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=254,tp_src=80,tp_dst=0 tcp_csum:7744
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with three MPLS label stack entries which tcpdump -vve shows as:
+dnl 60:66:66:66:03:00 > 50:54:00:00:00:00, ethertype MPLS multicast (0x8847), length 66: MPLS (label 20, exp 0, ttl 32)
+dnl		(label 20, exp 0, ttl 31)
+dnl		(label 20, exp 0, [S], ttl 30)
+dnl		(tos 0x0, ttl 254, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl        192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x7744 (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 03 00 88 47 00 01 40 20 00 01 40 1f 00 01 41 1e 45 00 00 2c 00 00 00 00 ff 06 3b 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:03:00,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=30,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:03:00,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=30,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:03:00,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=30,mpls_bos=1
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with three MPLS label stack entries which tcpdump -vve shows as:
+dnl 60:66:66:66:03:01 > 50:54:00:00:00:00, ethertype MPLS multicast (0x8848), length 66: MPLS (label 20, exp 0, ttl 32)
+dnl		(label 20, exp 0, ttl 31)
+dnl		(label 20, exp 0, [S], ttl 30)
+dnl		(tos 0x0, ttl 254, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl        192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x7744 (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 03 01 88 48 00 01 40 20 00 01 40 1f 00 01 41 1e 45 00 00 2c 00 00 00 00 ff 06 3b 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:03:01,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=29,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:03:01,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=29,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:03:01,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=29,mpls_bos=1
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with three MPLS label stack entries which tcpdump -vve shows as:
+dnl 60:66:66:66:03:10 > 50:54:00:00:00:00, ethertype MPLS multicast (0x8847), length 66: MPLS (label 20, exp 0, ttl 32)
+dnl		(label 20, exp 0, ttl 31)
+dnl		(label 20, exp 0, [S], ttl 30)
+dnl		(tos 0x0, ttl 254, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl        192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x7744 (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 03 10 88 47 00 01 40 20 00 01 40 1f 00 01 41 1e 45 00 00 2c 00 00 00 00 ff 06 3b 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:03:10,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=29,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:03:10,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=29,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:03:10,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=29,mpls_bos=1
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:04:00 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8848), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 04 00 88 48 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:04:00,dl_dst=50:54:00:00:00:07,mpls_label=0,mpls_tc=0,mpls_ttl=255,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:04:00,dl_dst=50:54:00:00:00:07,mpls_label=0,mpls_tc=0,mpls_ttl=255,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:04:00,dl_dst=50:54:00:00:00:07,mpls_label=0,mpls_tc=0,mpls_ttl=255,mpls_bos=1
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:04:01 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8847), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 04 01 88 47 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:04:01,dl_dst=50:54:00:00:00:07,mpls_label=0,mpls_tc=0,mpls_ttl=254,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:04:01,dl_dst=50:54:00:00:00:07,mpls_label=0,mpls_tc=0,mpls_ttl=254,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:04:01,dl_dst=50:54:00:00:00:07,mpls_label=0,mpls_tc=0,mpls_ttl=254,mpls_bos=1
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:04:10 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8848), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 04 10 88 48 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:04:10,dl_dst=50:54:00:00:00:07,mpls_label=0,mpls_tc=0,mpls_ttl=253,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:04:10,dl_dst=50:54:00:00:00:07,mpls_label=0,mpls_tc=0,mpls_ttl=253,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:04:10,dl_dst=50:54:00:00:00:07,mpls_label=0,mpls_tc=0,mpls_ttl=253,mpls_bos=1
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:05:00 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8847), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 05 00 88 47 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:05:00,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=32,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:05:00,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=32,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:05:00,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=32,mpls_bos=1
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:05:01 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8848), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 05 01 88 48 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:05:01,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=31,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:05:01,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=31,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:05:01,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=31,mpls_bos=1
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:05:10 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8847), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 05 10 88 47 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:05:10,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=31,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:05:10,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=31,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=62 in_port=1 (via action) data_len=62 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:05:10,dl_dst=50:54:00:00:00:07,mpls_label=20,mpls_tc=0,mpls_ttl=31,mpls_bos=1
+])
+
+AT_CHECK([ovs-appctl time/warp 5000], [0], [ignore])
 AT_CHECK([ovs-ofctl dump-flows br0 | ofctl_strip | sort], [0], [dnl
  cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:42 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
  cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:43 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
@@ -858,6 +1271,7 @@ AT_CHECK([ovs-ofctl dump-flows br0 | ofctl_strip | sort], [0], [dnl
  cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:46 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],set_mpls_ttl(10),CONTROLLER:65535
  cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:47 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],dec_mpls_ttl,set_mpls_ttl(10),CONTROLLER:65535
  cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:48 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],set_mpls_ttl(10),dec_mpls_ttl,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, mpls,dl_src=40:44:44:44:44:49 actions=push_mpls:0x8848,CONTROLLER:65535
  cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:01 actions=pop_mpls:0x0800,dec_ttl(0),CONTROLLER:65535
  cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:02 actions=pop_mpls:0x0800,load:0xa000001->NXM_OF_IP_DST[[]],CONTROLLER:65535
  cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:03 actions=pop_mpls:0x0800,move:NXM_OF_IP_DST[[]]->NXM_OF_IP_SRC[[]],CONTROLLER:65535
@@ -865,6 +1279,21 @@ AT_CHECK([ovs-ofctl dump-flows br0 | ofctl_strip | sort], [0], [dnl
  cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:05 actions=pop_mpls:0x0800,multipath(eth_src,50,modulo_n,256,0,NXM_OF_IP_SRC[[0..7]]),CONTROLLER:65535
  cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:06 actions=pop_mpls:0x0800,bundle_load(eth_src,50,hrw,ofport,NXM_OF_IP_SRC[[0..15]],slaves:1,2),CONTROLLER:65535
  cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:07 actions=pop_mpls:0x0800,learn(table=1,hard_timeout=60,eth_type=0x800,nw_proto=6,NXM_OF_IP_SRC[[]]=NXM_OF_IP_DST[[]]),CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:04:00 actions=pop_mpls:0x0800,push_mpls:0x8847,CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:04:01 actions=pop_mpls:0x0800,push_mpls:0x8848,dec_mpls_ttl,CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:04:10 actions=pop_mpls:0x0800,dec_ttl(0),push_mpls:0x8848,dec_mpls_ttl,CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:05:00 actions=push_mpls:0x8848,pop_mpls:0x8847,CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:05:01 actions=push_mpls:0x8847,pop_mpls:0x8848,dec_mpls_ttl,CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:05:10 actions=push_mpls:0x8848,dec_mpls_ttl,pop_mpls:0x8847,dec_mpls_ttl,CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=198, dl_src=60:66:66:66:01:00 actions=pop_mpls:0x8848,CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=198, dl_src=60:66:66:66:01:01 actions=pop_mpls:0x8847,dec_mpls_ttl,CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=198, dl_src=60:66:66:66:01:02 actions=pop_mpls:0x8848,load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=198, dl_src=60:66:66:66:02:00 actions=pop_mpls:0x8847,pop_mpls:0x0800,CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=198, dl_src=60:66:66:66:02:01 actions=pop_mpls:0x8848,pop_mpls:0x0800,dec_ttl(0),CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=198, dl_src=60:66:66:66:02:10 actions=pop_mpls:0x8847,dec_mpls_ttl,pop_mpls:0x0800,dec_ttl(0),CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=210, dl_src=60:66:66:66:03:00 actions=pop_mpls:0x8848,pop_mpls:0x8848,CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=210, dl_src=60:66:66:66:03:01 actions=pop_mpls:0x8847,pop_mpls:0x8847,dec_mpls_ttl,CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=210, dl_src=60:66:66:66:03:10 actions=pop_mpls:0x8848,dec_mpls_ttl,pop_mpls:0x8848,dec_mpls_ttl,CONTROLLER:65535
  table=1, hard_timeout=60, tcp,nw_src=192.168.0.2 actions=drop
 NXST_FLOW reply:
 ])
diff --git a/tests/test-bundle.c b/tests/test-bundle.c
index 41e2e38..c901bfc 100644
--- a/tests/test-bundle.c
+++ b/tests/test-bundle.c
@@ -142,7 +142,6 @@ main(int argc, char *argv[])
     for (i = 0; i < N_FLOWS; i++) {
         random_bytes(&flows[i], sizeof flows[i]);
         memset(flows[i].zeros, 0, sizeof flows[i].zeros);
-        flows[i].mpls_depth = 0;
         flows[i].regs[0] = ofp_to_u16(OFPP_NONE);
     }
 
diff --git a/tests/test-multipath.c b/tests/test-multipath.c
index f1b12e2..f5298bf 100644
--- a/tests/test-multipath.c
+++ b/tests/test-multipath.c
@@ -67,7 +67,6 @@ main(int argc, char *argv[])
 
             random_bytes(&flow, sizeof flow);
             memset(flow.zeros, 0, sizeof flow.zeros);
-            flow.mpls_depth = 0;
 
             mp.max_link = n - 1;
             multipath_execute(&mp, &flow, &wc);
diff --git a/utilities/ovs-dpctl.c b/utilities/ovs-dpctl.c
index fa78b53..19cfecf 100644
--- a/utilities/ovs-dpctl.c
+++ b/utilities/ovs-dpctl.c
@@ -1110,7 +1110,7 @@ dpctl_normalize_actions(int argc, char *argv[])
             printf("no vlan: ");
         }
 
-        if (af->flow.mpls_depth) {
+        if (eth_type_mpls(af->flow.dl_type)) {
             printf("mpls(label=%"PRIu32",tc=%d,ttl=%d): ",
                    mpls_lse_to_label(af->flow.mpls_lse),
                    mpls_lse_to_tc(af->flow.mpls_lse),
diff --git a/utilities/ovs-ofctl.8.in b/utilities/ovs-ofctl.8.in
index e66c605..39a1082 100644
--- a/utilities/ovs-ofctl.8.in
+++ b/utilities/ovs-ofctl.8.in
@@ -927,10 +927,13 @@ allows isn't supported at the moment.)
 A priority of zero and the tag of zero are used for the new tag.
 .
 .IP \fBpush_mpls\fR:\fIethertype\fR
-If the packet does not already contain any MPLS labels, changes the
-packet's Ethertype to \fIethertype\fR, which must be either the MPLS
-unicast Ethertype \fB0x8847\fR or the MPLS multicast Ethertype
-\fB0x8848\fR, and then pushes an initial label stack entry.  The label
+Adds the outermost MPLS label stack entry to the MPLS label stack.
+.
+If a label stack already exists then the new label, traffic control value
+and TTL of the new label stack entry
+are coppied the previouisly outmost label stack entry.
+.
+Otherwise, if a label stack does not already exist, the new label
 stack entry's default label is 2 if the packet contains IPv6 and 0
 otherwise, its default traffic control value is the low 3 bits of the
 packet's DSCP value (0 if the packet is not IP), and its TTL is copied
@@ -945,15 +948,6 @@ followed by another \fBpush_mpls\fR will result in the first
 .
 .IP \fBpop_mpls\fR:\fIethertype\fR
 Strips the outermost MPLS label stack entry.
-Currently the implementation restricts \fIethertype\fR to a non-MPLS Ethertype
-and thus \fBpop_mpls\fR should only be applied to packets with
-an MPLS label stack depth of one.
-.
-.IP
-There are some limitations in the implementation.  \fBpop_mpls\fR
-followed by another \fBpush_mpls\fR without an intermediate
-\fBpush_mpls\fR will result in the first \fBpush_mpls\fR being
-discarded.
 .
 .IP \fBmod_dl_src\fB:\fImac\fR
 Sets the source Ethernet address to \fImac\fR.
-- 
1.8.3.2
