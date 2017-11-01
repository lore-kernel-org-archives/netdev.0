From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 6/7] cxgb4: convert flower table to use rhashtable
Date: Wed,  1 Nov 2017 08:53:04 +0530
Message-ID: <1ceab8f553c5cc52b8761d112590749dc26d923a.1509505160.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:49097 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754179AbdKADY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 23:24:58 -0400
In-Reply-To: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
References: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

T6 supports ~500K hash filters and can theoretically climb up to
~1 million hash filters. Preallocated hash table is not efficient
in terms of memory usage. So, use rhashtable instead which gives
the flexibility to grow based on usage.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   4 +-
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   | 106 ++++++++++++++-------
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h   |   4 +-
 4 files changed, 82 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index bb7f0e4c9a81..0c83ceb5a1a6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -918,8 +918,10 @@ struct adapter {
 	struct chcr_stats_debug chcr_stats;
 
 	/* TC flower offload */
-	DECLARE_HASHTABLE(flower_anymatch_tbl, 9);
+	struct rhashtable flower_tbl;
+	struct rhashtable_params flower_ht_params;
 	struct timer_list flower_stats_timer;
+	struct work_struct flower_stats_work;
 
 	/* Ethtool Dump */
 	struct ethtool_dump eth_dump;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 35709c7f7c5b..8fd41917c07a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5182,7 +5182,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			dev_warn(&pdev->dev,
 				 "could not offload tc u32, continuing\n");
 
-		cxgb4_init_tc_flower(adapter);
+		if (cxgb4_init_tc_flower(adapter))
+			dev_warn(&pdev->dev,
+				 "could not offload tc flower, continuing\n");
 	}
 
 	if (is_offload(adapter) || is_hashfilter(adapter)) {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
index a26acd183eef..3953bc1fdc20 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
@@ -74,13 +74,8 @@ static struct ch_tc_flower_entry *allocate_flower_entry(void)
 static struct ch_tc_flower_entry *ch_flower_lookup(struct adapter *adap,
 						   unsigned long flower_cookie)
 {
-	struct ch_tc_flower_entry *flower_entry;
-
-	hash_for_each_possible_rcu(adap->flower_anymatch_tbl, flower_entry,
-				   link, flower_cookie)
-		if (flower_entry->tc_flower_cookie == flower_cookie)
-			return flower_entry;
-	return NULL;
+	return rhashtable_lookup_fast(&adap->flower_tbl, &flower_cookie,
+				      adap->flower_ht_params);
 }
 
 static void cxgb4_process_flow_match(struct net_device *dev,
@@ -707,12 +702,17 @@ int cxgb4_tc_flower_replace(struct net_device *dev,
 		goto free_entry;
 	}
 
-	INIT_HLIST_NODE(&ch_flower->link);
 	ch_flower->tc_flower_cookie = cls->cookie;
 	ch_flower->filter_id = ctx.tid;
-	hash_add_rcu(adap->flower_anymatch_tbl, &ch_flower->link, cls->cookie);
+	ret = rhashtable_insert_fast(&adap->flower_tbl, &ch_flower->node,
+				     adap->flower_ht_params);
+	if (ret)
+		goto del_filter;
 
-	return ret;
+	return 0;
+
+del_filter:
+	cxgb4_del_filter(dev, ch_flower->filter_id, &ch_flower->fs);
 
 free_entry:
 	kfree(ch_flower);
@@ -734,44 +734,66 @@ int cxgb4_tc_flower_destroy(struct net_device *dev,
 	if (ret)
 		goto err;
 
-	hash_del_rcu(&ch_flower->link);
+	ret = rhashtable_remove_fast(&adap->flower_tbl, &ch_flower->node,
+				     adap->flower_ht_params);
+	if (ret) {
+		netdev_err(dev, "Flow remove from rhashtable failed");
+		goto err;
+	}
 	kfree_rcu(ch_flower, rcu);
 
 err:
 	return ret;
 }
 
-static void ch_flower_stats_cb(struct timer_list *t)
+static void ch_flower_stats_handler(struct work_struct *work)
 {
-	struct adapter *adap = from_timer(adap, t, flower_stats_timer);
+	struct adapter *adap = container_of(work, struct adapter,
+					    flower_stats_work);
 	struct ch_tc_flower_entry *flower_entry;
 	struct ch_tc_flower_stats *ofld_stats;
-	unsigned int i;
+	struct rhashtable_iter iter;
 	u64 packets;
 	u64 bytes;
 	int ret;
 
-	rcu_read_lock();
-	hash_for_each_rcu(adap->flower_anymatch_tbl, i, flower_entry, link) {
-		ret = cxgb4_get_filter_counters(adap->port[0],
-						flower_entry->filter_id,
-						&packets, &bytes,
-						flower_entry->fs.hash);
-		if (!ret) {
-			spin_lock(&flower_entry->lock);
-			ofld_stats = &flower_entry->stats;
-
-			if (ofld_stats->prev_packet_count != packets) {
-				ofld_stats->prev_packet_count = packets;
-				ofld_stats->last_used = jiffies;
+	rhashtable_walk_enter(&adap->flower_tbl, &iter);
+	do {
+		flower_entry = ERR_PTR(rhashtable_walk_start(&iter));
+		if (IS_ERR(flower_entry))
+			goto walk_stop;
+
+		while ((flower_entry = rhashtable_walk_next(&iter)) &&
+		       !IS_ERR(flower_entry)) {
+			ret = cxgb4_get_filter_counters(adap->port[0],
+							flower_entry->filter_id,
+							&packets, &bytes,
+							flower_entry->fs.hash);
+			if (!ret) {
+				spin_lock(&flower_entry->lock);
+				ofld_stats = &flower_entry->stats;
+
+				if (ofld_stats->prev_packet_count != packets) {
+					ofld_stats->prev_packet_count = packets;
+					ofld_stats->last_used = jiffies;
+				}
+				spin_unlock(&flower_entry->lock);
 			}
-			spin_unlock(&flower_entry->lock);
 		}
-	}
-	rcu_read_unlock();
+walk_stop:
+		rhashtable_walk_stop(&iter);
+	} while (flower_entry == ERR_PTR(-EAGAIN));
+	rhashtable_walk_exit(&iter);
 	mod_timer(&adap->flower_stats_timer, jiffies + STATS_CHECK_PERIOD);
 }
 
+static void ch_flower_stats_cb(struct timer_list *t)
+{
+	struct adapter *adap = from_timer(adap, t, flower_stats_timer);
+
+	schedule_work(&adap->flower_stats_work);
+}
+
 int cxgb4_tc_flower_stats(struct net_device *dev,
 			  struct tc_cls_flower_offload *cls)
 {
@@ -814,15 +836,35 @@ int cxgb4_tc_flower_stats(struct net_device *dev,
 	return ret;
 }
 
-void cxgb4_init_tc_flower(struct adapter *adap)
+static const struct rhashtable_params cxgb4_tc_flower_ht_params = {
+	.nelem_hint = 384,
+	.head_offset = offsetof(struct ch_tc_flower_entry, node),
+	.key_offset = offsetof(struct ch_tc_flower_entry, tc_flower_cookie),
+	.key_len = sizeof(((struct ch_tc_flower_entry *)0)->tc_flower_cookie),
+	.max_size = 524288,
+	.min_size = 512,
+	.automatic_shrinking = true
+};
+
+int cxgb4_init_tc_flower(struct adapter *adap)
 {
-	hash_init(adap->flower_anymatch_tbl);
+	int ret;
+
+	adap->flower_ht_params = cxgb4_tc_flower_ht_params;
+	ret = rhashtable_init(&adap->flower_tbl, &adap->flower_ht_params);
+	if (ret)
+		return ret;
+
+	INIT_WORK(&adap->flower_stats_work, ch_flower_stats_handler);
 	timer_setup(&adap->flower_stats_timer, ch_flower_stats_cb, 0);
 	mod_timer(&adap->flower_stats_timer, jiffies + STATS_CHECK_PERIOD);
+	return 0;
 }
 
 void cxgb4_cleanup_tc_flower(struct adapter *adap)
 {
 	if (adap->flower_stats_timer.function)
 		del_timer_sync(&adap->flower_stats_timer);
+	cancel_work_sync(&adap->flower_stats_work);
+	rhashtable_destroy(&adap->flower_tbl);
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h
index 202d5c9ec303..050c8a50ae41 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h
@@ -48,7 +48,7 @@ struct ch_tc_flower_entry {
 	struct ch_filter_specification fs;
 	struct ch_tc_flower_stats stats;
 	unsigned long tc_flower_cookie;
-	struct hlist_node link;
+	struct rhash_head node;
 	struct rcu_head rcu;
 	spinlock_t lock; /* lock for stats */
 	u32 filter_id;
@@ -115,6 +115,6 @@ int cxgb4_tc_flower_destroy(struct net_device *dev,
 int cxgb4_tc_flower_stats(struct net_device *dev,
 			  struct tc_cls_flower_offload *cls);
 
-void cxgb4_init_tc_flower(struct adapter *adap);
+int cxgb4_init_tc_flower(struct adapter *adap);
 void cxgb4_cleanup_tc_flower(struct adapter *adap);
 #endif /* __CXGB4_TC_FLOWER_H */
-- 
2.14.1
