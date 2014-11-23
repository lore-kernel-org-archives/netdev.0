From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: fix mlx4_en_set_rxfh()
Date: Sat, 22 Nov 2014 17:24:19 -0800
Message-ID: <1416705859.17888.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
	 <1416147798-16561-13-git-send-email-edumazet@google.com>
	 <1416692961.7215.31.camel@decadent.org.uk>
	 <1416700690.20938.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:53492 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752444AbaKWBYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2014 20:24:22 -0500
Received: by mail-ie0-f169.google.com with SMTP id y20so7143552ier.28
        for <netdev@vger.kernel.org>; Sat, 22 Nov 2014 17:24:21 -0800 (PST)
In-Reply-To: <1416700690.20938.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

mlx4_en_set_rxfh() can crash if no RSS indir table is provided.

While we are at it, allow RSS key to be changed with ethtool -X

Tested:

myhost:~# cat /proc/sys/net/core/netdev_rss_key 
b6:89:91:f3:b2:c3:c2:90:11:e8:ce:45:e8:a9:9d:1c:f2:f6:d4:53:61:8b:26:3a:b3:9a:57:97:c3:b6:79:4d:2e:d9:66:5c:72:ed:b6:8e:c5:5d:4d:8c:22:67:30:ab:8a:6e:c3:6a

myhost:~# ethtool -x eth0
RX flow hash indirection table for eth0 with 8 RX ring(s):
    0:      0     1     2     3     4     5     6     7
RSS hash key:
b6:89:91:f3:b2:c3:c2:90:11:e8:ce:45:e8:a9:9d:1c:f2:f6:d4:53:61:8b:26:3a:b3:9a:57:97:c3:b6:79:4d:2e:d9:66:5c:72:ed:b6:8e

myhost:~# ethtool -X eth0 hkey \
03:0e:e2:43:fa:82:0e:73:14:2d:c0:68:21:9e:82:99:b9:84:d0:22:e2:b3:64:9f:4a:af:00:fa:cc:05:b4:4a:17:05:14:73:76:58:bd:2f

myhost:~# ethtool -x eth0
RX flow hash indirection table for eth0 with 8 RX ring(s):
    0:      0     1     2     3     4     5     6     7
RSS hash key:
03:0e:e2:43:fa:82:0e:73:14:2d:c0:68:21:9e:82:99:b9:84:d0:22:e2:b3:64:9f:4a:af:00:fa:cc:05:b4:4a:17:05:14:73:76:58:bd:2f


Reported-by: Ben Hutchings <ben@decadent.org.uk>
Fixes: b9d1ab7eb42e ("mlx4: use netdev_rss_key_fill() helper")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   10 +++++++---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    1 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |    3 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    1 +
 4 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index bdff834a2a7e..c45e06abc073 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -994,7 +994,7 @@ static int mlx4_en_get_rxfh(struct net_device *dev, u32 *ring_index, u8 *key)
 			rss_map->base_qpn;
 	}
 	if (key)
-		netdev_rss_key_fill(key, MLX4_EN_RSS_KEY_SIZE);
+		memcpy(key, priv->rss_key, MLX4_EN_RSS_KEY_SIZE);
 	return err;
 }
 
@@ -1012,6 +1012,8 @@ static int mlx4_en_set_rxfh(struct net_device *dev, const u32 *ring_index,
 	 * between rings
 	 */
 	for (i = 0; i < priv->rx_ring_num; i++) {
+		if (!ring_index)
+			continue;
 		if (i > 0 && !ring_index[i] && !rss_rings)
 			rss_rings = i;
 
@@ -1032,8 +1034,10 @@ static int mlx4_en_set_rxfh(struct net_device *dev, const u32 *ring_index,
 		mlx4_en_stop_port(dev, 1);
 	}
 
-	priv->prof->rss_rings = rss_rings;
-
+	if (ring_index)
+		priv->prof->rss_rings = rss_rings;
+	if (key)
+		memcpy(priv->rss_key, key, MLX4_EN_RSS_KEY_SIZE);
 	if (port_up) {
 		err = mlx4_en_start_port(dev);
 		if (err)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 89440cb25ad8..b7c99780aef3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2493,6 +2493,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	priv->num_tx_rings_p_up = mdev->profile.num_tx_rings_p_up;
 	priv->tx_ring_num = prof->tx_ring_num;
 	priv->tx_work_limit = MLX4_EN_DEFAULT_TX_WORK;
+	netdev_rss_key_fill(priv->rss_key, sizeof(priv->rss_key));
 
 	priv->tx_ring = kzalloc(sizeof(struct mlx4_en_tx_ring *) * MAX_TX_RINGS,
 				GFP_KERNEL);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b7bda8956011..946d35280abc 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1223,8 +1223,7 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 
 	rss_context->flags = rss_mask;
 	rss_context->hash_fn = MLX4_RSS_HASH_TOP;
-	netdev_rss_key_fill(rss_context->rss_key, MLX4_EN_RSS_KEY_SIZE);
-
+	memcpy(rss_context->rss_key, priv->rss_key, MLX4_EN_RSS_KEY_SIZE);
 	err = mlx4_qp_to_ready(mdev->dev, &priv->res.mtt, &context,
 			       &rss_map->indir_qp, &rss_map->indir_state);
 	if (err)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index de456749ffae..aaa7efbb9664 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -618,6 +618,7 @@ struct mlx4_en_priv {
 	__be16 vxlan_port;
 
 	u32 pflags;
+	u8 rss_key[MLX4_EN_RSS_KEY_SIZE];
 };
 
 enum mlx4_en_wol {
