From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 1/3] net/mlx4_en: Remove netif_device_detach from stop port flow
Date: Thu, 17 Nov 2016 17:40:49 +0200
Message-ID: <1479397251-6932-2-git-send-email-tariqt@mellanox.com>
References: <1479397251-6932-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53549 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S935528AbcKQRKO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:10:14 -0500
In-Reply-To: <1479397251-6932-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

netif_device_detach() should be called from shutdown flow only,
in any other scenario netif_device_detach is not needed and may
result in -ENODEV error in certain cases.
In order to prevent TX timeout issue during heavy CPU load
netif_carrier_off will be called.

Fixes: 3484aac16149 ("net/mlx4_en: Fix transmit timeout when driver restarts port")
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  8 ++++----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 22 ++++++++--------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  2 +-
 3 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index bdda17d2ea0f..3bb30f66aa07 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -932,7 +932,7 @@ static __be32 speed_set_ptys_admin(struct mlx4_en_priv *priv, u32 speed,
 	mutex_lock(&priv->mdev->state_lock);
 	if (priv->port_up) {
 		en_warn(priv, "Port link mode changed, restarting port...\n");
-		mlx4_en_stop_port(dev, 1);
+		mlx4_en_stop_port(dev);
 		if (mlx4_en_start_port(dev))
 			en_err(priv, "Failed restarting port %d\n", priv->port);
 	}
@@ -1077,7 +1077,7 @@ static int mlx4_en_set_ringparam(struct net_device *dev,
 
 	if (priv->port_up) {
 		port_up = 1;
-		mlx4_en_stop_port(dev, 1);
+		mlx4_en_stop_port(dev);
 	}
 
 	mlx4_en_safe_replace_resources(priv, tmp);
@@ -1205,7 +1205,7 @@ static int mlx4_en_set_rxfh(struct net_device *dev, const u32 *ring_index,
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		port_up = 1;
-		mlx4_en_stop_port(dev, 1);
+		mlx4_en_stop_port(dev);
 	}
 
 	if (ring_index)
@@ -1751,7 +1751,7 @@ static int mlx4_en_set_channels(struct net_device *dev,
 
 	if (priv->port_up) {
 		port_up = 1;
-		mlx4_en_stop_port(dev, 1);
+		mlx4_en_stop_port(dev);
 	}
 
 	mlx4_en_safe_replace_resources(priv, tmp);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 3a47e83d3e07..01a680b66177 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1741,8 +1741,7 @@ int mlx4_en_start_port(struct net_device *dev)
 		napi_schedule(&priv->rx_cq[i]->napi);
 
 	netif_tx_start_all_queues(dev);
-	netif_device_attach(dev);
-
+	netif_carrier_on(dev);
 	return 0;
 
 tx_err:
@@ -1767,7 +1766,7 @@ int mlx4_en_start_port(struct net_device *dev)
 }
 
 
-void mlx4_en_stop_port(struct net_device *dev, int detach)
+void mlx4_en_stop_port(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
@@ -1785,12 +1784,7 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 	mlx4_CLOSE_PORT(mdev->dev, priv->port);
 
 	/* Synchronize with tx routine */
-	netif_tx_lock_bh(dev);
-	if (detach)
-		netif_device_detach(dev);
-	netif_tx_stop_all_queues(dev);
-	netif_tx_unlock_bh(dev);
-
+	netif_carrier_off(dev);
 	netif_tx_disable(dev);
 
 	/* Set port as not active */
@@ -1903,7 +1897,7 @@ static void mlx4_en_restart(struct work_struct *work)
 	rtnl_lock();
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
-		mlx4_en_stop_port(dev, 1);
+		mlx4_en_stop_port(dev);
 		if (mlx4_en_start_port(dev))
 			en_err(priv, "Failed restarting port %d\n", priv->port);
 	}
@@ -1987,7 +1981,7 @@ static int mlx4_en_close(struct net_device *dev)
 
 	mutex_lock(&mdev->state_lock);
 
-	mlx4_en_stop_port(dev, 0);
+	mlx4_en_stop_port(dev);
 	netif_carrier_off(dev);
 
 	mutex_unlock(&mdev->state_lock);
@@ -2231,7 +2225,7 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 			 * the port */
 			en_dbg(DRV, priv, "Change MTU called with card down!?\n");
 		} else {
-			mlx4_en_stop_port(dev, 1);
+			mlx4_en_stop_port(dev);
 			err = mlx4_en_start_port(dev);
 			if (err) {
 				en_err(priv, "Failed restarting port:%d\n",
@@ -2687,7 +2681,7 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		port_up = 1;
-		mlx4_en_stop_port(dev, 1);
+		mlx4_en_stop_port(dev);
 	}
 
 	priv->xdp_ring_num = xdp_ring_num;
@@ -3406,7 +3400,7 @@ int mlx4_en_reset_config(struct net_device *dev,
 
 	if (priv->port_up) {
 		port_up = 1;
-		mlx4_en_stop_port(dev, 1);
+		mlx4_en_stop_port(dev);
 	}
 
 	en_warn(priv, "Changing device configuration rx filter(%x) rx vlan(%x)\n",
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index a3528dd1e72e..fb17acdfe528 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -659,7 +659,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			struct mlx4_en_port_profile *prof);
 
 int mlx4_en_start_port(struct net_device *dev);
-void mlx4_en_stop_port(struct net_device *dev, int detach);
+void mlx4_en_stop_port(struct net_device *dev);
 
 void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev,
 			      struct mlx4_en_stats_bitmap *stats_bitmap,
-- 
1.8.3.1
