From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 02/16] net/mlx5: Refactor create flow table method to accept underlay QP
Date: Thu, 13 Apr 2017 06:36:52 +0300
Message-ID: <20170413033706.19016-3-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170413033706.19016-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

IB flow tables need the underlay qp to perform flow steering.
Here we change the API of the flow tables creation to accept the
underlay QP number as a parameter in order to support IB (IPoIB) flow
steering.

Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  | 10 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    | 25 +++++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  5 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 16 +++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  8 +++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 84 +++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  1 +
 include/linux/mlx5/fs.h                            | 14 ++--
 8 files changed, 113 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
index c4e9cc79f5c7..c8a005326e30 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
@@ -321,10 +321,16 @@ static int arfs_create_table(struct mlx5e_priv *priv,
 {
 	struct mlx5e_arfs_tables *arfs = &priv->fs.arfs;
 	struct mlx5e_flow_table *ft = &arfs->arfs_tables[type].ft;
+	struct mlx5_flow_table_attr ft_attr = {};
 	int err;
 
-	ft->t = mlx5_create_flow_table(priv->fs.ns, MLX5E_NIC_PRIO,
-				       MLX5E_ARFS_TABLE_SIZE, MLX5E_ARFS_FT_LEVEL, 0);
+	ft->num_groups = 0;
+
+	ft_attr.max_fte = MLX5E_ARFS_TABLE_SIZE;
+	ft_attr.level = MLX5E_ARFS_FT_LEVEL;
+	ft_attr.prio = MLX5E_NIC_PRIO;
+
+	ft->t = mlx5_create_flow_table(priv->fs.ns, &ft_attr);
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
 		ft->t = NULL;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 5376d69a6b1a..729904c43801 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -803,11 +803,15 @@ static void mlx5e_destroy_ttc_table(struct mlx5e_priv *priv)
 static int mlx5e_create_ttc_table(struct mlx5e_priv *priv)
 {
 	struct mlx5e_ttc_table *ttc = &priv->fs.ttc;
+	struct mlx5_flow_table_attr ft_attr = {};
 	struct mlx5e_flow_table *ft = &ttc->ft;
 	int err;
 
-	ft->t = mlx5_create_flow_table(priv->fs.ns, MLX5E_NIC_PRIO,
-				       MLX5E_TTC_TABLE_SIZE, MLX5E_TTC_FT_LEVEL, 0);
+	ft_attr.max_fte = MLX5E_TTC_TABLE_SIZE;
+	ft_attr.level = MLX5E_TTC_FT_LEVEL;
+	ft_attr.prio = MLX5E_NIC_PRIO;
+
+	ft->t = mlx5_create_flow_table(priv->fs.ns, &ft_attr);
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
 		ft->t = NULL;
@@ -973,12 +977,16 @@ static int mlx5e_create_l2_table(struct mlx5e_priv *priv)
 {
 	struct mlx5e_l2_table *l2_table = &priv->fs.l2;
 	struct mlx5e_flow_table *ft = &l2_table->ft;
+	struct mlx5_flow_table_attr ft_attr = {};
 	int err;
 
 	ft->num_groups = 0;
-	ft->t = mlx5_create_flow_table(priv->fs.ns, MLX5E_NIC_PRIO,
-				       MLX5E_L2_TABLE_SIZE, MLX5E_L2_FT_LEVEL, 0);
 
+	ft_attr.max_fte = MLX5E_L2_TABLE_SIZE;
+	ft_attr.level = MLX5E_L2_FT_LEVEL;
+	ft_attr.prio = MLX5E_NIC_PRIO;
+
+	ft->t = mlx5_create_flow_table(priv->fs.ns, &ft_attr);
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
 		ft->t = NULL;
@@ -1076,11 +1084,16 @@ static int mlx5e_create_vlan_table_groups(struct mlx5e_flow_table *ft)
 static int mlx5e_create_vlan_table(struct mlx5e_priv *priv)
 {
 	struct mlx5e_flow_table *ft = &priv->fs.vlan.ft;
+	struct mlx5_flow_table_attr ft_attr = {};
 	int err;
 
 	ft->num_groups = 0;
-	ft->t = mlx5_create_flow_table(priv->fs.ns, MLX5E_NIC_PRIO,
-				       MLX5E_VLAN_TABLE_SIZE, MLX5E_VLAN_FT_LEVEL, 0);
+
+	ft_attr.max_fte = MLX5E_VLAN_TABLE_SIZE;
+	ft_attr.level = MLX5E_VLAN_FT_LEVEL;
+	ft_attr.prio = MLX5E_NIC_PRIO;
+
+	ft->t = mlx5_create_flow_table(priv->fs.ns, &ft_attr);
 
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index fcd5bc7e31db..b3281d1118b3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -337,6 +337,7 @@ esw_fdb_set_vport_promisc_rule(struct mlx5_eswitch *esw, u32 vport)
 static int esw_create_legacy_fdb_table(struct mlx5_eswitch *esw, int nvports)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
+	struct mlx5_flow_table_attr ft_attr = {};
 	struct mlx5_core_dev *dev = esw->dev;
 	struct mlx5_flow_namespace *root_ns;
 	struct mlx5_flow_table *fdb;
@@ -362,7 +363,9 @@ static int esw_create_legacy_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	memset(flow_group_in, 0, inlen);
 
 	table_size = BIT(MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size));
-	fdb = mlx5_create_flow_table(root_ns, 0, table_size, 0, 0);
+
+	ft_attr.max_fte = table_size;
+	fdb = mlx5_create_flow_table(root_ns, &ft_attr);
 	if (IS_ERR(fdb)) {
 		err = PTR_ERR(fdb);
 		esw_warn(dev, "Failed to create FDB Table err %d\n", err);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index fff962dac8e3..992b380d36be 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -432,6 +432,7 @@ static int esw_add_fdb_miss_rule(struct mlx5_eswitch *esw)
 static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
+	struct mlx5_flow_table_attr ft_attr = {};
 	int table_size, ix, esw_size, err = 0;
 	struct mlx5_core_dev *dev = esw->dev;
 	struct mlx5_flow_namespace *root_ns;
@@ -475,7 +476,11 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	esw->fdb_table.fdb = fdb;
 
 	table_size = nvports + MAX_PF_SQ + 1;
-	fdb = mlx5_create_flow_table(root_ns, FDB_SLOW_PATH, table_size, 0, 0);
+
+	ft_attr.max_fte = table_size;
+	ft_attr.prio = FDB_SLOW_PATH;
+
+	fdb = mlx5_create_flow_table(root_ns, &ft_attr);
 	if (IS_ERR(fdb)) {
 		err = PTR_ERR(fdb);
 		esw_warn(dev, "Failed to create slow path FDB Table err %d\n", err);
@@ -556,9 +561,10 @@ static void esw_destroy_offloads_fdb_table(struct mlx5_eswitch *esw)
 
 static int esw_create_offloads_table(struct mlx5_eswitch *esw)
 {
-	struct mlx5_flow_namespace *ns;
-	struct mlx5_flow_table *ft_offloads;
+	struct mlx5_flow_table_attr ft_attr = {};
 	struct mlx5_core_dev *dev = esw->dev;
+	struct mlx5_flow_table *ft_offloads;
+	struct mlx5_flow_namespace *ns;
 	int err = 0;
 
 	ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_OFFLOADS);
@@ -567,7 +573,9 @@ static int esw_create_offloads_table(struct mlx5_eswitch *esw)
 		return -EOPNOTSUPP;
 	}
 
-	ft_offloads = mlx5_create_flow_table(ns, 0, dev->priv.sriov.num_vfs + 2, 0, 0);
+	ft_attr.max_fte = dev->priv.sriov.num_vfs + 2;
+
+	ft_offloads = mlx5_create_flow_table(ns, &ft_attr);
 	if (IS_ERR(ft_offloads)) {
 		err = PTR_ERR(ft_offloads);
 		esw_warn(esw->dev, "Failed to create offloads table, err %d\n", err);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index c6178ea1a461..19e3d2fc2099 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -45,6 +45,10 @@ int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
 	u32 in[MLX5_ST_SZ_DW(set_flow_table_root_in)]   = {0};
 	u32 out[MLX5_ST_SZ_DW(set_flow_table_root_out)] = {0};
 
+	if ((MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_IB) &&
+	    ft->underlay_qpn == 0)
+		return 0;
+
 	MLX5_SET(set_flow_table_root_in, in, opcode,
 		 MLX5_CMD_OP_SET_FLOW_TABLE_ROOT);
 	MLX5_SET(set_flow_table_root_in, in, table_type, ft->type);
@@ -54,6 +58,10 @@ int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
 		MLX5_SET(set_flow_table_root_in, in, other_vport, 1);
 	}
 
+	if ((MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_IB) &&
+	    ft->underlay_qpn != 0)
+		MLX5_SET(set_flow_table_root_in, in, underlay_qpn, ft->underlay_qpn);
+
 	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 27ff815600f7..55182d0b06e8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -778,18 +778,16 @@ static void list_add_flow_table(struct mlx5_flow_table *ft,
 }
 
 static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
+							struct mlx5_flow_table_attr *ft_attr,
 							enum fs_flow_table_op_mod op_mod,
-							u16 vport, int prio,
-							int max_fte, u32 level,
-							u32 flags)
+							u16 vport)
 {
+	struct mlx5_flow_root_namespace *root = find_root(&ns->node);
 	struct mlx5_flow_table *next_ft = NULL;
+	struct fs_prio *fs_prio = NULL;
 	struct mlx5_flow_table *ft;
-	int err;
 	int log_table_sz;
-	struct mlx5_flow_root_namespace *root =
-		find_root(&ns->node);
-	struct fs_prio *fs_prio = NULL;
+	int err;
 
 	if (!root) {
 		pr_err("mlx5: flow steering failed to find root of namespace\n");
@@ -797,29 +795,31 @@ static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespa
 	}
 
 	mutex_lock(&root->chain_lock);
-	fs_prio = find_prio(ns, prio);
+	fs_prio = find_prio(ns, ft_attr->prio);
 	if (!fs_prio) {
 		err = -EINVAL;
 		goto unlock_root;
 	}
-	if (level >= fs_prio->num_levels) {
+	if (ft_attr->level >= fs_prio->num_levels) {
 		err = -ENOSPC;
 		goto unlock_root;
 	}
 	/* The level is related to the
 	 * priority level range.
 	 */
-	level += fs_prio->start_level;
-	ft = alloc_flow_table(level,
+	ft_attr->level += fs_prio->start_level;
+	ft = alloc_flow_table(ft_attr->level,
 			      vport,
-			      max_fte ? roundup_pow_of_two(max_fte) : 0,
+			      ft_attr->max_fte ? roundup_pow_of_two(ft_attr->max_fte) : 0,
 			      root->table_type,
-			      op_mod, flags);
+			      op_mod, ft_attr->flags);
 	if (!ft) {
 		err = -ENOMEM;
 		goto unlock_root;
 	}
 
+	ft->underlay_qpn = ft_attr->underlay_qpn;
+
 	tree_init_node(&ft->node, 1, del_flow_table);
 	log_table_sz = ft->max_fte ? ilog2(ft->max_fte) : 0;
 	next_ft = find_next_chained_ft(fs_prio);
@@ -849,44 +849,56 @@ static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespa
 }
 
 struct mlx5_flow_table *mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
-					       int prio, int max_fte,
-					       u32 level,
-					       u32 flags)
+					       struct mlx5_flow_table_attr *ft_attr)
 {
-	return __mlx5_create_flow_table(ns, FS_FT_OP_MOD_NORMAL, 0, prio,
-					max_fte, level, flags);
+	return __mlx5_create_flow_table(ns, ft_attr, FS_FT_OP_MOD_NORMAL, 0);
 }
 
 struct mlx5_flow_table *mlx5_create_vport_flow_table(struct mlx5_flow_namespace *ns,
 						     int prio, int max_fte,
 						     u32 level, u16 vport)
 {
-	return __mlx5_create_flow_table(ns, FS_FT_OP_MOD_NORMAL, vport, prio,
-					max_fte, level, 0);
+	struct mlx5_flow_table_attr ft_attr = {};
+
+	ft_attr.max_fte = max_fte;
+	ft_attr.level   = level;
+	ft_attr.prio    = prio;
+
+	return __mlx5_create_flow_table(ns, &ft_attr, FS_FT_OP_MOD_NORMAL, 0);
 }
 
-struct mlx5_flow_table *mlx5_create_lag_demux_flow_table(
-					       struct mlx5_flow_namespace *ns,
-					       int prio, u32 level)
+struct mlx5_flow_table*
+mlx5_create_lag_demux_flow_table(struct mlx5_flow_namespace *ns,
+				 int prio, u32 level)
 {
-	return __mlx5_create_flow_table(ns, FS_FT_OP_MOD_LAG_DEMUX, 0, prio, 0,
-					level, 0);
+	struct mlx5_flow_table_attr ft_attr = {};
+
+	ft_attr.level = level;
+	ft_attr.prio  = prio;
+	return __mlx5_create_flow_table(ns, &ft_attr, FS_FT_OP_MOD_LAG_DEMUX, 0);
 }
 EXPORT_SYMBOL(mlx5_create_lag_demux_flow_table);
 
-struct mlx5_flow_table *mlx5_create_auto_grouped_flow_table(struct mlx5_flow_namespace *ns,
-							    int prio,
-							    int num_flow_table_entries,
-							    int max_num_groups,
-							    u32 level,
-							    u32 flags)
+struct mlx5_flow_table*
+mlx5_create_auto_grouped_flow_table(struct mlx5_flow_namespace *ns,
+				    int prio,
+				    int num_flow_table_entries,
+				    int max_num_groups,
+				    u32 level,
+				    u32 flags)
 {
+	struct mlx5_flow_table_attr ft_attr = {};
 	struct mlx5_flow_table *ft;
 
 	if (max_num_groups > num_flow_table_entries)
 		return ERR_PTR(-EINVAL);
 
-	ft = mlx5_create_flow_table(ns, prio, num_flow_table_entries, level, flags);
+	ft_attr.max_fte = num_flow_table_entries;
+	ft_attr.prio    = prio;
+	ft_attr.level   = level;
+	ft_attr.flags   = flags;
+
+	ft = mlx5_create_flow_table(ns, &ft_attr);
 	if (IS_ERR(ft))
 		return ft;
 
@@ -1828,12 +1840,18 @@ static void set_prio_attrs(struct mlx5_flow_root_namespace *root_ns)
 static int create_anchor_flow_table(struct mlx5_flow_steering *steering)
 {
 	struct mlx5_flow_namespace *ns = NULL;
+	struct mlx5_flow_table_attr ft_attr = {};
 	struct mlx5_flow_table *ft;
 
 	ns = mlx5_get_flow_namespace(steering->dev, MLX5_FLOW_NAMESPACE_ANCHOR);
 	if (WARN_ON(!ns))
 		return -EINVAL;
-	ft = mlx5_create_flow_table(ns, ANCHOR_PRIO, ANCHOR_SIZE, ANCHOR_LEVEL, 0);
+
+	ft_attr.max_fte = ANCHOR_SIZE;
+	ft_attr.level   = ANCHOR_LEVEL;
+	ft_attr.prio    = ANCHOR_PRIO;
+
+	ft = mlx5_create_flow_table(ns, &ft_attr);
 	if (IS_ERR(ft)) {
 		mlx5_core_err(steering->dev, "Failed to create last anchor flow table");
 		return PTR_ERR(ft);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 03af2e7989f3..577d056bf3df 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -118,6 +118,7 @@ struct mlx5_flow_table {
 	/* FWD rules that point on this flow table */
 	struct list_head		fwd_rules;
 	u32				flags;
+	u32				underlay_qpn;
 };
 
 struct mlx5_fc_cache {
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index ae91a4bda1a3..1b166d2e19c5 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -104,12 +104,18 @@ mlx5_create_auto_grouped_flow_table(struct mlx5_flow_namespace *ns,
 				    u32 level,
 				    u32 flags);
 
+struct mlx5_flow_table_attr {
+	int prio;
+	int max_fte;
+	u32 level;
+	u32 flags;
+	u32 underlay_qpn;
+};
+
 struct mlx5_flow_table *
 mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
-		       int prio,
-		       int num_flow_table_entries,
-		       u32 level,
-		       u32 flags);
+		       struct mlx5_flow_table_attr *ft_attr);
+
 struct mlx5_flow_table *
 mlx5_create_vport_flow_table(struct mlx5_flow_namespace *ns,
 			     int prio,
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
