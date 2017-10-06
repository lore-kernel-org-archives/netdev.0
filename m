From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 9/9] net/mlx5: Add FGs and FTEs memory pool
Date: Fri,  6 Oct 2017 16:37:49 -0700
Message-ID: <20171006233749.25545-10-saeedm@mellanox.com>
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

Add memory pool allocation for flow groups and flow
table entry.

It is useful because these objects are not small and could
be allocated/deallocated many times.

Signed-off-by: Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 67 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  2 +
 2 files changed, 53 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index bc4bbb7..7a136ae 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -269,8 +269,9 @@ static void tree_put_node(struct fs_node *node)
 			if (node->del_sw_func)
 				node->del_sw_func(node);
 			up_write_ref_node(parent_node);
+		} else {
+			kfree(node);
 		}
-		kfree(node);
 		node = NULL;
 	}
 	if (!node && parent_node)
@@ -389,6 +390,15 @@ static struct mlx5_flow_root_namespace *find_root(struct fs_node *node)
 	return container_of(ns, struct mlx5_flow_root_namespace, ns);
 }
 
+static inline struct mlx5_flow_steering *get_steering(struct fs_node *node)
+{
+	struct mlx5_flow_root_namespace *root = find_root(node);
+
+	if (root)
+		return root->dev->priv.steering;
+	return NULL;
+}
+
 static inline struct mlx5_core_dev *get_dev(struct fs_node *node)
 {
 	struct mlx5_flow_root_namespace *root = find_root(node);
@@ -424,6 +434,7 @@ static void del_sw_flow_table(struct fs_node *node)
 	rhltable_destroy(&ft->fgs_hash);
 	fs_get_obj(prio, ft->node.parent);
 	prio->num_ft--;
+	kfree(ft);
 }
 
 static void del_sw_hw_rule(struct fs_node *node)
@@ -469,6 +480,7 @@ static void del_sw_hw_rule(struct fs_node *node)
 				       "%s can't del rule fg id=%d fte_index=%d\n",
 				       __func__, fg->id, fte->index);
 	}
+	kfree(rule);
 }
 
 static void del_hw_fte(struct fs_node *node)
@@ -497,6 +509,7 @@ static void del_hw_fte(struct fs_node *node)
 
 static void del_sw_fte(struct fs_node *node)
 {
+	struct mlx5_flow_steering *steering = get_steering(node);
 	struct mlx5_flow_group *fg;
 	struct fs_fte *fte;
 	int err;
@@ -509,6 +522,7 @@ static void del_sw_fte(struct fs_node *node)
 				     rhash_fte);
 	WARN_ON(err);
 	ida_simple_remove(&fg->fte_allocator, fte->index - fg->start_index);
+	kmem_cache_free(steering->ftes_cache, fte);
 }
 
 static void del_hw_flow_group(struct fs_node *node)
@@ -529,6 +543,7 @@ static void del_hw_flow_group(struct fs_node *node)
 
 static void del_sw_flow_group(struct fs_node *node)
 {
+	struct mlx5_flow_steering *steering = get_steering(node);
 	struct mlx5_flow_group *fg;
 	struct mlx5_flow_table *ft;
 	int err;
@@ -544,6 +559,7 @@ static void del_sw_flow_group(struct fs_node *node)
 			      &fg->hash,
 			      rhash_fg);
 	WARN_ON(err);
+	kmem_cache_free(steering->fgs_cache, fg);
 }
 
 static int insert_fte(struct mlx5_flow_group *fg, struct fs_fte *fte)
@@ -571,12 +587,14 @@ static int insert_fte(struct mlx5_flow_group *fg, struct fs_fte *fte)
 	return ret;
 }
 
-static struct fs_fte *alloc_fte(u32 *match_value,
+static struct fs_fte *alloc_fte(struct mlx5_flow_table *ft,
+				u32 *match_value,
 				struct mlx5_flow_act *flow_act)
 {
+	struct mlx5_flow_steering *steering = get_steering(&ft->node);
 	struct fs_fte *fte;
 
-	fte = kzalloc(sizeof(*fte), GFP_KERNEL);
+	fte = kmem_cache_zalloc(steering->ftes_cache, GFP_KERNEL);
 	if (!fte)
 		return ERR_PTR(-ENOMEM);
 
@@ -592,13 +610,15 @@ static struct fs_fte *alloc_fte(u32 *match_value,
 	return fte;
 }
 
-static void dealloc_flow_group(struct mlx5_flow_group *fg)
+static void dealloc_flow_group(struct mlx5_flow_steering *steering,
+			       struct mlx5_flow_group *fg)
 {
 	rhashtable_destroy(&fg->ftes_hash);
-	kfree(fg);
+	kmem_cache_free(steering->fgs_cache, fg);
 }
 
-static struct mlx5_flow_group *alloc_flow_group(u8 match_criteria_enable,
+static struct mlx5_flow_group *alloc_flow_group(struct mlx5_flow_steering *steering,
+						u8 match_criteria_enable,
 						void *match_criteria,
 						int start_index,
 						int end_index)
@@ -606,13 +626,13 @@ static struct mlx5_flow_group *alloc_flow_group(u8 match_criteria_enable,
 	struct mlx5_flow_group *fg;
 	int ret;
 
-	fg = kzalloc(sizeof(*fg), GFP_KERNEL);
+	fg = kmem_cache_zalloc(steering->fgs_cache, GFP_KERNEL);
 	if (!fg)
 		return ERR_PTR(-ENOMEM);
 
 	ret = rhashtable_init(&fg->ftes_hash, &rhash_fte);
 	if (ret) {
-		kfree(fg);
+		kmem_cache_free(steering->fgs_cache, fg);
 		return ERR_PTR(ret);
 }
 	ida_init(&fg->fte_allocator);
@@ -633,10 +653,11 @@ static struct mlx5_flow_group *alloc_insert_flow_group(struct mlx5_flow_table *f
 						       int end_index,
 						       struct list_head *prev)
 {
+	struct mlx5_flow_steering *steering = get_steering(&ft->node);
 	struct mlx5_flow_group *fg;
 	int ret;
 
-	fg = alloc_flow_group(match_criteria_enable, match_criteria,
+	fg = alloc_flow_group(steering, match_criteria_enable, match_criteria,
 			      start_index, end_index);
 	if (IS_ERR(fg))
 		return fg;
@@ -646,7 +667,7 @@ static struct mlx5_flow_group *alloc_insert_flow_group(struct mlx5_flow_table *f
 			      &fg->hash,
 			      rhash_fg);
 	if (ret) {
-		dealloc_flow_group(fg);
+		dealloc_flow_group(steering, fg);
 		return ERR_PTR(ret);
 	}
 
@@ -1569,6 +1590,7 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 		       int dest_num,
 		       int ft_version)
 {
+	struct mlx5_flow_steering *steering = get_steering(&ft->node);
 	struct mlx5_flow_group *g;
 	struct mlx5_flow_handle *rule;
 	struct match_list *iter;
@@ -1577,7 +1599,7 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 	u64  version;
 	int err;
 
-	fte = alloc_fte(spec->match_value, flow_act);
+	fte = alloc_fte(ft, spec->match_value, flow_act);
 	if (IS_ERR(fte))
 		return  ERR_PTR(-ENOMEM);
 
@@ -1611,7 +1633,7 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 				   flow_act, dest, dest_num, fte_tmp);
 		up_write_ref_node(&fte_tmp->node);
 		tree_put_node(&fte_tmp->node);
-		kfree(fte);
+		kmem_cache_free(steering->ftes_cache, fte);
 		return rule;
 	}
 
@@ -1653,7 +1675,7 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 				continue;
 			list_for_each_entry(iter, match_head, list)
 				up_write_ref_node(&iter->g->node);
-			kfree(fte);
+			kmem_cache_free(steering->ftes_cache, fte);
 			return ERR_PTR(err);
 		}
 
@@ -1670,7 +1692,7 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 out:
 	list_for_each_entry(iter, match_head, list)
 		up_write_ref_node(&iter->g->node);
-	kfree(fte);
+	kmem_cache_free(steering->ftes_cache, fte);
 	return rule;
 }
 
@@ -1682,6 +1704,7 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 		     int dest_num)
 
 {
+	struct mlx5_flow_steering *steering = get_steering(&ft->node);
 	struct mlx5_flow_group *g;
 	struct mlx5_flow_handle *rule;
 	struct match_list_head match_head;
@@ -1740,7 +1763,7 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 	if (err)
 		goto err_release_fg;
 
-	fte = alloc_fte(spec->match_value, flow_act);
+	fte = alloc_fte(ft, spec->match_value, flow_act);
 	if (IS_ERR(fte)) {
 		err = PTR_ERR(fte);
 		goto err_release_fg;
@@ -1748,7 +1771,7 @@ static u64 matched_fgs_get_version(struct list_head *match_head)
 
 	err = insert_fte(g, fte);
 	if (err) {
-		kfree(fte);
+		kmem_cache_free(steering->ftes_cache, fte);
 		goto err_release_fg;
 	}
 
@@ -2281,6 +2304,8 @@ void mlx5_cleanup_fs(struct mlx5_core_dev *dev)
 	cleanup_root_ns(steering->sniffer_rx_root_ns);
 	cleanup_root_ns(steering->sniffer_tx_root_ns);
 	mlx5_cleanup_fc_stats(dev);
+	kmem_cache_destroy(steering->ftes_cache);
+	kmem_cache_destroy(steering->fgs_cache);
 	kfree(steering);
 }
 
@@ -2386,6 +2411,16 @@ int mlx5_init_fs(struct mlx5_core_dev *dev)
 	steering->dev = dev;
 	dev->priv.steering = steering;
 
+	steering->fgs_cache = kmem_cache_create("mlx5_fs_fgs",
+						sizeof(struct mlx5_flow_group), 0,
+						0, NULL);
+	steering->ftes_cache = kmem_cache_create("mlx5_fs_ftes", sizeof(struct fs_fte), 0,
+						 0, NULL);
+	if (!steering->ftes_cache || !steering->fgs_cache) {
+		err = -ENOMEM;
+		goto err;
+	}
+
 	if ((((MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_ETH) &&
 	      (MLX5_CAP_GEN(dev, nic_flow_table))) ||
 	     ((MLX5_CAP_GEN(dev, port_type) == MLX5_CAP_PORT_TYPE_IB) &&
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 875b753..ebe1845 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -65,6 +65,8 @@ enum fs_fte_status {
 
 struct mlx5_flow_steering {
 	struct mlx5_core_dev *dev;
+	struct kmem_cache               *fgs_cache;
+	struct kmem_cache               *ftes_cache;
 	struct mlx5_flow_root_namespace *root_ns;
 	struct mlx5_flow_root_namespace *fdb_root_ns;
 	struct mlx5_flow_root_namespace *esw_egress_root_ns;
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
