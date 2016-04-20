From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 4/4] net/mlx4_en: Split SW RX dropped counter per RX ring
Date: Wed, 20 Apr 2016 16:01:18 +0300
Message-ID: <1461157278-18528-5-git-send-email-ogerlitz@mellanox.com>
References: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51103 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751726AbcDTNCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 09:02:04 -0400
In-Reply-To: <1461157278-18528-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Ben Elisha <eranbe@mellanox.com>

Count SW packet drops per RX ring instead of a global counter. This
will allow monitoring the number of rx drops per ring.

In addition, SW rx_dropped counter was overwritten by HW rx_dropped
counter, sum both of them instead to show the accurate value.

Fixes: a3333b35da16 ('net/mlx4_en: Moderate ethtool callback to [...] ')
Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
Reported-by: Brenden Blanco <bblanco@plumgrid.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 5 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_port.c    | 5 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    | 1 +
 4 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index f69584a..c761194 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -337,7 +337,7 @@ static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
 	case ETH_SS_STATS:
 		return bitmap_iterator_count(&it) +
 			(priv->tx_ring_num * 2) +
-			(priv->rx_ring_num * 2);
+			(priv->rx_ring_num * 3);
 	case ETH_SS_TEST:
 		return MLX4_EN_NUM_SELF_TEST - !(priv->mdev->dev->caps.flags
 					& MLX4_DEV_CAP_FLAG_UC_LOOPBACK) * 2;
@@ -404,6 +404,7 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		data[index++] = priv->rx_ring[i]->packets;
 		data[index++] = priv->rx_ring[i]->bytes;
+		data[index++] = priv->rx_ring[i]->dropped;
 	}
 	spin_unlock_bh(&priv->stats_lock);
 
@@ -477,6 +478,8 @@ static void mlx4_en_get_strings(struct net_device *dev,
 				"rx%d_packets", i);
 			sprintf(data + (index++) * ETH_GSTRING_LEN,
 				"rx%d_bytes", i);
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"rx%d_dropped", i);
 		}
 		break;
 	case ETH_SS_PRIV_FLAGS:
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 3904b5f..20b6c2e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -158,6 +158,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	u64 in_mod = reset << 8 | port;
 	int err;
 	int i, counter_index;
+	unsigned long sw_rx_dropped = 0;
 
 	mailbox = mlx4_alloc_cmd_mailbox(mdev->dev);
 	if (IS_ERR(mailbox))
@@ -180,6 +181,7 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		stats->rx_packets += priv->rx_ring[i]->packets;
 		stats->rx_bytes += priv->rx_ring[i]->bytes;
+		sw_rx_dropped += priv->rx_ring[i]->dropped;
 		priv->port_stats.rx_chksum_good += priv->rx_ring[i]->csum_ok;
 		priv->port_stats.rx_chksum_none += priv->rx_ring[i]->csum_none;
 		priv->port_stats.rx_chksum_complete += priv->rx_ring[i]->csum_complete;
@@ -236,7 +238,8 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 					  &mlx4_en_stats->MCAST_prio_1,
 					  NUM_PRIORITIES);
 	stats->collisions = 0;
-	stats->rx_dropped = be32_to_cpu(mlx4_en_stats->RDROP);
+	stats->rx_dropped = be32_to_cpu(mlx4_en_stats->RDROP) +
+			    sw_rx_dropped;
 	stats->rx_length_errors = be32_to_cpu(mlx4_en_stats->RdropLength);
 	stats->rx_over_errors = 0;
 	stats->rx_crc_errors = be32_to_cpu(mlx4_en_stats->RCRC);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 86bcfe5..91abc13 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -939,7 +939,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		/* GRO not possible, complete processing here */
 		skb = mlx4_en_rx_skb(priv, rx_desc, frags, length);
 		if (!skb) {
-			priv->stats.rx_dropped++;
+			ring->dropped++;
 			goto next;
 		}
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index d12ab6a..63b1aea 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -323,6 +323,7 @@ struct mlx4_en_rx_ring {
 	unsigned long csum_ok;
 	unsigned long csum_none;
 	unsigned long csum_complete;
+	unsigned long dropped;
 	int hwtstamp_rx_filter;
 	cpumask_var_t affinity_mask;
 };
-- 
2.3.7
