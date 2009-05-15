From: Gabriel Paubert <paubert@iram.es>
Subject: [PATCH] mv643xx_eth: fix PPC DMA breakage
Date: Fri, 15 May 2009 20:39:24 +0200
Message-ID: <20090515183924.GA29279@iram.es>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tbm@cyrius.com, LinuxPPC <linuxppc-dev@ozlabs.org>, pacman@kosh.dhis.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

After 2.6.29, PPC no more admits passing NULL to the dev parameter of
the DMA API. The result is a BUG followed by solid lock-up when the 
mv643xx_eth driver brings an interface up. The following patch makes 
the driver work on my Pegasos again; it is mostly a search and replace 
of NULL by mp->dev->dev.parent in dma allocation/freeing/mapping/unmapping
functions.

Signed-off-by: Gabriel Paubert <paubert@iram.es>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index a400d71..6bb5af3 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -569,7 +569,7 @@ static int rxq_process(struct rx_queue *rxq, int budget)
 		if (rxq->rx_curr_desc == rxq->rx_ring_size)
 			rxq->rx_curr_desc = 0;
 
-		dma_unmap_single(NULL, rx_desc->buf_ptr,
+		dma_unmap_single(mp->dev->dev.parent, rx_desc->buf_ptr,
 				 rx_desc->buf_size, DMA_FROM_DEVICE);
 		rxq->rx_desc_count--;
 		rx++;
@@ -678,8 +678,9 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 
 		rx_desc = rxq->rx_desc_area + rx;
 
-		rx_desc->buf_ptr = dma_map_single(NULL, skb->data,
-					mp->skb_size, DMA_FROM_DEVICE);
+		rx_desc->buf_ptr = dma_map_single(mp->dev->dev.parent,
+						  skb->data, mp->skb_size,
+						  DMA_FROM_DEVICE);
 		rx_desc->buf_size = mp->skb_size;
 		rxq->rx_skb[rx] = skb;
 		wmb();
@@ -718,6 +719,7 @@ static inline unsigned int has_tiny_unaligned_frags(struct sk_buff *skb)
 
 static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 {
+	struct mv643xx_eth_private *mp = txq_to_mp(txq);
 	int nr_frags = skb_shinfo(skb)->nr_frags;
 	int frag;
 
@@ -746,10 +748,10 @@ static void txq_submit_frag_skb(struct tx_queue *txq, struct sk_buff *skb)
 
 		desc->l4i_chk = 0;
 		desc->byte_cnt = this_frag->size;
-		desc->buf_ptr = dma_map_page(NULL, this_frag->page,
-						this_frag->page_offset,
-						this_frag->size,
-						DMA_TO_DEVICE);
+		desc->buf_ptr = dma_map_page(mp->dev->dev.parent,
+					     this_frag->page,
+					     this_frag->page_offset,
+					     this_frag->size, DMA_TO_DEVICE);
 	}
 }
 
@@ -826,7 +828,8 @@ no_csum:
 
 	desc->l4i_chk = l4i_chk;
 	desc->byte_cnt = length;
-	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
+	desc->buf_ptr = dma_map_single(mp->dev->dev.parent, skb->data,
+				       length, DMA_TO_DEVICE);
 
 	__skb_queue_tail(&txq->tx_skb, skb);
 
@@ -956,10 +959,10 @@ static int txq_reclaim(struct tx_queue *txq, int budget, int force)
 		}
 
 		if (cmd_sts & TX_FIRST_DESC) {
-			dma_unmap_single(NULL, desc->buf_ptr,
+			dma_unmap_single(mp->dev->dev.parent, desc->buf_ptr,
 					 desc->byte_cnt, DMA_TO_DEVICE);
 		} else {
-			dma_unmap_page(NULL, desc->buf_ptr,
+			dma_unmap_page(mp->dev->dev.parent, desc->buf_ptr,
 				       desc->byte_cnt, DMA_TO_DEVICE);
 		}
 
@@ -1894,9 +1897,9 @@ static int rxq_init(struct mv643xx_eth_private *mp, int index)
 						mp->rx_desc_sram_size);
 		rxq->rx_desc_dma = mp->rx_desc_sram_addr;
 	} else {
-		rxq->rx_desc_area = dma_alloc_coherent(NULL, size,
-							&rxq->rx_desc_dma,
-							GFP_KERNEL);
+		rxq->rx_desc_area = dma_alloc_coherent(mp->dev->dev.parent,
+						       size, &rxq->rx_desc_dma,
+						       GFP_KERNEL);
 	}
 
 	if (rxq->rx_desc_area == NULL) {
@@ -1947,7 +1950,7 @@ out_free:
 	if (index == 0 && size <= mp->rx_desc_sram_size)
 		iounmap(rxq->rx_desc_area);
 	else
-		dma_free_coherent(NULL, size,
+		dma_free_coherent(mp->dev->dev.parent, size,
 				  rxq->rx_desc_area,
 				  rxq->rx_desc_dma);
 
@@ -1979,7 +1982,7 @@ static void rxq_deinit(struct rx_queue *rxq)
 	    rxq->rx_desc_area_size <= mp->rx_desc_sram_size)
 		iounmap(rxq->rx_desc_area);
 	else
-		dma_free_coherent(NULL, rxq->rx_desc_area_size,
+		dma_free_coherent(mp->dev->dev.parent, rxq->rx_desc_area_size,
 				  rxq->rx_desc_area, rxq->rx_desc_dma);
 
 	kfree(rxq->rx_skb);
@@ -2007,9 +2010,9 @@ static int txq_init(struct mv643xx_eth_private *mp, int index)
 						mp->tx_desc_sram_size);
 		txq->tx_desc_dma = mp->tx_desc_sram_addr;
 	} else {
-		txq->tx_desc_area = dma_alloc_coherent(NULL, size,
-							&txq->tx_desc_dma,
-							GFP_KERNEL);
+		txq->tx_desc_area = dma_alloc_coherent(mp->dev->dev.parent,
+						       size, &txq->tx_desc_dma,
+						       GFP_KERNEL);
 	}
 
 	if (txq->tx_desc_area == NULL) {
@@ -2053,7 +2056,7 @@ static void txq_deinit(struct tx_queue *txq)
 	    txq->tx_desc_area_size <= mp->tx_desc_sram_size)
 		iounmap(txq->tx_desc_area);
 	else
-		dma_free_coherent(NULL, txq->tx_desc_area_size,
+		dma_free_coherent(mp->dev->dev.parent, txq->tx_desc_area_size,
 				  txq->tx_desc_area, txq->tx_desc_dma);
 }
