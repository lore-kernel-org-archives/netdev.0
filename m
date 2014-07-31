From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/3] openvswitch: Convert mask list into mask array.
Date: Thu, 31 Jul 2014 16:57:47 -0700
Message-ID: <1406851067-1651-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:50708 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752579AbaGaX5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 19:57:50 -0400
Received: by mail-pd0-f170.google.com with SMTP id g10so4398095pdj.15
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 16:57:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Next patch introduces cache for masks which stores index of
mask. list is not very convenient data structure for indexing
an element. Therefore this patch converts mask list into mask
array.

This patch does not change functionality.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Andy Zhou <azhou@nicira.com>
Acked-by: Thomas Graf <tgraf@redhat.com>
---
 net/openvswitch/flow.h       |   1 -
 net/openvswitch/flow_table.c | 182 ++++++++++++++++++++++++++++++++++++-------
 net/openvswitch/flow_table.h |   8 +-
 3 files changed, 159 insertions(+), 32 deletions(-)

diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index 5e5aaed..40ee7b0 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -123,7 +123,6 @@ struct sw_flow_key_range {
 struct sw_flow_mask {
 	int ref_count;
 	struct rcu_head rcu;
-	struct list_head list;
 	struct sw_flow_key_range range;
 	struct sw_flow_key key;
 };
diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index 02d15d8..4ba5244 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -45,6 +45,7 @@
 #include <net/ndisc.h>
 
 #define TBL_MIN_BUCKETS		1024
+#define MASK_ARRAY_SIZE_MIN	16
 #define REHASH_INTERVAL		(10 * 60 * HZ)
 
 static struct kmem_cache *flow_cache;
@@ -198,20 +199,70 @@ static struct table_instance *table_instance_alloc(int new_size)
 	return ti;
 }
 
+static struct mask_array *tbl_mask_array_alloc(int size)
+{
+	struct mask_array *new;
+
+	new = kzalloc(sizeof(*new) +
+		      sizeof(struct sw_flow_mask *) * size, GFP_KERNEL);
+	if (!new)
+		return NULL;
+
+	new->count = 0;
+	new->max = size;
+
+	return new;
+}
+
+static int tbl_mask_array_realloc(struct flow_table *tbl, int size)
+{
+	struct mask_array *old;
+	struct mask_array *new;
+
+	new = tbl_mask_array_alloc(size);
+	if (!new)
+		return -ENOMEM;
+
+	old = ovsl_dereference(tbl->mask_array);
+	if (old) {
+		int i;
+
+		for (i = 0; i < min(old->max, new->max); i++)
+			new->masks[i] = old->masks[i];
+
+		BUG_ON(old->count > new->max);
+		new->count = old->count;
+	}
+	rcu_assign_pointer(tbl->mask_array, new);
+
+	if (old)
+		kfree_rcu(old, rcu);
+
+	return 0;
+}
+
 int ovs_flow_tbl_init(struct flow_table *table)
 {
 	struct table_instance *ti;
+	struct mask_array *ma;
 
-	ti = table_instance_alloc(TBL_MIN_BUCKETS);
+	ma = tbl_mask_array_alloc(MASK_ARRAY_SIZE_MIN);
+	if (!ma)
+		return -ENOMEM;
 
+	ti = table_instance_alloc(TBL_MIN_BUCKETS);
 	if (!ti)
-		return -ENOMEM;
+		goto free_mask_array;
 
 	rcu_assign_pointer(table->ti, ti);
-	INIT_LIST_HEAD(&table->mask_list);
+	rcu_assign_pointer(table->mask_array, ma);
 	table->last_rehash = jiffies;
 	table->count = 0;
 	return 0;
+
+free_mask_array:
+	kfree(ma);
+	return -ENOMEM;
 }
 
 static void flow_tbl_destroy_rcu_cb(struct rcu_head *rcu)
@@ -255,6 +306,7 @@ skip_flows:
  */
 void ovs_flow_tbl_destroy(struct flow_table *table)
 {
+	kfree(rcu_dereference_raw(table->mask_array));
 	table_instance_destroy(rcu_dereference_raw(table->ti), false);
 }
 
@@ -432,19 +484,26 @@ static struct sw_flow *masked_flow_lookup(struct table_instance *ti,
 }
 
 struct sw_flow *ovs_flow_tbl_lookup_stats(struct flow_table *tbl,
-				    const struct sw_flow_key *key,
-				    u32 *n_mask_hit)
+					  const struct sw_flow_key *key,
+					  u32 *n_mask_hit)
 {
 	struct table_instance *ti = rcu_dereference_ovsl(tbl->ti);
-	struct sw_flow_mask *mask;
+	struct mask_array *ma;
 	struct sw_flow *flow;
+	int i;
 
 	*n_mask_hit = 0;
-	list_for_each_entry_rcu(mask, &tbl->mask_list, list) {
-		(*n_mask_hit)++;
-		flow = masked_flow_lookup(ti, key, mask);
-		if (flow)  /* Found */
-			return flow;
+	ma = rcu_dereference_ovsl(tbl->mask_array);
+	for (i = 0; i < ma->max; i++) {
+		struct sw_flow_mask *mask;
+
+		mask = rcu_dereference_ovsl(ma->masks[i]);
+		if (mask) {
+			(*n_mask_hit)++;
+			flow = masked_flow_lookup(ti, key, mask);
+			if (flow)  /* Found */
+				return flow;
+		}
 	}
 	return NULL;
 }
@@ -460,14 +519,18 @@ struct sw_flow *ovs_flow_tbl_lookup(struct flow_table *tbl,
 struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
 					  struct sw_flow_match *match)
 {
-	struct table_instance *ti = rcu_dereference_ovsl(tbl->ti);
-	struct sw_flow_mask *mask;
-	struct sw_flow *flow;
+	struct mask_array *ma = ovsl_dereference(tbl->mask_array);
+	int i;
 
 	/* Always called under ovs-mutex. */
-	list_for_each_entry(mask, &tbl->mask_list, list) {
+	for (i = 0; i < ma->count; i++) {
+		struct table_instance *ti = ovsl_dereference(tbl->ti);
+		struct sw_flow_mask *mask;
+		struct sw_flow *flow;
+
+		mask = ovsl_dereference(ma->masks[i]);
 		flow = masked_flow_lookup(ti, match->key, mask);
-		if (flow && ovs_flow_cmp_unmasked_key(flow, match))  /* Found */
+		if (flow && ovs_flow_cmp_unmasked_key(flow, match))
 			return flow;
 	}
 	return NULL;
@@ -475,13 +538,10 @@ struct sw_flow *ovs_flow_tbl_lookup_exact(struct flow_table *tbl,
 
 int ovs_flow_tbl_num_masks(const struct flow_table *table)
 {
-	struct sw_flow_mask *mask;
-	int num = 0;
+	struct mask_array *ma;
 
-	list_for_each_entry(mask, &table->mask_list, list)
-		num++;
-
-	return num;
+	ma = rcu_dereference_ovsl(table->mask_array);
+	return ma->count;
 }
 
 static struct table_instance *table_instance_expand(struct table_instance *ti)
@@ -489,6 +549,36 @@ static struct table_instance *table_instance_expand(struct table_instance *ti)
 	return table_instance_rehash(ti, ti->n_buckets * 2);
 }
 
+static void tbl_mask_array_delete_mask(struct mask_array *ma,
+				       const struct sw_flow_mask *mask)
+{
+	int i = 0;
+
+	/* Delete a mask pointer from the valid section.
+	 *
+	 * Also move the last entry in its place, so there is no
+	 * hole in the valid section (ma->masks[0 ... count-1]).
+	 *
+	 * Notice the last entry still points to the original mask.
+	 */
+	for (i = 0; i < ma->count; i++) {
+		if (mask == ovsl_dereference(ma->masks[i])) {
+			struct sw_flow_mask *last;
+
+			last = ovsl_dereference(ma->masks[ma->count - 1]);
+			rcu_assign_pointer(ma->masks[i], last);
+			ma->count--;
+			break;
+		}
+	}
+
+	/* Remove the deleted mask pointers from the invalid section. */
+	for (i = ma->count; i < ma->max; i++) {
+		if (mask == ovsl_dereference(ma->masks[i]))
+			RCU_INIT_POINTER(ma->masks[i], NULL);
+	}
+}
+
 /* Remove 'mask' from the mask list, if it is not needed any more. */
 static void flow_mask_remove(struct flow_table *tbl, struct sw_flow_mask *mask)
 {
@@ -501,7 +591,17 @@ static void flow_mask_remove(struct flow_table *tbl, struct sw_flow_mask *mask)
 		mask->ref_count--;
 
 		if (!mask->ref_count) {
-			list_del_rcu(&mask->list);
+			struct mask_array *ma;
+
+			ma = ovsl_dereference(tbl->mask_array);
+			/* Shrink the mask array if necessary. */
+			if ((ma->max > MASK_ARRAY_SIZE_MIN * 2) &&
+			    ma->count <= ma->max / 4) {
+				tbl_mask_array_realloc(tbl, ma->max / 2);
+				ma = ovsl_dereference(tbl->mask_array);
+			}
+
+			tbl_mask_array_delete_mask(ma, mask);
 			kfree_rcu(mask, rcu);
 		}
 	}
@@ -547,13 +647,16 @@ static bool mask_equal(const struct sw_flow_mask *a,
 static struct sw_flow_mask *flow_mask_find(const struct flow_table *tbl,
 					   const struct sw_flow_mask *mask)
 {
-	struct list_head *ml;
+	struct mask_array *ma;
+	int i;
+
+	ma = ovsl_dereference(tbl->mask_array);
+	for (i = 0; i < ma->count; i++) {
+		struct sw_flow_mask *t;
 
-	list_for_each(ml, &tbl->mask_list) {
-		struct sw_flow_mask *m;
-		m = container_of(ml, struct sw_flow_mask, list);
-		if (mask_equal(mask, m))
-			return m;
+		t = ovsl_dereference(ma->masks[i]);
+		if (t && mask_equal(mask, t))
+			return t;
 	}
 
 	return NULL;
@@ -564,15 +667,34 @@ static int flow_mask_insert(struct flow_table *tbl, struct sw_flow *flow,
 			    struct sw_flow_mask *new)
 {
 	struct sw_flow_mask *mask;
+
 	mask = flow_mask_find(tbl, new);
 	if (!mask) {
+		struct mask_array *ma;
+
 		/* Allocate a new mask if none exsits. */
 		mask = mask_alloc();
 		if (!mask)
 			return -ENOMEM;
 		mask->key = new->key;
 		mask->range = new->range;
-		list_add_rcu(&mask->list, &tbl->mask_list);
+
+		/* Add mask to mask-array. */
+		ma = ovsl_dereference(tbl->mask_array);
+		if (ma->count >= ma->max) {
+			int err;
+
+			err = tbl_mask_array_realloc(tbl, ma->max +
+						     MASK_ARRAY_SIZE_MIN);
+			if (err) {
+				kfree(mask);
+				return err;
+			}
+			ma = ovsl_dereference(tbl->mask_array);
+		}
+
+		rcu_assign_pointer(ma->masks[ma->count], mask);
+		ma->count++;
 	} else {
 		BUG_ON(!mask->ref_count);
 		mask->ref_count++;
diff --git a/net/openvswitch/flow_table.h b/net/openvswitch/flow_table.h
index f682c8c..2bab294 100644
--- a/net/openvswitch/flow_table.h
+++ b/net/openvswitch/flow_table.h
@@ -36,6 +36,12 @@
 
 #include "flow.h"
 
+struct mask_array {
+	struct rcu_head rcu;
+	int count, max;
+	struct sw_flow_mask __rcu *masks[];
+};
+
 struct table_instance {
 	struct flex_array *buckets;
 	unsigned int n_buckets;
@@ -47,7 +53,7 @@ struct table_instance {
 
 struct flow_table {
 	struct table_instance __rcu *ti;
-	struct list_head mask_list;
+	struct mask_array __rcu *mask_array;
 	unsigned long last_rehash;
 	unsigned int count;
 };
-- 
1.9.3
