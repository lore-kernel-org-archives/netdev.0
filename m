From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 09/21] ofproto: Add tundev_to_realdev()
Date: Thu, 24 May 2012 18:09:02 +0900
Message-ID: <1337850554-10339-10-git-send-email-horms@verge.net.au>
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

In essence this is a duplication of ovs_tnl_find_port(),
copying code from the datapath to vswitchd. It is planned
that the datapath version will be removed.

It is used to map from the tundev interface that a
packet is recieved by in the datapath to the tunnel realdev
interface used in user-sapce. It is the tunnel realdev
that has the tunnel configuration attached.

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 ofproto/ofproto-dpif.c | 194 ++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 174 insertions(+), 20 deletions(-)

diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index c7ea391..03a86bc 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -183,7 +183,7 @@ static void bundle_del_port(struct ofport_dpif *);
 static void bundle_run(struct ofbundle *);
 static void bundle_wait(struct ofbundle *);
 static struct ofbundle *lookup_input_bundle(const struct ofproto_dpif *,
-                                            uint16_t in_port, bool warn,
+                                            const struct flow *, bool warn,
                                             struct ofport_dpif **in_ofportp);
 
 /* A controller may use OFPP_NONE as the ingress port to indicate that
@@ -550,8 +550,12 @@ static unsigned remote_ports;
 static unsigned key_multicast_ports;
 static unsigned multicast_ports;
 
+static bool tunnel_adjust_flow(const struct ofproto_dpif *ofproto,
+                               struct flow *flow);
 static int set_tunnelling(struct ofport *ofport_, uint16_t realdev_ofp_port,
                           const struct tunnel_settings *s);
+static struct ofport_dpif *tundev_to_realdev(const struct ofproto_dpif *ofproto,
+                                             const struct flow *flow);
 
 static uint32_t
 realdev_to_txdev(const struct ofproto_dpif *ofproto,
@@ -2998,6 +3002,7 @@ ofproto_dpif_extract_flow_key(const struct ofproto_dpif *ofproto,
                               struct ofpbuf *packet)
 {
     enum odp_key_fitness fitness;
+    bool adjusted = false;
 
     fitness = odp_flow_key_to_flow(key, key_len, flow);
     if (fitness == ODP_FIT_ERROR) {
@@ -3005,7 +3010,9 @@ ofproto_dpif_extract_flow_key(const struct ofproto_dpif *ofproto,
     }
     *initial_tci = flow->vlan_tci;
 
-    if (vsp_adjust_flow(ofproto, flow)) {
+    if (tunnel_adjust_flow(ofproto, flow)) {
+        adjusted = true;
+    } else if (vsp_adjust_flow(ofproto, flow)) {
         if (packet) {
             /* Make the packet resemble the flow, so that it gets sent to an
              * OpenFlow controller properly, so that it looks correct for
@@ -3023,11 +3030,12 @@ ofproto_dpif_extract_flow_key(const struct ofproto_dpif *ofproto,
              * since we don't need that header anymore. */
             eth_push_vlan(packet, flow->vlan_tci);
         }
+        adjusted = true;
+    }
 
-        /* Let the caller know that we can't reproduce 'key' from 'flow'. */
-        if (fitness == ODP_FIT_PERFECT) {
-            fitness = ODP_FIT_TOO_MUCH;
-        }
+    /* Let the caller know that we can't reproduce 'key' from 'flow'. */
+    if (adjusted && fitness == ODP_FIT_PERFECT) {
+        fitness = ODP_FIT_TOO_MUCH;
     }
 
     return fitness;
@@ -5934,7 +5942,7 @@ add_mirror_actions(struct action_xlate_ctx *ctx, const struct flow *orig_flow)
     const struct nlattr *a;
     size_t left;
 
-    in_bundle = lookup_input_bundle(ctx->ofproto, orig_flow->in_port,
+    in_bundle = lookup_input_bundle(ctx->ofproto, orig_flow,
                                     ctx->packet != NULL, NULL);
     if (!in_bundle) {
         return;
@@ -6095,13 +6103,17 @@ update_learning_table(struct ofproto_dpif *ofproto,
 }
 
 static struct ofbundle *
-lookup_input_bundle(const struct ofproto_dpif *ofproto, uint16_t in_port,
-                    bool warn, struct ofport_dpif **in_ofportp)
+lookup_input_bundle(const struct ofproto_dpif *ofproto,
+                    const struct flow *flow, bool warn,
+                    struct ofport_dpif **in_ofportp)
 {
     struct ofport_dpif *ofport;
 
     /* Find the port and bundle for the received packet. */
-    ofport = get_ofp_port(ofproto, in_port);
+    ofport = tundev_to_realdev(ofproto, flow);
+    if (!ofport) {
+        ofport = get_ofp_port(ofproto, flow->in_port);
+    }
     if (in_ofportp) {
         *in_ofportp = ofport;
     }
@@ -6111,7 +6123,7 @@ lookup_input_bundle(const struct ofproto_dpif *ofproto, uint16_t in_port,
 
     /* Special-case OFPP_NONE, which a controller may use as the ingress
      * port for traffic that it is sourcing. */
-    if (in_port == OFPP_NONE) {
+    if (flow->in_port == OFPP_NONE) {
         return &ofpp_none_bundle;
     }
 
@@ -6129,7 +6141,7 @@ lookup_input_bundle(const struct ofproto_dpif *ofproto, uint16_t in_port,
         static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 5);
 
         VLOG_WARN_RL(&rl, "bridge %s: received packet on unknown "
-                     "port %"PRIu16, ofproto->up.name, in_port);
+                     "port %"PRIu16, ofproto->up.name, flow->in_port);
     }
     return NULL;
 }
@@ -6196,7 +6208,7 @@ xlate_normal(struct action_xlate_ctx *ctx)
 
     ctx->has_normal = true;
 
-    in_bundle = lookup_input_bundle(ctx->ofproto, ctx->flow.in_port,
+    in_bundle = lookup_input_bundle(ctx->ofproto, &ctx->flow,
                                     ctx->packet != NULL, &in_port);
     if (!in_bundle) {
         return;
@@ -7166,16 +7178,19 @@ tun_remove(struct ofport_dpif *ofport)
 }
 
 static void
-tun_add(struct ofport_dpif *ofport, uint16_t tundev_ofp_port,
-        const struct tunnel_settings *s)
+tun_add(struct ofport_dpif *ofport)
 {
     struct ofproto_dpif *ofproto = ofproto_dpif_cast(ofport->up.ofproto);
 
-    ofport->tun->tundev_ofp_port = tundev_ofp_port;
-    ofport->tun->s = *s;
+    /* Only add if the saddr is non-zero, in which case ofport is a
+     * realdev. Otherwise it is a tundev */
+    if (ofport->tun->s.daddr == htonl(0)) {
+        return;
+    }
+
     (*tun_port_pool(&ofport->tun->s))++;
     hmap_insert(&ofproto->tundev_map, &ofport->tun->tundev_node,
-                hash_int(tundev_ofp_port, 0));
+                hash_int(ofport->tun->tundev_ofp_port, 0));
 }
 
 static int
@@ -7203,15 +7218,154 @@ set_tunnelling(struct ofport *ofport_, uint16_t tundev_ofp_port,
         if (ofport->tun->tundev_ofp_port == tundev_ofp_port &&
             tunnel_settings_equal(&ofport->tun->s, s)) {
             return 0;
-        }
+       }
         tun_remove(ofport);
     }
 
-    tun_add(ofport, tundev_ofp_port, s);
+    ofport->tun->s = *s;
+    ofport->tun->tundev_ofp_port = tundev_ofp_port;
+    tun_add(ofport);
 
     return 0;
 }
 
+struct tunnel_lookup_key {
+    ovs_be64 tun_id;
+    ovs_be32 ipv4_src;
+    ovs_be32 ipv4_dst;
+    uint8_t tun_type;
+};
+
+static struct ofport_dpif *
+tundev_find(const struct ofproto_dpif *ofproto, uint16_t tundev_ofp_port,
+            const struct tunnel_lookup_key *tun_key)
+{
+    struct ofport_dpif_tun *tun;
+
+    HMAP_FOR_EACH_WITH_HASH (tun, tundev_node, hash_int(tundev_ofp_port, 0),
+                             &ofproto->tundev_map) {
+        if (tun_key->tun_type == tun->s.type &&
+            tun_key->ipv4_dst == tun->s.daddr &&
+            tun_key->tun_id == tun->s.in_key &&
+            tun_key->ipv4_src == tun->s.saddr) {
+	    return tun->ofport;
+        }
+    }
+
+    return NULL;
+}
+
+/* Returns the OpenFlow port number of the "real" device underlying the Linux
+ * tunnel device matching tun_key.
+ *
+ * Returns 0 if no match is found */
+static struct ofport_dpif *
+tundev_to_realdev(const struct ofproto_dpif *ofproto, const struct flow *flow)
+{
+    bool is_multicast = ipv4_is_multicast(flow->tun_key.ipv4_dst);
+    struct ofport_dpif *tundev_ofport;
+    struct ofport_dpif *realdev_ofport;
+    struct tunnel_lookup_key lookup;
+
+    /* Nothing to do if the packet wasn't unencapsulated on receive */
+    if (!flow->tun_key.ipv4_dst) {
+        return NULL;
+    }
+
+    /* Nothing to do if there are no tunnel devices configured */
+    if (hmap_is_empty(&ofproto->tundev_map)) {
+        return NULL;
+    }
+
+    /* Give up if the tunnel device can't be found
+     * or isn't a tunnel tundev */
+    tundev_ofport = get_ofp_port(ofproto, flow->in_port);
+    if (!tundev_ofport || !tundev_ofport->tun || tundev_ofport->tun->s.daddr) {
+        return NULL;
+    }
+
+    lookup.tun_id = flow->tun_key.tun_id;
+    lookup.ipv4_src = flow->tun_key.ipv4_dst;
+    lookup.ipv4_dst = flow->tun_key.ipv4_src;
+
+    /* First try for an exact match on the tun_id */
+    lookup.tun_id = flow->tun_key.tun_id;
+    lookup.tun_type = tundev_ofport->tun->s.type | TNL_T_KEY_EXACT;
+    if (!is_multicast && key_local_remote_ports) {
+        realdev_ofport = tundev_find(ofproto, flow->in_port, &lookup);
+        if (realdev_ofport)
+            return realdev_ofport;
+    }
+    if (key_remote_ports) {
+        lookup.ipv4_src = htonl(0);
+        realdev_ofport = tundev_find(ofproto, flow->in_port, &lookup);
+        if (realdev_ofport)
+            return realdev_ofport;
+        lookup.ipv4_src = flow->tun_key.ipv4_dst;
+    }
+
+    /* Then try matches that wildcard the tun_id. */
+    lookup.tun_id = htonll(0);
+    lookup.tun_type = tundev_ofport->tun->s.type | TNL_T_KEY_MATCH;
+    if (!is_multicast && local_remote_ports) {
+        realdev_ofport = tundev_find(ofproto, flow->in_port, &lookup);
+        if (realdev_ofport)
+            return realdev_ofport;
+    }
+    if (remote_ports) {
+        lookup.ipv4_src = htonl(0);
+        realdev_ofport = tundev_find(ofproto, flow->in_port, &lookup);
+        if (realdev_ofport)
+            return realdev_ofport;
+    }
+
+    if (is_multicast) {
+        lookup.ipv4_src = htonl(0);
+        lookup.ipv4_dst = flow->tun_key.ipv4_dst;
+        if (key_multicast_ports) {
+            lookup.tun_id = flow->tun_key.tun_id;
+            lookup.tun_type = tundev_ofport->tun->s.type | TNL_T_KEY_EXACT;
+            realdev_ofport = tundev_find(ofproto, flow->in_port, &lookup);
+            if (realdev_ofport)
+                return realdev_ofport;
+        }
+        if (multicast_ports) {
+            lookup.tun_id = 0;
+            lookup.tun_type = tundev_ofport->tun->s.type | TNL_T_KEY_MATCH;
+            realdev_ofport = tundev_find(ofproto, flow->in_port, &lookup);
+            if (realdev_ofport)
+                return realdev_ofport;
+        }
+    }
+
+    return NULL;
+}
+
+/* Given 'flow', a flow representing a packet received on 'ofproto', checks
+ * whether 'flow->in_port' represents a Linux tunnel device.  If so, changes
+ * 'flow->in_port' to the "real" device backing the tunnel device, sets
+ * 'flow->key' to using the real device's tunnel settings, and returns true.
+ * Otherwise (which is always the case unless tunneling enabled), returns
+ * false without making any changes. */
+static bool
+tunnel_adjust_flow(const struct ofproto_dpif *ofproto, struct flow *flow)
+{
+    const struct ofport_dpif *realdev_ofport = tundev_to_realdev(ofproto, flow);
+    if (!realdev_ofport) {
+        return false;
+    }
+
+    /* Cause the flow to be processed as if it came in on the real device with
+     * the tunnel's key. */
+    flow->in_port = ofp_port_to_odp_port(realdev_ofport->up.ofp_port);
+    flow->tun_key.tun_id = realdev_ofport->tun->s.out_key;
+    flow->tun_key.ipv4_src = realdev_ofport->tun->s.saddr;
+    flow->tun_key.ipv4_dst = realdev_ofport->tun->s.daddr;
+    flow->tun_key.ipv4_tos = realdev_ofport->tun->s.tos;
+    flow->tun_key.ipv4_ttl = realdev_ofport->tun->s.ttl;
+    return true;
+}
+
 /* Maps a port to the port that it should be transmitted on.
  * If tunneling is enabled then the associated tunnel port is returned.
  * If VLAN splintering is enabled then the ofp_port of the vlandev is
-- 
1.7.10.2.484.gcd07cc5
