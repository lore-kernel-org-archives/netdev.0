From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 4/9] net/mlx5: Export building of matched flow groups list
Date: Fri,  6 Oct 2017 16:37:44 -0700
Message-ID: <20171006233749.25545-5-saeedm@mellanox.com>
References: <20171006233749.25545-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Maor Gottlieb <maorg@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49828 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753003AbdJFXiU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 19:38:20 -0400
In-Reply-To: <20171006233749.25545-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Refactor the code and export the build of the matched flow groups
list to separate function.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 100 ++++++++++++++--------
 1 file changed, 64 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 2a0b556..33bcaca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1441,47 +1441,87 @@ static bool dest_is_valid(struct mlx5_flow_destination *dest,
 	return true;
 }
 
-static struct mlx5_flow_handle *
-try_add_to_existing_fg(struct mlx5_flow_table *ft,
-		       struct mlx5_flow_spec *spec,
-		       struct mlx5_flow_act *flow_act,
-		       struct mlx5_flow_destination *dest,
-		       int dest_num)
-{
+struct match_list {
+	struct list_head	list;
 	struct mlx5_flow_group *g;
-	struct mlx5_flow_handle *rule;
+};
+
+struct match_list_head {
+	struct list_head  list;
+	struct match_list first;
+};
+
+static void free_match_list(struct match_list_head *head)
+{
+	if (!list_empty(&head->list)) {
+		struct match_list *iter, *match_tmp;
+
+		list_del(&head->first.list);
+		list_for_each_entry_safe(iter, match_tmp, &head->list,
+					 list) {
+			list_del(&iter->list);
+			kfree(iter);
+		}
+	}
+}
+
+static int build_match_list(struct match_list_head *match_head,
+			    struct mlx5_flow_table *ft,
+			    struct mlx5_flow_spec *spec)
+{
 	struct rhlist_head *tmp, *list;
-	struct match_list {
-		struct list_head	list;
-		struct mlx5_flow_group *g;
-	} match_list, *iter;
-	LIST_HEAD(match_head);
+	struct mlx5_flow_group *g;
+	int err = 0;
 
 	rcu_read_lock();
+	INIT_LIST_HEAD(&match_head->list);
 	/* Collect all fgs which has a matching match_criteria */
 	list = rhltable_lookup(&ft->fgs_hash, spec, rhash_fg);
+	/* RCU is atomic, we can't execute FW commands here */
 	rhl_for_each_entry_rcu(g, tmp, list, hash) {
 		struct match_list *curr_match;
 
-		if (likely(list_empty(&match_head))) {
-			match_list.g = g;
-			list_add_tail(&match_list.list, &match_head);
+		if (likely(list_empty(&match_head->list))) {
+			match_head->first.g = g;
+			list_add_tail(&match_head->first.list,
+				      &match_head->list);
 			continue;
 		}
-		curr_match = kmalloc(sizeof(*curr_match), GFP_ATOMIC);
 
+		curr_match = kmalloc(sizeof(*curr_match), GFP_ATOMIC);
 		if (!curr_match) {
-			rcu_read_unlock();
-			rule = ERR_PTR(-ENOMEM);
-			goto free_list;
+			free_match_list(match_head);
+			err = -ENOMEM;
+			goto out;
 		}
 		curr_match->g = g;
-		list_add_tail(&curr_match->list, &match_head);
+		list_add_tail(&curr_match->list, &match_head->list);
 	}
+out:
 	rcu_read_unlock();
+	return err;
+}
+
+static struct mlx5_flow_handle *
+try_add_to_existing_fg(struct mlx5_flow_table *ft,
+		       struct mlx5_flow_spec *spec,
+		       struct mlx5_flow_act *flow_act,
+		       struct mlx5_flow_destination *dest,
+		       int dest_num)
+{
+	struct mlx5_flow_group *g;
+	struct mlx5_flow_handle *rule;
+	struct match_list_head match_head;
+	struct match_list *iter;
+	int err;
+
+	/* Collect all fgs which has a matching match_criteria */
+	err = build_match_list(&match_head, ft, spec);
+	if (err)
+		return ERR_PTR(err);
 
 	/* Try to find a fg that already contains a matching fte */
-	list_for_each_entry(iter, &match_head, list) {
+	list_for_each_entry(iter, &match_head.list, list) {
 		struct fs_fte *fte;
 
 		g = iter->g;
@@ -1500,7 +1540,7 @@ static bool dest_is_valid(struct mlx5_flow_destination *dest,
 	/* No group with matching fte found. Try to add a new fte to any
 	 * matching fg.
 	 */
-	list_for_each_entry(iter, &match_head, list) {
+	list_for_each_entry(iter, &match_head.list, list) {
 		g = iter->g;
 
 		nested_lock_ref_node(&g->node, FS_MUTEX_PARENT);
@@ -1516,19 +1556,7 @@ static bool dest_is_valid(struct mlx5_flow_destination *dest,
 	rule = ERR_PTR(-ENOENT);
 
 free_list:
-	if (!list_empty(&match_head)) {
-		struct match_list *match_tmp;
-
-		/* The most common case is having one FG. Since we want to
-		 * optimize this case, we save the first on the stack.
-		 * Therefore, no need to free it.
-		 */
-		list_del(&list_first_entry(&match_head, typeof(*iter), list)->list);
-		list_for_each_entry_safe(iter, match_tmp, &match_head, list) {
-			list_del(&iter->list);
-			kfree(iter);
-		}
-	}
+	free_match_list(&match_head);
 
 	return rule;
 }
-- 
1.8.3.1
