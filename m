From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 04/21] vswitchd: Add iface_parse_tunnel
Date: Thu, 24 May 2012 18:08:57 +0900
Message-ID: <1337850554-10339-5-git-send-email-horms@verge.net.au>
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

This duplicates parse_tunnel_config, the duplication will later be minimised.

iface_parse_tunnel() is currently only used to verify the configuration
by passing NULL as its third argument. It will later be used in storing
the configuration by passing a non-NULL argument. The purpose of verification
is to allow for error-free parsing later.

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 include/openvswitch/tunnel.h |   2 +
 ofproto/ofproto.h            |  33 +++++++
 vswitchd/bridge.c            | 214 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 249 insertions(+)

diff --git a/include/openvswitch/tunnel.h b/include/openvswitch/tunnel.h
index c494791..5f55ecc 100644
--- a/include/openvswitch/tunnel.h
+++ b/include/openvswitch/tunnel.h
@@ -71,5 +71,7 @@ enum {
 #define TNL_F_PMTUD		(1 << 5) /* Enable path MTU discovery. */
 #define TNL_F_HDR_CACHE		(1 << 6) /* Enable tunnel header caching. */
 #define TNL_F_IPSEC		(1 << 7) /* Traffic is IPsec encrypted. */
+#define TNL_F_IN_KEY	(1 << 8) /* Tunnel port has input key. */
+#define TNL_F_OUT_KEY	(1 << 9) /* Tunnel port has output key. */
 
 #endif /* openvswitch/tunnel.h */
diff --git a/ofproto/ofproto.h b/ofproto/ofproto.h
index ea988e7..d8739b0 100644
--- a/ofproto/ofproto.h
+++ b/ofproto/ofproto.h
@@ -367,7 +367,40 @@ void ofproto_get_vlan_usage(struct ofproto *, unsigned long int *vlan_bitmap);
 bool ofproto_has_vlan_usage_changed(const struct ofproto *);
 int ofproto_port_set_realdev(struct ofproto *, uint16_t vlandev_ofp_port,
                              uint16_t realdev_ofp_port, int vid);
+
+#define TNL_F_CSUM          (1 << 0) /* Checksum packets. */
+#define TNL_F_TOS_INHERIT	(1 << 1) /* Inherit ToS from inner packet. */
+#define TNL_F_TTL_INHERIT	(1 << 2) /* Inherit TTL from inner packet. */
+#define TNL_F_DF_INHERIT	(1 << 3) /* Inherit DF bit from inner packet. */
+#define TNL_F_DF_DEFAULT	(1 << 4) /* Set DF bit if inherit off or
+                                      * not IP. */
+#define TNL_F_PMTUD		    (1 << 5) /* Enable path MTU discovery. */
+#define TNL_F_HDR_CACHE		(1 << 6) /* Enable tunnel header caching. */
+#define TNL_F_IPSEC		    (1 << 7) /* Traffic is IPsec encrypted. */
+#define TNL_F_IN_KEY	    (1 << 8) /* Tunnel port has input key. */
+#define TNL_F_OUT_KEY	    (1 << 9) /* Tunnel port has output key. */
+
+#define TNL_T_PROTO_GRE     0
+#define TNL_T_PROTO_CAPWAP  1
+
+#define TNL_T_KEY_EXACT     (1 << 6)
+#define TNL_T_KEY_MATCH     (1 << 7)
+
+/* Tunnel device support */
+struct tunnel_settings {
+    ovs_be64 in_key;
+    ovs_be64 out_key;
+    ovs_be32 saddr;
+    ovs_be32 daddr;
+    uint8_t tos;
+    uint8_t ttl;
+    uint16_t flags;
+    uint8_t type;
+};
 
+void ofproto_port_set_tunnel(struct ofproto *ofproto, uint16_t tundev_ofp_port,
+                             uint16_t realdev_ofp_port,
+                             const struct tunnel_settings *s);
 #ifdef  __cplusplus
 }
 #endif
diff --git a/vswitchd/bridge.c b/vswitchd/bridge.c
index d720952..f775ae7 100644
--- a/vswitchd/bridge.c
+++ b/vswitchd/bridge.c
@@ -20,6 +20,7 @@
 #include <inttypes.h>
 #include <stdlib.h>
 #include "bitmap.h"
+#include "byte-order.h"
 #include "bond.h"
 #include "cfm.h"
 #include "coverage.h"
@@ -625,6 +626,13 @@ bridge_update_ofprotos(void)
     }
 }
 
+static bool
+is_tunnel_realdev(const char *type)
+{
+    return !strcmp(type, "gre") || !strcmp(type, "ipsec_gre") ||
+            !strcmp(type, "capwap");
+}
+
 static void
 port_configure(struct port *port)
 {
@@ -1333,6 +1341,207 @@ error:
     return error;
 }
 
+
+static const char *
+get_key(const struct shash *args, const char *name)
+{
+    const char *s;
+
+    s = shash_find_data(args, name);
+    if (!s) {
+        s = shash_find_data(args, "key");
+        if (!s) {
+            s = "0";
+        }
+    }
+
+    if (!strcmp(s, "flow")) {
+        /* This is the default if no attribute is present. */
+        return NULL;
+    }
+
+    return s;
+}
+
+static int
+iface_parse_tunnel(const struct ovsrec_interface *iface_cfg,
+                   const char *type, struct tunnel_settings *sp)
+{
+    bool is_gre = false;
+    bool is_ipsec = false;
+    struct shash args;
+    struct shash_node *node;
+    struct tunnel_settings s = { .tos = 0 };
+    bool ipsec_mech_set = false;
+    int status;
+    const char *key;
+
+    shash_init(&args);
+    shash_from_ovs_idl_map(iface_cfg->key_options,
+                           iface_cfg->value_options,
+                           iface_cfg->n_options, &args);
+
+    s.flags = TNL_F_DF_DEFAULT | TNL_F_PMTUD | TNL_F_HDR_CACHE;
+    if (!strcmp(type, "gre")) {
+        is_gre = true;
+        s.type = TNL_T_PROTO_GRE;
+    } else if (!strcmp(type, "ipsec_gre")) {
+        is_gre = true;
+        s.type = TNL_T_PROTO_GRE;
+        is_ipsec = true;
+        s.flags |= TNL_F_IPSEC;
+        s.flags &= ~TNL_F_HDR_CACHE;
+    } else if (strcmp(type, "capwap")) {
+        s.type = TNL_T_PROTO_CAPWAP;
+    }
+
+    SHASH_FOR_EACH (node, &args) {
+        if (!strcmp(node->name, "remote_ip")) {
+            struct in_addr in_addr;
+            if (lookup_ip(node->data, &in_addr)) {
+                VLOG_WARN("%s: bad %s 'remote_ip'", iface_cfg->name, type);
+            } else {
+                s.daddr = in_addr.s_addr;
+            }
+        } else if (!strcmp(node->name, "local_ip")) {
+            struct in_addr in_addr;
+            if (lookup_ip(node->data, &in_addr)) {
+                VLOG_WARN("%s: bad %s 'local_ip'", iface_cfg->name, type);
+            } else {
+                s.saddr = in_addr.s_addr;
+            }
+        } else if (!strcmp(node->name, "tos")) {
+            if (!strcmp(node->data, "inherit")) {
+                s.flags |= TNL_F_TOS_INHERIT;
+            } else {
+                s.tos = atoi(node->data);
+            }
+        } else if (!strcmp(node->name, "ttl")) {
+            if (!strcmp(node->data, "inherit")) {
+                s.flags |= TNL_F_TTL_INHERIT;
+            } else {
+                s.ttl = atoi(node->data);
+            }
+        } else if (!strcmp(node->name, "csum") && is_gre) {
+            if (!strcmp(node->data, "true")) {
+                s.flags |= TNL_F_CSUM;
+            }
+        } else if (!strcmp(node->name, "df_inherit")) {
+            if (!strcmp(node->data, "true")) {
+                s.flags |= TNL_F_DF_INHERIT;
+            }
+        } else if (!strcmp(node->name, "df_default")) {
+            if (!strcmp(node->data, "false")) {
+                s.flags &= ~TNL_F_DF_DEFAULT;
+            }
+        } else if (!strcmp(node->name, "pmtud")) {
+            if (!strcmp(node->data, "false")) {
+                s.flags &= ~TNL_F_PMTUD;
+            }
+        } else if (!strcmp(node->name, "header_cache")) {
+            if (!strcmp(node->data, "false")) {
+                s.flags &= ~TNL_F_HDR_CACHE;
+            }
+        } else if (!strcmp(node->name, "peer_cert") && is_ipsec) {
+            if (shash_find(&args, "certificate")) {
+                ipsec_mech_set = true;
+            } else {
+                const char *use_ssl_cert;
+
+                /* If the "use_ssl_cert" is true, then "certificate" and
+                 * "private_key" will be pulled from the SSL table.  The
+                 * use of this option is strongly discouraged, since it
+                 * will like be removed when multiple SSL configurations
+                 * are supported by OVS.
+                 */
+                use_ssl_cert = shash_find_data(&args, "use_ssl_cert");
+                if (!use_ssl_cert || strcmp(use_ssl_cert, "true")) {
+                    VLOG_ERR("%s: 'peer_cert' requires 'certificate' argument",
+                             iface_cfg->name);
+                    goto err;
+                }
+                ipsec_mech_set = true;
+            }
+        } else if (!strcmp(node->name, "psk") && is_ipsec) {
+            ipsec_mech_set = true;
+        } else if (is_ipsec
+                && (!strcmp(node->name, "certificate")
+                    || !strcmp(node->name, "private_key")
+                    || !strcmp(node->name, "use_ssl_cert"))) {
+            /* Ignore options not used by the netdev. */
+        } else if (!strcmp(node->name, "key") ||
+                   !strcmp(node->name, "in_key") ||
+                   !strcmp(node->name, "out_key")) {
+            /* Handled separately below. */
+        } else {
+            VLOG_WARN("%s: unknown %s argument '%s'", iface_cfg->name,
+                      type, node->name);
+        }
+    }
+
+    if (is_ipsec) {
+        char *file_name = xasprintf("%s/%s", ovs_rundir(),
+                "ovs-monitor-ipsec.pid");
+        pid_t pid = read_pidfile(file_name);
+        free(file_name);
+        if (pid < 0) {
+            VLOG_ERR("%s: IPsec requires the ovs-monitor-ipsec daemon",
+                     iface_cfg->name);
+            goto err;
+        }
+
+        if (shash_find(&args, "peer_cert") && shash_find(&args, "psk")) {
+            VLOG_ERR("%s: cannot define both 'peer_cert' and 'psk'",
+                     iface_cfg->name);
+            goto err;
+        }
+
+        if (!ipsec_mech_set) {
+            VLOG_ERR("%s: IPsec requires an 'peer_cert' or psk' argument",
+                     iface_cfg->name);
+            goto err;
+        }
+    }
+
+    if ((key = get_key(&args, "in_key"))) {
+        s.flags |= TNL_F_IN_KEY;
+        s.type |= TNL_T_KEY_EXACT;
+        s.in_key = htonll(strtoull(key, NULL, 0));
+    } else {
+        s.type |= TNL_T_KEY_MATCH;
+        s.in_key = 0ULL;
+    }
+    if ((key = get_key(&args, "out_key"))) {
+        s.flags |= TNL_F_OUT_KEY;
+        s.out_key = htonll(strtoull(key, NULL, 0));
+    } else {
+        s.out_key = 0ULL;
+    }
+
+    if (!s.daddr) {
+        VLOG_ERR("%s: %s type requires valid 'remote_ip' argument",
+                 iface_cfg->name, type);
+        goto err;
+    }
+
+    if (s.saddr) {
+        if (ip_is_multicast(s.daddr)) {
+            VLOG_WARN("%s: remote_ip is multicast, ignoring local_ip",
+                      iface_cfg->name);
+            s.saddr = 0;
+        }
+    }
+
+    if (sp) {
+            *sp = s;
+    }
+
+    status = 0;
+err:
+    shash_destroy(&args);
+    return status;
+}
+
 /* Creates a new iface on 'br' based on 'if_cfg'.  The new iface has OpenFlow
  * port number 'ofp_port'.  If ofp_port is negative, an OpenFlow port is
  * automatically allocated for the iface.  Takes ownership of and
@@ -1344,6 +1553,7 @@ iface_create(struct bridge *br, struct if_cfg *if_cfg, int ofp_port)
 {
     const struct ovsrec_interface *iface_cfg = if_cfg->cfg;
     const struct ovsrec_port *port_cfg = if_cfg->parent;
+    const char *type = iface_get_type(iface_cfg, br->cfg);
 
     struct netdev *netdev;
     struct iface *iface;
@@ -1355,6 +1565,10 @@ iface_create(struct bridge *br, struct if_cfg *if_cfg, int ofp_port)
     hmap_remove(&br->if_cfg_todo, &if_cfg->hmap_node);
     free(if_cfg);
 
+    if (is_tunnel_realdev(type) && iface_parse_tunnel(iface_cfg, type, NULL)) {
+        return false;
+    }
+
     /* Do the bits that can fail up front. */
     assert(!iface_lookup(br, iface_cfg->name));
     error = iface_do_create(br, iface_cfg, port_cfg, &ofp_port, &netdev);
-- 
1.7.10.2.484.gcd07cc5
