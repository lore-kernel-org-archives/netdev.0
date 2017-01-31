From: Andy Zhou <azhou@ovn.org>
Subject: [userspace meter v3 2/5] dp-packet: Enhance packet batch APIs.
Date: Mon, 30 Jan 2017 22:39:57 -0800
Message-ID: <1485844800-2873-3-git-send-email-azhou@ovn.org>
References: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@ovn.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35373 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751025AbdAaHBg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 02:01:36 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so26355810pfa.2
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 23:01:35 -0800 (PST)
In-Reply-To: <1485844800-2873-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One common use case of 'struct dp_packet_batch' is to process all
packets in the batch in order. Add an iterator for this use case
to simplify the logic of calling sites,

Another common use case is to drop packets in the batch, by reading
all packets, but writing back pointers of fewer packets. Add macros
to support this use case.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 lib/dp-packet.h              | 140 +++++++++++++++++++++++++++++++------------
 lib/dpif-netdev.c            |  62 +++++++++----------
 lib/dpif.c                   |   2 +-
 lib/netdev-dummy.c           |  10 ++--
 lib/netdev-linux.c           |   3 +-
 lib/netdev.c                 |  24 ++++----
 lib/odp-execute.c            |  55 ++++++++---------
 ofproto/ofproto-dpif-xlate.c |   2 +-
 tests/test-conntrack.c       |  56 +++++++----------
 9 files changed, 201 insertions(+), 153 deletions(-)

diff --git a/lib/dp-packet.h b/lib/dp-packet.h
index cf7d247..d0c14a5 100644
--- a/lib/dp-packet.h
+++ b/lib/dp-packet.h
@@ -632,79 +632,143 @@ reset_dp_packet_checksum_ol_flags(struct dp_packet *p)
 enum { NETDEV_MAX_BURST = 32 }; /* Maximum number packets in a batch. */
 
 struct dp_packet_batch {
-    int count;
+    size_t count;
     bool trunc; /* true if the batch needs truncate. */
     struct dp_packet *packets[NETDEV_MAX_BURST];
 };
 
-static inline void dp_packet_batch_init(struct dp_packet_batch *b)
+static inline void
+dp_packet_batch_init(struct dp_packet_batch *batch)
 {
-    b->count = 0;
-    b->trunc = false;
+    batch->count = 0;
+    batch->trunc = false;
 }
 
 static inline void
-dp_packet_batch_clone(struct dp_packet_batch *dst,
-                      struct dp_packet_batch *src)
+dp_packet_batch_add__(struct dp_packet_batch *batch,
+                      struct dp_packet *packet, size_t limit)
 {
-    int i;
-
-    for (i = 0; i < src->count; i++) {
-        dst->packets[i] = dp_packet_clone(src->packets[i]);
+    if (batch->count < limit) {
+        batch->packets[batch->count++] = packet;
+    } else {
+        dp_packet_delete(packet);
     }
-    dst->count = src->count;
-    dst->trunc = src->trunc;
 }
 
 static inline void
-packet_batch_init_packet(struct dp_packet_batch *b, struct dp_packet *p)
+dp_packet_batch_add(struct dp_packet_batch *batch, struct dp_packet *packet)
+{
+    dp_packet_batch_add__(batch, packet, NETDEV_MAX_BURST);
+}
+
+static inline size_t
+dp_packet_batch_size(const struct dp_packet_batch *batch)
+{
+    return batch->count;
+}
+
+/*
+ * Clear 'batch' for refill. Use dp_packet_batch_refill() to add
+ * packets back into the 'batch'.
+ *
+ * Return the original size of the 'batch'.  */
+static inline void
+dp_packet_batch_refill_init(struct dp_packet_batch *batch)
 {
-    b->count = 1;
-    b->trunc = false;
-    b->packets[0] = p;
+    batch->count = 0;
+};
+
+static inline void
+dp_packet_batch_refill(struct dp_packet_batch *batch,
+                       struct dp_packet *packet, size_t idx)
+{
+    dp_packet_batch_add__(batch, packet, MIN(NETDEV_MAX_BURST, idx + 1));
+}
+
+static inline void
+dp_packet_batch_init_packet(struct dp_packet_batch *batch, struct dp_packet *p)
+{
+    dp_packet_batch_init(batch);
+    batch->count = 1;
+    batch->packets[0] = p;
+}
+
+static inline bool
+dp_packet_batch_is_empty(const struct dp_packet_batch *batch)
+{
+    return !dp_packet_batch_size(batch);
+}
+
+#define DP_PACKET_BATCH_FOR_EACH(PACKET, BATCH)    \
+    for (size_t i = 0; i < dp_packet_batch_size(BATCH); i++)  \
+        if ((PACKET = BATCH->packets[i]) != NULL)
+
+/* Use this macro for cases where some packets in the 'BATCH' may be
+ * dropped after going through each packet in the 'BATCH'.
+ *
+ * For packets to stay in the 'BATCH', they need to be refilled back
+ * into the 'BATCH' by calling dp_packet_batch_refill(). Caller owns
+ * the packets that are not refilled.
+ *
+ * Caller needs to supply 'SIZE', that stores the current number of
+ * packets in 'BATCH'. It is best to declare this variable with
+ * the 'const' modifier since it should not be modified by
+ * the iterator.  */
+#define DP_PACKET_BATCH_REFILL_FOR_EACH(IDX, SIZE, PACKET, BATCH)       \
+    for (dp_packet_batch_refill_init(BATCH), IDX=0; IDX < SIZE; IDX++)  \
+         if ((PACKET = BATCH->packets[IDX]) != NULL)
+
+static inline void
+dp_packet_batch_clone(struct dp_packet_batch *dst,
+                      struct dp_packet_batch *src)
+{
+    struct dp_packet *packet;
+
+    dp_packet_batch_init(dst);
+    DP_PACKET_BATCH_FOR_EACH (packet, src) {
+        dp_packet_batch_add(dst, dp_packet_clone(packet));
+    }
 }
 
 static inline void
 dp_packet_delete_batch(struct dp_packet_batch *batch, bool may_steal)
 {
     if (may_steal) {
-        int i;
+        struct dp_packet *packet;
 
-        for (i = 0; i < batch->count; i++) {
-            dp_packet_delete(batch->packets[i]);
+        DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+            dp_packet_delete(packet);
         }
+        dp_packet_batch_init(batch);
     }
 }
 
 static inline void
-dp_packet_batch_apply_cutlen(struct dp_packet_batch *pktb)
+dp_packet_batch_apply_cutlen(struct dp_packet_batch *batch)
 {
-    int i;
-
-    if (!pktb->trunc)
-        return;
+    if (batch->trunc) {
+        struct dp_packet *packet;
 
-    for (i = 0; i < pktb->count; i++) {
-        uint32_t cutlen = dp_packet_get_cutlen(pktb->packets[i]);
+        DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+            uint32_t cutlen = dp_packet_get_cutlen(packet);
 
-        dp_packet_set_size(pktb->packets[i],
-                    dp_packet_size(pktb->packets[i]) - cutlen);
-        dp_packet_reset_cutlen(pktb->packets[i]);
+            dp_packet_set_size(packet, dp_packet_size(packet) - cutlen);
+            dp_packet_reset_cutlen(packet);
+        }
+        batch->trunc = false;
     }
-    pktb->trunc = false;
 }
 
 static inline void
-dp_packet_batch_reset_cutlen(struct dp_packet_batch *pktb)
+dp_packet_batch_reset_cutlen(struct dp_packet_batch *batch)
 {
-    int i;
+    if (batch->trunc) {
+        struct dp_packet *packet;
 
-    if (!pktb->trunc)
-        return;
-
-    pktb->trunc = false;
-    for (i = 0; i < pktb->count; i++) {
-        dp_packet_reset_cutlen(pktb->packets[i]);
+        DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+            dp_packet_reset_cutlen(packet);
+        }
+        batch->trunc = false;
     }
 }
 
diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index 42631bc..719a518 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -2683,7 +2683,7 @@ dpif_netdev_execute(struct dpif *dpif, struct dpif_execute *execute)
                                flow_hash_5tuple(execute->flow, 0));
     }
 
-    packet_batch_init_packet(&pp, execute->packet);
+    dp_packet_batch_init_packet(&pp, execute->packet);
     dp_netdev_execute_actions(pmd, &pp, false, execute->flow,
                               execute->actions, execute->actions_len,
                               time_msec());
@@ -4073,20 +4073,21 @@ dp_netdev_queue_batches(struct dp_packet *pkt,
  * initialized by this function using 'port_no'.
  */
 static inline size_t
-emc_processing(struct dp_netdev_pmd_thread *pmd, struct dp_packet_batch *packets_,
+emc_processing(struct dp_netdev_pmd_thread *pmd,
+               struct dp_packet_batch *packets_,
                struct netdev_flow_key *keys,
                struct packet_batch_per_flow batches[], size_t *n_batches,
                bool md_is_valid, odp_port_t port_no)
 {
     struct emc_cache *flow_cache = &pmd->flow_cache;
     struct netdev_flow_key *key = &keys[0];
-    size_t i, n_missed = 0, n_dropped = 0;
-    struct dp_packet **packets = packets_->packets;
-    int cnt = packets_->count;
+    size_t n_missed = 0, n_dropped = 0;
+    struct dp_packet *packet;
+    const size_t size = dp_packet_batch_size(packets_);
+    int i;
 
-    for (i = 0; i < cnt; i++) {
+    DP_PACKET_BATCH_REFILL_FOR_EACH (i, size, packet, packets_) {
         struct dp_netdev_flow *flow;
-        struct dp_packet *packet = packets[i];
 
         if (OVS_UNLIKELY(dp_packet_size(packet) < ETH_HEADER_LEN)) {
             dp_packet_delete(packet);
@@ -4094,7 +4095,8 @@ emc_processing(struct dp_netdev_pmd_thread *pmd, struct dp_packet_batch *packets
             continue;
         }
 
-        if (i != cnt - 1) {
+        if (i != size - 1) {
+            struct dp_packet **packets = packets_->packets;
             /* Prefetch next packet data and metadata. */
             OVS_PREFETCH(dp_packet_data(packets[i+1]));
             pkt_metadata_prefetch_init(&packets[i+1]->md);
@@ -4113,8 +4115,8 @@ emc_processing(struct dp_netdev_pmd_thread *pmd, struct dp_packet_batch *packets
                                     n_batches);
         } else {
             /* Exact match cache missed. Group missed packets together at
-             * the beginning of the 'packets' array.  */
-            packets[n_missed] = packet;
+             * the beginning of the 'packets' array. */
+            dp_packet_batch_refill(packets_, packet, i);
             /* 'key[n_missed]' contains the key of the current packet and it
              * must be returned to the caller. The next key should be extracted
              * to 'keys[n_missed + 1]'. */
@@ -4122,9 +4124,9 @@ emc_processing(struct dp_netdev_pmd_thread *pmd, struct dp_packet_batch *packets
         }
     }
 
-    dp_netdev_count_packet(pmd, DP_STAT_EXACT_HIT, cnt - n_dropped - n_missed);
+    dp_netdev_count_packet(pmd, DP_STAT_EXACT_HIT, size - n_dropped - n_missed);
 
-    return n_missed;
+    return dp_packet_batch_size(packets_);
 }
 
 static inline void
@@ -4168,7 +4170,7 @@ handle_packet_upcall(struct dp_netdev_pmd_thread *pmd, struct dp_packet *packet,
     /* We can't allow the packet batching in the next loop to execute
      * the actions.  Otherwise, if there are any slow path actions,
      * we'll send the packet up twice. */
-    packet_batch_init_packet(&b, packet);
+    dp_packet_batch_init_packet(&b, packet);
     dp_netdev_execute_actions(pmd, &b, true, &match.flow,
                               actions->data, actions->size, now);
 
@@ -4316,14 +4318,13 @@ dp_netdev_input__(struct dp_netdev_pmd_thread *pmd,
     OVS_ALIGNED_VAR(CACHE_LINE_SIZE) struct netdev_flow_key keys[PKT_ARRAY_SIZE];
     struct packet_batch_per_flow batches[PKT_ARRAY_SIZE];
     long long now = time_msec();
-    size_t newcnt, n_batches, i;
+    size_t n_batches;
     odp_port_t in_port;
 
     n_batches = 0;
-    newcnt = emc_processing(pmd, packets, keys, batches, &n_batches,
+    emc_processing(pmd, packets, keys, batches, &n_batches,
                             md_is_valid, port_no);
-    if (OVS_UNLIKELY(newcnt)) {
-        packets->count = newcnt;
+    if (!dp_packet_batch_is_empty(packets)) {
         /* Get ingress port from first packet's metadata. */
         in_port = packets->packets[0]->md.in_port.odp_port;
         fast_path_processing(pmd, packets, keys, batches, &n_batches, in_port, now);
@@ -4338,6 +4339,7 @@ dp_netdev_input__(struct dp_netdev_pmd_thread *pmd,
      * already its own batches[k] still waiting to be served.  So if its
      * ‘batch’ member is not reset, the recirculated packet would be wrongly
      * appended to batches[k] of the 1st call to dp_netdev_input__(). */
+    size_t i;
     for (i = 0; i < n_batches; i++) {
         batches[i].flow->batch = NULL;
     }
@@ -4512,7 +4514,7 @@ dp_execute_userspace_action(struct dp_netdev_pmd_thread *pmd,
                              DPIF_UC_ACTION, userdata, actions,
                              NULL);
     if (!error || error == ENOSPC) {
-        packet_batch_init_packet(&b, packet);
+        dp_packet_batch_init_packet(&b, packet);
         dp_netdev_execute_actions(pmd, &b, may_steal, flow,
                                   actions->data, actions->size, now);
     } else if (may_steal) {
@@ -4584,7 +4586,6 @@ dp_execute_cb(void *aux_, struct dp_packet_batch *packets_,
             p = pmd_tnl_port_cache_lookup(pmd, portno);
             if (p) {
                 struct dp_packet_batch tnl_pkt;
-                int i;
 
                 if (!may_steal) {
                     dp_packet_batch_clone(&tnl_pkt, packets_);
@@ -4595,12 +4596,13 @@ dp_execute_cb(void *aux_, struct dp_packet_batch *packets_,
                 dp_packet_batch_apply_cutlen(packets_);
 
                 netdev_pop_header(p->port->netdev, packets_);
-                if (!packets_->count) {
+                if (dp_packet_batch_is_empty(packets_)) {
                     return;
                 }
 
-                for (i = 0; i < packets_->count; i++) {
-                    packets_->packets[i]->md.in_port.odp_port = portno;
+                struct dp_packet *packet;
+                DP_PACKET_BATCH_FOR_EACH (packet, packets_) {
+                    packet->md.in_port.odp_port = portno;
                 }
 
                 (*depth)++;
@@ -4614,14 +4616,12 @@ dp_execute_cb(void *aux_, struct dp_packet_batch *packets_,
     case OVS_ACTION_ATTR_USERSPACE:
         if (!fat_rwlock_tryrdlock(&dp->upcall_rwlock)) {
             struct dp_packet_batch *orig_packets_ = packets_;
-            struct dp_packet **packets = packets_->packets;
             const struct nlattr *userdata;
             struct dp_packet_batch usr_pkt;
             struct ofpbuf actions;
             struct flow flow;
             ovs_u128 ufid;
             bool clone = false;
-            int i;
 
             userdata = nl_attr_find_nested(a, OVS_USERSPACE_ATTR_USERDATA);
             ofpbuf_init(&actions, 0);
@@ -4630,7 +4630,6 @@ dp_execute_cb(void *aux_, struct dp_packet_batch *packets_,
                 if (!may_steal) {
                     dp_packet_batch_clone(&usr_pkt, packets_);
                     packets_ = &usr_pkt;
-                    packets = packets_->packets;
                     clone = true;
                     dp_packet_batch_reset_cutlen(orig_packets_);
                 }
@@ -4638,10 +4637,11 @@ dp_execute_cb(void *aux_, struct dp_packet_batch *packets_,
                 dp_packet_batch_apply_cutlen(packets_);
             }
 
-            for (i = 0; i < packets_->count; i++) {
-                flow_extract(packets[i], &flow);
+            struct dp_packet *packet;
+            DP_PACKET_BATCH_FOR_EACH (packet, packets_) {
+                flow_extract(packet, &flow);
                 dpif_flow_hash(dp->dpif, &flow, sizeof flow, &ufid);
-                dp_execute_userspace_action(pmd, packets[i], may_steal, &flow,
+                dp_execute_userspace_action(pmd, packet, may_steal, &flow,
                                             &ufid, &actions, userdata, now);
             }
 
@@ -4659,15 +4659,15 @@ dp_execute_cb(void *aux_, struct dp_packet_batch *packets_,
     case OVS_ACTION_ATTR_RECIRC:
         if (*depth < MAX_RECIRC_DEPTH) {
             struct dp_packet_batch recirc_pkts;
-            int i;
 
             if (!may_steal) {
                dp_packet_batch_clone(&recirc_pkts, packets_);
                packets_ = &recirc_pkts;
             }
 
-            for (i = 0; i < packets_->count; i++) {
-                packets_->packets[i]->md.recirc_id = nl_attr_get_u32(a);
+            struct dp_packet *packet;
+            DP_PACKET_BATCH_FOR_EACH (packet, packets_) {
+                packet->md.recirc_id = nl_attr_get_u32(a);
             }
 
             (*depth)++;
diff --git a/lib/dpif.c b/lib/dpif.c
index 7c953b5..374f013 100644
--- a/lib/dpif.c
+++ b/lib/dpif.c
@@ -1202,7 +1202,7 @@ dpif_execute_with_help(struct dpif *dpif, struct dpif_execute *execute)
 
     COVERAGE_INC(dpif_execute_with_help);
 
-    packet_batch_init_packet(&pb, execute->packet);
+    dp_packet_batch_init_packet(&pb, execute->packet);
     odp_execute_actions(&aux, &pb, false, execute->actions,
                         execute->actions_len, dpif_execute_helper_cb);
     return aux.error;
diff --git a/lib/netdev-dummy.c b/lib/netdev-dummy.c
index 10df0a7..e02beae 100644
--- a/lib/netdev-dummy.c
+++ b/lib/netdev-dummy.c
@@ -1061,13 +1061,13 @@ netdev_dummy_send(struct netdev *netdev, int qid OVS_UNUSED,
 {
     struct netdev_dummy *dev = netdev_dummy_cast(netdev);
     int error = 0;
-    int i;
 
-    for (i = 0; i < batch->count; i++) {
-        const void *buffer = dp_packet_data(batch->packets[i]);
-        size_t size = dp_packet_size(batch->packets[i]);
+    struct dp_packet *packet;
+    DP_PACKET_BATCH_FOR_EACH(packet, batch) {
+        const void *buffer = dp_packet_data(packet);
+        size_t size = dp_packet_size(packet);
 
-        size -= dp_packet_get_cutlen(batch->packets[i]);
+        size -= dp_packet_get_cutlen(packet);
 
         if (size < ETH_HEADER_LEN) {
             error = EMSGSIZE;
diff --git a/lib/netdev-linux.c b/lib/netdev-linux.c
index a5a9ec1..9ff1333 100644
--- a/lib/netdev-linux.c
+++ b/lib/netdev-linux.c
@@ -1125,8 +1125,7 @@ netdev_linux_rxq_recv(struct netdev_rxq *rxq_, struct dp_packet_batch *batch)
         }
         dp_packet_delete(buffer);
     } else {
-        batch->packets[0] = buffer;
-        batch->count = 1;
+        dp_packet_batch_init_packet(batch, buffer);
     }
 
     return retval;
diff --git a/lib/netdev.c b/lib/netdev.c
index 839b1f6..1e6bb2b 100644
--- a/lib/netdev.c
+++ b/lib/netdev.c
@@ -749,20 +749,19 @@ netdev_send(struct netdev *netdev, int qid, struct dp_packet_batch *batch,
 void
 netdev_pop_header(struct netdev *netdev, struct dp_packet_batch *batch)
 {
-    int i, n_cnt = 0;
-    struct dp_packet **buffers = batch->packets;
+    struct dp_packet *packet;
+    size_t i, size = dp_packet_batch_size(batch);
 
-    for (i = 0; i < batch->count; i++) {
-        buffers[i] = netdev->netdev_class->pop_header(buffers[i]);
-        if (buffers[i]) {
+    DP_PACKET_BATCH_REFILL_FOR_EACH (i, size, packet, batch) {
+        packet = netdev->netdev_class->pop_header(packet);
+        if (packet) {
             /* Reset the checksum offload flags if present, to avoid wrong
              * interpretation in the further packet processing when
              * recirculated.*/
-            reset_dp_packet_checksum_ol_flags(buffers[i]);
-            buffers[n_cnt++] = buffers[i];
+            reset_dp_packet_checksum_ol_flags(packet);
+            dp_packet_batch_refill(batch, packet, i);
         }
     }
-    batch->count = n_cnt;
 }
 
 void
@@ -799,11 +798,10 @@ netdev_push_header(const struct netdev *netdev,
                    struct dp_packet_batch *batch,
                    const struct ovs_action_push_tnl *data)
 {
-    int i;
-
-    for (i = 0; i < batch->count; i++) {
-        netdev->netdev_class->push_header(batch->packets[i], data);
-        pkt_metadata_init(&batch->packets[i]->md, u32_to_odp(data->out_port));
+    struct dp_packet *packet;
+    DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+        netdev->netdev_class->push_header(packet, data);
+        pkt_metadata_init(&packet->md, u32_to_odp(data->out_port));
     }
 
     return 0;
diff --git a/lib/odp-execute.c b/lib/odp-execute.c
index c4ae5ce..465280b 100644
--- a/lib/odp-execute.c
+++ b/lib/odp-execute.c
@@ -523,7 +523,7 @@ odp_execute_sample(void *dp, struct dp_packet *packet, bool steal,
         }
     }
 
-    packet_batch_init_packet(&pb, packet);
+    dp_packet_batch_init_packet(&pb, packet);
     odp_execute_actions(dp, &pb, steal, nl_attr_get(subactions),
                         nl_attr_get_size(subactions), dp_execute_action);
 }
@@ -543,7 +543,7 @@ odp_execute_clone(void *dp, struct dp_packet *packet, bool steal,
          * will free the clone.  */
         packet = dp_packet_clone(packet);
     }
-    packet_batch_init_packet(&pb, packet);
+    dp_packet_batch_init_packet(&pb, packet);
     odp_execute_actions(dp, &pb, true, nl_attr_get(actions),
                         nl_attr_get_size(actions), dp_execute_action);
 }
@@ -588,11 +588,9 @@ odp_execute_actions(void *dp, struct dp_packet_batch *batch, bool steal,
                     const struct nlattr *actions, size_t actions_len,
                     odp_execute_cb dp_execute_action)
 {
-    struct dp_packet **packets = batch->packets;
-    int cnt = batch->count;
+    struct dp_packet *packet;
     const struct nlattr *a;
     unsigned int left;
-    int i;
 
     NL_ATTR_FOR_EACH_UNSAFE (a, left, actions, actions_len) {
         int type = nl_attr_type(a);
@@ -627,11 +625,10 @@ odp_execute_actions(void *dp, struct dp_packet_batch *batch, bool steal,
                 struct flow flow;
                 uint32_t hash;
 
-                for (i = 0; i < cnt; i++) {
-                    flow_extract(packets[i], &flow);
+                DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+                    flow_extract(packet, &flow);
                     hash = flow_hash_5tuple(&flow, hash_act->hash_basis);
-
-                    packets[i]->md.dp_hash = hash;
+                    packet->md.dp_hash = hash;
                 }
             } else {
                 /* Assert on unknown hash algorithm.  */
@@ -643,48 +640,48 @@ odp_execute_actions(void *dp, struct dp_packet_batch *batch, bool steal,
         case OVS_ACTION_ATTR_PUSH_VLAN: {
             const struct ovs_action_push_vlan *vlan = nl_attr_get(a);
 
-            for (i = 0; i < cnt; i++) {
-                eth_push_vlan(packets[i], vlan->vlan_tpid, vlan->vlan_tci);
+            DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+                eth_push_vlan(packet, vlan->vlan_tpid, vlan->vlan_tci);
             }
             break;
         }
 
         case OVS_ACTION_ATTR_POP_VLAN:
-            for (i = 0; i < cnt; i++) {
-                eth_pop_vlan(packets[i]);
+            DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+                eth_pop_vlan(packet);
             }
             break;
 
         case OVS_ACTION_ATTR_PUSH_MPLS: {
             const struct ovs_action_push_mpls *mpls = nl_attr_get(a);
 
-            for (i = 0; i < cnt; i++) {
-                push_mpls(packets[i], mpls->mpls_ethertype, mpls->mpls_lse);
+            DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+                push_mpls(packet, mpls->mpls_ethertype, mpls->mpls_lse);
             }
             break;
          }
 
         case OVS_ACTION_ATTR_POP_MPLS:
-            for (i = 0; i < cnt; i++) {
-                pop_mpls(packets[i], nl_attr_get_be16(a));
+            DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+                pop_mpls(packet, nl_attr_get_be16(a));
             }
             break;
 
         case OVS_ACTION_ATTR_SET:
-            for (i = 0; i < cnt; i++) {
-                odp_execute_set_action(packets[i], nl_attr_get(a));
+            DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+                odp_execute_set_action(packet, nl_attr_get(a));
             }
             break;
 
         case OVS_ACTION_ATTR_SET_MASKED:
-            for (i = 0; i < cnt; i++) {
-                odp_execute_masked_set_action(packets[i], nl_attr_get(a));
+            DP_PACKET_BATCH_FOR_EACH(packet, batch) {
+                odp_execute_masked_set_action(packet, nl_attr_get(a));
             }
             break;
 
         case OVS_ACTION_ATTR_SAMPLE:
-            for (i = 0; i < cnt; i++) {
-                odp_execute_sample(dp, packets[i], steal && last_action, a,
+            DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+                odp_execute_sample(dp, packet, steal && last_action, a,
                                    dp_execute_action);
             }
 
@@ -700,15 +697,15 @@ odp_execute_actions(void *dp, struct dp_packet_batch *batch, bool steal,
                         nl_attr_get_unspec(a, sizeof *trunc);
 
             batch->trunc = true;
-            for (i = 0; i < cnt; i++) {
-                dp_packet_set_cutlen(packets[i], trunc->max_len);
+            DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+                dp_packet_set_cutlen(packet, trunc->max_len);
             }
             break;
         }
 
         case OVS_ACTION_ATTR_CLONE:
-            for (i = 0; i < cnt; i++) {
-                odp_execute_clone(dp, packets[i], steal && last_action, a,
+            DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+                odp_execute_clone(dp, packet, steal && last_action, a,
                                   dp_execute_action);
             }
 
@@ -732,8 +729,8 @@ odp_execute_actions(void *dp, struct dp_packet_batch *batch, bool steal,
     }
 
     if (steal) {
-        for (i = 0; i < cnt; i++) {
-            dp_packet_delete(packets[i]);
+        DP_PACKET_BATCH_FOR_EACH (packet, batch) {
+            dp_packet_delete(packet);
         }
     }
 }
diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
index 0513394..48b27a6 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -3825,7 +3825,7 @@ execute_controller_action(struct xlate_ctx *ctx, int len,
     }
 
     packet = dp_packet_clone(ctx->xin->packet);
-    packet_batch_init_packet(&batch, packet);
+    dp_packet_batch_init_packet(&batch, packet);
     odp_execute_actions(NULL, &batch, false,
                         ctx->odp_actions->data, ctx->odp_actions->size, NULL);
 
diff --git a/tests/test-conntrack.c b/tests/test-conntrack.c
index 803e2b9..e362f8a 100644
--- a/tests/test-conntrack.c
+++ b/tests/test-conntrack.c
@@ -39,8 +39,6 @@ prepare_packets(size_t n, bool change, unsigned tid, ovs_be16 *dl_type)
     ovs_assert(n <= ARRAY_SIZE(pkt_batch->packets));
 
     dp_packet_batch_init(pkt_batch);
-    pkt_batch->count = n;
-
     for (i = 0; i < n; i++) {
         struct udp_header *udp;
         struct dp_packet *pkt = dp_packet_new(sizeof payload/2);
@@ -55,11 +53,10 @@ prepare_packets(size_t n, bool change, unsigned tid, ovs_be16 *dl_type)
             udp->udp_dst = htons(ntohs(udp->udp_dst) + i);
         }
 
-        pkt_batch->packets[i] = pkt;
+        dp_packet_batch_add(pkt_batch, pkt);
         *dl_type = flow.dl_type;
     }
 
-
     return pkt_batch;
 }
 
@@ -154,7 +151,6 @@ static void
 pcap_batch_execute_conntrack(struct conntrack *ct,
                              struct dp_packet_batch *pkt_batch)
 {
-    size_t i;
     struct dp_packet_batch new_batch;
     ovs_be16 dl_type = htons(0);
 
@@ -162,15 +158,14 @@ pcap_batch_execute_conntrack(struct conntrack *ct,
 
     /* pkt_batch contains packets with different 'dl_type'. We have to
      * call conntrack_execute() on packets with the same 'dl_type'. */
-
-    for (i = 0; i < pkt_batch->count; i++) {
-        struct dp_packet *pkt = pkt_batch->packets[i];
+    struct dp_packet *packet;
+    DP_PACKET_BATCH_FOR_EACH (packet, pkt_batch) {
         struct flow flow;
 
         /* This also initializes the l3 and l4 pointers. */
-        flow_extract(pkt, &flow);
+        flow_extract(packet, &flow);
 
-        if (!new_batch.count) {
+        if (dp_packet_batch_is_empty(&new_batch)) {
             dl_type = flow.dl_type;
         }
 
@@ -179,10 +174,10 @@ pcap_batch_execute_conntrack(struct conntrack *ct,
                               NULL);
             dp_packet_batch_init(&new_batch);
         }
-        new_batch.packets[new_batch.count++] = pkt;
+        new_batch.packets[new_batch.count++] = packet;;
     }
 
-    if (new_batch.count) {
+    if (!dp_packet_batch_is_empty(&new_batch)) {
         conntrack_execute(ct, &new_batch, dl_type, true, 0, NULL, NULL, NULL);
     }
 
@@ -191,9 +186,9 @@ pcap_batch_execute_conntrack(struct conntrack *ct,
 static void
 test_pcap(struct ovs_cmdl_context *ctx)
 {
-    size_t total_count, i, batch_size;
+    size_t total_count, batch_size;
     FILE *pcap;
-    int err;
+    int err = 0;
 
     pcap = ovs_pcap_open(ctx->argv[1], "rb");
     if (!pcap) {
@@ -214,41 +209,36 @@ test_pcap(struct ovs_cmdl_context *ctx)
 
     conntrack_init(&ct);
     total_count = 0;
-    for (;;) {
-        struct dp_packet_batch pkt_batch;
-
-        dp_packet_batch_init(&pkt_batch);
+    while (!err) {
+        struct dp_packet *packet;
+        struct dp_packet_batch pkt_batch_;
+        struct dp_packet_batch *batch = &pkt_batch_;
 
-        for (i = 0; i < batch_size; i++) {
-            err = ovs_pcap_read(pcap, &pkt_batch.packets[i], NULL);
-            if (err) {
-                break;
-            }
+        dp_packet_batch_init(batch);
+        err = ovs_pcap_read(pcap, &packet, NULL);
+        if (err) {
+            break;
         }
+        dp_packet_batch_add(batch, packet);
 
-        pkt_batch.count = i;
-        if (pkt_batch.count == 0) {
+        if (dp_packet_batch_is_empty(batch)) {
             break;
         }
 
-        pcap_batch_execute_conntrack(&ct, &pkt_batch);
+        pcap_batch_execute_conntrack(&ct, batch);
 
-        for (i = 0; i < pkt_batch.count; i++) {
+        DP_PACKET_BATCH_FOR_EACH (packet, batch) {
             struct ds ds = DS_EMPTY_INITIALIZER;
-            struct dp_packet *pkt = pkt_batch.packets[i];
 
             total_count++;
 
-            format_flags(&ds, ct_state_to_string, pkt->md.ct_state, '|');
+            format_flags(&ds, ct_state_to_string, packet->md.ct_state, '|');
             printf("%"PRIuSIZE": %s\n", total_count, ds_cstr(&ds));
 
             ds_destroy(&ds);
         }
 
-        dp_packet_delete_batch(&pkt_batch, true);
-        if (err) {
-            break;
-        }
+        dp_packet_delete_batch(batch, true);
     }
     conntrack_destroy(&ct);
 }
-- 
1.9.1
