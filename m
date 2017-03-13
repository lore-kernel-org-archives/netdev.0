From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 15/25] net/mlx5e: Enhanced flow table creation to support ETH and IB links.
Date: Mon, 13 Mar 2017 20:31:26 +0200
Message-ID: <1489429896-10781-16-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49908 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752385AbdCMScN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:32:13 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


IB link needs the the underlay_qp to support flow-steering, so change
the API of the flow-steering creation for supporting both types in the
same set of functions.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  | 12 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    | 39 ++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  9 ++-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 19 +++++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  8 +++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 67 ++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  1 +
 include/linux/mlx5/fs.h                            | 16 ++++--
 8 files changed, 125 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
index 68419a01db36..ea3032d97b0d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
@@ -325,10 +325,18 @@ static int arfs_create_table(struct mlx5e_priv *priv,
 {
 	struct mlx5e_arfs_tables *arfs = &priv->fs.arfs;
 	struct mlx5e_flow_table *ft = &arfs->arfs_tables[type].ft;
+	struct create_flow_table_param param = {0};
 	int err;
 
-	ft->t = mlx5_create_flow_table(priv->fs.ns, MLX5E_NIC_PRIO,
-				       MLX5E_ARFS_TABLE_SIZE, MLX5E_ARFS_FT_LEVEL, 0);
+	ft->num_groups = 0;
+
+	param.ns = priv->fs.ns;
+	param.prio = MLX5E_NIC_PRIO;
+	param.max_fte = MLX5E_ARFS_TABLE_SIZE;
+	param.level = MLX5E_ARFS_FT_LEVEL;
+	param.flags = 0;
+
+	ft->t = mlx5_create_flow_table(&param);
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
 		ft->t = NULL;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index c6b40003007c..46b48b76e7ca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -779,9 +779,16 @@ static int mlx5e_create_ttc_table(struct mlx5e_priv *priv)
 	struct mlx5e_ttc_table *ttc = &priv->fs.ttc;
 	struct mlx5e_flow_table *ft = &ttc->ft;
 	int err;
+	struct create_flow_table_param param = {0};
 
-	ft->t = mlx5_create_flow_table(priv->fs.ns, MLX5E_NIC_PRIO,
-				       MLX5E_TTC_TABLE_SIZE, MLX5E_TTC_FT_LEVEL, 0);
+	param.ns = priv->fs.ns;
+	param.prio = MLX5E_NIC_PRIO;
+	param.max_fte = MLX5E_TTC_TABLE_SIZE;
+	param.level = MLX5E_TTC_FT_LEVEL;
+	param.flags = 0;
+	param.underlay_qpn = priv->underlay_qpn;
+
+	ft->t = mlx5_create_flow_table(&param);
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
 		ft->t = NULL;
@@ -952,10 +959,16 @@ static int mlx5e_create_l2_table(struct mlx5e_priv *priv)
 	struct mlx5e_l2_table *l2_table = &priv->fs.l2;
 	struct mlx5e_flow_table *ft = &l2_table->ft;
 	int err;
+	struct create_flow_table_param param = {0};
+
+	param.ns = priv->fs.ns;
+	param.prio = MLX5E_NIC_PRIO;
+	param.max_fte = MLX5E_L2_TABLE_SIZE;
+	param.level = MLX5E_L2_FT_LEVEL;
+	param.flags = 0;
 
 	ft->num_groups = 0;
-	ft->t = mlx5_create_flow_table(priv->fs.ns, MLX5E_NIC_PRIO,
-				       MLX5E_L2_TABLE_SIZE, MLX5E_L2_FT_LEVEL, 0);
+	ft->t = mlx5_create_flow_table(&param);
 
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
@@ -1041,11 +1054,18 @@ static int mlx5e_create_vlan_table_groups(struct mlx5e_flow_table *ft)
 static int mlx5e_create_vlan_table(struct mlx5e_priv *priv)
 {
 	struct mlx5e_flow_table *ft = &priv->fs.vlan.ft;
+	struct create_flow_table_param param = {0};
 	int err;
 
 	ft->num_groups = 0;
-	ft->t = mlx5_create_flow_table(priv->fs.ns, MLX5E_NIC_PRIO,
-				       MLX5E_VLAN_TABLE_SIZE, MLX5E_VLAN_FT_LEVEL, 0);
+
+	param.ns = priv->fs.ns;
+	param.prio = MLX5E_NIC_PRIO;
+	param.max_fte = MLX5E_VLAN_TABLE_SIZE;
+	param.level = MLX5E_VLAN_FT_LEVEL;
+	param.flags = 0;
+
+	ft->t = mlx5_create_flow_table(&param);
 
 	if (IS_ERR(ft->t)) {
 		err = PTR_ERR(ft->t);
@@ -1091,13 +1111,6 @@ int mlx5i_create_flow_steering(struct mlx5e_priv *priv)
 	if (!priv->fs.ns)
 		return -EINVAL;
 
-	err = mlx5e_arfs_create_tables(priv);
-	if (err) {
-		netdev_err(priv->netdev, "Failed to create arfs tables, err=%d\n",
-			   err);
-		priv->netdev->hw_features &= ~NETIF_F_NTUPLE;
-	}
-
 	err = mlx5e_create_ttc_table(priv);
 	if (err) {
 		netdev_err(priv->netdev, "Failed to create ttc table, err=%d\n",
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index d0c8bf014453..06dfe755f931 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -340,6 +340,7 @@ static int esw_create_legacy_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	struct mlx5_core_dev *dev = esw->dev;
 	struct mlx5_flow_namespace *root_ns;
 	struct mlx5_flow_table *fdb;
+	struct create_flow_table_param param = {0};
 	struct mlx5_flow_group *g;
 	void *match_criteria;
 	int table_size;
@@ -361,8 +362,14 @@ static int esw_create_legacy_fdb_table(struct mlx5_eswitch *esw, int nvports)
 		return -ENOMEM;
 	memset(flow_group_in, 0, inlen);
 
+	param.ns = root_ns;
+	param.prio = 0;
+	param.level = 0;
+	param.max_fte = table_size;
+	param.flags = 0;
+
 	table_size = BIT(MLX5_CAP_ESW_FLOWTABLE_FDB(dev, log_max_ft_size));
-	fdb = mlx5_create_flow_table(root_ns, 0, table_size, 0, 0);
+	fdb = mlx5_create_flow_table(&param);
 	if (IS_ERR(fdb)) {
 		err = PTR_ERR(fdb);
 		esw_warn(dev, "Failed to create FDB Table err %d\n", err);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 595f7c7383b3..5e929888f0d8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -410,6 +410,7 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
 	struct mlx5_core_dev *dev = esw->dev;
 	struct mlx5_flow_namespace *root_ns;
+	struct create_flow_table_param param = {0};
 	struct mlx5_flow_table *fdb = NULL;
 	struct mlx5_flow_group *g;
 	u32 *flow_group_in;
@@ -447,7 +448,14 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
 	esw->fdb_table.fdb = fdb;
 
 	table_size = nvports + MAX_PF_SQ + 1;
-	fdb = mlx5_create_flow_table(root_ns, FDB_SLOW_PATH, table_size, 0, 0);
+
+	param.ns = root_ns;
+	param.prio = FDB_SLOW_PATH;
+	param.level = 0;
+	param.max_fte = table_size;
+	param.flags = 0;
+
+	fdb = mlx5_create_flow_table(&param);
 	if (IS_ERR(fdb)) {
 		err = PTR_ERR(fdb);
 		esw_warn(dev, "Failed to create slow path FDB Table err %d\n", err);
@@ -531,6 +539,7 @@ static int esw_create_offloads_table(struct mlx5_eswitch *esw)
 	struct mlx5_flow_namespace *ns;
 	struct mlx5_flow_table *ft_offloads;
 	struct mlx5_core_dev *dev = esw->dev;
+	struct create_flow_table_param param = {0};
 	int err = 0;
 
 	ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_OFFLOADS);
@@ -539,7 +548,13 @@ static int esw_create_offloads_table(struct mlx5_eswitch *esw)
 		return -EOPNOTSUPP;
 	}
 
-	ft_offloads = mlx5_create_flow_table(ns, 0, dev->priv.sriov.num_vfs + 2, 0, 0);
+	param.ns = ns;
+	param.prio = 0;
+	param.level = 0;
+	param.max_fte = dev->priv.sriov.num_vfs + 2;
+	param.flags = 0;
+
+	ft_offloads = mlx5_create_flow_table(&param);
 	if (IS_ERR(ft_offloads)) {
 		err = PTR_ERR(ft_offloads);
 		esw_warn(esw->dev, "Failed to create offloads table, err %d\n", err);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index b53fc85a2375..d82721f00f94 100644
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
index dd21fc557281..07e766770c14 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -776,18 +776,16 @@ static void list_add_flow_table(struct mlx5_flow_table *ft,
 	list_add(&ft->node.list, prev);
 }
 
-static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
+static struct mlx5_flow_table *__mlx5_create_flow_table(struct create_flow_table_param *param,
 							enum fs_flow_table_op_mod op_mod,
-							u16 vport, int prio,
-							int max_fte, u32 level,
-							u32 flags)
+							u16 vport)
 {
 	struct mlx5_flow_table *next_ft = NULL;
 	struct mlx5_flow_table *ft;
 	int err;
 	int log_table_sz;
 	struct mlx5_flow_root_namespace *root =
-		find_root(&ns->node);
+		find_root(&param->ns->node);
 	struct fs_prio *fs_prio = NULL;
 
 	if (!root) {
@@ -796,29 +794,31 @@ static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespa
 	}
 
 	mutex_lock(&root->chain_lock);
-	fs_prio = find_prio(ns, prio);
+	fs_prio = find_prio(param->ns, param->prio);
 	if (!fs_prio) {
 		err = -EINVAL;
 		goto unlock_root;
 	}
-	if (level >= fs_prio->num_levels) {
+	if (param->level >= fs_prio->num_levels) {
 		err = -ENOSPC;
 		goto unlock_root;
 	}
 	/* The level is related to the
 	 * priority level range.
 	 */
-	level += fs_prio->start_level;
-	ft = alloc_flow_table(level,
+	param->level += fs_prio->start_level;
+	ft = alloc_flow_table(param->level,
 			      vport,
-			      max_fte ? roundup_pow_of_two(max_fte) : 0,
+			      param->max_fte ? roundup_pow_of_two(param->max_fte) : 0,
 			      root->table_type,
-			      op_mod, flags);
+			      op_mod, param->flags);
 	if (!ft) {
 		err = -ENOMEM;
 		goto unlock_root;
 	}
 
+	ft->underlay_qpn = param->underlay_qpn;
+
 	tree_init_node(&ft->node, 1, del_flow_table);
 	log_table_sz = ft->max_fte ? ilog2(ft->max_fte) : 0;
 	next_ft = find_next_chained_ft(fs_prio);
@@ -847,29 +847,36 @@ static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespa
 	return ERR_PTR(err);
 }
 
-struct mlx5_flow_table *mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
-					       int prio, int max_fte,
-					       u32 level,
-					       u32 flags)
+struct mlx5_flow_table *mlx5_create_flow_table(struct create_flow_table_param *param)
 {
-	return __mlx5_create_flow_table(ns, FS_FT_OP_MOD_NORMAL, 0, prio,
-					max_fte, level, flags);
+	return __mlx5_create_flow_table(param, FS_FT_OP_MOD_NORMAL, 0);
 }
 
 struct mlx5_flow_table *mlx5_create_vport_flow_table(struct mlx5_flow_namespace *ns,
 						     int prio, int max_fte,
 						     u32 level, u16 vport)
 {
-	return __mlx5_create_flow_table(ns, FS_FT_OP_MOD_NORMAL, vport, prio,
-					max_fte, level, 0);
+	struct create_flow_table_param param = {0};
+
+	param.ns = ns;
+	param.prio = prio;
+	param.max_fte = max_fte;
+	param.level = level;
+
+	return __mlx5_create_flow_table(&param, FS_FT_OP_MOD_NORMAL, 0);
 }
 
 struct mlx5_flow_table *mlx5_create_lag_demux_flow_table(
 					       struct mlx5_flow_namespace *ns,
 					       int prio, u32 level)
 {
-	return __mlx5_create_flow_table(ns, FS_FT_OP_MOD_LAG_DEMUX, 0, prio, 0,
-					level, 0);
+	struct create_flow_table_param param = {0};
+
+	param.ns = ns;
+	param.prio = prio;
+	param.level = level;
+
+	return __mlx5_create_flow_table(&param, FS_FT_OP_MOD_LAG_DEMUX, 0);
 }
 EXPORT_SYMBOL(mlx5_create_lag_demux_flow_table);
 
@@ -881,11 +888,18 @@ struct mlx5_flow_table *mlx5_create_auto_grouped_flow_table(struct mlx5_flow_nam
 							    u32 flags)
 {
 	struct mlx5_flow_table *ft;
+	struct create_flow_table_param param = {0};
 
 	if (max_num_groups > num_flow_table_entries)
 		return ERR_PTR(-EINVAL);
 
-	ft = mlx5_create_flow_table(ns, prio, num_flow_table_entries, level, flags);
+	param.ns = ns;
+	param.prio = prio;
+	param.level = level;
+	param.max_fte = num_flow_table_entries;
+	param.flags = flags;
+
+	ft = mlx5_create_flow_table(&param);
 	if (IS_ERR(ft))
 		return ft;
 
@@ -1828,11 +1842,18 @@ static int create_anchor_flow_table(struct mlx5_flow_steering *steering)
 {
 	struct mlx5_flow_namespace *ns = NULL;
 	struct mlx5_flow_table *ft;
+	struct create_flow_table_param param = {0};
 
 	ns = mlx5_get_flow_namespace(steering->dev, MLX5_FLOW_NAMESPACE_ANCHOR);
 	if (WARN_ON(!ns))
 		return -EINVAL;
-	ft = mlx5_create_flow_table(ns, ANCHOR_PRIO, ANCHOR_SIZE, ANCHOR_LEVEL, 0);
+	param.ns = ns;
+	param.prio = ANCHOR_PRIO;
+	param.level = ANCHOR_LEVEL;
+	param.max_fte = ANCHOR_SIZE;
+	param.flags = 0;
+
+	ft = mlx5_create_flow_table(&param);
 	if (IS_ERR(ft)) {
 		mlx5_core_err(steering->dev, "Failed to create last anchor flow table");
 		return PTR_ERR(ft);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 8e668c63f69e..9ec8a2835642 100644
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
index 949b24b6c479..9ed3cfa607d1 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -104,12 +104,18 @@ struct mlx5_flow_table *
 				    u32 level,
 				    u32 flags);
 
+struct create_flow_table_param {
+	struct mlx5_flow_namespace *ns;
+	int prio;
+	int max_fte;
+	u32 level;
+	u32 flags;
+	u32 underlay_qpn;
+};
+
 struct mlx5_flow_table *
-mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
-		       int prio,
-		       int num_flow_table_entries,
-		       u32 level,
-		       u32 flags);
+mlx5_create_flow_table(struct create_flow_table_param *param);
+
 struct mlx5_flow_table *
 mlx5_create_vport_flow_table(struct mlx5_flow_namespace *ns,
 			     int prio,
-- 
1.8.3.1
