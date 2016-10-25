From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 03/12] net/mlx5: Keep autogroups list ordered
Date: Tue, 25 Oct 2016 18:36:26 +0300
Message-ID: <1477409795-28807-4-git-send-email-saeedm@mellanox.com>
References: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40901 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755498AbcJYPiV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:38:21 -0400
In-Reply-To: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Blakey <paulb@mellanox.com>

Finding a new autogroup range is done by going over a group list
sorted by each group start index. The search is stopped after finding
the first free range. Adding the newly created group to the list is
wrongly added to the end of the list regardless of its start index as
the parameter of where to insert it is ignored.

This commit makes sure to use that unused parameter to insert
it where requested.

Fixes: f0d22d187473 ('net/mlx5_core: Introduce flow steering autogrouped flow table')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 5da2cc8..17559c8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -879,7 +879,7 @@ static struct mlx5_flow_group *create_flow_group_common(struct mlx5_flow_table *
 	tree_init_node(&fg->node, !is_auto_fg, del_flow_group);
 	tree_add_node(&fg->node, &ft->node);
 	/* Add node to group list */
-	list_add(&fg->node.list, ft->node.children.prev);
+	list_add(&fg->node.list, prev_fg);
 
 	return fg;
 }
@@ -893,7 +893,7 @@ struct mlx5_flow_group *mlx5_create_flow_group(struct mlx5_flow_table *ft,
 		return ERR_PTR(-EPERM);
 
 	lock_ref_node(&ft->node);
-	fg = create_flow_group_common(ft, fg_in, &ft->node.children, false);
+	fg = create_flow_group_common(ft, fg_in, ft->node.children.prev, false);
 	unlock_ref_node(&ft->node);
 
 	return fg;
@@ -1012,7 +1012,7 @@ static struct mlx5_flow_group *create_autogroup(struct mlx5_flow_table *ft,
 						u32 *match_criteria)
 {
 	int inlen = MLX5_ST_SZ_BYTES(create_flow_group_in);
-	struct list_head *prev = &ft->node.children;
+	struct list_head *prev = ft->node.children.prev;
 	unsigned int candidate_index = 0;
 	struct mlx5_flow_group *fg;
 	void *match_criteria_addr;
-- 
2.7.4
