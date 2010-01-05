From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] mv643xx_eth: don't include cache padding in rx desc buffer size
Date: Tue, 5 Jan 2010 20:15:32 +0100
Message-ID: <20100105191532.GU1735@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:36812 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224Ab0AETPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 14:15:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Bishara <saeed@marvell.com>

If NET_SKB_PAD is not a multiple of the cache line size, mv643xx_eth 
allocates a couple of extra bytes at the start of each receive buffer
to make the data payload end up on a cache line boundary.

These extra bytes are skb_reserve()'d before DMA mapping, so they
should not be included in the DMA map byte count (as the mapping is
done starting at skb->data), nor should they be included in the
receive descriptor buffer size field, or the hardware can end up
DMAing beyond the end of the buffer, which can happen if someone
sends us a larger-than-MTU sized packet.

This problem was introduced in commit 7fd96ce47ff ("mv643xx_eth:
rework receive skb cache alignment", May 6 2009), but hasn't appeared
to be problematic so far, probably as the main users of mv643xx_eth
all have NET_SKB_PAD == L1_CACHE_BYTES.

Signed-off-by: Saeed Bishara <saeed@marvell.com>
Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1405a17..af67af5 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -656,6 +656,7 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 		struct sk_buff *skb;
 		int rx;
 		struct rx_desc *rx_desc;
+		int size;
 
 		skb = __skb_dequeue(&mp->rx_recycle);
 		if (skb == NULL)
@@ -678,10 +679,11 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 
 		rx_desc = rxq->rx_desc_area + rx;
 
+		size = skb->end - skb->data;
 		rx_desc->buf_ptr = dma_map_single(mp->dev->dev.parent,
-						  skb->data, mp->skb_size,
+						  skb->data, size,
 						  DMA_FROM_DEVICE);
-		rx_desc->buf_size = mp->skb_size;
+		rx_desc->buf_size = size;
 		rxq->rx_skb[rx] = skb;
 		wmb();
 		rx_desc->cmd_sts = BUFFER_OWNED_BY_DMA | RX_ENABLE_INTERRUPT;
