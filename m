From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 6/7] net/mlx5e: Refactor tc del flow to accept mlx5e_tc_flow instance
Date: Wed, 30 Nov 2016 00:19:31 +0200
Message-ID: <1480457972-31286-7-git-send-email-saeedm@mellanox.com>
References: <1480457972-31286-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45848 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754011AbcK2WT4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 17:19:56 -0500
In-Reply-To: <1480457972-31286-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

Change the function that deletes offloaded TC rule to get
struct mlx5e_tc_flow instance which contains both the flow
handle and flow attributes. This is a cleanup needed for
downstream patches, it doesn't change any functionality.

Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 4d71445..3875c1c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -143,18 +143,17 @@ mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 }
 
 static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
-			      struct mlx5_flow_handle *rule,
-			      struct mlx5_esw_flow_attr *attr)
+			      struct mlx5e_tc_flow *flow)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	struct mlx5_fc *counter = NULL;
 
-	counter = mlx5_flow_rule_counter(rule);
+	counter = mlx5_flow_rule_counter(flow->rule);
 
-	mlx5_del_flow_rules(rule);
+	mlx5_del_flow_rules(flow->rule);
 
 	if (esw && esw->mode == SRIOV_OFFLOADS)
-		mlx5_eswitch_del_vlan_action(esw, attr);
+		mlx5_eswitch_del_vlan_action(esw, flow->attr);
 
 	mlx5_fc_destroy(priv->mdev, counter);
 
@@ -1005,7 +1004,7 @@ int mlx5e_delete_flower(struct mlx5e_priv *priv,
 
 	rhashtable_remove_fast(&tc->ht, &flow->node, tc->ht_params);
 
-	mlx5e_tc_del_flow(priv, flow->rule, flow->attr);
+	mlx5e_tc_del_flow(priv, flow);
 
 	if (flow->attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
 		mlx5e_detach_encap(priv, flow);
@@ -1065,7 +1064,7 @@ static void _mlx5e_tc_del_flow(void *ptr, void *arg)
 	struct mlx5e_tc_flow *flow = ptr;
 	struct mlx5e_priv *priv = arg;
 
-	mlx5e_tc_del_flow(priv, flow->rule, flow->attr);
+	mlx5e_tc_del_flow(priv, flow);
 	kfree(flow);
 }
 
-- 
2.7.4
