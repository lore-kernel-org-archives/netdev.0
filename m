From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 07/10] net/mlx5e: Properly handle FW errors while adding TC rules
Date: Tue, 10 Jan 2017 22:33:36 +0200
Message-ID: <1484080419-24256-8-git-send-email-saeedm@mellanox.com>
References: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52063 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751126AbdAJUe1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:34:27 -0500
In-Reply-To: <1484080419-24256-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

When the firmware returns an error (common example is an attempt to
add twice the same rule which is refused by the some FWs), we are not
properly derefing/cleaning few resources allocated on the way.
Examples are vport vlan deref under eswitch vlan offloads, and encap
entry/neighbour deref under eswitch encapsulation offloads, fix that.

Fixes: a54e20b4fcae ('net/mlx5e: Add basic TC tunnel set action for SRIOV offloads')
Fixes: 8b32580df1cb ('net/mlx5e: Add TC vlan action for SRIOV offloads')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 5dbc81d..118cea5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -161,15 +161,21 @@ static void mlx5e_detach_encap(struct mlx5e_priv *priv,
 	}
 }
 
+/* we get here also when setting rule to the FW failed, etc. It means that the
+ * flow rule itself might not exist, but some offloading related to the actions
+ * should be cleaned.
+ */
 static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 			      struct mlx5e_tc_flow *flow)
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	struct mlx5_fc *counter = NULL;
 
-	counter = mlx5_flow_rule_counter(flow->rule);
-
-	mlx5_del_flow_rules(flow->rule);
+	if (!IS_ERR(flow->rule)) {
+		counter = mlx5_flow_rule_counter(flow->rule);
+		mlx5_del_flow_rules(flow->rule);
+		mlx5_fc_destroy(priv->mdev, counter);
+	}
 
 	if (esw && esw->mode == SRIOV_OFFLOADS) {
 		mlx5_eswitch_del_vlan_action(esw, flow->attr);
@@ -177,8 +183,6 @@ static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 			mlx5e_detach_encap(priv, flow);
 	}
 
-	mlx5_fc_destroy(priv->mdev, counter);
-
 	if (!mlx5e_tc_num_filters(priv) && (priv->fs.tc.t)) {
 		mlx5_destroy_flow_table(priv->fs.tc.t);
 		priv->fs.tc.t = NULL;
@@ -1017,7 +1021,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 
 	if (IS_ERR(flow->rule)) {
 		err = PTR_ERR(flow->rule);
-		goto err_free;
+		goto err_del_rule;
 	}
 
 	err = rhashtable_insert_fast(&tc->ht, &flow->node,
@@ -1028,7 +1032,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	goto out;
 
 err_del_rule:
-	mlx5_del_flow_rules(flow->rule);
+	mlx5e_tc_del_flow(priv, flow);
 
 err_free:
 	kfree(flow);
-- 
2.7.4
