From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] cxgb3: use the DMA state API instead of the pci equivalents
Date: Tue, 13 Apr 2010 09:32:12 +0900
Message-ID: <1271118734-28353-4-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1271118734-28353-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: fujita.tomonori@lab.ntt.co.jp, Divy Le Ray <divy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:38873 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754461Ab0DMAdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 20:33:35 -0400
In-Reply-To: <1271118734-28353-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replace the PCI DMA state API (include/linux/pci-dma.h) with the
DMA equivalents since the PCI DMA state API will be obsolete.

No functional change.

For further information about the background:

http://marc.info/?l=linux-netdev&m=127037540020276&w=2

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Divy Le Ray <divy@chelsio.com>
---
 drivers/net/cxgb3/sge.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 07d7e7f..5962b91 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -118,7 +118,7 @@ struct rx_sw_desc {                /* SW state per Rx descriptor */
 		struct sk_buff *skb;
 		struct fl_pg_chunk pg_chunk;
 	};
-	DECLARE_PCI_UNMAP_ADDR(dma_addr);
+	DEFINE_DMA_UNMAP_ADDR(dma_addr);
 };
 
 struct rsp_desc {		/* response queue descriptor */
@@ -208,7 +208,7 @@ static inline int need_skb_unmap(void)
 	 * unmapping by checking if DECLARE_PCI_UNMAP_ADDR defines anything.
 	 */
 	struct dummy {
-		DECLARE_PCI_UNMAP_ADDR(addr);
+		DEFINE_DMA_UNMAP_ADDR(addr);
 	};
 
 	return sizeof(struct dummy) != 0;
@@ -363,7 +363,7 @@ static void clear_rx_desc(struct pci_dev *pdev, const struct sge_fl *q,
 		put_page(d->pg_chunk.page);
 		d->pg_chunk.page = NULL;
 	} else {
-		pci_unmap_single(pdev, pci_unmap_addr(d, dma_addr),
+		pci_unmap_single(pdev, dma_unmap_addr(d, dma_addr),
 				 q->buf_size, PCI_DMA_FROMDEVICE);
 		kfree_skb(d->skb);
 		d->skb = NULL;
@@ -419,7 +419,7 @@ static inline int add_one_rx_buf(void *va, unsigned int len,
 	if (unlikely(pci_dma_mapping_error(pdev, mapping)))
 		return -ENOMEM;
 
-	pci_unmap_addr_set(sd, dma_addr, mapping);
+	dma_unmap_addr_set(sd, dma_addr, mapping);
 
 	d->addr_lo = cpu_to_be32(mapping);
 	d->addr_hi = cpu_to_be32((u64) mapping >> 32);
@@ -515,7 +515,7 @@ nomem:				q->alloc_failed++;
 				break;
 			}
 			mapping = sd->pg_chunk.mapping + sd->pg_chunk.offset;
-			pci_unmap_addr_set(sd, dma_addr, mapping);
+			dma_unmap_addr_set(sd, dma_addr, mapping);
 
 			add_one_rx_chunk(mapping, d, q->gen);
 			pci_dma_sync_single_for_device(adap->pdev, mapping,
@@ -791,11 +791,11 @@ static struct sk_buff *get_packet(struct adapter *adap, struct sge_fl *fl,
 		if (likely(skb != NULL)) {
 			__skb_put(skb, len);
 			pci_dma_sync_single_for_cpu(adap->pdev,
-					    pci_unmap_addr(sd, dma_addr), len,
+					    dma_unmap_addr(sd, dma_addr), len,
 					    PCI_DMA_FROMDEVICE);
 			memcpy(skb->data, sd->skb->data, len);
 			pci_dma_sync_single_for_device(adap->pdev,
-					    pci_unmap_addr(sd, dma_addr), len,
+					    dma_unmap_addr(sd, dma_addr), len,
 					    PCI_DMA_FROMDEVICE);
 		} else if (!drop_thres)
 			goto use_orig_buf;
@@ -810,7 +810,7 @@ recycle:
 		goto recycle;
 
 use_orig_buf:
-	pci_unmap_single(adap->pdev, pci_unmap_addr(sd, dma_addr),
+	pci_unmap_single(adap->pdev, dma_unmap_addr(sd, dma_addr),
 			 fl->buf_size, PCI_DMA_FROMDEVICE);
 	skb = sd->skb;
 	skb_put(skb, len);
@@ -843,7 +843,7 @@ static struct sk_buff *get_packet_pg(struct adapter *adap, struct sge_fl *fl,
 	struct sk_buff *newskb, *skb;
 	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
 
-	dma_addr_t dma_addr = pci_unmap_addr(sd, dma_addr);
+	dma_addr_t dma_addr = dma_unmap_addr(sd, dma_addr);
 
 	newskb = skb = q->pg_skb;
 	if (!skb && (len <= SGE_RX_COPY_THRES)) {
@@ -2097,7 +2097,7 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 	fl->credits--;
 
 	pci_dma_sync_single_for_cpu(adap->pdev,
-				    pci_unmap_addr(sd, dma_addr),
+				    dma_unmap_addr(sd, dma_addr),
 				    fl->buf_size - SGE_PG_RSVD,
 				    PCI_DMA_FROMDEVICE);
 
-- 
1.6.5

