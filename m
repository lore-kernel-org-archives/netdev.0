From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 5/8] net/mlx5: Don't store reserved part in FTEs and FGs
Date: Thu, 24 Aug 2017 16:21:49 +0300
Message-ID: <20170824132152.29538-6-saeedm@mellanox.com>
References: <20170824132152.29538-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34103 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751061AbdHXNV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 09:21:58 -0400
In-Reply-To: <20170824132152.29538-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

The current code stores fte_match_param in the software representation
of FTEs and FGs. fte_match_param contains a large reserved area at the
bottom of the struct. Since downstream patches are going to hash this
part, we would like to avoid doing so on a reserved part.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c |  8 --------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h | 16 ++++++++++++++--
 include/linux/mlx5/device.h                       |  2 +-
 4 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index 16b32f31d691..e0d0efd903bc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -263,7 +263,7 @@ static int mlx5_cmd_set_fte(struct mlx5_core_dev *dev,
 	MLX5_SET(flow_context, in_flow_context, modify_header_id, fte->modify_id);
 	in_match_value = MLX5_ADDR_OF(flow_context, in_flow_context,
 				      match_value);
-	memcpy(in_match_value, &fte->val, MLX5_ST_SZ_BYTES(fte_match_param));
+	memcpy(in_match_value, &fte->val, sizeof(fte->val));
 
 	in_dests = MLX5_ADDR_OF(flow_context, in_flow_context, destination);
 	if (fte->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index af245fcdba70..986c5e50e872 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -371,21 +371,14 @@ static void del_rule(struct fs_node *node)
 	struct mlx5_flow_table *ft;
 	struct mlx5_flow_group *fg;
 	struct fs_fte *fte;
-	u32	*match_value;
 	int modify_mask;
 	struct mlx5_core_dev *dev = get_dev(node);
-	int match_len = MLX5_ST_SZ_BYTES(fte_match_param);
 	int err;
 	bool update_fte = false;
 
-	match_value = kvzalloc(match_len, GFP_KERNEL);
-	if (!match_value)
-		return;
-
 	fs_get_obj(rule, node);
 	fs_get_obj(fte, rule->node.parent);
 	fs_get_obj(fg, fte->node.parent);
-	memcpy(match_value, fte->val, sizeof(fte->val));
 	fs_get_obj(ft, fg->node.parent);
 	list_del(&rule->node.list);
 	if (rule->sw_action == MLX5_FLOW_CONTEXT_ACTION_FWD_NEXT_PRIO) {
@@ -415,7 +408,6 @@ static void del_rule(struct fs_node *node)
 				       "%s can't del rule fg id=%d fte_index=%d\n",
 				       __func__, fg->id, fte->index);
 	}
-	kvfree(match_value);
 }
 
 static void del_fte(struct fs_node *node)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 5fbae885558f..bfbc081d17dc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -144,10 +144,22 @@ struct mlx5_fc {
 	struct mlx5_fc_cache cache ____cacheline_aligned_in_smp;
 };
 
+#define MLX5_FTE_MATCH_PARAM_RESERVED	reserved_at_600
+/* Calculate the fte_match_param length and without the reserved length.
+ * Make sure the reserved field is the last.
+ */
+#define MLX5_ST_SZ_DW_MATCH_PARAM					    \
+	((MLX5_BYTE_OFF(fte_match_param, MLX5_FTE_MATCH_PARAM_RESERVED) / sizeof(u32)) + \
+	 BUILD_BUG_ON_ZERO(MLX5_ST_SZ_BYTES(fte_match_param) !=		     \
+			   MLX5_FLD_SZ_BYTES(fte_match_param,		     \
+					     MLX5_FTE_MATCH_PARAM_RESERVED) +\
+			   MLX5_BYTE_OFF(fte_match_param,		     \
+					 MLX5_FTE_MATCH_PARAM_RESERVED)))
+
 /* Type of children is mlx5_flow_rule */
 struct fs_fte {
 	struct fs_node			node;
-	u32				val[MLX5_ST_SZ_DW(fte_match_param)];
+	u32				val[MLX5_ST_SZ_DW_MATCH_PARAM];
 	u32				dests_size;
 	u32				flow_tag;
 	u32				index;
@@ -175,7 +187,7 @@ struct mlx5_flow_namespace {
 
 struct mlx5_flow_group_mask {
 	u8	match_criteria_enable;
-	u32	match_criteria[MLX5_ST_SZ_DW(fte_match_param)];
+	u32	match_criteria[MLX5_ST_SZ_DW_MATCH_PARAM];
 };
 
 /* Type of children is fs_fte */
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index f31a0b5377e1..3c7442b56460 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -48,7 +48,7 @@
 /* helper macros */
 #define __mlx5_nullp(typ) ((struct mlx5_ifc_##typ##_bits *)0)
 #define __mlx5_bit_sz(typ, fld) sizeof(__mlx5_nullp(typ)->fld)
-#define __mlx5_bit_off(typ, fld) ((unsigned)(unsigned long)(&(__mlx5_nullp(typ)->fld)))
+#define __mlx5_bit_off(typ, fld) (offsetof(struct mlx5_ifc_##typ##_bits, fld))
 #define __mlx5_dw_off(typ, fld) (__mlx5_bit_off(typ, fld) / 32)
 #define __mlx5_64_off(typ, fld) (__mlx5_bit_off(typ, fld) / 64)
 #define __mlx5_dw_bit_off(typ, fld) (32 - __mlx5_bit_sz(typ, fld) - (__mlx5_bit_off(typ, fld) & 0x1f))
-- 
2.13.0
