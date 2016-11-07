From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 09/13] net/mlx5: Add creation flags when adding new flow table
Date: Mon,  7 Nov 2016 15:14:44 +0200
Message-ID: <1478524488-1377-10-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39593 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753297AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

When creating flow tables, allow the caller to specify creation flags.
Currently no flags are used and as such this patch doesn't add any new
functionality.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c                  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  6 ++---
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  2 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  7 +++---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  7 +++++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 28 +++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  1 +
 include/linux/mlx5/fs.h                            | 10 ++++++--
 12 files changed, 45 insertions(+), 26 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 292ae8b..9b16431 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1857,7 +1857,7 @@ static struct mlx5_ib_flow_prio *get_flow_table(struct mlx5_ib_dev *dev,
 		ft = mlx5_create_auto_grouped_flow_table(ns, priority,
 							 num_entries,
 							 num_groups,
-							 0);
+							 0, 0);
 
 		if (!IS_ERR(ft)) {
 			prio->refcount = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
index 8ff22e8..677b238 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
@@ -324,7 +324,7 @@ static int arfs_create_table(struct mlx5e_priv *priv,
 	int err;
 
 	ft->t = mlx5_create_flow_table(priv->fs.ns, MLX5E_NIC_PRIO,
-				       MLX5E_ARFS_TABLE_SIZE, MLX5E_ARFS_FT_LEVEL);
+				       MLX5E_ARFS_TABLE_SIZE, MLX5E_ARFS_FT_LEVEL, 0);
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
 		ft->t = NULL;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index bed544d..9617892 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -777,7 +777,7 @@ static int mlx5e_create_ttc_table(struct mlx5e_priv *priv)
 	int err;
 
 	ft->t = mlx5_create_flow_table(priv->fs.ns, MLX5E_NIC_PRIO,
-				       MLX5E_TTC_TABLE_SIZE, MLX5E_TTC_FT_LEVEL);
+				       MLX5E_TTC_TABLE_SIZE, MLX5E_TTC_FT_LEVEL, 0);
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
 		ft->t = NULL;
@@ -948,7 +948,7 @@ static int mlx5e_create_l2_table(struct mlx5e_priv *priv)
 
 	ft->num_groups = 0;
 	ft->t = mlx5_create_flow_table(priv->fs.ns, MLX5E_NIC_PRIO,
-				       MLX5E_L2_TABLE_SIZE, MLX5E_L2_FT_LEVEL);
+				       MLX5E_L2_TABLE_SIZE, MLX5E_L2_FT_LEVEL, 0);
 
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
@@ -1038,7 +1038,7 @@ static int mlx5e_create_vlan_table(struct mlx5e_priv *priv)
 
 	ft->num_groups = 0;
 	ft->t = mlx5_create_flow_table(priv->fs.ns, MLX5E_NIC_PRIO,
-				       MLX5E_VLAN_TABLE_SIZE, MLX5E_VLAN_FT_LEVEL);
+				       MLX5E_VLAN_TABLE_SIZE, MLX5E_VLAN_FT_LEVEL, 0);
 
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index cf52c06..87bb3db 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -99,7 +99,7 @@ static struct mlx5e_ethtool_table *get_flow_table(struct mlx5e_priv *priv,
 			   MLX5E_ETHTOOL_NUM_ENTRIES);
 	ft = mlx5_create_auto_grouped_flow_table(ns, prio,
 						 table_size,
-						 MLX5E_ETHTOOL_NUM_GROUPS, 0);
+						 MLX5E_ETHTOOL_NUM_GROUPS, 0, 0);
 	if (IS_ERR(ft))
 		return (void *)ft;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 165682e..cdd4303 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -83,7 +83,7 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 							    MLX5E_TC_PRIO,
 							    MLX5E_TC_TABLE_NUM_ENTRIES,
 							    MLX5E_TC_TABLE_NUM_GROUPS,
-							    0);
+							    0, 0);
 		if (IS_ERR(priv->fs.tc.t)) {
 			netdev_err(priv->netdev,
 				   "Failed to create tc offload table\n");
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 9ee002e..27f21ac 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -361,7 +361,7 @@ static int esw_create_legacy_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	memset(flow_group_in, 0, inlen);
 
 	table_size = BIT(MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size));
-	fdb = mlx5_create_flow_table(root_ns, 0, table_size, 0);
+	fdb = mlx5_create_flow_table(root_ns, 0, table_size, 0, 0);
 	if (IS_ERR(fdb)) {
 		err = PTR_ERR(fdb);
 		esw_warn(dev, "Failed to create FDB Table err %d\n", err);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 53d9d6c..b18f951 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -423,7 +423,8 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 
 	fdb = mlx5_create_auto_grouped_flow_table(root_ns, FDB_FAST_PATH,
 						  ESW_OFFLOADS_NUM_ENTRIES,
-						  ESW_OFFLOADS_NUM_GROUPS, 0);
+						  ESW_OFFLOADS_NUM_GROUPS, 0,
+						  0);
 	if (IS_ERR(fdb)) {
 		err = PTR_ERR(fdb);
 		esw_warn(dev, "Failed to create Fast path FDB Table err %d\n", err);
@@ -432,7 +433,7 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	esw->fdb_table.fdb = fdb;
 
 	table_size = nvports + MAX_PF_SQ + 1;
-	fdb = mlx5_create_flow_table(root_ns, FDB_SLOW_PATH, table_size, 0);
+	fdb = mlx5_create_flow_table(root_ns, FDB_SLOW_PATH, table_size, 0, 0);
 	if (IS_ERR(fdb)) {
 		err = PTR_ERR(fdb);
 		esw_warn(dev, "Failed to create slow path FDB Table err %d\n", err);
@@ -524,7 +525,7 @@ static int esw_create_offloads_table(struct mlx5_eswitch *esw)
 		return -ENOMEM;
 	}
 
-	ft_offloads = mlx5_create_flow_table(ns, 0, dev->priv.sriov.num_vfs + 2, 0);
+	ft_offloads = mlx5_create_flow_table(ns, 0, dev->priv.sriov.num_vfs + 2, 0, 0);
 	if (IS_ERR(ft_offloads)) {
 		err = PTR_ERR(ft_offloads);
 		esw_warn(esw->dev, "Failed to create offloads table, err %d\n", err);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index 301cec8..cc97bb2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -37,6 +37,7 @@
 #include "fs_core.h"
 #include "fs_cmd.h"
 #include "mlx5_core.h"
+#include "eswitch.h"
 
 int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
 			    struct mlx5_flow_table *ft)
@@ -61,8 +62,9 @@ int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
 			       enum fs_flow_table_op_mod op_mod,
 			       enum fs_flow_table_type type, unsigned int level,
 			       unsigned int log_size, struct mlx5_flow_table
-			       *next_ft, unsigned int *table_id)
+			       *next_ft, unsigned int *table_id, u32 flags)
 {
+	int en_encap_decap = !!(flags & MLX5_FLOW_TABLE_TUNNEL_EN);
 	u32 out[MLX5_ST_SZ_DW(create_flow_table_out)] = {0};
 	u32 in[MLX5_ST_SZ_DW(create_flow_table_in)]   = {0};
 	int err;
@@ -78,6 +80,9 @@ int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
 		MLX5_SET(create_flow_table_in, in, other_vport, 1);
 	}
 
+	MLX5_SET(create_flow_table_in, in, decap_en, en_encap_decap);
+	MLX5_SET(create_flow_table_in, in, encap_en, en_encap_decap);
+
 	switch (op_mod) {
 	case FS_FT_OP_MOD_NORMAL:
 		if (next_ft) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
index 86bead1..8fad806 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
@@ -38,7 +38,7 @@ int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
 			       enum fs_flow_table_op_mod op_mod,
 			       enum fs_flow_table_type type, unsigned int level,
 			       unsigned int log_size, struct mlx5_flow_table
-			       *next_ft, unsigned int *table_id);
+			       *next_ft, unsigned int *table_id, u32 flags);
 
 int mlx5_cmd_destroy_flow_table(struct mlx5_core_dev *dev,
 				struct mlx5_flow_table *ft);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index e65eabf..4d28c8d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -505,7 +505,8 @@ static struct mlx5_flow_group *alloc_flow_group(u32 *create_fg_in)
 
 static struct mlx5_flow_table *alloc_flow_table(int level, u16 vport, int max_fte,
 						enum fs_flow_table_type table_type,
-						enum fs_flow_table_op_mod op_mod)
+						enum fs_flow_table_op_mod op_mod,
+						u32 flags)
 {
 	struct mlx5_flow_table *ft;
 
@@ -519,6 +520,7 @@ static struct mlx5_flow_table *alloc_flow_table(int level, u16 vport, int max_ft
 	ft->type = table_type;
 	ft->vport = vport;
 	ft->max_fte = max_fte;
+	ft->flags = flags;
 	INIT_LIST_HEAD(&ft->fwd_rules);
 	mutex_init(&ft->lock);
 
@@ -777,7 +779,8 @@ static void list_add_flow_table(struct mlx5_flow_table *ft,
 static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
 							enum fs_flow_table_op_mod op_mod,
 							u16 vport, int prio,
-							int max_fte, u32 level)
+							int max_fte, u32 level,
+							u32 flags)
 {
 	struct mlx5_flow_table *next_ft = NULL;
 	struct mlx5_flow_table *ft;
@@ -810,7 +813,7 @@ static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespa
 			      vport,
 			      max_fte ? roundup_pow_of_two(max_fte) : 0,
 			      root->table_type,
-			      op_mod);
+			      op_mod, flags);
 	if (!ft) {
 		err = -ENOMEM;
 		goto unlock_root;
@@ -820,7 +823,8 @@ static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespa
 	log_table_sz = ft->max_fte ? ilog2(ft->max_fte) : 0;
 	next_ft = find_next_chained_ft(fs_prio);
 	err = mlx5_cmd_create_flow_table(root->dev, ft->vport, ft->op_mod, ft->type,
-					 ft->level, log_table_sz, next_ft, &ft->id);
+					 ft->level, log_table_sz, next_ft, &ft->id,
+					 ft->flags);
 	if (err)
 		goto free_ft;
 
@@ -845,10 +849,11 @@ static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespa
 
 struct mlx5_flow_table *mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
 					       int prio, int max_fte,
-					       u32 level)
+					       u32 level,
+					       u32 flags)
 {
 	return __mlx5_create_flow_table(ns, FS_FT_OP_MOD_NORMAL, 0, prio,
-					max_fte, level);
+					max_fte, level, flags);
 }
 
 struct mlx5_flow_table *mlx5_create_vport_flow_table(struct mlx5_flow_namespace *ns,
@@ -856,7 +861,7 @@ struct mlx5_flow_table *mlx5_create_vport_flow_table(struct mlx5_flow_namespace
 						     u32 level, u16 vport)
 {
 	return __mlx5_create_flow_table(ns, FS_FT_OP_MOD_NORMAL, vport, prio,
-					max_fte, level);
+					max_fte, level, 0);
 }
 
 struct mlx5_flow_table *mlx5_create_lag_demux_flow_table(
@@ -864,7 +869,7 @@ struct mlx5_flow_table *mlx5_create_lag_demux_flow_table(
 					       int prio, u32 level)
 {
 	return __mlx5_create_flow_table(ns, FS_FT_OP_MOD_LAG_DEMUX, 0, prio, 0,
-					level);
+					level, 0);
 }
 EXPORT_SYMBOL(mlx5_create_lag_demux_flow_table);
 
@@ -872,14 +877,15 @@ struct mlx5_flow_table *mlx5_create_auto_grouped_flow_table(struct mlx5_flow_nam
 							    int prio,
 							    int num_flow_table_entries,
 							    int max_num_groups,
-							    u32 level)
+							    u32 level,
+							    u32 flags)
 {
 	struct mlx5_flow_table *ft;
 
 	if (max_num_groups > num_flow_table_entries)
 		return ERR_PTR(-EINVAL);
 
-	ft = mlx5_create_flow_table(ns, prio, num_flow_table_entries, level);
+	ft = mlx5_create_flow_table(ns, prio, num_flow_table_entries, level, flags);
 	if (IS_ERR(ft))
 		return ft;
 
@@ -1822,7 +1828,7 @@ static int create_anchor_flow_table(struct mlx5_flow_steering *steering)
 	ns = mlx5_get_flow_namespace(steering->dev, MLX5_FLOW_NAMESPACE_ANCHOR);
 	if (!ns)
 		return -EINVAL;
-	ft = mlx5_create_flow_table(ns, ANCHOR_PRIO, ANCHOR_SIZE, ANCHOR_LEVEL);
+	ft = mlx5_create_flow_table(ns, ANCHOR_PRIO, ANCHOR_SIZE, ANCHOR_LEVEL, 0);
 	if (IS_ERR(ft)) {
 		mlx5_core_err(steering->dev, "Failed to create last anchor flow table");
 		return PTR_ERR(ft);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index d515088..9f616ed 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -117,6 +117,7 @@ struct mlx5_flow_table {
 	struct mutex			lock;
 	/* FWD rules that point on this flow table */
 	struct list_head		fwd_rules;
+	u32				flags;
 };
 
 struct mlx5_fc_cache {
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 0dcd287..ab1a5fd 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -42,6 +42,10 @@ enum {
 	MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO	= 1 << 16,
 };
 
+enum {
+	MLX5_FLOW_TABLE_TUNNEL_EN = BIT(0),
+};
+
 #define LEFTOVERS_RULE_NUM	 2
 static inline void build_leftovers_ft_param(int *priority,
 					    int *n_ent,
@@ -97,13 +101,15 @@ mlx5_create_auto_grouped_flow_table(struct mlx5_flow_namespace *ns,
 				    int prio,
 				    int num_flow_table_entries,
 				    int max_num_groups,
-				    u32 level);
+				    u32 level,
+				    u32 flags);
 
 struct mlx5_flow_table *
 mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
 		       int prio,
 		       int num_flow_table_entries,
-		       u32 level);
+		       u32 level,
+		       u32 flags);
 struct mlx5_flow_table *
 mlx5_create_vport_flow_table(struct mlx5_flow_namespace *ns,
 			     int prio,
-- 
2.7.4
