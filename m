From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 11/12] net/mlx5e: Don't sync netdev state when not registered
Date: Wed, 28 Dec 2016 14:58:41 +0200
Message-ID: <1482929922-32626-12-git-send-email-saeedm@mellanox.com>
References: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32811 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751600AbcL1M66 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 07:58:58 -0500
In-Reply-To: <1482929922-32626-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Skip setting netdev vxlan ports and netdev rx_mode on driver load
when netdev is not yet registered.

Synchronizing with netdev state is needed only on reset flow where the
netdev remains registered for the whole reset period.

This also fixes an access before initialization of net_device.addr_list_lock
- which for some reason initialized on register_netdev - where we queued
set_rx_mode work on driver load before netdev registration.

Fixes: 26e59d8077a3 ("net/mlx5e: Implement mlx5e interface attach/detach callbacks")
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Reviewed-by: Mohamad Haj Yahia <mohamad@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index be5ef03..cf270f6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3781,14 +3781,7 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 
 	mlx5_lag_add(mdev, netdev);
 
-	if (mlx5e_vxlan_allowed(mdev)) {
-		rtnl_lock();
-		udp_tunnel_get_rx_info(netdev);
-		rtnl_unlock();
-	}
-
 	mlx5e_enable_async_events(priv);
-	queue_work(priv->wq, &priv->set_rx_mode_work);
 
 	if (MLX5_CAP_GEN(mdev, vport_group_manager)) {
 		mlx5_query_nic_vport_mac_address(mdev, 0, rep.hw_id);
@@ -3798,6 +3791,18 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 		rep.netdev = netdev;
 		mlx5_eswitch_register_vport_rep(esw, 0, &rep);
 	}
+
+	if (netdev->reg_state != NETREG_REGISTERED)
+		return;
+
+	/* Device already registered: sync netdev system state */
+	if (mlx5e_vxlan_allowed(mdev)) {
+		rtnl_lock();
+		udp_tunnel_get_rx_info(netdev);
+		rtnl_unlock();
+	}
+
+	queue_work(priv->wq, &priv->set_rx_mode_work);
 }
 
 static void mlx5e_nic_disable(struct mlx5e_priv *priv)
-- 
2.7.4
