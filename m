From: "Jianming.qiao" <jqiaoulk@gmail.com>
Subject: [PATCH v2 net-next] net: systemport: Support 64bit statistics
Date: Wed, 19 Jul 2017 01:18:40 +0100
Message-ID: <1500423520-4169-1-git-send-email-jqiaoulk@gmail.com>
To: f.fainelli@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33743 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751647AbdGSASx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 20:18:53 -0400
Received: by mail-wr0-f193.google.com with SMTP id y43so7150745wrd.0
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 17:18:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jianming.qiao <kiki-good@hotmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 52 +++++++++++++++++++++++++++---
 drivers/net/ethernet/broadcom/bcmsysport.h |  9 ++++--
 2 files changed, 55 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 5274501..56f8951 100644
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
@@ -784,24 +789,31 @@ static void bcm_sysport_tx_reclaim_one(struct bcm_sysport_tx_ring *ring,
 				       unsigned int *pkts_compl)
 {
 	struct bcm_sysport_priv *priv = ring->priv;
+	struct bcm_sysport_stats *stats64 = &priv->stats64;
 	struct device *kdev = &priv->pdev->dev;
+	unsigned int len = 0;
 
 	if (cb->skb) {
-		ring->bytes += cb->skb->len;
-		*bytes_compl += cb->skb->len;
+		len = cb->skb->len;
+		*bytes_compl += len;
 		dma_unmap_single(kdev, dma_unmap_addr(cb, dma_addr),
 				 dma_unmap_len(cb, dma_len),
 				 DMA_TO_DEVICE);
-		ring->packets++;
 		(*pkts_compl)++;
 		bcm_sysport_free_cb(cb);
 	/* SKB fragment */
 	} else if (dma_unmap_addr(cb, dma_addr)) {
-		ring->bytes += dma_unmap_len(cb, dma_len);
+		len = dma_unmap_len(cb, dma_len);
 		dma_unmap_page(kdev, dma_unmap_addr(cb, dma_addr),
 			       dma_unmap_len(cb, dma_len), DMA_TO_DEVICE);
 		dma_unmap_addr_set(cb, dma_addr, 0);
 	}
+
+	u64_stats_update_begin(&stats64->syncp);
+	ring->bytes += len;
+	if (cb->skb)
+		ring->packets++;
+	u64_stats_update_end(&stats64->syncp);
 }
 
 /* Reclaim queued SKBs for transmission completion, lockless version */
@@ -1923,6 +1935,37 @@ static int bcm_sysport_stop(struct net_device *dev)
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
+			tx_bytes += ring->bytes;
+			tx_packets += ring->packets;
+		} while (u64_stats_fetch_retry_irq(&stats64->syncp, start));
+	}
+
+	stats->tx_packets = tx_packets;
+	stats->tx_bytes = tx_bytes;
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
@@ -1951,6 +1994,7 @@ static int bcm_sysport_stop(struct net_device *dev)
 	.ndo_poll_controller	= bcm_sysport_poll_controller,
 #endif
 	.ndo_get_stats		= bcm_sysport_get_nstats,
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
