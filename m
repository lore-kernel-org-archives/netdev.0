From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 19/52] sfc: Cleaned up struct tso_state fields
Date: Mon, 1 Sep 2008 12:47:02 +0100
Message-ID: <20080901114701.GM7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:56605 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757484AbYIALrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:47:05 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Squashed nested structures.

Renamed remaining_len to out_len, ifc.len to in_len, header_length to
header_len.

Moved ipv4_id into the group of output variables where it belongs.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tx.c |  161 +++++++++++++++++++++++---------------------------
 1 files changed, 75 insertions(+), 86 deletions(-)

diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index 51429b6..550856f 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -540,46 +540,37 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 
 /**
  * struct tso_state - TSO state for an SKB
- * @remaining_len: Bytes of data we've yet to segment
+ * @out_len: Remaining length in current segment
  * @seqnum: Current sequence number
+ * @ipv4_id: Current IPv4 ID, host endian
  * @packet_space: Remaining space in current packet
- * @ifc: Input fragment cursor.
- *	Where we are in the current fragment of the incoming SKB.  These
- *	values get updated in place when we split a fragment over
- *	multiple packets.
- * @p: Parameters.
- *	These values are set once at the start of the TSO send and do
- *	not get changed as the routine progresses.
+ * @dma_addr: DMA address of current position
+ * @in_len: Remaining length in current SKB fragment
+ * @unmap_len: Length of SKB fragment
+ * @unmap_addr: DMA address of SKB fragment
+ * @unmap_single: DMA single vs page mapping flag
+ * @header_len: Number of bytes of header
+ * @full_packet_size: Number of bytes to put in each outgoing segment
  *
  * The state used during segmentation.  It is put into this data structure
  * just to make it easy to pass into inline functions.
  */
 struct tso_state {
-	unsigned remaining_len;
+	/* Output position */
+	unsigned out_len;
 	unsigned seqnum;
+	unsigned ipv4_id;
 	unsigned packet_space;
 
-	struct {
-		/* DMA address of current position */
-		dma_addr_t dma_addr;
-		/* Remaining length */
-		unsigned int len;
-		/* DMA address and length of the whole fragment */
-		unsigned int unmap_len;
-		dma_addr_t unmap_addr;
-		bool unmap_single;
-	} ifc;
-
-	struct {
-		/* The number of bytes of header */
-		unsigned int header_length;
-
-		/* The number of bytes to put in each outgoing segment. */
-		int full_packet_size;
-
-		/* Current IPv4 ID, host endian. */
-		unsigned ipv4_id;
-	} p;
+	/* Input position */
+	dma_addr_t dma_addr;
+	unsigned in_len;
+	unsigned unmap_len;
+	dma_addr_t unmap_addr;
+	bool unmap_single;
+
+	unsigned header_len;
+	int full_packet_size;
 };
 
 
@@ -840,35 +831,34 @@ static inline void tso_start(struct tso_state *st, const struct sk_buff *skb)
 	/* All ethernet/IP/TCP headers combined size is TCP header size
 	 * plus offset of TCP header relative to start of packet.
 	 */
-	st->p.header_length = ((tcp_hdr(skb)->doff << 2u)
-			       + PTR_DIFF(tcp_hdr(skb), skb->data));
-	st->p.full_packet_size = (st->p.header_length
-				  + skb_shinfo(skb)->gso_size);
+	st->header_len = ((tcp_hdr(skb)->doff << 2u)
+			  + PTR_DIFF(tcp_hdr(skb), skb->data));
+	st->full_packet_size = st->header_len + skb_shinfo(skb)->gso_size;
 
-	st->p.ipv4_id = ntohs(ip_hdr(skb)->id);
+	st->ipv4_id = ntohs(ip_hdr(skb)->id);
 	st->seqnum = ntohl(tcp_hdr(skb)->seq);
 
 	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->urg);
 	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->syn);
 	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->rst);
 
-	st->packet_space = st->p.full_packet_size;
-	st->remaining_len = skb->len - st->p.header_length;
-	st->ifc.unmap_len = 0;
-	st->ifc.unmap_single = false;
+	st->packet_space = st->full_packet_size;
+	st->out_len = skb->len - st->header_len;
+	st->unmap_len = 0;
+	st->unmap_single = false;
 }
 
 static inline int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
 				   skb_frag_t *frag)
 {
-	st->ifc.unmap_addr = pci_map_page(efx->pci_dev, frag->page,
-					  frag->page_offset, frag->size,
-					  PCI_DMA_TODEVICE);
-	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->ifc.unmap_addr))) {
-		st->ifc.unmap_single = false;
-		st->ifc.unmap_len = frag->size;
-		st->ifc.len = frag->size;
-		st->ifc.dma_addr = st->ifc.unmap_addr;
+	st->unmap_addr = pci_map_page(efx->pci_dev, frag->page,
+				      frag->page_offset, frag->size,
+				      PCI_DMA_TODEVICE);
+	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->unmap_addr))) {
+		st->unmap_single = false;
+		st->unmap_len = frag->size;
+		st->in_len = frag->size;
+		st->dma_addr = st->unmap_addr;
 		return 0;
 	}
 	return -ENOMEM;
@@ -878,16 +868,16 @@ static inline int
 tso_get_head_fragment(struct tso_state *st, struct efx_nic *efx,
 		      const struct sk_buff *skb)
 {
-	int hl = st->p.header_length;
+	int hl = st->header_len;
 	int len = skb_headlen(skb) - hl;
 
-	st->ifc.unmap_addr = pci_map_single(efx->pci_dev, skb->data + hl,
-					    len, PCI_DMA_TODEVICE);
-	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->ifc.unmap_addr))) {
-		st->ifc.unmap_single = true;
-		st->ifc.unmap_len = len;
-		st->ifc.len = len;
-		st->ifc.dma_addr = st->ifc.unmap_addr;
+	st->unmap_addr = pci_map_single(efx->pci_dev, skb->data + hl,
+					len, PCI_DMA_TODEVICE);
+	if (likely(!pci_dma_mapping_error(efx->pci_dev, st->unmap_addr))) {
+		st->unmap_single = true;
+		st->unmap_len = len;
+		st->in_len = len;
+		st->dma_addr = st->unmap_addr;
 		return 0;
 	}
 	return -ENOMEM;
@@ -911,38 +901,38 @@ static inline int tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
 	struct efx_tx_buffer *buffer;
 	int n, end_of_packet, rc;
 
-	if (st->ifc.len == 0)
+	if (st->in_len == 0)
 		return 0;
 	if (st->packet_space == 0)
 		return 0;
 
-	EFX_BUG_ON_PARANOID(st->ifc.len <= 0);
+	EFX_BUG_ON_PARANOID(st->in_len <= 0);
 	EFX_BUG_ON_PARANOID(st->packet_space <= 0);
 
-	n = min(st->ifc.len, st->packet_space);
+	n = min(st->in_len, st->packet_space);
 
 	st->packet_space -= n;
-	st->remaining_len -= n;
-	st->ifc.len -= n;
+	st->out_len -= n;
+	st->in_len -= n;
 
-	rc = efx_tx_queue_insert(tx_queue, st->ifc.dma_addr, n, &buffer);
+	rc = efx_tx_queue_insert(tx_queue, st->dma_addr, n, &buffer);
 	if (likely(rc == 0)) {
-		if (st->remaining_len == 0)
+		if (st->out_len == 0)
 			/* Transfer ownership of the skb */
 			buffer->skb = skb;
 
-		end_of_packet = st->remaining_len == 0 || st->packet_space == 0;
+		end_of_packet = st->out_len == 0 || st->packet_space == 0;
 		buffer->continuation = !end_of_packet;
 
-		if (st->ifc.len == 0) {
+		if (st->in_len == 0) {
 			/* Transfer ownership of the pci mapping */
-			buffer->unmap_len = st->ifc.unmap_len;
-			buffer->unmap_single = st->ifc.unmap_single;
-			st->ifc.unmap_len = 0;
+			buffer->unmap_len = st->unmap_len;
+			buffer->unmap_single = st->unmap_single;
+			st->unmap_len = 0;
 		}
 	}
 
-	st->ifc.dma_addr += n;
+	st->dma_addr += n;
 	return rc;
 }
 
@@ -967,7 +957,7 @@ static inline int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 	u8 *header;
 
 	/* Allocate a DMA-mapped header buffer. */
-	if (likely(TSOH_SIZE(st->p.header_length) <= TSOH_STD_SIZE)) {
+	if (likely(TSOH_SIZE(st->header_len) <= TSOH_STD_SIZE)) {
 		if (tx_queue->tso_headers_free == NULL) {
 			if (efx_tsoh_block_alloc(tx_queue))
 				return -1;
@@ -978,7 +968,7 @@ static inline int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 		tsoh->unmap_len = 0;
 	} else {
 		tx_queue->tso_long_headers++;
-		tsoh = efx_tsoh_heap_alloc(tx_queue, st->p.header_length);
+		tsoh = efx_tsoh_heap_alloc(tx_queue, st->header_len);
 		if (unlikely(!tsoh))
 			return -1;
 	}
@@ -988,33 +978,32 @@ static inline int tso_start_new_packet(struct efx_tx_queue *tx_queue,
 	tsoh_iph = (struct iphdr *)(header + SKB_IPV4_OFF(skb));
 
 	/* Copy and update the headers. */
-	memcpy(header, skb->data, st->p.header_length);
+	memcpy(header, skb->data, st->header_len);
 
 	tsoh_th->seq = htonl(st->seqnum);
 	st->seqnum += skb_shinfo(skb)->gso_size;
-	if (st->remaining_len > skb_shinfo(skb)->gso_size) {
+	if (st->out_len > skb_shinfo(skb)->gso_size) {
 		/* This packet will not finish the TSO burst. */
-		ip_length = st->p.full_packet_size - ETH_HDR_LEN(skb);
+		ip_length = st->full_packet_size - ETH_HDR_LEN(skb);
 		tsoh_th->fin = 0;
 		tsoh_th->psh = 0;
 	} else {
 		/* This packet will be the last in the TSO burst. */
-		ip_length = (st->p.header_length - ETH_HDR_LEN(skb)
-			     + st->remaining_len);
+		ip_length = st->header_len - ETH_HDR_LEN(skb) + st->out_len;
 		tsoh_th->fin = tcp_hdr(skb)->fin;
 		tsoh_th->psh = tcp_hdr(skb)->psh;
 	}
 	tsoh_iph->tot_len = htons(ip_length);
 
 	/* Linux leaves suitable gaps in the IP ID space for us to fill. */
-	tsoh_iph->id = htons(st->p.ipv4_id);
-	st->p.ipv4_id++;
+	tsoh_iph->id = htons(st->ipv4_id);
+	st->ipv4_id++;
 
 	st->packet_space = skb_shinfo(skb)->gso_size;
 	++tx_queue->tso_packets;
 
 	/* Form a descriptor for this header. */
-	efx_tso_put_header(tx_queue, tsoh, st->p.header_length);
+	efx_tso_put_header(tx_queue, tsoh, st->header_len);
 
 	return 0;
 }
@@ -1048,7 +1037,7 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 	/* Assume that skb header area contains exactly the headers, and
 	 * all payload is in the frag list.
 	 */
-	if (skb_headlen(skb) == state.p.header_length) {
+	if (skb_headlen(skb) == state.header_len) {
 		/* Grab the first payload fragment. */
 		EFX_BUG_ON_PARANOID(skb_shinfo(skb)->nr_frags < 1);
 		frag_i = 0;
@@ -1072,7 +1061,7 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 			goto stop;
 
 		/* Move onto the next fragment? */
-		if (state.ifc.len == 0) {
+		if (state.in_len == 0) {
 			if (++frag_i >= skb_shinfo(skb)->nr_frags)
 				/* End of payload reached. */
 				break;
@@ -1108,13 +1097,13 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
 
  unwind:
 	/* Free the DMA mapping we were in the process of writing out */
-	if (state.ifc.unmap_len) {
-		if (state.ifc.unmap_single)
-			pci_unmap_single(efx->pci_dev, state.ifc.unmap_addr,
-					 state.ifc.unmap_len, PCI_DMA_TODEVICE);
+	if (state.unmap_len) {
+		if (state.unmap_single)
+			pci_unmap_single(efx->pci_dev, state.unmap_addr,
+					 state.unmap_len, PCI_DMA_TODEVICE);
 		else
-			pci_unmap_page(efx->pci_dev, state.ifc.unmap_addr,
-				       state.ifc.unmap_len, PCI_DMA_TODEVICE);
+			pci_unmap_page(efx->pci_dev, state.unmap_addr,
+				       state.unmap_len, PCI_DMA_TODEVICE);
 	}
 
 	efx_enqueue_unwind(tx_queue);
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

