From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 05/12] net/mlx5: Add user chosen levels when allocating flow tables
Date: Fri, 29 Apr 2016 01:36:35 +0300
Message-ID: <1461883002-8912-6-git-send-email-saeedm@mellanox.com>
References: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:33166 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751865AbcD1WiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 18:38:21 -0400
In-Reply-To: <1461883002-8912-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Currently, consumers of the flow steering infrastructure can't
choose their own flow table levels and are limited to one
flow table per level. This just waste levels.
Instead, we introduce here the possibility to use multiple
flow tables in a level. The user is free to connect these
flow tables, while following the rule (FTEs in FT of level x
could only point to FTs of level y where y > x).

In addition this patch switch the order of the create/destroy
flow tables of the NIC(vlan and main).

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c                 |    3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c   |   30 ++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   |    3 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |   66 +++++++++++++-------
 include/linux/mlx5/fs.h                           |    6 +-
 6 files changed, 70 insertions(+), 40 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 99eb1c1..3ff663c 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1438,7 +1438,8 @@ static struct mlx5_ib_flow_prio *get_flow_table(struct mlx5_ib_dev *dev,
 	if (!ft) {
 		ft = mlx5_create_auto_grouped_flow_table(ns, priority,
 							 num_entries,
-							 num_groups);
+							 num_groups,
+							 0);
 
 		if (!IS_ERR(ft)) {
 			prio->refcount = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 4df49e6..d61171a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -37,6 +37,11 @@
 #include <linux/mlx5/fs.h>
 #include "en.h"
 
+enum {
+	MLX5E_VLAN_FT_LEVEL = 0,
+	MLX5E_MAIN_FT_LEVEL
+};
+
 #define MLX5_SET_CFG(p, f, v) MLX5_SET(create_flow_group_in, p, f, v)
 
 enum {
@@ -1041,7 +1046,8 @@ static int mlx5e_create_main_flow_table(struct mlx5e_priv *priv)
 	int err;
 
 	ft->num_groups = 0;
-	ft->t = mlx5_create_flow_table(priv->fts.ns, 1, MLX5E_MAIN_TABLE_SIZE);
+	ft->t = mlx5_create_flow_table(priv->fts.ns, 1, MLX5E_MAIN_TABLE_SIZE,
+				       MLX5E_MAIN_FT_LEVEL);
 
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
@@ -1150,7 +1156,8 @@ static int mlx5e_create_vlan_flow_table(struct mlx5e_priv *priv)
 	int err;
 
 	ft->num_groups = 0;
-	ft->t = mlx5_create_flow_table(priv->fts.ns, 1, MLX5E_VLAN_TABLE_SIZE);
+	ft->t = mlx5_create_flow_table(priv->fts.ns, 1, MLX5E_VLAN_TABLE_SIZE,
+				       MLX5E_VLAN_FT_LEVEL);
 
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
@@ -1167,11 +1174,16 @@ static int mlx5e_create_vlan_flow_table(struct mlx5e_priv *priv)
 	if (err)
 		goto err_free_g;
 
+	err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
+	if (err)
+		goto err_destroy_vlan_flow_groups;
+
 	return 0;
 
+err_destroy_vlan_flow_groups:
+	mlx5e_destroy_groups(ft);
 err_free_g:
 	kfree(ft->g);
-
 err_destroy_vlan_flow_table:
 	mlx5_destroy_flow_table(ft->t);
 	ft->t = NULL;
@@ -1194,15 +1206,11 @@ int mlx5e_create_flow_tables(struct mlx5e_priv *priv)
 	if (!priv->fts.ns)
 		return -EINVAL;
 
-	err = mlx5e_create_vlan_flow_table(priv);
-	if (err)
-		return err;
-
 	err = mlx5e_create_main_flow_table(priv);
 	if (err)
-		goto err_destroy_vlan_flow_table;
+		return err;
 
-	err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
+	err = mlx5e_create_vlan_flow_table(priv);
 	if (err)
 		goto err_destroy_main_flow_table;
 
@@ -1210,8 +1218,6 @@ int mlx5e_create_flow_tables(struct mlx5e_priv *priv)
 
 err_destroy_main_flow_table:
 	mlx5e_destroy_main_flow_table(priv);
-err_destroy_vlan_flow_table:
-	mlx5e_destroy_vlan_flow_table(priv);
 
 	return err;
 }
@@ -1219,6 +1225,6 @@ err_destroy_vlan_flow_table:
 void mlx5e_destroy_flow_tables(struct mlx5e_priv *priv)
 {
 	mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
-	mlx5e_destroy_main_flow_table(priv);
 	mlx5e_destroy_vlan_flow_table(priv);
+	mlx5e_destroy_main_flow_table(priv);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index b3de09f..2137387 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -64,7 +64,8 @@ static struct mlx5_flow_rule *mlx5e_tc_add_flow(struct mlx5e_priv *priv,
 		priv->fts.tc.t =
 			mlx5_create_auto_grouped_flow_table(priv->fts.ns, 0,
 							    MLX5E_TC_FLOW_TABLE_NUM_ENTRIES,
-							    MLX5E_TC_FLOW_TABLE_NUM_GROUPS);
+							    MLX5E_TC_FLOW_TABLE_NUM_GROUPS,
+							    0);
 		if (IS_ERR(priv->fts.tc.t)) {
 			netdev_err(priv->netdev,
 				   "Failed to create tc offload table\n");
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index bc3d9f8..ff91bb5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -401,7 +401,7 @@ static int esw_create_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	memset(flow_group_in, 0, inlen);
 
 	table_size = BIT(MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size));
-	fdb = mlx5_create_flow_table(root_ns, 0, table_size);
+	fdb = mlx5_create_flow_table(root_ns, 0, table_size, 0);
 	if (IS_ERR_OR_NULL(fdb)) {
 		err = PTR_ERR(fdb);
 		esw_warn(dev, "Failed to create FDB Table err %d\n", err);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index cfb35c3..ca55d7e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -225,19 +225,6 @@ static struct fs_prio *find_prio(struct mlx5_flow_namespace *ns,
 	return NULL;
 }
 
-static unsigned int find_next_free_level(struct fs_prio *prio)
-{
-	if (!list_empty(&prio->node.children)) {
-		struct mlx5_flow_table *ft;
-
-		ft = list_last_entry(&prio->node.children,
-				     struct mlx5_flow_table,
-				     node.list);
-		return ft->level + 1;
-	}
-	return prio->start_level;
-}
-
 static bool masked_memcmp(void *mask, void *val1, void *val2, size_t size)
 {
 	unsigned int i;
@@ -696,9 +683,23 @@ static int connect_flow_table(struct mlx5_core_dev *dev, struct mlx5_flow_table
 	return err;
 }
 
+static void list_add_flow_table(struct mlx5_flow_table *ft,
+				struct fs_prio *prio)
+{
+	struct list_head *prev = &prio->node.children;
+	struct mlx5_flow_table *iter;
+
+	fs_for_each_ft(iter, prio) {
+		if (iter->level > ft->level)
+			break;
+		prev = &iter->node.list;
+	}
+	list_add(&ft->node.list, prev);
+}
+
 struct mlx5_flow_table *mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
-					       int prio,
-					       int max_fte)
+					       int prio, int max_fte,
+					       u32 level)
 {
 	struct mlx5_flow_table *next_ft = NULL;
 	struct mlx5_flow_table *ft;
@@ -719,12 +720,15 @@ struct mlx5_flow_table *mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
 		err = -EINVAL;
 		goto unlock_root;
 	}
-	if (fs_prio->num_ft == fs_prio->num_levels) {
+	if (level >= fs_prio->num_levels) {
 		err = -ENOSPC;
 		goto unlock_root;
 	}
-
-	ft = alloc_flow_table(find_next_free_level(fs_prio),
+	/* The level is related to the
+	 * priority level range.
+	 */
+	level += fs_prio->start_level;
+	ft = alloc_flow_table(level,
 			      roundup_pow_of_two(max_fte),
 			      root->table_type);
 	if (!ft) {
@@ -745,7 +749,7 @@ struct mlx5_flow_table *mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
 		goto destroy_ft;
 	lock_ref_node(&fs_prio->node);
 	tree_add_node(&ft->node, &fs_prio->node);
-	list_add_tail(&ft->node.list, &fs_prio->node.children);
+	list_add_flow_table(ft, fs_prio);
 	fs_prio->num_ft++;
 	unlock_ref_node(&fs_prio->node);
 	mutex_unlock(&root->chain_lock);
@@ -762,14 +766,15 @@ unlock_root:
 struct mlx5_flow_table *mlx5_create_auto_grouped_flow_table(struct mlx5_flow_namespace *ns,
 							    int prio,
 							    int num_flow_table_entries,
-							    int max_num_groups)
+							    int max_num_groups,
+							    u32 level)
 {
 	struct mlx5_flow_table *ft;
 
 	if (max_num_groups > num_flow_table_entries)
 		return ERR_PTR(-EINVAL);
 
-	ft = mlx5_create_flow_table(ns, prio, num_flow_table_entries);
+	ft = mlx5_create_flow_table(ns, prio, num_flow_table_entries, level);
 	if (IS_ERR(ft))
 		return ft;
 
@@ -1068,6 +1073,20 @@ unlock_fg:
 	return rule;
 }
 
+static bool dest_is_valid(struct mlx5_flow_destination *dest,
+			  u32 action,
+			  struct mlx5_flow_table *ft)
+{
+	if (!(action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST))
+		return true;
+
+	if (!dest || ((dest->type ==
+	    MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE) &&
+	    (dest->ft->level <= ft->level)))
+		return false;
+	return true;
+}
+
 static struct mlx5_flow_rule *
 _mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 		    u8 match_criteria_enable,
@@ -1080,7 +1099,7 @@ _mlx5_add_flow_rule(struct mlx5_flow_table *ft,
 	struct mlx5_flow_group *g;
 	struct mlx5_flow_rule *rule;
 
-	if ((action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) && !dest)
+	if (!dest_is_valid(dest, action, ft))
 		return ERR_PTR(-EINVAL);
 
 	nested_lock_ref_node(&ft->node, FS_MUTEX_GRANDPARENT);
@@ -1517,6 +1536,7 @@ static void set_prio_attrs(struct mlx5_flow_root_namespace *root_ns)
 
 #define ANCHOR_PRIO 0
 #define ANCHOR_SIZE 1
+#define ANCHOR_LEVEL 0
 static int create_anchor_flow_table(struct mlx5_core_dev
 							*dev)
 {
@@ -1526,7 +1546,7 @@ static int create_anchor_flow_table(struct mlx5_core_dev
 	ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_ANCHOR);
 	if (!ns)
 		return -EINVAL;
-	ft = mlx5_create_flow_table(ns, ANCHOR_PRIO, ANCHOR_SIZE);
+	ft = mlx5_create_flow_table(ns, ANCHOR_PRIO, ANCHOR_SIZE, ANCHOR_LEVEL);
 	if (IS_ERR(ft)) {
 		mlx5_core_err(dev, "Failed to create last anchor flow table");
 		return PTR_ERR(ft);
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 28a5b66..165ff4f 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -82,12 +82,14 @@ struct mlx5_flow_table *
 mlx5_create_auto_grouped_flow_table(struct mlx5_flow_namespace *ns,
 				    int prio,
 				    int num_flow_table_entries,
-				    int max_num_groups);
+				    int max_num_groups,
+				    u32 level);
 
 struct mlx5_flow_table *
 mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
 		       int prio,
-		       int num_flow_table_entries);
+		       int num_flow_table_entries,
+		       u32 level);
 int mlx5_destroy_flow_table(struct mlx5_flow_table *ft);
 
 /* inbox should be set with the following values:
-- 
1.7.1
