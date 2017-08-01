From: "Jianming.qiao" <jqiaoulk@gmail.com>
Subject: [PATCH v6 net-next] net: systemport: Support 64bit statistics
Date: Tue,  1 Aug 2017 02:18:13 +0100
Message-ID: <1501550293-20443-1-git-send-email-jqiaoulk@gmail.com>
To: f.fainelli@gmail.com, davem@davemloft.net, eric.dumazet@gmail.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33060 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbdHABSn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 21:18:43 -0400
Received: by mail-wr0-f196.google.com with SMTP id y43so174263wrd.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 18:18:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using Broadcom Systemport device in 32bit Platform, ifconfig can
only report up to 4G tx,rx status, which will be wrapped to 0 when the
number of incoming or outgoing packets exceeds 4G, only taking
around 2 hours in busy network environment (such as streaming).
Therefore, it makes hard for network diagnostic tool to get reliable
statistical result, so the patch is used to add 64bit support for
Broadcom Systemport device in 32bit Platform.

Signed-off-by: Jianming.qiao <kiki-good@hotmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 68 ++++++++++++++++++++----------
 drivers/net/ethernet/broadcom/bcmsysport.h |  9 +++-
 2 files changed, 52 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 5333601..bb3cc7a 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -662,6 +662,7 @@ static int bcm_sysport_alloc_rx_bufs(struct bcm_sysport_priv *priv)
 static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 					unsigned int budget)
 {
+	struct bcm_sysport_stats *stats64 = &priv->stats64;
 	struct net_device *ndev = priv->netdev;
 	unsigned int processed = 0, to_process;
 	struct bcm_sysport_cb *cb;
@@ -765,6 +766,10 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 		skb->protocol = eth_type_trans(skb, ndev);
 		ndev->stats.rx_packets++;
 		ndev->stats.rx_bytes += len;
+		u64_stats_update_begin(&stats64->syncp);
+		stats64->rx_packets++;
+		stats64->rx_bytes += len;
+		u64_stats_update_end(&stats64->syncp);
 
 		napi_gro_receive(&priv->napi, skb);
 next:
@@ -787,17 +792,15 @@ static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_tx_ring *ring,
 	struct device *kdev = &priv->pdev->dev;
 
 	if (cb->skb) {
-		ring->bytes += cb->skb->len;
 		*bytes_compl += cb->skb->len;
 		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
 				 dma_unmap_len(cb, dma_len),
 				 DMA_TO_DEVICE);
-		ring->packets++;
 		(*pkts_compl)++;
 		bcm_sysport_free_cb(cb);
 	/* SKB fragment */
 	} else if (dma_unmap_addr(cb, dma_addr)) {
-		ring->bytes += dma_unmap_len(cb, dma_len);
+		*bytes_compl += dma_unmap_len(cb, dma_len);
 		dma_unmap_page(kdev, dma_unmap_addr(cb, dma_addr),
 			       dma_unmap_len(cb, dma_len), DMA_TO_DEVICE);
 		dma_unmap_addr_set(cb, dma_addr, 0);
@@ -808,9 +811,10 @@ static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_tx_ring *ring,
 static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 					     struct bcm_sysport_tx_ring *ring)
 {
-	struct net_device *ndev = priv->netdev;
 	unsigned int c_index, last_c_index, last_tx_cn, num_tx_cbs;
+	struct bcm_sysport_stats *stats64 = &priv->stats64;
 	unsigned int pkts_compl = 0, bytes_compl = 0;
+	struct net_device *ndev = priv->netdev;
 	struct bcm_sysport_cb *cb;
 	u32 hw_ind;
 
@@ -849,6 +853,11 @@ static unsigned int __bcm_sysport_tx_reclaim(struct bcm_sysport_priv *priv,
 		last_c_index &= (num_tx_cbs - 1);
 	}
 
+	u64_stats_update_begin(&stats64->syncp);
+	ring->packets += pkts_compl;
+	ring->bytes += bytes_compl;
+	u64_stats_update_end(&stats64->syncp);
+
 	ring->c_index = c_index;
 
 	netif_dbg(priv, tx_done, ndev,
@@ -1671,24 +1680,6 @@ static int bcm_sysport_change_mac(struct net_device *dev, void *p)
 	return 0;
 }
 
-static struct net_device_stats *bcm_sysport_get_nstats(struct net_device *dev)
-{
-	struct bcm_sysport_priv *priv = netdev_priv(dev);
-	unsigned long tx_bytes = 0, tx_packets = 0;
-	struct bcm_sysport_tx_ring *ring;
-	unsigned int q;
-
-	for (q = 0; q < dev->num_tx_queues; q++) {
-		ring = &priv->tx_rings[q];
-		tx_bytes += ring->bytes;
-		tx_packets += ring->packets;
-	}
-
-	dev->stats.tx_bytes = tx_bytes;
-	dev->stats.tx_packets = tx_packets;
-	return &dev->stats;
-}
-
 static void bcm_sysport_netif_start(struct net_device *dev)
 {
 	struct bcm_sysport_priv *priv = netdev_priv(dev);
@@ -1923,6 +1914,37 @@ static int bcm_sysport_stop(struct net_device *dev)
 	return 0;
 }
 
+static void bcm_sysport_get_stats64(struct net_device *dev,
+				    struct rtnl_link_stats64 *stats)
+{
+	struct bcm_sysport_priv *priv = netdev_priv(dev);
+	struct bcm_sysport_stats *stats64 = &priv->stats64;
+	struct bcm_sysport_tx_ring *ring;
+	u64 tx_packets = 0, tx_bytes = 0;
+	unsigned int start;
+	unsigned int q;
+
+	netdev_stats_to_stats64(stats, &dev->stats);
+
+	for (q = 0; q < dev->num_tx_queues; q++) {
+		ring = &priv->tx_rings[q];
+		do {
+			start = u64_stats_fetch_begin_irq(&stats64->syncp);
+			tx_bytes = ring->bytes;
+			tx_packets = ring->packets;
+		} while (u64_stats_fetch_retry_irq(&stats64->syncp, start));
+
+		stats->tx_bytes += tx_bytes;
+		stats->tx_packets += tx_packets;
+	}
+
+	do {
+		start = u64_stats_fetch_begin_irq(&stats64->syncp);
+		stats->rx_packets = stats64->rx_packets;
+		stats->rx_bytes = stats64->rx_bytes;
+	} while (u64_stats_fetch_retry_irq(&stats64->syncp, start));
+}
+
 static const struct ethtool_ops bcm_sysport_ethtool_ops = {
 	.get_drvinfo		= bcm_sysport_get_drvinfo,
 	.get_msglevel		= bcm_sysport_get_msglvl,
@@ -1950,7 +1972,7 @@ static int bcm_sysport_stop(struct net_device *dev)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= bcm_sysport_poll_controller,
 #endif
-	.ndo_get_stats		= bcm_sysport_get_nstats,
+	.ndo_get_stats64	= bcm_sysport_get_stats64,
 };
 
 #define REV_FMT	"v%2x.%02x"
diff --git a/drivers/net/ethernet/broadcom/bcmsysport.h b/drivers/net/ethernet/broadcom/bcmsysport.h
index 77a51c1..c03a176 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.h
+++ b/drivers/net/ethernet/broadcom/bcmsysport.h
@@ -657,6 +657,9 @@ struct bcm_sysport_stats {
 	enum bcm_sysport_stat_type type;
 	/* reg offset from UMAC base for misc counters */
 	u16 reg_offset;
+	u64     rx_packets;
+	u64     rx_bytes;
+	struct u64_stats_sync   syncp;
 };
 
 /* Software house keeping helper structure */
@@ -693,8 +696,8 @@ struct bcm_sysport_tx_ring {
 	struct bcm_sysport_cb *cbs;	/* Transmit control blocks */
 	struct dma_desc	*desc_cpu;	/* CPU view of the descriptor */
 	struct bcm_sysport_priv *priv;	/* private context backpointer */
-	unsigned long	packets;	/* packets statistics */
-	unsigned long	bytes;		/* bytes statistics */
+	u64	packets;		/* packets statistics */
+	u64	bytes;			/* bytes statistics */
 };
 
 /* Driver private structure */
@@ -743,5 +746,7 @@ struct bcm_sysport_priv {
 
 	/* Ethtool */
 	u32			msg_enable;
+	/* 64bit stats on 32bit/64bit Machine */
+	struct bcm_sysport_stats stats64;
 };
 #endif /* __BCM_SYSPORT_H */
-- 
1.9.1
