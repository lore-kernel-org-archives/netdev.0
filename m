From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/9] Add TSO support
Date: Wed, 7 May 2008 12:51:12 +0100
Message-ID: <20080507115112.GM2217@solarflare.com>
References: <20080507114121.GL2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:55708 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752489AbYEGLvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 07:51:42 -0400
Content-Disposition: inline
In-Reply-To: <20080507114121.GL2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SFC4000 controller does not have hardware support for TSO, and the
core GSO code incurs a high cost in allocating and freeing skbs.  This
TSO implementation uses lightweight packet header structures and is
substantially faster.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    4 +-
 drivers/net/sfc/ethtool.c    |   27 ++
 drivers/net/sfc/net_driver.h |   14 +
 drivers/net/sfc/tx.c         |  664 ++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 708 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 59edcf7..418f2e5 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1873,6 +1873,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 		tx_queue->queue = i;
 		tx_queue->buffer = NULL;
 		tx_queue->channel = &efx->channel[0]; /* for safety */
+		tx_queue->tso_headers_free = NULL;
 	}
 	for (i = 0; i < EFX_MAX_RX_QUEUES; i++) {
 		rx_queue = &efx->rx_queue[i];
@@ -2071,7 +2072,8 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	net_dev = alloc_etherdev(sizeof(*efx));
 	if (!net_dev)
 		return -ENOMEM;
-	net_dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_HIGHDMA;
+	net_dev->features |= (NETIF_F_IP_CSUM | NETIF_F_SG |
+			      NETIF_F_HIGHDMA | NETIF_F_TSO);
 	if (lro)
 		net_dev->features |= NETIF_F_LRO;
 	efx = net_dev->priv;
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index ad541ba..b756840 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -272,6 +272,22 @@ static void efx_ethtool_get_stats(struct net_device *net_dev,
 	}
 }
 
+static int efx_ethtool_set_tso(struct net_device *net_dev, u32 enable)
+{
+	int rc;
+
+	/* Our TSO requires TX checksumming, so force TX checksumming
+	 * on when TSO is enabled.
+	 */
+	if (enable) {
+		rc = efx_ethtool_set_tx_csum(net_dev, 1);
+		if (rc)
+			return rc;
+	}
+
+	return ethtool_op_set_tso(net_dev, enable);
+}
+
 static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable)
 {
 	struct efx_nic *efx = net_dev->priv;
@@ -283,6 +299,15 @@ static int efx_ethtool_set_tx_csum(struct net_device *net_dev, u32 enable)
 
 	efx_flush_queues(efx);
 
+	/* Our TSO requires TX checksumming, so disable TSO when
+	 * checksumming is disabled
+	 */
+	if (!enable) {
+		rc = efx_ethtool_set_tso(net_dev, 0);
+		if (rc)
+			return rc;
+	}
+
 	return 0;
 }
 
@@ -451,6 +476,8 @@ struct ethtool_ops efx_ethtool_ops = {
 	.set_tx_csum		= efx_ethtool_set_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
+	.get_tso		= ethtool_op_get_tso,
+	.set_tso		= efx_ethtool_set_tso,
 	.get_flags		= ethtool_op_get_flags,
 	.set_flags		= ethtool_op_set_flags,
 	.get_strings		= efx_ethtool_get_strings,
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index c505482..6ffa711 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -134,6 +134,8 @@ struct efx_special_buffer {
  *	Set only on the final fragment of a packet; %NULL for all other
  *	fragments.  When this fragment completes, then we can free this
  *	skb.
+ * @tsoh: The associated TSO header structure, or %NULL if this
+ *	buffer is not a TSO header.
  * @dma_addr: DMA address of the fragment.
  * @len: Length of this fragment.
  *	This field is zero when the queue slot is empty.
@@ -144,6 +146,7 @@ struct efx_special_buffer {
  */
 struct efx_tx_buffer {
 	const struct sk_buff *skb;
+	struct efx_tso_header *tsoh;
 	dma_addr_t dma_addr;
 	unsigned short len;
 	unsigned char continuation;
@@ -187,6 +190,13 @@ struct efx_tx_buffer {
  *	variable indicates that the queue is full.  This is to
  *	avoid cache-line ping-pong between the xmit path and the
  *	completion path.
+ * @tso_headers_free: A list of TSO headers allocated for this TX queue
+ *	that are not in use, and so available for new TSO sends. The list
+ *	is protected by the TX queue lock.
+ * @tso_bursts: Number of times TSO xmit invoked by kernel
+ * @tso_long_headers: Number of packets with headers too long for standard
+ *	blocks
+ * @tso_packets: Number of packets via the TSO xmit path
  */
 struct efx_tx_queue {
 	/* Members which don't change on the fast path */
@@ -206,6 +216,10 @@ struct efx_tx_queue {
 	unsigned int insert_count ____cacheline_aligned_in_smp;
 	unsigned int write_count;
 	unsigned int old_read_count;
+	struct efx_tso_header *tso_headers_free;
+	unsigned int tso_bursts;
+	unsigned int tso_long_headers;
+	unsigned int tso_packets;
 };
 
 /**
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index fbb866b..9b436f5 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -82,6 +82,46 @@ static inline void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
 	}
 }
 
+/**
+ * struct efx_tso_header - a DMA mapped buffer for packet headers
+ * @next: Linked list of free ones.
+ *	The list is protected by the TX queue lock.
+ * @dma_unmap_len: Length to unmap for an oversize buffer, or 0.
+ * @dma_addr: The DMA address of the header below.
+ *
+ * This controls the memory used for a TSO header.  Use TSOH_DATA()
+ * to find the packet header data.  Use TSOH_SIZE() to calculate the
+ * total size required for a given packet header length.  TSO headers
+ * in the free list are exactly %TSOH_STD_SIZE bytes in size.
+ */
+struct efx_tso_header {
+	union {
+		struct efx_tso_header *next;
+		size_t unmap_len;
+	};
+	dma_addr_t dma_addr;
+};
+
+static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
+			       const struct sk_buff *skb);
+static void efx_fini_tso(struct efx_tx_queue *tx_queue);
+static void efx_tsoh_heap_free(struct efx_tx_queue *tx_queue,
+			       struct efx_tso_header *tsoh);
+
+static inline void efx_tsoh_free(struct efx_tx_queue *tx_queue,
+				 struct efx_tx_buffer *buffer)
+{
+	if (buffer->tsoh) {
+		if (likely(!buffer->tsoh->unmap_len)) {
+			buffer->tsoh->next = tx_queue->tso_headers_free;
+			tx_queue->tso_headers_free = buffer->tsoh;
+		} else {
+			efx_tsoh_heap_free(tx_queue, buffer->tsoh);
+		}
+		buffer->tsoh = NULL;
+	}
+}
+
 
 /*
  * Add a socket buffer to a TX queue
@@ -114,6 +154,9 @@ static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 
 	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
 
+	if (skb_shinfo((struct sk_buff *)skb)->gso_size)
+		return efx_enqueue_skb_tso(tx_queue, skb);
+
 	/* Get size of the initial fragment */
 	len = skb_headlen(skb);
 
@@ -166,6 +209,8 @@ static inline int efx_enqueue_skb(struct efx_tx_queue *tx_queue,
 			insert_ptr = (tx_queue->insert_count &
 				      efx->type->txd_ring_mask);
 			buffer = &tx_queue->buffer[insert_ptr];
+			efx_tsoh_free(tx_queue, buffer);
+			EFX_BUG_ON_PARANOID(buffer->tsoh);
 			EFX_BUG_ON_PARANOID(buffer->skb);
 			EFX_BUG_ON_PARANOID(buffer->len);
 			EFX_BUG_ON_PARANOID(buffer->continuation != 1);
@@ -432,6 +477,9 @@ void efx_fini_tx_queue(struct efx_tx_queue *tx_queue)
 
 	efx_release_tx_buffers(tx_queue);
 
+	/* Free up TSO header cache */
+	efx_fini_tso(tx_queue);
+
 	/* Release queue's stop on port, if any */
 	if (tx_queue->stopped) {
 		tx_queue->stopped = 0;
@@ -450,3 +498,619 @@ void efx_remove_tx_queue(struct efx_tx_queue *tx_queue)
 }
 
 
+/* Efx TCP segmentation acceleration.
+ *
+ * Why?  Because by doing it here in the driver we can go significantly
+ * faster than the GSO.
+ *
+ * Requires TX checksum offload support.
+ */
+
+/* Number of bytes inserted at the start of a TSO header buffer,
+ * similar to NET_IP_ALIGN.
+ */
+#if defined(__i386__) || defined(__x86_64__)
+#define TSOH_OFFSET	0
+#else
+#define TSOH_OFFSET	NET_IP_ALIGN
+#endif
+
+#define TSOH_BUFFER(tsoh)	((u8 *)(tsoh + 1) + TSOH_OFFSET)
+
+/* Total size of struct efx_tso_header, buffer and padding */
+#define TSOH_SIZE(hdr_len)					\
+	(sizeof(struct efx_tso_header) + TSOH_OFFSET + hdr_len)
+
+/* Size of blocks on free list.  Larger blocks must be allocated from
+ * the heap.
+ */
+#define TSOH_STD_SIZE		128
+
+#define PTR_DIFF(p1, p2)  ((u8 *)(p1) - (u8 *)(p2))
+#define ETH_HDR_LEN(skb)  (skb_network_header(skb) - (skb)->data)
+#define SKB_TCP_OFF(skb)  PTR_DIFF(tcp_hdr(skb), (skb)->data)
+#define SKB_IPV4_OFF(skb) PTR_DIFF(ip_hdr(skb), (skb)->data)
+
+/**
+ * struct tso_state - TSO state for an SKB
+ * @remaining_len: Bytes of data we've yet to segment
+ * @seqnum: Current sequence number
+ * @packet_space: Remaining space in current packet
+ * @ifc: Input fragment cursor.
+ *	Where we are in the current fragment of the incoming SKB.  These
+ *	values get updated in place when we split a fragment over
+ *	multiple packets.
+ * @p: Parameters.
+ *	These values are set once at the start of the TSO send and do
+ *	not get changed as the routine progresses.
+ *
+ * The state used during segmentation.  It is put into this data structure
+ * just to make it easy to pass into inline functions.
+ */
+struct tso_state {
+	unsigned remaining_len;
+	unsigned seqnum;
+	unsigned packet_space;
+
+	struct {
+		/* DMA address of current position */
+		dma_addr_t dma_addr;
+		/* Remaining length */
+		unsigned int len;
+		/* DMA address and length of the whole fragment */
+		unsigned int unmap_len;
+		dma_addr_t unmap_addr;
+		struct page *page;
+		unsigned page_off;
+	} ifc;
+
+	struct {
+		/* The number of bytes of header */
+		unsigned int header_length;
+
+		/* The number of bytes to put in each outgoing segment. */
+		int full_packet_size;
+
+		/* Current IPv4 ID, host endian. */
+		unsigned ipv4_id;
+	} p;
+};
+
+
+/*
+ * Verify that our various assumptions about sk_buffs and the conditions
+ * under which TSO will be attempted hold true.
+ */
+static inline void efx_tso_check_safe(const struct sk_buff *skb)
+{
+	EFX_BUG_ON_PARANOID(skb->protocol != htons(ETH_P_IP));
+	EFX_BUG_ON_PARANOID(((struct ethhdr *)skb->data)->h_proto !=
+			    skb->protocol);
+	EFX_BUG_ON_PARANOID(ip_hdr(skb)->protocol != IPPROTO_TCP);
+	EFX_BUG_ON_PARANOID((PTR_DIFF(tcp_hdr(skb), skb->data)
+			     + (tcp_hdr(skb)->doff << 2u)) >
+			    skb_headlen(skb));
+}
+
+
+/*
+ * Allocate a page worth of efx_tso_header structures, and string them
+ * into the tx_queue->tso_headers_free linked list. Return 0 or -ENOMEM.
+ */
+static int efx_tsoh_block_alloc(struct efx_tx_queue *tx_queue)
+{
+
+	struct pci_dev *pci_dev = tx_queue->efx->pci_dev;
+	struct efx_tso_header *tsoh;
+	dma_addr_t dma_addr;
+	u8 *base_kva, *kva;
+
+	base_kva = pci_alloc_consistent(pci_dev, PAGE_SIZE, &dma_addr);
+	if (base_kva == NULL) {
+		EFX_ERR(tx_queue->efx, "Unable to allocate page for TSO"
+			" headers\n");
+		return -ENOMEM;
+	}
+
+	/* pci_alloc_consistent() allocates pages. */
+	EFX_BUG_ON_PARANOID(dma_addr & (PAGE_SIZE - 1u));
+
+	for (kva = base_kva; kva < base_kva + PAGE_SIZE; kva += TSOH_STD_SIZE) {
+		tsoh = (struct efx_tso_header *)kva;
+		tsoh->dma_addr = dma_addr + (TSOH_BUFFER(tsoh) - base_kva);
+		tsoh->next = tx_queue->tso_headers_free;
+		tx_queue->tso_headers_free = tsoh;
+	}
+
+	return 0;
+}
+
+
+/* Free up a TSO header, and all others in the same page. */
+static void efx_tsoh_block_free(struct efx_tx_queue *tx_queue,
+				struct efx_tso_header *tsoh,
+				struct pci_dev *pci_dev)
+{
+	struct efx_tso_header **p;
+	unsigned long base_kva;
+	dma_addr_t base_dma;
+
+	base_kva = (unsigned long)tsoh & PAGE_MASK;
+	base_dma = tsoh->dma_addr & PAGE_MASK;
+
+	p = &tx_queue->tso_headers_free;
+	while (*p != NULL)
+		if (((unsigned long)*p & PAGE_MASK) == base_kva)
+			*p = (*p)->next;
+		else
+			p = &(*p)->next;
+
+	pci_free_consistent(pci_dev, PAGE_SIZE, (void *)base_kva, base_dma);
+}
+
+static struct efx_tso_header *
+efx_tsoh_heap_alloc(struct efx_tx_queue *tx_queue, size_t header_len)
+{
+	struct efx_tso_header *tsoh;
+
+	tsoh = kmalloc(TSOH_SIZE(header_len), GFP_ATOMIC | GFP_DMA);
+	if (unlikely(!tsoh))
+		return NULL;
+
+	tsoh->dma_addr = pci_map_single(tx_queue->efx->pci_dev,
+					TSOH_BUFFER(tsoh), header_len,
+					PCI_DMA_TODEVICE);
+	if (unlikely(pci_dma_mapping_error(tsoh->dma_addr))) {
+		kfree(tsoh);
+		return NULL;
+	}
+
+	tsoh->unmap_len = header_len;
+	return tsoh;
+}
+
+static void
+efx_tsoh_heap_free(struct efx_tx_queue *tx_queue, struct efx_tso_header *tsoh)
+{
+	pci_unmap_single(tx_queue->efx->pci_dev,
+			 tsoh->dma_addr, tsoh->unmap_len,
+			 PCI_DMA_TODEVICE);
+	kfree(tsoh);
+}
+
+/**
+ * efx_tx_queue_insert - push descriptors onto the TX queue
+ * @tx_queue:		Efx TX queue
+ * @dma_addr:		DMA address of fragment
+ * @len:		Length of fragment
+ * @skb:		Only non-null for end of last segment
+ * @end_of_packet:	True if last fragment in a packet
+ * @unmap_addr:		DMA address of fragment for unmapping
+ * @unmap_len:		Only set this in last segment of a fragment
+ *
+ * Push descriptors onto the TX queue.  Return 0 on success or 1 if
+ * @tx_queue full.
+ */
+static int efx_tx_queue_insert(struct efx_tx_queue *tx_queue,
+			       dma_addr_t dma_addr, unsigned len,
+			       const struct sk_buff *skb, int end_of_packet,
+			       dma_addr_t unmap_addr, unsigned unmap_len)
+{
+	struct efx_tx_buffer *buffer;
+	struct efx_nic *efx = tx_queue->efx;
+	unsigned dma_len, fill_level, insert_ptr, misalign;
+	int q_space;
+
+	EFX_BUG_ON_PARANOID(len <= 0);
+
+	fill_level = tx_queue->insert_count - tx_queue->old_read_count;
+	/* -1 as there is no way to represent all descriptors used */
+	q_space = efx->type->txd_ring_mask - 1 - fill_level;
+
+	while (1) {
+		if (unlikely(q_space-- <= 0)) {
+			/* It might be that completions have happened
+			 * since the xmit path last checked.  Update
+			 * the xmit path's copy of read_count.
+			 */
+			++tx_queue->stopped;
+			/* This memory barrier protects the change of
+			 * stopped from the access of read_count. */
+			smp_mb();
+			tx_queue->old_read_count =
+				*(volatile unsigned *)&tx_queue->read_count;
+			fill_level = (tx_queue->insert_count
+				      - tx_queue->old_read_count);
+			q_space = efx->type->txd_ring_mask - 1 - fill_level;
+			if (unlikely(q_space-- <= 0))
+				return 1;
+			smp_mb();
+			--tx_queue->stopped;
+		}
+
+		insert_ptr = tx_queue->insert_count & efx->type->txd_ring_mask;
+		buffer = &tx_queue->buffer[insert_ptr];
+		++tx_queue->insert_count;
+
+		EFX_BUG_ON_PARANOID(tx_queue->insert_count -
+				    tx_queue->read_count >
+				    efx->type->txd_ring_mask);
+
+		efx_tsoh_free(tx_queue, buffer);
+		EFX_BUG_ON_PARANOID(buffer->len);
+		EFX_BUG_ON_PARANOID(buffer->unmap_len);
+		EFX_BUG_ON_PARANOID(buffer->skb);
+		EFX_BUG_ON_PARANOID(buffer->continuation != 1);
+		EFX_BUG_ON_PARANOID(buffer->tsoh);
+
+		buffer->dma_addr = dma_addr;
+
+		/* Ensure we do not cross a boundary unsupported by H/W */
+		dma_len = (~dma_addr & efx->type->tx_dma_mask) + 1;
+
+		misalign = (unsigned)dma_addr & efx->type->bug5391_mask;
+		if (misalign && dma_len + misalign > 512)
+			dma_len = 512 - misalign;
+
+		/* If there is enough space to send then do so */
+		if (dma_len >= len)
+			break;
+
+		buffer->len = dma_len; /* Don't set the other members */
+		dma_addr += dma_len;
+		len -= dma_len;
+	}
+
+	EFX_BUG_ON_PARANOID(!len);
+	buffer->len = len;
+	buffer->skb = skb;
+	buffer->continuation = !end_of_packet;
+	buffer->unmap_addr = unmap_addr;
+	buffer->unmap_len = unmap_len;
+	return 0;
+}
+
+
+/*
+ * Put a TSO header into the TX queue.
+ *
+ * This is special-cased because we know that it is small enough to fit in
+ * a single fragment, and we know it doesn't cross a page boundary.  It
+ * also allows us to not worry about end-of-packet etc.
+ */
+static inline void efx_tso_put_header(struct efx_tx_queue *tx_queue,
+				      struct efx_tso_header *tsoh, unsigned len)
+{
+	struct efx_tx_buffer *buffer;
+
+	buffer = &tx_queue->buffer[tx_queue->insert_count &
+				   tx_queue->efx->type->txd_ring_mask];
+	efx_tsoh_free(tx_queue, buffer);
+	EFX_BUG_ON_PARANOID(buffer->len);
+	EFX_BUG_ON_PARANOID(buffer->unmap_len);
+	EFX_BUG_ON_PARANOID(buffer->skb);
+	EFX_BUG_ON_PARANOID(buffer->continuation != 1);
+	EFX_BUG_ON_PARANOID(buffer->tsoh);
+	buffer->len = len;
+	buffer->dma_addr = tsoh->dma_addr;
+	buffer->tsoh = tsoh;
+
+	++tx_queue->insert_count;
+}
+
+
+/* Remove descriptors put into a tx_queue. */
+static void efx_enqueue_unwind(struct efx_tx_queue *tx_queue)
+{
+	struct efx_tx_buffer *buffer;
+
+	/* Work backwards until we hit the original insert pointer value */
+	while (tx_queue->insert_count != tx_queue->write_count) {
+		--tx_queue->insert_count;
+		buffer = &tx_queue->buffer[tx_queue->insert_count &
+					   tx_queue->efx->type->txd_ring_mask];
+		efx_tsoh_free(tx_queue, buffer);
+		EFX_BUG_ON_PARANOID(buffer->skb);
+		buffer->len = 0;
+		buffer->continuation = 1;
+		if (buffer->unmap_len) {
+			pci_unmap_page(tx_queue->efx->pci_dev,
+				       buffer->unmap_addr,
+				       buffer->unmap_len, PCI_DMA_TODEVICE);
+			buffer->unmap_len = 0;
+		}
+	}
+}
+
+
+/* Parse the SKB header and initialise state. */
+static inline void tso_start(struct tso_state *st, const struct sk_buff *skb)
+{
+	/* All ethernet/IP/TCP headers combined size is TCP header size
+	 * plus offset of TCP header relative to start of packet.
+	 */
+	st->p.header_length = ((tcp_hdr(skb)->doff << 2u)
+			       + PTR_DIFF(tcp_hdr(skb), skb->data));
+	st->p.full_packet_size = (st->p.header_length
+				  + skb_shinfo(skb)->gso_size);
+
+	st->p.ipv4_id = ntohs(ip_hdr(skb)->id);
+	st->seqnum = ntohl(tcp_hdr(skb)->seq);
+
+	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->urg);
+	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->syn);
+	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->rst);
+
+	st->packet_space = st->p.full_packet_size;
+	st->remaining_len = skb->len - st->p.header_length;
+}
+
+
+/**
+ * tso_get_fragment - record fragment details and map for DMA
+ * @st:			TSO state
+ * @efx:		Efx NIC
+ * @data:		Pointer to fragment data
+ * @len:		Length of fragment
+ *
+ * Record fragment details and map for DMA.  Return 0 on success, or
+ * -%ENOMEM if DMA mapping fails.
+ */
+static inline int tso_get_fragment(struct tso_state *st, struct efx_nic *efx,
+				   int len, struct page *page, int page_off)
+{
+
+	st->ifc.unmap_addr = pci_map_page(efx->pci_dev, page, page_off,
+					  len, PCI_DMA_TODEVICE);
+	if (likely(!pci_dma_mapping_error(st->ifc.unmap_addr))) {
+		st->ifc.unmap_len = len;
+		st->ifc.len = len;
+		st->ifc.dma_addr = st->ifc.unmap_addr;
+		st->ifc.page = page;
+		st->ifc.page_off = page_off;
+		return 0;
+	}
+	return -ENOMEM;
+}
+
+
+/**
+ * tso_fill_packet_with_fragment - form descriptors for the current fragment
+ * @tx_queue:		Efx TX queue
+ * @skb:		Socket buffer
+ * @st:			TSO state
+ *
+ * Form descriptors for the current fragment, until we reach the end
+ * of fragment or end-of-packet.  Return 0 on success, 1 if not enough
+ * space in @tx_queue.
+ */
+static inline int tso_fill_packet_with_fragment(struct efx_tx_queue *tx_queue,
+						const struct sk_buff *skb,
+						struct tso_state *st)
+{
+
+	int n, end_of_packet, rc;
+
+	if (st->ifc.len == 0)
+		return 0;
+	if (st->packet_space == 0)
+		return 0;
+
+	EFX_BUG_ON_PARANOID(st->ifc.len <= 0);
+	EFX_BUG_ON_PARANOID(st->packet_space <= 0);
+
+	n = min(st->ifc.len, st->packet_space);
+
+	st->packet_space -= n;
+	st->remaining_len -= n;
+	st->ifc.len -= n;
+	st->ifc.page_off += n;
+	end_of_packet = st->remaining_len == 0 || st->packet_space == 0;
+
+	rc = efx_tx_queue_insert(tx_queue, st->ifc.dma_addr, n,
+				 st->remaining_len ? NULL : skb,
+				 end_of_packet, st->ifc.unmap_addr,
+				 st->ifc.len ? 0 : st->ifc.unmap_len);
+
+	st->ifc.dma_addr += n;
+
+	return rc;
+}
+
+
+/**
+ * tso_start_new_packet - generate a new header and prepare for the new packet
+ * @tx_queue:		Efx TX queue
+ * @skb:		Socket buffer
+ * @st:			TSO state
+ *
+ * Generate a new header and prepare for the new packet.  Return 0 on
+ * success, or -1 if failed to alloc header.
+ */
+static inline int tso_start_new_packet(struct efx_tx_queue *tx_queue,
+				       const struct sk_buff *skb,
+				       struct tso_state *st)
+{
+	struct efx_tso_header *tsoh;
+	struct iphdr *tsoh_iph;
+	struct tcphdr *tsoh_th;
+	unsigned ip_length;
+	u8 *header;
+
+	/* Allocate a DMA-mapped header buffer. */
+	if (likely(TSOH_SIZE(st->p.header_length) <= TSOH_STD_SIZE)) {
+		if (tx_queue->tso_headers_free == NULL)
+			if (efx_tsoh_block_alloc(tx_queue))
+				return -1;
+		EFX_BUG_ON_PARANOID(!tx_queue->tso_headers_free);
+		tsoh = tx_queue->tso_headers_free;
+		tx_queue->tso_headers_free = tsoh->next;
+		tsoh->unmap_len = 0;
+	} else {
+		tx_queue->tso_long_headers++;
+		tsoh = efx_tsoh_heap_alloc(tx_queue, st->p.header_length);
+		if (unlikely(!tsoh))
+			return -1;
+	}
+
+	header = TSOH_BUFFER(tsoh);
+	tsoh_th = (struct tcphdr *)(header + SKB_TCP_OFF(skb));
+	tsoh_iph = (struct iphdr *)(header + SKB_IPV4_OFF(skb));
+
+	/* Copy and update the headers. */
+	memcpy(header, skb->data, st->p.header_length);
+
+	tsoh_th->seq = htonl(st->seqnum);
+	st->seqnum += skb_shinfo(skb)->gso_size;
+	if (st->remaining_len > skb_shinfo(skb)->gso_size) {
+		/* This packet will not finish the TSO burst. */
+		ip_length = st->p.full_packet_size - ETH_HDR_LEN(skb);
+		tsoh_th->fin = 0;
+		tsoh_th->psh = 0;
+	} else {
+		/* This packet will be the last in the TSO burst. */
+		ip_length = (st->p.header_length - ETH_HDR_LEN(skb)
+			     + st->remaining_len);
+		tsoh_th->fin = tcp_hdr(skb)->fin;
+		tsoh_th->psh = tcp_hdr(skb)->psh;
+	}
+	tsoh_iph->tot_len = htons(ip_length);
+
+	/* Linux leaves suitable gaps in the IP ID space for us to fill. */
+	tsoh_iph->id = htons(st->p.ipv4_id);
+	st->p.ipv4_id++;
+
+	st->packet_space = skb_shinfo(skb)->gso_size;
+	++tx_queue->tso_packets;
+
+	/* Form a descriptor for this header. */
+	efx_tso_put_header(tx_queue, tsoh, st->p.header_length);
+
+	return 0;
+}
+
+
+/**
+ * efx_enqueue_skb_tso - segment and transmit a TSO socket buffer
+ * @tx_queue:		Efx TX queue
+ * @skb:		Socket buffer
+ *
+ * Context: You must hold netif_tx_lock() to call this function.
+ *
+ * Add socket buffer @skb to @tx_queue, doing TSO or return != 0 if
+ * @skb was not enqueued.  In all cases @skb is consumed.  Return
+ * %NETDEV_TX_OK or %NETDEV_TX_BUSY.
+ */
+static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
+			       const struct sk_buff *skb)
+{
+	int frag_i, rc, rc2 = NETDEV_TX_OK;
+	struct tso_state state;
+	skb_frag_t *f;
+
+	/* Verify TSO is safe - these checks should never fail. */
+	efx_tso_check_safe(skb);
+
+	EFX_BUG_ON_PARANOID(tx_queue->write_count != tx_queue->insert_count);
+
+	tso_start(&state, skb);
+
+	/* Assume that skb header area contains exactly the headers, and
+	 * all payload is in the frag list.
+	 */
+	if (skb_headlen(skb) == state.p.header_length) {
+		/* Grab the first payload fragment. */
+		EFX_BUG_ON_PARANOID(skb_shinfo(skb)->nr_frags < 1);
+		frag_i = 0;
+		f = &skb_shinfo(skb)->frags[frag_i];
+		rc = tso_get_fragment(&state, tx_queue->efx,
+				      f->size, f->page, f->page_offset);
+		if (rc)
+			goto mem_err;
+	} else {
+		/* It may look like this code fragment assumes that the
+		 * skb->data portion does not cross a page boundary, but
+		 * that is not the case.  It is guaranteed to be direct
+		 * mapped memory, and therefore is physically contiguous,
+		 * and so DMA will work fine.  kmap_atomic() on this region
+		 * will just return the direct mapping, so that will work
+		 * too.
+		 */
+		int page_off = (unsigned long)skb->data & (PAGE_SIZE - 1);
+		int hl = state.p.header_length;
+		rc = tso_get_fragment(&state, tx_queue->efx,
+				      skb_headlen(skb) - hl,
+				      virt_to_page(skb->data), page_off + hl);
+		if (rc)
+			goto mem_err;
+		frag_i = -1;
+	}
+
+	if (tso_start_new_packet(tx_queue, skb, &state) < 0)
+		goto mem_err;
+
+	while (1) {
+		rc = tso_fill_packet_with_fragment(tx_queue, skb, &state);
+		if (unlikely(rc))
+			goto stop;
+
+		/* Move onto the next fragment? */
+		if (state.ifc.len == 0) {
+			if (++frag_i >= skb_shinfo(skb)->nr_frags)
+				/* End of payload reached. */
+				break;
+			f = &skb_shinfo(skb)->frags[frag_i];
+			rc = tso_get_fragment(&state, tx_queue->efx,
+					      f->size, f->page, f->page_offset);
+			if (rc)
+				goto mem_err;
+		}
+
+		/* Start at new packet? */
+		if (state.packet_space == 0 &&
+		    tso_start_new_packet(tx_queue, skb, &state) < 0)
+			goto mem_err;
+	}
+
+	/* Pass off to hardware */
+	falcon_push_buffers(tx_queue);
+
+	tx_queue->tso_bursts++;
+	return NETDEV_TX_OK;
+
+ mem_err:
+	EFX_ERR(tx_queue->efx, "Out of memory for TSO headers, or PCI mapping"
+		" error\n");
+	dev_kfree_skb_any((struct sk_buff *)skb);
+	goto unwind;
+
+ stop:
+	rc2 = NETDEV_TX_BUSY;
+
+	/* Stop the queue if it wasn't stopped before. */
+	if (tx_queue->stopped == 1)
+		efx_stop_queue(tx_queue->efx);
+
+ unwind:
+	efx_enqueue_unwind(tx_queue);
+	return rc2;
+}
+
+
+/*
+ * Free up all TSO datastructures associated with tx_queue. This
+ * routine should be called only once the tx_queue is both empty and
+ * will no longer be used.
+ */
+static void efx_fini_tso(struct efx_tx_queue *tx_queue)
+{
+	unsigned i;
+
+	if (tx_queue->buffer)
+		for (i = 0; i <= tx_queue->efx->type->txd_ring_mask; ++i)
+			efx_tsoh_free(tx_queue, &tx_queue->buffer[i]);
+
+	while (tx_queue->tso_headers_free != NULL)
+		efx_tsoh_block_free(tx_queue, tx_queue->tso_headers_free,
+				    tx_queue->efx->pci_dev);
+}

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
