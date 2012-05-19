From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tg3: use netdev_alloc_frag() API
Date: Sat, 19 May 2012 09:15:49 +0200
Message-ID: <1337411749.7029.77.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:56172 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908Ab2ESHP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 03:15:58 -0400
Received: by wibhj8 with SMTP id hj8so790608wib.1
        for <netdev@vger.kernel.org>; Sat, 19 May 2012 00:15:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Update our reference driver to use netdev_alloc_frag() API instead of
the temporary custom allocator I introduced in commit 8d4057a938
(tg3: provide frags as skb head)

This removes the memory leak we had, since we could leak one page at
device dismantle.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Matt Carlson <mcarlson@broadcom.com>
Cc: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   38 +++-----------------------
 drivers/net/ethernet/broadcom/tg3.h |    2 -
 2 files changed, 5 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 4230e70..d55df32 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -195,15 +195,6 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 #define TG3_RX_OFFSET(tp)	(NET_SKB_PAD)
 #endif
 
-/* This driver uses the new build_skb() API providing a frag as skb->head
- * This strategy permits better GRO aggregation, better TCP coalescing, and
- * better splice() implementation (avoids a copy from head to a page), at
- * minimal memory cost.
- * In this 2048 bytes block, we have enough room to store the MTU=1500 frame
- * and the struct skb_shared_info.
- */
-#define TG3_FRAGSIZE 2048
-
 /* minimum number of free TX descriptors required to wake up TX process */
 #define TG3_TX_WAKEUP_THRESH(tnapi)		((tnapi)->tx_pending / 4)
 #define TG3_TX_BD_DMA_MAX_2K		2048
@@ -5631,25 +5622,6 @@ static void tg3_tx(struct tg3_napi *tnapi)
 	}
 }
 
-static void *tg3_frag_alloc(struct tg3_rx_prodring_set *tpr)
-{
-	void *data;
-
-	if (tpr->rx_page_size < TG3_FRAGSIZE) {
-		struct page *page = alloc_page(GFP_ATOMIC);
-
-		if (!page)
-			return NULL;
-		atomic_add((PAGE_SIZE / TG3_FRAGSIZE) - 1, &page->_count); 
-		tpr->rx_page_addr = page_address(page);
-		tpr->rx_page_size = PAGE_SIZE;
-	}
-	data = tpr->rx_page_addr;
-	tpr->rx_page_addr += TG3_FRAGSIZE;
-	tpr->rx_page_size -= TG3_FRAGSIZE;
-	return data;
-}
-
 static void tg3_frag_free(bool is_frag, void *data)
 {
 	if (is_frag)
@@ -5668,7 +5640,7 @@ static void tg3_rx_data_free(struct tg3 *tp, struct ring_info *ri, u32 map_sz)
 
 	pci_unmap_single(tp->pdev, dma_unmap_addr(ri, mapping),
 			 map_sz, PCI_DMA_FROMDEVICE);
-	tg3_frag_free(skb_size <= TG3_FRAGSIZE, ri->data);
+	tg3_frag_free(skb_size <= PAGE_SIZE, ri->data);
 	ri->data = NULL;
 }
 
@@ -5721,9 +5693,9 @@ static int tg3_alloc_rx_data(struct tg3 *tp, struct tg3_rx_prodring_set *tpr,
 	 */
 	skb_size = SKB_DATA_ALIGN(data_size + TG3_RX_OFFSET(tp)) +
 		   SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
-	if (skb_size <= TG3_FRAGSIZE) {
-		data = tg3_frag_alloc(tpr);
-		*frag_size = TG3_FRAGSIZE;
+	if (skb_size <= PAGE_SIZE) {
+		data = netdev_alloc_frag(skb_size);
+		*frag_size = skb_size;
 	} else {
 		data = kmalloc(skb_size, GFP_ATOMIC);
 		*frag_size = 0;
@@ -5736,7 +5708,7 @@ static int tg3_alloc_rx_data(struct tg3 *tp, struct tg3_rx_prodring_set *tpr,
 				 data_size,
 				 PCI_DMA_FROMDEVICE);
 	if (unlikely(pci_dma_mapping_error(tp->pdev, mapping))) {
-		tg3_frag_free(skb_size <= TG3_FRAGSIZE, data);
+		tg3_frag_free(skb_size <= PAGE_SIZE, data);
 		return -EIO;
 	}
 
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 7c85545..93865f8 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2815,8 +2815,6 @@ struct tg3_rx_prodring_set {
 	struct ring_info		*rx_jmb_buffers;
 	dma_addr_t			rx_std_mapping;
 	dma_addr_t			rx_jmb_mapping;
-	void				*rx_page_addr;
-	unsigned int			rx_page_size;
 };
 
 #define TG3_IRQ_MAX_VECS_RSS		5
