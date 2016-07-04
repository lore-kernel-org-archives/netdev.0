From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 2/8] net/mlx5: Introduce mlx5_flow_steering structure
Date: Mon,  4 Jul 2016 17:23:06 +0300
Message-ID: <1467642192-28259-3-git-send-email-saeedm@mellanox.com>
References: <1467642192-28259-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54679 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751889AbcGDOXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 10:23:51 -0400
In-Reply-To: <1467642192-28259-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Instead of having all steering private name spaces and
steering module fields flat in mlx5_core_priv, we wrap
them in mlx5_flow_steering for better modularity and
API exposure.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 134 ++++++++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |   8 ++
 include/linux/mlx5/driver.h                       |   6 +-
 3 files changed, 84 insertions(+), 64 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 7fcdae1..0f969cb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1363,12 +1363,13 @@ void mlx5_destroy_flow_group(struct mlx5_flow_group *fg)
 struct mlx5_flow_namespace *mlx5_get_flow_namespace(struct mlx5_core_dev *dev,
 						    enum mlx5_flow_namespace_type type)
 {
-	struct mlx5_flow_root_namespace *root_ns = dev->priv.root_ns;
+	struct mlx5_flow_steering *steering = dev->priv.steering;
+	struct mlx5_flow_root_namespace *root_ns;
 	int prio;
 	struct fs_prio *fs_prio;
 	struct mlx5_flow_namespace *ns;
 
-	if (!root_ns)
+	if (!steering)
 		return NULL;
 
 	switch (type) {
@@ -1380,24 +1381,28 @@ struct mlx5_flow_namespace *mlx5_get_flow_namespace(struct mlx5_core_dev *dev,
 		prio = type;
 		break;
 	case MLX5_FLOW_NAMESPACE_FDB:
-		if (dev->priv.fdb_root_ns)
-			return &dev->priv.fdb_root_ns->ns;
+		if (steering->fdb_root_ns)
+			return &steering->fdb_root_ns->ns;
 		else
 			return NULL;
 	case MLX5_FLOW_NAMESPACE_ESW_EGRESS:
-		if (dev->priv.esw_egress_root_ns)
-			return &dev->priv.esw_egress_root_ns->ns;
+		if (steering->esw_egress_root_ns)
+			return &steering->esw_egress_root_ns->ns;
 		else
 			return NULL;
 	case MLX5_FLOW_NAMESPACE_ESW_INGRESS:
-		if (dev->priv.esw_ingress_root_ns)
-			return &dev->priv.esw_ingress_root_ns->ns;
+		if (steering->esw_ingress_root_ns)
+			return &steering->esw_ingress_root_ns->ns;
 		else
 			return NULL;
 	default:
 		return NULL;
 	}
 
+	root_ns = steering->root_ns;
+	if (!root_ns)
+		return NULL;
+
 	fs_prio = find_prio(&root_ns->ns, prio);
 	if (!fs_prio)
 		return NULL;
@@ -1483,13 +1488,13 @@ static bool has_required_caps(struct mlx5_core_dev *dev, struct node_caps *caps)
 	return true;
 }
 
-static int init_root_tree_recursive(struct mlx5_core_dev *dev,
+static int init_root_tree_recursive(struct mlx5_flow_steering *steering,
 				    struct init_tree_node *init_node,
 				    struct fs_node *fs_parent_node,
 				    struct init_tree_node *init_parent_node,
 				    int prio)
 {
-	int max_ft_level = MLX5_CAP_FLOWTABLE(dev,
+	int max_ft_level = MLX5_CAP_FLOWTABLE(steering->dev,
 					      flow_table_properties_nic_receive.
 					      max_ft_level);
 	struct mlx5_flow_namespace *fs_ns;
@@ -1500,7 +1505,7 @@ static int init_root_tree_recursive(struct mlx5_core_dev *dev,
 
 	if (init_node->type == FS_TYPE_PRIO) {
 		if ((init_node->min_ft_level > max_ft_level) ||
-		    !has_required_caps(dev, &init_node->caps))
+		    !has_required_caps(steering->dev, &init_node->caps))
 			return 0;
 
 		fs_get_obj(fs_ns, fs_parent_node);
@@ -1521,7 +1526,7 @@ static int init_root_tree_recursive(struct mlx5_core_dev *dev,
 	}
 	prio = 0;
 	for (i = 0; i < init_node->ar_size; i++) {
-		err = init_root_tree_recursive(dev, &init_node->children[i],
+		err = init_root_tree_recursive(steering, &init_node->children[i],
 					       base, init_node, prio);
 		if (err)
 			return err;
@@ -1534,7 +1539,7 @@ static int init_root_tree_recursive(struct mlx5_core_dev *dev,
 	return 0;
 }
 
-static int init_root_tree(struct mlx5_core_dev *dev,
+static int init_root_tree(struct mlx5_flow_steering *steering,
 			  struct init_tree_node *init_node,
 			  struct fs_node *fs_parent_node)
 {
@@ -1544,7 +1549,7 @@ static int init_root_tree(struct mlx5_core_dev *dev,
 
 	fs_get_obj(fs_ns, fs_parent_node);
 	for (i = 0; i < init_node->ar_size; i++) {
-		err = init_root_tree_recursive(dev, &init_node->children[i],
+		err = init_root_tree_recursive(steering, &init_node->children[i],
 					       &fs_ns->node,
 					       init_node, i);
 		if (err)
@@ -1553,7 +1558,7 @@ static int init_root_tree(struct mlx5_core_dev *dev,
 	return 0;
 }
 
-static struct mlx5_flow_root_namespace *create_root_ns(struct mlx5_core_dev *dev,
+static struct mlx5_flow_root_namespace *create_root_ns(struct mlx5_flow_steering *steering,
 						       enum fs_flow_table_type
 						       table_type)
 {
@@ -1565,7 +1570,7 @@ static struct mlx5_flow_root_namespace *create_root_ns(struct mlx5_core_dev *dev
 	if (!root_ns)
 		return NULL;
 
-	root_ns->dev = dev;
+	root_ns->dev = steering->dev;
 	root_ns->table_type = table_type;
 
 	ns = &root_ns->ns;
@@ -1620,46 +1625,45 @@ static void set_prio_attrs(struct mlx5_flow_root_namespace *root_ns)
 #define ANCHOR_PRIO 0
 #define ANCHOR_SIZE 1
 #define ANCHOR_LEVEL 0
-static int create_anchor_flow_table(struct mlx5_core_dev
-							*dev)
+static int create_anchor_flow_table(struct mlx5_flow_steering *steering)
 {
 	struct mlx5_flow_namespace *ns = NULL;
 	struct mlx5_flow_table *ft;
 
-	ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_ANCHOR);
+	ns = mlx5_get_flow_namespace(steering->dev, MLX5_FLOW_NAMESPACE_ANCHOR);
 	if (!ns)
 		return -EINVAL;
 	ft = mlx5_create_flow_table(ns, ANCHOR_PRIO, ANCHOR_SIZE, ANCHOR_LEVEL);
 	if (IS_ERR(ft)) {
-		mlx5_core_err(dev, "Failed to create last anchor flow table");
+		mlx5_core_err(steering->dev, "Failed to create last anchor flow table");
 		return PTR_ERR(ft);
 	}
 	return 0;
 }
 
-static int init_root_ns(struct mlx5_core_dev *dev)
+static int init_root_ns(struct mlx5_flow_steering *steering)
 {
 
-	dev->priv.root_ns = create_root_ns(dev, FS_FT_NIC_RX);
-	if (IS_ERR_OR_NULL(dev->priv.root_ns))
+	steering->root_ns = create_root_ns(steering, FS_FT_NIC_RX);
+	if (IS_ERR_OR_NULL(steering->root_ns))
 		goto cleanup;
 
-	if (init_root_tree(dev, &root_fs, &dev->priv.root_ns->ns.node))
+	if (init_root_tree(steering, &root_fs, &steering->root_ns->ns.node))
 		goto cleanup;
 
-	set_prio_attrs(dev->priv.root_ns);
+	set_prio_attrs(steering->root_ns);
 
-	if (create_anchor_flow_table(dev))
+	if (create_anchor_flow_table(steering))
 		goto cleanup;
 
 	return 0;
 
 cleanup:
-	mlx5_cleanup_fs(dev);
+	mlx5_cleanup_fs(steering->dev);
 	return -ENOMEM;
 }
 
-static void cleanup_single_prio_root_ns(struct mlx5_core_dev *dev,
+static void cleanup_single_prio_root_ns(struct mlx5_flow_steering *steering,
 					struct mlx5_flow_root_namespace *root_ns)
 {
 	struct fs_node *prio;
@@ -1672,11 +1676,11 @@ static void cleanup_single_prio_root_ns(struct mlx5_core_dev *dev,
 					struct fs_node,
 				 list);
 		if (tree_remove_node(prio))
-			mlx5_core_warn(dev,
+			mlx5_core_warn(steering->dev,
 				       "Flow steering priority wasn't destroyed, refcount > 1\n");
 	}
 	if (tree_remove_node(&root_ns->ns.node))
-		mlx5_core_warn(dev,
+		mlx5_core_warn(steering->dev,
 			       "Flow steering namespace wasn't destroyed, refcount > 1\n");
 	root_ns = NULL;
 }
@@ -1690,12 +1694,12 @@ static void destroy_flow_tables(struct fs_prio *prio)
 		mlx5_destroy_flow_table(iter);
 }
 
-static void cleanup_root_ns(struct mlx5_core_dev *dev)
+static void cleanup_root_ns(struct mlx5_flow_steering *steering)
 {
-	struct mlx5_flow_root_namespace *root_ns = dev->priv.root_ns;
+	struct mlx5_flow_root_namespace *root_ns = steering->root_ns;
 	struct fs_prio *iter_prio;
 
-	if (!MLX5_CAP_GEN(dev, nic_flow_table))
+	if (!MLX5_CAP_GEN(steering->dev, nic_flow_table))
 		return;
 
 	if (!root_ns)
@@ -1720,7 +1724,7 @@ static void cleanup_root_ns(struct mlx5_core_dev *dev)
 				fs_get_obj(obj_iter_prio2, iter_prio2);
 				destroy_flow_tables(obj_iter_prio2);
 				if (tree_remove_node(iter_prio2)) {
-					mlx5_core_warn(dev,
+					mlx5_core_warn(steering->dev,
 						       "Priority %d wasn't destroyed, refcount > 1\n",
 						       obj_iter_prio2->prio);
 					return;
@@ -1737,7 +1741,7 @@ static void cleanup_root_ns(struct mlx5_core_dev *dev)
 						 struct fs_node,
 						 list);
 			if (tree_remove_node(iter_ns)) {
-				mlx5_core_warn(dev,
+				mlx5_core_warn(steering->dev,
 					       "Namespace wasn't destroyed, refcount > 1\n");
 				return;
 			}
@@ -1754,7 +1758,7 @@ static void cleanup_root_ns(struct mlx5_core_dev *dev)
 
 		fs_get_obj(obj_prio_node, prio_node);
 		if (tree_remove_node(prio_node)) {
-			mlx5_core_warn(dev,
+			mlx5_core_warn(steering->dev,
 				       "Priority %d wasn't destroyed, refcount > 1\n",
 				       obj_prio_node->prio);
 			return;
@@ -1762,70 +1766,75 @@ static void cleanup_root_ns(struct mlx5_core_dev *dev)
 	}
 
 	if (tree_remove_node(&root_ns->ns.node)) {
-		mlx5_core_warn(dev,
+		mlx5_core_warn(steering->dev,
 			       "root namespace wasn't destroyed, refcount > 1\n");
 		return;
 	}
 
-	dev->priv.root_ns = NULL;
+	steering->root_ns = NULL;
 }
 
 void mlx5_cleanup_fs(struct mlx5_core_dev *dev)
 {
+	struct mlx5_flow_steering *steering = dev->priv.steering;
+
 	if (MLX5_CAP_GEN(dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
 		return;
 
-	cleanup_root_ns(dev);
-	cleanup_single_prio_root_ns(dev, dev->priv.fdb_root_ns);
-	cleanup_single_prio_root_ns(dev, dev->priv.esw_egress_root_ns);
-	cleanup_single_prio_root_ns(dev, dev->priv.esw_ingress_root_ns);
+	cleanup_root_ns(steering);
+	cleanup_single_prio_root_ns(steering, steering->esw_egress_root_ns);
+	cleanup_single_prio_root_ns(steering, steering->esw_ingress_root_ns);
+	cleanup_single_prio_root_ns(steering, steering->fdb_root_ns);
 	mlx5_cleanup_fc_stats(dev);
+	kfree(steering);
 }
 
-static int init_fdb_root_ns(struct mlx5_core_dev *dev)
+static int init_fdb_root_ns(struct mlx5_flow_steering *steering)
 {
 	struct fs_prio *prio;
 
-	dev->priv.fdb_root_ns = create_root_ns(dev, FS_FT_FDB);
-	if (!dev->priv.fdb_root_ns)
+	steering->fdb_root_ns = create_root_ns(steering, FS_FT_FDB);
+	if (!steering->fdb_root_ns)
 		return -ENOMEM;
 
 	/* Create single prio */
-	prio = fs_create_prio(&dev->priv.fdb_root_ns->ns, 0, 1);
+	prio = fs_create_prio(&steering->fdb_root_ns->ns, 0, 1);
 	if (IS_ERR(prio)) {
-		cleanup_single_prio_root_ns(dev, dev->priv.fdb_root_ns);
+		cleanup_single_prio_root_ns(steering, steering->fdb_root_ns);
 		return PTR_ERR(prio);
 	} else {
 		return 0;
 	}
 }
 
-static int init_egress_acl_root_ns(struct mlx5_core_dev *dev)
+static int init_ingress_acl_root_ns(struct mlx5_flow_steering *steering)
 {
 	struct fs_prio *prio;
 
-	dev->priv.esw_egress_root_ns = create_root_ns(dev, FS_FT_ESW_EGRESS_ACL);
-	if (!dev->priv.esw_egress_root_ns)
+	steering->esw_egress_root_ns = create_root_ns(steering, FS_FT_ESW_EGRESS_ACL);
+	if (!steering->esw_egress_root_ns)
 		return -ENOMEM;
 
 	/* create 1 prio*/
-	prio = fs_create_prio(&dev->priv.esw_egress_root_ns->ns, 0, MLX5_TOTAL_VPORTS(dev));
+	prio = fs_create_prio(&steering->esw_egress_root_ns->ns, 0,
+			      MLX5_TOTAL_VPORTS(steering->dev));
 	if (IS_ERR(prio))
 		return PTR_ERR(prio);
 	else
 		return 0;
 }
 
-static int init_ingress_acl_root_ns(struct mlx5_core_dev *dev)
+static int init_egress_acl_root_ns(struct mlx5_flow_steering *steering)
 {
 	struct fs_prio *prio;
 
-	dev->priv.esw_ingress_root_ns = create_root_ns(dev, FS_FT_ESW_INGRESS_ACL);
-	if (!dev->priv.esw_ingress_root_ns)
+	steering->esw_ingress_root_ns = create_root_ns(steering, FS_FT_ESW_INGRESS_ACL);
+	if (!steering->esw_ingress_root_ns)
 		return -ENOMEM;
 
 	/* create 1 prio*/
-	prio = fs_create_prio(&dev->priv.esw_ingress_root_ns->ns, 0, MLX5_TOTAL_VPORTS(dev));
+	prio = fs_create_prio(&steering->esw_ingress_root_ns->ns, 0,
+			      MLX5_TOTAL_VPORTS(steering->dev));
 	if (IS_ERR(prio))
 		return PTR_ERR(prio);
 	else
@@ -1834,6 +1843,7 @@ static int init_ingress_acl_root_ns(struct mlx5_core_dev *dev)
 
 int mlx5_init_fs(struct mlx5_core_dev *dev)
 {
+	struct mlx5_flow_steering *steering;
 	int err = 0;
 
 	if (MLX5_CAP_GEN(dev, port_type) != MLX5_CAP_PORT_TYPE_ETH)
@@ -1843,26 +1853,32 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 	if (err)
 		return err;
 
+	steering = kzalloc(sizeof(*steering), GFP_KERNEL);
+	if (!steering)
+		return -ENOMEM;
+	steering->dev = dev;
+	dev->priv.steering = steering;
+
 	if (MLX5_CAP_GEN(dev, nic_flow_table) &&
 	    MLX5_CAP_FLOWTABLE_NIC_RX(dev, ft_support)) {
-		err = init_root_ns(dev);
+		err = init_root_ns(steering);
 		if (err)
 			goto err;
 	}
 
 	if (MLX5_CAP_GEN(dev, eswitch_flow_table)) {
 		if (MLX5_CAP_ESW_FLOWTABLE_FDB(dev, ft_support)) {
-			err = init_fdb_root_ns(dev);
+			err = init_fdb_root_ns(steering);
 			if (err)
 				goto err;
 		}
 		if (MLX5_CAP_ESW_EGRESS_ACL(dev, ft_support)) {
-			err = init_egress_acl_root_ns(dev);
+			err = init_egress_acl_root_ns(steering);
 			if (err)
 				goto err;
 		}
 		if (MLX5_CAP_ESW_INGRESS_ACL(dev, ft_support)) {
-			err = init_ingress_acl_root_ns(dev);
+			err = init_ingress_acl_root_ns(steering);
 			if (err)
 				goto err;
 		}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index aa41a73..d7ba91a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -55,6 +55,14 @@ enum fs_fte_status {
 	FS_FTE_STATUS_EXISTING = 1UL << 0,
 };
 
+struct mlx5_flow_steering {
+	struct mlx5_core_dev *dev;
+	struct mlx5_flow_root_namespace *root_ns;
+	struct mlx5_flow_root_namespace *fdb_root_ns;
+	struct mlx5_flow_root_namespace *esw_egress_root_ns;
+	struct mlx5_flow_root_namespace *esw_ingress_root_ns;
+};
+
 struct fs_node {
 	struct list_head	list;
 	struct list_head	children;
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index e22b345..f21c459 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -550,14 +550,10 @@ struct mlx5_priv {
 	struct list_head        ctx_list;
 	spinlock_t              ctx_lock;
 
+	struct mlx5_flow_steering *steering;
 	struct mlx5_eswitch     *eswitch;
 	struct mlx5_core_sriov	sriov;
 	unsigned long		pci_dev_data;
-	struct mlx5_flow_root_namespace *root_ns;
-	struct mlx5_flow_root_namespace *fdb_root_ns;
-	struct mlx5_flow_root_namespace *esw_egress_root_ns;
-	struct mlx5_flow_root_namespace *esw_ingress_root_ns;
-
 	struct mlx5_fc_stats		fc_stats;
 	struct mlx5_rl_table            rl_table;
 };
-- 
2.8.0
