From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH] vmxnet3: fix starving rx ring whenoc_skb kb fails
Date: Tue, 5 Jul 2011 17:34:05 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1107051721230.32629@sbhatewara-dev1.eng.vmware.com>
References: <03E840D17E263A48A5766AD576E0423A012911782E@exch-mbx-111.vmware.com> <20110617.005356.180809929241094878.davem@davemloft.net> <1308312860.11457.56.camel@localhost> <20110617.120900.550060204741705506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	scottjg@vmware.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:9077 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754730Ab1GFAeD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 20:34:03 -0400
In-Reply-To: <20110617.120900.550060204741705506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If the rx ring is completely empty, then the device may never fire an rx 
interrupt. Unfortunately, the rx interrupt is what triggers populating the 
rx ring with fresh buffers, so this will cause networking to lock up.

This patch replenishes the skb in recv descriptor as soon as it is 
peeled off while processing rx completions. If the skb/buffer 
allocation fails, existing one is recycled and the packet in hand is 
dropped. This way none of the RX desc is ever left empty, thus avoiding 
starvation

Signed-off-by: Scott J. Goldman <scottjg@vmware.com>
Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
---

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index 2c14736..fabcded 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -573,7 +573,7 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32 ring_idx,
 	struct vmxnet3_cmd_ring *ring = &rq->rx_ring[ring_idx];
 	u32 val;
 
-	while (num_allocated < num_to_alloc) {
+	while (num_allocated <= num_to_alloc) {
 		struct vmxnet3_rx_buf_info *rbi;
 		union Vmxnet3_GenericDesc *gd;
 
@@ -619,9 +619,15 @@ vmxnet3_rq_alloc_rx_buf(struct vmxnet3_rx_queue *rq, u32 ring_idx,
 
 		BUG_ON(rbi->dma_addr == 0);
 		gd->rxd.addr = cpu_to_le64(rbi->dma_addr);
-		gd->dword[2] = cpu_to_le32((ring->gen << VMXNET3_RXD_GEN_SHIFT)
+		gd->dword[2] = cpu_to_le32((!ring->gen << VMXNET3_RXD_GEN_SHIFT)
 					   | val | rbi->len);
 
+		/* Fill the last buffer but dont mark it ready, or else the
+		 * device will think that the queue is full */
+		if (num_allocated == num_to_alloc)
+			break;
+
+		gd->dword[2] |= cpu_to_le32(ring->gen << VMXNET3_RXD_GEN_SHIFT);
 		num_allocated++;
 		vmxnet3_cmd_ring_adv_next2fill(ring);
 	}
@@ -1138,6 +1144,7 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 		VMXNET3_REG_RXPROD, VMXNET3_REG_RXPROD2
 	};
 	u32 num_rxd = 0;
+	bool skip_page_frags = false;
 	struct Vmxnet3_RxCompDesc *rcd;
 	struct vmxnet3_rx_ctx *ctx = &rq->rx_ctx;
 #ifdef __BIG_ENDIAN_BITFIELD
@@ -1148,11 +1155,12 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 			  &rxComp);
 	while (rcd->gen == rq->comp_ring.gen) {
 		struct vmxnet3_rx_buf_info *rbi;
-		struct sk_buff *skb;
+		struct sk_buff *skb, *new_skb = NULL;
+		struct page *new_page = NULL;
 		int num_to_alloc;
 		struct Vmxnet3_RxDesc *rxd;
 		u32 idx, ring_idx;
-
+		struct vmxnet3_cmd_ring	*ring = NULL;
 		if (num_rxd >= quota) {
 			/* we may stop even before we see the EOP desc of
 			 * the current pkt
@@ -1163,6 +1171,7 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 		BUG_ON(rcd->rqID != rq->qid && rcd->rqID != rq->qid2);
 		idx = rcd->rxdIdx;
 		ring_idx = rcd->rqID < adapter->num_rx_queues ? 0 : 1;
+		ring = rq->rx_ring + ring_idx;
 		vmxnet3_getRxDesc(rxd, &rq->rx_ring[ring_idx].base[idx].rxd,
 				  &rxCmdDesc);
 		rbi = rq->buf_info[ring_idx] + idx;
@@ -1191,37 +1200,80 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 				goto rcd_done;
 			}
 
+			skip_page_frags = false;
 			ctx->skb = rbi->skb;
-			rbi->skb = NULL;
+			new_skb = dev_alloc_skb(rbi->len + NET_IP_ALIGN);
+			if (new_skb == NULL) {
+				/* Skb allocation failed, do not handover this
+				 * skb to stack. Reuse it. Drop the existing pkt
+				 */
+				rq->stats.rx_buf_alloc_failure++;
+				ctx->skb = NULL;
+				rq->stats.drop_total++;
+				skip_page_frags = true;
+				goto rcd_done;
+			}
 
 			pci_unmap_single(adapter->pdev, rbi->dma_addr, rbi->len,
 					 PCI_DMA_FROMDEVICE);
 
 			skb_put(ctx->skb, rcd->len);
+
+			/* Immediate refill */
+			new_skb->dev = adapter->netdev;
+			skb_reserve(new_skb, NET_IP_ALIGN);
+			rbi->skb = new_skb;
+			rbi->dma_addr = pci_map_single(adapter->pdev,
+					rbi->skb->data, rbi->len,
+					PCI_DMA_FROMDEVICE);
+			rxd->addr = cpu_to_le64(rbi->dma_addr);
+			rxd->len = rbi->len;
+
 		} else {
-			BUG_ON(ctx->skb == NULL);
+			BUG_ON(ctx->skb == NULL && !skip_page_frags);
+
 			/* non SOP buffer must be type 1 in most cases */
-			if (rbi->buf_type == VMXNET3_RX_BUF_PAGE) {
-				BUG_ON(rxd->btype != VMXNET3_RXD_BTYPE_BODY);
+			BUG_ON(rbi->buf_type != VMXNET3_RX_BUF_PAGE);
+			BUG_ON(rxd->btype != VMXNET3_RXD_BTYPE_BODY);
 
-				if (rcd->len) {
-					pci_unmap_page(adapter->pdev,
-						       rbi->dma_addr, rbi->len,
-						       PCI_DMA_FROMDEVICE);
+			/* If an sop buffer was dropped, skip all
+			 * following non-sop fragments. They will be reused.
+			 */
+			if (skip_page_frags)
+				goto rcd_done;
 
-					vmxnet3_append_frag(ctx->skb, rcd, rbi);
-					rbi->page = NULL;
-				}
-			} else {
-				/*
-				 * The only time a non-SOP buffer is type 0 is
-				 * when it's EOP and error flag is raised, which
-				 * has already been handled.
+			new_page = alloc_page(GFP_ATOMIC);
+			if (unlikely(new_page == NULL)) {
+				/* Replacement page frag could not be allocated.
+				 * Reuse this page. Drop the pkt and free the
+				 * skb which contained this page as a frag. Skip
+				 * processing all the following non-sop frags.
 				 */
-				BUG_ON(true);
+				rq->stats.rx_buf_alloc_failure++;
+				dev_kfree_skb(ctx->skb);
+				ctx->skb = NULL;
+				skip_page_frags = true;
+				goto rcd_done;
+			}
+
+			if (rcd->len) {
+				pci_unmap_page(adapter->pdev,
+					       rbi->dma_addr, rbi->len,
+					       PCI_DMA_FROMDEVICE);
+
+				vmxnet3_append_frag(ctx->skb, rcd, rbi);
 			}
+
+			/* Immediate refill */
+			rbi->page = new_page;
+			rbi->dma_addr = pci_map_page(adapter->pdev, rbi->page,
+						     0, PAGE_SIZE,
+						     PCI_DMA_FROMDEVICE);
+			rxd->addr = cpu_to_le64(rbi->dma_addr);
+			rxd->len = rbi->len;
 		}
 
+
 		skb = ctx->skb;
 		if (rcd->eop) {
 			skb->len += skb->data_len;
@@ -1243,26 +1295,27 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
 		}
 
 rcd_done:
-		/* device may skip some rx descs */
-		rq->rx_ring[ring_idx].next2comp = idx;
-		VMXNET3_INC_RING_IDX_ONLY(rq->rx_ring[ring_idx].next2comp,
-					  rq->rx_ring[ring_idx].size);
-
-		/* refill rx buffers frequently to avoid starving the h/w */
-		num_to_alloc = vmxnet3_cmd_ring_desc_avail(rq->rx_ring +
-							   ring_idx);
-		if (unlikely(num_to_alloc > VMXNET3_RX_ALLOC_THRESHOLD(rq,
-							ring_idx, adapter))) {
-			vmxnet3_rq_alloc_rx_buf(rq, ring_idx, num_to_alloc,
-						adapter);
-
-			/* if needed, update the register */
-			if (unlikely(rq->shared->updateRxProd)) {
-				VMXNET3_WRITE_BAR0_REG(adapter,
-					rxprod_reg[ring_idx] + rq->qid * 8,
-					rq->rx_ring[ring_idx].next2fill);
-				rq->uncommitted[ring_idx] = 0;
-			}
+		/* device may have skipped some rx descs */
+		ring->next2comp = idx;
+		num_to_alloc = vmxnet3_cmd_ring_desc_avail(ring);
+		ring = rq->rx_ring + ring_idx;
+		while (num_to_alloc) {
+			vmxnet3_getRxDesc(rxd, &ring->base[ring->next2fill].rxd,
+					  &rxCmdDesc);
+			BUG_ON(!rxd->addr);
+
+			/* Recv desc is ready to be used by the device */
+			rxd->gen = ring->gen;
+			vmxnet3_cmd_ring_adv_next2fill(ring);
+			num_to_alloc--;
+		}
+
+		/* if needed, update the register */
+		if (unlikely(rq->shared->updateRxProd)) {
+			VMXNET3_WRITE_BAR0_REG(adapter,
+				rxprod_reg[ring_idx] + rq->qid * 8,
+				ring->next2fill);
+			rq->uncommitted[ring_idx] = 0;
 		}
 
 		vmxnet3_comp_ring_adv_next2proc(&rq->comp_ring);
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index 2e37985..a9cb3fa 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -69,10 +69,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.1.9.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.1.14.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01010900
+#define VMXNET3_DRIVER_VERSION_NUM      0x01010E00
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
