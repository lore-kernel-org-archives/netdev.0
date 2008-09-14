From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/5] mv643xx_eth: avoid dropping tx lock during transmit reclaim
Date: Sun, 14 Sep 2008 19:13:45 +0200
Message-ID: <20080914171345.GC28798@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:39727 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbYINRNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 13:13:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By moving DMA unmapping during transmit reclaim back under the netif
tx lock, we avoid the situation where we read the DMA address and buffer
length from the descriptor under the lock and then not do anything with
that data after dropping the lock on platforms where the DMA unmapping
routines are all NOPs (which is the case on all ARM platforms that
mv643xx_eth is used on at least).

This saves two uncached reads, which makes a small but measurable
performance difference in routing benchmarks.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   22 +++++++---------------
 1 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index d653b5a..7410eca 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -866,8 +866,6 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		struct tx_desc *desc;
 		u32 cmd_sts;
 		struct sk_buff *skb;
-		dma_addr_t addr;
-		int count;
 
 		tx_index = txq->tx_used_desc;
 		desc = &txq->tx_desc_area[tx_index];
@@ -886,8 +884,6 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		reclaimed++;
 		txq->tx_desc_count--;
 
-		addr = desc->buf_ptr;
-		count = desc->byte_cnt;
 		skb = txq->tx_skb[tx_index];
 		txq->tx_skb[tx_index] = NULL;
 
@@ -896,20 +892,16 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 			mp->dev->stats.tx_errors++;
 		}
 
-		/*
-		 * Drop tx queue lock while we free the skb.
-		 */
-		__netif_tx_unlock(nq);
-
-		if (cmd_sts & TX_FIRST_DESC)
-			dma_unmap_single(NULL, addr, count, DMA_TO_DEVICE);
-		else
-			dma_unmap_page(NULL, addr, count, DMA_TO_DEVICE);
+		if (cmd_sts & TX_FIRST_DESC) {
+			dma_unmap_single(NULL, desc->buf_ptr,
+					 desc->byte_cnt, DMA_TO_DEVICE);
+		} else {
+			dma_unmap_page(NULL, desc->buf_ptr,
+				       desc->byte_cnt, DMA_TO_DEVICE);
+		}
 
 		if (skb)
 			dev_kfree_skb(skb);
-
-		__netif_tx_lock(nq, smp_processor_id());
 	}
 
 	__netif_tx_unlock(nq);
-- 
1.5.6.4
