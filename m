From: Andy Zhou <azhou@ovn.org>
Subject: [userspace meter v3 5/5] dpif-netdev: Simple DROP meter implementation.
Date: Mon, 30 Jan 2017 22:40:00 -0800
Message-ID: <1485844800-2873-6-git-send-email-azhou@ovn.org>
References: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Jarno Rajahalme <jarno@ovn.org>,
        Andy Zhou <azhou@ovn.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35411 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751052AbdAaHBk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 02:01:40 -0500
Received: by mail-pf0-f194.google.com with SMTP id f144so26356122pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 23:01:40 -0800 (PST)
In-Reply-To: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jarno@ovn.org>

Meters may be used by any flow, so some kind of locking must be used.
In this version we have an adaptive mutex for each meter, which may
not be optimal for DPDK.  However, this should serve as a basis for
further improvement.

A batch of packets is first tried as a whole, and only if some of the
meter bands are hit, we need to process the packets individually.

Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 lib/dpif-netdev.c    | 362 ++++++++++++++++++++++++++++++++++++++++++++++++---
 tests/dpif-netdev.at | 106 +++++++++++++++
 2 files changed, 450 insertions(+), 18 deletions(-)

diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index f81b464..96c283a 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -86,6 +86,8 @@ DEFINE_STATIC_PER_THREAD_DATA(uint32_t, recirc_depth, 0)
 
 /* Configuration parameters. */
 enum { MAX_FLOWS = 65536 };     /* Maximum number of flows in flow table. */
+enum { MAX_METERS = 65536 };    /* Maximum number of meters. */
+enum { MAX_BANDS = 8 };         /* Maximum number of bands / meter. */
 
 /* Protects against changes to 'dp_netdevs'. */
 static struct ovs_mutex dp_netdev_mutex = OVS_MUTEX_INITIALIZER;
@@ -193,6 +195,31 @@ static bool dpcls_lookup(struct dpcls *cls,
                          struct dpcls_rule **rules, size_t cnt,
                          int *num_lookups_p);
 
+/* Set of supported meter flags */
+#define DP_SUPPORTED_METER_FLAGS_MASK \
+    (OFPMF13_STATS | OFPMF13_PKTPS | OFPMF13_KBPS | OFPMF13_BURST)
+
+/* Set of supported meter band types */
+#define DP_SUPPORTED_METER_BAND_TYPES           \
+    ( 1 << OFPMBT13_DROP )
+
+struct dp_meter_band {
+    struct ofputil_meter_band up; /* type, prec_level, pad, rate, burst_size */
+    uint32_t bucket; /* In 1/1000 packets (for PKTPS), or in bits (for KBPS) */
+    uint64_t packet_count;
+    uint64_t byte_count;
+};
+
+struct dp_meter {
+    uint16_t flags;
+    uint16_t n_bands;
+    uint32_t max_delta_t;
+    uint64_t used;
+    uint64_t packet_count;
+    uint64_t byte_count;
+    struct dp_meter_band bands[];
+};
+
 /* Datapath based on the network device interface from netdev.h.
  *
  *
@@ -223,6 +250,11 @@ struct dp_netdev {
     struct hmap ports;
     struct seq *port_seq;       /* Incremented whenever a port changes. */
 
+    /* Meters. */
+    struct ovs_mutex meter_locks[MAX_METERS];
+    struct dp_meter *meters[MAX_METERS]; /* Meter bands. */
+    uint32_t meter_free;                 /* Next free meter. */
+
     /* Protects access to ofproto-dpif-upcall interface during revalidator
      * thread synchronization. */
     struct fat_rwlock upcall_rwlock;
@@ -1059,6 +1091,10 @@ create_dp_netdev(const char *name, const struct dpif_class *class,
     dp->reconfigure_seq = seq_create();
     dp->last_reconfigure_seq = seq_read(dp->reconfigure_seq);
 
+    for (int i = 0; i < MAX_METERS; ++i) {
+        ovs_mutex_init_adaptive(&dp->meter_locks[i]);
+    }
+
     /* Disable upcalls by default. */
     dp_netdev_disable_upcall(dp);
     dp->upcall_aux = NULL;
@@ -1136,6 +1172,16 @@ dp_netdev_destroy_upcall_lock(struct dp_netdev *dp)
     fat_rwlock_destroy(&dp->upcall_rwlock);
 }
 
+static void
+dp_delete_meter(struct dp_netdev *dp, uint32_t meter_id)
+    OVS_REQUIRES(dp->meter_locks[meter_id])
+{
+    if (dp->meters[meter_id]) {
+        free(dp->meters[meter_id]);
+        dp->meters[meter_id] = NULL;
+    }
+}
+
 /* Requires dp_netdev_mutex so that we can't get a new reference to 'dp'
  * through the 'dp_netdevs' shash while freeing 'dp'. */
 static void
@@ -1151,6 +1197,7 @@ dp_netdev_free(struct dp_netdev *dp)
         do_del_port(dp, port);
     }
     ovs_mutex_unlock(&dp->port_mutex);
+
     dp_netdev_destroy_all_pmds(dp, true);
     cmap_destroy(&dp->poll_threads);
 
@@ -1169,6 +1216,13 @@ dp_netdev_free(struct dp_netdev *dp)
     /* Upcalls must be disabled at this point */
     dp_netdev_destroy_upcall_lock(dp);
 
+    for (int i = 0; i < MAX_METERS; ++i) {
+        ovs_mutex_lock(&dp->meter_locks[i]);
+        dp_delete_meter(dp, i);
+        ovs_mutex_unlock(&dp->meter_locks[i]);
+        ovs_mutex_destroy(&dp->meter_locks[i]);
+    }
+
     free(dp->pmd_cmask);
     free(CONST_CAST(char *, dp->name));
     free(dp);
@@ -3603,37 +3657,304 @@ static void
 dpif_netdev_meter_get_features(const struct dpif * dpif OVS_UNUSED,
                                struct ofputil_meter_features *features)
 {
-    features->max_meters = 0;
-    features->band_types = 0;
-    features->capabilities = 0;
-    features->max_bands = 0;
+    features->max_meters = MAX_METERS;
+    features->band_types = DP_SUPPORTED_METER_BAND_TYPES;
+    features->capabilities = DP_SUPPORTED_METER_FLAGS_MASK;
+    features->max_bands = MAX_BANDS;
     features->max_color = 0;
 }
 
+/* Returns false when packet needs to be dropped. */
+static void
+dp_netdev_run_meter(struct dp_netdev *dp, struct dp_packet_batch *packets_,
+                    uint32_t meter_id, long long int now)
+{
+    struct dp_meter *meter;
+    struct dp_meter_band *band;
+    long long int long_delta_t; /* msec */
+    uint32_t delta_t; /* msec */
+    int i;
+    int cnt = packets_->count;
+    uint32_t bytes, volume;
+    int exceeded_band[NETDEV_MAX_BURST];
+    uint32_t exceeded_rate[NETDEV_MAX_BURST];
+    int exceeded_pkt = cnt; /* First packet that exceeded a band rate. */
+
+    if (meter_id >= MAX_METERS) {
+        return;
+    }
+
+    ovs_mutex_lock(&dp->meter_locks[meter_id]);
+    meter = dp->meters[meter_id];
+    if (!meter) {
+        goto out;
+    }
+
+    /* Initialize as negative values. */
+    memset(exceeded_band, 0xff, cnt * sizeof *exceeded_band);
+    /* Initialize as zeroes. */
+    memset(exceeded_rate, 0, cnt * sizeof *exceeded_rate);
+
+    /* All packets will hit the meter at the same time. */
+    long_delta_t = (now - meter->used); /* msec */
+
+    /* Make sure delta_t will not be too large, so that bucket will not
+     * wrap around below. */
+    delta_t = (long_delta_t > (long long int)meter->max_delta_t)
+        ? meter->max_delta_t : (uint32_t)long_delta_t;
+
+    /* Update meter stats. */
+    meter->used = now;
+    meter->packet_count += cnt;
+    bytes = 0;
+    for (i = 0; i < cnt; i++) {
+        bytes += dp_packet_size(packets_->packets[i]);
+    }
+    meter->byte_count += bytes;
+
+    /* Meters can operate in terms of packets per second or kilobits per
+     * second. */
+    if (meter->flags & OFPMF13_PKTPS) {
+        /* Rate in packets/second, bucket 1/1000 packets. */
+        /* msec * packets/sec = 1/1000 packets. */
+        volume = cnt * 1000; /* Take 'cnt' packets from the bucket. */
+    } else {
+        /* Rate in kbps, bucket in bits. */
+        /* msec * kbps = bits */
+        volume = bytes * 8;
+    }
+
+    /* Update all bands and find the one hit with the highest rate for each
+     * packet (if any). */
+    for (int m = 0; m < meter->n_bands; ++m) {
+        band = &meter->bands[m];
+
+        /* Update band's bucket. */
+        band->bucket += delta_t * band->up.rate;
+        if (band->bucket > band->up.burst_size) {
+            band->bucket = band->up.burst_size;
+        }
+
+        /* Drain the bucket for all the packets, if possible. */
+        if (band->bucket >= volume) {
+            band->bucket -= volume;
+        } else {
+            int band_exceeded_pkt;
+
+            /* Band limit hit, must process packet-by-packet. */
+            if (meter->flags & OFPMF13_PKTPS) {
+                band_exceeded_pkt = band->bucket / 1000;
+                band->bucket %= 1000; /* Remainder stays in bucket. */
+
+                /* Update the exceeding band for each exceeding packet.
+                 * (Only one band will be fired by a packet, and that
+                 * can be different for each packet.) */
+                for (i = band_exceeded_pkt; i < cnt; i++) {
+                    if (band->up.rate > exceeded_rate[i]) {
+                        exceeded_rate[i] = band->up.rate;
+                        exceeded_band[i] = m;
+                    }
+                }
+            } else {
+                /* Packet sizes differ, must process one-by-one. */
+                band_exceeded_pkt = cnt;
+                for (i = 0; i < cnt; i++) {
+                    uint32_t bits = dp_packet_size(packets_->packets[i]) * 8;
+
+                    if (band->bucket >= bits) {
+                        band->bucket -= bits;
+                    } else {
+                        if (i < band_exceeded_pkt) {
+                            band_exceeded_pkt = i;
+                        }
+                        /* Update the exceeding band for the exceeding packet.
+                         * (Only one band will be fired by a packet, and that
+                         * can be different for each packet.) */
+                        if (band->up.rate > exceeded_rate[i]) {
+                            exceeded_rate[i] = band->up.rate;
+                            exceeded_band[i] = m;
+                        }
+                    }
+                }
+            }
+            /* Remember the first exceeding packet. */
+            if (exceeded_pkt > band_exceeded_pkt) {
+                exceeded_pkt = band_exceeded_pkt;
+            }
+        }
+    }
+
+    /* Fire the highest rate band exceeded by each packet.
+     * Drop packets if needed, by swapping packet to the end that will be
+     * ignored. */
+    const size_t size = dp_packet_batch_size(packets_);
+    struct dp_packet *packet;
+    size_t j;
+    DP_PACKET_BATCH_REFILL_FOR_EACH (j, size, packet, packets_) {
+        if (exceeded_band[j] >= 0) {
+            /* Meter drop packet. */
+            band = &meter->bands[exceeded_band[j]];
+            band->packet_count += 1;
+            band->byte_count += dp_packet_size(packet);
+
+            dp_packet_delete(packet);
+        } else {
+            /* Meter accepts packet. */
+            dp_packet_batch_refill(packets_, packet, j);
+        }
+    }
+ out:
+    ovs_mutex_unlock(&dp->meter_locks[meter_id]);
+}
+
+/* Meter set/get/del processing is still single-threaded. */
 static int
-dpif_netdev_meter_set(struct dpif *dpif OVS_UNUSED,
-                      ofproto_meter_id *meter_id OVS_UNUSED,
-                      struct ofputil_meter_config *config OVS_UNUSED)
+dpif_netdev_meter_set(struct dpif *dpif, ofproto_meter_id *meter_id,
+                      struct ofputil_meter_config *config)
 {
-    return EFBIG; /* meter_id out of range */
+    struct dp_netdev *dp = get_dp_netdev(dpif);
+    uint32_t mid = meter_id->uint32;
+    struct dp_meter *meter;
+    int i;
+
+    if (mid == UINT32_MAX) {
+        mid = dp->meter_free;
+    }
+    if (mid >= MAX_METERS) {
+        return EFBIG; /* Meter_id out of range. */
+    }
+
+    if (config->flags & ~DP_SUPPORTED_METER_FLAGS_MASK ||
+        !(config->flags & (OFPMF13_KBPS | OFPMF13_PKTPS))) {
+        return EBADF; /* Unsupported flags set */
+    }
+    /* Validate bands */
+    if (config->n_bands == 0 || config->n_bands > MAX_BANDS) {
+        return EINVAL; /* Too many bands */
+    }
+    for (i = 0; i < config->n_bands; ++i) {
+        switch (config->bands[i].type) {
+        case OFPMBT13_DROP:
+            break;
+        default:
+            return ENODEV; /* Unsupported band type */
+        }
+    }
+
+    /* Allocate meter */
+    meter = xzalloc(sizeof *meter
+                    + config->n_bands * sizeof(struct dp_meter_band));
+    if (meter) {
+        meter->flags = config->flags;
+        meter->n_bands = config->n_bands;
+        meter->max_delta_t = 0;
+        meter->used = time_msec();
+
+        /* set up bands */
+        for (i = 0; i < config->n_bands; ++i) {
+            uint32_t band_max_delta_t;
+
+            /* Set burst size to a workable value if none specified. */
+            if (config->bands[i].burst_size == 0) {
+                config->bands[i].burst_size = config->bands[i].rate;
+            }
+
+            meter->bands[i].up = config->bands[i];
+            /* Convert burst size to the bucket units: */
+            /* pkts => 1/1000 packets, kilobits => bits. */
+            meter->bands[i].up.burst_size *= 1000;
+            /* Initialize bucket to empty. */
+            meter->bands[i].bucket = 0;
+
+            /* Figure out max delta_t that is enough to fill any bucket. */
+            band_max_delta_t
+                = meter->bands[i].up.burst_size / meter->bands[i].up.rate;
+            if (band_max_delta_t > meter->max_delta_t) {
+                meter->max_delta_t = band_max_delta_t;
+            }
+        }
+
+        ovs_mutex_lock(&dp->meter_locks[mid]);
+        dp_delete_meter(dp, mid); /* Free existing meter, if any */
+        dp->meters[mid] = meter;
+        ovs_mutex_unlock(&dp->meter_locks[mid]);
+
+        meter_id->uint32 = mid; /* Store on success. */
+
+        /* Find next free meter */
+        if (dp->meter_free == mid) { /* Now taken. */
+            do {
+                if (++mid >= MAX_METERS) { /* Wrap around */
+                    mid = 0;
+                }
+                if (mid == dp->meter_free) { /* Full circle */
+                    mid = MAX_METERS;
+                    break;
+                }
+            } while (dp->meters[mid]);
+            dp->meter_free = mid; /* Next free meter or MAX_METERS */
+        }
+        return 0;
+    }
+    return ENOMEM;
 }
 
 static int
-dpif_netdev_meter_get(const struct dpif *dpif OVS_UNUSED,
-                      ofproto_meter_id meter_id OVS_UNUSED,
-                      struct ofputil_meter_stats *stats OVS_UNUSED,
-                      uint16_t n_bands OVS_UNUSED)
+dpif_netdev_meter_get(const struct dpif *dpif,
+                      ofproto_meter_id meter_id_,
+                      struct ofputil_meter_stats *stats, uint16_t n_bands)
 {
-    return EFBIG; /* meter_id out of range */
+    const struct dp_netdev *dp = get_dp_netdev(dpif);
+    const struct dp_meter *meter;
+    uint32_t meter_id = meter_id_.uint32;
+
+    if (meter_id >= MAX_METERS) {
+        return EFBIG;
+    }
+    meter = dp->meters[meter_id];
+    if (!meter) {
+        return ENOENT;
+    }
+    if (stats) {
+        int i = 0;
+
+        ovs_mutex_lock(&dp->meter_locks[meter_id]);
+        stats->packet_in_count = meter->packet_count;
+        stats->byte_in_count = meter->byte_count;
+
+        for (i = 0; i < n_bands && i < meter->n_bands; ++i) {
+            stats->bands[i].packet_count = meter->bands[i].packet_count;
+            stats->bands[i].byte_count = meter->bands[i].byte_count;
+        }
+        ovs_mutex_unlock(&dp->meter_locks[meter_id]);
+
+        stats->n_bands = i;
+    }
+    return 0;
 }
 
 static int
-dpif_netdev_meter_del(struct dpif *dpif OVS_UNUSED,
-                      ofproto_meter_id meter_id OVS_UNUSED,
-                      struct ofputil_meter_stats *stats OVS_UNUSED,
-                      uint16_t n_bands OVS_UNUSED)
+dpif_netdev_meter_del(struct dpif *dpif,
+                      ofproto_meter_id meter_id_,
+                      struct ofputil_meter_stats *stats, uint16_t n_bands)
 {
-    return EFBIG; /* meter_id out of range */
+    struct dp_netdev *dp = get_dp_netdev(dpif);
+    int error;
+
+    error = dpif_netdev_meter_get(dpif, meter_id_, stats, n_bands);
+    if (!error) {
+        uint32_t meter_id = meter_id_.uint32;
+
+        ovs_mutex_lock(&dp->meter_locks[meter_id]);
+        dp_delete_meter(dp, meter_id);
+        ovs_mutex_unlock(&dp->meter_locks[meter_id]);
+
+        /* Keep free meter index as low as possible */
+        if (meter_id < dp->meter_free) {
+            dp->meter_free = meter_id;
+        }
+    }
+    return error;
 }
 
 
@@ -4565,6 +4886,7 @@ dp_execute_userspace_action(struct dp_netdev_pmd_thread *pmd,
 static void
 dp_execute_cb(void *aux_, struct dp_packet_batch *packets_,
               const struct nlattr *a, bool may_steal)
+    OVS_NO_THREAD_SAFETY_ANALYSIS
 {
     struct dp_netdev_execute_aux *aux = aux_;
     uint32_t *depth = recirc_depth_get();
@@ -4762,6 +5084,10 @@ dp_execute_cb(void *aux_, struct dp_packet_batch *packets_,
     }
 
     case OVS_ACTION_ATTR_METER:
+        dp_netdev_run_meter(pmd->dp, packets_, nl_attr_get_u32(a),
+                            time_msec());
+        break;
+
     case OVS_ACTION_ATTR_PUSH_VLAN:
     case OVS_ACTION_ATTR_POP_VLAN:
     case OVS_ACTION_ATTR_PUSH_MPLS:
diff --git a/tests/dpif-netdev.at b/tests/dpif-netdev.at
index fff0460..586a5b1 100644
--- a/tests/dpif-netdev.at
+++ b/tests/dpif-netdev.at
@@ -4,6 +4,13 @@ m4_divert_push([PREPARE_TESTS])
 [
 # Strips out uninteresting parts of flow output, as well as parts
 # that vary from one run to another (e.g., timing and bond actions).
+strip_timers () {
+    sed '
+    s/duration:[0-9]*\.[0-9]*/duration:0.0/
+    s/used:[0-9]*\.[0-9]*/used:0.0/
+'
+}
+
 strip_xout () {
     sed '
     s/ufid:[-0-9a-f]* //
@@ -160,3 +167,102 @@ skb_priority(0/0),skb_mark(0/0),ct_state(0/0),ct_zone(0/0),ct_mark(0/0),ct_label
 
 DPIF_NETDEV_MISS_FLOW_DUMP([dummy])
 DPIF_NETDEV_MISS_FLOW_DUMP([dummy-pmd])
+
+AT_SETUP([dpif-netdev - meters])
+# Create br0 with interfaces p1 and p7
+#    and br1 with interfaces p2 and p8
+# with p1 and p2 connected via unix domain socket
+OVS_VSWITCHD_START(
+  [add-port br0 p1 -- set interface p1 type=dummy options:pstream=punix:$OVS_RUNDIR/p0.sock ofport_request=1 -- \
+   add-port br0 p7 -- set interface p7 ofport_request=7 type=dummy -- \
+   add-br br1 -- \
+   set bridge br1 other-config:hwaddr=aa:66:aa:66:00:00 -- \
+   set bridge br1 datapath-type=dummy other-config:datapath-id=1234 \
+                  fail-mode=secure -- \
+   add-port br1 p2 -- set interface p2 type=dummy options:stream=unix:$OVS_RUNDIR/p0.sock ofport_request=2 -- \
+   add-port br1 p8 -- set interface p8 ofport_request=8 type=dummy --])
+AT_CHECK([ovs-appctl vlog/set dpif:dbg dpif_netdev:dbg])
+
+AT_CHECK([ovs-ofctl -O OpenFlow13 add-meter br0 'meter=1 pktps burst stats bands=type=drop rate=1 burst_size=1'])
+AT_CHECK([ovs-ofctl -O OpenFlow13 add-meter br0 'meter=2 kbps burst stats bands=type=drop rate=1 burst_size=2'])
+AT_CHECK([ovs-ofctl -O OpenFlow13 add-flow br0 'in_port=1 action=meter:1,7'])
+AT_CHECK([ovs-ofctl -O OpenFlow13 add-flow br0 'in_port=7 action=meter:2,1'])
+AT_CHECK([ovs-ofctl add-flow br1 'in_port=2 action=8'])
+AT_CHECK([ovs-ofctl add-flow br1 'in_port=8 action=2'])
+ovs-appctl time/stop
+
+AT_CHECK([ovs-ofctl -O OpenFlow13 dump-meters br0], [0], [dnl
+OFPST_METER_CONFIG reply (OF1.3) (xid=0x2):
+meter=1 pktps burst stats bands=
+type=drop rate=1 burst_size=1
+
+meter=2 kbps burst stats bands=
+type=drop rate=1 burst_size=2
+])
+
+ovs-appctl time/warp 5000
+AT_CHECK([ovs-appctl netdev-dummy/receive p7 'in_port(7),eth(src=50:54:00:00:00:09,dst=50:54:00:00:00:0a),eth_type(0x0800),ipv4(src=10.0.0.2,dst=10.0.0.1,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p7 'in_port(7),eth(src=50:54:00:00:00:09,dst=50:54:00:00:00:0a),eth_type(0x0800),ipv4(src=10.0.0.2,dst=10.0.0.1,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p7 'in_port(7),eth(src=50:54:00:00:00:09,dst=50:54:00:00:00:0a),eth_type(0x0800),ipv4(src=10.0.0.2,dst=10.0.0.1,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p7 'in_port(7),eth(src=50:54:00:00:00:09,dst=50:54:00:00:00:0a),eth_type(0x0800),ipv4(src=10.0.0.2,dst=10.0.0.1,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p7 'in_port(7),eth(src=50:54:00:00:00:09,dst=50:54:00:00:00:0a),eth_type(0x0800),ipv4(src=10.0.0.2,dst=10.0.0.1,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p8 'in_port(8),eth(src=50:54:00:00:00:0b,dst=50:54:00:00:00:0c),eth_type(0x0800),ipv4(src=10.0.0.3,dst=10.0.0.4,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p8 'in_port(8),eth(src=50:54:00:00:00:0b,dst=50:54:00:00:00:0c),eth_type(0x0800),ipv4(src=10.0.0.3,dst=10.0.0.4,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p8 'in_port(8),eth(src=50:54:00:00:00:0b,dst=50:54:00:00:00:0c),eth_type(0x0800),ipv4(src=10.0.0.3,dst=10.0.0.4,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p8 'in_port(8),eth(src=50:54:00:00:00:0b,dst=50:54:00:00:00:0c),eth_type(0x0800),ipv4(src=10.0.0.3,dst=10.0.0.4,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p8 'in_port(8),eth(src=50:54:00:00:00:0b,dst=50:54:00:00:00:0c),eth_type(0x0800),ipv4(src=10.0.0.3,dst=10.0.0.4,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+sleep 1  # wait for forwarders process packets
+
+# Meter 1 is measuring packets, allowing one packet per second with
+# bursts of one packet, so 4 out of 5 packets should hit the drop
+# band.
+# Meter 2 is measuring kbps, with burst size 2 (== 2000 bits). 4 packets
+# (240 bytes == 1920 bits) pass, but the last packet should hit the drop band.
+AT_CHECK([ovs-ofctl -O OpenFlow13 meter-stats br0 | strip_timers], [0], [dnl
+OFPST_METER reply (OF1.3) (xid=0x2):
+meter:1 flow_count:1 packet_in_count:5 byte_in_count:300 duration:0.0s bands:
+0: packet_count:4 byte_count:240
+
+meter:2 flow_count:1 packet_in_count:5 byte_in_count:300 duration:0.0s bands:
+0: packet_count:1 byte_count:60
+])
+
+# Advance time by 1/2 second
+ovs-appctl time/warp 500
+
+AT_CHECK([ovs-appctl netdev-dummy/receive p7 'in_port(7),eth(src=50:54:00:00:00:09,dst=50:54:00:00:00:0a),eth_type(0x0800),ipv4(src=10.0.0.2,dst=10.0.0.1,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p7 'in_port(7),eth(src=50:54:00:00:00:09,dst=50:54:00:00:00:0a),eth_type(0x0800),ipv4(src=10.0.0.2,dst=10.0.0.1,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p7 'in_port(7),eth(src=50:54:00:00:00:09,dst=50:54:00:00:00:0a),eth_type(0x0800),ipv4(src=10.0.0.2,dst=10.0.0.1,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p7 'in_port(7),eth(src=50:54:00:00:00:09,dst=50:54:00:00:00:0a),eth_type(0x0800),ipv4(src=10.0.0.2,dst=10.0.0.1,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p7 'in_port(7),eth(src=50:54:00:00:00:09,dst=50:54:00:00:00:0a),eth_type(0x0800),ipv4(src=10.0.0.2,dst=10.0.0.1,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p8 'in_port(8),eth(src=50:54:00:00:00:0b,dst=50:54:00:00:00:0c),eth_type(0x0800),ipv4(src=10.0.0.3,dst=10.0.0.4,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p8 'in_port(8),eth(src=50:54:00:00:00:0b,dst=50:54:00:00:00:0c),eth_type(0x0800),ipv4(src=10.0.0.3,dst=10.0.0.4,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p8 'in_port(8),eth(src=50:54:00:00:00:0b,dst=50:54:00:00:00:0c),eth_type(0x0800),ipv4(src=10.0.0.3,dst=10.0.0.4,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p8 'in_port(8),eth(src=50:54:00:00:00:0b,dst=50:54:00:00:00:0c),eth_type(0x0800),ipv4(src=10.0.0.3,dst=10.0.0.4,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+AT_CHECK([ovs-appctl netdev-dummy/receive p8 'in_port(8),eth(src=50:54:00:00:00:0b,dst=50:54:00:00:00:0c),eth_type(0x0800),ipv4(src=10.0.0.3,dst=10.0.0.4,proto=1,tos=0,ttl=64,frag=no),icmp(type=8,code=0)' --len 60])
+sleep 1  # wait for forwarders process packets
+
+# Meter 1 is measuring packets, allowing one packet per second with
+# bursts of one packet, so all 5 of the new packets should hit the drop
+# band.
+# Meter 2 is measuring kbps, with burst size 2 (== 2000 bits). After 500ms
+# there should be space for 80 + 500 bits, so one new 60 byte (480 bit) packet
+# should pass, remaining 4 should hit the drop band.
+AT_CHECK([ovs-ofctl -O OpenFlow13 meter-stats br0 | strip_timers], [0], [dnl
+OFPST_METER reply (OF1.3) (xid=0x2):
+meter:1 flow_count:1 packet_in_count:10 byte_in_count:600 duration:0.0s bands:
+0: packet_count:9 byte_count:540
+
+meter:2 flow_count:1 packet_in_count:10 byte_in_count:600 duration:0.0s bands:
+0: packet_count:5 byte_count:300
+])
+
+AT_CHECK([cat ovs-vswitchd.log | filter_flow_install | strip_xout_keep_actions], [0], [dnl
+recirc_id(0),in_port(1),eth_type(0x0800),ipv4(frag=no), actions:meter(0),7
+recirc_id(0),in_port(2),eth_type(0x0800),ipv4(frag=no), actions:8
+recirc_id(0),in_port(7),eth_type(0x0800),ipv4(frag=no), actions:meter(1),1
+recirc_id(0),in_port(8),eth_type(0x0800),ipv4(frag=no), actions:2
+])
+
+OVS_VSWITCHD_STOP
+AT_CLEANUP
-- 
1.9.1
