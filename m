From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 7/7] net/mlx5e: Remove flow encap entry in the correct place
Date: Wed, 30 Nov 2016 00:19:32 +0200
Message-ID: <1480457972-31286-8-git-send-email-saeedm@mellanox.com>
References: <1480457972-31286-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45852 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755300AbcK2WT4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 17:19:56 -0500
In-Reply-To: <1480457972-31286-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roi Dayan <roid@mellanox.com>

Handling flow encap entry should be inside tc del flow
and is only relevant for offloaded eswitch TC rules.

Fixes: 11a457e9b6c1 ("net/mlx5e: Add basic TC tunnel set action for SRIOV offloads")
Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 43 +++++++++++++------------
 1 file changed, 22 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 3875c1c..f07ef8c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -142,6 +142,24 @@ mlx5e_tc_add_fdb_flow(struct mlx5e_priv *priv,
 	return mlx5_eswitch_add_offloaded_rule(esw, spec, attr);
 }
 
+static void mlx5e_detach_encap(struct mlx5e_priv *priv,
+			       struct mlx5e_tc_flow *flow) {
+	struct list_head *next = flow->encap.next;
+
+	list_del(&flow->encap);
+	if (list_empty(next)) {
+		struct mlx5_encap_entry *e;
+
+		e = list_entry(next, struct mlx5_encap_entry, flows);
+		if (e->n) {
+			mlx5_encap_dealloc(priv->mdev, e->encap_id);
+			neigh_release(e->n);
+		}
+		hlist_del_rcu(&e->encap_hlist);
+		kfree(e);
+	}
+}
+
 static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 			      struct mlx5e_tc_flow *flow)
 {
@@ -152,8 +170,11 @@ static void mlx5e_tc_del_flow(struct mlx5e_priv *priv,
 
 	mlx5_del_flow_rules(flow->rule);
 
-	if (esw && esw->mode == SRIOV_OFFLOADS)
+	if (esw && esw->mode == SRIOV_OFFLOADS) {
 		mlx5_eswitch_del_vlan_action(esw, flow->attr);
+		if (flow->attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
+			mlx5e_detach_encap(priv, flow);
+	}
 
 	mlx5_fc_destroy(priv->mdev, counter);
 
@@ -973,24 +994,6 @@ int mlx5e_configure_flower(struct mlx5e_priv *priv, __be16 protocol,
 	return err;
 }
 
-static void mlx5e_detach_encap(struct mlx5e_priv *priv,
-			       struct mlx5e_tc_flow *flow) {
-	struct list_head *next = flow->encap.next;
-
-	list_del(&flow->encap);
-	if (list_empty(next)) {
-		struct mlx5_encap_entry *e;
-
-		e = list_entry(next, struct mlx5_encap_entry, flows);
-		if (e->n) {
-			mlx5_encap_dealloc(priv->mdev, e->encap_id);
-			neigh_release(e->n);
-		}
-		hlist_del_rcu(&e->encap_hlist);
-		kfree(e);
-	}
-}
-
 int mlx5e_delete_flower(struct mlx5e_priv *priv,
 			struct tc_cls_flower_offload *f)
 {
@@ -1006,8 +1009,6 @@ int mlx5e_delete_flower(struct mlx5e_priv *priv,
 
 	mlx5e_tc_del_flow(priv, flow);
 
-	if (flow->attr->action & MLX5_FLOW_CONTEXT_ACTION_ENCAP)
-		mlx5e_detach_encap(priv, flow);
 
 	kfree(flow);
 
-- 
2.7.4
