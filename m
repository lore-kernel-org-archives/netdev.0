From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 05/15] net/mlx5e: Use flag to properly monitor a flow rule offloading state
Date: Sun, 30 Apr 2017 16:20:06 +0300
Message-ID: <20170430132016.27012-6-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46745 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756563AbdD3NU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:27 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Instead of relaying on the 'flow->rule' pointer value which can be
valid or invalid (in case the FW returns an error while trying to offload
the rule), monitor the rule state using a flag.

In downstream patch which adds support to IP tunneling neigh update
flow, a TC rule could be cached in the driver and not offloaded into the
HW. In this case, the flow handle pointer stays NULL.

Check the offloaded flag to properly deal with rules which are currently
not offloaded when querying rule statistics.

This patch doesn't add any new functionality.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 25ecffa1a3df..2a9289b8a33b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -59,6 +59,7 @@ struct mlx5_nic_flow_attr {
 enum {
 	MLX5E_TC_FLOW_ESWITCH	= BIT(0),
 	MLX5E_TC_FLOW_NIC	= BIT(1),
+	MLX5E_TC_FLOW_OFFLOADED	= BIT(2),
 };
 
 struct mlx5e_tc_flow {
@@ -245,7 +246,8 @@ static void mlx5e_tc_del_fdb_flow(struct mlx5e_priv *priv,
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 	struct mlx5_esw_flow_attr *attr = flow->esw_attr;
 
-	mlx5_eswitch_del_offloaded_rule(esw, flow->rule, flow->esw_attr);
+	if (flow->flags & MLX5E_TC_FLOW_OFFLOADED)
+		mlx5_eswitch_del_offloaded_rule(esw, flow->rule, flow->esw_attr);
 
 	mlx5_eswitch_del_vlan_action(esw, flow->esw_attr);
 
@@ -1591,6 +1593,7 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 		goto err_free;
 	}
 
+	flow->flags |= MLX5E_TC_FLOW_OFFLOADED;
 	err = rhashtable_insert_fast(&tc->ht, &flow->node,
 				     tc->ht_params);
 	if (err)
@@ -1646,6 +1649,9 @@ int mlx5e_stats_flower(struct mlx5e_priv *priv,
 	if (!flow)
 		return -EINVAL;
 
+	if (!(flow->flags & MLX5E_TC_FLOW_OFFLOADED))
+		return 0;
+
 	counter = mlx5_flow_rule_counter(flow->rule);
 	if (!counter)
 		return 0;
-- 
2.11.0
