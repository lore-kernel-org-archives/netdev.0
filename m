From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: bcmgenet: Track per TX/RX rings statistics
Date: Thu, 16 Mar 2017 10:27:08 -0700
Message-ID: <20170316172708.32008-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com, pgynther@google.com,
        jaedon.shin@gmail.com, opendmb@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:34974 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752376AbdCPR3h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 13:29:37 -0400
Received: by mail-qk0-f196.google.com with SMTP id o135so6844989qke.2
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 10:29:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__bcmgenet_tx_reclaim() is currently summing TX bytes/packets in a way
that is not SMP friendly, mutliples CPUs could run
__bcmgenet_tx_reclaim() independently and still update stats->tx_bytes
and stats->tx_packets, cloberring the other CPUs statistics.

Fix this by tracking per RX and TX rings the number of bytes, packets,
dropped and errors statistics, and provide a bcmgenet_get_stats()
function which aggregates everything and returns a consistent output.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Eric,

The patch was originally from you, can you add your SoB to this if you
agree with that?

Thank you!

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 77 +++++++++++++++++++++++---
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  6 ++
 2 files changed, 75 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 44f9c0a1f85d..f493276d432a 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -707,6 +707,19 @@ struct bcmgenet_stats {
 	.reg_offset = offset, \
 }
 
+#define STAT_GENET_Q(num) \
+	STAT_GENET_SOFT_MIB("txq" __stringify(num) "_packets", \
+			tx_rings[num].packets), \
+	STAT_GENET_SOFT_MIB("txq" __stringify(num) "_bytes", \
+			tx_rings[num].bytes), \
+	STAT_GENET_SOFT_MIB("rxq" __stringify(num) "_bytes", \
+			rx_rings[num].bytes),	 \
+	STAT_GENET_SOFT_MIB("rxq" __stringify(num) "_packets", \
+			rx_rings[num].packets), \
+	STAT_GENET_SOFT_MIB("rxq" __stringify(num) "_errors", \
+			rx_rings[num].errors), \
+	STAT_GENET_SOFT_MIB("rxq" __stringify(num) "_dropped", \
+			rx_rings[num].dropped)
 
 /* There is a 0xC gap between the end of RX and beginning of TX stats and then
  * between the end of TX stats and the beginning of the RX RUNT
@@ -801,6 +814,12 @@ static const struct bcmgenet_stats bcmgenet_gstrings_stats[] = {
 	STAT_GENET_SOFT_MIB("alloc_rx_buff_failed", mib.alloc_rx_buff_failed),
 	STAT_GENET_SOFT_MIB("rx_dma_failed", mib.rx_dma_failed),
 	STAT_GENET_SOFT_MIB("tx_dma_failed", mib.tx_dma_failed),
+	/* Per TX queues */
+	STAT_GENET_Q(0),
+	STAT_GENET_Q(1),
+	STAT_GENET_Q(2),
+	STAT_GENET_Q(3),
+	STAT_GENET_Q(16),
 };
 
 #define BCMGENET_STATS_LEN	ARRAY_SIZE(bcmgenet_gstrings_stats)
@@ -1298,8 +1317,8 @@ static unsigned int __bcmgenet_tx_reclaim(struct net_device *dev,
 	ring->free_bds += txbds_processed;
 	ring->c_index = c_index;
 
-	dev->stats.tx_packets += pkts_compl;
-	dev->stats.tx_bytes += bytes_compl;
+	ring->packets += pkts_compl;
+	ring->bytes += bytes_compl;
 
 	netdev_tx_completed_queue(netdev_get_tx_queue(dev, ring->queue),
 				  pkts_compl, bytes_compl);
@@ -1694,8 +1713,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_rx_ring *ring,
 		   DMA_P_INDEX_DISCARD_CNT_MASK;
 	if (discards > ring->old_discards) {
 		discards = discards - ring->old_discards;
-		dev->stats.rx_missed_errors += discards;
-		dev->stats.rx_errors += discards;
+		ring->errors += discards;
 		ring->old_discards += discards;
 
 		/* Clear HW register when we reach 75% of maximum 0xFFFF */
@@ -1718,7 +1736,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_rx_ring *ring,
 		skb = bcmgenet_rx_refill(priv, cb);
 
 		if (unlikely(!skb)) {
-			dev->stats.rx_dropped++;
+			ring->dropped++;
 			goto next;
 		}
 
@@ -1746,7 +1764,7 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_rx_ring *ring,
 		if (unlikely(!(dma_flag & DMA_EOP) || !(dma_flag & DMA_SOP))) {
 			netif_err(priv, rx_status, dev,
 				  "dropping fragmented packet!\n");
-			dev->stats.rx_errors++;
+			ring->errors++;
 			dev_kfree_skb_any(skb);
 			goto next;
 		}
@@ -1795,8 +1813,8 @@ static unsigned int bcmgenet_desc_rx(struct bcmgenet_rx_ring *ring,
 
 		/*Finish setting up the received SKB and send it to the kernel*/
 		skb->protocol = eth_type_trans(skb, priv->dev);
-		dev->stats.rx_packets++;
-		dev->stats.rx_bytes += len;
+		ring->packets++;
+		ring->bytes += len;
 		if (dma_flag & DMA_RX_MULT)
 			dev->stats.multicast++;
 
@@ -3134,6 +3152,48 @@ static int bcmgenet_set_mac_addr(struct net_device *dev, void *p)
 	return 0;
 }
 
+static struct net_device_stats *bcmgenet_get_stats(struct net_device *dev)
+{
+	struct bcmgenet_priv *priv = netdev_priv(dev);
+	unsigned long tx_bytes = 0, tx_packets = 0;
+	unsigned long rx_bytes = 0, rx_packets = 0;
+	unsigned long rx_errors = 0, rx_dropped = 0;
+	struct bcmgenet_tx_ring *tx_ring;
+	struct bcmgenet_rx_ring *rx_ring;
+	unsigned int q;
+
+	for (q = 0; q < priv->hw_params->tx_queues; q++) {
+		tx_ring = &priv->tx_rings[q];
+		tx_bytes += tx_ring->bytes;
+		tx_packets += tx_ring->packets;
+	}
+	tx_ring = &priv->tx_rings[DESC_INDEX];
+	tx_bytes += tx_ring->bytes;
+	tx_packets += tx_ring->packets;
+
+	for (q = 0; q < priv->hw_params->rx_queues; q++) {
+		rx_ring = &priv->rx_rings[q];
+
+		rx_bytes += rx_ring->bytes;
+		rx_packets += rx_ring->packets;
+		rx_errors += rx_ring->errors;
+		rx_dropped += rx_ring->dropped;
+	}
+	rx_ring = &priv->rx_rings[DESC_INDEX];
+	rx_bytes += rx_ring->bytes;
+	rx_packets += rx_ring->packets;
+	rx_errors += rx_ring->errors;
+	rx_dropped += rx_ring->dropped;
+
+	dev->stats.tx_bytes = tx_bytes;
+	dev->stats.tx_packets = tx_packets;
+	dev->stats.rx_bytes = rx_bytes;
+	dev->stats.rx_packets = rx_packets;
+	dev->stats.rx_errors = rx_errors;
+	dev->stats.rx_missed_errors = rx_errors;
+	return &dev->stats;
+}
+
 static const struct net_device_ops bcmgenet_netdev_ops = {
 	.ndo_open		= bcmgenet_open,
 	.ndo_stop		= bcmgenet_close,
@@ -3146,6 +3206,7 @@ static const struct net_device_ops bcmgenet_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= bcmgenet_poll_controller,
 #endif
+	.ndo_get_stats		= bcmgenet_get_stats,
 };
 
 /* Array of GENET hardware parameters/characteristics */
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 5692c0582434..efd07020b89f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -552,6 +552,8 @@ struct bcmgenet_skb_cb {
 struct bcmgenet_tx_ring {
 	spinlock_t	lock;		/* ring lock */
 	struct napi_struct napi;	/* NAPI per tx queue */
+	unsigned long	packets;
+	unsigned long	bytes;
 	unsigned int	index;		/* ring index */
 	unsigned int	queue;		/* queue index */
 	struct enet_cb	*cbs;		/* tx ring buffer control block*/
@@ -570,6 +572,10 @@ struct bcmgenet_tx_ring {
 
 struct bcmgenet_rx_ring {
 	struct napi_struct napi;	/* Rx NAPI struct */
+	unsigned long	bytes;
+	unsigned long	packets;
+	unsigned long	errors;
+	unsigned long	dropped;
 	unsigned int	index;		/* Rx ring index */
 	struct enet_cb	*cbs;		/* Rx ring buffer control block */
 	unsigned int	size;		/* Rx ring size */
-- 
2.9.3
