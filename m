From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 04/18] net/mlx5: Add hold/put rules refcount API
Date: Fri, 17 Jun 2016 17:43:45 +0300
Message-ID: <1466174639-14576-5-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57414 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755365AbcFQOrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:47:21 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Steering consumers (e.g. sniffer) will need to hold a refcount
on flow rules which weren't created by them until the work on
the rule will be finished.

For that we reveal here an API to hold/put a refcount on a rule and
add a completion mechanism so the rule will not be cleared until
the ref holder will release it.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 105 +++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |   2 +
 include/linux/mlx5/fs.h                           |   3 +
 3 files changed, 76 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index ea90b66..06f94bf 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -141,6 +141,7 @@ static void tree_init_node(struct fs_node *node,
 	INIT_LIST_HEAD(&node->list);
 	INIT_LIST_HEAD(&node->children);
 	mutex_init(&node->lock);
+	init_completion(&node->complete);
 	node->remove_func = remove_func;
 }
 
@@ -190,6 +191,7 @@ static void unlock_ref_node(struct fs_node *node)
 static void tree_put_node(struct fs_node *node)
 {
 	struct fs_node *parent_node = node->parent;
+	bool node_deleted = false;
 
 	lock_ref_node(parent_node);
 	if (atomic_dec_and_test(&node->refcount)) {
@@ -197,21 +199,68 @@ static void tree_put_node(struct fs_node *node)
 			list_del_init(&node->list);
 		if (node->remove_func)
 			node->remove_func(node);
-		kfree(node);
-		node = NULL;
+		complete(&node->complete);
+		node_deleted = true;
 	}
 	unlock_ref_node(parent_node);
-	if (!node && parent_node)
+	if (node_deleted && parent_node)
 		tree_put_node(parent_node);
 }
 
-static int tree_remove_node(struct fs_node *node)
+static struct mlx5_flow_root_namespace *find_root(struct fs_node *node)
 {
-	if (atomic_read(&node->refcount) > 1) {
-		atomic_dec(&node->refcount);
-		return -EEXIST;
+	struct fs_node *root;
+	struct mlx5_flow_namespace *ns;
+
+	root = node->root;
+
+	if (WARN_ON(root->type != FS_TYPE_NAMESPACE)) {
+		pr_warn("mlx5: flow steering node is not in tree or garbaged\n");
+		return NULL;
 	}
+
+	ns = container_of(root, struct mlx5_flow_namespace, node);
+	return container_of(ns, struct mlx5_flow_root_namespace, ns);
+}
+
+static inline struct mlx5_core_dev *get_dev(struct fs_node *node)
+{
+	struct mlx5_flow_root_namespace *root = find_root(node);
+
+	if (root)
+		return root->dev;
+	return NULL;
+}
+
+#define MLX5_FS_TIMEOUT_MSEC 1000
+static int tree_remove_node(struct fs_node *node)
+{
+	unsigned long timeout = msecs_to_jiffies(MLX5_FS_TIMEOUT_MSEC);
+	struct mlx5_core_dev *dev = get_dev(node);
+
 	tree_put_node(node);
+	if (!wait_for_completion_timeout(&node->complete, timeout)) {
+		mlx5_core_warn(dev, "Timeout waiting for removing steering object\n");
+		return -ETIMEDOUT;
+	}
+	kfree(node);
+	node = NULL;
+
+	return 0;
+}
+
+static int tree_force_remove_node(struct fs_node *node)
+{
+	struct fs_node *parent_node = node->parent;
+
+	lock_ref_node(parent_node);
+	list_del_init(&node->list);
+	if (node->remove_func)
+		node->remove_func(node);
+	kfree(node);
+	node = NULL;
+	unlock_ref_node(parent_node);
+
 	return 0;
 }
 
@@ -295,31 +344,6 @@ static bool compare_match_criteria(u8 match_criteria_enable1,
 		!memcmp(mask1, mask2, MLX5_ST_SZ_BYTES(fte_match_param));
 }
 
-static struct mlx5_flow_root_namespace *find_root(struct fs_node *node)
-{
-	struct fs_node *root;
-	struct mlx5_flow_namespace *ns;
-
-	root = node->root;
-
-	if (WARN_ON(root->type != FS_TYPE_NAMESPACE)) {
-		pr_warn("mlx5: flow steering node is not in tree or garbaged\n");
-		return NULL;
-	}
-
-	ns = container_of(root, struct mlx5_flow_namespace, node);
-	return container_of(ns, struct mlx5_flow_root_namespace, ns);
-}
-
-static inline struct mlx5_core_dev *get_dev(struct fs_node *node)
-{
-	struct mlx5_flow_root_namespace *root = find_root(node);
-
-	if (root)
-		return root->dev;
-	return NULL;
-}
-
 static void del_flow_table(struct fs_node *node)
 {
 	struct mlx5_flow_table *ft;
@@ -870,6 +894,7 @@ static struct mlx5_flow_rule *alloc_rule(struct mlx5_flow_destination *dest)
 		return NULL;
 
 	INIT_LIST_HEAD(&rule->next_ft);
+	atomic_set(&rule->refcount, 1);
 	rule->node.type = FS_TYPE_FLOW_DEST;
 	if (dest)
 		memcpy(&rule->dest_attr, dest, sizeof(*dest));
@@ -1063,7 +1088,7 @@ static struct mlx5_flow_rule *add_rule_fg(struct mlx5_flow_group *fg,
 		    action == fte->action && flow_tag == fte->flow_tag) {
 			rule = find_flow_rule(fte, dest);
 			if (rule) {
-				atomic_inc(&rule->node.refcount);
+				atomic_inc(&rule->refcount);
 				unlock_ref_node(&fte->node);
 				unlock_ref_node(&fg->node);
 				return rule;
@@ -1251,6 +1276,8 @@ EXPORT_SYMBOL(mlx5_add_flow_rule);
 
 void mlx5_del_flow_rule(struct mlx5_flow_rule *rule)
 {
+	if (!atomic_dec_and_test(&rule->refcount))
+		return;
 	tree_remove_node(&rule->node);
 }
 EXPORT_SYMBOL(mlx5_del_flow_rule);
@@ -1658,7 +1685,7 @@ static void clean_tree(struct fs_node *node)
 
 		list_for_each_entry_safe(iter, temp, &node->children, list)
 			clean_tree(iter);
-		tree_remove_node(node);
+		tree_force_remove_node(node);
 	}
 }
 
@@ -1786,3 +1813,13 @@ err:
 	mlx5_cleanup_fs(dev);
 	return err;
 }
+
+void mlx5_get_flow_rule(struct mlx5_flow_rule *rule)
+{
+	tree_get_node(&rule->node);
+}
+
+void mlx5_put_flow_rule(struct mlx5_flow_rule *rule)
+{
+	tree_put_node(&rule->node);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index d7ba91a..29dd9e0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -71,6 +71,7 @@ struct fs_node {
 	struct fs_node		*root;
 	/* lock the node for writing and traversing */
 	struct mutex		lock;
+	struct completion	complete;
 	atomic_t		refcount;
 	void			(*remove_func)(struct fs_node *);
 };
@@ -83,6 +84,7 @@ struct mlx5_flow_rule {
 	 */
 	struct list_head			next_ft;
 	u32					sw_action;
+	atomic_t				refcount;
 };
 
 /* Type of children is mlx5_flow_group */
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index b300d43..37e13a1 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -149,4 +149,7 @@ void mlx5_fc_destroy(struct mlx5_core_dev *dev, struct mlx5_fc *counter);
 void mlx5_fc_query_cached(struct mlx5_fc *counter,
 			  u64 *bytes, u64 *packets, u64 *lastuse);
 
+void mlx5_get_flow_rule(struct mlx5_flow_rule *rule);
+void mlx5_put_flow_rule(struct mlx5_flow_rule *rule);
+
 #endif
-- 
2.8.0
