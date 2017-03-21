From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 2/8] net/mlx5e: Change the TC offload rule add/del code path to be per NIC or E-Switch
Date: Tue, 21 Mar 2017 15:59:13 +0200
Message-ID: <20170321135919.25018-3-saeedm@mellanox.com>
References: <20170321135919.25018-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38158 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751477AbdCUN7y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 09:59:54 -0400
In-Reply-To: <20170321135919.25018-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Refactor the code to deal with add/del TC rules to have handler per NIC/E-switch
offloading use case, and push the latter into the e-switch code. This provides
better separation and is to be used in down-stream patch for applying a fix.

Fixes: bffaa916588e ("net/mlx5: E-Switch, Add control for inline mode")
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Roi Dayan <roid@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 59 ++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  5 ++
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 14 +++++
 3 files changed, 58 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 79481f4cf264..2825b5665456 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -133,6 +133,23 @@ mlx5e_tc_add_nic_flow(struct mlx5e_priv *priv,
 	return rule;
 }
 
+static void mlx5e_tc_del_nic_flow(struct mlx5e_priv *priv,
+				  struct mlx5e_tc_flow *flow)
+{
+	struct mlx5_fc *counter = NULL;
+
+	if (!IS_ERR(flow->rule)) {
+		counter = mlx5_flow_rule_counter(flow->rule);
+		mlx5_del_flow_rules(flow->rule);
+		mlx5_fc_destroy(priv->mdev, counter);
+	}
+
+	if (!mlx5e_tc_num_filters(priv) && (priv->fs.tc.t)) {
+		mlx5_destroy_flow_table(priv->fs.tc.t);
+		priv->fs.tc.t = NULL;
+	}
+}
+
 static struct mlx5_flow_handle *
 mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 		      struct mlx5_flow_spec *spec,
@@ -149,7 +166,24 @@ mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 }
 
 static void mlx5e_detach_encap(struct mlx5e_priv *priv,
-			       struct mlx5e_tc_flow *flow) {
+			       struct mlx5e_tc_flow *flow);
+
+static void mlx5e_tc_del_fdb_flow(struct mlx5e_priv *priv,
+				  struct mlx5e_tc_flow *flow)
+{
+	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
+
+	mlx5_eswitch_del_offloaded_rule(esw, flow->rule, flow->attr);
+
+	mlx5_eswitch_del_vlan_action(esw, flow->attr);
+
+	if (flow->attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
+		mlx5e_detach_encap(priv, flow);
+}
+
+static void mlx5e_detach_encap(struct mlx5e_priv *priv,
+			       struct mlx5e_tc_flow *flow)
+{
 	struct list_head *next = flow->encap.next;
 
 	list_del(&flow->encap);
@@ -173,25 +207,10 @@ static void mlx5e_detach_encap(struct mlx5e_priv *priv,
 static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 			      struct mlx5e_tc_flow *flow)
 {
-	struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
-	struct mlx5_fc *counter = NULL;
-
-	if (!IS_ERR(flow->rule)) {
-		counter = mlx5_flow_rule_counter(flow->rule);
-		mlx5_del_flow_rules(flow->rule);
-		mlx5_fc_destroy(priv->mdev, counter);
-	}
-
-	if (flow->flags & MLX5E_TC_FLOW_ESWITCH) {
-		mlx5_eswitch_del_vlan_action(esw, flow->attr);
-		if (flow->attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
-			mlx5e_detach_encap(priv, flow);
-	}
-
-	if (!mlx5e_tc_num_filters(priv) && (priv->fs.tc.t)) {
-		mlx5_destroy_flow_table(priv->fs.tc.t);
-		priv->fs.tc.t = NULL;
-	}
+	if (flow->flags & MLX5E_TC_FLOW_ESWITCH)
+		mlx5e_tc_del_fdb_flow(priv, flow);
+	else
+		mlx5e_tc_del_nic_flow(priv, flow);
 }
 
 static void parse_vxlan_attr(struct mlx5_flow_spec *spec,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index 5b78883d5654..9227a83a97e3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -271,6 +271,11 @@ struct mlx5_flow_handle *
 mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 				struct mlx5_flow_spec *spec,
 				struct mlx5_esw_flow_attr *attr);
+void
+mlx5_eswitch_del_offloaded_rule(struct mlx5_eswitch *esw,
+				struct mlx5_flow_handle *rule,
+				struct mlx5_esw_flow_attr *attr);
+
 struct mlx5_flow_handle *
 mlx5_eswitch_create_vport_rx_rule(struct mlx5_eswitch *esw, int vport, u32 tirn);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 4f5b0d47d5f3..bfabefe20ac0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -97,6 +97,20 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 	return rule;
 }
 
+void
+mlx5_eswitch_del_offloaded_rule(struct mlx5_eswitch *esw,
+				struct mlx5_flow_handle *rule,
+				struct mlx5_esw_flow_attr *attr)
+{
+	struct mlx5_fc *counter = NULL;
+
+	if (!IS_ERR(rule)) {
+		counter = mlx5_flow_rule_counter(rule);
+		mlx5_del_flow_rules(rule);
+		mlx5_fc_destroy(esw->dev, counter);
+	}
+}
+
 static int esw_set_global_vlan_pop(struct mlx5_eswitch *esw, u8 val)
 {
 	struct mlx5_eswitch_rep *rep;
-- 
2.11.0
