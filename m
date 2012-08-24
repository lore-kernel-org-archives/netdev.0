From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 01/16] sfc: Refactor struct efx_tx_buffer to use a
 flags field
Date: Fri, 24 Aug 2012 20:47:58 +0100
Message-ID: <1345837678.2694.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56641 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757692Ab2HXTsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:48:01 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a flags field to struct efx_tx_buffer, replacing the
continuation and map_single booleans.

Since a single descriptor cannot be both a TSO header and the last
descriptor for an skb, unionise efx_tx_buffer::{skb,tsoh} and add
flags for validity of these fields.

Clear all flags in free buffers (whereas previously the continuation
flag would be set).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |   27 ++++++-----
 drivers/net/ethernet/sfc/nic.c        |    4 +-
 drivers/net/ethernet/sfc/tx.c         |   78 +++++++++++++++------------------
 3 files changed, 53 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index cd9c0a9..0ac01fa 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -91,29 +91,30 @@ struct efx_special_buffer {
 };
 
 /**
- * struct efx_tx_buffer - An Efx TX buffer
- * @skb: The associated socket buffer.
- *	Set only on the final fragment of a packet; %NULL for all other
- *	fragments.  When this fragment completes, then we can free this
- *	skb.
- * @tsoh: The associated TSO header structure, or %NULL if this
- *	buffer is not a TSO header.
+ * struct efx_tx_buffer - buffer state for a TX descriptor
+ * @skb: When @flags & %EFX_TX_BUF_SKB, the associated socket buffer to be
+ *	freed when descriptor completes
+ * @tsoh: When @flags & %EFX_TX_BUF_TSOH, the associated TSO header structure.
  * @dma_addr: DMA address of the fragment.
+ * @flags: Flags for allocation and DMA mapping type
  * @len: Length of this fragment.
  *	This field is zero when the queue slot is empty.
- * @continuation: True if this fragment is not the end of a packet.
- * @unmap_single: True if dma_unmap_single should be used.
  * @unmap_len: Length of this fragment to unmap
  */
 struct efx_tx_buffer {
-	const struct sk_buff *skb;
-	struct efx_tso_header *tsoh;
+	union {
+		const struct sk_buff *skb;
+		struct efx_tso_header *tsoh;
+	};
 	dma_addr_t dma_addr;
+	unsigned short flags;
 	unsigned short len;
-	bool continuation;
-	bool unmap_single;
 	unsigned short unmap_len;
 };
+#define EFX_TX_BUF_CONT		1	/* not last descriptor of packet */
+#define EFX_TX_BUF_SKB		2	/* buffer is last part of skb */
+#define EFX_TX_BUF_TSOH		4	/* buffer is TSO header */
+#define EFX_TX_BUF_MAP_SINGLE	8	/* buffer was mapped with dma_map_single() */
 
 /**
  * struct efx_tx_queue - An Efx TX queue
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 326d799..aa11370 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -401,8 +401,10 @@ void efx_nic_push_buffers(struct efx_tx_queue *tx_queue)
 		++tx_queue->write_count;
 
 		/* Create TX descriptor ring entry */
+		BUILD_BUG_ON(EFX_TX_BUF_CONT != 1);
 		EFX_POPULATE_QWORD_4(*txd,
-				     FSF_AZ_TX_KER_CONT, buffer->continuation,
+				     FSF_AZ_TX_KER_CONT,
+				     buffer->flags & EFX_TX_BUF_CONT,
 				     FSF_AZ_TX_KER_BYTE_COUNT, buffer->len,
 				     FSF_AZ_TX_KER_BUF_REGION, 0,
 				     FSF_AZ_TX_KER_BUF_ADDR, buffer->dma_addr);
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 1871343..24c82f3 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -39,25 +39,25 @@ static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 		struct device *dma_dev = &tx_queue->efx->pci_dev->dev;
 		dma_addr_t unmap_addr = (buffer->dma_addr + buffer->len -
 					 buffer->unmap_len);
-		if (buffer->unmap_single)
+		if (buffer->flags & EFX_TX_BUF_MAP_SINGLE)
 			dma_unmap_single(dma_dev, unmap_addr, buffer->unmap_len,
 					 DMA_TO_DEVICE);
 		else
 			dma_unmap_page(dma_dev, unmap_addr, buffer->unmap_len,
 				       DMA_TO_DEVICE);
 		buffer->unmap_len = 0;
-		buffer->unmap_single = false;
 	}
 
-	if (buffer->skb) {
+	if (buffer->flags & EFX_TX_BUF_SKB) {
 		(*pkts_compl)++;
 		(*bytes_compl) += buffer->skb->len;
 		dev_kfree_skb_any((struct sk_buff *) buffer->skb);
-		buffer->skb = NULL;
 		netif_vdbg(tx_queue->efx, tx_done, tx_queue->efx->net_dev,
 			   "TX queue %d transmission id %x complete\n",
 			   tx_queue->queue, tx_queue->read_count);
 	}
+
+	buffer->flags &= EFX_TX_BUF_TSOH;
 }
 
 /**
@@ -89,14 +89,14 @@ static void efx_tsoh_heap_free(struct efx_tx_queue *tx_queue,
 static void efx_tsoh_free(struct efx_tx_queue *tx_queue,
 			  struct efx_tx_buffer *buffer)
 {
-	if (buffer->tsoh) {
+	if (buffer->flags & EFX_TX_BUF_TSOH) {
 		if (likely(!buffer->tsoh->unmap_len)) {
 			buffer->tsoh->next = tx_queue->tso_headers_free;
 			tx_queue->tso_headers_free = buffer->tsoh;
 		} else {
 			efx_tsoh_heap_free(tx_queue, buffer->tsoh);
 		}
-		buffer->tsoh = NULL;
+		buffer->flags &= ~EFX_TX_BUF_TSOH;
 	}
 }
 
@@ -163,7 +163,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	unsigned int len, unmap_len = 0, fill_level, insert_ptr;
 	dma_addr_t dma_addr, unmap_addr = 0;
 	unsigned int dma_len;
-	bool unmap_single;
+	unsigned short dma_flags;
 	int q_space, i = 0;
 	netdev_tx_t rc = NETDEV_TX_OK;
 
@@ -190,7 +190,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 	 * since this is more efficient on machines with sparse
 	 * memory.
 	 */
-	unmap_single = true;
+	dma_flags = EFX_TX_BUF_MAP_SINGLE;
 	dma_addr = dma_map_single(dma_dev, skb->data, len, PCI_DMA_TODEVICE);
 
 	/* Process all fragments */
@@ -234,10 +234,8 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 			insert_ptr = tx_queue->insert_count & tx_queue->ptr_mask;
 			buffer = &tx_queue->buffer[insert_ptr];
 			efx_tsoh_free(tx_queue, buffer);
-			EFX_BUG_ON_PARANOID(buffer->tsoh);
-			EFX_BUG_ON_PARANOID(buffer->skb);
+			EFX_BUG_ON_PARANOID(buffer->flags);
 			EFX_BUG_ON_PARANOID(buffer->len);
-			EFX_BUG_ON_PARANOID(!buffer->continuation);
 			EFX_BUG_ON_PARANOID(buffer->unmap_len);
 
 			dma_len = efx_max_tx_len(efx, dma_addr);
@@ -247,13 +245,14 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 			/* Fill out per descriptor fields */
 			buffer->len = dma_len;
 			buffer->dma_addr = dma_addr;
+			buffer->flags = EFX_TX_BUF_CONT;
 			len -= dma_len;
 			dma_addr += dma_len;
 			++tx_queue->insert_count;
 		} while (len);
 
 		/* Transfer ownership of the unmapping to the final buffer */
-		buffer->unmap_single = unmap_single;
+		buffer->flags = EFX_TX_BUF_CONT | dma_flags;
 		buffer->unmap_len = unmap_len;
 		unmap_len = 0;
 
@@ -264,14 +263,14 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 		len = skb_frag_size(fragment);
 		i++;
 		/* Map for DMA */
-		unmap_single = false;
+		dma_flags = 0;
 		dma_addr = skb_frag_dma_map(dma_dev, fragment, 0, len,
 					    DMA_TO_DEVICE);
 	}
 
 	/* Transfer ownership of the skb to the final buffer */
 	buffer->skb = skb;
-	buffer->continuation = false;
+	buffer->flags = EFX_TX_BUF_SKB | dma_flags;
 
 	netdev_tx_sent_queue(tx_queue->core_txq, skb->len);
 
@@ -302,7 +301,7 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 
 	/* Free the fragment we were mid-way through pushing */
 	if (unmap_len) {
-		if (unmap_single)
+		if (dma_flags & EFX_TX_BUF_MAP_SINGLE)
 			dma_unmap_single(dma_dev, unmap_addr, unmap_len,
 					 DMA_TO_DEVICE);
 		else
@@ -340,7 +339,6 @@ static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
 		}
 
 		efx_dequeue_buffer(tx_queue, buffer, pkts_compl, bytes_compl);
-		buffer->continuation = true;
 		buffer->len = 0;
 
 		++tx_queue->read_count;
@@ -484,7 +482,7 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 {
 	struct efx_nic *efx = tx_queue->efx;
 	unsigned int entries;
-	int i, rc;
+	int rc;
 
 	/* Create the smallest power-of-two aligned ring */
 	entries = max(roundup_pow_of_two(efx->txq_entries), EFX_MIN_DMAQ_SIZE);
@@ -500,8 +498,6 @@ int efx_probe_tx_queue(struct efx_tx_queue *tx_queue)
 				   GFP_KERNEL);
 	if (!tx_queue->buffer)
 		return -ENOMEM;
-	for (i = 0; i <= tx_queue->ptr_mask; ++i)
-		tx_queue->buffer[i].continuation = true;
 
 	/* Allocate hardware ring */
 	rc = efx_nic_probe_tx(tx_queue);
@@ -546,7 +542,6 @@ void efx_release_tx_buffers(struct efx_tx_queue *tx_queue)
 		unsigned int pkts_compl = 0, bytes_compl = 0;
 		buffer = &tx_queue->buffer[tx_queue->read_count & tx_queue->ptr_mask];
 		efx_dequeue_buffer(tx_queue, buffer, &pkts_compl, &bytes_compl);
-		buffer->continuation = true;
 		buffer->len = 0;
 
 		++tx_queue->read_count;
@@ -631,7 +626,7 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
  * @in_len: Remaining length in current SKB fragment
  * @unmap_len: Length of SKB fragment
  * @unmap_addr: DMA address of SKB fragment
- * @unmap_single: DMA single vs page mapping flag
+ * @dma_flags: TX buffer flags for DMA mapping - %EFX_TX_BUF_MAP_SINGLE or 0
  * @protocol: Network protocol (after any VLAN header)
  * @header_len: Number of bytes of header
  * @full_packet_size: Number of bytes to put in each outgoing segment
@@ -651,7 +646,7 @@ struct tso_state {
 	unsigned in_len;
 	unsigned unmap_len;
 	dma_addr_t unmap_addr;
-	bool unmap_single;
+	unsigned short dma_flags;
 
 	__be16 protocol;
 	unsigned header_len;
@@ -833,9 +828,7 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 		efx_tsoh_free(tx_queue, buffer);
 		EFX_BUG_ON_PARANOID(buffer->len);
 		EFX_BUG_ON_PARANOID(buffer->unmap_len);
-		EFX_BUG_ON_PARANOID(buffer->skb);
-		EFX_BUG_ON_PARANOID(!buffer->continuation);
-		EFX_BUG_ON_PARANOID(buffer->tsoh);
+		EFX_BUG_ON_PARANOID(buffer->flags);
 
 		buffer->dma_addr = dma_addr;
 
@@ -845,7 +838,8 @@ static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
 		if (dma_len >= len)
 			break;
 
-		buffer->len = dma_len; /* Don't set the other members */
+		buffer->len = dma_len;
+		buffer->flags = EFX_TX_BUF_CONT;
 		dma_addr += dma_len;
 		len -= dma_len;
 	}
@@ -873,12 +867,11 @@ static void efx_tso_put_header(struct efx_tx_queue *tx_queue,
 	efx_tsoh_free(tx_queue, buffer);
 	EFX_BUG_ON_PARANOID(buffer->len);
 	EFX_BUG_ON_PARANOID(buffer->unmap_len);
-	EFX_BUG_ON_PARANOID(buffer->skb);
-	EFX_BUG_ON_PARANOID(!buffer->continuation);
-	EFX_BUG_ON_PARANOID(buffer->tsoh);
+	EFX_BUG_ON_PARANOID(buffer->flags);
 	buffer->len = len;
 	buffer->dma_addr = tsoh->dma_addr;
 	buffer->tsoh = tsoh;
+	buffer->flags = EFX_TX_BUF_TSOH | EFX_TX_BUF_CONT;
 
 	++tx_queue->insert_count;
 }
@@ -896,11 +889,11 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 		buffer = &tx_queue->buffer[tx_queue->insert_count &
 					   tx_queue->ptr_mask];
 		efx_tsoh_free(tx_queue, buffer);
-		EFX_BUG_ON_PARANOID(buffer->skb);
+		EFX_BUG_ON_PARANOID(buffer->flags & EFX_TX_BUF_SKB);
 		if (buffer->unmap_len) {
 			unmap_addr = (buffer->dma_addr + buffer->len -
 				      buffer->unmap_len);
-			if (buffer->unmap_single)
+			if (buffer->flags & EFX_TX_BUF_MAP_SINGLE)
 				dma_unmap_single(&tx_queue->efx->pci_dev->dev,
 						 unmap_addr, buffer->unmap_len,
 						 DMA_TO_DEVICE);
@@ -911,7 +904,7 @@ static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
 			buffer->unmap_len = 0;
 		}
 		buffer->len = 0;
-		buffer->continuation = true;
+		buffer->flags = 0;
 	}
 }
 
@@ -938,7 +931,7 @@ static void tso_start(struct tso_state *st, const struct sk_buff *skb)
 
 	st->out_len = skb->len - st->header_len;
 	st->unmap_len = 0;
-	st->unmap_single = false;
+	st->dma_flags = 0;
 }
 
 static int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
@@ -947,7 +940,7 @@ static int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
 	st->unmap_addr = skb_frag_dma_map(&efx->pci_dev->dev, frag, 0,
 					  skb_frag_size(frag), DMA_TO_DEVICE);
 	if (likely(!dma_mapping_error(&efx->pci_dev->dev, st->unmap_addr))) {
-		st->unmap_single = false;
+		st->dma_flags = 0;
 		st->unmap_len = skb_frag_size(frag);
 		st->in_len = skb_frag_size(frag);
 		st->dma_addr = st->unmap_addr;
@@ -965,7 +958,7 @@ static int tso_get_head_fragment(struct tso_state *st, struct efx_nic *efx,
 	st->unmap_addr = dma_map_single(&efx->pci_dev->dev, skb->data + hl,
 					len, DMA_TO_DEVICE);
 	if (likely(!dma_mapping_error(&efx->pci_dev->dev, st->unmap_addr))) {
-		st->unmap_single = true;
+		st->dma_flags = EFX_TX_BUF_MAP_SINGLE;
 		st->unmap_len = len;
 		st->in_len = len;
 		st->dma_addr = st->unmap_addr;
@@ -990,7 +983,7 @@ static int tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
 					 struct tso_state *st)
 {
 	struct efx_tx_buffer *buffer;
-	int n, end_of_packet, rc;
+	int n, rc;
 
 	if (st->in_len == 0)
 		return 0;
@@ -1008,17 +1001,18 @@ static int tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
 
 	rc = efx_tx_queue_insert(tx_queue, st->dma_addr, n, &buffer);
 	if (likely(rc == 0)) {
-		if (st->out_len == 0)
+		if (st->out_len == 0) {
 			/* Transfer ownership of the skb */
 			buffer->skb = skb;
-
-		end_of_packet = st->out_len == 0 || st->packet_space == 0;
-		buffer->continuation = !end_of_packet;
+			buffer->flags = EFX_TX_BUF_SKB;
+		} else if (st->packet_space != 0) {
+			buffer->flags = EFX_TX_BUF_CONT;
+		}
 
 		if (st->in_len == 0) {
 			/* Transfer ownership of the DMA mapping */
 			buffer->unmap_len = st->unmap_len;
-			buffer->unmap_single = st->unmap_single;
+			buffer->flags |= st->dma_flags;
 			st->unmap_len = 0;
 		}
 	}
@@ -1195,7 +1189,7 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
  unwind:
 	/* Free the DMA mapping we were in the process of writing out */
 	if (state.unmap_len) {
-		if (state.unmap_single)
+		if (state.dma_flags & EFX_TX_BUF_MAP_SINGLE)
 			dma_unmap_single(&efx->pci_dev->dev, state.unmap_addr,
 					 state.unmap_len, DMA_TO_DEVICE);
 		else
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
