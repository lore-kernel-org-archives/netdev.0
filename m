From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 01/10] net/mlx5: Store counters in rbtree instead of list
Date: Wed, 13 Jul 2016 00:28:57 +0300
Message-ID: <1468358946-28709-2-git-send-email-saeedm@mellanox.com>
References: <1468358946-28709-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51211 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751084AbcGLVbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 17:31:03 -0400
In-Reply-To: <1468358946-28709-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>

In order to use bulk counters, we need to have counters sorted by id.

Signed-off-by: Amir Vadai <amir@vadai.me>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  1 +
 .../net/ethernet/mellanox/mlx5/core/fs_counters.c  | 64 ++++++++++++++++++----
 include/linux/mlx5/driver.h                        |  2 +-
 3 files changed, 56 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index d7ba91a..9cffb6a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -111,6 +111,7 @@ struct mlx5_fc_cache {
 };
 
 struct mlx5_fc {
+	struct rb_node node;
 	struct list_head list;
 
 	/* last{packets,bytes} members are used when calculating the delta since
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
index 164dc37..aaf8fd1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c
@@ -32,6 +32,7 @@
 
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/fs.h>
+#include <linux/rbtree.h>
 #include "mlx5_core.h"
 #include "fs_core.h"
 #include "fs_cmd.h"
@@ -68,6 +69,27 @@
  *   elapsed, the thread will actually query the hardware.
  */
 
+static void mlx5_fc_stats_insert(struct rb_root *root, struct mlx5_fc *counter)
+{
+	struct rb_node **new = &root->rb_node;
+	struct rb_node *parent = NULL;
+
+	while (*new) {
+		struct mlx5_fc *this = container_of(*new, struct mlx5_fc, node);
+		int result = counter->id - this->id;
+
+		parent = *new;
+		if (result < 0)
+			new = &((*new)->rb_left);
+		else
+			new = &((*new)->rb_right);
+	}
+
+	/* Add new node and rebalance tree. */
+	rb_link_node(&counter->node, parent, new);
+	rb_insert_color(&counter->node, root);
+}
+
 static void mlx5_fc_stats_work(struct work_struct *work)
 {
 	struct mlx5_core_dev *dev = container_of(work, struct mlx5_core_dev,
@@ -75,25 +97,35 @@ static void mlx5_fc_stats_work(struct work_struct *work)
 	struct mlx5_fc_stats *fc_stats = &dev->priv.fc_stats;
 	unsigned long now = jiffies;
 	struct mlx5_fc *counter;
-	struct mlx5_fc *tmp;
+	struct rb_node *node;
+	LIST_HEAD(tmplist);
 	int err = 0;
 
 	spin_lock(&fc_stats->addlist_lock);
 
-	list_splice_tail_init(&fc_stats->addlist, &fc_stats->list);
+	list_splice_tail_init(&fc_stats->addlist, &tmplist);
 
-	if (!list_empty(&fc_stats->list))
+	if (!list_empty(&tmplist) || !RB_EMPTY_ROOT(&fc_stats->counters))
 		queue_delayed_work(fc_stats->wq, &fc_stats->work, MLX5_FC_STATS_PERIOD);
 
 	spin_unlock(&fc_stats->addlist_lock);
 
-	list_for_each_entry_safe(counter, tmp, &fc_stats->list, list) {
-		struct mlx5_fc_cache *c = &counter->cache;
+	list_for_each_entry(counter, &tmplist, list)
+		mlx5_fc_stats_insert(&fc_stats->counters, counter);
+
+	node = rb_first(&fc_stats->counters);
+	while (node) {
+		struct mlx5_fc_cache *c;
 		u64 packets;
 		u64 bytes;
 
+		counter = rb_entry(node, struct mlx5_fc, node);
+		c = &counter->cache;
+
+		node = rb_next(node);
+
 		if (counter->deleted) {
-			list_del(&counter->list);
+			rb_erase(&counter->node, &fc_stats->counters);
 
 			mlx5_cmd_fc_free(dev, counter->id);
 
@@ -176,7 +208,7 @@ int mlx5_init_fc_stats(struct mlx5_core_dev *dev)
 {
 	struct mlx5_fc_stats *fc_stats = &dev->priv.fc_stats;
 
-	INIT_LIST_HEAD(&fc_stats->list);
+	fc_stats->counters = RB_ROOT;
 	INIT_LIST_HEAD(&fc_stats->addlist);
 	spin_lock_init(&fc_stats->addlist_lock);
 
@@ -194,20 +226,32 @@ void mlx5_cleanup_fc_stats(struct mlx5_core_dev *dev)
 	struct mlx5_fc_stats *fc_stats = &dev->priv.fc_stats;
 	struct mlx5_fc *counter;
 	struct mlx5_fc *tmp;
+	struct rb_node *node;
 
 	cancel_delayed_work_sync(&dev->priv.fc_stats.work);
 	destroy_workqueue(dev->priv.fc_stats.wq);
 	dev->priv.fc_stats.wq = NULL;
 
-	list_splice_tail_init(&fc_stats->addlist, &fc_stats->list);
-
-	list_for_each_entry_safe(counter, tmp, &fc_stats->list, list) {
+	list_for_each_entry_safe(counter, tmp, &fc_stats->addlist, list) {
 		list_del(&counter->list);
 
 		mlx5_cmd_fc_free(dev, counter->id);
 
 		kfree(counter);
 	}
+
+	node = rb_first(&fc_stats->counters);
+	while (node) {
+		counter = rb_entry(node, struct mlx5_fc, node);
+
+		node = rb_next(node);
+
+		rb_erase(&counter->node, &fc_stats->counters);
+
+		mlx5_cmd_fc_free(dev, counter->id);
+
+		kfree(counter);
+	}
 }
 
 void mlx5_fc_query_cached(struct mlx5_fc *counter,
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 81e8396..a041b99 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -469,7 +469,7 @@ struct mlx5_irq_info {
 };
 
 struct mlx5_fc_stats {
-	struct list_head list;
+	struct rb_root counters;
 	struct list_head addlist;
 	/* protect addlist add/splice operations */
 	spinlock_t addlist_lock;
-- 
2.8.0
