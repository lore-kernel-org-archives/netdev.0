From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 07/15] drivers, net, mlx5: convert fs_node.refcount from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 10:23:41 +0300
Message-ID: <1508484229-19706-8-git-send-email-elena.reshetova@intel.com>
References: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-rdma@vger.kernel.org,
        linux-hams@vger.kernel.org, linux-ppp@vger.kernel.org,
        ganeshgr@chelsio.com, nbd@openwrt.org, john@phrozen.org,
        sean.wang@mediatek.com, matthias.bgg@gmail.com,
        yishaih@mellanox.com, saeedm@mellanox.com, matanb@mellanox.com,
        tariqt@mellanox.com, leonro@mellanox.com,
        ajk@comnets.uni-bremen.de, paulus@samba.org, zbr@ioremap.net,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable fs_node.refcount is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 28 +++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  3 ++-
 2 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index f77e496..c7fa1389 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -188,7 +188,7 @@ static void tree_init_node(struct fs_node *node,
 			   void (*del_hw_func)(struct fs_node *),
 			   void (*del_sw_func)(struct fs_node *))
 {
-	atomic_set(&node->refcount, 1);
+	refcount_set(&node->refcount, 1);
 	INIT_LIST_HEAD(&node->list);
 	INIT_LIST_HEAD(&node->children);
 	init_rwsem(&node->lock);
@@ -200,7 +200,7 @@ static void tree_init_node(struct fs_node *node,
 static void tree_add_node(struct fs_node *node, struct fs_node *parent)
 {
 	if (parent)
-		atomic_inc(&parent->refcount);
+		refcount_inc(&parent->refcount);
 	node->parent = parent;
 
 	/* Parent is the root */
@@ -212,7 +212,7 @@ static void tree_add_node(struct fs_node *node, struct fs_node *parent)
 
 static int tree_get_node(struct fs_node *node)
 {
-	return atomic_add_unless(&node->refcount, 1, 0);
+	return refcount_inc_not_zero(&node->refcount);
 }
 
 static void nested_down_read_ref_node(struct fs_node *node,
@@ -220,7 +220,7 @@ static void nested_down_read_ref_node(struct fs_node *node,
 {
 	if (node) {
 		down_read_nested(&node->lock, class);
-		atomic_inc(&node->refcount);
+		refcount_inc(&node->refcount);
 	}
 }
 
@@ -229,7 +229,7 @@ static void nested_down_write_ref_node(struct fs_node *node,
 {
 	if (node) {
 		down_write_nested(&node->lock, class);
-		atomic_inc(&node->refcount);
+		refcount_inc(&node->refcount);
 	}
 }
 
@@ -237,19 +237,19 @@ static void down_write_ref_node(struct fs_node *node)
 {
 	if (node) {
 		down_write(&node->lock);
-		atomic_inc(&node->refcount);
+		refcount_inc(&node->refcount);
 	}
 }
 
 static void up_read_ref_node(struct fs_node *node)
 {
-	atomic_dec(&node->refcount);
+	refcount_dec(&node->refcount);
 	up_read(&node->lock);
 }
 
 static void up_write_ref_node(struct fs_node *node)
 {
-	atomic_dec(&node->refcount);
+	refcount_dec(&node->refcount);
 	up_write(&node->lock);
 }
 
@@ -257,7 +257,7 @@ static void tree_put_node(struct fs_node *node)
 {
 	struct fs_node *parent_node = node->parent;
 
-	if (atomic_dec_and_test(&node->refcount)) {
+	if (refcount_dec_and_test(&node->refcount)) {
 		if (node->del_hw_func)
 			node->del_hw_func(node);
 		if (parent_node) {
@@ -280,8 +280,8 @@ static void tree_put_node(struct fs_node *node)
 
 static int tree_remove_node(struct fs_node *node)
 {
-	if (atomic_read(&node->refcount) > 1) {
-		atomic_dec(&node->refcount);
+	if (refcount_read(&node->refcount) > 1) {
+		refcount_dec(&node->refcount);
 		return -EEXIST;
 	}
 	tree_put_node(node);
@@ -1184,7 +1184,7 @@ static void destroy_flow_handle(struct fs_fte *fte,
 				int i)
 {
 	for (; --i >= 0;) {
-		if (atomic_dec_and_test(&handle->rule[i]->node.refcount)) {
+		if (refcount_dec_and_test(&handle->rule[i]->node.refcount)) {
 			fte->dests_size--;
 			list_del(&handle->rule[i]->node.list);
 			kfree(handle->rule[i]);
@@ -1215,7 +1215,7 @@ create_flow_handle(struct fs_fte *fte,
 		if (dest) {
 			rule = find_flow_rule(fte, dest + i);
 			if (rule) {
-				atomic_inc(&rule->node.refcount);
+				refcount_inc(&rule->node.refcount);
 				goto rule_found;
 			}
 		}
@@ -1466,7 +1466,7 @@ static struct mlx5_flow_handle *add_rule_fg(struct mlx5_flow_group *fg,
 	trace_mlx5_fs_set_fte(fte, false);
 
 	for (i = 0; i < handle->num_rules; i++) {
-		if (atomic_read(&handle->rule[i]->node.refcount) == 1) {
+		if (refcount_read(&handle->rule[i]->node.refcount) == 1) {
 			tree_add_node(&handle->rule[i]->node, &fte->node);
 			trace_mlx5_fs_add_rule(handle->rule[i]);
 		}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
index 80f6f3c7..397d24a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.h
@@ -33,6 +33,7 @@
 #ifndef _MLX5_FS_CORE_
 #define _MLX5_FS_CORE_
 
+#include <linux/refcount.h>
 #include <linux/mlx5/fs.h>
 #include <linux/rhashtable.h>
 
@@ -84,7 +85,7 @@ struct fs_node {
 	struct fs_node		*root;
 	/* lock the node for writing and traversing */
 	struct rw_semaphore	lock;
-	atomic_t		refcount;
+	refcount_t		refcount;
 	bool			active;
 	void			(*del_hw_func)(struct fs_node *);
 	void			(*del_sw_func)(struct fs_node *);
-- 
2.7.4
