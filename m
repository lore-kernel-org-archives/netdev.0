From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 3/6 V2] mlx4_en: Checksum counters per ring
Date: Tue, 18 Oct 2011 13:50:56 +0200
Message-ID: <4E9D6820.8010207@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:43382 "HELO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757945Ab1JRN7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 09:59:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Not updating common counters from data path.
The checksum counters are per ring, summarizing them when collecting statistics.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_port.c |    6 ++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |    2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    3 +++
 4 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
index 9d27555..03c84cd 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_port.c
@@ -214,15 +214,21 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset)
 
 	stats->rx_packets = 0;
 	stats->rx_bytes = 0;
+	priv->port_stats.rx_chksum_good = 0;
+	priv->port_stats.rx_chksum_none = 0;
 	for (i = 0; i < priv->rx_ring_num; i++) {
 		stats->rx_packets += priv->rx_ring[i].packets;
 		stats->rx_bytes += priv->rx_ring[i].bytes;
+		priv->port_stats.rx_chksum_good += priv->rx_ring[i].csum_ok;
+		priv->port_stats.rx_chksum_none += priv->rx_ring[i].csum_none;
 	}
 	stats->tx_packets = 0;
 	stats->tx_bytes = 0;
+	priv->port_stats.tx_chksum_offload = 0;
 	for (i = 0; i < priv->tx_ring_num; i++) {
 		stats->tx_packets += priv->tx_ring[i].packets;
 		stats->tx_bytes += priv->tx_ring[i].bytes;
+		priv->port_stats.tx_chksum_offload += priv->tx_ring[i].tx_csum;
 	}
 
 	stats->rx_errors = be64_to_cpu(mlx4_en_stats->PCS) +
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index fbf1dcf..1231b21 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -587,7 +587,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		if (likely(dev->features & NETIF_F_RXCSUM)) {
 			if ((cqe->status & cpu_to_be16(MLX4_CQE_STATUS_IPOK)) &&
 			    (cqe->checksum == cpu_to_be16(0xffff))) {
-				priv->port_stats.rx_chksum_good++;
+				ring->csum_ok++;
 				/* This packet is eligible for LRO if it is:
 				 * - DIX Ethernet (type interpretation)
 				 * - TCP/IP (v4)
@@ -627,11 +627,11 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 				ip_summed = CHECKSUM_UNNECESSARY;
 			} else {
 				ip_summed = CHECKSUM_NONE;
-				priv->port_stats.rx_chksum_none++;
+				ring->csum_none++;
 			}
 		} else {
 			ip_summed = CHECKSUM_NONE;
-			priv->port_stats.rx_chksum_none++;
+			ring->csum_none++;
 		}
 
 		skb = mlx4_en_rx_skb(priv, rx_desc, skb_frags,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 6e03de0..f199460 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -695,7 +695,7 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
 		tx_desc->ctrl.srcrb_flags |= cpu_to_be32(MLX4_WQE_CTRL_IP_CSUM |
 							 MLX4_WQE_CTRL_TCP_UDP_CSUM);
-		priv->port_stats.tx_chksum_offload++;
+		ring->tx_csum++;
 	}
 
 	if (unlikely(priv->validate_loopback)) {
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 3b753f7..a6b5cf6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -249,6 +249,7 @@ struct mlx4_en_tx_ring {
 	struct mlx4_srq dummy;
 	unsigned long bytes;
 	unsigned long packets;
+	unsigned long tx_csum;
 	spinlock_t comp_lock;
 	struct mlx4_bf bf;
 	bool bf_enabled;
@@ -275,6 +276,8 @@ struct mlx4_en_rx_ring {
 	void *rx_info;
 	unsigned long bytes;
 	unsigned long packets;
+	unsigned long csum_ok;
+	unsigned long csum_none;
 };
 
 
-- 
1.7.7
