From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 07/21] vswitchd: Configure tunnel interfaces.
Date: Thu, 24 May 2012 18:09:00 +0900
Message-ID: <1337850554-10339-8-git-send-email-horms@verge.net.au>
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

For tunnel realdevs this sets the remote IP and type,
and optionally source IP, ttl and tos. The remote IP
must non-zero.

For tunnel tundevs only the type is configured.
The remote IP must be zero.

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 vswitchd/bridge.c | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 69 insertions(+)

diff --git a/vswitchd/bridge.c b/vswitchd/bridge.c
index 3d187f0..a67f391 100644
--- a/vswitchd/bridge.c
+++ b/vswitchd/bridge.c
@@ -242,6 +242,7 @@ static void iface_set_ofport(const struct ovsrec_interface *, int64_t ofport);
 static void iface_clear_db_record(const struct ovsrec_interface *if_cfg);
 static void iface_configure_qos(struct iface *, const struct ovsrec_qos *);
 static void iface_configure_cfm(struct iface *);
+static void iface_configure_tunnel(struct iface *);
 static void iface_refresh_cfm_stats(struct iface *);
 static void iface_refresh_stats(struct iface *);
 static void iface_refresh_status(struct iface *);
@@ -535,6 +536,7 @@ bridge_reconfigure_continue(const struct ovsrec_open_vswitch *ovs_cfg)
             LIST_FOR_EACH (iface, port_elem, &port->ifaces) {
                 iface_configure_cfm(iface);
                 iface_configure_qos(iface, port->cfg->qos);
+                iface_configure_tunnel(iface);
                 iface_set_mac(iface);
             }
         }
@@ -627,6 +629,21 @@ bridge_update_ofprotos(void)
     }
 }
 
+is_tunnel_tundev(const char *type)
+{
+    return !strcmp(type, "gre-tundev") || !strcmp(type, "capwap-tundev");
+}
+
+static uint8_t
+tunnel_tundev_type_from_str(const char *type)
+{
+    if (!strcmp(type, "gre-tundev"))
+        return TNL_T_PROTO_GRE;
+    if (!strcmp(type, "gre-tundev"))
+        return TNL_T_PROTO_CAPWAP;
+    NOT_REACHED();
+}
+
 static bool
 is_tunnel_realdev(const char *type)
 {
@@ -648,6 +665,15 @@ port_configure(struct port *port)
         return;
     }
 
+    if (list_is_singleton(&port->ifaces)) {
+        iface = CONTAINER_OF(list_front(&port->ifaces),
+                             struct iface, port_elem);
+        if (is_tunnel_tundev(iface->type)) {
+            ofproto_bundle_unregister(port->bridge->ofproto, port);
+            return;
+        }
+    }
+
     /* Get name. */
     s.name = port->name;
 
@@ -3686,6 +3712,49 @@ iface_configure_cfm(struct iface *iface)
     ofproto_port_set_cfm(iface->port->bridge->ofproto, iface->ofp_port, &s);
 }
 
+static void
+iface_configure_tunnel_tundev(struct iface *iface)
+{
+    const char *type = iface_get_type(iface->cfg, iface->port->bridge->cfg);
+    struct tunnel_settings s = { .type = tunnel_tundev_type_from_str(type) };
+
+    ofproto_port_set_tunnel(iface->port->bridge->ofproto, 0,
+                            iface->ofp_port, &s);
+}
+
+static void
+iface_configure_tunnel_realdev(struct iface *iface)
+{
+    struct tunnel_settings s = { .tos = 0 };
+    const char *type = iface_get_type(iface->cfg, iface->port->bridge->cfg);
+    struct iface *tundev;
+
+    /* This will not fail as it has already been called
+     * to check for errors */
+    iface_parse_tunnel(iface->cfg, type, &s);
+
+    tundev = iface_lookup(iface->port->bridge, type);
+    assert(tundev);
+
+    ofproto_port_set_tunnel(iface->port->bridge->ofproto, tundev->ofp_port,
+                            iface->ofp_port, &s);
+}
+
+static void
+iface_configure_tunnel(struct iface *iface)
+{
+    const char *type = iface_get_type(iface->cfg, iface->port->bridge->cfg);
+
+    if (is_tunnel_realdev(type)) {
+        return iface_configure_tunnel_realdev(iface);
+    } else if (is_tunnel_tundev(type)) {
+        return iface_configure_tunnel_tundev(iface);
+    }
+
+    /* Nothing to do */
+    return;
+}
+
 /* Returns true if 'iface' is synthetic, that is, if we constructed it locally
  * instead of obtaining it from the database. */
 static bool
-- 
1.7.10.2.484.gcd07cc5
