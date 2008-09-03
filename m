From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/2] mv643xx_eth: hook up skb recycling
Date: Wed,  3 Sep 2008 15:55:01 +0200
Message-ID: <1220450101-21317-3-git-send-email-buytenh@wantstofly.org>
References: <1220450101-21317-1-git-send-email-buytenh@wantstofly.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:58001 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752833AbYICNzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 09:55:05 -0400
In-Reply-To: <1220450101-21317-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This increases the maximum loss-free packet forwarding rate in
routing workloads by typically about 25%.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   65 ++++++++++++++++++++++++++++++--------------
 1 files changed, 44 insertions(+), 21 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 67451e6..d513a04 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -362,6 +362,9 @@ struct mv643xx_eth_private {
 	u8 work_rx_refill;
 	u8 work_rx_oom;
 
+	int skb_size;
+	struct sk_buff_head rx_recycle;
+
 	/*
 	 * RX state.
 	 */
@@ -558,31 +561,19 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 static int rxq_refill(struct rx_queue *rxq, int budget)
 {
 	struct mv643xx_eth_private *mp = rxq_to_mp(rxq);
-	int skb_size;
 	int refilled;
 
-	/*
-	 * Reserve 2+14 bytes for an ethernet header (the hardware
-	 * automatically prepends 2 bytes of dummy data to each
-	 * received packet), 16 bytes for up to four VLAN tags, and
-	 * 4 bytes for the trailing FCS -- 36 bytes total.
-	 */
-	skb_size = rxq_to_mp(rxq)->dev->mtu + 36;
-
-	/*
-	 * Make sure that the skb size is a multiple of 8 bytes, as
-	 * the lower three bits of the receive descriptor's buffer
-	 * size field are ignored by the hardware.
-	 */
-	skb_size = (skb_size + 7) & ~7;
-
 	refilled = 0;
 	while (refilled < budget && rxq->rx_desc_count < rxq->rx_ring_size) {
 		struct sk_buff *skb;
 		int unaligned;
 		int rx;
 
-		skb = dev_alloc_skb(skb_size + dma_get_cache_alignment() - 1);
+		skb = __skb_dequeue(&mp->rx_recycle);
+		if (skb == NULL)
+			skb = dev_alloc_skb(mp->skb_size +
+					    dma_get_cache_alignment() - 1);
+
 		if (skb == NULL) {
 			mp->work_rx_oom |= 1 << rxq->index;
 			goto oom;
@@ -600,8 +591,8 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 			rxq->rx_used_desc = 0;
 
 		rxq->rx_desc_area[rx].buf_ptr = dma_map_single(NULL, skb->data,
-						skb_size, DMA_FROM_DEVICE);
-		rxq->rx_desc_area[rx].buf_size = skb_size;
+						mp->skb_size, DMA_FROM_DEVICE);
+		rxq->rx_desc_area[rx].buf_size = mp->skb_size;
 		rxq->rx_skb[rx] = skb;
 		wmb();
 		rxq->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
@@ -905,8 +896,13 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		else
 			dma_unmap_page(NULL, addr, count, DMA_TO_DEVICE);
 
-		if (skb)
-			dev_kfree_skb(skb);
+		if (skb != NULL) {
+			if (skb_queue_len(&mp->rx_recycle) < 1000 &&
+			    skb_recycle_check(skb, mp->skb_size))
+				__skb_queue_tail(&mp->rx_recycle, skb);
+			else
+				dev_kfree_skb(skb);
+		}
 
 		__netif_tx_lock(nq, smp_processor_id());
 	}
@@ -2042,6 +2038,26 @@ static void set_tx_coal(struct mv643xx_eth_private *mp, unsigned int delay)
 	wrl(mp, TX_FIFO_URGENT_THRESHOLD(mp->port_num), (coal & 0x3fff) << 4);
 }
 
+static void mv643xx_eth_recalc_skb_size(struct mv643xx_eth_private *mp)
+{
+	int skb_size;
+
+	/*
+	 * Reserve 2+14 bytes for an ethernet header (the hardware
+	 * automatically prepends 2 bytes of dummy data to each
+	 * received packet), 16 bytes for up to four VLAN tags, and
+	 * 4 bytes for the trailing FCS -- 36 bytes total.
+	 */
+	skb_size = mp->dev->mtu + 36;
+
+	/*
+	 * Make sure that the skb size is a multiple of 8 bytes, as
+	 * the lower three bits of the receive descriptor's buffer
+	 * size field are ignored by the hardware.
+	 */
+	mp->skb_size = (skb_size + 7) & ~7;
+}
+
 static int mv643xx_eth_open(struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
@@ -2061,8 +2077,12 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	init_mac_tables(mp);
 
+	mv643xx_eth_recalc_skb_size(mp);
+
 	napi_enable(&mp->napi);
 
+	skb_queue_head_init(&mp->rx_recycle);
+
 	for (i = 0; i < mp->rxq_count; i++) {
 		err = rxq_init(mp, i);
 		if (err) {
@@ -2156,6 +2176,8 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	mv643xx_eth_get_stats(dev);
 	mib_counters_update(mp);
 
+	skb_queue_purge(&mp->rx_recycle);
+
 	for (i = 0; i < mp->rxq_count; i++)
 		rxq_deinit(mp->rxq + i);
 	for (i = 0; i < mp->txq_count; i++)
@@ -2182,6 +2204,7 @@ static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
+	mv643xx_eth_recalc_skb_size(mp);
 	tx_set_rate(mp, 1000000000, 16777216);
 
 	if (!netif_running(dev))
-- 
1.5.6.4

