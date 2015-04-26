From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net 2/2] net/mlx4_en: Prevent setting invalid RSS hash function
Date: Sun, 26 Apr 2015 17:36:06 +0300
Message-ID: <1430058966-24046-3-git-send-email-amirv@mellanox.com>
References: <1430058966-24046-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:51018 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752235AbbDZOgy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Apr 2015 10:36:54 -0400
In-Reply-To: <1430058966-24046-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mlx4_en_check_rxfh_func() was checking for hardware support before
setting a known RSS hash function, but didn't do any check before
setting unknown RSS hash function. Need to make it fail on such values.
In this occasion, moved the actual setting of the new value from the
check function into mlx4_en_set_rxfh().

Fixes: 947cbb0 ("net/mlx4_en: Support for configurable RSS hash function")
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 29 ++++++++++++++-----------
 1 file changed, 16 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 3f44e2b..a2ddf3d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1102,20 +1102,21 @@ static int mlx4_en_check_rxfh_func(struct net_device *dev, u8 hfunc)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 
 	/* check if requested function is supported by the device */
-	if ((hfunc == ETH_RSS_HASH_TOP &&
-	     !(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RSS_TOP)) ||
-	    (hfunc == ETH_RSS_HASH_XOR &&
-	     !(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RSS_XOR)))
-		return -EINVAL;
+	if (hfunc == ETH_RSS_HASH_TOP) {
+		if (!(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RSS_TOP))
+			return -EINVAL;
+		if (!(dev->features & NETIF_F_RXHASH))
+			en_warn(priv, "Toeplitz hash function should be used in conjunction with RX hashing for optimal performance\n");
+		return 0;
+	} else if (hfunc == ETH_RSS_HASH_XOR) {
+		if (!(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RSS_XOR))
+			return -EINVAL;
+		if (dev->features & NETIF_F_RXHASH)
+			en_warn(priv, "Enabling both XOR Hash function and RX Hashing can limit RPS functionality\n");
+		return 0;
+	}
 
-	priv->rss_hash_fn = hfunc;
-	if (hfunc == ETH_RSS_HASH_TOP && !(dev->features & NETIF_F_RXHASH))
-		en_warn(priv,
-			"Toeplitz hash function should be used in conjunction with RX hashing for optimal performance\n");
-	if (hfunc == ETH_RSS_HASH_XOR && (dev->features & NETIF_F_RXHASH))
-		en_warn(priv,
-			"Enabling both XOR Hash function and RX Hashing can limit RPS functionality\n");
-	return 0;
+	return -EINVAL;
 }
 
 static int mlx4_en_get_rxfh(struct net_device *dev, u32 *ring_index, u8 *key,
@@ -1189,6 +1190,8 @@ static int mlx4_en_set_rxfh(struct net_device *dev, const u32 *ring_index,
 		priv->prof->rss_rings = rss_rings;
 	if (key)
 		memcpy(priv->rss_key, key, MLX4_EN_RSS_KEY_SIZE);
+	if (hfunc !=  ETH_RSS_HASH_NO_CHANGE)
+		priv->rss_hash_fn = hfunc;
 
 	if (port_up) {
 		err = mlx4_en_start_port(dev);
-- 
1.9.3
