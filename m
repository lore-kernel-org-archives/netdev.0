From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 3/3] openvswitch: Introduce flow mask cache.
Date: Thu, 31 Jul 2014 16:57:54 -0700
Message-ID: <1406851074-1680-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:38148 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752796AbaGaX55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 19:57:57 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so4399281pdj.16
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 16:57:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On a packet OVS needs to lookup flow-table with every mask
until it finds a match. The packet flow-key is first masked
with mask in the list and then the masked key is looked up in
flow-table. Therefore number of masks can affect packet
processing performance.

Following patch introduces caching for masks. It uses packet
RSS as key to lookup entry in mask cache. Mask cache has index
of the mask in mask-array.
This has doubled throughput performance when OVS has 20 masks
and packets are hitting all of these different masks evenly.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
Tested-by: Vasmi Abidi <vabidi@vmware.com>
Acked-by: Thomas Graf <tgraf@redhat.com>
---
 net/openvswitch/datapath.c   |   3 +-
 net/openvswitch/flow_table.c | 124 +++++++++++++++++++++++++++++++++++++------
 net/openvswitch/flow_table.h |  11 +++-
 3 files changed, 119 insertions(+), 19 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index e5cc62b..ac57c0b 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -260,7 +260,8 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	}
 
 	/* Look up flow. */
-	flow = ovs_flow_tbl_lookup_stats(&dp->table, &key, &n_mask_hit);
+	flow = ovs_flow_tbl_lookup_stats(&dp->table, &key, skb_get_hash(skb),
+					 &n_mask_hit);
 	if (unlikely(!flow)) {
 		struct dp_upcall_info upcall;
 
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 4ba5244..13ecef8 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -48,6 +48,10 @@
 #define MASK_ARRAY_SIZE_MIN	16
 #define REHASH_INTERVAL		(10 * 60 * HZ)
 
+#define MC_HASH_SHIFT		8
+#define MC_HASH_ENTRIES		(1u << MC_HASH_SHIFT)
+#define MC_HASH_SEGS		((sizeof(uint32_t) * 8) / MC_HASH_SHIFT)
+
 static struct kmem_cache *flow_cache;
 struct kmem_cache *flow_stats_cache __read_mostly;
 
@@ -245,10 +249,17 @@ int ovs_flow_tbl_init(struct flow_table *table)
 {
 	struct table_instance *ti;
 	struct mask_array *ma;
+	int cache_size;
+
+	cache_size = sizeof(struct mask_cache_entry) * MC_HASH_ENTRIES;
+	table->mask_cache = __alloc_percpu(cache_size,
+					   __alignof__(struct mask_cache_entry));
+	if (!table->mask_cache)
+		return -ENOMEM;
 
 	ma = tbl_mask_array_alloc(MASK_ARRAY_SIZE_MIN);
 	if (!ma)
-		return -ENOMEM;
+		goto free_mask_cache;
 
 	ti = table_instance_alloc(TBL_MIN_BUCKETS);
 	if (!ti)
@@ -262,6 +273,8 @@ int ovs_flow_tbl_init(struct flow_table *table)
 
 free_mask_array:
 	kfree(ma);
+free_mask_cache:
+	free_percpu(table->mask_cache);
 	return -ENOMEM;
 }
 
@@ -307,6 +320,7 @@ skip_flows:
 void ovs_flow_tbl_destroy(struct flow_table *table)
 {
 	kfree(rcu_dereference_raw(table->mask_array));
+	free_percpu(table->mask_cache);
 	table_instance_destroy(rcu_dereference_raw(table->ti), false);
 }
 
@@ -462,7 +476,8 @@ bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
 
 static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 					  const struct sw_flow_key *unmasked,
-					  struct sw_flow_mask *mask)
+					  struct sw_flow_mask *mask,
+					  u32 *n_mask_hit)
 {
 	struct sw_flow *flow;
 	struct hlist_head *head;
@@ -474,6 +489,7 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 	ovs_flow_mask_key(&masked_key, unmasked, mask);
 	hash = flow_hash(&masked_key, key_start, key_end);
 	head = find_bucket(ti, hash);
+	(*n_mask_hit)++;
 	hlist_for_each_entry_rcu(flow, head, hash_node[ti->node_ver]) {
 		if (flow->mask == mask && flow->hash == hash &&
 		    flow_cmp_masked_key(flow, &masked_key,
@@ -483,37 +499,112 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 	return NULL;
 }
 
-struct sw_flow *ovs_flow_tbl_lookup_stats(struct flow_table *tbl,
-					  const struct sw_flow_key *key,
-					  u32 *n_mask_hit)
+static struct sw_flow *flow_lookup(struct flow_table *tbl,
+				   struct table_instance *ti,
+				   struct mask_array *ma,
+				   const struct sw_flow_key *key,
+				   u32 *n_mask_hit,
+				   u32 *index)
 {
-	struct table_instance *ti = rcu_dereference_ovsl(tbl->ti);
-	struct mask_array *ma;
 	struct sw_flow *flow;
 	int i;
 
-	*n_mask_hit = 0;
-	ma = rcu_dereference_ovsl(tbl->mask_array);
 	for (i = 0; i < ma->max; i++) {
 		struct sw_flow_mask *mask;
 
 		mask = rcu_dereference_ovsl(ma->masks[i]);
-		if (mask) {
-			(*n_mask_hit)++;
-			flow = masked_flow_lookup(ti, key, mask);
-			if (flow)  /* Found */
-				return flow;
+		if (!mask)
+			break;
+
+		flow = masked_flow_lookup(ti, key, mask, n_mask_hit);
+		if (flow) { /* Found */
+			*index = i;
+			return flow;
 		}
 	}
 	return NULL;
 }
 
+/* mask_cache maps packet to probable mask. It uses packet RSS as key
+ * to lookup mask. This cache is not tightly coupled cache, It means
+ * updates to mask list can result in inconsistent cache entry in mask
+ * cache, in such cases full lookup is done.
+ * This is per cpu cache and is divided in MC_HASH_SEGS segments.
+ */
+struct sw_flow *ovs_flow_tbl_lookup_stats(struct flow_table *tbl,
+					  const struct sw_flow_key *key,
+					  u32 skb_hash,
+					  u32 *n_mask_hit)
+{
+	struct mask_array *ma = rcu_dereference(tbl->mask_array);
+	struct table_instance *ti = rcu_dereference(tbl->ti);
+	struct mask_cache_entry *entries, *ce;
+	struct sw_flow *flow;
+	u32 hash = skb_hash;
+	int seg;
+
+	*n_mask_hit = 0;
+	if (unlikely(!skb_hash)) {
+		u32 __always_unused mask_index;
+
+		return flow_lookup(tbl, ti, ma, key, n_mask_hit, &mask_index);
+	}
+
+	ce = NULL;
+	entries = this_cpu_ptr(tbl->mask_cache);
+
+	/* Find the cache entry 'ce' to operate on. */
+	for (seg = 0; seg < MC_HASH_SEGS; seg++) {
+		int index = hash & (MC_HASH_ENTRIES - 1);
+		struct mask_cache_entry *e;
+
+		e = &entries[index];
+		if (e->skb_hash == skb_hash) {
+			struct sw_flow_mask *cache;
+			int i = e->mask_index;
+
+			if (likely(i < ma->max)) {
+				cache = rcu_dereference(ma->masks[i]);
+				if (cache) {
+					flow = masked_flow_lookup(ti, key,
+								  cache,
+								  n_mask_hit);
+					if (flow)
+						return flow;
+				}
+			}
+
+			/* Cache miss. This is the best cache
+			 * replacement candidate.
+			 */
+			e->skb_hash = 0;
+			ce = e;
+			break;
+		}
+
+		if (!ce || e->skb_hash < ce->skb_hash)
+			ce = e;  /* A better replacement cache candidate. */
+
+		hash >>= MC_HASH_SHIFT;
+	}
+
+	/* Cache miss, do full lookup. */
+	flow = flow_lookup(tbl, ti, ma, key, n_mask_hit, &ce->mask_index);
+	if (flow)
+		ce->skb_hash = skb_hash;
+
+	return flow;
+}
+
 struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
 				    const struct sw_flow_key *key)
 {
+	struct table_instance *ti = rcu_dereference_ovsl(tbl->ti);
+	struct mask_array *ma = rcu_dereference_ovsl(tbl->mask_array);
 	u32 __always_unused n_mask_hit;
+	u32 __always_unused index;
 
-	return ovs_flow_tbl_lookup_stats(tbl, key, &n_mask_hit);
+	return flow_lookup(tbl, ti, ma, key, &n_mask_hit, &index);
 }
 
 struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
@@ -525,11 +616,12 @@ struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
 	/* Always called under ovs-mutex. */
 	for (i = 0; i < ma->count; i++) {
 		struct table_instance *ti = ovsl_dereference(tbl->ti);
+		u32 __always_unused n_mask_hit;
 		struct sw_flow_mask *mask;
 		struct sw_flow *flow;
 
 		mask = ovsl_dereference(ma->masks[i]);
-		flow = masked_flow_lookup(ti, match->key, mask);
+		flow = masked_flow_lookup(ti, match->key, mask, &n_mask_hit);
 		if (flow && ovs_flow_cmp_unmasked_key(flow, match))
 			return flow;
 	}
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index 2bab294..98ec990b 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -36,6 +36,11 @@
 
 #include "flow.h"
 
+struct mask_cache_entry {
+	u32 skb_hash;
+	u32 mask_index;
+};
+
 struct mask_array {
 	struct rcu_head rcu;
 	int count, max;
@@ -53,6 +58,7 @@ struct table_instance {
 
 struct flow_table {
 	struct table_instance __rcu *ti;
+	struct mask_cache_entry __percpu *mask_cache;
 	struct mask_array __rcu *mask_array;
 	unsigned long last_rehash;
 	unsigned int count;
@@ -78,8 +84,9 @@ int  ovs_flow_tbl_num_masks(const struct flow_table *table);
 struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *table,
 				       u32 *bucket, u32 *idx);
 struct sw_flow *ovs_flow_tbl_lookup_stats(struct flow_table *,
-				    const struct sw_flow_key *,
-				    u32 *n_mask_hit);
+					  const struct sw_flow_key *,
+					  u32 skb_hash,
+					  u32 *n_mask_hit);
 struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
 				    const struct sw_flow_key *);
 struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
-- 
1.9.3
