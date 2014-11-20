From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 2/2] net/mlx4_en: Support for configurable RSS hash function
Date: Thu, 20 Nov 2014 16:26:50 +0200
Message-ID: <1416493610-8966-3-git-send-email-amirv@mellanox.com>
References: <1416493610-8966-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46704 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753356AbaKTO1H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 09:27:07 -0500
In-Reply-To: <1416493610-8966-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

The ConnectX HW is capable of using one of the following hash functions:
Toeplitz and an XOR hash function. This patch extends the implementation
of the mlx4_en driver set/get_rxfh callbacks to support getting and
setting the RSS hash function used by the device.

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 78 ++++++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 11 ++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 13 ++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  2 +-
 4 files changed, 80 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index c50181a..ae679ca 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -978,6 +978,27 @@ static u32 mlx4_en_get_rxfh_key_size(struct net_device *netdev)
 	return MLX4_EN_RSS_KEY_SIZE;
 }
 
+static int mlx4_en_check_rxfh_func(struct net_device *dev, u8 hfunc)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+
+	/* check if requested function is supported by the device */
+	if ((hfunc == ETH_RSS_HASH_TOP &&
+	     !(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RSS_TOP)) ||
+	    (hfunc == ETH_RSS_HASH_XOR &&
+	     !(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RSS_XOR)))
+		return -EINVAL;
+
+	priv->rss_hash_fn = hfunc;
+	if (hfunc == ETH_RSS_HASH_TOP && !(dev->features & NETIF_F_RXHASH))
+		en_warn(priv,
+			"Toeplitz hash function should be used in conjunction with RX hashing for optimal performance\n");
+	if (hfunc == ETH_RSS_HASH_XOR && (dev->features & NETIF_F_RXHASH))
+		en_warn(priv,
+			"Enabling both XOR Hash function and RX Hashing can limit RPS functionality\n");
+	return 0;
+}
+
 static int mlx4_en_get_rxfh(struct net_device *dev, u32 *ring_index, u8 *key,
 			    u8 *hfunc)
 {
@@ -987,18 +1008,23 @@ static int mlx4_en_get_rxfh(struct net_device *dev, u32 *ring_index, u8 *key,
 	size_t n = priv->rx_ring_num;
 	int err = 0;
 
-	if (!ring_index)
+	if (!ring_index && !hfunc && !key)
 		return -EOPNOTSUPP;
 
-	rss_rings = priv->prof->rss_rings ?: priv->rx_ring_num;
-	rss_rings = 1 << ilog2(rss_rings);
+	if (ring_index) {
+		rss_rings = priv->prof->rss_rings ?: priv->rx_ring_num;
+		rss_rings = 1 << ilog2(rss_rings);
 
-	while (n--) {
-		ring_index[n] = rss_map->qps[n % rss_rings].qpn -
-			rss_map->base_qpn;
+		while (n--) {
+			ring_index[n] = rss_map->qps[n % rss_rings].qpn -
+				rss_map->base_qpn;
+		}
 	}
 	if (key)
 		netdev_rss_key_fill(key, MLX4_EN_RSS_KEY_SIZE);
+	if (hfunc)
+		*hfunc = priv->rss_hash_fn;
+
 	return err;
 }
 
@@ -1015,26 +1041,35 @@ static int mlx4_en_set_rxfh(struct net_device *dev, const u32 *ring_index,
 	/* We require at least one supported parameter to be changed and no
 	 * change in any of the unsupported parameters
 	 */
-	if (!ring_index || (key || hfunc != ETH_RSS_HASH_NO_CHANGE))
+	if ((!ring_index && hfunc == ETH_RSS_HASH_NO_CHANGE) || key)
 		return -EOPNOTSUPP;
 
-	/* Calculate RSS table size and make sure flows are spread evenly
-	 * between rings
-	 */
-	for (i = 0; i < priv->rx_ring_num; i++) {
-		if (i > 0 && !ring_index[i] && !rss_rings)
-			rss_rings = i;
+	if (ring_index) {
+		/* Calculate RSS table size and make sure flows are spread
+		 * evenly between rings
+		 */
+		for (i = 0; i < priv->rx_ring_num; i++) {
+			if (i > 0 && !ring_index[i] && !rss_rings)
+				rss_rings = i;
+
+			if (ring_index[i] != (i % (rss_rings ?:
+						   priv->rx_ring_num)))
+				return -EINVAL;
+		}
 
-		if (ring_index[i] != (i % (rss_rings ?: priv->rx_ring_num)))
+		if (!rss_rings)
+			rss_rings = priv->rx_ring_num;
+
+		/* RSS table size must be an order of 2 */
+		if (!is_power_of_2(rss_rings))
 			return -EINVAL;
 	}
 
-	if (!rss_rings)
-		rss_rings = priv->rx_ring_num;
-
-	/* RSS table size must be an order of 2 */
-	if (!is_power_of_2(rss_rings))
-		return -EINVAL;
+	if (hfunc != ETH_RSS_HASH_NO_CHANGE) {
+		err = mlx4_en_check_rxfh_func(dev, hfunc);
+		if (err)
+			return err;
+	}
 
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
@@ -1042,7 +1077,8 @@ static int mlx4_en_set_rxfh(struct net_device *dev, const u32 *ring_index,
 		mlx4_en_stop_port(dev, 1);
 	}
 
-	priv->prof->rss_rings = rss_rings;
+	if (ring_index)
+		priv->prof->rss_rings = rss_rings;
 
 	if (port_up) {
 		err = mlx4_en_start_port(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f3df9b3..d81bb31 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2596,6 +2596,17 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_A0)
 		dev->priv_flags |= IFF_UNICAST_FLT;
 
+	/* Setting a default hash function value */
+	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RSS_TOP) {
+		priv->rss_hash_fn = ETH_RSS_HASH_TOP;
+	} else if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RSS_XOR) {
+		priv->rss_hash_fn = ETH_RSS_HASH_XOR;
+	} else {
+		en_warn(priv,
+			"No RSS hash capabilities exposed, using Toeplitz\n");
+		priv->rss_hash_fn = ETH_RSS_HASH_TOP;
+	}
+
 	mdev->pndev[port] = dev;
 
 	netif_carrier_off(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index b7bda89..3b3ffbd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1223,8 +1223,17 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 
 	rss_context->flags = rss_mask;
 	rss_context->hash_fn = MLX4_RSS_HASH_TOP;
-	netdev_rss_key_fill(rss_context->rss_key, MLX4_EN_RSS_KEY_SIZE);
-
+	if (priv->rss_hash_fn == ETH_RSS_HASH_XOR) {
+		rss_context->hash_fn = MLX4_RSS_HASH_XOR;
+	} else if (priv->rss_hash_fn == ETH_RSS_HASH_TOP) {
+		rss_context->hash_fn = MLX4_RSS_HASH_TOP;
+		netdev_rss_key_fill(rss_context->rss_key,
+				    MLX4_EN_RSS_KEY_SIZE);
+	} else {
+		en_err(priv, "Unknown RSS hash function requested\n");
+		err = -EINVAL;
+		goto indir_err;
+	}
 	err = mlx4_qp_to_ready(mdev->dev, &priv->res.mtt, &context,
 			       &rss_map->indir_qp, &rss_map->indir_state);
 	if (err)
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index de45674..f08c34c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -376,7 +376,6 @@ struct mlx4_en_port_profile {
 };
 
 struct mlx4_en_profile {
-	int rss_xor;
 	int udp_rss;
 	u8 rss_mask;
 	u32 active_ports;
@@ -618,6 +617,7 @@ struct mlx4_en_priv {
 	__be16 vxlan_port;
 
 	u32 pflags;
+	u8 rss_hash_fn;
 };
 
 enum mlx4_en_wol {
-- 
1.8.3.4
