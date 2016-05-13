From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 6/8] net/mlx5_core: Introduce flow steering destination of type counter
Date: Fri, 13 May 2016 12:55:40 +0000
Message-ID: <1463144142-13810-7-git-send-email-amir@vadai.me>
References: <1463144142-13810-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41819 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752689AbcEMM6I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 08:58:08 -0400
In-Reply-To: <1463144142-13810-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirva@mellanox.com>

When adding a flow steering rule with a counter, need to supply a
destination of type MLX5_FLOW_DESTINATION_TYPE_COUNTER, with a pointer
to a struct mlx5_fc.
Also, MLX5_FLOW_CONTEXT_ACTION_COUNT bit should be set in the action.

Signed-off-by: Amir Vadai <amirva@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c  | 36 +++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h  |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 52 +++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h | 23 ++++++++++
 include/linux/mlx5/fs.h                           |  2 +
 include/linux/mlx5/mlx5_ifc.h                     |  2 +
 6 files changed, 106 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
index ccb63a0..a5bb6b6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c
@@ -241,17 +241,20 @@ static int mlx5_cmd_set_fte(struct mlx5_core_dev *dev,
 	MLX5_SET(flow_context, in_flow_context, group_id, group_id);
 	MLX5_SET(flow_context, in_flow_context, flow_tag, fte->flow_tag);
 	MLX5_SET(flow_context, in_flow_context, action, fte->action);
-	MLX5_SET(flow_context, in_flow_context, destination_list_size,
-		 fte->dests_size);
 	in_match_value = MLX5_ADDR_OF(flow_context, in_flow_context,
 				      match_value);
 	memcpy(in_match_value, &fte->val, MLX5_ST_SZ_BYTES(fte_match_param));
 
+	in_dests = MLX5_ADDR_OF(flow_context, in_flow_context, destination);
 	if (fte->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
-		in_dests = MLX5_ADDR_OF(flow_context, in_flow_context, destination);
+		int list_size = 0;
+
 		list_for_each_entry(dst, &fte->node.children, node.list) {
 			unsigned int id;
 
+			if (dst->dest_attr.type == MLX5_FLOW_DESTINATION_TYPE_COUNTER)
+				continue;
+
 			MLX5_SET(dest_format_struct, in_dests, destination_type,
 				 dst->dest_attr.type);
 			if (dst->dest_attr.type ==
@@ -262,8 +265,31 @@ static int mlx5_cmd_set_fte(struct mlx5_core_dev *dev,
 			}
 			MLX5_SET(dest_format_struct, in_dests, destination_id, id);
 			in_dests += MLX5_ST_SZ_BYTES(dest_format_struct);
+			list_size++;
+		}
+
+		MLX5_SET(flow_context, in_flow_context, destination_list_size,
+			 list_size);
+	}
+
+	if (fte->action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
+		int list_size = 0;
+
+		list_for_each_entry(dst, &fte->node.children, node.list) {
+			if (dst->dest_attr.type !=
+			    MLX5_FLOW_DESTINATION_TYPE_COUNTER)
+				continue;
+
+			MLX5_SET(flow_counter_list, in_dests, flow_counter_id,
+				 dst->dest_attr.counter->id);
+			in_dests += MLX5_ST_SZ_BYTES(dest_format_struct);
+			list_size++;
 		}
+
+		MLX5_SET(flow_context, in_flow_context, flow_counter_list_size,
+			 list_size);
 	}
+
 	memset(out, 0, sizeof(out));
 	err = mlx5_cmd_exec_check_status(dev, in, inlen, out,
 					 sizeof(out));
@@ -283,18 +309,16 @@ int mlx5_cmd_create_fte(struct mlx5_core_dev *dev,
 int mlx5_cmd_update_fte(struct mlx5_core_dev *dev,
 			struct mlx5_flow_table *ft,
 			unsigned group_id,
+			int modify_mask,
 			struct fs_fte *fte)
 {
 	int opmod;
-	int modify_mask;
 	int atomic_mod_cap = MLX5_CAP_FLOWTABLE(dev,
 						flow_table_properties_nic_receive.
 						flow_modify_en);
 	if (!atomic_mod_cap)
 		return -ENOTSUPP;
 	opmod = 1;
-	modify_mask = 1 <<
-		MLX5_SET_FTE_MODIFY_ENABLE_MASK_DESTINATION_LIST;
 
 	return	mlx5_cmd_set_fte(dev, opmod, modify_mask, ft, group_id, fte);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
index 18c111a..fc4f7b8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h
@@ -62,6 +62,7 @@ int mlx5_cmd_create_fte(struct mlx5_core_dev *dev,
 int mlx5_cmd_update_fte(struct mlx5_core_dev *dev,
 			struct mlx5_flow_table *ft,
 			unsigned group_id,
+			int modify_mask,
 			struct fs_fte *fte);
 
 int mlx5_cmd_delete_fte(struct mlx5_core_dev *dev,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 659a698..9420def 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -344,6 +344,7 @@ static void del_rule(struct fs_node *node)
 	struct mlx5_flow_group *fg;
 	struct fs_fte *fte;
 	u32	*match_value;
+	int modify_mask;
 	struct mlx5_core_dev *dev = get_dev(node);
 	int match_len = MLX5_ST_SZ_BYTES(fte_match_param);
 	int err;
@@ -367,8 +368,11 @@ static void del_rule(struct fs_node *node)
 	}
 	if ((fte->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) &&
 	    --fte->dests_size) {
+		modify_mask = BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_DESTINATION_LIST),
 		err = mlx5_cmd_update_fte(dev, ft,
-					  fg->id, fte);
+					  fg->id,
+					  modify_mask,
+					  fte);
 		if (err)
 			pr_warn("%s can't del rule fg id=%d fte_index=%d\n",
 				__func__, fg->id, fte->index);
@@ -615,6 +619,7 @@ int mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
 	struct mlx5_flow_table *ft;
 	struct mlx5_flow_group *fg;
 	struct fs_fte *fte;
+	int modify_mask = BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_DESTINATION_LIST);
 	int err = 0;
 
 	fs_get_obj(fte, rule->node.parent);
@@ -626,7 +631,9 @@ int mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
 
 	memcpy(&rule->dest_attr, dest, sizeof(*dest));
 	err = mlx5_cmd_update_fte(get_dev(&ft->node),
-				  ft, fg->id, fte);
+				  ft, fg->id,
+				  modify_mask,
+				  fte);
 	unlock_ref_node(&fte->node);
 
 	return err;
@@ -877,6 +884,7 @@ static struct mlx5_flow_rule *add_rule_fte(struct fs_fte *fte,
 {
 	struct mlx5_flow_table *ft;
 	struct mlx5_flow_rule *rule;
+	int modify_mask = 0;
 	int err;
 
 	rule = alloc_rule(dest);
@@ -892,14 +900,20 @@ static struct mlx5_flow_rule *add_rule_fte(struct fs_fte *fte,
 		list_add(&rule->node.list, &fte->node.children);
 	else
 		list_add_tail(&rule->node.list, &fte->node.children);
-	if (dest)
+	if (dest) {
 		fte->dests_size++;
+
+		modify_mask |= dest->type == MLX5_FLOW_DESTINATION_TYPE_COUNTER ?
+			BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_FLOW_COUNTERS) :
+			BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_DESTINATION_LIST);
+	}
+
 	if (fte->dests_size == 1 || !dest)
 		err = mlx5_cmd_create_fte(get_dev(&ft->node),
 					  ft, fg->id, fte);
 	else
 		err = mlx5_cmd_update_fte(get_dev(&ft->node),
-					  ft, fg->id, fte);
+					  ft, fg->id, modify_mask, fte);
 	if (err)
 		goto free_rule;
 
@@ -1092,10 +1106,40 @@ unlock_fg:
 	return rule;
 }
 
+struct mlx5_fc *mlx5_flow_rule_counter(struct mlx5_flow_rule *rule)
+{
+	struct mlx5_flow_rule *dst;
+	struct fs_fte *fte;
+
+	fs_get_obj(fte, rule->node.parent);
+
+	fs_for_each_dst(dst, fte) {
+		if (dst->dest_attr.type == MLX5_FLOW_DESTINATION_TYPE_COUNTER)
+			return dst->dest_attr.counter;
+	}
+
+	return NULL;
+}
+
+static bool counter_is_valid(struct mlx5_fc *counter, u32 action)
+{
+	if (!(action & MLX5_FLOW_CONTEXT_ACTION_COUNT))
+		return !counter;
+
+	if (!counter)
+		return false;
+
+	/* Hardware support counter for a drop action only */
+	return action == (MLX5_FLOW_CONTEXT_ACTION_DROP | MLX5_FLOW_CONTEXT_ACTION_COUNT);
+}
+
 static bool dest_is_valid(struct mlx5_flow_destination *dest,
 			  u32 action,
 			  struct mlx5_flow_table *ft)
 {
+	if (dest && (dest->type == MLX5_FLOW_DESTINATION_TYPE_COUNTER))
+		return counter_is_valid(dest->counter, action);
+
 	if (!(action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST))
 		return true;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 8e76cc5..1989048 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -96,6 +96,28 @@ struct mlx5_flow_table {
 	struct list_head		fwd_rules;
 };
 
+struct mlx5_fc_cache {
+	u64 packets;
+	u64 bytes;
+	u64 lastuse;
+};
+
+struct mlx5_fc {
+	struct list_head list;
+
+	/* last{packets,bytes} members are used when calculating the delta since
+	 * last reading
+	 */
+	u64 lastpackets;
+	u64 lastbytes;
+
+	u16 id;
+	bool deleted;
+	bool aging;
+
+	struct mlx5_fc_cache cache ____cacheline_aligned_in_smp;
+};
+
 /* Type of children is mlx5_flow_rule */
 struct fs_fte {
 	struct fs_node			node;
@@ -105,6 +127,7 @@ struct fs_fte {
 	u32				index;
 	u32				action;
 	enum fs_fte_status		status;
+	struct mlx5_fc			*counter;
 };
 
 /* Type of children is mlx5_flow_table/namespace */
diff --git a/include/linux/mlx5/fs.h b/include/linux/mlx5/fs.h
index 6467569..c8b9ede 100644
--- a/include/linux/mlx5/fs.h
+++ b/include/linux/mlx5/fs.h
@@ -73,6 +73,7 @@ struct mlx5_flow_destination {
 		u32			tir_num;
 		struct mlx5_flow_table	*ft;
 		u32			vport_num;
+		struct mlx5_fc		*counter;
 	};
 };
 
@@ -125,4 +126,5 @@ void mlx5_del_flow_rule(struct mlx5_flow_rule *fr);
 int mlx5_modify_rule_destination(struct mlx5_flow_rule *rule,
 				 struct mlx5_flow_destination *dest);
 
+struct mlx5_fc *mlx5_flow_rule_counter(struct mlx5_flow_rule *rule);
 #endif
diff --git a/include/linux/mlx5/mlx5_ifc.h b/include/linux/mlx5/mlx5_ifc.h
index 614c795..9a05cd7 100644
--- a/include/linux/mlx5/mlx5_ifc.h
+++ b/include/linux/mlx5/mlx5_ifc.h
@@ -936,6 +936,8 @@ enum mlx5_flow_destination_type {
 	MLX5_FLOW_DESTINATION_TYPE_VPORT        = 0x0,
 	MLX5_FLOW_DESTINATION_TYPE_FLOW_TABLE   = 0x1,
 	MLX5_FLOW_DESTINATION_TYPE_TIR          = 0x2,
+
+	MLX5_FLOW_DESTINATION_TYPE_COUNTER      = 0x100,
 };
 
 struct mlx5_ifc_dest_format_struct_bits {
-- 
2.8.0
