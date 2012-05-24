From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 10/21] classifier: Convert struct flow
	flow_metadata to use tun_key
Date: Thu, 24 May 2012 18:09:03 +0900
Message-ID: <1337850554-10339-11-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1337850554-10339-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

This allows the tun_key tp be bassed throughout user-space,
attached to a flow. This is the essence of flow-based tunneling.

This does not add tun_key or wildcards, other than the existing match for
the tun_id. It is envisaged that most if not all fields of the tun_key
could be wildcarded.

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

v4
* flow_format() and ofp_print_packet_in() format strings:
  - Make more consistent with eachother and format_odp_key_attr()
  - Update for flags field of tunnel
* Remove debugging message
* Add struct flow_tun_key to avoid needing to use
  ovs_key_ipv4_tunnel which is defined in a Linux kernel header.
  This code should be ofproto-provider agnostic.

v3
* Initial posting

classifer: don't use kernel tunnel structure
---
 lib/classifier.c        |  8 ++++----
 lib/dpif-linux.c        |  2 +-
 lib/flow.c              | 31 ++++++++++++++++++++++++++-----
 lib/flow.h              | 21 ++++++++++++++++-----
 lib/meta-flow.c         |  4 ++--
 lib/nx-match.c          |  2 +-
 lib/odp-util.c          | 24 ++++++++++++++++--------
 lib/ofp-print.c         | 12 ++++++++++--
 lib/ofp-util.c          |  4 ++--
 ofproto/ofproto-dpif.c  | 11 ++++++-----
 tests/test-classifier.c |  7 ++++---
 11 files changed, 88 insertions(+), 38 deletions(-)

diff --git a/lib/classifier.c b/lib/classifier.c
index e11a585..7dc6560 100644
--- a/lib/classifier.c
+++ b/lib/classifier.c
@@ -129,7 +129,7 @@ cls_rule_set_tun_id_masked(struct cls_rule *rule,
                            ovs_be64 tun_id, ovs_be64 mask)
 {
     rule->wc.tun_id_mask = mask;
-    rule->flow.tun_id = tun_id & mask;
+    rule->flow.tun_key.tun_id = tun_id & mask;
 }
 
 void
@@ -563,11 +563,11 @@ cls_rule_format(const struct cls_rule *rule, struct ds *s)
     case 0:
         break;
     case CONSTANT_HTONLL(UINT64_MAX):
-        ds_put_format(s, "tun_id=%#"PRIx64",", ntohll(f->tun_id));
+        ds_put_format(s, "tun_id=%#"PRIx64",", ntohll(f->tun_key.tun_id));
         break;
     default:
         ds_put_format(s, "tun_id=%#"PRIx64"/%#"PRIx64",",
-                      ntohll(f->tun_id), ntohll(wc->tun_id_mask));
+                      ntohll(f->tun_key.tun_id), ntohll(wc->tun_id_mask));
         break;
     }
     if (!(w & FWW_IN_PORT)) {
@@ -1187,7 +1187,7 @@ flow_equal_except(const struct flow *a, const struct flow *b,
         }
     }
 
-    return (!((a->tun_id ^ b->tun_id) & wildcards->tun_id_mask)
+    return (!((a->tun_key.tun_id ^ b->tun_key.tun_id) & wildcards->tun_id_mask)
             && !((a->nw_src ^ b->nw_src) & wildcards->nw_src_mask)
             && !((a->nw_dst ^ b->nw_dst) & wildcards->nw_dst_mask)
             && (wc & FWW_IN_PORT || a->in_port == b->in_port)
diff --git a/lib/dpif-linux.c b/lib/dpif-linux.c
index 256c9d6..0e5cdd2 100644
--- a/lib/dpif-linux.c
+++ b/lib/dpif-linux.c
@@ -1292,7 +1292,7 @@ dpif_linux_vport_send(int dp_ifindex, uint32_t port_no,
     uint64_t action;
 
     ofpbuf_use_const(&packet, data, size);
-    flow_extract(&packet, 0, htonll(0), 0, &flow);
+    flow_extract(&packet, 0, NULL, 0, &flow);
 
     ofpbuf_use_stack(&key, &keybuf, sizeof keybuf);
     odp_flow_key_from_flow(&key, &flow);
diff --git a/lib/flow.c b/lib/flow.c
index fc61610..8645e7d 100644
--- a/lib/flow.c
+++ b/lib/flow.c
@@ -330,7 +330,8 @@ invalid:
  *      present and has a correct length, and otherwise NULL.
  */
 void
-flow_extract(struct ofpbuf *packet, uint32_t skb_priority, ovs_be64 tun_id,
+flow_extract(struct ofpbuf *packet, uint32_t skb_priority,
+             const struct flow_tun_key *tun_key,
              uint16_t ofp_in_port, struct flow *flow)
 {
     struct ofpbuf b = *packet;
@@ -339,7 +340,9 @@ flow_extract(struct ofpbuf *packet, uint32_t skb_priority, ovs_be64 tun_id,
     COVERAGE_INC(flow_extract);
 
     memset(flow, 0, sizeof *flow);
-    flow->tun_id = tun_id;
+    if (tun_key) {
+        flow->tun_key = *tun_key;;
+    }
     flow->in_port = ofp_in_port;
     flow->skb_priority = skb_priority;
 
@@ -449,7 +452,7 @@ flow_zero_wildcards(struct flow *flow, const struct flow_wildcards *wildcards)
     for (i = 0; i < FLOW_N_REGS; i++) {
         flow->regs[i] &= wildcards->reg_masks[i];
     }
-    flow->tun_id &= wildcards->tun_id_mask;
+    flow->tun_key.tun_id &= wildcards->tun_id_mask;
     flow->nw_src &= wildcards->nw_src_mask;
     flow->nw_dst &= wildcards->nw_dst_mask;
     if (wc & FWW_IN_PORT) {
@@ -508,7 +511,7 @@ flow_get_metadata(const struct flow *flow, struct flow_metadata *fmd)
 {
     BUILD_ASSERT_DECL(FLOW_WC_SEQ == 10);
 
-    fmd->tun_id = flow->tun_id;
+    fmd->tun_key = flow->tun_key;
     fmd->tun_id_mask = htonll(UINT64_MAX);
 
     memcpy(fmd->regs, flow->regs, sizeof fmd->regs);
@@ -528,11 +531,13 @@ flow_to_string(const struct flow *flow)
 void
 flow_format(struct ds *ds, const struct flow *flow)
 {
+    /* The tunnel key is also displayed as part of tunnel() below.
+     * It is here for backwards-compatibility */
     ds_put_format(ds, "priority:%"PRIu32
                       ",tunnel:%#"PRIx64
                       ",in_port:%04"PRIx16,
                       flow->skb_priority,
-                      ntohll(flow->tun_id),
+                      ntohll(flow->tun_key.tun_id),
                       flow->in_port);
 
     ds_put_format(ds, ",tci(");
@@ -579,6 +584,22 @@ flow_format(struct ds *ds, const struct flow *flow)
                 ETH_ADDR_ARGS(flow->arp_sha),
                 ETH_ADDR_ARGS(flow->arp_tha));
     }
+    if (!eth_addr_is_zero(flow->arp_sha) || !eth_addr_is_zero(flow->arp_tha)) {
+        ds_put_format(ds, " arp_ha("ETH_ADDR_FMT"->"ETH_ADDR_FMT")",
+                ETH_ADDR_ARGS(flow->arp_sha),
+                ETH_ADDR_ARGS(flow->arp_tha));
+    }
+    if (flow->tun_key.ipv4_dst != htonl(0)) {
+        ds_put_format(ds, " tunnel(tun_id:%"PRIx64",flags:%"PRIx32
+                          ",ip("IP_FMT"->"IP_FMT"),"
+                          ",tos:%"PRIx8",ttl:%"PRIu8")",
+                          ntohll(flow->tun_key.tun_id),
+                          flow->tun_key.tun_flags,
+                          IP_ARGS(&flow->tun_key.ipv4_src),
+                          IP_ARGS(&flow->tun_key.ipv4_dst),
+                          flow->tun_key.ipv4_tos, flow->tun_key.ipv4_ttl);
+    }
+
 }
 
 void
diff --git a/lib/flow.h b/lib/flow.h
index 7ee9a26..0b5932f 100644
--- a/lib/flow.h
+++ b/lib/flow.h
@@ -52,8 +52,18 @@ BUILD_ASSERT_DECL(FLOW_N_REGS <= NXM_NX_MAX_REGS);
 BUILD_ASSERT_DECL(FLOW_NW_FRAG_ANY == NX_IP_FRAG_ANY);
 BUILD_ASSERT_DECL(FLOW_NW_FRAG_LATER == NX_IP_FRAG_LATER);
 
+struct flow_tun_key {
+	ovs_be64 tun_id;
+	uint32_t tun_flags;
+	ovs_be32 ipv4_src;
+	ovs_be32 ipv4_dst;
+	uint8_t  ipv4_tos;
+	uint8_t  ipv4_ttl;
+	uint8_t  pad[2];
+};
+
 struct flow {
-    ovs_be64 tun_id;            /* Encapsulating tunnel ID. */
+    struct flow_tun_key tun_key;/* Encapsulating tunnel. */
     struct in6_addr ipv6_src;   /* IPv6 source address. */
     struct in6_addr ipv6_dst;   /* IPv6 destination address. */
     struct in6_addr nd_target;  /* IPv6 neighbor discovery (ND) target. */
@@ -82,7 +92,7 @@ struct flow {
  * indicate which metadata fields are relevant in a given context.  Typically
  * they will be all 1 or all 0. */
 struct flow_metadata {
-    ovs_be64 tun_id;                 /* Encapsulating tunnel ID. */
+    struct flow_tun_key tun_key;     /* Encapsulating tunnel. */
     ovs_be64 tun_id_mask;            /* 1-bit in each significant tun_id bit.*/
 
     uint32_t regs[FLOW_N_REGS];      /* Registers. */
@@ -93,16 +103,17 @@ struct flow_metadata {
 
 /* Assert that there are FLOW_SIG_SIZE bytes of significant data in "struct
  * flow", followed by FLOW_PAD_SIZE bytes of padding. */
-#define FLOW_SIG_SIZE (110 + FLOW_N_REGS * 4)
+#define FLOW_SIG_SIZE (126 + FLOW_N_REGS * 4)
 #define FLOW_PAD_SIZE 2
 BUILD_ASSERT_DECL(offsetof(struct flow, nw_frag) == FLOW_SIG_SIZE - 1);
 BUILD_ASSERT_DECL(sizeof(((struct flow *)0)->nw_frag) == 1);
 BUILD_ASSERT_DECL(sizeof(struct flow) == FLOW_SIG_SIZE + FLOW_PAD_SIZE);
 
 /* Remember to update FLOW_WC_SEQ when changing 'struct flow'. */
-BUILD_ASSERT_DECL(FLOW_SIG_SIZE == 142 && FLOW_WC_SEQ == 10);
+BUILD_ASSERT_DECL(FLOW_SIG_SIZE == 158 && FLOW_WC_SEQ == 10);
 
-void flow_extract(struct ofpbuf *, uint32_t priority, ovs_be64 tun_id,
+void flow_extract(struct ofpbuf *, uint32_t priority,
+	          const struct flow_tun_key *,
                   uint16_t in_port, struct flow *);
 void flow_zero_wildcards(struct flow *, const struct flow_wildcards *);
 void flow_get_metadata(const struct flow *, struct flow_metadata *);
diff --git a/lib/meta-flow.c b/lib/meta-flow.c
index 8b60b35..0b47ea1 100644
--- a/lib/meta-flow.c
+++ b/lib/meta-flow.c
@@ -962,7 +962,7 @@ mf_get_value(const struct mf_field *mf, const struct flow *flow,
 {
     switch (mf->id) {
     case MFF_TUN_ID:
-        value->be64 = flow->tun_id;
+        value->be64 = flow->tun_key.tun_id;
         break;
 
     case MFF_IN_PORT:
@@ -1300,7 +1300,7 @@ mf_set_flow_value(const struct mf_field *mf,
 {
     switch (mf->id) {
     case MFF_TUN_ID:
-        flow->tun_id = value->be64;
+        flow->tun_key.tun_id = value->be64;
         break;
 
     case MFF_IN_PORT:
diff --git a/lib/nx-match.c b/lib/nx-match.c
index 34c8354..f97ef5d 100644
--- a/lib/nx-match.c
+++ b/lib/nx-match.c
@@ -541,7 +541,7 @@ nx_put_match(struct ofpbuf *b, const struct cls_rule *cr,
     }
 
     /* Tunnel ID. */
-    nxm_put_64m(b, NXM_NX_TUN_ID, flow->tun_id, cr->wc.tun_id_mask);
+    nxm_put_64m(b, NXM_NX_TUN_ID, flow->tun_key.tun_id, cr->wc.tun_id_mask);
 
     /* Registers. */
     for (i = 0; i < FLOW_N_REGS; i++) {
diff --git a/lib/odp-util.c b/lib/odp-util.c
index 7cff00c..5f76f5e 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -1299,8 +1299,12 @@ odp_flow_key_from_flow(struct ofpbuf *buf, const struct flow *flow)
         nl_msg_put_u32(buf, OVS_KEY_ATTR_PRIORITY, flow->skb_priority);
     }
 
-    if (flow->tun_id != htonll(0)) {
-        nl_msg_put_be64(buf, OVS_KEY_ATTR_TUN_ID, flow->tun_id);
+    if (flow->tun_key.ipv4_dst != htonl(0)) {
+        struct flow_tun_key *tun_key;
+
+        tun_key = nl_msg_put_unspec_uninit(buf, OVS_KEY_ATTR_IPV4_TUNNEL,
+                                           sizeof *tun_key);
+        *tun_key = flow->tun_key;
     }
 
     if (flow->in_port != OFPP_NONE && flow->in_port != OFPP_CONTROLLER) {
@@ -1791,9 +1795,13 @@ odp_flow_key_to_flow(const struct nlattr *key, size_t key_len,
         expected_attrs |= UINT64_C(1) << OVS_KEY_ATTR_PRIORITY;
     }
 
-    if (present_attrs & (UINT64_C(1) << OVS_KEY_ATTR_TUN_ID)) {
-        flow->tun_id = nl_attr_get_be64(attrs[OVS_KEY_ATTR_TUN_ID]);
-        expected_attrs |= UINT64_C(1) << OVS_KEY_ATTR_TUN_ID;
+    if (present_attrs & (UINT64_C(1) << OVS_KEY_ATTR_IPV4_TUNNEL)) {
+        const struct flow_tun_key *tun_key;
+
+        tun_key = nl_attr_get(attrs[OVS_KEY_ATTR_IPV4_TUNNEL]);
+        flow->tun_key = *tun_key;
+
+        expected_attrs |= UINT64_C(1) << OVS_KEY_ATTR_IPV4_TUNNEL;
     }
 
     if (present_attrs & (UINT64_C(1) << OVS_KEY_ATTR_IN_PORT)) {
@@ -1887,13 +1895,13 @@ static void
 commit_set_tun_id_action(const struct flow *flow, struct flow *base,
                          struct ofpbuf *odp_actions)
 {
-    if (base->tun_id == flow->tun_id) {
+    if (base->tun_key.tun_id == flow->tun_key.tun_id) {
         return;
     }
-    base->tun_id = flow->tun_id;
+    base->tun_key.tun_id = flow->tun_key.tun_id;
 
     commit_set_action(odp_actions, OVS_KEY_ATTR_TUN_ID,
-                      &base->tun_id, sizeof(base->tun_id));
+                      &base->tun_key.tun_id, sizeof(base->tun_key.tun_id));
 }
 
 static void
diff --git a/lib/ofp-print.c b/lib/ofp-print.c
index 1757a30..fff7454 100644
--- a/lib/ofp-print.c
+++ b/lib/ofp-print.c
@@ -106,11 +106,19 @@ ofp_print_packet_in(struct ds *string, const struct ofp_header *oh,
     ds_put_format(string, " total_len=%"PRIu16" in_port=", pin.total_len);
     ofputil_format_port(pin.fmd.in_port, string);
 
-    if (pin.fmd.tun_id_mask) {
-        ds_put_format(string, " tun_id=0x%"PRIx64, ntohll(pin.fmd.tun_id));
+    if (pin.fmd.tun_key.ipv4_dst != htonl(0)) {
+        ds_put_format(string, " tunnel(tun_id=0x%"PRIx64,
+                              ntohll(pin.fmd.tun_key.tun_id));
         if (pin.fmd.tun_id_mask != htonll(UINT64_MAX)) {
             ds_put_format(string, "/0x%"PRIx64, ntohll(pin.fmd.tun_id_mask));
         }
+        ds_put_format(string, ",flags=%"PRIx32",ip="IP_FMT"->"IP_FMT","
+                              "tos=%"PRIx8",ttl=%"PRIu8")",
+                              pin.fmd.tun_key.tun_flags,
+                              IP_ARGS(&pin.fmd.tun_key.ipv4_src),
+                              IP_ARGS(&pin.fmd.tun_key.ipv4_dst),
+                              pin.fmd.tun_key.ipv4_tos,
+                              pin.fmd.tun_key.ipv4_ttl);
     }
 
     for (i = 0; i < FLOW_N_REGS; i++) {
diff --git a/lib/ofp-util.c b/lib/ofp-util.c
index 90124ec..652a6bf 100644
--- a/lib/ofp-util.c
+++ b/lib/ofp-util.c
@@ -2096,7 +2096,7 @@ ofputil_decode_packet_in(struct ofputil_packet_in *pin,
 
         pin->fmd.in_port = rule.flow.in_port;
 
-        pin->fmd.tun_id = rule.flow.tun_id;
+        pin->fmd.tun_key.tun_id = rule.flow.tun_key.tun_id;
         pin->fmd.tun_id_mask = rule.wc.tun_id_mask;
 
         memcpy(pin->fmd.regs, rule.flow.regs, sizeof pin->fmd.regs);
@@ -2149,7 +2149,7 @@ ofputil_encode_packet_in(const struct ofputil_packet_in *pin,
                             + 2 + send_len);
 
         cls_rule_init_catchall(&rule, 0);
-        cls_rule_set_tun_id_masked(&rule, pin->fmd.tun_id,
+        cls_rule_set_tun_id_masked(&rule, pin->fmd.tun_key.tun_id,
                                    pin->fmd.tun_id_mask);
 
         for (i = 0; i < FLOW_N_REGS; i++) {
diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index 03a86bc..2a52f37 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -3080,7 +3080,7 @@ handle_miss_upcalls(struct ofproto_dpif *ofproto, struct dpif_upcall *upcalls,
             continue;
         }
         flow_extract(upcall->packet, miss->flow.skb_priority,
-                     miss->flow.tun_id, miss->flow.in_port, &miss->flow);
+                     &miss->flow.tun_key, miss->flow.in_port, &miss->flow);
 
         /* Add other packets to a to-do list. */
         hash = flow_hash(&miss->flow, 0);
@@ -5464,7 +5464,7 @@ do_xlate_actions(const union ofp_action *in, size_t n_in,
         case OFPUTIL_NXAST_SET_TUNNEL:
             nast = (const struct nx_action_set_tunnel *) ia;
             tun_id = htonll(ntohl(nast->tun_id));
-            ctx->flow.tun_id = tun_id;
+            ctx->flow.tun_key.tun_id = tun_id;
             break;
 
         case OFPUTIL_NXAST_SET_QUEUE:
@@ -5492,7 +5492,7 @@ do_xlate_actions(const union ofp_action *in, size_t n_in,
 
         case OFPUTIL_NXAST_SET_TUNNEL64:
             tun_id = ((const struct nx_action_set_tunnel64 *) ia)->tun_id;
-            ctx->flow.tun_id = tun_id;
+            ctx->flow.tun_key.tun_id = tun_id;
             break;
 
         case OFPUTIL_NXAST_MULTIPATH:
@@ -5576,7 +5576,7 @@ action_xlate_ctx_init(struct action_xlate_ctx *ctx,
     ctx->ofproto = ofproto;
     ctx->flow = *flow;
     ctx->base_flow = ctx->flow;
-    ctx->base_flow.tun_id = 0;
+    ctx->base_flow.tun_key.ipv4_src = 0;
     ctx->base_flow.vlan_tci = initial_tci;
     ctx->rule = rule;
     ctx->packet = packet;
@@ -6739,6 +6739,7 @@ ofproto_unixctl_trace(struct unixctl_conn *conn, int argc, const char *argv[],
         const char *packet_s = argv[5];
         uint16_t in_port = ofp_port_to_odp_port(atoi(in_port_s));
         ovs_be64 tun_id = htonll(strtoull(tun_id_s, NULL, 0));
+        struct ovs_key_ipv4_tunnel tun_key = { .tun_id = tun_id };
         uint32_t priority = atoi(priority_s);
         const char *msg;
 
@@ -6753,7 +6754,7 @@ ofproto_unixctl_trace(struct unixctl_conn *conn, int argc, const char *argv[],
         ds_put_cstr(&result, s);
         free(s);
 
-        flow_extract(packet, priority, tun_id, in_port, &flow);
+        flow_extract(packet, priority, &tun_key, in_port, &flow);
         initial_tci = flow.vlan_tci;
     } else {
         unixctl_command_reply_error(conn, "Bad command syntax");
diff --git a/tests/test-classifier.c b/tests/test-classifier.c
index fcafdb2..5bb5df8 100644
--- a/tests/test-classifier.c
+++ b/tests/test-classifier.c
@@ -44,7 +44,7 @@
     /*                                    struct flow  all-caps */  \
     /*        FWW_* bit(s)                member name  name     */  \
     /*        --------------------------  -----------  -------- */  \
-    CLS_FIELD(0,                          tun_id,      TUN_ID)      \
+    CLS_FIELD(0,                          tun_key.tun_id,  TUN_ID)  \
     CLS_FIELD(0,                          nw_src,      NW_SRC)      \
     CLS_FIELD(0,                          nw_dst,      NW_DST)      \
     CLS_FIELD(FWW_IN_PORT,                in_port,     IN_PORT)     \
@@ -206,7 +206,8 @@ match(const struct cls_rule *wild, const struct flow *fixed)
             eq = !((fixed->vlan_tci ^ wild->flow.vlan_tci)
                    & wild->wc.vlan_tci_mask);
         } else if (f_idx == CLS_F_IDX_TUN_ID) {
-            eq = !((fixed->tun_id ^ wild->flow.tun_id) & wild->wc.tun_id_mask);
+            eq = !((fixed->tun_key.tun_id ^ wild->flow.tun_key.tun_id) &
+                   wild->wc.tun_id_mask);
         } else if (f_idx == CLS_F_IDX_NW_DSCP) {
             eq = !((fixed->nw_tos ^ wild->flow.nw_tos) & IP_DSCP_MASK);
         } else {
@@ -362,7 +363,7 @@ compare_classifiers(struct classifier *cls, struct tcls *tcls)
         x = rand () % N_FLOW_VALUES;
         flow.nw_src = nw_src_values[get_value(&x, N_NW_SRC_VALUES)];
         flow.nw_dst = nw_dst_values[get_value(&x, N_NW_DST_VALUES)];
-        flow.tun_id = tun_id_values[get_value(&x, N_TUN_ID_VALUES)];
+        flow.tun_key.tun_id = tun_id_values[get_value(&x, N_TUN_ID_VALUES)];
         flow.in_port = in_port_values[get_value(&x, N_IN_PORT_VALUES)];
         flow.vlan_tci = vlan_tci_values[get_value(&x, N_VLAN_TCI_VALUES)];
         flow.dl_type = dl_type_values[get_value(&x, N_DL_TYPE_VALUES)];
-- 
1.7.10.2.484.gcd07cc5
