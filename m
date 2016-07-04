From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 3/8] net/mlx5: Properly remove all steering objects
Date: Mon,  4 Jul 2016 17:23:07 +0300
Message-ID: <1467642192-28259-4-git-send-email-saeedm@mellanox.com>
References: <1467642192-28259-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54682 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751980AbcGDOXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 10:23:51 -0400
In-Reply-To: <1467642192-28259-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Instead of explicitly cleaning up the well known parts of the steering
tree, we use the generic tree structure to traverse for cleanup.
No functional changes.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 120 +++-------------------
 1 file changed, 15 insertions(+), 105 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 0f969cb..3e95775 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1663,115 +1663,24 @@ cleanup:
 	return -ENOMEM;
 }
 
-static void cleanup_single_prio_root_ns(struct mlx5_flow_steering *steering,
-					struct mlx5_flow_root_namespace *root_ns)
+static void clean_tree(struct fs_node *node)
 {
-	struct fs_node *prio;
-
-	if (!root_ns)
-		return;
+	if (node) {
+		struct fs_node *iter;
+		struct fs_node *temp;
 
-	if (!list_empty(&root_ns->ns.node.children)) {
-		prio = list_first_entry(&root_ns->ns.node.children,
-					struct fs_node,
-				 list);
-		if (tree_remove_node(prio))
-			mlx5_core_warn(steering->dev,
-				       "Flow steering priority wasn't destroyed, refcount > 1\n");
+		list_for_each_entry_safe(iter, temp, &node->children, list)
+			clean_tree(iter);
+		tree_remove_node(node);
 	}
-	if (tree_remove_node(&root_ns->ns.node))
-		mlx5_core_warn(steering->dev,
-			       "Flow steering namespace wasn't destroyed, refcount > 1\n");
-	root_ns = NULL;
-}
-
-static void destroy_flow_tables(struct fs_prio *prio)
-{
-	struct mlx5_flow_table *iter;
-	struct mlx5_flow_table *tmp;
-
-	fs_for_each_ft_safe(iter, tmp, prio)
-		mlx5_destroy_flow_table(iter);
 }
 
-static void cleanup_root_ns(struct mlx5_flow_steering *steering)
+static void cleanup_root_ns(struct mlx5_flow_root_namespace *root_ns)
 {
-	struct mlx5_flow_root_namespace *root_ns = steering->root_ns;
-	struct fs_prio *iter_prio;
-
-	if (!MLX5_CAP_GEN(steering->dev, nic_flow_table))
-		return;
-
 	if (!root_ns)
 		return;
 
-	/* stage 1 */
-	fs_for_each_prio(iter_prio, &root_ns->ns) {
-		struct fs_node *node;
-		struct mlx5_flow_namespace *iter_ns;
-
-		fs_for_each_ns_or_ft(node, iter_prio) {
-			if (node->type == FS_TYPE_FLOW_TABLE)
-				continue;
-			fs_get_obj(iter_ns, node);
-			while (!list_empty(&iter_ns->node.children)) {
-				struct fs_prio *obj_iter_prio2;
-				struct fs_node *iter_prio2 =
-					list_first_entry(&iter_ns->node.children,
-							 struct fs_node,
-							 list);
-
-				fs_get_obj(obj_iter_prio2, iter_prio2);
-				destroy_flow_tables(obj_iter_prio2);
-				if (tree_remove_node(iter_prio2)) {
-					mlx5_core_warn(steering->dev,
-						       "Priority %d wasn't destroyed, refcount > 1\n",
-						       obj_iter_prio2->prio);
-					return;
-				}
-			}
-		}
-	}
-
-	/* stage 2 */
-	fs_for_each_prio(iter_prio, &root_ns->ns) {
-		while (!list_empty(&iter_prio->node.children)) {
-			struct fs_node *iter_ns =
-				list_first_entry(&iter_prio->node.children,
-						 struct fs_node,
-						 list);
-			if (tree_remove_node(iter_ns)) {
-				mlx5_core_warn(steering->dev,
-					       "Namespace wasn't destroyed, refcount > 1\n");
-				return;
-			}
-		}
-	}
-
-	/* stage 3 */
-	while (!list_empty(&root_ns->ns.node.children)) {
-		struct fs_prio *obj_prio_node;
-		struct fs_node *prio_node =
-			list_first_entry(&root_ns->ns.node.children,
-					 struct fs_node,
-					 list);
-
-		fs_get_obj(obj_prio_node, prio_node);
-		if (tree_remove_node(prio_node)) {
-			mlx5_core_warn(steering->dev,
-				       "Priority %d wasn't destroyed, refcount > 1\n",
-				       obj_prio_node->prio);
-			return;
-		}
-	}
-
-	if (tree_remove_node(&root_ns->ns.node)) {
-		mlx5_core_warn(steering->dev,
-			       "root namespace wasn't destroyed, refcount > 1\n");
-		return;
-	}
-
-	steering->root_ns = NULL;
+	clean_tree(&root_ns->ns.node);
 }
 
 void mlx5_cleanup_fs(struct mlx5_core_dev *dev)
@@ -1781,10 +1690,10 @@ void mlx5_cleanup_fs(struct mlx5_core_dev *dev)
 	if (MLX5_CAP_GEN(dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
 		return;
 
-	cleanup_root_ns(steering);
-	cleanup_single_prio_root_ns(steering, steering->esw_egress_root_ns);
-	cleanup_single_prio_root_ns(steering, steering->esw_ingress_root_ns);
-	cleanup_single_prio_root_ns(steering, steering->fdb_root_ns);
+	cleanup_root_ns(steering->root_ns);
+	cleanup_root_ns(steering->esw_egress_root_ns);
+	cleanup_root_ns(steering->esw_ingress_root_ns);
+	cleanup_root_ns(steering->fdb_root_ns);
 	mlx5_cleanup_fc_stats(dev);
 	kfree(steering);
 }
@@ -1800,7 +1709,8 @@ static int init_fdb_root_ns(struct mlx5_flow_steering *steering)
 	/* Create single prio */
 	prio = fs_create_prio(&steering->fdb_root_ns->ns, 0, 1);
 	if (IS_ERR(prio)) {
-		cleanup_single_prio_root_ns(steering, steering->fdb_root_ns);
+		cleanup_root_ns(steering->fdb_root_ns);
+		steering->fdb_root_ns = NULL;
 		return PTR_ERR(prio);
 	} else {
 		return 0;
-- 
2.8.0
