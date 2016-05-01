From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 3/4] net/mlx5e: Implement a mlx5e workqueue
Date: Sun,  1 May 2016 22:59:56 +0300
Message-ID: <1462132797-22853-4-git-send-email-saeedm@mellanox.com>
References: <1462132797-22853-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:55766 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752150AbcEAUCI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2016 16:02:08 -0400
In-Reply-To: <1462132797-22853-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Finlay <matt@mellanox.com>

Implement a mlx5e workqueue to handle all mlx5e specific tasks.  Move
all tasks currently using the system workqueue to the new workqueue.
This is in preparation for vxlan using the mlx5e workqueue in order to
schedule port add/remove operations.

Signed-off-by: Matthew Finlay <matt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 30 ++++++++++++++---------
 2 files changed, 20 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e80ce94..3881dce 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -567,6 +567,7 @@ struct mlx5e_priv {
 	struct mlx5e_vxlan_db      vxlan;
 
 	struct mlx5e_params        params;
+	struct workqueue_struct    *wq;
 	struct work_struct         update_carrier_work;
 	struct work_struct         set_rx_mode_work;
 	struct delayed_work        update_stats_work;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 67d548b..9ab0841 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -262,9 +262,8 @@ static void mlx5e_update_stats_work(struct work_struct *work)
 	mutex_lock(&priv->state_lock);
 	if (test_bit(MLX5E_STATE_OPENED, &priv->state)) {
 		mlx5e_update_stats(priv);
-		schedule_delayed_work(dwork,
-				      msecs_to_jiffies(
-					      MLX5E_UPDATE_STATS_INTERVAL));
+		queue_delayed_work(priv->wq, dwork,
+				   msecs_to_jiffies(MLX5E_UPDATE_STATS_INTERVAL));
 	}
 	mutex_unlock(&priv->state_lock);
 }
@@ -280,7 +279,7 @@ static void mlx5e_async_event(struct mlx5_core_dev *mdev, void *vpriv,
 	switch (event) {
 	case MLX5_DEV_EVENT_PORT_UP:
 	case MLX5_DEV_EVENT_PORT_DOWN:
-		schedule_work(&priv->update_carrier_work);
+		queue_work(priv->wq, &priv->update_carrier_work);
 		break;
 
 	default:
@@ -1505,7 +1504,7 @@ int mlx5e_open_locked(struct net_device *netdev)
 	mlx5e_update_carrier(priv);
 	mlx5e_timestamp_init(priv);
 
-	schedule_delayed_work(&priv->update_stats_work, 0);
+	queue_delayed_work(priv->wq, &priv->update_stats_work, 0);
 
 	return 0;
 
@@ -1961,7 +1960,7 @@ static void mlx5e_set_rx_mode(struct net_device *dev)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
-	schedule_work(&priv->set_rx_mode_work);
+	queue_work(priv->wq, &priv->set_rx_mode_work);
 }
 
 static int mlx5e_set_mac(struct net_device *netdev, void *addr)
@@ -1976,7 +1975,7 @@ static int mlx5e_set_mac(struct net_device *netdev, void *addr)
 	ether_addr_copy(netdev->dev_addr, saddr->sa_data);
 	netif_addr_unlock_bh(netdev);
 
-	schedule_work(&priv->set_rx_mode_work);
+	queue_work(priv->wq, &priv->set_rx_mode_work);
 
 	return 0;
 }
@@ -2498,10 +2497,14 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 
 	priv = netdev_priv(netdev);
 
+	priv->wq = create_singlethread_workqueue("mlx5e");
+	if (!priv->wq)
+		goto err_free_netdev;
+
 	err = mlx5_alloc_map_uar(mdev, &priv->cq_uar, false);
 	if (err) {
 		mlx5_core_err(mdev, "alloc_map uar failed, %d\n", err);
-		goto err_free_netdev;
+		goto err_destroy_wq;
 	}
 
 	err = mlx5_core_alloc_pd(mdev, &priv->pdn);
@@ -2580,7 +2583,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
 		vxlan_get_rx_port(netdev);
 
 	mlx5e_enable_async_events(priv);
-	schedule_work(&priv->set_rx_mode_work);
+	queue_work(priv->wq, &priv->set_rx_mode_work);
 
 	return priv;
 
@@ -2617,6 +2620,9 @@ err_dealloc_pd:
 err_unmap_free_uar:
 	mlx5_unmap_free_uar(mdev, &priv->cq_uar);
 
+err_destroy_wq:
+	destroy_workqueue(priv->wq);
+
 err_free_netdev:
 	free_netdev(netdev);
 
@@ -2630,9 +2636,9 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 
 	set_bit(MLX5E_STATE_DESTROYING, &priv->state);
 
-	schedule_work(&priv->set_rx_mode_work);
+	queue_work(priv->wq, &priv->set_rx_mode_work);
 	mlx5e_disable_async_events(priv);
-	flush_scheduled_work();
+	flush_workqueue(priv->wq);
 	if (test_bit(MLX5_INTERFACE_STATE_SHUTDOWN, &mdev->intf_state)) {
 		netif_device_detach(netdev);
 		mutex_lock(&priv->state_lock);
@@ -2655,6 +2661,8 @@ static void mlx5e_destroy_netdev(struct mlx5_core_dev *mdev, void *vpriv)
 	mlx5_core_dealloc_transport_domain(priv->mdev, priv->tdn);
 	mlx5_core_dealloc_pd(priv->mdev, priv->pdn);
 	mlx5_unmap_free_uar(priv->mdev, &priv->cq_uar);
+	cancel_delayed_work_sync(&priv->update_stats_work);
+	destroy_workqueue(priv->wq);
 
 	if (!test_bit(MLX5_INTERFACE_STATE_SHUTDOWN, &mdev->intf_state))
 		free_netdev(netdev);
-- 
2.8.0
