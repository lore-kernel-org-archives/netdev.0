From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 06/21] ofproto: Add set_tunnelling()
Date: Thu, 24 May 2012 18:08:59 +0900
Message-ID: <1337850554-10339-7-git-send-email-horms@verge.net.au>
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

Allow configuration of tunneling in ofproto_port instances.

For tunnel realdevs this includes the remote IP of the and type tunnel,
and optionally the local IP, tos and ttl.

For tunnel tundevs it only includes the type.

realdevs and tundevs can be differentiated by examining the remote IP,
which is always zero for tundevs and always non-zero for realdevs.

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 ofproto/ofproto-dpif.c     | 116 +++++++++++++++++++++++++++++++++++++++++++++
 ofproto/ofproto-provider.h |  12 +++++
 ofproto/ofproto.c          |  28 +++++++++++
 ofproto/ofproto.h          |  13 +++++
 4 files changed, 169 insertions(+)

diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index f2c2ca9..642b508 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -476,6 +476,13 @@ static void facet_account(struct facet *);
 
 static bool facet_is_controller_flow(struct facet *);
 
+struct ofport_dpif_tun {
+    struct tunnel_settings s;
+    uint16_t tundev_ofp_port;
+    struct hmap_node tundev_node;
+    struct ofport_dpif *ofport;  /* Containing ofport_dpif */
+};
+
 struct ofport_dpif {
     struct ofport up;
 
@@ -503,6 +510,9 @@ struct ofport_dpif {
      * widespread use, we will delete these interfaces. */
     uint16_t realdev_ofp_port;
     int vlandev_vid;
+
+    /* Tunneling */
+    struct ofport_dpif_tun *tun;
 };
 
 /* Node in 'ofport_dpif''s 'priorities' map.  Used to maintain a map from
@@ -535,6 +545,16 @@ static bool vsp_adjust_flow(const struct ofproto_dpif *, struct flow *);
 static void vsp_remove(struct ofport_dpif *);
 static void vsp_add(struct ofport_dpif *, uint16_t realdev_ofp_port, int vid);
 
+static unsigned key_local_remote_ports;
+static unsigned key_remote_ports;
+static unsigned local_remote_ports;
+static unsigned remote_ports;
+static unsigned key_multicast_ports;
+static unsigned multicast_ports;
+
+static int set_tunnelling(struct ofport *ofport_, uint16_t realdev_ofp_port,
+                          const struct tunnel_settings *s);
+
 static struct ofport_dpif *
 ofport_dpif_cast(const struct ofport *ofport)
 {
@@ -612,6 +632,9 @@ struct ofproto_dpif {
     /* VLAN splinters. */
     struct hmap realdev_vid_map; /* (realdev,vid) -> vlandev. */
     struct hmap vlandev_map;     /* vlandev -> (realdev,vid). */
+
+    /* Tunnelling */
+    struct hmap tundev_map;     /* tundev -> realdev */
 };
 
 /* Defer flow mod completion until "ovs-appctl ofproto/unclog"?  (Useful only
@@ -771,6 +794,8 @@ construct(struct ofproto *ofproto_)
     hmap_init(&ofproto->vlandev_map);
     hmap_init(&ofproto->realdev_vid_map);
 
+    hmap_init(&ofproto->tundev_map);
+
     hmap_insert(&all_ofproto_dpifs, &ofproto->all_ofproto_dpifs_node,
                 hash_string(ofproto->up.name, 0));
     memset(&ofproto->stats, 0, sizeof ofproto->stats);
@@ -1153,6 +1178,7 @@ port_construct(struct ofport *port_)
     hmap_init(&port->priorities);
     port->realdev_ofp_port = 0;
     port->vlandev_vid = 0;
+    port->tun = NULL;
     port->carrier_seq = netdev_get_carrier_resets(port->up.netdev);
 
     if (ofproto->sflow) {
@@ -1171,6 +1197,7 @@ port_destruct(struct ofport *port_)
     ofproto->need_revalidate = true;
     bundle_remove(port_);
     set_cfm(port_, NULL);
+    set_tunnelling(port_, 0, NULL);
     if (ofproto->sflow) {
         dpif_sflow_del_port(ofproto->sflow, port->odp_port);
     }
@@ -7097,6 +7124,94 @@ vsp_add(struct ofport_dpif *port, uint16_t realdev_ofp_port, int vid)
     }
 }
 
+static inline bool
+ipv4_is_multicast(__be32 addr)
+{
+    return (addr & htonl(0xf0000000)) == htonl(0xe0000000);
+}
+
+static unsigned int *
+tun_port_pool(const struct tunnel_settings *s)
+{
+    bool is_multicast = ipv4_is_multicast(s->daddr);
+
+    if (s->type & TNL_T_KEY_MATCH) {
+        if (s->saddr)
+            return &local_remote_ports;
+        else if (is_multicast)
+            return &multicast_ports;
+        else
+            return &remote_ports;
+    } else {
+        if (s->saddr)
+            return &key_local_remote_ports;
+        else if (is_multicast)
+            return &key_multicast_ports;
+        else
+            return &key_remote_ports;
+    }
+}
+
+static void
+tun_remove(struct ofport_dpif *ofport)
+{
+    struct ofproto_dpif *ofproto = ofproto_dpif_cast(ofport->up.ofproto);
+
+    if (!ofport->tun) {
+        return;
+    }
+
+    hmap_remove(&ofproto->tundev_map, &ofport->tun->tundev_node);
+    (*tun_port_pool(&ofport->tun->s))--;
+}
+
+static void
+tun_add(struct ofport_dpif *ofport, uint16_t tundev_ofp_port,
+        const struct tunnel_settings *s)
+{
+    struct ofproto_dpif *ofproto = ofproto_dpif_cast(ofport->up.ofproto);
+
+    ofport->tun->tundev_ofp_port = tundev_ofp_port;
+    ofport->tun->s = *s;
+    (*tun_port_pool(&ofport->tun->s))++;
+    hmap_insert(&ofproto->tundev_map, &ofport->tun->tundev_node,
+                hash_int(tundev_ofp_port, 0));
+}
+
+static int
+set_tunnelling(struct ofport *ofport_, uint16_t tundev_ofp_port,
+               const struct tunnel_settings *s)
+{
+    struct ofport_dpif *ofport = ofport_dpif_cast(ofport_);
+
+    if (!s) {
+        tun_remove(ofport);
+        free(ofport->tun);
+        ofport->tun = NULL;
+        return 0;
+    }
+
+    if (!ofport->tun) {
+        struct ofproto_dpif *ofproto;
+
+        ofproto = ofproto_dpif_cast(ofport->up.ofproto);
+        ofproto->need_revalidate = true;
+        ofport->tun = xzalloc(sizeof *ofport->tun);
+        ofport->tun->ofport = ofport;
+    }
+    else {
+        if (ofport->tun->tundev_ofp_port == tundev_ofp_port &&
+            tunnel_settings_equal(&ofport->tun->s, s)) {
+            return 0;
+        }
+        tun_remove(ofport);
+    }
+
+    tun_add(ofport, tundev_ofp_port, s);
+
+    return 0;
+}
+
 const struct ofproto_class ofproto_dpif_class = {
     enumerate_types,
     enumerate_names,
@@ -7159,4 +7274,5 @@ const struct ofproto_class ofproto_dpif_class = {
     forward_bpdu_changed,
     set_mac_idle_time,
     set_realdev,
+    set_tunnelling,
 };
diff --git a/ofproto/ofproto-provider.h b/ofproto/ofproto-provider.h
index 1f3ad37..be39691 100644
--- a/ofproto/ofproto-provider.h
+++ b/ofproto/ofproto-provider.h
@@ -1168,6 +1168,18 @@ struct ofproto_class {
      * it. */
     int (*set_realdev)(struct ofport *ofport,
                        uint16_t realdev_ofp_port, int vid);
+
+    /* Configures tunneling for 'ofport'.
+     *
+     * If 'tunnel_settings' is nonnull, configures tunneling
+     * according to its members.
+     *
+     * If 'tunneling_settings' is null, then any tunnel configuration is
+     * removed.
+     *
+     * This function should be null if tunnelling is not supported */
+    int (*set_tunnelling)(struct ofport *ofport, uint16_t tundev_ofp_port,
+			  const struct tunnel_settings *s);
 };
 
 extern const struct ofproto_class ofproto_dpif_class;
diff --git a/ofproto/ofproto.c b/ofproto/ofproto.c
index 0bda06a..79f7a24 100644
--- a/ofproto/ofproto.c
+++ b/ofproto/ofproto.c
@@ -4184,3 +4184,31 @@ ofproto_port_set_realdev(struct ofproto *ofproto, uint16_t vlandev_ofp_port,
     }
     return error;
 }
+
+/* Configure tunneling parameters of a port
+ *
+ * This function has no effect if 'ofproto' does not have a port 'ofp_port'. */
+void
+ofproto_port_set_tunnel(struct ofproto *ofproto, uint16_t tundev_ofp_port,
+			uint16_t ofp_port, const struct tunnel_settings *s)
+{
+    struct ofport *ofport;
+    int error;
+
+    ofport = ofproto_get_port(ofproto, ofp_port);
+    if (!ofport) {
+        VLOG_WARN("%s: cannot configure tunnel on nonexistent port %"PRIu16,
+                  ofproto->name, ofp_port);
+        return;
+    }
+
+    error = (ofproto->ofproto_class->set_tunnelling
+             ? ofproto->ofproto_class->set_tunnelling(ofport,
+						      tundev_ofp_port, s)
+             : EOPNOTSUPP);
+    if (error) {
+        VLOG_WARN("%s: Tunnel configuration on port %"PRIu16" (%s) failed (%s)",
+                  ofproto->name, ofp_port,
+		  netdev_get_name(ofport->netdev), strerror(error));
+    }
+}
diff --git a/ofproto/ofproto.h b/ofproto/ofproto.h
index d8739b0..147a588 100644
--- a/ofproto/ofproto.h
+++ b/ofproto/ofproto.h
@@ -398,6 +398,19 @@ struct tunnel_settings {
     uint8_t type;
 };
 
+static inline bool
+tunnel_settings_equal(const struct tunnel_settings *a,
+                      const struct tunnel_settings *b)
+{
+        return a->daddr == b->daddr &&
+                a->in_key == b->in_key &&
+                a->out_key == b->out_key &&
+                a->saddr == b->saddr &&
+                a->flags == b->flags &&
+                a->tos == b->tos &&
+                a->ttl == b->ttl;
+}
+
 void ofproto_port_set_tunnel(struct ofproto *ofproto, uint16_t tundev_ofp_port,
                              uint16_t realdev_ofp_port,
                              const struct tunnel_settings *s);
-- 
1.7.10.2.484.gcd07cc5
