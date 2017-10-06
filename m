From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 1/9] net/mlx5: Fix creating a new FTE when an existing but full FTE exists
Date: Fri,  6 Oct 2017 16:37:41 -0700
Message-ID: <20171006233749.25545-2-saeedm@mellanox.com>
References: <20171006233749.25545-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49746 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752461AbdJFXiL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 19:38:11 -0400
In-Reply-To: <20171006233749.25545-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>

Currently, when a flow steering rule is added, we look for a FTE with
an identical value. If we find a match, we try to merge the required
destinations with the existing ones. In a case where the existing
destination list is full, the code should return an error to its
consumer. However, the current code just tries to create another FTE.
Fixing that by returning an error in this special scenario.

Fixes: f478be79a22e ("net/mlx5: Add hash table for flow groups in flow table")
Signed-off-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 5a7bea6..6ffe925 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1449,7 +1449,7 @@ static bool dest_is_valid(struct mlx5_flow_destination *dest,
 		       int dest_num)
 {
 	struct mlx5_flow_group *g;
-	struct mlx5_flow_handle *rule = ERR_PTR(-ENOENT);
+	struct mlx5_flow_handle *rule;
 	struct rhlist_head *tmp, *list;
 	struct match_list {
 		struct list_head	list;
@@ -1513,6 +1513,8 @@ static bool dest_is_valid(struct mlx5_flow_destination *dest,
 		unlock_ref_node(&g->node);
 	}
 
+	rule = ERR_PTR(-ENOENT);
+
 free_list:
 	if (!list_empty(&match_head)) {
 		struct match_list *match_tmp;
@@ -1553,7 +1555,7 @@ static bool dest_is_valid(struct mlx5_flow_destination *dest,
 
 	nested_lock_ref_node(&ft->node, FS_MUTEX_GRANDPARENT);
 	rule = try_add_to_existing_fg(ft, spec, flow_act, dest, dest_num);
-	if (!IS_ERR(rule))
+	if (!IS_ERR(rule) || PTR_ERR(rule) != -ENOENT)
 		goto unlock;
 
 	g = create_autogroup(ft, spec->match_criteria_enable,
-- 
1.8.3.1
