From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 2/9] net/mlx5e: Use short attribute form when adding/deleting offloaded TC flows
Date: Sun, 11 Jun 2017 17:55:46 +0300
Message-ID: <20170611145553.14180-3-saeedm@mellanox.com>
References: <20170611145553.14180-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46634 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751920AbdFKO4K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:56:10 -0400
In-Reply-To: <20170611145553.14180-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Instead of going through flow->nic/esw_attr for each usage, assign
an attr pointer per the context (nic or esw) and use that.

This patch doesn't add any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index cfb32fe5129d..a9feddc31667 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -177,6 +177,7 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 static void mlx5e_tc_del_nic_flow(struct mlx5e_priv *priv,
 				  struct mlx5e_tc_flow *flow)
 {
+	struct mlx5_nic_flow_attr *attr = flow->nic_attr;
 	struct mlx5_fc *counter = NULL;
 
 	counter = mlx5_flow_rule_counter(flow->rule);
@@ -188,9 +189,9 @@ static void mlx5e_tc_del_nic_flow(struct mlx5e_priv *priv,
 		priv->fs.tc.t = NULL;
 	}
 
-	if (flow->nic_attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
+	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
 		mlx5_modify_header_dealloc(priv->mdev,
-					   flow->nic_attr->mod_hdr_id);
+					   attr->mod_hdr_id);
 }
 
 static void mlx5e_detach_encap(struct mlx5e_priv *priv,
@@ -231,7 +232,7 @@ mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 	return rule;
 
 err_add_rule:
-	if (flow->esw_attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
+	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
 		mlx5_modify_header_dealloc(priv->mdev,
 					   attr->mod_hdr_id);
 err_mod_hdr:
@@ -250,17 +251,17 @@ static void mlx5e_tc_del_fdb_flow(struct mlx5e_priv *priv,
 
 	if (flow->flags & MLX5E_TC_FLOW_OFFLOADED) {
 		flow->flags &= ~MLX5E_TC_FLOW_OFFLOADED;
-		mlx5_eswitch_del_offloaded_rule(esw, flow->rule, flow->esw_attr);
+		mlx5_eswitch_del_offloaded_rule(esw, flow->rule, attr);
 	}
 
-	mlx5_eswitch_del_vlan_action(esw, flow->esw_attr);
+	mlx5_eswitch_del_vlan_action(esw, attr);
 
-	if (flow->esw_attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP) {
+	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP) {
 		mlx5e_detach_encap(priv, flow);
-		kvfree(flow->esw_attr->parse_attr);
+		kvfree(attr->parse_attr);
 	}
 
-	if (flow->esw_attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
+	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
 		mlx5_modify_header_dealloc(priv->mdev,
 					   attr->mod_hdr_id);
 }
-- 
2.11.0
