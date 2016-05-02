From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 09/12] net/mlx5: E-Switch, Use vport event handler for vport cleanup
Date: Mon,  2 May 2016 19:43:41 +0300
Message-ID: <1462207424-4463-10-git-send-email-saeedm@mellanox.com>
References: <1462207424-4463-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:40230 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754531AbcEBQow (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2016 12:44:52 -0400
In-Reply-To: <1462207424-4463-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

Remove the usage of explicit cleanup function and use existing vport
change handler. Calling vport change handler while vport
is disabled will cleanup the vport resources.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 33 +++++++----------------
 1 file changed, 9 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
index 48c8919..37b4be9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.c
@@ -643,6 +643,9 @@ static void esw_update_vport_addr_list(struct mlx5_eswitch *esw,
 		addr->action = MLX5_ACTION_DEL;
 	}
 
+	if (!vport->enabled)
+		goto out;
+
 	err = mlx5_query_nic_vport_mac_list(esw->dev, vport_num, list_type,
 					    mac_list, &size);
 	if (err)
@@ -1188,27 +1191,6 @@ static void esw_enable_vport(struct mlx5_eswitch *esw, int vport_num,
 	mutex_unlock(&esw->state_lock);
 }
 
-static void esw_cleanup_vport(struct mlx5_eswitch *esw, u16 vport_num)
-{
-	struct mlx5_vport *vport = &esw->vports[vport_num];
-	struct l2addr_node *node;
-	struct vport_addr *addr;
-	struct hlist_node *tmp;
-	int hi;
-
-	for_each_l2hash_node(node, tmp, vport->uc_list, hi) {
-		addr = container_of(node, struct vport_addr, node);
-		addr->action = MLX5_ACTION_DEL;
-	}
-	esw_apply_vport_addr_list(esw, vport_num, MLX5_NVPRT_LIST_TYPE_UC);
-
-	for_each_l2hash_node(node, tmp, vport->mc_list, hi) {
-		addr = container_of(node, struct vport_addr, node);
-		addr->action = MLX5_ACTION_DEL;
-	}
-	esw_apply_vport_addr_list(esw, vport_num, MLX5_NVPRT_LIST_TYPE_MC);
-}
-
 static void esw_disable_vport(struct mlx5_eswitch *esw, int vport_num)
 {
 	struct mlx5_vport *vport = &esw->vports[vport_num];
@@ -1219,7 +1201,6 @@ static void esw_disable_vport(struct mlx5_eswitch *esw, int vport_num)
 	esw_debug(esw->dev, "Disabling vport(%d)\n", vport_num);
 	/* Mark this vport as disabled to discard new events */
 	vport->enabled = false;
-	vport->enabled_events = 0;
 
 	synchronize_irq(mlx5_get_msix_vec(esw->dev, MLX5_EQ_VEC_ASYNC));
 
@@ -1232,8 +1213,12 @@ static void esw_disable_vport(struct mlx5_eswitch *esw, int vport_num)
 	/* Disable events from this vport */
 	arm_vport_context_events_cmd(esw->dev, vport->vport, 0);
 	mutex_lock(&esw->state_lock);
-	/* We don't assume VFs will cleanup after themselves */
-	esw_cleanup_vport(esw, vport_num);
+	/* We don't assume VFs will cleanup after themselves.
+	 * Calling vport change handler while vport is disabled will cleanup
+	 * the vport resources.
+	 */
+	esw_vport_change_handler(&vport->vport_change_handler);
+	vport->enabled_events = 0;
 	if (vport_num) {
 		esw_vport_disable_egress_acl(esw, vport);
 		esw_vport_disable_ingress_acl(esw, vport);
-- 
2.8.0
