From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V3 3/3] net/mlx4_en: Add ethtool statistics for XDP cases
Date: Wed,  2 Nov 2016 17:12:25 +0200
Message-ID: <1478099545-24181-4-git-send-email-tariqt@mellanox.com>
References: <1478099545-24181-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44220 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753225AbcKBPMf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:12:35 -0400
In-Reply-To: <1478099545-24181-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XDP statistics are reported in ethtool, in total and per ring,
as follows:
- xdp_drop: the number of packets dropped by xdp.
- xdp_tx: the number of packets forwarded by xdp.
- xdp_tx_full: the number of times an xdp forward failed
	due to a full tx xdp ring.

In addition, all packets that are dropped/forwarded by XDP
are no longer accounted in rx_packets/rx_bytes of the ring,
so that they count traffic that is passed to the stack.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 25 ++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  4 ++++
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |  6 ++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 12 +++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |  8 ++++----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  7 ++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h | 10 +++++++++-
 7 files changed, 60 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index e8ccb95680bc..487a58f9c192 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -195,6 +195,10 @@ static int mlx4_en_moderation_update(struct mlx4_en_priv *priv)
 	"tx_prio_7_packets", "tx_prio_7_bytes",
 	"tx_novlan_packets", "tx_novlan_bytes",
 
+	/* xdp statistics */
+	"rx_xdp_drop",
+	"rx_xdp_tx",
+	"rx_xdp_tx_full",
 };
 
 static const char mlx4_en_test_names[][ETH_GSTRING_LEN]= {
@@ -340,7 +344,7 @@ static int mlx4_en_get_sset_count(struct net_device *dev, int sset)
 	case ETH_SS_STATS:
 		return bitmap_iterator_count(&it) +
 			(priv->tx_ring_num[TX] * 2) +
-			(priv->rx_ring_num * 3);
+			(priv->rx_ring_num * (3 + NUM_XDP_STATS));
 	case ETH_SS_TEST:
 		return MLX4_EN_NUM_SELF_TEST - !(priv->mdev->dev->caps.flags
 					& MLX4_DEV_CAP_FLAG_UC_LOOPBACK) * 2;
@@ -400,6 +404,10 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 		if (bitmap_iterator_test(&it))
 			data[index++] = ((unsigned long *)&priv->pkstats)[i];
 
+	for (i = 0; i < NUM_XDP_STATS; i++, bitmap_iterator_inc(&it))
+		if (bitmap_iterator_test(&it))
+			data[index++] = ((unsigned long *)&priv->xdp_stats)[i];
+
 	for (i = 0; i < priv->tx_ring_num[TX]; i++) {
 		data[index++] = priv->tx_ring[TX][i]->packets;
 		data[index++] = priv->tx_ring[TX][i]->bytes;
@@ -408,6 +416,9 @@ static void mlx4_en_get_ethtool_stats(struct net_device *dev,
 		data[index++] = priv->rx_ring[i]->packets;
 		data[index++] = priv->rx_ring[i]->bytes;
 		data[index++] = priv->rx_ring[i]->dropped;
+		data[index++] = priv->rx_ring[i]->xdp_drop;
+		data[index++] = priv->rx_ring[i]->xdp_tx;
+		data[index++] = priv->rx_ring[i]->xdp_tx_full;
 	}
 	spin_unlock_bh(&priv->stats_lock);
 
@@ -470,6 +481,12 @@ static void mlx4_en_get_strings(struct net_device *dev,
 				strcpy(data + (index++) * ETH_GSTRING_LEN,
 				       main_strings[strings]);
 
+		for (i = 0; i < NUM_XDP_STATS; i++, strings++,
+		     bitmap_iterator_inc(&it))
+			if (bitmap_iterator_test(&it))
+				strcpy(data + (index++) * ETH_GSTRING_LEN,
+				       main_strings[strings]);
+
 		for (i = 0; i < priv->tx_ring_num[TX]; i++) {
 			sprintf(data + (index++) * ETH_GSTRING_LEN,
 				"tx%d_packets", i);
@@ -483,6 +500,12 @@ static void mlx4_en_get_strings(struct net_device *dev,
 				"rx%d_bytes", i);
 			sprintf(data + (index++) * ETH_GSTRING_LEN,
 				"rx%d_dropped", i);
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"rx%d_xdp_drop", i);
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"rx%d_xdp_tx", i);
+			sprintf(data + (index++) * ETH_GSTRING_LEN,
+				"rx%d_xdp_tx_full", i);
 		}
 		break;
 	case ETH_SS_PRIV_FLAGS:
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index edf0a99177e1..0f6225c042be 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -3125,6 +3125,10 @@ void mlx4_en_set_stats_bitmap(struct mlx4_dev *dev,
 
 	if (!mlx4_is_slave(dev))
 		bitmap_set(stats_bitmap->bitmap, last_i, NUM_PKT_STATS);
+	last_i += NUM_PKT_STATS;
+
+	bitmap_set(stats_bitmap->bitmap, last_i, NUM_XDP_STATS);
+	last_i += NUM_XDP_STATS;
 }
 
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 2e1ab4642569..1eb4c1e10bad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -179,6 +179,9 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 	priv->port_stats.rx_chksum_good = 0;
 	priv->port_stats.rx_chksum_none = 0;
 	priv->port_stats.rx_chksum_complete = 0;
+	priv->xdp_stats.rx_xdp_drop    = 0;
+	priv->xdp_stats.rx_xdp_tx      = 0;
+	priv->xdp_stats.rx_xdp_tx_full = 0;
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		stats->rx_packets += priv->rx_ring[i]->packets;
 		stats->rx_bytes += priv->rx_ring[i]->bytes;
@@ -186,6 +189,9 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 		priv->port_stats.rx_chksum_good += priv->rx_ring[i]->csum_ok;
 		priv->port_stats.rx_chksum_none += priv->rx_ring[i]->csum_none;
 		priv->port_stats.rx_chksum_complete += priv->rx_ring[i]->csum_complete;
+		priv->xdp_stats.rx_xdp_drop    += priv->rx_ring[i]->xdp_drop;
+		priv->xdp_stats.rx_xdp_tx      += priv->rx_ring[i]->xdp_tx;
+		priv->xdp_stats.rx_xdp_tx_full += priv->rx_ring[i]->xdp_tx_full;
 	}
 	stats->tx_packets = 0;
 	stats->tx_bytes = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 71196f68b55d..2cc91002064f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -875,8 +875,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		 */
 		length = be32_to_cpu(cqe->byte_cnt);
 		length -= ring->fcs_del;
-		ring->bytes += length;
-		ring->packets++;
 		l2_tunnel = (dev->hw_enc_features & NETIF_F_RXCSUM) &&
 			(cqe->vlan_my_qpn & cpu_to_be32(MLX4_CQE_L2_TUNNEL));
 
@@ -902,22 +900,26 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			case XDP_PASS:
 				break;
 			case XDP_TX:
-				if (likely(!mlx4_en_xmit_frame(frags, dev,
+				if (likely(!mlx4_en_xmit_frame(ring, frags, dev,
 							length, cq->ring,
 							&doorbell_pending)))
 					goto consumed;
-				goto xdp_drop; /* Drop on xmit failure */
+				goto xdp_drop_no_cnt; /* Drop on xmit failure */
 			default:
 				bpf_warn_invalid_xdp_action(act);
 			case XDP_ABORTED:
 			case XDP_DROP:
-xdp_drop:
+				ring->xdp_drop++;
+xdp_drop_no_cnt:
 				if (likely(mlx4_en_rx_recycle(ring, frags)))
 					goto consumed;
 				goto next;
 			}
 		}
 
+		ring->bytes += length;
+		ring->packets++;
+
 		if (likely(dev->features & NETIF_F_RXCSUM)) {
 			if (cqe->status & cpu_to_be16(MLX4_CQE_STATUS_TCP |
 						      MLX4_CQE_STATUS_UDP)) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 95dc864bb2f7..5de3cbe24f2b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -1079,7 +1079,8 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	return NETDEV_TX_OK;
 }
 
-netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_alloc *frame,
+netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
+			       struct mlx4_en_rx_alloc *frame,
 			       struct net_device *dev, unsigned int length,
 			       int tx_ind, int *doorbell_pending)
 {
@@ -1154,8 +1155,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_alloc *frame,
 		((ring->prod & ring->size) ?
 		 cpu_to_be32(MLX4_EN_BIT_DESC_OWN) : 0);
 
-	ring->packets++;
-	ring->bytes += tx_info->nr_bytes;
+	rx_ring->xdp_tx++;
 	AVG_PERF_COUNTER(priv->pstats.tx_pktsz_avg, length);
 
 	ring->prod += nr_txbb;
@@ -1179,7 +1179,7 @@ netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_alloc *frame,
 	return NETDEV_TX_OK;
 
 tx_drop_count:
-	ring->tx_dropped++;
+	rx_ring->xdp_tx_full++;
 tx_drop:
 	return NETDEV_TX_BUSY;
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 6e0693659f85..eff21651b673 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -350,6 +350,9 @@ struct mlx4_en_rx_ring {
 	unsigned long csum_ok;
 	unsigned long csum_none;
 	unsigned long csum_complete;
+	unsigned long xdp_drop;
+	unsigned long xdp_tx;
+	unsigned long xdp_tx_full;
 	unsigned long dropped;
 	int hwtstamp_rx_filter;
 	cpumask_var_t affinity_mask;
@@ -599,6 +602,7 @@ struct mlx4_en_priv {
 	struct mlx4_en_flow_stats_rx rx_flowstats;
 	struct mlx4_en_flow_stats_tx tx_flowstats;
 	struct mlx4_en_port_stats port_stats;
+	struct mlx4_en_xdp_stats xdp_stats;
 	struct mlx4_en_stats_bitmap stats_bitmap;
 	struct list_head mc_list;
 	struct list_head curr_list;
@@ -687,7 +691,8 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
 			 void *accel_priv, select_queue_fallback_t fallback);
 netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev);
-netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_alloc *frame,
+netdev_tx_t mlx4_en_xmit_frame(struct mlx4_en_rx_ring *rx_ring,
+			       struct mlx4_en_rx_alloc *frame,
 			       struct net_device *dev, unsigned int length,
 			       int tx_ind, int *doorbell_pending);
 void mlx4_en_xmit_doorbell(struct mlx4_en_tx_ring *ring);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
index 7fd466c0b929..48641cb0367f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h
@@ -55,6 +55,13 @@ struct mlx4_en_perf_stats {
 #define NUM_PERF_COUNTERS		6
 };
 
+struct mlx4_en_xdp_stats {
+	unsigned long rx_xdp_drop;
+	unsigned long rx_xdp_tx;
+	unsigned long rx_xdp_tx_full;
+#define NUM_XDP_STATS		3
+};
+
 #define NUM_MAIN_STATS	21
 
 #define MLX4_NUM_PRIORITIES	8
@@ -107,7 +114,8 @@ enum {
 };
 
 #define NUM_ALL_STATS	(NUM_MAIN_STATS + NUM_PORT_STATS + NUM_PKT_STATS + \
-			 NUM_FLOW_STATS + NUM_PERF_STATS + NUM_PF_STATS)
+			 NUM_FLOW_STATS + NUM_PERF_STATS + NUM_PF_STATS + \
+			 NUM_XDP_STATS)
 
 #define MLX4_FIND_NETDEV_STAT(n) (offsetof(struct net_device_stats, n) / \
 				  sizeof(((struct net_device_stats *)0)->n))
-- 
1.8.3.1
