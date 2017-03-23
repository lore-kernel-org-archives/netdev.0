From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/3] net: systemport: Track per TX ring statistics
Date: Thu, 23 Mar 2017 10:36:46 -0700
Message-ID: <20170323173648.21143-2-f.fainelli@gmail.com>
References: <20170323173648.21143-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, opendmb@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33469 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752529AbdCWRh7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 13:37:59 -0400
Received: by mail-wm0-f68.google.com with SMTP id n11so583544wma.0
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 10:37:58 -0700 (PDT)
In-Reply-To: <20170323173648.21143-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bcm_sysport_tx_reclaim_one() is currently summing TX bytes/packets in a
way that is not SMP friendly, mutliples CPUs could run
bcm_sysport_tx_reclaim_one() independently and still update
stats->tx_bytes and stats->tx_packets, cloberring the other CPUs
statistics.

Fix this by tracking per TX rings the number of bytes, packets,
dropped and errors statistics, and provide a bcm_sysport_get_nstats()
function which aggregates everything and returns a consistent output.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 65 ++++++++++++++++++++++++++----
 drivers/net/ethernet/broadcom/bcmsysport.h |  5 +++
 2 files changed, 63 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index a68d4889f5db..986fb05529fc 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -284,6 +284,7 @@ static const struct bcm_sysport_stats bcm_sysport_gstrings_stats[] = {
 	STAT_MIB_SOFT("alloc_rx_buff_failed", mib.alloc_rx_buff_failed),
 	STAT_MIB_SOFT("rx_dma_failed", mib.rx_dma_failed),
 	STAT_MIB_SOFT("tx_dma_failed", mib.tx_dma_failed),
+	/* Per TX-queue statistics are dynamically appended */
 };
 
 #define BCM_SYSPORT_STATS_LEN	ARRAY_SIZE(bcm_sysport_gstrings_stats)
@@ -338,7 +339,8 @@ static int bcm_sysport_get_sset_count(struct net_device *dev, int string_set)
 				continue;
 			j++;
 		}
-		return j;
+		/* Include per-queue statistics */
+		return j + dev->num_tx_queues * NUM_SYSPORT_TXQ_STAT;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -349,6 +351,7 @@ static void bcm_sysport_get_strings(struct net_device *dev,
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
 	const struct bcm_sysport_stats *s;
+	char buf[128];
 	int i, j;
 
 	switch (stringset) {
@@ -363,6 +366,18 @@ static void bcm_sysport_get_strings(struct net_device *dev,
 			       ETH_GSTRING_LEN);
 			j++;
 		}
+
+		for (i = 0; i < dev->num_tx_queues; i++) {
+			snprintf(buf, sizeof(buf), "txq%d_packets", i);
+			memcpy(data + j * ETH_GSTRING_LEN, buf,
+			       ETH_GSTRING_LEN);
+			j++;
+
+			snprintf(buf, sizeof(buf), "txq%d_bytes", i);
+			memcpy(data + j * ETH_GSTRING_LEN, buf,
+			       ETH_GSTRING_LEN);
+			j++;
+		}
 		break;
 	default:
 		break;
@@ -418,6 +433,7 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 				  struct ethtool_stats *stats, u64 *data)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	struct bcm_sysport_tx_ring *ring;
 	int i, j;
 
 	if (netif_running(dev))
@@ -436,6 +452,22 @@ static void bcm_sysport_get_stats(struct net_device *dev,
 		data[j] = *(unsigned long *)p;
 		j++;
 	}
+
+	/* For SYSTEMPORT Lite since we have holes in our statistics, j would
+	 * be equal to BCM_SYSPORT_STATS_LEN at the end of the loop, but it
+	 * needs to point to how many total statistics we have minus the
+	 * number of per TX queue statistics
+	 */
+	j = bcm_sysport_get_sset_count(dev, ETH_SS_STATS) -
+	    dev->num_tx_queues * NUM_SYSPORT_TXQ_STAT;
+
+	for (i = 0; i < dev->num_tx_queues; i++) {
+		ring = &priv->tx_rings[i];
+		data[j] = ring->packets;
+		j++;
+		data[j] = ring->bytes;
+		j++;
+	}
 }
 
 static void bcm_sysport_get_wol(struct net_device *dev,
@@ -746,26 +778,26 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 	return processed;
 }
 
-static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_priv *priv,
+static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_tx_ring *ring,
 				       struct bcm_sysport_cb *cb,
 				       unsigned int *bytes_compl,
 				       unsigned int *pkts_compl)
 {
+	struct bcm_sysport_priv *priv = ring->priv;
 	struct device *kdev = &priv->pdev->dev;
-	struct net_device *ndev = priv->netdev;
 
 	if (cb->skb) {
-		ndev->stats.tx_bytes += cb->skb->len;
+		ring->bytes += cb->skb->len;
 		*bytes_compl += cb->skb->len;
 		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
 				 dma_unmap_len(cb, dma_len),
 				 DMA_TO_DEVICE);
-		ndev->stats.tx_packets++;
+		ring->packets++;
 		(*pkts_compl)++;
 		bcm_sysport_free_cb(cb);
 	/* SKB fragment */
 	} else if (dma_unmap_addr(cb, dma_addr)) {
-		ndev->stats.tx_bytes += dma_unmap_len(cb, dma_len);
+		ring->bytes += dma_unmap_len(cb, dma_len);
 		dma_unmap_page(kdev, dma_unmap_addr(cb, dma_addr),
 			       dma_unmap_len(cb, dma_len), DMA_TO_DEVICE);
 		dma_unmap_addr_set(cb, dma_addr, 0);
@@ -803,7 +835,7 @@ static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 
 	while (last_tx_cn-- > 0) {
 		cb = ring->cbs + last_c_index;
-		bcm_sysport_tx_reclaim_one(priv, cb, &bytes_compl, &pkts_compl);
+		bcm_sysport_tx_reclaim_one(ring, cb, &bytes_compl, &pkts_compl);
 
 		ring->desc_count++;
 		last_c_index++;
@@ -1632,6 +1664,24 @@ static int bcm_sysport_change_mac(struct net_device *dev, void *p)
 	return 0;
 }
 
+static struct net_device_stats *bcm_sysport_get_nstats(struct net_device *dev)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	unsigned long tx_bytes = 0, tx_packets = 0;
+	struct bcm_sysport_tx_ring *ring;
+	unsigned int q;
+
+	for (q = 0; q < dev->num_tx_queues; q++) {
+		ring = &priv->tx_rings[q];
+		tx_bytes += ring->bytes;
+		tx_packets += ring->packets;
+	}
+
+	dev->stats.tx_bytes = tx_bytes;
+	dev->stats.tx_packets = tx_packets;
+	return &dev->stats;
+}
+
 static void bcm_sysport_netif_start(struct net_device *dev)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
@@ -1893,6 +1943,7 @@ static const struct net_device_ops bcm_sysport_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= bcm_sysport_poll_controller,
 #endif
+	.ndo_get_stats		= bcm_sysport_get_nstats,
 };
 
 #define REV_FMT	"v%2x.%02x"
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index 863ddd7870b7..77a51c167a69 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -647,6 +647,9 @@ enum bcm_sysport_stat_type {
 	.reg_offset = ofs, \
 }
 
+/* TX bytes and packets */
+#define NUM_SYSPORT_TXQ_STAT	2
+
 struct bcm_sysport_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int stat_sizeof;
@@ -690,6 +693,8 @@ struct bcm_sysport_tx_ring {
 	struct bcm_sysport_cb *cbs;	/* Transmit control blocks */
 	struct dma_desc	*desc_cpu;	/* CPU view of the descriptor */
 	struct bcm_sysport_priv *priv;	/* private context backpointer */
+	unsigned long	packets;	/* packets statistics */
+	unsigned long	bytes;		/* bytes statistics */
 };
 
 /* Driver private structure */
-- 
2.9.3
