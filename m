From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] chelsio: use the DMA state API instead of the pci equivalents
Date: Tue, 13 Apr 2010 09:32:11 +0900
Message-ID: <1271118734-28353-3-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1271118734-28353-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: fujita.tomonori@lab.ntt.co.jp, Divy Le Ray <divy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:38872 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754455Ab0DMAdf (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 drivers/net/chelsio/sge.c |   50 ++++++++++++++++++++++----------------------
 1 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index df3a141..475304f 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -162,14 +162,14 @@ struct respQ_e {
  */
 struct cmdQ_ce {
 	struct sk_buff *skb;
-	DECLARE_PCI_UNMAP_ADDR(dma_addr);
-	DECLARE_PCI_UNMAP_LEN(dma_len);
+	DEFINE_DMA_UNMAP_ADDR(dma_addr);
+	DEFINE_DMA_UNMAP_LEN(dma_len);
 };
 
 struct freelQ_ce {
 	struct sk_buff *skb;
-	DECLARE_PCI_UNMAP_ADDR(dma_addr);
-	DECLARE_PCI_UNMAP_LEN(dma_len);
+	DEFINE_DMA_UNMAP_ADDR(dma_addr);
+	DEFINE_DMA_UNMAP_LEN(dma_len);
 };
 
 /*
@@ -518,8 +518,8 @@ static void free_freelQ_buffers(struct pci_dev *pdev, struct freelQ *q)
 	while (q->credits--) {
 		struct freelQ_ce *ce = &q->centries[cidx];
 
-		pci_unmap_single(pdev, pci_unmap_addr(ce, dma_addr),
-				 pci_unmap_len(ce, dma_len),
+		pci_unmap_single(pdev, dma_unmap_addr(ce, dma_addr),
+				 dma_unmap_len(ce, dma_len),
 				 PCI_DMA_FROMDEVICE);
 		dev_kfree_skb(ce->skb);
 		ce->skb = NULL;
@@ -633,9 +633,9 @@ static void free_cmdQ_buffers(struct sge *sge, struct cmdQ *q, unsigned int n)
 	q->in_use -= n;
 	ce = &q->centries[cidx];
 	while (n--) {
-		if (likely(pci_unmap_len(ce, dma_len))) {
-			pci_unmap_single(pdev, pci_unmap_addr(ce, dma_addr),
-					 pci_unmap_len(ce, dma_len),
+		if (likely(dma_unmap_len(ce, dma_len))) {
+			pci_unmap_single(pdev, dma_unmap_addr(ce, dma_addr),
+					 dma_unmap_len(ce, dma_len),
 					 PCI_DMA_TODEVICE);
 			if (q->sop)
 				q->sop = 0;
@@ -851,8 +851,8 @@ static void refill_free_list(struct sge *sge, struct freelQ *q)
 		skb_reserve(skb, sge->rx_pkt_pad);
 
 		ce->skb = skb;
-		pci_unmap_addr_set(ce, dma_addr, mapping);
-		pci_unmap_len_set(ce, dma_len, dma_len);
+		dma_unmap_addr_set(ce, dma_addr, mapping);
+		dma_unmap_len_set(ce, dma_len, dma_len);
 		e->addr_lo = (u32)mapping;
 		e->addr_hi = (u64)mapping >> 32;
 		e->len_gen = V_CMD_LEN(dma_len) | V_CMD_GEN1(q->genbit);
@@ -1059,13 +1059,13 @@ static inline struct sk_buff *get_packet(struct pci_dev *pdev,
 		skb_reserve(skb, 2);	/* align IP header */
 		skb_put(skb, len);
 		pci_dma_sync_single_for_cpu(pdev,
-					    pci_unmap_addr(ce, dma_addr),
-					    pci_unmap_len(ce, dma_len),
+					    dma_unmap_addr(ce, dma_addr),
+					    dma_unmap_len(ce, dma_len),
 					    PCI_DMA_FROMDEVICE);
 		skb_copy_from_linear_data(ce->skb, skb->data, len);
 		pci_dma_sync_single_for_device(pdev,
-					       pci_unmap_addr(ce, dma_addr),
-					       pci_unmap_len(ce, dma_len),
+					       dma_unmap_addr(ce, dma_addr),
+					       dma_unmap_len(ce, dma_len),
 					       PCI_DMA_FROMDEVICE);
 		recycle_fl_buf(fl, fl->cidx);
 		return skb;
@@ -1077,8 +1077,8 @@ use_orig_buf:
 		return NULL;
 	}
 
-	pci_unmap_single(pdev, pci_unmap_addr(ce, dma_addr),
-			 pci_unmap_len(ce, dma_len), PCI_DMA_FROMDEVICE);
+	pci_unmap_single(pdev, dma_unmap_addr(ce, dma_addr),
+			 dma_unmap_len(ce, dma_len), PCI_DMA_FROMDEVICE);
 	skb = ce->skb;
 	prefetch(skb->data);
 
@@ -1100,8 +1100,8 @@ static void unexpected_offload(struct adapter *adapter, struct freelQ *fl)
 	struct freelQ_ce *ce = &fl->centries[fl->cidx];
 	struct sk_buff *skb = ce->skb;
 
-	pci_dma_sync_single_for_cpu(adapter->pdev, pci_unmap_addr(ce, dma_addr),
-			    pci_unmap_len(ce, dma_len), PCI_DMA_FROMDEVICE);
+	pci_dma_sync_single_for_cpu(adapter->pdev, dma_unmap_addr(ce, dma_addr),
+			    dma_unmap_len(ce, dma_len), PCI_DMA_FROMDEVICE);
 	pr_err("%s: unexpected offload packet, cmd %u\n",
 	       adapter->name, *skb->data);
 	recycle_fl_buf(fl, fl->cidx);
@@ -1182,7 +1182,7 @@ static inline unsigned int write_large_page_tx_descs(unsigned int pidx,
 			write_tx_desc(e1, *desc_mapping, SGE_TX_DESC_MAX_PLEN,
 				      *gen, nfrags == 0 && *desc_len == 0);
 			ce1->skb = NULL;
-			pci_unmap_len_set(ce1, dma_len, 0);
+			dma_unmap_len_set(ce1, dma_len, 0);
 			*desc_mapping += SGE_TX_DESC_MAX_PLEN;
 			if (*desc_len) {
 				ce1++;
@@ -1233,7 +1233,7 @@ static inline void write_tx_descs(struct adapter *adapter, struct sk_buff *skb,
 	e->addr_hi = (u64)desc_mapping >> 32;
 	e->len_gen = V_CMD_LEN(first_desc_len) | V_CMD_GEN1(gen);
 	ce->skb = NULL;
-	pci_unmap_len_set(ce, dma_len, 0);
+	dma_unmap_len_set(ce, dma_len, 0);
 
 	if (PAGE_SIZE > SGE_TX_DESC_MAX_PLEN &&
 	    desc_len > SGE_TX_DESC_MAX_PLEN) {
@@ -1257,8 +1257,8 @@ static inline void write_tx_descs(struct adapter *adapter, struct sk_buff *skb,
 	}
 
 	ce->skb = NULL;
-	pci_unmap_addr_set(ce, dma_addr, mapping);
-	pci_unmap_len_set(ce, dma_len, skb->len - skb->data_len);
+	dma_unmap_addr_set(ce, dma_addr, mapping);
+	dma_unmap_len_set(ce, dma_len, skb->len - skb->data_len);
 
 	for (i = 0; nfrags--; i++) {
 		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
@@ -1284,8 +1284,8 @@ static inline void write_tx_descs(struct adapter *adapter, struct sk_buff *skb,
 			write_tx_desc(e1, desc_mapping, desc_len, gen,
 				      nfrags == 0);
 		ce->skb = NULL;
-		pci_unmap_addr_set(ce, dma_addr, mapping);
-		pci_unmap_len_set(ce, dma_len, frag->size);
+		dma_unmap_addr_set(ce, dma_addr, mapping);
+		dma_unmap_len_set(ce, dma_len, frag->size);
 	}
 	ce->skb = skb;
 	wmb();
-- 
1.6.5

