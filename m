From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V2 14/15] net/mlx5: Add option to add fwd rule with counter
Date: Sun, 30 Oct 2016 23:22:07 +0200
Message-ID: <1477862528-4328-15-git-send-email-saeedm@mellanox.com>
References: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Mark Bloch <markb@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:60370 "EHLO mellanox.co.il"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1756346AbcJ3VXn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Oct 2016 17:23:43 -0400
In-Reply-To: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Bloch <markb@mellanox.com>

Currently the code supports only drop rules to possess counters,
add that ability also for fwd rules.

Signed-off-by: Mark Bloch <markb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 24 +++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 6732287..0dfd998 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -374,6 +374,7 @@ static void del_rule(struct fs_node *node)
 	struct mlx5_core_dev *dev = get_dev(node);
 	int match_len = MLX5_ST_SZ_BYTES(fte_match_param);
 	int err;
+	bool update_fte = false;
 
 	match_value = mlx5_vzalloc(match_len);
 	if (!match_value) {
@@ -392,13 +393,23 @@ static void del_rule(struct fs_node *node)
 		list_del(&rule->next_ft);
 		mutex_unlock(&rule->dest_attr.ft->lock);
 	}
+
+	if (rule->dest_attr.type == MLX5_FLOW_DESTINATION_TYPE_COUNTER  &&
+	    --fte->dests_size) {
+		modify_mask = BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_ACTION);
+		fte->action &= ~MLX5_FLOW_CONTEXT_ACTION_COUNT;
+		update_fte = true;
+		goto out;
+	}
+
 	if ((fte->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) &&
 	    --fte->dests_size) {
 		modify_mask = BIT(MLX5_SET_FTE_MODIFY_ENABLE_MASK_DESTINATION_LIST),
-		err = mlx5_cmd_update_fte(dev, ft,
-					  fg->id,
-					  modify_mask,
-					  fte);
+		update_fte = true;
+	}
+out:
+	if (update_fte && fte->dests_size) {
+		err = mlx5_cmd_update_fte(dev, ft, fg->id, modify_mask, fte);
 		if (err)
 			mlx5_core_warn(dev,
 				       "%s can't del rule fg id=%d fte_index=%d\n",
@@ -1287,8 +1298,9 @@ static bool counter_is_valid(struct mlx5_fc *counter, u32 action)
 	if (!counter)
 		return false;
 
-	/* Hardware support counter for a drop action only */
-	return action == (MLX5_FLOW_CONTEXT_ACTION_DROP | MLX5_FLOW_CONTEXT_ACTION_COUNT);
+	return (action & (MLX5_FLOW_CONTEXT_ACTION_DROP |
+			  MLX5_FLOW_CONTEXT_ACTION_FWD_DEST)) &&
+		(action & MLX5_FLOW_CONTEXT_ACTION_COUNT);
 }
 
 static bool dest_is_valid(struct mlx5_flow_destination *dest,
-- 
2.7.4
