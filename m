From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net-next 09/14] net: sunbmac: Use net_device_stats from struct net_device
Date: Fri,  7 Apr 2017 10:17:34 +0200
Message-ID: <20170407081739.5243-10-tklauser@distanz.ch>
References: <20170407081739.5243-1-tklauser@distanz.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:34532 "EHLO mail.zhinst.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755346AbdDGIRq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 04:17:46 -0400
In-Reply-To: <20170407081739.5243-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using a private copy of struct net_device_stats in struct
bigmac, use stats from struct net_device.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/sun/sunbmac.c | 18 +++++++++---------
 drivers/net/ethernet/sun/sunbmac.h |  1 -
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index c4caf486cbef..3189722110c2 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -169,7 +169,7 @@ static void bigmac_stop(struct bigmac *bp)
 
 static void bigmac_get_counters(struct bigmac *bp, void __iomem *bregs)
 {
-	struct net_device_stats *stats = &bp->enet_stats;
+	struct net_device_stats *stats = &bp->dev->stats;
 
 	stats->rx_crc_errors += sbus_readl(bregs + BMAC_RCRCECTR);
 	sbus_writel(0, bregs + BMAC_RCRCECTR);
@@ -774,8 +774,8 @@ static void bigmac_tx(struct bigmac *bp)
 		if (this->tx_flags & TXD_OWN)
 			break;
 		skb = bp->tx_skbs[elem];
-		bp->enet_stats.tx_packets++;
-		bp->enet_stats.tx_bytes += skb->len;
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += skb->len;
 		dma_unmap_single(&bp->bigmac_op->dev,
 				 this->tx_addr, skb->len,
 				 DMA_TO_DEVICE);
@@ -811,12 +811,12 @@ static void bigmac_rx(struct bigmac *bp)
 
 		/* Check for errors. */
 		if (len < ETH_ZLEN) {
-			bp->enet_stats.rx_errors++;
-			bp->enet_stats.rx_length_errors++;
+			bp->dev->stats.rx_errors++;
+			bp->dev->stats.rx_length_errors++;
 
 	drop_it:
 			/* Return it to the BigMAC. */
-			bp->enet_stats.rx_dropped++;
+			bp->dev->stats.rx_dropped++;
 			this->rx_flags =
 				(RXD_OWN | ((RX_BUF_ALLOC_SIZE - 34) & RXD_LENGTH));
 			goto next;
@@ -875,8 +875,8 @@ static void bigmac_rx(struct bigmac *bp)
 		/* No checksums done by the BigMAC ;-( */
 		skb->protocol = eth_type_trans(skb, bp->dev);
 		netif_rx(skb);
-		bp->enet_stats.rx_packets++;
-		bp->enet_stats.rx_bytes += len;
+		bp->dev->stats.rx_packets++;
+		bp->dev->stats.rx_bytes += len;
 	next:
 		elem = NEXT_RX(elem);
 		this = &rxbase[elem];
@@ -987,7 +987,7 @@ static struct net_device_stats *bigmac_get_stats(struct net_device *dev)
 	struct bigmac *bp = netdev_priv(dev);
 
 	bigmac_get_counters(bp, bp->bregs);
-	return &bp->enet_stats;
+	return &dev->stats;
 }
 
 static void bigmac_set_multicast(struct net_device *dev)
diff --git a/drivers/net/ethernet/sun/sunbmac.h b/drivers/net/ethernet/sun/sunbmac.h
index 532fc56830cf..ee56930475a8 100644
--- a/drivers/net/ethernet/sun/sunbmac.h
+++ b/drivers/net/ethernet/sun/sunbmac.h
@@ -311,7 +311,6 @@ struct bigmac {
 	enum bigmac_timer_state	timer_state;
 	unsigned int		timer_ticks;
 
-	struct net_device_stats	enet_stats;
 	struct platform_device	*qec_op;
 	struct platform_device	*bigmac_op;
 	struct net_device	*dev;
-- 
2.12.2
