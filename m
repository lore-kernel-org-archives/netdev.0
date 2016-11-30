From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next 7/8] net/mlx5e: Save the represntor netdevice as part of the representor
Date: Wed, 30 Nov 2016 16:41:34 +0200
Message-ID: <1480516895-29545-8-git-send-email-hadarh@mellanox.com>
References: <1480516895-29545-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46047 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755920AbcK3PhO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:37:14 -0500
In-Reply-To: <1480516895-29545-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the representor private data to a net_device pointer holding the
representor netdevice, instead of void pointer holding mlx5e_priv.

It will be used by a new eswitch service function, returning the uplink representor
netdevice.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c         |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c          | 15 ++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h         |  3 ++-
 .../net/ethernet/mellanox/mlx5/core/eswitch_offloads.c    | 12 +++++++++++-
 4 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 6b492ca..37c0d84 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3796,7 +3796,7 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 		rep.load = mlx5e_nic_rep_load;
 		rep.unload = mlx5e_nic_rep_unload;
 		rep.vport = FDB_UPLINK_VPORT;
-		rep.priv_data = priv;
+		rep.netdev = netdev;
 		mlx5_eswitch_register_vport_rep(esw, 0, &rep);
 	}
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 9b1e351..0868677 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -208,7 +208,8 @@ int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv)
 
 int mlx5e_nic_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 {
-	struct mlx5e_priv *priv = rep->priv_data;
+	struct net_device *netdev = rep->netdev;
+	struct mlx5e_priv *priv = netdev_priv(netdev);
 
 	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
 		return mlx5e_add_sqs_fwd_rules(priv);
@@ -226,7 +227,8 @@ void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv)
 void mlx5e_nic_rep_unload(struct mlx5_eswitch *esw,
 			  struct mlx5_eswitch_rep *rep)
 {
-	struct mlx5e_priv *priv = rep->priv_data;
+	struct net_device *netdev = rep->netdev;
+	struct mlx5e_priv *priv = netdev_priv(netdev);
 
 	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
 		mlx5e_remove_sqs_fwd_rules(priv);
@@ -555,7 +557,7 @@ int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
 		return -EINVAL;
 	}
 
-	rep->priv_data = netdev_priv(netdev);
+	rep->netdev = netdev;
 
 	err = mlx5e_attach_netdev(esw->dev, netdev);
 	if (err) {
@@ -577,7 +579,7 @@ int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
 	mlx5e_detach_netdev(esw->dev, netdev);
 
 err_destroy_netdev:
-	mlx5e_destroy_netdev(esw->dev, rep->priv_data);
+	mlx5e_destroy_netdev(esw->dev, netdev_priv(netdev));
 
 	return err;
 
@@ -586,10 +588,9 @@ int mlx5e_vport_rep_load(struct mlx5_eswitch *esw,
 void mlx5e_vport_rep_unload(struct mlx5_eswitch *esw,
 			    struct mlx5_eswitch_rep *rep)
 {
-	struct mlx5e_priv *priv = rep->priv_data;
-	struct net_device *netdev = priv->netdev;
+	struct net_device *netdev = rep->netdev;
 
 	unregister_netdev(netdev);
 	mlx5e_detach_netdev(esw->dev, netdev);
-	mlx5e_destroy_netdev(esw->dev, priv);
+	mlx5e_destroy_netdev(esw->dev, netdev_priv(netdev));
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index cf1aa56..8661dd3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -186,7 +186,7 @@ struct mlx5_eswitch_rep {
 					 struct mlx5_eswitch_rep *rep);
 	u16		       vport;
 	u8		       hw_id[ETH_ALEN];
-	void		      *priv_data;
+	struct net_device      *netdev;
 
 	struct mlx5_flow_handle *vport_rx_rule;
 	struct list_head       vport_sqs_list;
@@ -318,6 +318,7 @@ void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 				     struct mlx5_eswitch_rep *rep);
 void mlx5_eswitch_unregister_vport_rep(struct mlx5_eswitch *esw,
 				       int vport_index);
+struct net_device *mlx5_eswitch_get_uplink_netdev(struct mlx5_eswitch *esw);
 
 int mlx5_eswitch_add_vlan_action(struct mlx5_eswitch *esw,
 				 struct mlx5_esw_flow_attr *attr);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index 5c01550..466e161 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -970,7 +970,7 @@ void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 	rep->load   = __rep->load;
 	rep->unload = __rep->unload;
 	rep->vport  = __rep->vport;
-	rep->priv_data = __rep->priv_data;
+	rep->netdev = __rep->netdev;
 	ether_addr_copy(rep->hw_id, __rep->hw_id);
 
 	INIT_LIST_HEAD(&rep->vport_sqs_list);
@@ -990,3 +990,13 @@ void mlx5_eswitch_unregister_vport_rep(struct mlx5_eswitch *esw,
 
 	rep->valid = false;
 }
+
+struct net_device *mlx5_eswitch_get_uplink_netdev(struct mlx5_eswitch *esw)
+{
+#define UPLINK_REP_INDEX 0
+	struct mlx5_esw_offload *offloads = &esw->offloads;
+	struct mlx5_eswitch_rep *rep;
+
+	rep = &offloads->vport_reps[UPLINK_REP_INDEX];
+	return rep->netdev;
+}
-- 
1.8.3.1
