From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCHv2 2/2] mv643xx_eth: hook up skb recycling
Date: Sun, 28 Sep 2008 22:47:12 +0200
Message-ID: <20080928204712.GC19070@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ram.Natarajan@Emulex.Com, Eric Dumazet <dada1@cosmosbay.com>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:38194 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752783AbYI1UrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2008 16:47:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This gives a nice increase in the maximum loss-free packet forwarding
rate in routing workloads.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   66 ++++++++++++++++++++++++++++++--------------
 1 files changed, 45 insertions(+), 21 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 55aa8ba..372811a 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -370,6 +370,9 @@ struct mv643xx_eth_private {
 	u8 work_rx_refill;
 	u8 work_rx_oom;
 
+	int skb_size;
+	struct sk_buff_head rx_recycle;
+
 	/*
 	 * RX state.
 	 */
@@ -566,31 +569,19 @@ static int rxq_process(struct rx_queue *rxq, int budget)
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
@@ -608,8 +599,8 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 			rxq->rx_used_desc = 0;
 
 		rxq->rx_desc_area[rx].buf_ptr = dma_map_single(NULL, skb->data,
-						skb_size, DMA_FROM_DEVICE);
-		rxq->rx_desc_area[rx].buf_size = skb_size;
+						mp->skb_size, DMA_FROM_DEVICE);
+		rxq->rx_desc_area[rx].buf_size = mp->skb_size;
 		rxq->rx_skb[rx] = skb;
 		wmb();
 		rxq->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
@@ -904,8 +895,14 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 				       desc->byte_cnt, DMA_TO_DEVICE);
 		}
 
-		if (skb)
-			dev_kfree_skb(skb);
+		if (skb != NULL) {
+			if (skb_queue_len(&mp->rx_recycle) <
+					mp->default_rx_ring_size &&
+			    skb_recycle_check(skb, mp->skb_size))
+				__skb_queue_head(&mp->rx_recycle, skb);
+			else
+				dev_kfree_skb(skb);
+		}
 	}
 
 	__netif_tx_unlock(nq);
@@ -2042,6 +2039,26 @@ static void set_tx_coal(struct mv643xx_eth_private *mp, unsigned int delay)
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
@@ -2061,8 +2078,12 @@ static int mv643xx_eth_open(struct net_device *dev)
 
 	init_mac_tables(mp);
 
+	mv643xx_eth_recalc_skb_size(mp);
+
 	napi_enable(&mp->napi);
 
+	skb_queue_head_init(&mp->rx_recycle);
+
 	for (i = 0; i < mp->rxq_count; i++) {
 		err = rxq_init(mp, i);
 		if (err) {
@@ -2158,6 +2179,8 @@ static int mv643xx_eth_stop(struct net_device *dev)
 	mv643xx_eth_get_stats(dev);
 	mib_counters_update(mp);
 
+	skb_queue_purge(&mp->rx_recycle);
+
 	for (i = 0; i < mp->rxq_count; i++)
 		rxq_deinit(mp->rxq + i);
 	for (i = 0; i < mp->txq_count; i++)
@@ -2184,6 +2207,7 @@ static int mv643xx_eth_change_mtu(struct net_device *dev, int new_mtu)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
+	mv643xx_eth_recalc_skb_size(mp);
 	tx_set_rate(mp, 1000000000, 16777216);
 
 	if (!netif_running(dev))
-- 
1.5.6.4
