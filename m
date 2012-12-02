From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next v2 2/3] net/mlx4_en: Fix TX moderation info loss after set_ringparam is called
Date: Sun,  2 Dec 2012 15:49:22 +0200
Message-ID: <1354456163-10497-3-git-send-email-amirv@mellanox.com>
References: <1354456163-10497-1-git-send-email-amirv@mellanox.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Oren Duer <oren@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:33574 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751770Ab2LBNtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 08:49:40 -0500
In-Reply-To: <1354456163-10497-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to re-set tx moderation information after calling set_ringparam
else default tx moderation will be used.
Also avoid related code duplication, by putting it in a utility function.

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   59 ++++++++++++-----------
 1 files changed, 30 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 9d0b88e..dc8ccb4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -43,6 +43,34 @@
 #define EN_ETHTOOL_SHORT_MASK cpu_to_be16(0xffff)
 #define EN_ETHTOOL_WORD_MASK  cpu_to_be32(0xffffffff)
 
+static int mlx4_en_moderation_update(struct mlx4_en_priv *priv)
+{
+	int i;
+	int err = 0;
+
+	for (i = 0; i < priv->tx_ring_num; i++) {
+		priv->tx_cq[i].moder_cnt = priv->tx_frames;
+		priv->tx_cq[i].moder_time = priv->tx_usecs;
+		err = mlx4_en_set_cq_moder(priv, &priv->tx_cq[i]);
+		if (err)
+			return err;
+	}
+
+	if (priv->adaptive_rx_coal)
+		return 0;
+
+	for (i = 0; i < priv->rx_ring_num; i++) {
+		priv->rx_cq[i].moder_cnt = priv->rx_frames;
+		priv->rx_cq[i].moder_time = priv->rx_usecs;
+		priv->last_moder_time[i] = MLX4_EN_AUTO_CONF;
+		err = mlx4_en_set_cq_moder(priv, &priv->rx_cq[i]);
+		if (err)
+			return err;
+	}
+
+	return err;
+}
+
 static void
 mlx4_en_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *drvinfo)
 {
@@ -381,7 +409,6 @@ static int mlx4_en_set_coalesce(struct net_device *dev,
 			      struct ethtool_coalesce *coal)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
-	int err, i;
 
 	priv->rx_frames = (coal->rx_max_coalesced_frames ==
 			   MLX4_EN_AUTO_CONF) ?
@@ -397,14 +424,6 @@ static int mlx4_en_set_coalesce(struct net_device *dev,
 	    coal->tx_max_coalesced_frames != priv->tx_frames) {
 		priv->tx_usecs = coal->tx_coalesce_usecs;
 		priv->tx_frames = coal->tx_max_coalesced_frames;
-		for (i = 0; i < priv->tx_ring_num; i++) {
-			priv->tx_cq[i].moder_cnt = priv->tx_frames;
-			priv->tx_cq[i].moder_time = priv->tx_usecs;
-			if (mlx4_en_set_cq_moder(priv, &priv->tx_cq[i])) {
-				en_warn(priv, "Failed changing moderation "
-					      "for TX cq %d\n", i);
-			}
-		}
 	}
 
 	/* Set adaptive coalescing params */
@@ -414,18 +433,8 @@ static int mlx4_en_set_coalesce(struct net_device *dev,
 	priv->rx_usecs_high = coal->rx_coalesce_usecs_high;
 	priv->sample_interval = coal->rate_sample_interval;
 	priv->adaptive_rx_coal = coal->use_adaptive_rx_coalesce;
-	if (priv->adaptive_rx_coal)
-		return 0;
 
-	for (i = 0; i < priv->rx_ring_num; i++) {
-		priv->rx_cq[i].moder_cnt = priv->rx_frames;
-		priv->rx_cq[i].moder_time = priv->rx_usecs;
-		priv->last_moder_time[i] = MLX4_EN_AUTO_CONF;
-		err = mlx4_en_set_cq_moder(priv, &priv->rx_cq[i]);
-		if (err)
-			return err;
-	}
-	return 0;
+	return mlx4_en_moderation_update(priv);
 }
 
 static int mlx4_en_set_pauseparam(struct net_device *dev,
@@ -466,7 +475,6 @@ static int mlx4_en_set_ringparam(struct net_device *dev,
 	u32 rx_size, tx_size;
 	int port_up = 0;
 	int err = 0;
-	int i;
 
 	if (param->rx_jumbo_pending || param->rx_mini_pending)
 		return -EINVAL;
@@ -505,14 +513,7 @@ static int mlx4_en_set_ringparam(struct net_device *dev,
 			en_err(priv, "Failed starting port\n");
 	}
 
-	for (i = 0; i < priv->rx_ring_num; i++) {
-		priv->rx_cq[i].moder_cnt = priv->rx_frames;
-		priv->rx_cq[i].moder_time = priv->rx_usecs;
-		priv->last_moder_time[i] = MLX4_EN_AUTO_CONF;
-		err = mlx4_en_set_cq_moder(priv, &priv->rx_cq[i]);
-		if (err)
-			goto out;
-	}
+	err = mlx4_en_moderation_update(priv);
 
 out:
 	mutex_unlock(&mdev->state_lock);
-- 
1.7.8.2
