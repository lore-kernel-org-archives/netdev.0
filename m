From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 05/11] openvswitch: Move mega-flow list out of rehashing struct.
Date: Sat,  2 Nov 2013 00:43:44 -0700
Message-ID: <1383378230-59624-6-git-send-email-jesse@nicira.com>
References: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:33874 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752192Ab3KBVxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 17:53:04 -0400
Received: by mail-pa0-f51.google.com with SMTP id ld10so5508333pab.10
        for <netdev@vger.kernel.org>; Sat, 02 Nov 2013 14:53:02 -0700 (PDT)
In-Reply-To: <1383378230-59624-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

ovs-flow rehash does not touch mega flow list. Following patch
moves it dp struct datapath.  Avoid one extra indirection for
accessing mega-flow list head on every packet receive.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c   |  77 ++++------------
 net/openvswitch/datapath.h   |   6 +-
 net/openvswitch/flow_table.c | 205 ++++++++++++++++++++++++++-----------------
 net/openvswitch/flow_table.h |  32 +++----
 4 files changed, 155 insertions(+), 165 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 72e6874..60b9be3 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -59,8 +59,6 @@
 #include "vport-internal_dev.h"
 #include "vport-netdev.h"
 
-#define REHASH_FLOW_INTERVAL (10 * 60 * HZ)
-
 int ovs_net_id __read_mostly;
 
 static void ovs_notify(struct sk_buff *skb, struct genl_info *info,
@@ -163,7 +161,7 @@ static void destroy_dp_rcu(struct rcu_head *rcu)
 {
 	struct datapath *dp = container_of(rcu, struct datapath, rcu);
 
-	ovs_flow_tbl_destroy((__force struct flow_table *)dp->table, false);
+	ovs_flow_tbl_destroy(&dp->table, false);
 	free_percpu(dp->stats_percpu);
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp->ports);
@@ -235,7 +233,7 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	}
 
 	/* Look up flow. */
-	flow = ovs_flow_tbl_lookup(rcu_dereference(dp->table), &key);
+	flow = ovs_flow_tbl_lookup(&dp->table, &key);
 	if (unlikely(!flow)) {
 		struct dp_upcall_info upcall;
 
@@ -453,23 +451,6 @@ out:
 	return err;
 }
 
-/* Called with ovs_mutex. */
-static int flush_flows(struct datapath *dp)
-{
-	struct flow_table *old_table;
-	struct flow_table *new_table;
-
-	old_table = ovsl_dereference(dp->table);
-	new_table = ovs_flow_tbl_alloc(TBL_MIN_BUCKETS);
-	if (!new_table)
-		return -ENOMEM;
-
-	rcu_assign_pointer(dp->table, new_table);
-
-	ovs_flow_tbl_destroy(old_table, true);
-	return 0;
-}
-
 static void clear_stats(struct sw_flow *flow)
 {
 	flow->used = 0;
@@ -584,11 +565,9 @@ static struct genl_ops dp_packet_genl_ops[] = {
 
 static void get_dp_stats(struct datapath *dp, struct ovs_dp_stats *stats)
 {
-	struct flow_table *table;
 	int i;
 
-	table = rcu_dereference_check(dp->table, lockdep_ovsl_is_held());
-	stats->n_flows = ovs_flow_tbl_count(table);
+	stats->n_flows = ovs_flow_tbl_count(&dp->table);
 
 	stats->n_hit = stats->n_missed = stats->n_lost = 0;
 	for_each_possible_cpu(i) {
@@ -773,7 +752,6 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow_mask mask;
 	struct sk_buff *reply;
 	struct datapath *dp;
-	struct flow_table *table;
 	struct sw_flow_actions *acts = NULL;
 	struct sw_flow_match match;
 	int error;
@@ -814,12 +792,9 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	if (!dp)
 		goto err_unlock_ovs;
 
-	table = ovsl_dereference(dp->table);
-
 	/* Check if this is a duplicate flow */
-	flow = ovs_flow_tbl_lookup(table, &key);
+	flow = ovs_flow_tbl_lookup(&dp->table, &key);
 	if (!flow) {
-		struct flow_table *new_table = NULL;
 		struct sw_flow_mask *mask_p;
 
 		/* Bail out if we're not allowed to create a new flow. */
@@ -827,19 +802,6 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		if (info->genlhdr->cmd == OVS_FLOW_CMD_SET)
 			goto err_unlock_ovs;
 
-		/* Expand table, if necessary, to make room. */
-		if (ovs_flow_tbl_need_to_expand(table))
-			new_table = ovs_flow_tbl_expand(table);
-		else if (time_after(jiffies, dp->last_rehash + REHASH_FLOW_INTERVAL))
-			new_table = ovs_flow_tbl_rehash(table);
-
-		if (new_table && !IS_ERR(new_table)) {
-			rcu_assign_pointer(dp->table, new_table);
-			ovs_flow_tbl_destroy(table, true);
-			table = ovsl_dereference(dp->table);
-			dp->last_rehash = jiffies;
-		}
-
 		/* Allocate flow. */
 		flow = ovs_flow_alloc();
 		if (IS_ERR(flow)) {
@@ -852,7 +814,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		flow->unmasked_key = key;
 
 		/* Make sure mask is unique in the system */
-		mask_p = ovs_sw_flow_mask_find(table, &mask);
+		mask_p = ovs_sw_flow_mask_find(&dp->table, &mask);
 		if (!mask_p) {
 			/* Allocate a new mask if none exsits. */
 			mask_p = ovs_sw_flow_mask_alloc();
@@ -860,7 +822,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 				goto err_flow_free;
 			mask_p->key = mask.key;
 			mask_p->range = mask.range;
-			ovs_sw_flow_mask_insert(table, mask_p);
+			ovs_sw_flow_mask_insert(&dp->table, mask_p);
 		}
 
 		ovs_sw_flow_mask_add_ref(mask_p);
@@ -868,7 +830,7 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 		rcu_assign_pointer(flow->sf_acts, acts);
 
 		/* Put flow in bucket. */
-		ovs_flow_tbl_insert(table, flow);
+		ovs_flow_tbl_insert(&dp->table, flow);
 
 		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
 						info->snd_seq, OVS_FLOW_CMD_NEW);
@@ -936,7 +898,6 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *reply;
 	struct sw_flow *flow;
 	struct datapath *dp;
-	struct flow_table *table;
 	struct sw_flow_match match;
 	int err;
 
@@ -957,8 +918,7 @@ static int ovs_flow_cmd_get(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	table = ovsl_dereference(dp->table);
-	flow = ovs_flow_tbl_lookup(table, &key);
+	flow = ovs_flow_tbl_lookup(&dp->table, &key);
 	if (!flow || !ovs_flow_cmp_unmasked_key(flow, &match)) {
 		err = -ENOENT;
 		goto unlock;
@@ -986,7 +946,6 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	struct sk_buff *reply;
 	struct sw_flow *flow;
 	struct datapath *dp;
-	struct flow_table *table;
 	struct sw_flow_match match;
 	int err;
 
@@ -998,7 +957,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	if (!a[OVS_FLOW_ATTR_KEY]) {
-		err = flush_flows(dp);
+		err = ovs_flow_tbl_flush(&dp->table);
 		goto unlock;
 	}
 
@@ -1007,8 +966,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 	if (err)
 		goto unlock;
 
-	table = ovsl_dereference(dp->table);
-	flow = ovs_flow_tbl_lookup(table, &key);
+	flow = ovs_flow_tbl_lookup(&dp->table, &key);
 	if (!flow || !ovs_flow_cmp_unmasked_key(flow, &match)) {
 		err = -ENOENT;
 		goto unlock;
@@ -1020,7 +978,7 @@ static int ovs_flow_cmd_del(struct sk_buff *skb, struct genl_info *info)
 		goto unlock;
 	}
 
-	ovs_flow_tbl_remove(table, flow);
+	ovs_flow_tbl_remove(&dp->table, flow);
 
 	err = ovs_flow_cmd_fill_info(flow, dp, reply, info->snd_portid,
 				     info->snd_seq, 0, OVS_FLOW_CMD_DEL);
@@ -1039,8 +997,8 @@ unlock:
 static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct ovs_header *ovs_header = genlmsg_data(nlmsg_data(cb->nlh));
+	struct table_instance *ti;
 	struct datapath *dp;
-	struct flow_table *table;
 
 	rcu_read_lock();
 	dp = get_dp(sock_net(skb->sk), ovs_header->dp_ifindex);
@@ -1049,14 +1007,14 @@ static int ovs_flow_cmd_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		return -ENODEV;
 	}
 
-	table = rcu_dereference(dp->table);
+	ti = rcu_dereference(dp->table.ti);
 	for (;;) {
 		struct sw_flow *flow;
 		u32 bucket, obj;
 
 		bucket = cb->args[0];
 		obj = cb->args[1];
-		flow = ovs_flow_tbl_dump_next(table, &bucket, &obj);
+		flow = ovs_flow_tbl_dump_next(ti, &bucket, &obj);
 		if (!flow)
 			break;
 
@@ -1220,9 +1178,8 @@ static int ovs_dp_cmd_new(struct sk_buff *skb, struct genl_info *info)
 	ovs_dp_set_net(dp, hold_net(sock_net(skb->sk)));
 
 	/* Allocate table. */
-	err = -ENOMEM;
-	rcu_assign_pointer(dp->table, ovs_flow_tbl_alloc(TBL_MIN_BUCKETS));
-	if (!dp->table)
+	err = ovs_flow_tbl_init(&dp->table);
+	if (err)
 		goto err_free_dp;
 
 	dp->stats_percpu = alloc_percpu(struct dp_stats_percpu);
@@ -1279,7 +1236,7 @@ err_destroy_ports_array:
 err_destroy_percpu:
 	free_percpu(dp->stats_percpu);
 err_destroy_table:
-	ovs_flow_tbl_destroy(ovsl_dereference(dp->table), false);
+	ovs_flow_tbl_destroy(&dp->table, false);
 err_free_dp:
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp);
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index a6982ef..acfd4af 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -58,12 +58,11 @@ struct dp_stats_percpu {
  * struct datapath - datapath for flow-based packet switching
  * @rcu: RCU callback head for deferred destruction.
  * @list_node: Element in global 'dps' list.
- * @table: Current flow table.  Protected by ovs_mutex and RCU.
+ * @table: flow table.
  * @ports: Hash table for ports.  %OVSP_LOCAL port always exists.  Protected by
  * ovs_mutex and RCU.
  * @stats_percpu: Per-CPU datapath statistics.
  * @net: Reference to net namespace.
- * @last_rehash: Timestamp of last rehash.
  *
  * Context: See the comment on locking at the top of datapath.c for additional
  * locking information.
@@ -73,7 +72,7 @@ struct datapath {
 	struct list_head list_node;
 
 	/* Flow table. */
-	struct flow_table __rcu *table;
+	struct flow_table table;
 
 	/* Switch ports. */
 	struct hlist_head *ports;
@@ -85,7 +84,6 @@ struct datapath {
 	/* Network namespace ref. */
 	struct net *net;
 #endif
-	unsigned long last_rehash;
 };
 
 /**
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index dcadb75..1c7e773 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -44,6 +44,11 @@
 #include <net/ipv6.h>
 #include <net/ndisc.h>
 
+#include "datapath.h"
+
+#define TBL_MIN_BUCKETS		1024
+#define REHASH_INTERVAL		(10 * 60 * HZ)
+
 static struct kmem_cache *flow_cache;
 
 static u16 range_n_bytes(const struct sw_flow_key_range *range)
@@ -82,6 +87,11 @@ struct sw_flow *ovs_flow_alloc(void)
 	return flow;
 }
 
+int ovs_flow_tbl_count(struct flow_table *table)
+{
+	return table->count;
+}
+
 static struct flex_array *alloc_buckets(unsigned int n_buckets)
 {
 	struct flex_array *buckets;
@@ -136,18 +146,18 @@ static void free_buckets(struct flex_array *buckets)
 	flex_array_free(buckets);
 }
 
-static void __flow_tbl_destroy(struct flow_table *table)
+static void __table_instance_destroy(struct table_instance *ti)
 {
 	int i;
 
-	if (table->keep_flows)
+	if (ti->keep_flows)
 		goto skip_flows;
 
-	for (i = 0; i < table->n_buckets; i++) {
+	for (i = 0; i < ti->n_buckets; i++) {
 		struct sw_flow *flow;
-		struct hlist_head *head = flex_array_get(table->buckets, i);
+		struct hlist_head *head = flex_array_get(ti->buckets, i);
 		struct hlist_node *n;
-		int ver = table->node_ver;
+		int ver = ti->node_ver;
 
 		hlist_for_each_entry_safe(flow, n, head, hash_node[ver]) {
 			hlist_del(&flow->hash_node[ver]);
@@ -155,74 +165,74 @@ static void __flow_tbl_destroy(struct flow_table *table)
 		}
 	}
 
-	BUG_ON(!list_empty(table->mask_list));
-	kfree(table->mask_list);
-
 skip_flows:
-	free_buckets(table->buckets);
-	kfree(table);
+	free_buckets(ti->buckets);
+	kfree(ti);
 }
 
-static struct flow_table *__flow_tbl_alloc(int new_size)
+static struct table_instance *table_instance_alloc(int new_size)
 {
-	struct flow_table *table = kmalloc(sizeof(*table), GFP_KERNEL);
+	struct table_instance *ti = kmalloc(sizeof(*ti), GFP_KERNEL);
 
-	if (!table)
+	if (!ti)
 		return NULL;
 
-	table->buckets = alloc_buckets(new_size);
+	ti->buckets = alloc_buckets(new_size);
 
-	if (!table->buckets) {
-		kfree(table);
+	if (!ti->buckets) {
+		kfree(ti);
 		return NULL;
 	}
-	table->n_buckets = new_size;
-	table->count = 0;
-	table->node_ver = 0;
-	table->keep_flows = false;
-	get_random_bytes(&table->hash_seed, sizeof(u32));
-	table->mask_list = NULL;
+	ti->n_buckets = new_size;
+	ti->node_ver = 0;
+	ti->keep_flows = false;
+	get_random_bytes(&ti->hash_seed, sizeof(u32));
 
-	return table;
+	return ti;
 }
 
-struct flow_table *ovs_flow_tbl_alloc(int new_size)
+int ovs_flow_tbl_init(struct flow_table *table)
 {
-	struct flow_table *table = __flow_tbl_alloc(new_size);
+	struct table_instance *ti;
 
-	if (!table)
-		return NULL;
+	ti = table_instance_alloc(TBL_MIN_BUCKETS);
 
-	table->mask_list = kmalloc(sizeof(struct list_head), GFP_KERNEL);
-	if (!table->mask_list) {
-		table->keep_flows = true;
-		__flow_tbl_destroy(table);
-		return NULL;
-	}
-	INIT_LIST_HEAD(table->mask_list);
+	if (!ti)
+		return -ENOMEM;
 
-	return table;
+	rcu_assign_pointer(table->ti, ti);
+	INIT_LIST_HEAD(&table->mask_list);
+	table->last_rehash = jiffies;
+	table->count = 0;
+	return 0;
 }
 
 static void flow_tbl_destroy_rcu_cb(struct rcu_head *rcu)
 {
-	struct flow_table *table = container_of(rcu, struct flow_table, rcu);
+	struct table_instance *ti = container_of(rcu, struct table_instance, rcu);
 
-	__flow_tbl_destroy(table);
+	__table_instance_destroy(ti);
 }
 
-void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred)
+static void table_instance_destroy(struct table_instance *ti, bool deferred)
 {
-	if (!table)
+	if (!ti)
 		return;
 
 	if (deferred)
-		call_rcu(&table->rcu, flow_tbl_destroy_rcu_cb);
+		call_rcu(&ti->rcu, flow_tbl_destroy_rcu_cb);
 	else
-		__flow_tbl_destroy(table);
+		__table_instance_destroy(ti);
+}
+
+void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred)
+{
+	struct table_instance *ti = ovsl_dereference(table->ti);
+
+	table_instance_destroy(ti, deferred);
 }
 
-struct sw_flow *ovs_flow_tbl_dump_next(struct flow_table *table,
+struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *ti,
 				       u32 *bucket, u32 *last)
 {
 	struct sw_flow *flow;
@@ -230,10 +240,10 @@ struct sw_flow *ovs_flow_tbl_dump_next(struct flow_table *table,
 	int ver;
 	int i;
 
-	ver = table->node_ver;
-	while (*bucket < table->n_buckets) {
+	ver = ti->node_ver;
+	while (*bucket < ti->n_buckets) {
 		i = 0;
-		head = flex_array_get(table->buckets, *bucket);
+		head = flex_array_get(ti->buckets, *bucket);
 		hlist_for_each_entry_rcu(flow, head, hash_node[ver]) {
 			if (i < *last) {
 				i++;
@@ -249,25 +259,23 @@ struct sw_flow *ovs_flow_tbl_dump_next(struct flow_table *table,
 	return NULL;
 }
 
-static struct hlist_head *find_bucket(struct flow_table *table, u32 hash)
+static struct hlist_head *find_bucket(struct table_instance *ti, u32 hash)
 {
-	hash = jhash_1word(hash, table->hash_seed);
-	return flex_array_get(table->buckets,
-				(hash & (table->n_buckets - 1)));
+	hash = jhash_1word(hash, ti->hash_seed);
+	return flex_array_get(ti->buckets,
+				(hash & (ti->n_buckets - 1)));
 }
 
-static void __tbl_insert(struct flow_table *table, struct sw_flow *flow)
+static void table_instance_insert(struct table_instance *ti, struct sw_flow *flow)
 {
 	struct hlist_head *head;
 
-	head = find_bucket(table, flow->hash);
-	hlist_add_head_rcu(&flow->hash_node[table->node_ver], head);
-
-	table->count++;
+	head = find_bucket(ti, flow->hash);
+	hlist_add_head_rcu(&flow->hash_node[ti->node_ver], head);
 }
 
-static void flow_table_copy_flows(struct flow_table *old,
-				  struct flow_table *new)
+static void flow_table_copy_flows(struct table_instance *old,
+				  struct table_instance *new)
 {
 	int old_ver;
 	int i;
@@ -283,35 +291,42 @@ static void flow_table_copy_flows(struct flow_table *old,
 		head = flex_array_get(old->buckets, i);
 
 		hlist_for_each_entry(flow, head, hash_node[old_ver])
-			__tbl_insert(new, flow);
+			table_instance_insert(new, flow);
 	}
 
-	new->mask_list = old->mask_list;
 	old->keep_flows = true;
 }
 
-static struct flow_table *__flow_tbl_rehash(struct flow_table *table,
+static struct table_instance *table_instance_rehash(struct table_instance *ti,
 					    int n_buckets)
 {
-	struct flow_table *new_table;
+	struct table_instance *new_ti;
 
-	new_table = __flow_tbl_alloc(n_buckets);
-	if (!new_table)
+	new_ti = table_instance_alloc(n_buckets);
+	if (!new_ti)
 		return ERR_PTR(-ENOMEM);
 
-	flow_table_copy_flows(table, new_table);
+	flow_table_copy_flows(ti, new_ti);
 
-	return new_table;
+	return new_ti;
 }
 
-struct flow_table *ovs_flow_tbl_rehash(struct flow_table *table)
+int ovs_flow_tbl_flush(struct flow_table *flow_table)
 {
-	return __flow_tbl_rehash(table, table->n_buckets);
-}
+	struct table_instance *old_ti;
+	struct table_instance *new_ti;
 
-struct flow_table *ovs_flow_tbl_expand(struct flow_table *table)
-{
-	return __flow_tbl_rehash(table, table->n_buckets * 2);
+	old_ti = ovsl_dereference(flow_table->ti);
+	new_ti = table_instance_alloc(TBL_MIN_BUCKETS);
+	if (!new_ti)
+		return -ENOMEM;
+
+	rcu_assign_pointer(flow_table->ti, new_ti);
+	flow_table->last_rehash = jiffies;
+	flow_table->count = 0;
+
+	table_instance_destroy(old_ti, true);
+	return 0;
 }
 
 static u32 flow_hash(const struct sw_flow_key *key, int key_start,
@@ -367,7 +382,7 @@ bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
 	return cmp_key(&flow->unmasked_key, key, key_start, key_end);
 }
 
-static struct sw_flow *masked_flow_lookup(struct flow_table *table,
+static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 					  const struct sw_flow_key *unmasked,
 					  struct sw_flow_mask *mask)
 {
@@ -380,8 +395,8 @@ static struct sw_flow *masked_flow_lookup(struct flow_table *table,
 
 	ovs_flow_mask_key(&masked_key, unmasked, mask);
 	hash = flow_hash(&masked_key, key_start, key_end);
-	head = find_bucket(table, hash);
-	hlist_for_each_entry_rcu(flow, head, hash_node[table->node_ver]) {
+	head = find_bucket(ti, hash);
+	hlist_for_each_entry_rcu(flow, head, hash_node[ti->node_ver]) {
 		if (flow->mask == mask &&
 		    flow_cmp_masked_key(flow, &masked_key,
 					  key_start, key_end))
@@ -393,29 +408,55 @@ static struct sw_flow *masked_flow_lookup(struct flow_table *table,
 struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
 				    const struct sw_flow_key *key)
 {
-	struct sw_flow *flow = NULL;
+	struct table_instance *ti = rcu_dereference(tbl->ti);
 	struct sw_flow_mask *mask;
+	struct sw_flow *flow;
 
-	list_for_each_entry_rcu(mask, tbl->mask_list, list) {
-		flow = masked_flow_lookup(tbl, key, mask);
+	list_for_each_entry_rcu(mask, &tbl->mask_list, list) {
+		flow = masked_flow_lookup(ti, key, mask);
 		if (flow)  /* Found */
-			break;
+			return flow;
 	}
+	return NULL;
+}
 
-	return flow;
+static struct table_instance *table_instance_expand(struct table_instance *ti)
+{
+	return table_instance_rehash(ti, ti->n_buckets * 2);
 }
 
 void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow)
 {
+	struct table_instance *ti = NULL;
+	struct table_instance *new_ti = NULL;
+
+	ti = ovsl_dereference(table->ti);
+
+	/* Expand table, if necessary, to make room. */
+	if (table->count > ti->n_buckets)
+		new_ti = table_instance_expand(ti);
+	else if (time_after(jiffies, table->last_rehash + REHASH_INTERVAL))
+		new_ti = table_instance_rehash(ti, ti->n_buckets);
+
+	if (new_ti && !IS_ERR(new_ti)) {
+		rcu_assign_pointer(table->ti, new_ti);
+		ovs_flow_tbl_destroy(table, true);
+		ti = ovsl_dereference(table->ti);
+		table->last_rehash = jiffies;
+	}
+
 	flow->hash = flow_hash(&flow->key, flow->mask->range.start,
 			flow->mask->range.end);
-	__tbl_insert(table, flow);
+	table_instance_insert(ti, flow);
+	table->count++;
 }
 
 void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
 {
+	struct table_instance *ti = ovsl_dereference(table->ti);
+
 	BUG_ON(table->count == 0);
-	hlist_del_rcu(&flow->hash_node[table->node_ver]);
+	hlist_del_rcu(&flow->hash_node[ti->node_ver]);
 	table->count--;
 }
 
@@ -475,7 +516,7 @@ struct sw_flow_mask *ovs_sw_flow_mask_find(const struct flow_table *tbl,
 {
 	struct list_head *ml;
 
-	list_for_each(ml, tbl->mask_list) {
+	list_for_each(ml, &tbl->mask_list) {
 		struct sw_flow_mask *m;
 		m = container_of(ml, struct sw_flow_mask, list);
 		if (mask_equal(mask, m))
@@ -492,7 +533,7 @@ struct sw_flow_mask *ovs_sw_flow_mask_find(const struct flow_table *tbl,
  */
 void ovs_sw_flow_mask_insert(struct flow_table *tbl, struct sw_flow_mask *mask)
 {
-	list_add_rcu(&mask->list, tbl->mask_list);
+	list_add_rcu(&mask->list, &tbl->mask_list);
 }
 
 /* Initializes the flow module.
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index d7a1144..5d1abe5 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -36,42 +36,36 @@
 
 #include "flow.h"
 
-#define TBL_MIN_BUCKETS		1024
-
-struct flow_table {
+struct table_instance {
 	struct flex_array *buckets;
-	unsigned int count, n_buckets;
+	unsigned int n_buckets;
 	struct rcu_head rcu;
-	struct list_head *mask_list;
 	int node_ver;
 	u32 hash_seed;
 	bool keep_flows;
 };
 
+struct flow_table {
+	struct table_instance __rcu *ti;
+	struct list_head mask_list;
+	unsigned long last_rehash;
+	unsigned int count;
+};
+
 int ovs_flow_init(void);
 void ovs_flow_exit(void);
 
 struct sw_flow *ovs_flow_alloc(void);
 void ovs_flow_free(struct sw_flow *, bool deferred);
 
-static inline int ovs_flow_tbl_count(struct flow_table *table)
-{
-	return table->count;
-}
-
-static inline int ovs_flow_tbl_need_to_expand(struct flow_table *table)
-{
-	return (table->count > table->n_buckets);
-}
-
-struct flow_table *ovs_flow_tbl_alloc(int new_size);
-struct flow_table *ovs_flow_tbl_expand(struct flow_table *table);
-struct flow_table *ovs_flow_tbl_rehash(struct flow_table *table);
+int ovs_flow_tbl_init(struct flow_table *);
+int ovs_flow_tbl_count(struct flow_table *table);
 void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred);
+int ovs_flow_tbl_flush(struct flow_table *flow_table);
 
 void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow);
 void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow);
-struct sw_flow *ovs_flow_tbl_dump_next(struct flow_table *table,
+struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *table,
 				       u32 *bucket, u32 *idx);
 struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
 				    const struct sw_flow_key *);
-- 
1.8.3.2
