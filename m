From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 10/10] net/mlx4_en: Fix transmit timeout when driver restarts port
Date: Thu, 31 Jan 2013 11:07:11 +0200
Message-ID: <1359623231-4491-11-git-send-email-amirv@mellanox.com>
References: <1359623231-4491-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:44192 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753030Ab3AaJHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 04:07:38 -0500
In-Reply-To: <1359623231-4491-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under heavy CPU load, changing, ring size/mtu/etc. could result in transmit
timeout, since stop-start port might take more than 10 seconds.
Calling netif_detach_device to prevent tx queue transmit timeout.

netif_detach_device() is not called under ndo_stop, because netif_carrier_off
will prevent the timeout, and device should not be marked as not present, or
else user won't be able to start it later on.

CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   14 ++++++++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    2 +-
 3 files changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 738e95d..911d488 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -496,7 +496,7 @@ static int mlx4_en_set_ringparam(struct net_device *dev,
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		port_up = 1;
-		mlx4_en_stop_port(dev);
+		mlx4_en_stop_port(dev, 1);
 	}
 
 	mlx4_en_free_resources(priv);
@@ -591,7 +591,7 @@ static int mlx4_en_set_rxfh_indir(struct net_device *dev,
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		port_up = 1;
-		mlx4_en_stop_port(dev);
+		mlx4_en_stop_port(dev, 1);
 	}
 
 	priv->prof->rss_rings = rss_rings;
@@ -1096,7 +1096,7 @@ static int mlx4_en_set_channels(struct net_device *dev,
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		port_up = 1;
-		mlx4_en_stop_port(dev);
+		mlx4_en_stop_port(dev, 1);
 	}
 
 	mlx4_en_free_resources(priv);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 7b513e9..ac1c14f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1178,6 +1178,8 @@ int mlx4_en_start_port(struct net_device *dev)
 
 	priv->port_up = true;
 	netif_tx_start_all_queues(dev);
+	netif_device_attach(dev);
+
 	return 0;
 
 tx_err:
@@ -1200,7 +1202,7 @@ cq_err:
 }
 
 
-void mlx4_en_stop_port(struct net_device *dev)
+void mlx4_en_stop_port(struct net_device *dev, int detach)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
@@ -1216,9 +1218,13 @@ void mlx4_en_stop_port(struct net_device *dev)
 
 	/* Synchronize with tx routine */
 	netif_tx_lock_bh(dev);
+	if (detach)
+		netif_device_detach(dev);
 	netif_tx_stop_all_queues(dev);
 	netif_tx_unlock_bh(dev);
 
+	netif_tx_disable(dev);
+
 	/* Set port as not active */
 	priv->port_up = false;
 
@@ -1323,7 +1329,7 @@ static void mlx4_en_restart(struct work_struct *work)
 
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
-		mlx4_en_stop_port(dev);
+		mlx4_en_stop_port(dev, 1);
 		for (i = 0; i < priv->tx_ring_num; i++)
 			netdev_tx_reset_queue(priv->tx_ring[i].tx_queue);
 		if (mlx4_en_start_port(dev))
@@ -1395,7 +1401,7 @@ static int mlx4_en_close(struct net_device *dev)
 
 	mutex_lock(&mdev->state_lock);
 
-	mlx4_en_stop_port(dev);
+	mlx4_en_stop_port(dev, 0);
 	netif_carrier_off(dev);
 
 	mutex_unlock(&mdev->state_lock);
@@ -1533,7 +1539,7 @@ static int mlx4_en_change_mtu(struct net_device *dev, int new_mtu)
 			 * the port */
 			en_dbg(DRV, priv, "Change MTU called with card down!?\n");
 		} else {
-			mlx4_en_stop_port(dev);
+			mlx4_en_stop_port(dev, 1);
 			err = mlx4_en_start_port(dev);
 			if (err) {
 				en_err(priv, "Failed restarting port:%d\n",
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 4fb4a3e..43f0165 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -539,7 +539,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			struct mlx4_en_port_profile *prof);
 
 int mlx4_en_start_port(struct net_device *dev);
-void mlx4_en_stop_port(struct net_device *dev);
+void mlx4_en_stop_port(struct net_device *dev, int detach);
 
 void mlx4_en_free_resources(struct mlx4_en_priv *priv);
 int mlx4_en_alloc_resources(struct mlx4_en_priv *priv);
-- 
1.7.8.2
