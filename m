From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 15/52] sfc: Use pci_map_single() to map the skb header when doing TSO
Date: Mon, 1 Sep 2008 12:46:40 +0100
Message-ID: <20080901114639.GI7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:36286 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756276AbYIALqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:46:42 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tx.c |  152 +++++++++++++++++++++++++++-----------------------
 1 files changed, 83 insertions(+), 69 deletions(-)

diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 0452ea6..1112775 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -287,9 +287,14 @@ static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 	}
 
 	/* Free the fragment we were mid-way through pushing */
-	if (unmap_len)
-		pci_unmap_page(pci_dev, unmap_addr, unmap_len,
-			       PCI_DMA_TODEVICE);
+	if (unmap_len) {
+		if (unmap_single)
+			pci_unmap_single(pci_dev, unmap_addr, unmap_len,
+					 PCI_DMA_TODEVICE);
+		else
+			pci_unmap_page(pci_dev, unmap_addr, unmap_len,
+				       PCI_DMA_TODEVICE);
+	}
 
 	return rc;
 }
@@ -561,8 +566,7 @@ struct tso_state {
 		/* DMA address and length of the whole fragment */
 		unsigned int unmap_len;
 		dma_addr_t unmap_addr;
-		struct page *page;
-		unsigned page_off;
+		unsigned int unmap_single;
 	} ifc;
 
 	struct {
@@ -686,18 +690,14 @@ efx_tsoh_heap_free(struct efx_tx_queue *tx_queue, struct efx_tso_header *tsoh)
  * @tx_queue:		Efx TX queue
  * @dma_addr:		DMA address of fragment
  * @len:		Length of fragment
- * @skb:		Only non-null for end of last segment
- * @end_of_packet:	True if last fragment in a packet
- * @unmap_addr:		DMA address of fragment for unmapping
- * @unmap_len:		Only set this in last segment of a fragment
+ * @final_buffer:	The final buffer inserted into the queue
  *
  * Push descriptors onto the TX queue.  Return 0 on success or 1 if
  * @tx_queue full.
  */
 static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 			       dma_addr_t dma_addr, unsigned len,
-			       const struct sk_buff *skb, int end_of_packet,
-			       dma_addr_t unmap_addr, unsigned unmap_len)
+			       struct efx_tx_buffer **final_buffer)
 {
 	struct efx_tx_buffer *buffer;
 	struct efx_nic *efx = tx_queue->efx;
@@ -725,8 +725,10 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 			fill_level = (tx_queue->insert_count
 				      - tx_queue->old_read_count);
 			q_space = efx->type->txd_ring_mask - 1 - fill_level;
-			if (unlikely(q_space-- <= 0))
+			if (unlikely(q_space-- <= 0)) {
+				*final_buffer = NULL;
 				return 1;
+			}
 			smp_mb();
 			--tx_queue->stopped;
 		}
@@ -766,10 +768,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 
 	EFX_BUG_ON_PARANOID(!len);
 	buffer->len = len;
-	buffer->skb = skb;
-	buffer->continuation = !end_of_packet;
-	buffer->unmap_addr = unmap_addr;
-	buffer->unmap_len = unmap_len;
+	*final_buffer = buffer;
 	return 0;
 }
 
@@ -817,9 +816,16 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 		buffer->len = 0;
 		buffer->continuation = 1;
 		if (buffer->unmap_len) {
-			pci_unmap_page(tx_queue->efx->pci_dev,
-				       buffer->unmap_addr,
-				       buffer->unmap_len, PCI_DMA_TODEVICE);
+			if (buffer->unmap_single)
+				pci_unmap_single(tx_queue->efx->pci_dev,
+						 buffer->unmap_addr,
+						 buffer->unmap_len,
+						 PCI_DMA_TODEVICE);
+			else
+				pci_unmap_page(tx_queue->efx->pci_dev,
+					       buffer->unmap_addr,
+					       buffer->unmap_len,
+					       PCI_DMA_TODEVICE);
 			buffer->unmap_len = 0;
 		}
 	}
@@ -846,31 +852,40 @@ static inline void tso_start(struct tso_state *st, const struct sk_buff *skb)
 
 	st->packet_space = st->p.full_packet_size;
 	st->remaining_len = skb->len - st->p.header_length;
+	st->ifc.unmap_len = 0;
+	st->ifc.unmap_single = 0;
 }
 
-
-/**
- * tso_get_fragment - record fragment details and map for DMA
- * @st:			TSO state
- * @efx:		Efx NIC
- * @data:		Pointer to fragment data
- * @len:		Length of fragment
- *
- * Record fragment details and map for DMA.  Return 0 on success, or
- * -%ENOMEM if DMA mapping fails.
- */
 static inline int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
-				   int len, struct page *page, int page_off)
+				   skb_frag_t *frag)
 {
+	st->ifc.unmap_addr = pci_map_page(efx->pci_dev, frag->page,
+					  frag->page_offset, frag->size,
+					  PCI_DMA_TODEVICE);
+	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->ifc.unmap_addr))) {
+		st->ifc.unmap_single = 0;
+		st->ifc.unmap_len = frag->size;
+		st->ifc.len = frag->size;
+		st->ifc.dma_addr = st->ifc.unmap_addr;
+		return 0;
+	}
+	return -ENOMEM;
+}
+
+static inline int
+tso_get_head_fragment(struct tso_state *st, struct efx_nic *efx,
+		      const struct sk_buff *skb)
+{
+	int hl = st->p.header_length;
+	int len = skb_headlen(skb) - hl;
 
-	st->ifc.unmap_addr = pci_map_page(efx->pci_dev, page, page_off,
-					  len, PCI_DMA_TODEVICE);
+	st->ifc.unmap_addr = pci_map_single(efx->pci_dev, skb->data + hl,
+					    len, PCI_DMA_TODEVICE);
 	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->ifc.unmap_addr))) {
+		st->ifc.unmap_single = 1;
 		st->ifc.unmap_len = len;
 		st->ifc.len = len;
 		st->ifc.dma_addr = st->ifc.unmap_addr;
-		st->ifc.page = page;
-		st->ifc.page_off = page_off;
 		return 0;
 	}
 	return -ENOMEM;
@@ -891,7 +906,7 @@ static inline int tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
 						const struct sk_buff *skb,
 						struct tso_state *st)
 {
-
+	struct efx_tx_buffer *buffer;
 	int n, end_of_packet, rc;
 
 	if (st->ifc.len == 0)
@@ -907,16 +922,25 @@ static inline int tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
 	st->packet_space -= n;
 	st->remaining_len -= n;
 	st->ifc.len -= n;
-	st->ifc.page_off += n;
-	end_of_packet = st->remaining_len == 0 || st->packet_space == 0;
 
-	rc = efx_tx_queue_insert(tx_queue, st->ifc.dma_addr, n,
-				 st->remaining_len ? NULL : skb,
-				 end_of_packet, st->ifc.unmap_addr,
-				 st->ifc.len ? 0 : st->ifc.unmap_len);
+	rc = efx_tx_queue_insert(tx_queue, st->ifc.dma_addr, n, &buffer);
+	if (likely(rc == 0)) {
+		if (st->remaining_len == 0)
+			/* Transfer ownership of the skb */
+			buffer->skb = skb;
 
-	st->ifc.dma_addr += n;
+		end_of_packet = st->remaining_len == 0 || st->packet_space == 0;
+		buffer->continuation = !end_of_packet;
 
+		if (st->ifc.len == 0) {
+			/* Transfer ownership of the pci mapping */
+			buffer->unmap_len = st->ifc.unmap_len;
+			buffer->unmap_single = st->ifc.unmap_single;
+			st->ifc.unmap_len = 0;
+		}
+	}
+
+	st->ifc.dma_addr += n;
 	return rc;
 }
 
@@ -1008,9 +1032,9 @@ static inline int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 			       const struct sk_buff *skb)
 {
+	struct efx_nic *efx = tx_queue->efx;
 	int frag_i, rc, rc2 = NETDEV_TX_OK;
 	struct tso_state state;
-	skb_frag_t *f;
 
 	/* Verify TSO is safe - these checks should never fail. */
 	efx_tso_check_safe(skb);
@@ -1026,25 +1050,12 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 		/* Grab the first payload fragment. */
 		EFX_BUG_ON_PARANOID(skb_shinfo(skb)->nr_frags < 1);
 		frag_i = 0;
-		f = &skb_shinfo(skb)->frags[frag_i];
-		rc = tso_get_fragment(&state, tx_queue->efx,
-				      f->size, f->page, f->page_offset);
+		rc = tso_get_fragment(&state, efx,
+				      skb_shinfo(skb)->frags + frag_i);
 		if (rc)
 			goto mem_err;
 	} else {
-		/* It may look like this code fragment assumes that the
-		 * skb->data portion does not cross a page boundary, but
-		 * that is not the case.  It is guaranteed to be direct
-		 * mapped memory, and therefore is physically contiguous,
-		 * and so DMA will work fine.  kmap_atomic() on this region
-		 * will just return the direct mapping, so that will work
-		 * too.
-		 */
-		int page_off = (unsigned long)skb->data & (PAGE_SIZE - 1);
-		int hl = state.p.header_length;
-		rc = tso_get_fragment(&state, tx_queue->efx,
-				      skb_headlen(skb) - hl,
-				      virt_to_page(skb->data), page_off + hl);
+		rc = tso_get_head_fragment(&state, efx, skb);
 		if (rc)
 			goto mem_err;
 		frag_i = -1;
@@ -1063,9 +1074,8 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 			if (++frag_i >= skb_shinfo(skb)->nr_frags)
 				/* End of payload reached. */
 				break;
-			f = &skb_shinfo(skb)->frags[frag_i];
-			rc = tso_get_fragment(&state, tx_queue->efx,
-					      f->size, f->page, f->page_offset);
+			rc = tso_get_fragment(&state, efx,
+					      skb_shinfo(skb)->frags + frag_i);
 			if (rc)
 				goto mem_err;
 		}
@@ -1083,8 +1093,7 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 	return NETDEV_TX_OK;
 
  mem_err:
-	EFX_ERR(tx_queue->efx, "Out of memory for TSO headers, or PCI mapping"
-		" error\n");
+	EFX_ERR(efx, "Out of memory for TSO headers, or PCI mapping error\n");
 	dev_kfree_skb_any((struct sk_buff *)skb);
 	goto unwind;
 
@@ -1093,13 +1102,18 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 
 	/* Stop the queue if it wasn't stopped before. */
 	if (tx_queue->stopped == 1)
-		efx_stop_queue(tx_queue->efx);
+		efx_stop_queue(efx);
 
  unwind:
 	/* Free the DMA mapping we were in the process of writing out */
-	if (state.ifc.unmap_len)
-		pci_unmap_page(tx_queue->efx->pci_dev, state.ifc.unmap_addr,
-			       state.ifc.unmap_len, PCI_DMA_TODEVICE);
+	if (state.ifc.unmap_len) {
+		if (state.ifc.unmap_single)
+			pci_unmap_single(efx->pci_dev, state.ifc.unmap_addr,
+					 state.ifc.unmap_len, PCI_DMA_TODEVICE);
+		else
+			pci_unmap_page(efx->pci_dev, state.ifc.unmap_addr,
+				       state.ifc.unmap_len, PCI_DMA_TODEVICE);
+	}
 
 	efx_enqueue_unwind(tx_queue);
 	return rc2;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

