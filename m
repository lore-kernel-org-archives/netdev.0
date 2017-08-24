From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 4/8] net/mlx5: Convert linear search for free index to ida
Date: Thu, 24 Aug 2017 16:21:48 +0300
Message-ID: <20170824132152.29538-5-saeedm@mellanox.com>
References: <20170824132152.29538-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34118 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753046AbdHXNV6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 09:21:58 -0400
In-Reply-To: <20170824132152.29538-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

When allocating a flow table entry, we need to allocate a free index
in the flow group. Currently, this is done by traversing the existing
flow table entries in the flow group, until a free index is found.
Replacing this by using a ida, which allows us to find a free index
much faster.

Signed-off-by: Matan Barak <matanb@mellanox.com>
Reviewed-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 56 ++++++++---------------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  2 +-
 2 files changed, 20 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index e8690fe46bf2..af245fcdba70 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -360,6 +360,7 @@ static void del_flow_table(struct fs_node *node)
 	err = mlx5_cmd_destroy_flow_table(dev, ft);
 	if (err)
 		mlx5_core_warn(dev, "flow steering can't destroy ft\n");
+	ida_destroy(&ft->fte_allocator);
 	fs_get_obj(prio, ft->node.parent);
 	prio->num_ft--;
 }
@@ -437,8 +438,8 @@ static void del_fte(struct fs_node *node)
 			       "flow steering can't delete fte in index %d of flow group id %d\n",
 			       fte->index, fg->id);
 
+	ida_simple_remove(&ft->fte_allocator, fte->index);
 	fte->status = 0;
-	fg->num_ftes--;
 }
 
 static void del_flow_group(struct fs_node *node)
@@ -523,6 +524,7 @@ static struct mlx5_flow_table *alloc_flow_table(int level, u16 vport, int max_ft
 	ft->flags = flags;
 	INIT_LIST_HEAD(&ft->fwd_rules);
 	mutex_init(&ft->lock);
+	ida_init(&ft->fte_allocator);
 
 	return ft;
 }
@@ -839,6 +841,7 @@ static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespa
 destroy_ft:
 	mlx5_cmd_destroy_flow_table(root->dev, ft);
 free_ft:
+	ida_destroy(&ft->fte_allocator);
 	kfree(ft);
 unlock_root:
 	mutex_unlock(&root->chain_lock);
@@ -1102,41 +1105,26 @@ add_rule_fte(struct fs_fte *fte,
 	return ERR_PTR(err);
 }
 
-/* Assumed fg is locked */
-static unsigned int get_free_fte_index(struct mlx5_flow_group *fg,
-				       struct list_head **prev)
-{
-	struct fs_fte *fte;
-	unsigned int start = fg->start_index;
-
-	if (prev)
-		*prev = &fg->node.children;
-
-	/* assumed list is sorted by index */
-	fs_for_each_fte(fte, fg) {
-		if (fte->index != start)
-			return start;
-		start++;
-		if (prev)
-			*prev = &fte->node.list;
-	}
-
-	return start;
-}
-
-/* prev is output, prev->next = new_fte */
 static struct fs_fte *create_fte(struct mlx5_flow_group *fg,
 				 u32 *match_value,
-				 struct mlx5_flow_act *flow_act,
-				 struct list_head **prev)
+				 struct mlx5_flow_act *flow_act)
 {
+	struct mlx5_flow_table *ft;
 	struct fs_fte *fte;
 	int index;
 
-	index = get_free_fte_index(fg, prev);
+	fs_get_obj(ft, fg->node.parent);
+	index = ida_simple_get(&ft->fte_allocator, fg->start_index,
+			       fg->start_index + fg->max_ftes,
+			       GFP_KERNEL);
+	if (index < 0)
+		return ERR_PTR(index);
+
 	fte = alloc_fte(flow_act, match_value, index);
-	if (IS_ERR(fte))
+	if (IS_ERR(fte)) {
+		ida_simple_remove(&ft->fte_allocator, index);
 		return fte;
+	}
 
 	return fte;
 }
@@ -1234,7 +1222,6 @@ static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 {
 	struct mlx5_flow_handle *handle;
 	struct mlx5_flow_table *ft;
-	struct list_head *prev;
 	struct fs_fte *fte;
 	int i;
 
@@ -1267,12 +1254,8 @@ static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 		unlock_ref_node(&fte->node);
 	}
 	fs_get_obj(ft, fg->node.parent);
-	if (fg->num_ftes >= fg->max_ftes) {
-		handle = ERR_PTR(-ENOSPC);
-		goto unlock_fg;
-	}
 
-	fte = create_fte(fg, match_value, flow_act, &prev);
+	fte = create_fte(fg, match_value, flow_act);
 	if (IS_ERR(fte)) {
 		handle = (void *)fte;
 		goto unlock_fg;
@@ -1286,10 +1269,9 @@ static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 		goto unlock_fg;
 	}
 
-	fg->num_ftes++;
-
 	tree_add_node(&fte->node, &fg->node);
-	list_add(&fte->node.list, prev);
+	/* fte list isn't sorted */
+	list_add_tail(&fte->node.list, &fg->node.children);
 add_rules:
 	for (i = 0; i < handle->num_rules; i++) {
 		if (atomic_read(&handle->rule[i]->node.refcount) == 1)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 9fb5a333df52..5fbae885558f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -118,6 +118,7 @@ struct mlx5_flow_table {
 	/* FWD rules that point on this flow table */
 	struct list_head		fwd_rules;
 	u32				flags;
+	struct ida			fte_allocator;
 };
 
 struct mlx5_fc_cache {
@@ -183,7 +184,6 @@ struct mlx5_flow_group {
 	struct mlx5_flow_group_mask	mask;
 	u32				start_index;
 	u32				max_ftes;
-	u32				num_ftes;
 	u32				id;
 };
 
-- 
2.13.0
