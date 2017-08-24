From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 6/8] net/mlx5: Add hash table to search FTEs in a flow-group
Date: Thu, 24 Aug 2017 16:21:50 +0300
Message-ID: <20170824132152.29538-7-saeedm@mellanox.com>
References: <20170824132152.29538-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34102 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751116AbdHXNV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 09:21:58 -0400
In-Reply-To: <20170824132152.29538-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

When adding a flow table entry (fte) to a flow group (fg), we first
need to check whether this fte exist. In such a case we just merge
the destinations (if possible). Currently, this is done by traversing
the fte list available in a fg. This could take a lot of time when
using large flow groups. Speeding this up by using rhashtable, which
is much faster.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Reviewed-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 228 +++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |   3 +
 2 files changed, 160 insertions(+), 71 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 986c5e50e872..d8d45b006996 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -150,6 +150,14 @@ enum fs_i_mutex_lock_class {
 	FS_MUTEX_CHILD
 };
 
+static const struct rhashtable_params rhash_fte = {
+	.key_len = FIELD_SIZEOF(struct fs_fte, val),
+	.key_offset = offsetof(struct fs_fte, val),
+	.head_offset = offsetof(struct fs_fte, hash),
+	.automatic_shrinking = true,
+	.min_size = 1,
+};
+
 static void del_rule(struct fs_node *node);
 static void del_flow_table(struct fs_node *node);
 static void del_flow_group(struct fs_node *node);
@@ -255,63 +263,59 @@ static struct fs_prio *find_prio(struct mlx5_flow_namespace *ns,
 	return NULL;
 }
 
-static bool masked_memcmp(void *mask, void *val1, void *val2, size_t size)
+static bool check_last_reserved(const u32 *match_criteria)
 {
-	unsigned int i;
-
-	for (i = 0; i < size; i++, mask++, val1++, val2++)
-		if ((*((u8 *)val1) & (*(u8 *)mask)) !=
-		    ((*(u8 *)val2) & (*(u8 *)mask)))
-			return false;
+	char *match_criteria_reserved =
+		MLX5_ADDR_OF(fte_match_param, match_criteria, MLX5_FTE_MATCH_PARAM_RESERVED);
 
-	return true;
+	return	!match_criteria_reserved[0] &&
+		!memcmp(match_criteria_reserved, match_criteria_reserved + 1,
+			MLX5_FLD_SZ_BYTES(fte_match_param,
+					  MLX5_FTE_MATCH_PARAM_RESERVED) - 1);
 }
 
-static bool compare_match_value(struct mlx5_flow_group_mask *mask,
-				void *fte_param1, void *fte_param2)
+static bool check_valid_mask(u8 match_criteria_enable, const u32 *match_criteria)
 {
-	if (mask->match_criteria_enable &
-	    1 << MLX5_CREATE_FLOW_GROUP_IN_MATCH_CRITERIA_ENABLE_OUTER_HEADERS) {
-		void *fte_match1 = MLX5_ADDR_OF(fte_match_param,
-						fte_param1, outer_headers);
-		void *fte_match2 = MLX5_ADDR_OF(fte_match_param,
-						fte_param2, outer_headers);
-		void *fte_mask = MLX5_ADDR_OF(fte_match_param,
-					      mask->match_criteria, outer_headers);
+	if (match_criteria_enable & ~(
+		(1 << MLX5_CREATE_FLOW_GROUP_IN_MATCH_CRITERIA_ENABLE_OUTER_HEADERS)   |
+		(1 << MLX5_CREATE_FLOW_GROUP_IN_MATCH_CRITERIA_ENABLE_MISC_PARAMETERS) |
+		(1 << MLX5_CREATE_FLOW_GROUP_IN_MATCH_CRITERIA_ENABLE_INNER_HEADERS)))
+		return false;
 
-		if (!masked_memcmp(fte_mask, fte_match1, fte_match2,
-				   MLX5_ST_SZ_BYTES(fte_match_set_lyr_2_4)))
+	if (!(match_criteria_enable &
+	      1 << MLX5_CREATE_FLOW_GROUP_IN_MATCH_CRITERIA_ENABLE_OUTER_HEADERS)) {
+		char *fg_type_mask = MLX5_ADDR_OF(fte_match_param,
+						  match_criteria, outer_headers);
+
+		if (fg_type_mask[0] ||
+		    memcmp(fg_type_mask, fg_type_mask + 1,
+			   MLX5_ST_SZ_BYTES(fte_match_set_lyr_2_4) - 1))
 			return false;
 	}
 
-	if (mask->match_criteria_enable &
-	    1 << MLX5_CREATE_FLOW_GROUP_IN_MATCH_CRITERIA_ENABLE_MISC_PARAMETERS) {
-		void *fte_match1 = MLX5_ADDR_OF(fte_match_param,
-						fte_param1, misc_parameters);
-		void *fte_match2 = MLX5_ADDR_OF(fte_match_param,
-						fte_param2, misc_parameters);
-		void *fte_mask = MLX5_ADDR_OF(fte_match_param,
-					  mask->match_criteria, misc_parameters);
+	if (!(match_criteria_enable &
+	      1 << MLX5_CREATE_FLOW_GROUP_IN_MATCH_CRITERIA_ENABLE_MISC_PARAMETERS)) {
+		char *fg_type_mask = MLX5_ADDR_OF(fte_match_param,
+						  match_criteria, misc_parameters);
 
-		if (!masked_memcmp(fte_mask, fte_match1, fte_match2,
-				   MLX5_ST_SZ_BYTES(fte_match_set_misc)))
+		if (fg_type_mask[0] ||
+		    memcmp(fg_type_mask, fg_type_mask + 1,
+			   MLX5_ST_SZ_BYTES(fte_match_set_misc) - 1))
 			return false;
 	}
 
-	if (mask->match_criteria_enable &
-	    1 << MLX5_CREATE_FLOW_GROUP_IN_MATCH_CRITERIA_ENABLE_INNER_HEADERS) {
-		void *fte_match1 = MLX5_ADDR_OF(fte_match_param,
-						fte_param1, inner_headers);
-		void *fte_match2 = MLX5_ADDR_OF(fte_match_param,
-						fte_param2, inner_headers);
-		void *fte_mask = MLX5_ADDR_OF(fte_match_param,
-					  mask->match_criteria, inner_headers);
+	if (!(match_criteria_enable &
+	      1 << MLX5_CREATE_FLOW_GROUP_IN_MATCH_CRITERIA_ENABLE_INNER_HEADERS)) {
+		char *fg_type_mask = MLX5_ADDR_OF(fte_match_param,
+						  match_criteria, inner_headers);
 
-		if (!masked_memcmp(fte_mask, fte_match1, fte_match2,
-				   MLX5_ST_SZ_BYTES(fte_match_set_lyr_2_4)))
+		if (fg_type_mask[0] ||
+		    memcmp(fg_type_mask, fg_type_mask + 1,
+			   MLX5_ST_SZ_BYTES(fte_match_set_lyr_2_4) - 1))
 			return false;
 	}
-	return true;
+
+	return check_last_reserved(match_criteria);
 }
 
 static bool compare_match_criteria(u8 match_criteria_enable1,
@@ -410,6 +414,18 @@ static void del_rule(struct fs_node *node)
 	}
 }
 
+static void destroy_fte(struct fs_fte *fte, struct mlx5_flow_group *fg)
+{
+	struct mlx5_flow_table *ft;
+	int ret;
+
+	ret = rhashtable_remove_fast(&fg->ftes_hash, &fte->hash, rhash_fte);
+	WARN_ON(ret);
+	fte->status = 0;
+	fs_get_obj(ft, fg->node.parent);
+	ida_simple_remove(&ft->fte_allocator, fte->index);
+}
+
 static void del_fte(struct fs_node *node)
 {
 	struct mlx5_flow_table *ft;
@@ -430,8 +446,7 @@ static void del_fte(struct fs_node *node)
 			       "flow steering can't delete fte in index %d of flow group id %d\n",
 			       fte->index, fg->id);
 
-	ida_simple_remove(&ft->fte_allocator, fte->index);
-	fte->status = 0;
+	destroy_fte(fte, fg);
 }
 
 static void del_flow_group(struct fs_node *node)
@@ -447,6 +462,7 @@ static void del_flow_group(struct fs_node *node)
 	if (ft->autogroup.active)
 		ft->autogroup.num_groups--;
 
+	rhashtable_destroy(&fg->ftes_hash);
 	if (mlx5_cmd_destroy_flow_group(dev, ft, fg->id))
 		mlx5_core_warn(dev, "flow steering can't destroy fg %d of ft %d\n",
 			       fg->id, ft->id);
@@ -481,10 +497,17 @@ static struct mlx5_flow_group *alloc_flow_group(u32 *create_fg_in)
 	u8 match_criteria_enable = MLX5_GET(create_flow_group_in,
 					    create_fg_in,
 					    match_criteria_enable);
+	int ret;
+
 	fg = kzalloc(sizeof(*fg), GFP_KERNEL);
 	if (!fg)
 		return ERR_PTR(-ENOMEM);
 
+	ret = rhashtable_init(&fg->ftes_hash, &rhash_fte);
+	if (ret) {
+		kfree(fg);
+		return ERR_PTR(ret);
+	}
 	fg->mask.match_criteria_enable = match_criteria_enable;
 	memcpy(&fg->mask.match_criteria, match_criteria,
 	       sizeof(fg->mask.match_criteria));
@@ -920,10 +943,8 @@ static struct mlx5_flow_group *create_flow_group_common(struct mlx5_flow_table *
 		return fg;
 
 	err = mlx5_cmd_create_flow_group(dev, ft, fg_in, &fg->id);
-	if (err) {
-		kfree(fg);
-		return ERR_PTR(err);
-	}
+	if (err)
+		goto err_free_fg;
 
 	if (ft->autogroup.active)
 		ft->autogroup.num_groups++;
@@ -934,13 +955,27 @@ static struct mlx5_flow_group *create_flow_group_common(struct mlx5_flow_table *
 	list_add(&fg->node.list, prev_fg);
 
 	return fg;
+
+err_free_fg:
+	rhashtable_destroy(&fg->ftes_hash);
+	kfree(fg);
+
+	return ERR_PTR(err);
 }
 
 struct mlx5_flow_group *mlx5_create_flow_group(struct mlx5_flow_table *ft,
 					       u32 *fg_in)
 {
+	void *match_criteria = MLX5_ADDR_OF(create_flow_group_in,
+					    fg_in, match_criteria);
+	u8 match_criteria_enable = MLX5_GET(create_flow_group_in,
+					    fg_in,
+					    match_criteria_enable);
 	struct mlx5_flow_group *fg;
 
+	if (!check_valid_mask(match_criteria_enable, match_criteria))
+		return ERR_PTR(-EINVAL);
+
 	if (ft->autogroup.active)
 		return ERR_PTR(-EPERM);
 
@@ -1104,6 +1139,7 @@ static struct fs_fte *create_fte(struct mlx5_flow_group *fg,
 	struct mlx5_flow_table *ft;
 	struct fs_fte *fte;
 	int index;
+	int ret;
 
 	fs_get_obj(ft, fg->node.parent);
 	index = ida_simple_get(&ft->fte_allocator, fg->start_index,
@@ -1114,11 +1150,20 @@ static struct fs_fte *create_fte(struct mlx5_flow_group *fg,
 
 	fte = alloc_fte(flow_act, match_value, index);
 	if (IS_ERR(fte)) {
-		ida_simple_remove(&ft->fte_allocator, index);
-		return fte;
+		ret = PTR_ERR(fte);
+		goto err_alloc;
 	}
+	ret = rhashtable_insert_fast(&fg->ftes_hash, &fte->hash, rhash_fte);
+	if (ret)
+		goto err_hash;
 
 	return fte;
+
+err_hash:
+	kfree(fte);
+err_alloc:
+	ida_simple_remove(&ft->fte_allocator, index);
+	return ERR_PTR(ret);
 }
 
 static struct mlx5_flow_group *create_autogroup(struct mlx5_flow_table *ft,
@@ -1206,42 +1251,78 @@ static struct mlx5_flow_rule *find_flow_rule(struct fs_fte *fte,
 	return NULL;
 }
 
+static bool check_conflicting_actions(u32 action1, u32 action2)
+{
+	u32 xored_actions = action1 ^ action2;
+
+	/* if one rule only wants to count, it's ok */
+	if (action1 == MLX5_FLOW_CONTEXT_ACTION_COUNT ||
+	    action2 == MLX5_FLOW_CONTEXT_ACTION_COUNT)
+		return false;
+
+	if (xored_actions & (MLX5_FLOW_CONTEXT_ACTION_DROP  |
+			     MLX5_FLOW_CONTEXT_ACTION_ENCAP |
+			     MLX5_FLOW_CONTEXT_ACTION_DECAP))
+		return true;
+
+	return false;
+}
+
+static int check_conflicting_ftes(struct fs_fte *fte, const struct mlx5_flow_act *flow_act)
+{
+	if (check_conflicting_actions(flow_act->action, fte->action)) {
+		mlx5_core_warn(get_dev(&fte->node),
+			       "Found two FTEs with conflicting actions\n");
+		return -EEXIST;
+	}
+
+	if (fte->flow_tag != flow_act->flow_tag) {
+		mlx5_core_warn(get_dev(&fte->node),
+			       "FTE flow tag %u already exists with different flow tag %u\n",
+			       fte->flow_tag,
+			       flow_act->flow_tag);
+		return -EEXIST;
+	}
+
+	return 0;
+}
+
 static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 					    u32 *match_value,
 					    struct mlx5_flow_act *flow_act,
 					    struct mlx5_flow_destination *dest,
 					    int dest_num)
 {
+	u32 masked_val[sizeof(fg->mask.match_criteria)];
 	struct mlx5_flow_handle *handle;
 	struct mlx5_flow_table *ft;
 	struct fs_fte *fte;
 	int i;
 
 	nested_lock_ref_node(&fg->node, FS_MUTEX_PARENT);
-	fs_for_each_fte(fte, fg) {
+	for (i = 0; i < sizeof(masked_val); i++)
+		masked_val[i] = match_value[i] & fg->mask.match_criteria[i];
+	fte = rhashtable_lookup_fast(&fg->ftes_hash, masked_val, rhash_fte);
+	if (fte) {
+		int old_action;
+		int ret;
+
 		nested_lock_ref_node(&fte->node, FS_MUTEX_CHILD);
-		if (compare_match_value(&fg->mask, match_value, &fte->val) &&
-		    (flow_act->action & fte->action)) {
-			int old_action = fte->action;
-
-			if (fte->flow_tag != flow_act->flow_tag) {
-				mlx5_core_warn(get_dev(&fte->node),
-					       "FTE flow tag %u already exists with different flow tag %u\n",
-					       fte->flow_tag,
-					       flow_act->flow_tag);
-				handle = ERR_PTR(-EEXIST);
-				goto unlock_fte;
-			}
+		ret = check_conflicting_ftes(fte, flow_act);
+		if (ret) {
+			handle = ERR_PTR(ret);
+			goto unlock_fte;
+		}
 
-			fte->action |= flow_act->action;
-			handle = add_rule_fte(fte, fg, dest, dest_num,
-					      old_action != flow_act->action);
-			if (IS_ERR(handle)) {
-				fte->action = old_action;
-				goto unlock_fte;
-			} else {
-				goto add_rules;
-			}
+		old_action = fte->action;
+		fte->action |= flow_act->action;
+		handle = add_rule_fte(fte, fg, dest, dest_num,
+				      old_action != flow_act->action);
+		if (IS_ERR(handle)) {
+			fte->action = old_action;
+			goto unlock_fte;
+		} else {
+			goto add_rules;
 		}
 		unlock_ref_node(&fte->node);
 	}
@@ -1257,6 +1338,7 @@ static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 	handle = add_rule_fte(fte, fg, dest, dest_num, false);
 	if (IS_ERR(handle)) {
 		unlock_ref_node(&fte->node);
+		destroy_fte(fte, fg);
 		kfree(fte);
 		goto unlock_fg;
 	}
@@ -1332,6 +1414,10 @@ _mlx5_add_flow_rules(struct mlx5_flow_table *ft,
 	struct mlx5_flow_handle *rule;
 	int i;
 
+	if (!check_valid_mask(spec->match_criteria_enable,
+			      spec->match_criteria))
+		return ERR_PTR(-EINVAL);
+
 	for (i = 0; i < dest_num; i++) {
 		if (!dest_is_valid(&dest[i], flow_act->action, ft))
 			return ERR_PTR(-EINVAL);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index bfbc081d17dc..62709a3865d2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -34,6 +34,7 @@
 #define _MLX5_FS_CORE_
 
 #include <linux/mlx5/fs.h>
+#include <linux/rhashtable.h>
 
 enum fs_node_type {
 	FS_TYPE_NAMESPACE,
@@ -168,6 +169,7 @@ struct fs_fte {
 	u32				modify_id;
 	enum fs_fte_status		status;
 	struct mlx5_fc			*counter;
+	struct rhash_head		hash;
 };
 
 /* Type of children is mlx5_flow_table/namespace */
@@ -197,6 +199,7 @@ struct mlx5_flow_group {
 	u32				start_index;
 	u32				max_ftes;
 	u32				id;
+	struct rhashtable		ftes_hash;
 };
 
 struct mlx5_flow_root_namespace {
-- 
2.13.0
