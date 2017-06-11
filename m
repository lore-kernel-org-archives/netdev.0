From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 4/9] net/mlx5e: Use modify header ID cache for offloaded TC E-Switch flows
Date: Sun, 11 Jun 2017 17:55:48 +0300
Message-ID: <20170611145553.14180-5-saeedm@mellanox.com>
References: <20170611145553.14180-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46636 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751917AbdFKO4K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:56:10 -0400
In-Reply-To: <20170611145553.14180-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Use the modify header ID cache for the header re-write part of offloading
TC eswitch flows.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index e1217c2279ab..4625a0e226da 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -344,10 +344,7 @@ mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 	}
 
 	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR) {
-		err = mlx5_modify_header_alloc(priv->mdev, MLX5_FLOW_NAMESPACE_FDB,
-					       parse_attr->num_mod_hdr_actions,
-					       parse_attr->mod_hdr_actions,
-					       &attr->mod_hdr_id);
+		err = mlx5e_attach_mod_hdr(priv, flow, parse_attr);
 		kfree(parse_attr->mod_hdr_actions);
 		if (err) {
 			rule = ERR_PTR(err);
@@ -363,8 +360,7 @@ mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 
 err_add_rule:
 	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
-		mlx5_modify_header_dealloc(priv->mdev,
-					   attr->mod_hdr_id);
+		mlx5e_detach_mod_hdr(priv, flow);
 err_mod_hdr:
 	mlx5_eswitch_del_vlan_action(esw, attr);
 err_add_vlan:
@@ -392,8 +388,7 @@ static void mlx5e_tc_del_fdb_flow(struct mlx5e_priv *priv,
 	}
 
 	if (attr->action & MLX5_FLOW_CONTEXT_ACTION_MOD_HDR)
-		mlx5_modify_header_dealloc(priv->mdev,
-					   attr->mod_hdr_id);
+		mlx5e_detach_mod_hdr(priv, flow);
 }
 
 void mlx5e_tc_encap_flows_add(struct mlx5e_priv *priv,
-- 
2.11.0
