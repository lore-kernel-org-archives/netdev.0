From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 2/2] net/mlx4_en: Low Latency recv statistics
Date: Tue, 18 Jun 2013 16:18:28 +0300
Message-ID: <1371561508-11960-3-git-send-email-amirv@mellanox.com>
References: <1371561508-11960-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:36196 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932160Ab3FRNSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jun 2013 09:18:45 -0400
In-Reply-To: <1371561508-11960-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 20 +++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  4 ++++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  6 ++++++
 3 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index c9e6b62..727874f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -222,7 +222,12 @@ static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
 	switch (sset) {
 	case ETH_SS_STATS:
 		return (priv->stats_bitmap ? bit_count : NUM_ALL_STATS) +
-			(priv->tx_ring_num + priv->rx_ring_num) * 2;
+			(priv->tx_ring_num * 2) +
+#ifdef CONFIG_NET_LL_RX_POLL
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
+#ifdef CONFIG_NET_LL_RX_POLL
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
+#ifdef CONFIG_NET_LL_RX_POLL
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
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index bb9847a..2b2f09c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -85,6 +85,10 @@ static int mlx4_en_low_latency_recv(struct napi_struct *napi)
 		return LL_FLUSH_BUSY;
 
 	done = mlx4_en_process_rx_cq(dev, cq, 4);
+	if (likely(done))
+		rx_ring->cleaned += done;
+	else
+		rx_ring->misses++;
 
 	mlx4_en_cq_unlock_poll(cq);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 11c862e..57192a8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -290,6 +290,11 @@ struct mlx4_en_rx_ring {
 	void *rx_info;
 	unsigned long bytes;
 	unsigned long packets;
+#ifdef CONFIG_NET_LL_RX_POLL
+	unsigned long yields;
+	unsigned long misses;
+	unsigned long cleaned;
+#endif
 	unsigned long csum_ok;
 	unsigned long csum_none;
 	int hwtstamp_rx_filter;
@@ -625,6 +630,7 @@ static inline bool mlx4_en_cq_lock_poll(struct mlx4_en_cq *cq)
 
 		cq->state |= MLX4_EN_CQ_STATE_POLL_YIELD;
 		rc = false;
+		rx_ring->yields++;
 	} else
 		/* preserve yield marks */
 		cq->state |= MLX4_EN_CQ_STATE_POLL;
-- 
1.8.3.251.g1462b67
