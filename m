From: Andy Zhou <azhou@ovn.org>
Subject: [userspace meter v3 3/5] dpif: Meter framework.
Date: Mon, 30 Jan 2017 22:39:58 -0800
Message-ID: <1485844800-2873-4-git-send-email-azhou@ovn.org>
References: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Jarno Rajahalme <jarno@ovn.org>,
        Andy Zhou <azhou@ovn.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33082 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751026AbdAaHBh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 02:01:37 -0500
Received: by mail-pf0-f196.google.com with SMTP id e4so26266057pfg.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 23:01:37 -0800 (PST)
In-Reply-To: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>

Add DPIF-level infrastructure for meters.  Allow meter_set to modify
the meter configuration (e.g. set the burst size if unspecified).

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 datapath/linux/compat/include/linux/openvswitch.h |  4 +-
 lib/dpif-netdev.c                                 | 45 ++++++++++++
 lib/dpif-netlink.c                                | 46 +++++++++++-
 lib/dpif-provider.h                               | 29 ++++++++
 lib/dpif.c                                        | 88 +++++++++++++++++++++++
 lib/dpif.h                                        | 13 +++-
 lib/odp-execute.c                                 |  3 +
 lib/odp-util.c                                    | 14 ++++
 ofproto/ofproto-dpif-sflow.c                      |  1 +
 ofproto/ofproto-dpif.c                            | 60 ++++++++++++++--
 ofproto/ofproto-provider.h                        | 13 ++--
 ofproto/ofproto.c                                 |  2 +-
 12 files changed, 304 insertions(+), 14 deletions(-)

diff --git a/datapath/linux/compat/include/linux/openvswitch.h b/datapath/linux/compat/include/linux/openvswitch.h
index 425d3a4..b121391 100644
--- a/datapath/linux/compat/include/linux/openvswitch.h
+++ b/datapath/linux/compat/include/linux/openvswitch.h
@@ -787,13 +787,14 @@ enum ovs_nat_attr {
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
  * type may not be changed.
  *
- *
  * @OVS_ACTION_ATTR_SET_TO_MASKED: Kernel internal masked set action translated
  * from the @OVS_ACTION_ATTR_SET.
  * @OVS_ACTION_ATTR_TUNNEL_PUSH: Push tunnel header described by struct
  * ovs_action_push_tnl.
  * @OVS_ACTION_ATTR_TUNNEL_POP: Lookup tunnel port by port-no passed and pop
  * tunnel header.
+ * @OVS_ACTION_ATTR_METER: Run packet through a meter, which may drop the
+ * packet, or modify the packet (e.g., change the DSCP field).
  */
 
 enum ovs_action_attr {
@@ -819,6 +820,7 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_TUNNEL_PUSH,   /* struct ovs_action_push_tnl*/
 	OVS_ACTION_ATTR_TUNNEL_POP,    /* u32 port number. */
 	OVS_ACTION_ATTR_CLONE,         /* Nested OVS_CLONE_ATTR_*.  */
+	OVS_ACTION_ATTR_METER,         /* u32 meter number. */
 #endif
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index 719a518..f81b464 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -3597,6 +3597,46 @@ dp_netdev_disable_upcall(struct dp_netdev *dp)
     fat_rwlock_wrlock(&dp->upcall_rwlock);
 }
 
+
+/* Meters */
+static void
+dpif_netdev_meter_get_features(const struct dpif * dpif OVS_UNUSED,
+                               struct ofputil_meter_features *features)
+{
+    features->max_meters = 0;
+    features->band_types = 0;
+    features->capabilities = 0;
+    features->max_bands = 0;
+    features->max_color = 0;
+}
+
+static int
+dpif_netdev_meter_set(struct dpif *dpif OVS_UNUSED,
+                      ofproto_meter_id *meter_id OVS_UNUSED,
+                      struct ofputil_meter_config *config OVS_UNUSED)
+{
+    return EFBIG; /* meter_id out of range */
+}
+
+static int
+dpif_netdev_meter_get(const struct dpif *dpif OVS_UNUSED,
+                      ofproto_meter_id meter_id OVS_UNUSED,
+                      struct ofputil_meter_stats *stats OVS_UNUSED,
+                      uint16_t n_bands OVS_UNUSED)
+{
+    return EFBIG; /* meter_id out of range */
+}
+
+static int
+dpif_netdev_meter_del(struct dpif *dpif OVS_UNUSED,
+                      ofproto_meter_id meter_id OVS_UNUSED,
+                      struct ofputil_meter_stats *stats OVS_UNUSED,
+                      uint16_t n_bands OVS_UNUSED)
+{
+    return EFBIG; /* meter_id out of range */
+}
+
+
 static void
 dpif_netdev_disable_upcall(struct dpif *dpif)
     OVS_NO_THREAD_SAFETY_ANALYSIS
@@ -4721,6 +4761,7 @@ dp_execute_cb(void *aux_, struct dp_packet_batch *packets_,
         break;
     }
 
+    case OVS_ACTION_ATTR_METER:
     case OVS_ACTION_ATTR_PUSH_VLAN:
     case OVS_ACTION_ATTR_POP_VLAN:
     case OVS_ACTION_ATTR_PUSH_MPLS:
@@ -4858,6 +4899,10 @@ const struct dpif_class dpif_netdev_class = {
     dpif_netdev_ct_dump_next,
     dpif_netdev_ct_dump_done,
     dpif_netdev_ct_flush,
+    dpif_netdev_meter_get_features,
+    dpif_netdev_meter_set,
+    dpif_netdev_meter_get,
+    dpif_netdev_meter_del,
 };
 
 static void
diff --git a/lib/dpif-netlink.c b/lib/dpif-netlink.c
index c8b0e37..8a48227 100644
--- a/lib/dpif-netlink.c
+++ b/lib/dpif-netlink.c
@@ -2356,6 +2356,46 @@ dpif_netlink_ct_flush(struct dpif *dpif OVS_UNUSED, const uint16_t *zone)
     }
 }
 
+
+/* Meters */
+static void
+dpif_netlink_meter_get_features(const struct dpif * dpif OVS_UNUSED,
+                                struct ofputil_meter_features *features)
+{
+    features->max_meters = 0;
+    features->band_types = 0;
+    features->capabilities = 0;
+    features->max_bands = 0;
+    features->max_color = 0;
+}
+
+static int
+dpif_netlink_meter_set(struct dpif *dpif OVS_UNUSED,
+                       ofproto_meter_id *meter_id OVS_UNUSED,
+                       struct ofputil_meter_config *config OVS_UNUSED)
+{
+    return EFBIG; /* meter_id out of range */
+}
+
+static int
+dpif_netlink_meter_get(const struct dpif *dpif OVS_UNUSED,
+                       ofproto_meter_id meter_id OVS_UNUSED,
+                       struct ofputil_meter_stats *stats OVS_UNUSED,
+                       uint16_t n_bands OVS_UNUSED)
+{
+    return EFBIG; /* meter_id out of range */
+}
+
+static int
+dpif_netlink_meter_del(struct dpif *dpif OVS_UNUSED,
+                       ofproto_meter_id meter_id OVS_UNUSED,
+                       struct ofputil_meter_stats *stats OVS_UNUSED,
+                       uint16_t n_bands OVS_UNUSED)
+{
+    return EFBIG; /* meter_id out of range */
+}
+
+
 const struct dpif_class dpif_netlink_class = {
     "system",
     NULL,                       /* init */
@@ -2400,7 +2440,11 @@ const struct dpif_class dpif_netlink_class = {
     dpif_netlink_ct_dump_start,
     dpif_netlink_ct_dump_next,
     dpif_netlink_ct_dump_done,
-    dpif_netlink_ct_flush
+    dpif_netlink_ct_flush,
+    dpif_netlink_meter_get_features,
+    dpif_netlink_meter_set,
+    dpif_netlink_meter_get,
+    dpif_netlink_meter_del,
 };
 
 static int
diff --git a/lib/dpif-provider.h b/lib/dpif-provider.h
index d3b2bb9..ea3e152 100644
--- a/lib/dpif-provider.h
+++ b/lib/dpif-provider.h
@@ -427,6 +427,35 @@ struct dpif_class {
     /* Flushes the connection tracking tables. If 'zone' is not NULL,
      * only deletes connections in '*zone'. */
     int (*ct_flush)(struct dpif *, const uint16_t *zone);
+
+    /* Meters */
+
+    /* Queries 'dpif' for supported meter features.
+     * NULL pointer means no meter features are supported. */
+    void (*meter_get_features)(const struct dpif *,
+                               struct ofputil_meter_features *);
+
+    /* Adds or modifies 'meter' in 'dpif'.   If '*meter_id' is UINT32_MAX,
+     * adds a new meter, otherwise modifies an existing meter.
+     *
+     * If meter is successfully added, sets '*meter_id' to the new meter's
+     * meter id selected by 'dpif'. */
+    int (*meter_set)(struct dpif *, ofproto_meter_id *meter_id,
+                     struct ofputil_meter_config *);
+
+    /* Queries 'dpif' for meter stats with the given 'meter_id'.  Stores
+     * maximum of 'n_bands' meter statistics, returning the number of band
+     * stats returned in 'stats->n_bands' if successful. */
+    int (*meter_get)(const struct dpif *, ofproto_meter_id meter_id,
+                     struct ofputil_meter_stats *, uint16_t n_bands);
+
+    /* Removes meter 'meter_id' from 'dpif'. Stores meter and band statistics
+     * (for maximum of 'n_bands', returning the number of band stats returned
+     * in 'stats->n_bands' if successful.  'stats' may be passed in as NULL if
+     * no stats are needed, in which case 'n_bands' must be passed in as
+     * zero. */
+    int (*meter_del)(struct dpif *, ofproto_meter_id meter_id,
+                     struct ofputil_meter_stats *, uint16_t n_bands);
 };
 
 extern const struct dpif_class dpif_netlink_class;
diff --git a/lib/dpif.c b/lib/dpif.c
index 374f013..4e9476c 100644
--- a/lib/dpif.c
+++ b/lib/dpif.c
@@ -63,6 +63,9 @@ COVERAGE_DEFINE(dpif_flow_del);
 COVERAGE_DEFINE(dpif_execute);
 COVERAGE_DEFINE(dpif_purge);
 COVERAGE_DEFINE(dpif_execute_with_help);
+COVERAGE_DEFINE(dpif_meter_set);
+COVERAGE_DEFINE(dpif_meter_get);
+COVERAGE_DEFINE(dpif_meter_del);
 
 static const struct dpif_class *base_dpif_classes[] = {
 #if defined(__linux__) || defined(_WIN32)
@@ -1174,6 +1177,7 @@ dpif_execute_helper_cb(void *aux_, struct dp_packet_batch *packets_,
     }
 
     case OVS_ACTION_ATTR_HASH:
+    case OVS_ACTION_ATTR_METER:
     case OVS_ACTION_ATTR_PUSH_VLAN:
     case OVS_ACTION_ATTR_POP_VLAN:
     case OVS_ACTION_ATTR_PUSH_MPLS:
@@ -1757,3 +1761,87 @@ dpif_supports_tnl_push_pop(const struct dpif *dpif)
 {
     return dpif_is_netdev(dpif);
 }
+
+/* Meters */
+void
+dpif_meter_get_features(const struct dpif *dpif,
+                        struct ofputil_meter_features *features)
+{
+    memset(features, 0, sizeof *features);
+    if (dpif->dpif_class->meter_get_features) {
+        dpif->dpif_class->meter_get_features(dpif, features);
+    }
+}
+
+/* Adds or modifies meter identified by 'meter_id' in 'dpif'.  If '*meter_id'
+ * is UINT32_MAX, adds a new meter, otherwise modifies an existing meter.
+ *
+ * If meter is successfully added, sets '*meter_id' to the new meter's
+ * meter number. */
+int
+dpif_meter_set(struct dpif *dpif, ofproto_meter_id *meter_id,
+               struct ofputil_meter_config *config)
+{
+    int error;
+
+    COVERAGE_INC(dpif_meter_set);
+
+    error = dpif->dpif_class->meter_set(dpif, meter_id, config);
+    if (!error) {
+        VLOG_DBG_RL(&dpmsg_rl, "%s: DPIF meter %"PRIu32" set",
+                    dpif_name(dpif), meter_id->uint32);
+    } else {
+        VLOG_WARN_RL(&error_rl, "%s: failed to set DPIF meter %"PRIu32": %s",
+                     dpif_name(dpif), meter_id->uint32, ovs_strerror(error));
+        meter_id->uint32 = UINT32_MAX;
+    }
+    return error;
+}
+
+int
+dpif_meter_get(const struct dpif *dpif, ofproto_meter_id meter_id,
+               struct ofputil_meter_stats *stats, uint16_t n_bands)
+{
+    int error;
+
+    COVERAGE_INC(dpif_meter_get);
+
+    error = dpif->dpif_class->meter_get(dpif, meter_id, stats, n_bands);
+    if (!error) {
+        VLOG_DBG_RL(&dpmsg_rl, "%s: DPIF meter %"PRIu32" get stats",
+                    dpif_name(dpif), meter_id.uint32);
+    } else {
+        VLOG_WARN_RL(&error_rl,
+                     "%s: failed to get DPIF meter %"PRIu32" stats: %s",
+                     dpif_name(dpif), meter_id.uint32, ovs_strerror(error));
+        stats->packet_in_count = ~0;
+        stats->byte_in_count = ~0;
+        stats->n_bands = 0;
+    }
+    return error;
+}
+
+int
+dpif_meter_del(struct dpif *dpif, ofproto_meter_id meter_id,
+               struct ofputil_meter_stats *stats, uint16_t n_bands)
+{
+    int error;
+
+    COVERAGE_INC(dpif_meter_del);
+
+    error = dpif->dpif_class->meter_del(dpif, meter_id, stats, n_bands);
+    if (!error) {
+        VLOG_DBG_RL(&dpmsg_rl, "%s: DPIF meter %"PRIu32" deleted",
+                    dpif_name(dpif), meter_id.uint32);
+    } else {
+        VLOG_WARN_RL(&error_rl,
+                     "%s: failed to delete DPIF meter %"PRIu32": %s",
+                     dpif_name(dpif), meter_id.uint32, ovs_strerror(error));
+        if (stats) {
+            stats->packet_in_count = ~0;
+            stats->byte_in_count = ~0;
+            stats->n_bands = 0;
+        }
+    }
+    return error;
+}
diff --git a/lib/dpif.h b/lib/dpif.h
index aa4fb8b..851fdc2 100644
--- a/lib/dpif.h
+++ b/lib/dpif.h
@@ -389,9 +389,10 @@
 #include <stdint.h>
 
 #include "dpdk.h"
-#include "netdev.h"
 #include "dp-packet.h"
+#include "netdev.h"
 #include "openflow/openflow.h"
+#include "openvswitch/ofp-util.h"
 #include "ovs-numa.h"
 #include "packets.h"
 #include "util.h"
@@ -856,6 +857,16 @@ void dpif_disable_upcall(struct dpif *);
 
 void dpif_print_packet(struct dpif *, struct dpif_upcall *);
 
+/* Meters. */
+void dpif_meter_get_features(const struct dpif *,
+                             struct ofputil_meter_features *);
+int dpif_meter_set(struct dpif *, ofproto_meter_id *meter_id,
+                   struct ofputil_meter_config *);
+int dpif_meter_get(const struct dpif *, ofproto_meter_id meter_id,
+                   struct ofputil_meter_stats *, uint16_t n_bands);
+int dpif_meter_del(struct dpif *, ofproto_meter_id meter_id,
+                   struct ofputil_meter_stats *, uint16_t n_bands);
+
 /* Miscellaneous. */
 
 void dpif_get_netflow_ids(const struct dpif *,
diff --git a/lib/odp-execute.c b/lib/odp-execute.c
index 465280b..dd31c98 100644
--- a/lib/odp-execute.c
+++ b/lib/odp-execute.c
@@ -561,6 +561,7 @@ requires_datapath_assistance(const struct nlattr *a)
     case OVS_ACTION_ATTR_USERSPACE:
     case OVS_ACTION_ATTR_RECIRC:
     case OVS_ACTION_ATTR_CT:
+    case OVS_ACTION_ATTR_METER:
         return true;
 
     case OVS_ACTION_ATTR_SET:
@@ -714,6 +715,8 @@ odp_execute_actions(void *dp, struct dp_packet_batch *batch, bool steal,
                  * stolen them.  */
                 return;
             }
+        case OVS_ACTION_ATTR_METER:
+            /* Not implemented yet. */
             break;
 
         case OVS_ACTION_ATTR_OUTPUT:
diff --git a/lib/odp-util.c b/lib/odp-util.c
index 430793b..5545f75 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -110,6 +110,7 @@ odp_action_len(uint16_t type)
     case OVS_ACTION_ATTR_TRUNC: return sizeof(struct ovs_action_trunc);
     case OVS_ACTION_ATTR_TUNNEL_PUSH: return ATTR_LEN_VARIABLE;
     case OVS_ACTION_ATTR_TUNNEL_POP: return sizeof(uint32_t);
+    case OVS_ACTION_ATTR_METER: return sizeof(uint32_t);
     case OVS_ACTION_ATTR_USERSPACE: return ATTR_LEN_VARIABLE;
     case OVS_ACTION_ATTR_PUSH_VLAN: return sizeof(struct ovs_action_push_vlan);
     case OVS_ACTION_ATTR_POP_VLAN: return 0;
@@ -794,6 +795,9 @@ format_odp_action(struct ds *ds, const struct nlattr *a)
     }
 
     switch (type) {
+    case OVS_ACTION_ATTR_METER:
+        ds_put_format(ds, "meter(%"PRIu32")", nl_attr_get_u32(a));
+        break;
     case OVS_ACTION_ATTR_OUTPUT:
         ds_put_format(ds, "%"PRIu32, nl_attr_get_u32(a));
         break;
@@ -1683,6 +1687,16 @@ parse_odp_action(const char *s, const struct simap *port_names,
     }
 
     {
+        unsigned long long int meter_id;
+        int n = -1;
+
+        if (sscanf(s, "meter(%lli)%n", &meter_id, &n) > 0 && n > 0) {
+            nl_msg_put_u32(actions, OVS_ACTION_ATTR_METER, meter_id);
+            return n;
+        }
+    }
+
+    {
         double percentage;
         int n = -1;
 
diff --git a/ofproto/ofproto-dpif-sflow.c b/ofproto/ofproto-dpif-sflow.c
index e4ae760..f10ccd0 100644
--- a/ofproto/ofproto-dpif-sflow.c
+++ b/ofproto/ofproto-dpif-sflow.c
@@ -1132,6 +1132,7 @@ dpif_sflow_read_actions(const struct flow *flow,
 	case OVS_ACTION_ATTR_RECIRC:
 	case OVS_ACTION_ATTR_HASH:
         case OVS_ACTION_ATTR_CT:
+        case OVS_ACTION_ATTR_METER:
 	    break;
 
 	case OVS_ACTION_ATTR_SET_MASKED:
diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index e1112eb..cf9fb21 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -5185,6 +5185,58 @@ ofproto_dpif_delete_internal_flow(struct ofproto_dpif *ofproto,
     return 0;
 }
 
+static void
+meter_get_features(const struct ofproto *ofproto_,
+                   struct ofputil_meter_features *features)
+{
+    const struct ofproto_dpif *ofproto = ofproto_dpif_cast(ofproto_);
+
+    dpif_meter_get_features(ofproto->backer->dpif, features);
+}
+
+static enum ofperr
+meter_set(struct ofproto *ofproto_, ofproto_meter_id *meter_id,
+          struct ofputil_meter_config *config)
+{
+    struct ofproto_dpif *ofproto = ofproto_dpif_cast(ofproto_);
+
+    switch (dpif_meter_set(ofproto->backer->dpif, meter_id, config)) {
+    case 0:
+        return 0;
+    case EFBIG: /* meter_id out of range */
+    case ENOMEM: /* Cannot allocate meter */
+        return OFPERR_OFPMMFC_OUT_OF_METERS;
+    case EBADF: /* Unsupported flags */
+        return OFPERR_OFPMMFC_BAD_FLAGS;
+    case EINVAL: /* Too many bands */
+        return OFPERR_OFPMMFC_OUT_OF_BANDS;
+    case ENODEV: /* Unsupported band type */
+        return OFPERR_OFPMMFC_BAD_BAND;
+    default:
+        return OFPERR_OFPMMFC_UNKNOWN;
+    }
+}
+
+static enum ofperr
+meter_get(const struct ofproto *ofproto_, ofproto_meter_id meter_id,
+          struct ofputil_meter_stats *stats, uint16_t n_bands)
+{
+    const struct ofproto_dpif *ofproto = ofproto_dpif_cast(ofproto_);
+
+    if (!dpif_meter_get(ofproto->backer->dpif, meter_id, stats, n_bands)) {
+        return 0;
+    }
+    return OFPERR_OFPMMFC_UNKNOWN_METER;
+}
+
+static void
+meter_del(struct ofproto *ofproto_, ofproto_meter_id meter_id)
+{
+    struct ofproto_dpif *ofproto = ofproto_dpif_cast(ofproto_);
+
+    dpif_meter_del(ofproto->backer->dpif, meter_id, NULL, 0);
+}
+
 const struct ofproto_class ofproto_dpif_class = {
     init,
     enumerate_types,
@@ -5273,10 +5325,10 @@ const struct ofproto_class ofproto_dpif_class = {
     set_mac_table_config,
     set_mcast_snooping,
     set_mcast_snooping_port,
-    NULL,                       /* meter_get_features */
-    NULL,                       /* meter_set */
-    NULL,                       /* meter_get */
-    NULL,                       /* meter_del */
+    meter_get_features,
+    meter_set,
+    meter_get,
+    meter_del,
     group_alloc,                /* group_alloc */
     group_construct,            /* group_construct */
     group_destruct,             /* group_destruct */
diff --git a/ofproto/ofproto-provider.h b/ofproto/ofproto-provider.h
index 3739ebc..abe9cb8 100644
--- a/ofproto/ofproto-provider.h
+++ b/ofproto/ofproto-provider.h
@@ -1769,16 +1769,17 @@ struct ofproto_class {
      * leaving '*id' unchanged.  On failure, the existing meter configuration
      * is left intact. */
     enum ofperr (*meter_set)(struct ofproto *ofproto, ofproto_meter_id *id,
-                             const struct ofputil_meter_config *config);
+                             struct ofputil_meter_config *config);
 
     /* Gets the meter and meter band packet and byte counts for maximum of
-     * 'stats->n_bands' bands for the meter with provider ID 'id' within
-     * 'ofproto'.  The caller fills in the other stats values.  The band stats
-     * are copied to memory at 'stats->bands' provided by the caller.  The
-     * number of returned band stats is returned in 'stats->n_bands'. */
+     * 'n_bands' bands for the meter with provider ID 'id' within 'ofproto'.
+     * The caller fills in the other stats values.  The band stats are copied
+     * to memory at 'stats->bands' provided by the caller.  The number of
+     * returned band stats is returned in 'stats->n_bands'. */
     enum ofperr (*meter_get)(const struct ofproto *ofproto,
                              ofproto_meter_id id,
-                             struct ofputil_meter_stats *stats);
+                             struct ofputil_meter_stats *stats,
+                             uint16_t n_bands);
 
     /* Deletes a meter, making the 'ofproto_meter_id' invalid for any
      * further calls. */
diff --git a/ofproto/ofproto.c b/ofproto/ofproto.c
index 0b5e0fa..49652d7 100644
--- a/ofproto/ofproto.c
+++ b/ofproto/ofproto.c
@@ -6423,7 +6423,7 @@ handle_meter_request(struct ofconn *ofconn, const struct ofp_header *request,
 
             if (!ofproto->ofproto_class->meter_get(ofproto,
                                                    meter->provider_meter_id,
-                                                   &stats)) {
+                                                   &stats, meter->n_bands)) {
                 ofputil_append_meter_stats(&replies, &stats);
             }
         } else { /* type == OFPTYPE_METER_CONFIG_REQUEST */
-- 
1.9.1
