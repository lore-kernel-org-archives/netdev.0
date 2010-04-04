From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: RE: [PATCH] bnx2x: use the dma state API instead of the pci
 equivalents
Date: Sun, 4 Apr 2010 20:51:03 +0900
Message-ID: <20100404205028H.fujita.tomonori@lab.ntt.co.jp>
References: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDC@SJEXCHCCR02.corp.ad.broadcom.com>
	<20100404190116N.fujita.tomonori@lab.ntt.co.jp>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDD@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fujita.tomonori@lab.ntt.co.jp, davem@davemloft.net,
	netdev@vger.kernel.org, eilong@broadcom.com
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:56018 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752285Ab0DDLvM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Apr 2010 07:51:12 -0400
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDC525ADDD@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 4 Apr 2010 03:24:46 -0700
"Vladislav Zolotarov" <vladz@broadcom.com> wrote:

> Ok. Got it now. Thanks, Fujita. I think we should patch the bnx2x to
> use the generic model (not just the mapping macros).

I've attached the patch.

There is one functional change: pci_alloc_consistent ->
dma_alloc_coherent

pci_alloc_consistent is a wrapper function of dma_alloc_coherent with
GFP_ATOMIC flag (see include/asm-generic/pci-dma-compat.h).

pci_alloc_consistent uses GFP_ATOMIC flag because of the compatibility
for some broken drivers that use the function in interrupt. But
GFP_ATOMIC should be avoided if possible. Looks like bnx2x doesn't use
pci_alloc_consistent in interrupt so I replaced them with
dma_alloc_coherent with GFP_KERNEL.

Please check if that change works for bnx2x.

> One last question: since which kernel version the generic DMA layer
> may be used instead of PCI DMA layer?

After 2.6.34-rc2.

Well, on the majority of architectures, you have been able to use the
generic DMA API over the PCI DMA API. The PCI DMA API is just the
wrapper of the generic DMA API. But on some architectures, two APIs
worked differently a bit. since 2.6.34-rc2, two API work in the exact
same way on all the architectures.


=
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] bnx2x: use the DMA API instead of the pci equivalents

The DMA API is preferred.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/bnx2x.h      |    4 +-
 drivers/net/bnx2x_main.c |  110 +++++++++++++++++++++++----------------------
 2 files changed, 58 insertions(+), 56 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 3c48a7a..ae9c89e 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -163,7 +163,7 @@ do {								 \
 
 struct sw_rx_bd {
 	struct sk_buff	*skb;
-	DECLARE_PCI_UNMAP_ADDR(mapping)
+	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
 struct sw_tx_bd {
@@ -176,7 +176,7 @@ struct sw_tx_bd {
 
 struct sw_rx_page {
 	struct page	*page;
-	DECLARE_PCI_UNMAP_ADDR(mapping)
+	DEFINE_DMA_UNMAP_ADDR(mapping);
 };
 
 union db_prod {
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index fa9275c..63a17d6 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -842,7 +842,7 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	/* unmap first bd */
 	DP(BNX2X_MSG_OFF, "free bd_idx %d\n", bd_idx);
 	tx_start_bd = &fp->tx_desc_ring[bd_idx].start_bd;
-	pci_unmap_single(bp->pdev, BD_UNMAP_ADDR(tx_start_bd),
+	dma_unmap_single(&bp->pdev->dev, BD_UNMAP_ADDR(tx_start_bd),
 			 BD_UNMAP_LEN(tx_start_bd), PCI_DMA_TODEVICE);
 
 	nbd = le16_to_cpu(tx_start_bd->nbd) - 1;
@@ -872,8 +872,8 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 
 		DP(BNX2X_MSG_OFF, "free frag bd_idx %d\n", bd_idx);
 		tx_data_bd = &fp->tx_desc_ring[bd_idx].reg_bd;
-		pci_unmap_page(bp->pdev, BD_UNMAP_ADDR(tx_data_bd),
-			       BD_UNMAP_LEN(tx_data_bd), PCI_DMA_TODEVICE);
+		dma_unmap_page(&bp->pdev->dev, BD_UNMAP_ADDR(tx_data_bd),
+			       BD_UNMAP_LEN(tx_data_bd), DMA_TO_DEVICE);
 		if (--nbd)
 			bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
 	}
@@ -1086,7 +1086,7 @@ static inline void bnx2x_free_rx_sge(struct bnx2x *bp,
 	if (!page)
 		return;
 
-	pci_unmap_page(bp->pdev, pci_unmap_addr(sw_buf, mapping),
+	dma_unmap_page(&bp->pdev->dev, dma_unmap_addr(sw_buf, mapping),
 		       SGE_PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
 	__free_pages(page, PAGES_PER_SGE_SHIFT);
 
@@ -1115,15 +1115,15 @@ static inline int bnx2x_alloc_rx_sge(struct bnx2x *bp,
 	if (unlikely(page == NULL))
 		return -ENOMEM;
 
-	mapping = pci_map_page(bp->pdev, page, 0, SGE_PAGE_SIZE*PAGES_PER_SGE,
-			       PCI_DMA_FROMDEVICE);
+	mapping = dma_map_page(&bp->pdev->dev, page, 0,
+			       SGE_PAGE_SIZE*PAGES_PER_SGE, DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
 		__free_pages(page, PAGES_PER_SGE_SHIFT);
 		return -ENOMEM;
 	}
 
 	sw_buf->page = page;
-	pci_unmap_addr_set(sw_buf, mapping, mapping);
+	dma_unmap_addr_set(sw_buf, mapping, mapping);
 
 	sge->addr_hi = cpu_to_le32(U64_HI(mapping));
 	sge->addr_lo = cpu_to_le32(U64_LO(mapping));
@@ -1143,15 +1143,15 @@ static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
 	if (unlikely(skb == NULL))
 		return -ENOMEM;
 
-	mapping = pci_map_single(bp->pdev, skb->data, bp->rx_buf_size,
-				 PCI_DMA_FROMDEVICE);
+	mapping = dma_map_single(&bp->pdev->dev, skb->data, bp->rx_buf_size,
+				 DMA_FROM_DEVICE);
 	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
 		dev_kfree_skb(skb);
 		return -ENOMEM;
 	}
 
 	rx_buf->skb = skb;
-	pci_unmap_addr_set(rx_buf, mapping, mapping);
+	dma_unmap_addr_set(rx_buf, mapping, mapping);
 
 	rx_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
 	rx_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
@@ -1173,13 +1173,13 @@ static void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
 	struct eth_rx_bd *cons_bd = &fp->rx_desc_ring[cons];
 	struct eth_rx_bd *prod_bd = &fp->rx_desc_ring[prod];
 
-	pci_dma_sync_single_for_device(bp->pdev,
-				       pci_unmap_addr(cons_rx_buf, mapping),
-				       RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
+	dma_sync_single_for_device(&bp->pdev->dev,
+				   dma_unmap_addr(cons_rx_buf, mapping),
+				   RX_COPY_THRESH, DMA_FROM_DEVICE);
 
 	prod_rx_buf->skb = cons_rx_buf->skb;
-	pci_unmap_addr_set(prod_rx_buf, mapping,
-			   pci_unmap_addr(cons_rx_buf, mapping));
+	dma_unmap_addr_set(prod_rx_buf, mapping,
+			   dma_unmap_addr(cons_rx_buf, mapping));
 	*prod_bd = *cons_bd;
 }
 
@@ -1283,9 +1283,9 @@ static void bnx2x_tpa_start(struct bnx2x_fastpath *fp, u16 queue,
 
 	/* move empty skb from pool to prod and map it */
 	prod_rx_buf->skb = fp->tpa_pool[queue].skb;
-	mapping = pci_map_single(bp->pdev, fp->tpa_pool[queue].skb->data,
-				 bp->rx_buf_size, PCI_DMA_FROMDEVICE);
-	pci_unmap_addr_set(prod_rx_buf, mapping, mapping);
+	mapping = dma_map_single(&bp->pdev->dev, fp->tpa_pool[queue].skb->data,
+				 bp->rx_buf_size, DMA_FROM_DEVICE);
+	dma_unmap_addr_set(prod_rx_buf, mapping, mapping);
 
 	/* move partial skb from cons to pool (don't unmap yet) */
 	fp->tpa_pool[queue] = *cons_rx_buf;
@@ -1361,8 +1361,9 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		}
 
 		/* Unmap the page as we r going to pass it to the stack */
-		pci_unmap_page(bp->pdev, pci_unmap_addr(&old_rx_pg, mapping),
-			      SGE_PAGE_SIZE*PAGES_PER_SGE, PCI_DMA_FROMDEVICE);
+		dma_unmap_page(&bp->pdev->dev,
+			       dma_unmap_addr(&old_rx_pg, mapping),
+			       SGE_PAGE_SIZE*PAGES_PER_SGE, DMA_FROM_DEVICE);
 
 		/* Add one frag and update the appropriate fields in the skb */
 		skb_fill_page_desc(skb, j, old_rx_pg.page, 0, frag_len);
@@ -1389,8 +1390,8 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 	/* Unmap skb in the pool anyway, as we are going to change
 	   pool entry status to BNX2X_TPA_STOP even if new skb allocation
 	   fails. */
-	pci_unmap_single(bp->pdev, pci_unmap_addr(rx_buf, mapping),
-			 bp->rx_buf_size, PCI_DMA_FROMDEVICE);
+	dma_unmap_single(&bp->pdev->dev, dma_unmap_addr(rx_buf, mapping),
+			 bp->rx_buf_size, DMA_FROM_DEVICE);
 
 	if (likely(new_skb)) {
 		/* fix ip xsum and give it to the stack */
@@ -1620,10 +1621,10 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 				}
 			}
 
-			pci_dma_sync_single_for_device(bp->pdev,
-					pci_unmap_addr(rx_buf, mapping),
-						       pad + RX_COPY_THRESH,
-						       PCI_DMA_FROMDEVICE);
+			dma_sync_single_for_device(&bp->pdev->dev,
+					dma_unmap_addr(rx_buf, mapping),
+						   pad + RX_COPY_THRESH,
+						   DMA_FROM_DEVICE);
 			prefetch(skb);
 			prefetch(((char *)(skb)) + 128);
 
@@ -1665,10 +1666,10 @@ static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 
 			} else
 			if (likely(bnx2x_alloc_rx_skb(bp, fp, bd_prod) == 0)) {
-				pci_unmap_single(bp->pdev,
-					pci_unmap_addr(rx_buf, mapping),
+				dma_unmap_single(&bp->pdev->dev,
+					dma_unmap_addr(rx_buf, mapping),
 						 bp->rx_buf_size,
-						 PCI_DMA_FROMDEVICE);
+						 DMA_FROM_DEVICE);
 				skb_reserve(skb, pad);
 				skb_put(skb, len);
 
@@ -4940,9 +4941,9 @@ static inline void bnx2x_free_tpa_pool(struct bnx2x *bp,
 		}
 
 		if (fp->tpa_state[i] == BNX2X_TPA_START)
-			pci_unmap_single(bp->pdev,
-					 pci_unmap_addr(rx_buf, mapping),
-					 bp->rx_buf_size, PCI_DMA_FROMDEVICE);
+			dma_unmap_single(&bp->pdev->dev,
+					 dma_unmap_addr(rx_buf, mapping),
+					 bp->rx_buf_size, DMA_FROM_DEVICE);
 
 		dev_kfree_skb(skb);
 		rx_buf->skb = NULL;
@@ -4978,7 +4979,7 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 					fp->disable_tpa = 1;
 					break;
 				}
-				pci_unmap_addr_set((struct sw_rx_bd *)
+				dma_unmap_addr_set((struct sw_rx_bd *)
 							&bp->fp->tpa_pool[i],
 						   mapping, 0);
 				fp->tpa_state[i] = BNX2X_TPA_STOP;
@@ -5658,8 +5659,8 @@ static void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 
 static int bnx2x_gunzip_init(struct bnx2x *bp)
 {
-	bp->gunzip_buf = pci_alloc_consistent(bp->pdev, FW_BUF_SIZE,
-					      &bp->gunzip_mapping);
+	bp->gunzip_buf = dma_alloc_coherent(&bp->pdev->dev, FW_BUF_SIZE,
+					    &bp->gunzip_mapping, GFP_KERNEL);
 	if (bp->gunzip_buf  == NULL)
 		goto gunzip_nomem1;
 
@@ -5679,8 +5680,8 @@ gunzip_nomem3:
 	bp->strm = NULL;
 
 gunzip_nomem2:
-	pci_free_consistent(bp->pdev, FW_BUF_SIZE, bp->gunzip_buf,
-			    bp->gunzip_mapping);
+	dma_free_coherent(&bp->pdev->dev, FW_BUF_SIZE, bp->gunzip_buf,
+			  bp->gunzip_mapping);
 	bp->gunzip_buf = NULL;
 
 gunzip_nomem1:
@@ -5696,8 +5697,8 @@ static void bnx2x_gunzip_end(struct bnx2x *bp)
 	bp->strm = NULL;
 
 	if (bp->gunzip_buf) {
-		pci_free_consistent(bp->pdev, FW_BUF_SIZE, bp->gunzip_buf,
-				    bp->gunzip_mapping);
+		dma_free_coherent(&bp->pdev->dev, FW_BUF_SIZE, bp->gunzip_buf,
+				  bp->gunzip_mapping);
 		bp->gunzip_buf = NULL;
 	}
 }
@@ -6692,7 +6693,7 @@ static void bnx2x_free_mem(struct bnx2x *bp)
 #define BNX2X_PCI_FREE(x, y, size) \
 	do { \
 		if (x) { \
-			pci_free_consistent(bp->pdev, size, x, y); \
+			dma_free_coherent(&bp->pdev->dev, size, x, y); \
 			x = NULL; \
 			y = 0; \
 		} \
@@ -6773,7 +6774,7 @@ static int bnx2x_alloc_mem(struct bnx2x *bp)
 
 #define BNX2X_PCI_ALLOC(x, y, size) \
 	do { \
-		x = pci_alloc_consistent(bp->pdev, size, y); \
+		x = dma_alloc_coherent(&bp->pdev->dev, size, y, GFP_KERNEL); \
 		if (x == NULL) \
 			goto alloc_mem_err; \
 		memset(x, 0, size); \
@@ -6906,9 +6907,9 @@ static void bnx2x_free_rx_skbs(struct bnx2x *bp)
 			if (skb == NULL)
 				continue;
 
-			pci_unmap_single(bp->pdev,
-					 pci_unmap_addr(rx_buf, mapping),
-					 bp->rx_buf_size, PCI_DMA_FROMDEVICE);
+			dma_unmap_single(&bp->pdev->dev,
+					 dma_unmap_addr(rx_buf, mapping),
+					 bp->rx_buf_size, DMA_FROM_DEVICE);
 
 			rx_buf->skb = NULL;
 			dev_kfree_skb(skb);
@@ -10269,8 +10270,8 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode, u8 link_up)
 
 	bd_prod = TX_BD(fp_tx->tx_bd_prod);
 	tx_start_bd = &fp_tx->tx_desc_ring[bd_prod].start_bd;
-	mapping = pci_map_single(bp->pdev, skb->data,
-				 skb_headlen(skb), PCI_DMA_TODEVICE);
+	mapping = dma_map_single(&bp->pdev->dev, skb->data,
+				 skb_headlen(skb), DMA_TO_DEVICE);
 	tx_start_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
 	tx_start_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
 	tx_start_bd->nbd = cpu_to_le16(2); /* start + pbd */
@@ -11316,8 +11317,8 @@ static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 
-	mapping = pci_map_single(bp->pdev, skb->data,
-				 skb_headlen(skb), PCI_DMA_TODEVICE);
+	mapping = dma_map_single(&bp->pdev->dev, skb->data,
+				 skb_headlen(skb), DMA_TO_DEVICE);
 
 	tx_start_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
 	tx_start_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
@@ -11374,8 +11375,9 @@ static netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (total_pkt_bd == NULL)
 			total_pkt_bd = &fp->tx_desc_ring[bd_prod].reg_bd;
 
-		mapping = pci_map_page(bp->pdev, frag->page, frag->page_offset,
-				       frag->size, PCI_DMA_TODEVICE);
+		mapping = dma_map_page(&bp->pdev->dev, frag->page,
+				       frag->page_offset,
+				       frag->size, DMA_TO_DEVICE);
 
 		tx_data_bd->addr_hi = cpu_to_le32(U64_HI(mapping));
 		tx_data_bd->addr_lo = cpu_to_le32(U64_LO(mapping));
@@ -11832,15 +11834,15 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 		goto err_out_release;
 	}
 
-	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) == 0) {
+	if (dma_set_mask(&pdev->dev, DMA_BIT_MASK(64)) == 0) {
 		bp->flags |= USING_DAC_FLAG;
-		if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64)) != 0) {
-			pr_err("pci_set_consistent_dma_mask failed, aborting\n");
+		if (dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64)) != 0) {
+			pr_err("dma_set_coherent_mask failed, aborting\n");
 			rc = -EIO;
 			goto err_out_release;
 		}
 
-	} else if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) != 0) {
+	} else if (dma_set_mask(&pdev->dev, DMA_BIT_MASK(32)) != 0) {
 		pr_err("System does not support DMA, aborting\n");
 		rc = -EIO;
 		goto err_out_release;
-- 
1.7.0

