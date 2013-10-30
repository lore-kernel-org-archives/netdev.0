From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 06/11] openvswitch: Simplify mega-flow APIs.
Date: Tue, 29 Oct 2013 17:22:19 -0700
Message-ID: <1383092544-50599-7-git-send-email-jesse@nicira.com>
References: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:41191 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751859Ab3J3AWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 20:22:41 -0400
Received: by mail-pd0-f174.google.com with SMTP id z10so165631pdj.33
        for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 17:22:40 -0700 (PDT)
In-Reply-To: <1383092544-50599-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>

Hides mega-flow implementation in flow_table.c rather than
datapath.c.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 net/openvswitch/datapath.c   |  27 +++------
 net/openvswitch/flow_table.c | 138 +++++++++++++++++++++++++------------------
 net/openvswitch/flow_table.h |  12 +---
 3 files changed, 89 insertions(+), 88 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 60b9be3..cf27097 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -161,7 +161,7 @@ static void destroy_dp_rcu(struct rcu_head *rcu)
 {
 	struct datapath *dp = container_of(rcu, struct datapath, rcu);
 
-	ovs_flow_tbl_destroy(&dp->table, false);
+	ovs_flow_tbl_destroy(&dp->table);
 	free_percpu(dp->stats_percpu);
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp->ports);
@@ -795,8 +795,6 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 	/* Check if this is a duplicate flow */
 	flow = ovs_flow_tbl_lookup(&dp->table, &key);
 	if (!flow) {
-		struct sw_flow_mask *mask_p;
-
 		/* Bail out if we're not allowed to create a new flow. */
 		error = -ENOENT;
 		if (info->genlhdr->cmd == OVS_FLOW_CMD_SET)
@@ -812,25 +810,14 @@ static int ovs_flow_cmd_new_or_set(struct sk_buff *skb, struct genl_info *info)
 
 		flow->key = masked_key;
 		flow->unmasked_key = key;
-
-		/* Make sure mask is unique in the system */
-		mask_p = ovs_sw_flow_mask_find(&dp->table, &mask);
-		if (!mask_p) {
-			/* Allocate a new mask if none exsits. */
-			mask_p = ovs_sw_flow_mask_alloc();
-			if (!mask_p)
-				goto err_flow_free;
-			mask_p->key = mask.key;
-			mask_p->range = mask.range;
-			ovs_sw_flow_mask_insert(&dp->table, mask_p);
-		}
-
-		ovs_sw_flow_mask_add_ref(mask_p);
-		flow->mask = mask_p;
 		rcu_assign_pointer(flow->sf_acts, acts);
 
 		/* Put flow in bucket. */
-		ovs_flow_tbl_insert(&dp->table, flow);
+		error = ovs_flow_tbl_insert(&dp->table, flow, &mask);
+		if (error) {
+			acts = NULL;
+			goto err_flow_free;
+		}
 
 		reply = ovs_flow_cmd_build_info(flow, dp, info->snd_portid,
 						info->snd_seq, OVS_FLOW_CMD_NEW);
@@ -1236,7 +1223,7 @@ err_destroy_ports_array:
 err_destroy_percpu:
 	free_percpu(dp->stats_percpu);
 err_destroy_table:
-	ovs_flow_tbl_destroy(&dp->table, false);
+	ovs_flow_tbl_destroy(&dp->table);
 err_free_dp:
 	release_net(ovs_dp_get_net(dp));
 	kfree(dp);
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 1c7e773..036e019 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -128,12 +128,36 @@ static void rcu_free_flow_callback(struct rcu_head *rcu)
 	flow_free(flow);
 }
 
+static void rcu_free_sw_flow_mask_cb(struct rcu_head *rcu)
+{
+	struct sw_flow_mask *mask = container_of(rcu, struct sw_flow_mask, rcu);
+
+	kfree(mask);
+}
+
+static void flow_mask_del_ref(struct sw_flow_mask *mask, bool deferred)
+{
+	if (!mask)
+		return;
+
+	BUG_ON(!mask->ref_count);
+	mask->ref_count--;
+
+	if (!mask->ref_count) {
+		list_del_rcu(&mask->list);
+		if (deferred)
+			call_rcu(&mask->rcu, rcu_free_sw_flow_mask_cb);
+		else
+			kfree(mask);
+	}
+}
+
 void ovs_flow_free(struct sw_flow *flow, bool deferred)
 {
 	if (!flow)
 		return;
 
-	ovs_sw_flow_mask_del_ref(flow->mask, deferred);
+	flow_mask_del_ref(flow->mask, deferred);
 
 	if (deferred)
 		call_rcu(&flow->rcu, rcu_free_flow_callback);
@@ -225,11 +249,11 @@ static void table_instance_destroy(struct table_instance *ti, bool deferred)
 		__table_instance_destroy(ti);
 }
 
-void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred)
+void ovs_flow_tbl_destroy(struct flow_table *table)
 {
 	struct table_instance *ti = ovsl_dereference(table->ti);
 
-	table_instance_destroy(ti, deferred);
+	table_instance_destroy(ti, false);
 }
 
 struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *ti,
@@ -304,7 +328,7 @@ static struct table_instance *table_instance_rehash(struct table_instance *ti,
 
 	new_ti = table_instance_alloc(n_buckets);
 	if (!new_ti)
-		return ERR_PTR(-ENOMEM);
+		return NULL;
 
 	flow_table_copy_flows(ti, new_ti);
 
@@ -425,32 +449,6 @@ static struct table_instance *table_instance_expand(struct table_instance *ti)
 	return table_instance_rehash(ti, ti->n_buckets * 2);
 }
 
-void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow)
-{
-	struct table_instance *ti = NULL;
-	struct table_instance *new_ti = NULL;
-
-	ti = ovsl_dereference(table->ti);
-
-	/* Expand table, if necessary, to make room. */
-	if (table->count > ti->n_buckets)
-		new_ti = table_instance_expand(ti);
-	else if (time_after(jiffies, table->last_rehash + REHASH_INTERVAL))
-		new_ti = table_instance_rehash(ti, ti->n_buckets);
-
-	if (new_ti && !IS_ERR(new_ti)) {
-		rcu_assign_pointer(table->ti, new_ti);
-		ovs_flow_tbl_destroy(table, true);
-		ti = ovsl_dereference(table->ti);
-		table->last_rehash = jiffies;
-	}
-
-	flow->hash = flow_hash(&flow->key, flow->mask->range.start,
-			flow->mask->range.end);
-	table_instance_insert(ti, flow);
-	table->count++;
-}
-
 void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
 {
 	struct table_instance *ti = ovsl_dereference(table->ti);
@@ -460,7 +458,7 @@ void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow)
 	table->count--;
 }
 
-struct sw_flow_mask *ovs_sw_flow_mask_alloc(void)
+static struct sw_flow_mask *mask_alloc(void)
 {
 	struct sw_flow_mask *mask;
 
@@ -471,35 +469,11 @@ struct sw_flow_mask *ovs_sw_flow_mask_alloc(void)
 	return mask;
 }
 
-void ovs_sw_flow_mask_add_ref(struct sw_flow_mask *mask)
+static void mask_add_ref(struct sw_flow_mask *mask)
 {
 	mask->ref_count++;
 }
 
-static void rcu_free_sw_flow_mask_cb(struct rcu_head *rcu)
-{
-	struct sw_flow_mask *mask = container_of(rcu, struct sw_flow_mask, rcu);
-
-	kfree(mask);
-}
-
-void ovs_sw_flow_mask_del_ref(struct sw_flow_mask *mask, bool deferred)
-{
-	if (!mask)
-		return;
-
-	BUG_ON(!mask->ref_count);
-	mask->ref_count--;
-
-	if (!mask->ref_count) {
-		list_del_rcu(&mask->list);
-		if (deferred)
-			call_rcu(&mask->rcu, rcu_free_sw_flow_mask_cb);
-		else
-			kfree(mask);
-	}
-}
-
 static bool mask_equal(const struct sw_flow_mask *a,
 		       const struct sw_flow_mask *b)
 {
@@ -511,7 +485,7 @@ static bool mask_equal(const struct sw_flow_mask *a,
 		&& (memcmp(a_, b_, range_n_bytes(&a->range)) == 0);
 }
 
-struct sw_flow_mask *ovs_sw_flow_mask_find(const struct flow_table *tbl,
+static struct sw_flow_mask *flow_mask_find(const struct flow_table *tbl,
 					   const struct sw_flow_mask *mask)
 {
 	struct list_head *ml;
@@ -531,9 +505,55 @@ struct sw_flow_mask *ovs_sw_flow_mask_find(const struct flow_table *tbl,
  * The caller needs to make sure that 'mask' is not the same
  * as any masks that are already on the list.
  */
-void ovs_sw_flow_mask_insert(struct flow_table *tbl, struct sw_flow_mask *mask)
+static int flow_mask_insert(struct flow_table *tbl, struct sw_flow *flow,
+			    struct sw_flow_mask *new)
+{
+	struct sw_flow_mask *mask;
+	mask = flow_mask_find(tbl, new);
+	if (!mask) {
+		/* Allocate a new mask if none exsits. */
+		mask = mask_alloc();
+		if (!mask)
+			return -ENOMEM;
+		mask->key = new->key;
+		mask->range = new->range;
+		list_add_rcu(&mask->list, &tbl->mask_list);
+	}
+
+	mask_add_ref(mask);
+	flow->mask = mask;
+	return 0;
+}
+
+int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
+			struct sw_flow_mask *mask)
 {
-	list_add_rcu(&mask->list, &tbl->mask_list);
+	struct table_instance *new_ti = NULL;
+	struct table_instance *ti;
+	int err;
+
+	err = flow_mask_insert(table, flow, mask);
+	if (err)
+		return err;
+
+	flow->hash = flow_hash(&flow->key, flow->mask->range.start,
+			flow->mask->range.end);
+	ti = ovsl_dereference(table->ti);
+	table_instance_insert(ti, flow);
+	table->count++;
+
+	/* Expand table, if necessary, to make room. */
+	if (table->count > ti->n_buckets)
+		new_ti = table_instance_expand(ti);
+	else if (time_after(jiffies, table->last_rehash + REHASH_INTERVAL))
+		new_ti = table_instance_rehash(ti, ti->n_buckets);
+
+	if (new_ti) {
+		rcu_assign_pointer(table->ti, new_ti);
+		table_instance_destroy(ti, true);
+		table->last_rehash = jiffies;
+	}
+	return 0;
 }
 
 /* Initializes the flow module.
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index 5d1abe5..4db5f78 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -60,10 +60,11 @@ void ovs_flow_free(struct sw_flow *, bool deferred);
 
 int ovs_flow_tbl_init(struct flow_table *);
 int ovs_flow_tbl_count(struct flow_table *table);
-void ovs_flow_tbl_destroy(struct flow_table *table, bool deferred);
+void ovs_flow_tbl_destroy(struct flow_table *table);
 int ovs_flow_tbl_flush(struct flow_table *flow_table);
 
-void ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow);
+int ovs_flow_tbl_insert(struct flow_table *table, struct sw_flow *flow,
+			struct sw_flow_mask *mask);
 void ovs_flow_tbl_remove(struct flow_table *table, struct sw_flow *flow);
 struct sw_flow *ovs_flow_tbl_dump_next(struct table_instance *table,
 				       u32 *bucket, u32 *idx);
@@ -73,13 +74,6 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *,
 bool ovs_flow_cmp_unmasked_key(const struct sw_flow *flow,
 			       struct sw_flow_match *match);
 
-struct sw_flow_mask *ovs_sw_flow_mask_alloc(void);
-void ovs_sw_flow_mask_add_ref(struct sw_flow_mask *);
-void ovs_sw_flow_mask_del_ref(struct sw_flow_mask *, bool deferred);
-void ovs_sw_flow_mask_insert(struct flow_table *, struct sw_flow_mask *);
-struct sw_flow_mask *ovs_sw_flow_mask_find(const struct flow_table *,
-					   const struct sw_flow_mask *);
 void ovs_flow_mask_key(struct sw_flow_key *dst, const struct sw_flow_key *src,
 		       const struct sw_flow_mask *mask);
-
 #endif /* flow_table.h */
-- 
1.8.3.2
