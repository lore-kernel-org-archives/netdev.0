From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next V2 09/15] net/mlx5: Don't unlock fte while still using it
Date: Sun, 30 Oct 2016 23:22:02 +0200
Message-ID: <1477862528-4328-10-git-send-email-saeedm@mellanox.com>
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
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60265 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753615AbcJ3VXs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 17:23:48 -0400
In-Reply-To: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Bloch <markb@mellanox.com>

When adding a new rule to an fte, we need to hold the fte lock
until we add that rule to the fte and increase the fte ref count.

Fixes: 0c56b97503fd ("net/mlx5_core: Introduce flow steering API")
Signed-off-by: Mark Bloch <markb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
index 5da2cc8..a07ff30 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/fs_core.c
@@ -1107,9 +1107,8 @@ static struct mlx5_flow_rule *add_rule_fg(struct mlx5_flow_group *fg,
 				return rule;
 			}
 			rule = add_rule_fte(fte, fg, dest);
-			unlock_ref_node(&fte->node);
 			if (IS_ERR(rule))
-				goto unlock_fg;
+				goto unlock_fte;
 			else
 				goto add_rule;
 		}
@@ -1127,6 +1126,7 @@ static struct mlx5_flow_rule *add_rule_fg(struct mlx5_flow_group *fg,
 		goto unlock_fg;
 	}
 	tree_init_node(&fte->node, 0, del_fte);
+	nested_lock_ref_node(&fte->node, FS_MUTEX_CHILD);
 	rule = add_rule_fte(fte, fg, dest);
 	if (IS_ERR(rule)) {
 		kfree(fte);
@@ -1139,6 +1139,8 @@ static struct mlx5_flow_rule *add_rule_fg(struct mlx5_flow_group *fg,
 	list_add(&fte->node.list, prev);
 add_rule:
 	tree_add_node(&rule->node, &fte->node);
+unlock_fte:
+	unlock_ref_node(&fte->node);
 unlock_fg:
 	unlock_ref_node(&fg->node);
 	return rule;
-- 
2.7.4
