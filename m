From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH 6/8] net: mv643xx_eth: Limit the TSO segments and adjust stop/wake thresholds
Date: Fri, 30 May 2014 13:40:09 -0300
Message-ID: <1401468011-10609-7-git-send-email-ezequiel.garcia@free-electrons.com>
References: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Tawfik Bayouk <tawfik@marvell.com>, fugang.duan@freescale.com,
	Willy Tarreau <w@1wt.eu>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:58450 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933867AbaE3Ql0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 12:41:26 -0400
In-Reply-To: <1401468011-10609-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently small MSS values may require too many TSO descriptors for
the default queue size. This commit prevents this situation by fixing
the maximum supported TSO number of segments to 100 and by setting a
minimum Tx queue size. The minimum Tx queue size is set so that at
least 2 worst-case skb can be accommodated.

In addition, the queue stop and wake thresholds values are adjusted
accordingly. The queue is stopped when there's room for only 1 worst-case
skb and waked when the number of descriptors is half that value.

Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 63 ++++++++++++++++++++----------
 1 file changed, 42 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 97a60de..2cea86d 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -185,6 +185,10 @@ static char mv643xx_eth_driver_version[] = "1.4";
 
 #define TSO_HEADER_SIZE		128
 
+/* Max number of allowed TCP segments for software TSO */
+#define MV643XX_MAX_TSO_SEGS 100
+#define MV643XX_MAX_SKB_DESCS (MV643XX_MAX_TSO_SEGS * 2 + MAX_SKB_FRAGS)
+
 /*
  * RX/TX descriptors.
  */
@@ -348,6 +352,9 @@ struct tx_queue {
 	int tx_curr_desc;
 	int tx_used_desc;
 
+	int tx_stop_threshold;
+	int tx_wake_threshold;
+
 	char *tso_hdrs;
 	dma_addr_t tso_hdrs_dma;
 
@@ -497,7 +504,7 @@ static void txq_maybe_wake(struct tx_queue *txq)
 
 	if (netif_tx_queue_stopped(nq)) {
 		__netif_tx_lock(nq, smp_processor_id());
-		if (txq->tx_ring_size - txq->tx_desc_count >= MAX_SKB_FRAGS + 1)
+		if (txq->tx_desc_count <= txq->tx_wake_threshold)
 			netif_tx_wake_queue(nq);
 		__netif_tx_unlock(nq);
 	}
@@ -897,7 +904,8 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 	}
 }
 
-static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
+static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb,
+			  struct net_device *dev)
 {
 	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 	int nr_frags = skb_shinfo(skb)->nr_frags;
@@ -910,11 +918,15 @@ static int txq_submit_skb(struct tx_queue *txq, struct sk_buff *skb)
 	cmd_sts = 0;
 	l4i_chk = 0;
 
+	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
+		if (net_ratelimit())
+			netdev_err(dev, "tx queue full?!\n");
+		return -EBUSY;
+	}
+
 	ret = skb_tx_csum(mp, skb, &l4i_chk, &cmd_sts, skb->len);
-	if (ret) {
-		dev_kfree_skb_any(skb);
+	if (ret)
 		return ret;
-	}
 	cmd_sts |= TX_FIRST_DESC | GEN_CRC | BUFFER_OWNED_BY_DMA;
 
 	tx_index = txq->tx_curr_desc++;
@@ -972,28 +984,17 @@ static netdev_tx_t mv643xx_eth_xmit(struct sk_buff *skb, struct net_device *dev)
 		return NETDEV_TX_BUSY;
 	}
 
-	if (txq->tx_ring_size - txq->tx_desc_count < MAX_SKB_FRAGS + 1) {
-		if (net_ratelimit())
-			netdev_err(dev, "tx queue full?!\n");
-		txq->tx_dropped++;
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-
 	length = skb->len;
 
 	if (skb_is_gso(skb))
 		ret = txq_submit_tso(txq, skb, dev);
 	else
-		ret = txq_submit_skb(txq, skb);
+		ret = txq_submit_skb(txq, skb, dev);
 	if (!ret) {
-		int entries_left;
-
 		txq->tx_bytes += length;
 		txq->tx_packets++;
 
-		entries_left = txq->tx_ring_size - txq->tx_desc_count;
-		if (entries_left < MAX_SKB_FRAGS + 1)
+		if (txq->tx_desc_count >= txq->tx_stop_threshold)
 			netif_tx_stop_queue(nq);
 	} else if (ret == -EBUSY) {
 		return NETDEV_TX_BUSY;
@@ -1617,7 +1618,11 @@ mv643xx_eth_set_ringparam(struct net_device *dev, struct ethtool_ringparam *er)
 		return -EINVAL;
 
 	mp->rx_ring_size = er->rx_pending < 4096 ? er->rx_pending : 4096;
-	mp->tx_ring_size = er->tx_pending < 4096 ? er->tx_pending : 4096;
+	mp->tx_ring_size = clamp_t(unsigned int, er->tx_pending,
+				   MV643XX_MAX_SKB_DESCS * 2, 4096);
+	if (mp->tx_ring_size != er->tx_pending)
+		netdev_warn(dev, "TX queue size set to %u (requested %u)\n",
+			    mp->tx_ring_size, er->tx_pending);
 
 	if (netif_running(dev)) {
 		mv643xx_eth_stop(dev);
@@ -1993,6 +1998,13 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 
 	txq->tx_ring_size = mp->tx_ring_size;
 
+	/* A queue must always have room for at least one skb.
+	 * Therefore, stop the queue when the free entries reaches
+	 * the maximum number of descriptors per skb.
+	 */
+	txq->tx_stop_threshold = txq->tx_ring_size - MV643XX_MAX_SKB_DESCS;
+	txq->tx_wake_threshold = txq->tx_stop_threshold / 2;
+
 	txq->tx_desc_count = 0;
 	txq->tx_curr_desc = 0;
 	txq->tx_used_desc = 0;
@@ -2852,6 +2864,7 @@ static void set_params(struct mv643xx_eth_private *mp,
 		       struct mv643xx_eth_platform_data *pd)
 {
 	struct net_device *dev = mp->dev;
+	unsigned int tx_ring_size;
 
 	if (is_valid_ether_addr(pd->mac_addr))
 		memcpy(dev->dev_addr, pd->mac_addr, ETH_ALEN);
@@ -2866,9 +2879,16 @@ static void set_params(struct mv643xx_eth_private *mp,
 
 	mp->rxq_count = pd->rx_queue_count ? : 1;
 
-	mp->tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
+	tx_ring_size = DEFAULT_TX_QUEUE_SIZE;
 	if (pd->tx_queue_size)
-		mp->tx_ring_size = pd->tx_queue_size;
+		tx_ring_size = pd->tx_queue_size;
+
+	mp->tx_ring_size = clamp_t(unsigned int, tx_ring_size,
+				   MV643XX_MAX_SKB_DESCS * 2, 4096);
+	if (mp->tx_ring_size != tx_ring_size)
+		netdev_warn(dev, "TX queue size set to %u (requested %u)\n",
+			    mp->tx_ring_size, tx_ring_size);
+
 	mp->tx_desc_sram_addr = pd->tx_sram_addr;
 	mp->tx_desc_sram_size = pd->tx_sram_size;
 
@@ -3095,6 +3115,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	dev->hw_features = dev->features;
 
 	dev->priv_flags |= IFF_UNICAST_FLT;
+	dev->gso_max_segs = MV643XX_MAX_TSO_SEGS;
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-- 
1.9.1
