From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 25/30] net/mlx5: LAG demux flow table support
Date: Sat, 20 Aug 2016 23:12:08 +0300
Message-ID: <1471723933-5894-26-git-send-email-saeedm@mellanox.com>
References: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Aviv Heller <avivh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34234 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752227AbcHTUMu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 16:12:50 -0400
In-Reply-To: <1471723933-5894-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviv Heller <avivh@mellanox.com>

Add interfaces to allow the creation and destruction of a
LAG demux flow table.

It is a special flow table used during LAG for redirecting
non user-mode packets from PF0 to PF1 root ft, if a packet was
received on phys port two.

Signed-off-by: Aviv Heller <avivh@mellanox.com>
Reviewed-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  | 56 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h  |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 31 +++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  6 +++
 include/linux/mlx5/fs.h                           |  3 ++
 5 files changed, 75 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index 7aaefa9..7a0415e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -58,6 +58,7 @@ int mlx5_cmd_update_root_ft(struct mlx5_core_dev *dev,
 
 int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
 			       u16 vport,
+			       enum fs_flow_table_op_mod op_mod,
 			       enum fs_flow_table_type type, unsigned int level,
 			       unsigned int log_size, struct mlx5_flow_table
 			       *next_ft, unsigned int *table_id)
@@ -69,10 +70,6 @@ int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
 	MLX5_SET(create_flow_table_in, in, opcode,
 		 MLX5_CMD_OP_CREATE_FLOW_TABLE);
 
-	if (next_ft) {
-		MLX5_SET(create_flow_table_in, in, table_miss_mode, 1);
-		MLX5_SET(create_flow_table_in, in, table_miss_id, next_ft->id);
-	}
 	MLX5_SET(create_flow_table_in, in, table_type, type);
 	MLX5_SET(create_flow_table_in, in, level, level);
 	MLX5_SET(create_flow_table_in, in, log_size, log_size);
@@ -81,6 +78,22 @@ int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
 		MLX5_SET(create_flow_table_in, in, other_vport, 1);
 	}
 
+	switch (op_mod) {
+	case FS_FT_OP_MOD_NORMAL:
+		if (next_ft) {
+			MLX5_SET(create_flow_table_in, in, table_miss_mode, 1);
+			MLX5_SET(create_flow_table_in, in, table_miss_id, next_ft->id);
+		}
+		break;
+
+	case FS_FT_OP_MOD_LAG_DEMUX:
+		MLX5_SET(create_flow_table_in, in, op_mod, 0x1);
+		if (next_ft)
+			MLX5_SET(create_flow_table_in, in, lag_master_next_table_id,
+				 next_ft->id);
+		break;
+	}
+
 	err = mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
 	if (!err)
 		*table_id = MLX5_GET(create_flow_table_out, out,
@@ -117,17 +130,32 @@ int mlx5_cmd_modify_flow_table(struct mlx5_core_dev *dev,
 		 MLX5_CMD_OP_MODIFY_FLOW_TABLE);
 	MLX5_SET(modify_flow_table_in, in, table_type, ft->type);
 	MLX5_SET(modify_flow_table_in, in, table_id, ft->id);
-	if (ft->vport) {
-		MLX5_SET(modify_flow_table_in, in, vport_number, ft->vport);
-		MLX5_SET(modify_flow_table_in, in, other_vport, 1);
-	}
-	MLX5_SET(modify_flow_table_in, in, modify_field_select,
-		 MLX5_MODIFY_FLOW_TABLE_MISS_TABLE_ID);
-	if (next_ft) {
-		MLX5_SET(modify_flow_table_in, in, table_miss_mode, 1);
-		MLX5_SET(modify_flow_table_in, in, table_miss_id, next_ft->id);
+
+	if (ft->op_mod == FS_FT_OP_MOD_LAG_DEMUX) {
+		MLX5_SET(modify_flow_table_in, in, modify_field_select,
+			 MLX5_MODIFY_FLOW_TABLE_LAG_NEXT_TABLE_ID);
+		if (next_ft) {
+			MLX5_SET(modify_flow_table_in, in,
+				 lag_master_next_table_id, next_ft->id);
+		} else {
+			MLX5_SET(modify_flow_table_in, in,
+				 lag_master_next_table_id, 0);
+		}
 	} else {
-		MLX5_SET(modify_flow_table_in, in, table_miss_mode, 0);
+		if (ft->vport) {
+			MLX5_SET(modify_flow_table_in, in, vport_number,
+				 ft->vport);
+			MLX5_SET(modify_flow_table_in, in, other_vport, 1);
+		}
+		MLX5_SET(modify_flow_table_in, in, modify_field_select,
+			 MLX5_MODIFY_FLOW_TABLE_MISS_TABLE_ID);
+		if (next_ft) {
+			MLX5_SET(modify_flow_table_in, in, table_miss_mode, 1);
+			MLX5_SET(modify_flow_table_in, in, table_miss_id,
+				 next_ft->id);
+		} else {
+			MLX5_SET(modify_flow_table_in, in, table_miss_mode, 0);
+		}
 	}
 
 	return mlx5_cmd_exec(dev, in, sizeof(in), out, sizeof(out));
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
index ac52fdf..c5bc468 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
@@ -35,6 +35,7 @@
 
 int mlx5_cmd_create_flow_table(struct mlx5_core_dev *dev,
 			       u16 vport,
+			       enum fs_flow_table_op_mod op_mod,
 			       enum fs_flow_table_type type, unsigned int level,
 			       unsigned int log_size, struct mlx5_flow_table
 			       *next_ft, unsigned int *table_id);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 243efc5..eabd734 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -477,7 +477,8 @@ static struct mlx5_flow_group *alloc_flow_group(u32 *create_fg_in)
 }
 
 static struct mlx5_flow_table *alloc_flow_table(int level, u16 vport, int max_fte,
-						enum fs_flow_table_type table_type)
+						enum fs_flow_table_type table_type,
+						enum fs_flow_table_op_mod op_mod)
 {
 	struct mlx5_flow_table *ft;
 
@@ -487,6 +488,7 @@ static struct mlx5_flow_table *alloc_flow_table(int level, u16 vport, int max_ft
 
 	ft->level = level;
 	ft->node.type = FS_TYPE_FLOW_TABLE;
+	ft->op_mod = op_mod;
 	ft->type = table_type;
 	ft->vport = vport;
 	ft->max_fte = max_fte;
@@ -724,6 +726,7 @@ static void list_add_flow_table(struct mlx5_flow_table *ft,
 }
 
 static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
+							enum fs_flow_table_op_mod op_mod,
 							u16 vport, int prio,
 							int max_fte, u32 level)
 {
@@ -756,18 +759,19 @@ static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespa
 	level += fs_prio->start_level;
 	ft = alloc_flow_table(level,
 			      vport,
-			      roundup_pow_of_two(max_fte),
-			      root->table_type);
+			      max_fte ? roundup_pow_of_two(max_fte) : 0,
+			      root->table_type,
+			      op_mod);
 	if (!ft) {
 		err = -ENOMEM;
 		goto unlock_root;
 	}
 
 	tree_init_node(&ft->node, 1, del_flow_table);
-	log_table_sz = ilog2(ft->max_fte);
+	log_table_sz = ft->max_fte ? ilog2(ft->max_fte) : 0;
 	next_ft = find_next_chained_ft(fs_prio);
-	err = mlx5_cmd_create_flow_table(root->dev, ft->vport, ft->type, ft->level,
-					 log_table_sz, next_ft, &ft->id);
+	err = mlx5_cmd_create_flow_table(root->dev, ft->vport, ft->op_mod, ft->type,
+					 ft->level, log_table_sz, next_ft, &ft->id);
 	if (err)
 		goto free_ft;
 
@@ -794,16 +798,27 @@ struct mlx5_flow_table *mlx5_create_flow_table(struct mlx5_flow_namespace *ns,
 					       int prio, int max_fte,
 					       u32 level)
 {
-	return __mlx5_create_flow_table(ns, 0, prio, max_fte, level);
+	return __mlx5_create_flow_table(ns, FS_FT_OP_MOD_NORMAL, 0, prio,
+					max_fte, level);
 }
 
 struct mlx5_flow_table *mlx5_create_vport_flow_table(struct mlx5_flow_namespace *ns,
 						     int prio, int max_fte,
 						     u32 level, u16 vport)
 {
-	return __mlx5_create_flow_table(ns, vport, prio, max_fte, level);
+	return __mlx5_create_flow_table(ns, FS_FT_OP_MOD_NORMAL, vport, prio,
+					max_fte, level);
 }
 
+struct mlx5_flow_table *mlx5_create_lag_demux_flow_table(
+					       struct mlx5_flow_namespace *ns,
+					       int prio, u32 level)
+{
+	return __mlx5_create_flow_table(ns, FS_FT_OP_MOD_LAG_DEMUX, 0, prio, 0,
+					level);
+}
+EXPORT_SYMBOL(mlx5_create_lag_demux_flow_table);
+
 struct mlx5_flow_table *mlx5_create_auto_grouped_flow_table(struct mlx5_flow_namespace *ns,
 							    int prio,
 							    int num_flow_table_entries,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 9cffb6a..23e46e3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -51,6 +51,11 @@ enum fs_flow_table_type {
 	FS_FT_FDB             = 0X4,
 };
 
+enum fs_flow_table_op_mod {
+	FS_FT_OP_MOD_NORMAL,
+	FS_FT_OP_MOD_LAG_DEMUX,
+};
+
 enum fs_fte_status {
 	FS_FTE_STATUS_EXISTING = 1UL << 0,
 };
@@ -93,6 +98,7 @@ struct mlx5_flow_table {
 	unsigned int			max_fte;
 	unsigned int			level;
 	enum fs_flow_table_type		type;
+	enum fs_flow_table_op_mod	op_mod;
 	struct {
 		bool			active;
 		unsigned int		required_groups;
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index e036d60..7edfe0b 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -106,6 +106,9 @@ mlx5_create_vport_flow_table(struct mlx5_flow_namespace *ns,
 			     int prio,
 			     int num_flow_table_entries,
 			     u32 level, u16 vport);
+struct mlx5_flow_table *mlx5_create_lag_demux_flow_table(
+					       struct mlx5_flow_namespace *ns,
+					       int prio, u32 level);
 int mlx5_destroy_flow_table(struct mlx5_flow_table *ft);
 
 /* inbox should be set with the following values:
-- 
2.7.4
