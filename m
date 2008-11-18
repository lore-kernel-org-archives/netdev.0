From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 6/6] mv643xx_eth: calculate descriptor pointer only once in rxq_refill()
Date: Tue, 18 Nov 2008 23:30:29 +0100
Message-ID: <20081118223028.GX5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:38090 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbYKRWaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 17:30:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index d56724a..b56fdf0 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -593,6 +593,7 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 		struct sk_buff *skb;
 		int unaligned;
 		int rx;
+		struct rx_desc *rx_desc;
 
 		skb = __skb_dequeue(&mp->rx_recycle);
 		if (skb == NULL)
@@ -615,13 +616,14 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 		if (rxq->rx_used_desc == rxq->rx_ring_size)
 			rxq->rx_used_desc = 0;
 
-		rxq->rx_desc_area[rx].buf_ptr = dma_map_single(NULL, skb->data,
-						mp->skb_size, DMA_FROM_DEVICE);
-		rxq->rx_desc_area[rx].buf_size = mp->skb_size;
+		rx_desc = rxq->rx_desc_area + rx;
+
+		rx_desc->buf_ptr = dma_map_single(NULL, skb->data,
+					mp->skb_size, DMA_FROM_DEVICE);
+		rx_desc->buf_size = mp->skb_size;
 		rxq->rx_skb[rx] = skb;
 		wmb();
-		rxq->rx_desc_area[rx].cmd_sts = BUFFER_OWNED_BY_DMA |
-						RX_ENABLE_INTERRUPT;
+		rx_desc->cmd_sts = BUFFER_OWNED_BY_DMA | RX_ENABLE_INTERRUPT;
 		wmb();
 
 		/*
-- 
1.5.6.4
