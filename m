From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 6/9] net/mlx5: Replace fs_node mutex with reader/writer semaphore
Date: Fri,  6 Oct 2017 16:37:46 -0700
Message-ID: <20171006233749.25545-7-saeedm@mellanox.com>
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

Currently, steering object is protected by mutex lock, replace
the mutex lock with reader/writer semaphore .
In this patch we still use only write semaphore. In downstream
patches we will switch part of the write locks to read locks.

Signed-off-by: Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 28 +++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  2 +-
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 41f26f4..9406e72 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -145,10 +145,10 @@ struct node_caps {
 	}
 };
 
-enum fs_i_mutex_lock_class {
-	FS_MUTEX_GRANDPARENT,
-	FS_MUTEX_PARENT,
-	FS_MUTEX_CHILD
+enum fs_i_lock_class {
+	FS_LOCK_GRANDPARENT,
+	FS_LOCK_PARENT,
+	FS_LOCK_CHILD
 };
 
 static const struct rhashtable_params rhash_fte = {
@@ -184,7 +184,7 @@ static void tree_init_node(struct fs_node *node,
 	atomic_set(&node->refcount, 1);
 	INIT_LIST_HEAD(&node->list);
 	INIT_LIST_HEAD(&node->children);
-	mutex_init(&node->lock);
+	init_rwsem(&node->lock);
 	node->remove_func = remove_func;
 	node->active = false;
 }
@@ -208,10 +208,10 @@ static void tree_get_node(struct fs_node *node)
 }
 
 static void nested_lock_ref_node(struct fs_node *node,
-				 enum fs_i_mutex_lock_class class)
+				 enum fs_i_lock_class class)
 {
 	if (node) {
-		mutex_lock_nested(&node->lock, class);
+		down_write_nested(&node->lock, class);
 		atomic_inc(&node->refcount);
 	}
 }
@@ -219,7 +219,7 @@ static void nested_lock_ref_node(struct fs_node *node,
 static void lock_ref_node(struct fs_node *node)
 {
 	if (node) {
-		mutex_lock(&node->lock);
+		down_write(&node->lock);
 		atomic_inc(&node->refcount);
 	}
 }
@@ -228,7 +228,7 @@ static void unlock_ref_node(struct fs_node *node)
 {
 	if (node) {
 		atomic_dec(&node->refcount);
-		mutex_unlock(&node->lock);
+		up_write(&node->lock);
 	}
 }
 
@@ -1376,7 +1376,7 @@ static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 		int old_action;
 		int ret;
 
-		nested_lock_ref_node(&fte->node, FS_MUTEX_CHILD);
+		nested_lock_ref_node(&fte->node, FS_LOCK_CHILD);
 		ret = check_conflicting_ftes(fte, flow_act);
 		if (ret) {
 			handle = ERR_PTR(ret);
@@ -1400,7 +1400,7 @@ static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 	fte = alloc_insert_fte(fg, match_value, flow_act);
 	if (IS_ERR(fte))
 		return (void *)fte;
-	nested_lock_ref_node(&fte->node, FS_MUTEX_CHILD);
+	nested_lock_ref_node(&fte->node, FS_LOCK_CHILD);
 	handle = add_rule_fte(fte, fg, dest, dest_num, false);
 	if (IS_ERR(handle)) {
 		unlock_ref_node(&fte->node);
@@ -1548,7 +1548,7 @@ static int build_match_list(struct match_list_head *match_head,
 		struct fs_fte *fte;
 
 		g = iter->g;
-		nested_lock_ref_node(&g->node, FS_MUTEX_PARENT);
+		nested_lock_ref_node(&g->node, FS_LOCK_PARENT);
 		fte = rhashtable_lookup_fast(&g->ftes_hash, spec->match_value,
 					     rhash_fte);
 		if (fte) {
@@ -1566,7 +1566,7 @@ static int build_match_list(struct match_list_head *match_head,
 	list_for_each_entry(iter, &match_head.list, list) {
 		g = iter->g;
 
-		nested_lock_ref_node(&g->node, FS_MUTEX_PARENT);
+		nested_lock_ref_node(&g->node, FS_LOCK_PARENT);
 		rule = add_rule_fg(g, spec->match_value,
 				   flow_act, dest, dest_num, NULL);
 		if (!IS_ERR(rule) || PTR_ERR(rule) != -ENOSPC) {
@@ -1605,7 +1605,7 @@ static int build_match_list(struct match_list_head *match_head,
 			return ERR_PTR(-EINVAL);
 	}
 
-	nested_lock_ref_node(&ft->node, FS_MUTEX_GRANDPARENT);
+	nested_lock_ref_node(&ft->node, FS_LOCK_GRANDPARENT);
 	rule = try_add_to_existing_fg(ft, spec, flow_act, dest, dest_num);
 	if (!IS_ERR(rule) || PTR_ERR(rule) != -ENOENT)
 		goto unlock;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 6e5d25b..b5c079f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -80,7 +80,7 @@ struct fs_node {
 	struct fs_node		*parent;
 	struct fs_node		*root;
 	/* lock the node for writing and traversing */
-	struct mutex		lock;
+	struct rw_semaphore	lock;
 	atomic_t		refcount;
 	bool			active;
 	void			(*remove_func)(struct fs_node *);
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
