From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V3 2/2] net/mlx4_en: Support for configurable RSS hash function
Date: Tue,  2 Dec 2014 18:12:11 +0200
Message-ID: <1417536731-11211-3-git-send-email-amirv@mellanox.com>
References: <1417536731-11211-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50724 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932249AbaLBQMY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2014 11:12:24 -0500
In-Reply-To: <1417536731-11211-1-git-send-email-amirv@mellanox.com>
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
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 34 +++++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 11 ++++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 14 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  2 +-
 4 files changed, 54 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 28c3fc5..90e0f04 100644
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
@@ -999,7 +1020,7 @@ static int mlx4_en_get_rxfh(struct net_device *dev, u32 *ring_index, u8 *key,
 	if (key)
 		memcpy(key, priv->rss_key, MLX4_EN_RSS_KEY_SIZE);
 	if (hfunc)
-		*hfunc = ETH_RSS_HASH_TOP;
+		*hfunc = priv->rss_hash_fn;
 	return err;
 }
 
@@ -1013,10 +1034,6 @@ static int mlx4_en_set_rxfh(struct net_device *dev, const u32 *ring_index,
 	int i;
 	int rss_rings = 0;
 
-	/* We do not allow change in unsupported parameters */
-	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
-		return -EOPNOTSUPP;
-
 	/* Calculate RSS table size and make sure flows are spread evenly
 	 * between rings
 	 */
@@ -1037,6 +1054,12 @@ static int mlx4_en_set_rxfh(struct net_device *dev, const u32 *ring_index,
 	if (!is_power_of_2(rss_rings))
 		return -EINVAL;
 
+	if (hfunc != ETH_RSS_HASH_NO_CHANGE) {
+		err = mlx4_en_check_rxfh_func(dev, hfunc);
+		if (err)
+			return err;
+	}
+
 	mutex_lock(&mdev->state_lock);
 	if (priv->port_up) {
 		port_up = 1;
@@ -1047,6 +1070,7 @@ static int mlx4_en_set_rxfh(struct net_device *dev, const u32 *ring_index,
 		priv->prof->rss_rings = rss_rings;
 	if (key)
 		memcpy(priv->rss_key, key, MLX4_EN_RSS_KEY_SIZE);
+
 	if (port_up) {
 		err = mlx4_en_start_port(dev);
 		if (err)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b7c9978..dcc0d3d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2608,6 +2608,17 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
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
index 946d352..4ca396e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1223,7 +1223,19 @@ int mlx4_en_config_rss_steer(struct mlx4_en_priv *priv)
 
 	rss_context->flags = rss_mask;
 	rss_context->hash_fn = MLX4_RSS_HASH_TOP;
-	memcpy(rss_context->rss_key, priv->rss_key, MLX4_EN_RSS_KEY_SIZE);
+	if (priv->rss_hash_fn == ETH_RSS_HASH_XOR) {
+		rss_context->hash_fn = MLX4_RSS_HASH_XOR;
+	} else if (priv->rss_hash_fn == ETH_RSS_HASH_TOP) {
+		rss_context->hash_fn = MLX4_RSS_HASH_TOP;
+		memcpy(rss_context->rss_key, priv->rss_key,
+		       MLX4_EN_RSS_KEY_SIZE);
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
index aaa7efb..ac48a8d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -376,7 +376,6 @@ struct mlx4_en_port_profile {
 };
 
 struct mlx4_en_profile {
-	int rss_xor;
 	int udp_rss;
 	u8 rss_mask;
 	u32 active_ports;
@@ -619,6 +618,7 @@ struct mlx4_en_priv {
 
 	u32 pflags;
 	u8 rss_key[MLX4_EN_RSS_KEY_SIZE];
+	u8 rss_hash_fn;
 };
 
 enum mlx4_en_wol {
-- 
1.8.3.4
