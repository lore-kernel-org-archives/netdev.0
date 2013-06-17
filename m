From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/2] net/mlx4_en: Low Latency recv statistics
Date: Mon, 17 Jun 2013 13:58:23 +0300
Message-ID: <1371466703-3370-3-git-send-email-amirv@mellanox.com>
References: <1371466703-3370-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, eliezer.tamir@linux.intel.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38620 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932620Ab3FQK6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jun 2013 06:58:50 -0400
In-Reply-To: <1371466703-3370-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 20 +++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  9 +++++++++
 2 files changed, 28 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index c9e6b62..a9e6987 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -222,7 +222,12 @@ static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
 	switch (sset) {
 	case ETH_SS_STATS:
 		return (priv->stats_bitmap ? bit_count : NUM_ALL_STATS) +
-			(priv->tx_ring_num + priv->rx_ring_num) * 2;
+			(priv->tx_ring_num * 2) +
+#ifdef LL_EXTENDED_STATS
+			(priv->rx_ring_num * 5);
+#else
+			(priv->rx_ring_num * 2);
+#endif
 	case ETH_SS_TEST:
 		return MLX4_EN_NUM_SELF_TEST - !(priv->mdev->dev->caps.flags
 					& MLX4_DEV_CAP_FLAG_UC_LOOPBACK) * 2;
@@ -271,6 +276,11 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		data[index++] = priv->rx_ring[i].packets;
 		data[index++] = priv->rx_ring[i].bytes;
+#ifdef LL_EXTENDED_STATS
+		data[index++] = priv->rx_ring[i].yields;
+		data[index++] = priv->rx_ring[i].misses;
+		data[index++] = priv->rx_ring[i].cleaned;
+#endif
 	}
 	spin_unlock_bh(&priv->stats_lock);
 
@@ -334,6 +344,14 @@ static void mlx4_en_get_strings(struct net_device *dev,
 				"rx%d_packets", i);
 			sprintf(data + (index++) * ETH_GSTRING_LEN,
 				"rx%d_bytes", i);
+#ifdef LL_EXTENDED_STATS
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"rx%d_napi_yield", i);
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"rx%d_misses", i);
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"rx%d_cleaned", i);
+#endif
 		}
 		break;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index ab3dad5..0127b47 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -84,6 +84,10 @@
 #define MLX4_EN_FILTER_HASH_SHIFT 4
 #define MLX4_EN_FILTER_EXPIRY_QUOTA 60
 
+#ifdef CONFIG_NET_LL_RX_POLL
+#define LL_EXTENDED_STATS
+#endif
+
 /* Typical TSO descriptor with 16 gather entries is 352 bytes... */
 #define MAX_DESC_SIZE		512
 #define MAX_DESC_TXBBS		(MAX_DESC_SIZE / TXBB_SIZE)
@@ -290,6 +294,11 @@ struct mlx4_en_rx_ring {
 	void *rx_info;
 	unsigned long bytes;
 	unsigned long packets;
+#ifdef LL_EXTENDED_STATS
+	unsigned long yields;
+	unsigned long misses;
+	unsigned long cleaned;
+#endif
 	unsigned long csum_ok;
 	unsigned long csum_none;
 	int hwtstamp_rx_filter;
-- 
1.8.3.251.g1462b67
