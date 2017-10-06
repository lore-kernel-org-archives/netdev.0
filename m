From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 3/9] net/mlx5: Move the entry index allocator to flow group
Date: Fri,  6 Oct 2017 16:37:43 -0700
Message-ID: <20171006233749.25545-4-saeedm@mellanox.com>
References: <20171006233749.25545-1-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171006233749.25545-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

When new flow table entry is added, we search for free index
in the flow group and not in the flow table, therefore we can move
the allocator from flow table to flow group.
In downstream patches it will enable us to lock smaller part
of the steering tree.

Signed-off-by: Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 18 +++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  2 +-
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index f390828..2a0b556 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -384,7 +384,6 @@ static void del_flow_table(struct fs_node *node)
 	err = mlx5_cmd_destroy_flow_table(dev, ft);
 	if (err)
 		mlx5_core_warn(dev, "flow steering can't destroy ft\n");
-	ida_destroy(&ft->fte_allocator);
 	rhltable_destroy(&ft->fgs_hash);
 	fs_get_obj(prio, ft->node.parent);
 	prio->num_ft--;
@@ -445,7 +444,7 @@ static void destroy_fte(struct fs_fte *fte, struct mlx5_flow_group *fg)
 	WARN_ON(ret);
 	fte->status = 0;
 	fs_get_obj(ft, fg->node.parent);
-	ida_simple_remove(&ft->fte_allocator, fte->index);
+	ida_simple_remove(&fg->fte_allocator, fte->index - fg->start_index);
 }
 
 static void del_fte(struct fs_node *node)
@@ -488,6 +487,7 @@ static void del_flow_group(struct fs_node *node)
 		ft->autogroup.num_groups--;
 
 	rhashtable_destroy(&fg->ftes_hash);
+	ida_destroy(&fg->fte_allocator);
 	err = rhltable_remove(&ft->fgs_hash,
 			      &fg->hash,
 			      rhash_fg);
@@ -537,6 +537,7 @@ static struct mlx5_flow_group *alloc_flow_group(u32 *create_fg_in)
 		kfree(fg);
 		return ERR_PTR(ret);
 	}
+	ida_init(&fg->fte_allocator);
 	fg->mask.match_criteria_enable = match_criteria_enable;
 	memcpy(&fg->mask.match_criteria, match_criteria,
 	       sizeof(fg->mask.match_criteria));
@@ -575,7 +576,6 @@ static struct mlx5_flow_table *alloc_flow_table(int level, u16 vport, int max_ft
 	ft->flags = flags;
 	INIT_LIST_HEAD(&ft->fwd_rules);
 	mutex_init(&ft->lock);
-	ida_init(&ft->fte_allocator);
 
 	return ft;
 }
@@ -892,7 +892,6 @@ static struct mlx5_flow_table *__mlx5_create_flow_table(struct mlx5_flow_namespa
 destroy_ft:
 	mlx5_cmd_destroy_flow_table(root->dev, ft);
 free_ft:
-	ida_destroy(&ft->fte_allocator);
 	kfree(ft);
 unlock_root:
 	mutex_unlock(&root->chain_lock);
@@ -1003,6 +1002,7 @@ static struct mlx5_flow_group *create_flow_group_common(struct mlx5_flow_table *
 				rhash_fg));
 err_free_fg:
 	rhashtable_destroy(&fg->ftes_hash);
+	ida_destroy(&fg->fte_allocator);
 	kfree(fg);
 
 	return ERR_PTR(err);
@@ -1181,18 +1181,18 @@ static struct fs_fte *create_fte(struct mlx5_flow_group *fg,
 				 u32 *match_value,
 				 struct mlx5_flow_act *flow_act)
 {
-	struct mlx5_flow_table *ft;
 	struct fs_fte *fte;
 	int index;
 	int ret;
 
-	fs_get_obj(ft, fg->node.parent);
-	index = ida_simple_get(&ft->fte_allocator, fg->start_index,
-			       fg->start_index + fg->max_ftes,
+	index = ida_simple_get(&fg->fte_allocator, 0,
+			       fg->max_ftes,
 			       GFP_KERNEL);
 	if (index < 0)
 		return ERR_PTR(index);
 
+	index += fg->start_index;
+
 	fte = alloc_fte(flow_act, match_value, index);
 	if (IS_ERR(fte)) {
 		ret = PTR_ERR(fte);
@@ -1207,7 +1207,7 @@ static struct fs_fte *create_fte(struct mlx5_flow_group *fg,
 err_hash:
 	kfree(fte);
 err_alloc:
-	ida_simple_remove(&ft->fte_allocator, index);
+	ida_simple_remove(&fg->fte_allocator, index - fg->start_index);
 	return ERR_PTR(ret);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 5509a752..02c969c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -119,7 +119,6 @@ struct mlx5_flow_table {
 	/* FWD rules that point on this flow table */
 	struct list_head		fwd_rules;
 	u32				flags;
-	struct ida			fte_allocator;
 	struct rhltable			fgs_hash;
 };
 
@@ -199,6 +198,7 @@ struct mlx5_flow_group {
 	struct mlx5_flow_group_mask	mask;
 	u32				start_index;
 	u32				max_ftes;
+	struct ida			fte_allocator;
 	u32				id;
 	struct rhashtable		ftes_hash;
 	struct rhlist_head		hash;
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
