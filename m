From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 05/21] vswitchd: Add add_tunnel_ports()
Date: Thu, 24 May 2012 18:08:58 +0900
Message-ID: <1337850554-10339-6-git-send-email-horms@verge.net.au>
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

Add tunnel tundevs for tunnel realdevs as needed.

In general the notion is that realdevs may be configured by users
and from an end-user point of view are compatible with the existing
port-based tunneling code. And that tundevs exist in the datapath
arnd are actually used to send and recieve packets, based on flows.

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 vswitchd/bridge.c | 67 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)

diff --git a/vswitchd/bridge.c b/vswitchd/bridge.c
index f775ae7..3d187f0 100644
--- a/vswitchd/bridge.c
+++ b/vswitchd/bridge.c
@@ -268,6 +268,7 @@ static void configure_splinter_port(struct port *);
 static void add_vlan_splinter_ports(struct bridge *,
                                     const unsigned long int *splinter_vlans,
                                     struct shash *ports);
+static void add_tunnel_ports(struct bridge *, struct shash *ports);
 
 /* Public functions. */
 
@@ -2751,6 +2752,8 @@ bridge_add_del_ports(struct bridge *br,
         add_vlan_splinter_ports(br, splinter_vlans, &new_ports);
     }
 
+    add_tunnel_ports(br, &new_ports);
+
     /* Get rid of deleted ports.
      * Get rid of deleted interfaces on ports that still exist. */
     HMAP_FOR_EACH_SAFE (port, next, hmap_node, &br->ports) {
@@ -4153,6 +4156,70 @@ add_vlan_splinter_ports(struct bridge *br,
     }
 }
 
+static struct ovsrec_port *
+synthesize_tunnel_port(const char *name, const char *type)
+{
+    struct ovsrec_interface *iface;
+    struct ovsrec_port *port;
+
+    iface = xzalloc(sizeof *iface);
+    iface->name = xstrdup(name);
+    iface->type = type;
+
+    port = xzalloc(sizeof *port);
+    port->interfaces = xmemdup(&iface, sizeof iface);
+    port->n_interfaces = 1;
+    port->name = xstrdup(name);
+
+    register_block(iface);
+    register_block(iface->name);
+    register_block(port);
+    register_block(port->interfaces);
+    register_block(port->name);
+
+    return port;
+}
+
+/* For each interface with 'br' is a tunnel, adds the corresponding
+ * ovsrec_port to 'ports' if it is not already present */
+static void
+add_tunnel_ports(struct bridge *br, struct shash *ports)
+{
+    size_t i;
+
+    /* We iterate through 'br->cfg->ports' instead of 'ports' here because
+     * we're modifying 'ports'. */
+    for (i = 0; i < br->cfg->n_ports; i++) {
+        const char *name = br->cfg->ports[i]->name;
+        struct ovsrec_port *port_cfg = shash_find_data(ports, name);
+        size_t j;
+
+        for (j = 0; j < port_cfg->n_interfaces; j++) {
+            struct ovsrec_interface *iface_cfg = port_cfg->interfaces[j];
+            const char *type = iface_get_type(iface_cfg, br->cfg);
+            const char *tundev_name;
+            const char *tundev_type;
+
+            if (!is_tunnel_realdev(type)) {
+                continue;
+            }
+
+            tundev_name = strcmp(type, "ipsec_gre") ? type : "gre";
+            if (!strcmp(tundev_name, "gre")) {
+                tundev_type = "gre-tundev";
+            } else {
+                tundev_type = "capwap-tundev";
+            }
+
+            if (!shash_find(ports, tundev_name)) {
+                    shash_add(ports, tundev_name,
+                              synthesize_tunnel_port(tundev_name,
+                                                     tundev_type));
+            }
+        }
+    }
+}
+
 static void
 mirror_refresh_stats(struct mirror *m)
 {
-- 
1.7.10.2.484.gcd07cc5
