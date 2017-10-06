From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 8/9] net/mlx5: Allocate FTE object without lock
Date: Fri,  6 Oct 2017 16:37:48 -0700
Message-ID: <20171006233749.25545-9-saeedm@mellanox.com>
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

Allocation of new FTE is a massive operation, part of
it could be done without taking the flow group write lock.
Split the FTE allocation to two functions of actions which
need to be under lock and action which don't have.

Signed-off-by: Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 92 +++++++++++------------
 1 file changed, 46 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index e7301cf..bc4bbb7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -546,9 +546,33 @@ static void del_sw_flow_group(struct fs_node *node)
 	WARN_ON(err);
 }
 
-static struct fs_fte *alloc_fte(struct mlx5_flow_act *flow_act,
-				u32 *match_value,
-				unsigned int index)
+static int insert_fte(struct mlx5_flow_group *fg, struct fs_fte *fte)
+{
+	int index;
+	int ret;
+
+	index = ida_simple_get(&fg->fte_allocator, 0, fg->max_ftes, GFP_KERNEL);
+	if (index < 0)
+		return index;
+
+	fte->index = index + fg->start_index;
+	ret = rhashtable_insert_fast(&fg->ftes_hash,
+				     &fte->hash,
+				     rhash_fte);
+	if (ret)
+		goto err_ida_remove;
+
+	tree_add_node(&fte->node, &fg->node);
+	list_add_tail(&fte->node.list, &fg->node.children);
+	return 0;
+
+err_ida_remove:
+	ida_simple_remove(&fg->fte_allocator, index);
+	return ret;
+}
+
+static struct fs_fte *alloc_fte(u32 *match_value,
+				struct mlx5_flow_act *flow_act)
 {
 	struct fs_fte *fte;
 
@@ -559,51 +583,13 @@ static struct fs_fte *alloc_fte(struct mlx5_flow_act *flow_act,
 	memcpy(fte->val, match_value, sizeof(fte->val));
 	fte->node.type =  FS_TYPE_FLOW_ENTRY;
 	fte->flow_tag = flow_act->flow_tag;
-	fte->index = index;
 	fte->action = flow_act->action;
 	fte->encap_id = flow_act->encap_id;
 	fte->modify_id = flow_act->modify_id;
 
-	return fte;
-}
-
-static struct fs_fte *alloc_insert_fte(struct mlx5_flow_group *fg,
-				       u32 *match_value,
-				       struct mlx5_flow_act *flow_act)
-{
-	struct fs_fte *fte;
-	int index;
-	int ret;
-
-	index = ida_simple_get(&fg->fte_allocator, 0,
-			       fg->max_ftes,
-			       GFP_KERNEL);
-	if (index < 0)
-		return ERR_PTR(index);
-
-	fte = alloc_fte(flow_act, match_value, index + fg->start_index);
-	if (IS_ERR(fte)) {
-		ret = PTR_ERR(fte);
-		goto err_ida_remove;
-	}
-
-	ret = rhashtable_insert_fast(&fg->ftes_hash,
-				     &fte->hash,
-				     rhash_fte);
-	if (ret)
-		goto err_free;
-
 	tree_init_node(&fte->node, del_hw_fte, del_sw_fte);
-	tree_add_node(&fte->node, &fg->node);
-	list_add_tail(&fte->node.list, &fg->node.children);
 
 	return fte;
-
-err_free:
-	kfree(fte);
-err_ida_remove:
-	ida_simple_remove(&fg->fte_allocator, index);
-	return ERR_PTR(ret);
 }
 
 static void dealloc_flow_group(struct mlx5_flow_group *fg)
@@ -1589,6 +1575,11 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 	bool take_write = false;
 	struct fs_fte *fte;
 	u64  version;
+	int err;
+
+	fte = alloc_fte(spec->match_value, flow_act);
+	if (IS_ERR(fte))
+		return  ERR_PTR(-ENOMEM);
 
 	list_for_each_entry(iter, match_head, list) {
 		nested_down_read_ref_node(&iter->g->node, FS_LOCK_PARENT);
@@ -1620,6 +1611,7 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 				   flow_act, dest, dest_num, fte_tmp);
 		up_write_ref_node(&fte_tmp->node);
 		tree_put_node(&fte_tmp->node);
+		kfree(fte);
 		return rule;
 	}
 
@@ -1655,13 +1647,14 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 
 		if (!g->node.active)
 			continue;
-		fte = alloc_insert_fte(g, spec->match_value, flow_act);
-		if (IS_ERR(fte)) {
-			if (PTR_ERR(fte) == -ENOSPC)
+		err = insert_fte(g, fte);
+		if (err) {
+			if (err == -ENOSPC)
 				continue;
 			list_for_each_entry(iter, match_head, list)
 				up_write_ref_node(&iter->g->node);
-			return (void *)fte;
+			kfree(fte);
+			return ERR_PTR(err);
 		}
 
 		nested_down_write_ref_node(&fte->node, FS_LOCK_CHILD);
@@ -1677,6 +1670,7 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 out:
 	list_for_each_entry(iter, match_head, list)
 		up_write_ref_node(&iter->g->node);
+	kfree(fte);
 	return rule;
 }
 
@@ -1746,12 +1740,18 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 	if (err)
 		goto err_release_fg;
 
-	fte = alloc_insert_fte(g, spec->match_value, flow_act);
+	fte = alloc_fte(spec->match_value, flow_act);
 	if (IS_ERR(fte)) {
 		err = PTR_ERR(fte);
 		goto err_release_fg;
 	}
 
+	err = insert_fte(g, fte);
+	if (err) {
+		kfree(fte);
+		goto err_release_fg;
+	}
+
 	nested_down_write_ref_node(&fte->node, FS_LOCK_CHILD);
 	up_write_ref_node(&g->node);
 	rule = add_rule_fg(g, spec->match_value, flow_act, dest,
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
