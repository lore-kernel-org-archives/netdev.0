From: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 07/16] drivers, net, mlx5: convert fs_node.refcount from atomic_t to refcount_t
Date: Tue, 28 Mar 2017 11:56:34 +0300
Message-ID: <1490691403-4016-8-git-send-email-elena.reshetova@intel.com>
References: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-ppp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ganeshgr-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
        matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        ajk-iz34hMvxm2Hmj42eshorlhS11BummzK+@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org, j@w1.fi,
        kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
        gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
        Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490691403-4016-1-git-send-email-elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Signed-off-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 24 +++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  3 ++-
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 2478516..4f74d15 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -163,7 +163,7 @@ static void tree_init_node(struct fs_node *node,
 			   unsigned int refcount,
 			   void (*remove_func)(struct fs_node *))
 {
-	atomic_set(&node->refcount, refcount);
+	refcount_set(&node->refcount, refcount);
 	INIT_LIST_HEAD(&node->list);
 	INIT_LIST_HEAD(&node->children);
 	mutex_init(&node->lock);
@@ -173,7 +173,7 @@ static void tree_init_node(struct fs_node *node,
 static void tree_add_node(struct fs_node *node, struct fs_node *parent)
 {
 	if (parent)
-		atomic_inc(&parent->refcount);
+		refcount_inc(&parent->refcount);
 	node->parent = parent;
 
 	/* Parent is the root */
@@ -185,7 +185,7 @@ static void tree_add_node(struct fs_node *node, struct fs_node *parent)
 
 static void tree_get_node(struct fs_node *node)
 {
-	atomic_inc(&node->refcount);
+	refcount_inc(&node->refcount);
 }
 
 static void nested_lock_ref_node(struct fs_node *node,
@@ -193,7 +193,7 @@ static void nested_lock_ref_node(struct fs_node *node,
 {
 	if (node) {
 		mutex_lock_nested(&node->lock, class);
-		atomic_inc(&node->refcount);
+		refcount_inc(&node->refcount);
 	}
 }
 
@@ -201,14 +201,14 @@ static void lock_ref_node(struct fs_node *node)
 {
 	if (node) {
 		mutex_lock(&node->lock);
-		atomic_inc(&node->refcount);
+		refcount_inc(&node->refcount);
 	}
 }
 
 static void unlock_ref_node(struct fs_node *node)
 {
 	if (node) {
-		atomic_dec(&node->refcount);
+		refcount_dec(&node->refcount);
 		mutex_unlock(&node->lock);
 	}
 }
@@ -218,7 +218,7 @@ static void tree_put_node(struct fs_node *node)
 	struct fs_node *parent_node = node->parent;
 
 	lock_ref_node(parent_node);
-	if (atomic_dec_and_test(&node->refcount)) {
+	if (refcount_dec_and_test(&node->refcount)) {
 		if (parent_node)
 			list_del_init(&node->list);
 		if (node->remove_func)
@@ -233,8 +233,8 @@ static void tree_put_node(struct fs_node *node)
 
 static int tree_remove_node(struct fs_node *node)
 {
-	if (atomic_read(&node->refcount) > 1) {
-		atomic_dec(&node->refcount);
+	if (refcount_read(&node->refcount) > 1) {
+		refcount_dec(&node->refcount);
 		return -EEXIST;
 	}
 	tree_put_node(node);
@@ -982,7 +982,7 @@ static void destroy_flow_handle(struct fs_fte *fte,
 				int i)
 {
 	for (; --i >= 0;) {
-		if (atomic_dec_and_test(&handle->rule[i]->node.refcount)) {
+		if (refcount_dec_and_test(&handle->rule[i]->node.refcount)) {
 			fte->dests_size--;
 			list_del(&handle->rule[i]->node.list);
 			kfree(handle->rule[i]);
@@ -1013,7 +1013,7 @@ create_flow_handle(struct fs_fte *fte,
 		if (dest) {
 			rule = find_flow_rule(fte, dest + i);
 			if (rule) {
-				atomic_inc(&rule->node.refcount);
+				refcount_inc(&rule->node.refcount);
 				goto rule_found;
 			}
 		}
@@ -1282,7 +1282,7 @@ static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 	list_add(&fte->node.list, prev);
 add_rules:
 	for (i = 0; i < handle->num_rules; i++) {
-		if (atomic_read(&handle->rule[i]->node.refcount) == 1)
+		if (refcount_read(&handle->rule[i]->node.refcount) == 1)
 			tree_add_node(&handle->rule[i]->node, &fte->node);
 	}
 unlock_fte:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 8e668c6..86bc743b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -33,6 +33,7 @@
 #ifndef _MLX5_FS_CORE_
 #define _MLX5_FS_CORE_
 
+#include <linux/refcount.h>
 #include <linux/mlx5/fs.h>
 
 enum fs_node_type {
@@ -80,7 +81,7 @@ struct fs_node {
 	struct fs_node		*root;
 	/* lock the node for writing and traversing */
 	struct mutex		lock;
-	atomic_t		refcount;
+	refcount_t		refcount;
 	void			(*remove_func)(struct fs_node *);
 };
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
