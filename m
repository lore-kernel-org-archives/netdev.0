From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 01/12] net/mlx5e: Add prefix for e-switch offloaded TC flow attributes
Date: Wed, 29 Mar 2017 02:27:02 +0300
Message-ID: <20170328232713.29894-2-saeedm@mellanox.com>
References: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42825 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932392AbdC1X2B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:01 -0400
In-Reply-To: <20170328232713.29894-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Add esw_ prefix to the flow attributes attached to offloaded e-switch
TC flows. This is a pre-step to add attributes to offloaded NIC TC flows.

Also, save one pointer space by using gcc's zero size array, this would
be beneficial for environments where 100Ks (or Ms) of flows are offloaded.

This patch doesn't change any functionality.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index fade7233dac5..b2501987988b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -58,7 +58,7 @@ struct mlx5e_tc_flow {
 	u8			flags;
 	struct mlx5_flow_handle *rule;
 	struct list_head	encap; /* flows sharing the same encap */
-	struct mlx5_esw_flow_attr *attr;
+	struct mlx5_esw_flow_attr esw_attr[0];
 };
 
 enum {
@@ -173,11 +173,11 @@ static void mlx5e_tc_del_fdb_flow(struct mlx5e_priv *priv,
 {
 	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 
-	mlx5_eswitch_del_offloaded_rule(esw, flow->rule, flow->attr);
+	mlx5_eswitch_del_offloaded_rule(esw, flow->rule, flow->esw_attr);
 
-	mlx5_eswitch_del_vlan_action(esw, flow->attr);
+	mlx5_eswitch_del_vlan_action(esw, flow->esw_attr);
 
-	if (flow->attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
+	if (flow->esw_attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
 		mlx5e_detach_encap(priv, flow);
 }
 
@@ -1073,7 +1073,7 @@ static int mlx5e_attach_encap(struct mlx5e_priv *priv,
 static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 				struct mlx5e_tc_flow *flow)
 {
-	struct mlx5_esw_flow_attr *attr = flow->attr;
+	struct mlx5_esw_flow_attr *attr = flow->esw_attr;
 	struct ip_tunnel_info *info = NULL;
 	const struct tc_action *a;
 	LIST_HEAD(actions);
@@ -1191,11 +1191,10 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 		goto err_free;
 
 	if (flow->flags & MLX5E_TC_FLOW_ESWITCH) {
-		flow->attr  = (struct mlx5_esw_flow_attr *)(flow + 1);
 		err = parse_tc_fdb_actions(priv, f->exts, flow);
 		if (err < 0)
 			goto err_free;
-		flow->rule = mlx5e_tc_add_fdb_flow(priv, spec, flow->attr);
+		flow->rule = mlx5e_tc_add_fdb_flow(priv, spec, flow->esw_attr);
 	} else {
 		err = parse_tc_nic_actions(priv, f->exts, &action, &flow_tag);
 		if (err < 0)
-- 
2.11.0
