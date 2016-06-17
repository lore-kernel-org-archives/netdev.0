From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 06/18] net/mlx5: Introduce table of function pointer steering commands
Date: Fri, 17 Jun 2016 17:43:47 +0300
Message-ID: <1466174639-14576-7-git-send-email-saeedm@mellanox.com>
References: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Doug Ledford <dledford@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Huy Nguyen <huyn@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57422 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932130AbcFQOrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2016 10:47:23 -0400
In-Reply-To: <1466174639-14576-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

The hardware automatically steers RoCE packets.
Thus, these rules aren't added through the flow steering
infrastructure. However, we want to make the flow steering software
tree describes the various flows of every packet.

In order to do that we add table of function pointer steering
commands. This will be later used by the virtual RoCE namespace.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  | 79 ++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h  | 70 ++++++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 73 ++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  1 +
 4 files changed, 125 insertions(+), 98 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index a5bb6b6..c3eecff 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -38,8 +38,8 @@
 #include "fs_cmd.h"
 #include "mlx5_core.h"
 
-int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
-			    struct mlx5_flow_table *ft)
+static int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
+				   struct mlx5_flow_table *ft)
 {
 	u32 in[MLX5_ST_SZ_DW(set_flow_table_root_in)];
 	u32 out[MLX5_ST_SZ_DW(set_flow_table_root_out)];
@@ -60,11 +60,11 @@ int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
 					  sizeof(out));
 }
 
-int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
-			       u16 vport,
-			       enum fs_flow_table_type type, unsigned int level,
-			       unsigned int log_size, struct mlx5_flow_table
-			       *next_ft, unsigned int *table_id)
+static int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
+				      u16 vport,
+				      enum fs_flow_table_type type, unsigned int level,
+				      unsigned int log_size, struct mlx5_flow_table
+				      *next_ft, unsigned int *table_id)
 {
 	u32 out[MLX5_ST_SZ_DW(create_flow_table_out)];
 	u32 in[MLX5_ST_SZ_DW(create_flow_table_in)];
@@ -97,8 +97,8 @@ int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
 	return err;
 }
 
-int mlx5_cmd_destroy_flow_table(struct mlx5_core_dev *dev,
-				struct mlx5_flow_table *ft)
+static int mlx5_cmd_destroy_flow_table(struct mlx5_core_dev *dev,
+				       struct mlx5_flow_table *ft)
 {
 	u32 in[MLX5_ST_SZ_DW(destroy_flow_table_in)];
 	u32 out[MLX5_ST_SZ_DW(destroy_flow_table_out)];
@@ -119,9 +119,9 @@ int mlx5_cmd_destroy_flow_table(struct mlx5_core_dev *dev,
 					  sizeof(out));
 }
 
-int mlx5_cmd_modify_flow_table(struct mlx5_core_dev *dev,
-			       struct mlx5_flow_table *ft,
-			       struct mlx5_flow_table *next_ft)
+static int mlx5_cmd_modify_flow_table(struct mlx5_core_dev *dev,
+				      struct mlx5_flow_table *ft,
+				      struct mlx5_flow_table *next_ft)
 {
 	u32 in[MLX5_ST_SZ_DW(modify_flow_table_in)];
 	u32 out[MLX5_ST_SZ_DW(modify_flow_table_out)];
@@ -150,10 +150,10 @@ int mlx5_cmd_modify_flow_table(struct mlx5_core_dev *dev,
 					  sizeof(out));
 }
 
-int mlx5_cmd_create_flow_group(struct mlx5_core_dev *dev,
-			       struct mlx5_flow_table *ft,
-			       u32 *in,
-			       unsigned int *group_id)
+static int mlx5_cmd_create_flow_group(struct mlx5_core_dev *dev,
+				      struct mlx5_flow_table *ft,
+				      u32 *in,
+				      unsigned int *group_id)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
 	u32 out[MLX5_ST_SZ_DW(create_flow_group_out)];
@@ -180,9 +180,9 @@ int mlx5_cmd_create_flow_group(struct mlx5_core_dev *dev,
 	return err;
 }
 
-int mlx5_cmd_destroy_flow_group(struct mlx5_core_dev *dev,
-				struct mlx5_flow_table *ft,
-				unsigned int group_id)
+static int mlx5_cmd_destroy_flow_group(struct mlx5_core_dev *dev,
+				       struct mlx5_flow_table *ft,
+				       unsigned int group_id)
 {
 	u32 out[MLX5_ST_SZ_DW(destroy_flow_group_out)];
 	u32 in[MLX5_ST_SZ_DW(destroy_flow_group_in)];
@@ -298,19 +298,19 @@ static int mlx5_cmd_set_fte(struct mlx5_core_dev *dev,
 	return err;
 }
 
-int mlx5_cmd_create_fte(struct mlx5_core_dev *dev,
-			struct mlx5_flow_table *ft,
-			unsigned group_id,
-			struct fs_fte *fte)
+static int mlx5_cmd_create_fte(struct mlx5_core_dev *dev,
+			       struct mlx5_flow_table *ft,
+			       unsigned int group_id,
+			       struct fs_fte *fte)
 {
 	return	mlx5_cmd_set_fte(dev, 0, 0, ft, group_id, fte);
 }
 
-int mlx5_cmd_update_fte(struct mlx5_core_dev *dev,
-			struct mlx5_flow_table *ft,
-			unsigned group_id,
-			int modify_mask,
-			struct fs_fte *fte)
+static int mlx5_cmd_update_fte(struct mlx5_core_dev *dev,
+			       struct mlx5_flow_table *ft,
+			       unsigned int group_id,
+			       int modify_mask,
+			       struct fs_fte *fte)
 {
 	int opmod;
 	int atomic_mod_cap = MLX5_CAP_FLOWTABLE(dev,
@@ -323,9 +323,9 @@ int mlx5_cmd_update_fte(struct mlx5_core_dev *dev,
 	return	mlx5_cmd_set_fte(dev, opmod, modify_mask, ft, group_id, fte);
 }
 
-int mlx5_cmd_delete_fte(struct mlx5_core_dev *dev,
-			struct mlx5_flow_table *ft,
-			unsigned int index)
+static int mlx5_cmd_delete_fte(struct mlx5_core_dev *dev,
+			       struct mlx5_flow_table *ft,
+			       unsigned int index)
 {
 	u32 out[MLX5_ST_SZ_DW(delete_fte_out)];
 	u32 in[MLX5_ST_SZ_DW(delete_fte_in)];
@@ -413,3 +413,20 @@ int mlx5_cmd_fc_query(struct mlx5_core_dev *dev, u16 id,
 
 	return 0;
 }
+
+static const struct steering_cmds steering_cmds = {
+	.update_root_ft		= mlx5_cmd_update_root_ft,
+	.create_flow_table	= mlx5_cmd_create_flow_table,
+	.destroy_flow_table	= mlx5_cmd_destroy_flow_table,
+	.modify_flow_table	= mlx5_cmd_modify_flow_table,
+	.create_flow_group	= mlx5_cmd_create_flow_group,
+	.destroy_flow_group	= mlx5_cmd_destroy_flow_group,
+	.create_fte		= mlx5_cmd_create_fte,
+	.update_fte		= mlx5_cmd_update_fte,
+	.delete_fte		= mlx5_cmd_delete_fte,
+};
+
+const struct steering_cmds *mlx5_get_phys_fs_cmds(void)
+{
+	return &steering_cmds;
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
index fc4f7b8..b3f16ca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
@@ -33,44 +33,40 @@
 #ifndef _MLX5_FS_CMD_
 #define _MLX5_FS_CMD_
 
-int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
-			       u16 vport,
-			       enum fs_flow_table_type type, unsigned int level,
-			       unsigned int log_size, struct mlx5_flow_table
-			       *next_ft, unsigned int *table_id);
+struct steering_cmds {
+	int (*update_root_ft)(struct mlx5_core_dev *dev,
+			      struct mlx5_flow_table *ft);
+	int (*create_flow_table)(struct mlx5_core_dev *dev, u16 vport,
+				 enum fs_flow_table_type type, unsigned int level,
+				 unsigned int log_size, struct mlx5_flow_table
+				 *next_ft, unsigned int *table_id);
+	int (*destroy_flow_table)(struct mlx5_core_dev *dev,
+				  struct mlx5_flow_table *ft);
+	int (*modify_flow_table)(struct mlx5_core_dev *dev,
+				 struct mlx5_flow_table *ft,
+				 struct mlx5_flow_table *next_ft);
+	int (*create_flow_group)(struct mlx5_core_dev *dev,
+				 struct mlx5_flow_table *ft,
+				 u32 *in,
+				 unsigned int *group_id);
+	int (*destroy_flow_group)(struct mlx5_core_dev *dev,
+				  struct mlx5_flow_table *ft,
+				  unsigned int group_id);
+	int (*create_fte)(struct mlx5_core_dev *dev,
+			  struct mlx5_flow_table *ft,
+			  unsigned int group_id,
+			  struct fs_fte *fte);
+	int (*update_fte)(struct mlx5_core_dev *dev,
+			  struct mlx5_flow_table *ft,
+			  unsigned int group_id,
+			  int modify_mask,
+			  struct fs_fte *fte);
+	int (*delete_fte)(struct mlx5_core_dev *dev,
+			  struct mlx5_flow_table *ft,
+			  unsigned int index);
+};
 
-int mlx5_cmd_destroy_flow_table(struct mlx5_core_dev *dev,
-				struct mlx5_flow_table *ft);
-
-int mlx5_cmd_modify_flow_table(struct mlx5_core_dev *dev,
-			       struct mlx5_flow_table *ft,
-			       struct mlx5_flow_table *next_ft);
-
-int mlx5_cmd_create_flow_group(struct mlx5_core_dev *dev,
-			       struct mlx5_flow_table *ft,
-			       u32 *in, unsigned int *group_id);
-
-int mlx5_cmd_destroy_flow_group(struct mlx5_core_dev *dev,
-				struct mlx5_flow_table *ft,
-				unsigned int group_id);
-
-int mlx5_cmd_create_fte(struct mlx5_core_dev *dev,
-			struct mlx5_flow_table *ft,
-			unsigned group_id,
-			struct fs_fte *fte);
-
-int mlx5_cmd_update_fte(struct mlx5_core_dev *dev,
-			struct mlx5_flow_table *ft,
-			unsigned group_id,
-			int modify_mask,
-			struct fs_fte *fte);
-
-int mlx5_cmd_delete_fte(struct mlx5_core_dev *dev,
-			struct mlx5_flow_table *ft,
-			unsigned int index);
-
-int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
-			    struct mlx5_flow_table *ft);
+const struct steering_cmds *mlx5_get_phys_fs_cmds(void);
 
 int mlx5_cmd_fc_alloc(struct mlx5_core_dev *dev, u16 *id);
 int mlx5_cmd_fc_free(struct mlx5_core_dev *dev, u16 id);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 6ef7b99..e762a9c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -346,6 +346,7 @@ static bool compare_match_criteria(u8 match_criteria_enable1,
 
 static void del_flow_table(struct fs_node *node)
 {
+	struct mlx5_flow_root_namespace *root = find_root(node);
 	struct mlx5_flow_table *ft;
 	struct mlx5_core_dev *dev;
 	struct fs_prio *prio;
@@ -354,7 +355,7 @@ static void del_flow_table(struct fs_node *node)
 	fs_get_obj(ft, node);
 	dev = get_dev(&ft->node);
 
-	err = mlx5_cmd_destroy_flow_table(dev, ft);
+	err = root->cmds->destroy_flow_table(dev, ft);
 	if (err)
 		pr_warn("flow steering can't destroy ft\n");
 	fs_get_obj(prio, ft->node.parent);
@@ -363,6 +364,7 @@ static void del_flow_table(struct fs_node *node)
 
 static void del_rule(struct fs_node *node)
 {
+	struct mlx5_flow_root_namespace *root = find_root(node);
 	struct rule_client_data *priv_data;
 	struct rule_client_data *tmp;
 	struct mlx5_flow_rule *rule;
@@ -401,10 +403,8 @@ static void del_rule(struct fs_node *node)
 	if ((fte->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) &&
 	    --fte->dests_size) {
 		modify_mask = BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_DESTINATION_LIST),
-		err = mlx5_cmd_update_fte(dev, ft,
-					  fg->id,
-					  modify_mask,
-					  fte);
+		err = root->cmds->update_fte(dev, ft, fg->id,
+					     modify_mask, fte);
 		if (err)
 			pr_warn("%s can't del rule fg id=%d fte_index=%d\n",
 				__func__, fg->id, fte->index);
@@ -414,6 +414,7 @@ static void del_rule(struct fs_node *node)
 
 static void del_fte(struct fs_node *node)
 {
+	struct mlx5_flow_root_namespace *root = find_root(node);
 	struct mlx5_flow_table *ft;
 	struct mlx5_flow_group *fg;
 	struct mlx5_core_dev *dev;
@@ -425,8 +426,8 @@ static void del_fte(struct fs_node *node)
 	fs_get_obj(ft, fg->node.parent);
 
 	dev = get_dev(&ft->node);
-	err = mlx5_cmd_delete_fte(dev, ft,
-				  fte->index);
+	err = root->cmds->delete_fte(dev, ft,
+				     fte->index);
 	if (err)
 		pr_warn("flow steering can't delete fte in index %d of flow group id %d\n",
 			fte->index, fg->id);
@@ -437,6 +438,7 @@ static void del_fte(struct fs_node *node)
 
 static void del_flow_group(struct fs_node *node)
 {
+	struct mlx5_flow_root_namespace *root = find_root(node);
 	struct mlx5_flow_group *fg;
 	struct mlx5_flow_table *ft;
 	struct mlx5_core_dev *dev;
@@ -445,7 +447,7 @@ static void del_flow_group(struct fs_node *node)
 	fs_get_obj(ft, fg->node.parent);
 	dev = get_dev(&ft->node);
 
-	if (mlx5_cmd_destroy_flow_group(dev, ft, fg->id))
+	if (root->cmds->destroy_flow_group(dev, ft, fg->id))
 		pr_warn("flow steering can't destroy fg %d of ft %d\n",
 			fg->id, ft->id);
 }
@@ -584,15 +586,16 @@ static int connect_fts_in_prio(struct mlx5_core_dev *dev,
 			       struct fs_prio *prio,
 			       struct mlx5_flow_table *ft)
 {
+	struct mlx5_flow_root_namespace *root = find_root(&prio->node);
 	struct mlx5_flow_table *iter;
 	int i = 0;
 	int err;
 
 	fs_for_each_ft(iter, prio) {
 		i++;
-		err = mlx5_cmd_modify_flow_table(dev,
-						 iter,
-						 ft);
+		err = root->cmds->modify_flow_table(dev,
+						    iter,
+						    ft);
 		if (err) {
 			mlx5_core_warn(dev, "Failed to modify flow table %d\n",
 				       iter->id);
@@ -635,7 +638,7 @@ static int update_root_ft_create(struct mlx5_flow_table *ft, struct fs_prio
 	if (ft->level >= min_level)
 		return 0;
 
-	err = mlx5_cmd_update_root_ft(root->dev, ft);
+	err = root->cmds->update_root_ft(root->dev, ft);
 	if (err)
 		mlx5_core_warn(root->dev, "Update root flow table of id=%u failed\n",
 			       ft->id);
@@ -648,6 +651,8 @@ static int update_root_ft_create(struct mlx5_flow_table *ft, struct fs_prio
 int mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
 				 struct mlx5_flow_destination *dest)
 {
+	struct mlx5_flow_root_namespace *root =
+		find_root(&rule->node);
 	struct mlx5_flow_table *ft;
 	struct mlx5_flow_group *fg;
 	struct fs_fte *fte;
@@ -662,10 +667,10 @@ int mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
 	fs_get_obj(ft, fg->node.parent);
 
 	memcpy(&rule->dest_attr, dest, sizeof(*dest));
-	err = mlx5_cmd_update_fte(get_dev(&ft->node),
-				  ft, fg->id,
-				  modify_mask,
-				  fte);
+	err = root->cmds->update_fte(get_dev(&ft->node),
+				     ft, fg->id,
+				     modify_mask,
+				     fte);
 	unlock_ref_node(&fte->node);
 
 	return err;
@@ -783,8 +788,8 @@ static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespa
 	tree_init_node(&ft->node, 1, del_flow_table);
 	log_table_sz = ilog2(ft->max_fte);
 	next_ft = find_next_chained_ft(fs_prio);
-	err = mlx5_cmd_create_flow_table(root->dev, ft->vport, ft->type, ft->level,
-					 log_table_sz, next_ft, &ft->id);
+	err = root->cmds->create_flow_table(root->dev, ft->vport, ft->type, ft->level,
+					    log_table_sz, next_ft, &ft->id);
 	if (err)
 		goto free_ft;
 
@@ -799,7 +804,7 @@ static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespa
 	mutex_unlock(&root->chain_lock);
 	return ft;
 destroy_ft:
-	mlx5_cmd_destroy_flow_table(root->dev, ft);
+	root->cmds->destroy_flow_table(root->dev, ft);
 free_ft:
 	kfree(ft);
 unlock_root:
@@ -850,6 +855,7 @@ static struct mlx5_flow_group *create_flow_group_common(struct mlx5_flow_table *
 							*prev_fg,
 							bool is_auto_fg)
 {
+	struct mlx5_flow_root_namespace *root = find_root(&ft->node);
 	struct mlx5_flow_group *fg;
 	struct mlx5_core_dev *dev = get_dev(&ft->node);
 	int err;
@@ -861,7 +867,7 @@ static struct mlx5_flow_group *create_flow_group_common(struct mlx5_flow_table *
 	if (IS_ERR(fg))
 		return fg;
 
-	err = mlx5_cmd_create_flow_group(dev, ft, fg_in, &fg->id);
+	err = root->cmds->create_flow_group(dev, ft, fg_in, &fg->id);
 	if (err) {
 		kfree(fg);
 		return ERR_PTR(err);
@@ -917,6 +923,7 @@ static struct mlx5_flow_rule *add_rule_fte(struct fs_fte *fte,
 					   struct mlx5_flow_group *fg,
 					   struct mlx5_flow_destination *dest)
 {
+	struct mlx5_flow_root_namespace *root = find_root(&fg->node);
 	struct mlx5_flow_table *ft;
 	struct mlx5_flow_rule *rule;
 	int modify_mask = 0;
@@ -944,11 +951,11 @@ static struct mlx5_flow_rule *add_rule_fte(struct fs_fte *fte,
 	}
 
 	if (fte->dests_size == 1 || !dest)
-		err = mlx5_cmd_create_fte(get_dev(&ft->node),
-					  ft, fg->id, fte);
+		err = root->cmds->create_fte(get_dev(&ft->node),
+					     ft, fg->id, fte);
 	else
-		err = mlx5_cmd_update_fte(get_dev(&ft->node),
-					  ft, fg->id, modify_mask, fte);
+		err = root->cmds->update_fte(get_dev(&ft->node),
+					     ft, fg->id, modify_mask, fte);
 	if (err)
 		goto free_rule;
 
@@ -1390,7 +1397,7 @@ static int update_root_ft_destroy(struct mlx5_flow_table *ft)
 
 	new_root_ft = find_next_ft(ft);
 	if (new_root_ft) {
-		int err = mlx5_cmd_update_root_ft(root->dev, new_root_ft);
+		int err = root->cmds->update_root_ft(root->dev, new_root_ft);
 
 		if (err) {
 			mlx5_core_warn(root->dev, "Update root flow table of id=%u failed\n",
@@ -1662,7 +1669,8 @@ static int init_root_tree(struct mlx5_flow_steering *steering,
 
 static struct mlx5_flow_root_namespace *create_root_ns(struct mlx5_flow_steering *steering,
 						       enum fs_flow_table_type
-						       table_type)
+						       table_type,
+						       const struct steering_cmds *cmds)
 {
 	struct mlx5_flow_root_namespace *root_ns;
 	struct mlx5_flow_namespace *ns;
@@ -1674,6 +1682,7 @@ static struct mlx5_flow_root_namespace *create_root_ns(struct mlx5_flow_steering
 
 	root_ns->dev = steering->dev;
 	root_ns->table_type = table_type;
+	root_ns->cmds = cmds;
 
 	ns = &root_ns->ns;
 	fs_init_namespace(ns);
@@ -1746,7 +1755,8 @@ static int create_anchor_flow_table(struct mlx5_flow_steering *steering)
 static int init_root_ns(struct mlx5_flow_steering *steering)
 {
 
-	steering->root_ns = create_root_ns(steering, FS_FT_NIC_RX);
+	steering->root_ns = create_root_ns(steering, FS_FT_NIC_RX,
+					   mlx5_get_phys_fs_cmds());
 	if (IS_ERR_OR_NULL(steering->root_ns))
 		goto cleanup;
 
@@ -1804,7 +1814,8 @@ static int init_fdb_root_ns(struct mlx5_flow_steering *steering)
 {
 	struct fs_prio *prio;
 
-	steering->fdb_root_ns = create_root_ns(steering, FS_FT_FDB);
+	steering->fdb_root_ns = create_root_ns(steering, FS_FT_FDB,
+					       mlx5_get_phys_fs_cmds());
 	if (!steering->fdb_root_ns)
 		return -ENOMEM;
 
@@ -1823,7 +1834,8 @@ static int init_ingress_acl_root_ns(struct mlx5_flow_steering *steering)
 {
 	struct fs_prio *prio;
 
-	steering->esw_egress_root_ns = create_root_ns(steering, FS_FT_ESW_EGRESS_ACL);
+	steering->esw_egress_root_ns = create_root_ns(steering, FS_FT_ESW_EGRESS_ACL,
+						      mlx5_get_phys_fs_cmds());
 	if (!steering->esw_egress_root_ns)
 		return -ENOMEM;
 
@@ -1840,7 +1852,8 @@ static int init_egress_acl_root_ns(struct mlx5_flow_steering *steering)
 {
 	struct fs_prio *prio;
 
-	steering->esw_ingress_root_ns = create_root_ns(steering, FS_FT_ESW_INGRESS_ACL);
+	steering->esw_ingress_root_ns = create_root_ns(steering, FS_FT_ESW_INGRESS_ACL,
+						       mlx5_get_phys_fs_cmds());
 	if (!steering->esw_ingress_root_ns)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index dc08742..1d963fd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -186,6 +186,7 @@ struct mlx5_flow_root_namespace {
 	struct mlx5_flow_table		*root_ft;
 	/* Should be held when chaining flow tables */
 	struct mutex			chain_lock;
+	const struct steering_cmds	*cmds;
 };
 
 int mlx5_init_fc_stats(struct mlx5_core_dev *dev);
-- 
2.8.0
