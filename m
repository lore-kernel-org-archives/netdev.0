From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next PATCH v2 16/29] fm10k: Add transmit and receive fastpath
 and interrupt handlers
Date: Sat, 20 Sep 2014 19:50:03 -0400
Message-ID: <20140920234949.2977.74643.stgit@ahduyck-bv4.jf.intel.com>
References: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>, john.fastabend@gmail.com,
	matthew.vick@intel.com, jeffrey.t.kirsher@intel.com,
	sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45499 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813AbaITX6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Sep 2014 19:58:48 -0400
In-Reply-To: <20140920234342.2977.21667.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change adds the transmit and receive fastpath and interrupt handlers.
With this code in place the network device is now able to send and receive
frames over the network interface using a single queue.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
CC: Rick Jones <rick.jones2@hp.com>
---

v2: Replaced dev_kfree_skb_any in Tx cleanup with dev_consume_skb_any

 drivers/net/ethernet/intel/fm10k/fm10k.h        |    5 
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   |  937 +++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |   94 ++
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c    |    3 
 4 files changed, 1037 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index c0a169a..98cbcd8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -391,6 +391,11 @@ extern char fm10k_driver_name[];
 extern const char fm10k_driver_version[];
 int fm10k_init_queueing_scheme(struct fm10k_intfc *interface);
 void fm10k_clear_queueing_scheme(struct fm10k_intfc *interface);
+netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
+				  struct fm10k_ring *tx_ring);
+void fm10k_tx_timeout_reset(struct fm10k_intfc *interface);
+bool fm10k_check_tx_hang(struct fm10k_ring *tx_ring);
+void fm10k_alloc_rx_buffers(struct fm10k_ring *rx_ring, u16 cleaned_count);
 
 /* PCI */
 void fm10k_mbx_free_irq(struct fm10k_intfc *);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index bf84c26..9d3bda3 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -67,6 +67,921 @@ static void __exit fm10k_exit_module(void)
 }
 module_exit(fm10k_exit_module);
 
+static bool fm10k_alloc_mapped_page(struct fm10k_ring *rx_ring,
+				    struct fm10k_rx_buffer *bi)
+{
+	struct page *page = bi->page;
+	dma_addr_t dma;
+
+	/* Only page will be NULL if buffer was consumed */
+	if (likely(page))
+		return true;
+
+	/* alloc new page for storage */
+	page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+	if (unlikely(!page)) {
+		rx_ring->rx_stats.alloc_failed++;
+		return false;
+	}
+
+	/* map page for use */
+	dma = dma_map_page(rx_ring->dev, page, 0, PAGE_SIZE, DMA_FROM_DEVICE);
+
+	/* if mapping failed free memory back to system since
+	 * there isn't much point in holding memory we can't use
+	 */
+	if (dma_mapping_error(rx_ring->dev, dma)) {
+		__free_page(page);
+		bi->page = NULL;
+
+		rx_ring->rx_stats.alloc_failed++;
+		return false;
+	}
+
+	bi->dma = dma;
+	bi->page = page;
+	bi->page_offset = 0;
+
+	return true;
+}
+
+/**
+ * fm10k_alloc_rx_buffers - Replace used receive buffers
+ * @rx_ring: ring to place buffers on
+ * @cleaned_count: number of buffers to replace
+ **/
+void fm10k_alloc_rx_buffers(struct fm10k_ring *rx_ring, u16 cleaned_count)
+{
+	union fm10k_rx_desc *rx_desc;
+	struct fm10k_rx_buffer *bi;
+	u16 i = rx_ring->next_to_use;
+
+	/* nothing to do */
+	if (!cleaned_count)
+		return;
+
+	rx_desc = FM10K_RX_DESC(rx_ring, i);
+	bi = &rx_ring->rx_buffer[i];
+	i -= rx_ring->count;
+
+	do {
+		if (!fm10k_alloc_mapped_page(rx_ring, bi))
+			break;
+
+		/* Refresh the desc even if buffer_addrs didn't change
+		 * because each write-back erases this info.
+		 */
+		rx_desc->q.pkt_addr = cpu_to_le64(bi->dma + bi->page_offset);
+
+		rx_desc++;
+		bi++;
+		i++;
+		if (unlikely(!i)) {
+			rx_desc = FM10K_RX_DESC(rx_ring, 0);
+			bi = rx_ring->rx_buffer;
+			i -= rx_ring->count;
+		}
+
+		/* clear the hdr_addr for the next_to_use descriptor */
+		rx_desc->q.hdr_addr = 0;
+
+		cleaned_count--;
+	} while (cleaned_count);
+
+	i += rx_ring->count;
+
+	if (rx_ring->next_to_use != i) {
+		/* record the next descriptor to use */
+		rx_ring->next_to_use = i;
+
+		/* update next to alloc since we have filled the ring */
+		rx_ring->next_to_alloc = i;
+
+		/* Force memory writes to complete before letting h/w
+		 * know there are new descriptors to fetch.  (Only
+		 * applicable for weak-ordered memory model archs,
+		 * such as IA-64).
+		 */
+		wmb();
+
+		/* notify hardware of new descriptors */
+		writel(i, rx_ring->tail);
+	}
+}
+
+/**
+ * fm10k_reuse_rx_page - page flip buffer and store it back on the ring
+ * @rx_ring: rx descriptor ring to store buffers on
+ * @old_buff: donor buffer to have page reused
+ *
+ * Synchronizes page for reuse by the interface
+ **/
+static void fm10k_reuse_rx_page(struct fm10k_ring *rx_ring,
+				struct fm10k_rx_buffer *old_buff)
+{
+	struct fm10k_rx_buffer *new_buff;
+	u16 nta = rx_ring->next_to_alloc;
+
+	new_buff = &rx_ring->rx_buffer[nta];
+
+	/* update, and store next to alloc */
+	nta++;
+	rx_ring->next_to_alloc = (nta < rx_ring->count) ? nta : 0;
+
+	/* transfer page from old buffer to new buffer */
+	memcpy(new_buff, old_buff, sizeof(struct fm10k_rx_buffer));
+
+	/* sync the buffer for use by the device */
+	dma_sync_single_range_for_device(rx_ring->dev, old_buff->dma,
+					 old_buff->page_offset,
+					 FM10K_RX_BUFSZ,
+					 DMA_FROM_DEVICE);
+}
+
+static bool fm10k_can_reuse_rx_page(struct fm10k_rx_buffer *rx_buffer,
+				    struct page *page,
+				    unsigned int truesize)
+{
+	/* avoid re-using remote pages */
+	if (unlikely(page_to_nid(page) != numa_mem_id()))
+		return false;
+
+#if (PAGE_SIZE < 8192)
+	/* if we are only owner of page we can reuse it */
+	if (unlikely(page_count(page) != 1))
+		return false;
+
+	/* flip page offset to other buffer */
+	rx_buffer->page_offset ^= FM10K_RX_BUFSZ;
+
+	/* since we are the only owner of the page and we need to
+	 * increment it, just set the value to 2 in order to avoid
+	 * an unnecessary locked operation
+	 */
+	atomic_set(&page->_count, 2);
+#else
+	/* move offset up to the next cache line */
+	rx_buffer->page_offset += truesize;
+
+	if (rx_buffer->page_offset > (PAGE_SIZE - FM10K_RX_BUFSZ))
+		return false;
+
+	/* bump ref count on page before it is given to the stack */
+	get_page(page);
+#endif
+
+	return true;
+}
+
+/**
+ * fm10k_add_rx_frag - Add contents of Rx buffer to sk_buff
+ * @rx_ring: rx descriptor ring to transact packets on
+ * @rx_buffer: buffer containing page to add
+ * @rx_desc: descriptor containing length of buffer written by hardware
+ * @skb: sk_buff to place the data into
+ *
+ * This function will add the data contained in rx_buffer->page to the skb.
+ * This is done either through a direct copy if the data in the buffer is
+ * less than the skb header size, otherwise it will just attach the page as
+ * a frag to the skb.
+ *
+ * The function will then update the page offset if necessary and return
+ * true if the buffer can be reused by the interface.
+ **/
+static bool fm10k_add_rx_frag(struct fm10k_ring *rx_ring,
+			      struct fm10k_rx_buffer *rx_buffer,
+			      union fm10k_rx_desc *rx_desc,
+			      struct sk_buff *skb)
+{
+	struct page *page = rx_buffer->page;
+	unsigned int size = le16_to_cpu(rx_desc->w.length);
+#if (PAGE_SIZE < 8192)
+	unsigned int truesize = FM10K_RX_BUFSZ;
+#else
+	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+#endif
+
+	if ((size <= FM10K_RX_HDR_LEN) && !skb_is_nonlinear(skb)) {
+		unsigned char *va = page_address(page) + rx_buffer->page_offset;
+
+		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
+
+		/* we can reuse buffer as-is, just make sure it is local */
+		if (likely(page_to_nid(page) == numa_mem_id()))
+			return true;
+
+		/* this page cannot be reused so discard it */
+		put_page(page);
+		return false;
+	}
+
+	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
+			rx_buffer->page_offset, size, truesize);
+
+	return fm10k_can_reuse_rx_page(rx_buffer, page, truesize);
+}
+
+static struct sk_buff *fm10k_fetch_rx_buffer(struct fm10k_ring *rx_ring,
+					     union fm10k_rx_desc *rx_desc,
+					     struct sk_buff *skb)
+{
+	struct fm10k_rx_buffer *rx_buffer;
+	struct page *page;
+
+	rx_buffer = &rx_ring->rx_buffer[rx_ring->next_to_clean];
+
+	page = rx_buffer->page;
+	prefetchw(page);
+
+	if (likely(!skb)) {
+		void *page_addr = page_address(page) +
+				  rx_buffer->page_offset;
+
+		/* prefetch first cache line of first page */
+		prefetch(page_addr);
+#if L1_CACHE_BYTES < 128
+		prefetch(page_addr + L1_CACHE_BYTES);
+#endif
+
+		/* allocate a skb to store the frags */
+		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
+						FM10K_RX_HDR_LEN);
+		if (unlikely(!skb)) {
+			rx_ring->rx_stats.alloc_failed++;
+			return NULL;
+		}
+
+		/* we will be copying header into skb->data in
+		 * pskb_may_pull so it is in our interest to prefetch
+		 * it now to avoid a possible cache miss
+		 */
+		prefetchw(skb->data);
+	}
+
+	/* we are reusing so sync this buffer for CPU use */
+	dma_sync_single_range_for_cpu(rx_ring->dev,
+				      rx_buffer->dma,
+				      rx_buffer->page_offset,
+				      FM10K_RX_BUFSZ,
+				      DMA_FROM_DEVICE);
+
+	/* pull page into skb */
+	if (fm10k_add_rx_frag(rx_ring, rx_buffer, rx_desc, skb)) {
+		/* hand second half of page back to the ring */
+		fm10k_reuse_rx_page(rx_ring, rx_buffer);
+	} else {
+		/* we are not reusing the buffer so unmap it */
+		dma_unmap_page(rx_ring->dev, rx_buffer->dma,
+			       PAGE_SIZE, DMA_FROM_DEVICE);
+	}
+
+	/* clear contents of rx_buffer */
+	rx_buffer->page = NULL;
+
+	return skb;
+}
+
+/**
+ * fm10k_process_skb_fields - Populate skb header fields from Rx descriptor
+ * @rx_ring: rx descriptor ring packet is being transacted on
+ * @rx_desc: pointer to the EOP Rx descriptor
+ * @skb: pointer to current skb being populated
+ *
+ * This function checks the ring, descriptor, and packet information in
+ * order to populate the hash, checksum, VLAN, timestamp, protocol, and
+ * other fields within the skb.
+ **/
+static unsigned int fm10k_process_skb_fields(struct fm10k_ring *rx_ring,
+					     union fm10k_rx_desc *rx_desc,
+					     struct sk_buff *skb)
+{
+	unsigned int len = skb->len;
+
+	FM10K_CB(skb)->fi.w.vlan = rx_desc->w.vlan;
+
+	skb_record_rx_queue(skb, rx_ring->queue_index);
+
+	FM10K_CB(skb)->fi.d.glort = rx_desc->d.glort;
+
+	if (rx_desc->w.vlan) {
+		u16 vid = le16_to_cpu(rx_desc->w.vlan);
+
+		if (vid != rx_ring->vid)
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vid);
+	}
+
+	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
+
+	return len;
+}
+
+/**
+ * fm10k_is_non_eop - process handling of non-EOP buffers
+ * @rx_ring: Rx ring being processed
+ * @rx_desc: Rx descriptor for current buffer
+ *
+ * This function updates next to clean.  If the buffer is an EOP buffer
+ * this function exits returning false, otherwise it will place the
+ * sk_buff in the next buffer to be chained and return true indicating
+ * that this is in fact a non-EOP buffer.
+ **/
+static bool fm10k_is_non_eop(struct fm10k_ring *rx_ring,
+			     union fm10k_rx_desc *rx_desc)
+{
+	u32 ntc = rx_ring->next_to_clean + 1;
+
+	/* fetch, update, and store next to clean */
+	ntc = (ntc < rx_ring->count) ? ntc : 0;
+	rx_ring->next_to_clean = ntc;
+
+	prefetch(FM10K_RX_DESC(rx_ring, ntc));
+
+	if (likely(fm10k_test_staterr(rx_desc, FM10K_RXD_STATUS_EOP)))
+		return false;
+
+	return true;
+}
+
+/**
+ * fm10k_pull_tail - fm10k specific version of skb_pull_tail
+ * @rx_ring: rx descriptor ring packet is being transacted on
+ * @rx_desc: pointer to the EOP Rx descriptor
+ * @skb: pointer to current skb being adjusted
+ *
+ * This function is an fm10k specific version of __pskb_pull_tail.  The
+ * main difference between this version and the original function is that
+ * this function can make several assumptions about the state of things
+ * that allow for significant optimizations versus the standard function.
+ * As a result we can do things like drop a frag and maintain an accurate
+ * truesize for the skb.
+ */
+static void fm10k_pull_tail(struct fm10k_ring *rx_ring,
+			    union fm10k_rx_desc *rx_desc,
+			    struct sk_buff *skb)
+{
+	struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
+	unsigned char *va;
+	unsigned int pull_len;
+
+	/* it is valid to use page_address instead of kmap since we are
+	 * working with pages allocated out of the lomem pool per
+	 * alloc_page(GFP_ATOMIC)
+	 */
+	va = skb_frag_address(frag);
+
+	/* we need the header to contain the greater of either ETH_HLEN or
+	 * 60 bytes if the skb->len is less than 60 for skb_pad.
+	 */
+	pull_len = eth_get_headlen(va, FM10K_RX_HDR_LEN);
+
+	/* align pull length to size of long to optimize memcpy performance */
+	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
+
+	/* update all of the pointers */
+	skb_frag_size_sub(frag, pull_len);
+	frag->page_offset += pull_len;
+	skb->data_len -= pull_len;
+	skb->tail += pull_len;
+}
+
+/**
+ * fm10k_cleanup_headers - Correct corrupted or empty headers
+ * @rx_ring: rx descriptor ring packet is being transacted on
+ * @rx_desc: pointer to the EOP Rx descriptor
+ * @skb: pointer to current skb being fixed
+ *
+ * Address the case where we are pulling data in on pages only
+ * and as such no data is present in the skb header.
+ *
+ * In addition if skb is not at least 60 bytes we need to pad it so that
+ * it is large enough to qualify as a valid Ethernet frame.
+ *
+ * Returns true if an error was encountered and skb was freed.
+ **/
+static bool fm10k_cleanup_headers(struct fm10k_ring *rx_ring,
+				  union fm10k_rx_desc *rx_desc,
+				  struct sk_buff *skb)
+{
+	if (unlikely((fm10k_test_staterr(rx_desc,
+					 FM10K_RXD_STATUS_RXE)))) {
+		dev_kfree_skb_any(skb);
+		rx_ring->rx_stats.errors++;
+		return true;
+	}
+
+	/* place header in linear portion of buffer */
+	if (skb_is_nonlinear(skb))
+		fm10k_pull_tail(rx_ring, rx_desc, skb);
+
+	/* if skb_pad returns an error the skb was freed */
+	if (unlikely(skb->len < 60)) {
+		int pad_len = 60 - skb->len;
+
+		if (skb_pad(skb, pad_len))
+			return true;
+		__skb_put(skb, pad_len);
+	}
+
+	return false;
+}
+
+/**
+ * fm10k_receive_skb - helper function to handle rx indications
+ * @q_vector: structure containing interrupt and ring information
+ * @skb: packet to send up
+ **/
+static void fm10k_receive_skb(struct fm10k_q_vector *q_vector,
+			      struct sk_buff *skb)
+{
+	napi_gro_receive(&q_vector->napi, skb);
+}
+
+static bool fm10k_clean_rx_irq(struct fm10k_q_vector *q_vector,
+			       struct fm10k_ring *rx_ring,
+			       int budget)
+{
+	struct sk_buff *skb = rx_ring->skb;
+	unsigned int total_bytes = 0, total_packets = 0;
+	u16 cleaned_count = fm10k_desc_unused(rx_ring);
+
+	do {
+		union fm10k_rx_desc *rx_desc;
+
+		/* return some buffers to hardware, one at a time is too slow */
+		if (cleaned_count >= FM10K_RX_BUFFER_WRITE) {
+			fm10k_alloc_rx_buffers(rx_ring, cleaned_count);
+			cleaned_count = 0;
+		}
+
+		rx_desc = FM10K_RX_DESC(rx_ring, rx_ring->next_to_clean);
+
+		if (!fm10k_test_staterr(rx_desc, FM10K_RXD_STATUS_DD))
+			break;
+
+		/* This memory barrier is needed to keep us from reading
+		 * any other fields out of the rx_desc until we know the
+		 * RXD_STATUS_DD bit is set
+		 */
+		rmb();
+
+		/* retrieve a buffer from the ring */
+		skb = fm10k_fetch_rx_buffer(rx_ring, rx_desc, skb);
+
+		/* exit if we failed to retrieve a buffer */
+		if (!skb)
+			break;
+
+		cleaned_count++;
+
+		/* fetch next buffer in frame if non-eop */
+		if (fm10k_is_non_eop(rx_ring, rx_desc))
+			continue;
+
+		/* verify the packet layout is correct */
+		if (fm10k_cleanup_headers(rx_ring, rx_desc, skb)) {
+			skb = NULL;
+			continue;
+		}
+
+		/* populate checksum, timestamp, VLAN, and protocol */
+		total_bytes += fm10k_process_skb_fields(rx_ring, rx_desc, skb);
+
+		fm10k_receive_skb(q_vector, skb);
+
+		/* reset skb pointer */
+		skb = NULL;
+
+		/* update budget accounting */
+		total_packets++;
+	} while (likely(total_packets < budget));
+
+	/* place incomplete frames back on ring for completion */
+	rx_ring->skb = skb;
+
+	u64_stats_update_begin(&rx_ring->syncp);
+	rx_ring->stats.packets += total_packets;
+	rx_ring->stats.bytes += total_bytes;
+	u64_stats_update_end(&rx_ring->syncp);
+	q_vector->rx.total_packets += total_packets;
+	q_vector->rx.total_bytes += total_bytes;
+
+	return total_packets < budget;
+}
+
+static bool fm10k_tx_desc_push(struct fm10k_ring *tx_ring,
+			       struct fm10k_tx_desc *tx_desc, u16 i,
+			       dma_addr_t dma, unsigned int size, u8 desc_flags)
+{
+	/* set RS and INT for last frame in a cache line */
+	if ((++i & (FM10K_TXD_WB_FIFO_SIZE - 1)) == 0)
+		desc_flags |= FM10K_TXD_FLAG_RS | FM10K_TXD_FLAG_INT;
+
+	/* record values to descriptor */
+	tx_desc->buffer_addr = cpu_to_le64(dma);
+	tx_desc->flags = desc_flags;
+	tx_desc->buflen = cpu_to_le16(size);
+
+	/* return true if we just wrapped the ring */
+	return i == tx_ring->count;
+}
+
+static void fm10k_tx_map(struct fm10k_ring *tx_ring,
+			 struct fm10k_tx_buffer *first)
+{
+	struct sk_buff *skb = first->skb;
+	struct fm10k_tx_buffer *tx_buffer;
+	struct fm10k_tx_desc *tx_desc;
+	struct skb_frag_struct *frag;
+	unsigned char *data;
+	dma_addr_t dma;
+	unsigned int data_len, size;
+	u16 i = tx_ring->next_to_use;
+	u8 flags = 0;
+
+	tx_desc = FM10K_TX_DESC(tx_ring, i);
+
+	/* add HW VLAN tag */
+	if (vlan_tx_tag_present(skb))
+		tx_desc->vlan = cpu_to_le16(vlan_tx_tag_get(skb));
+	else
+		tx_desc->vlan = 0;
+
+	size = skb_headlen(skb);
+	data = skb->data;
+
+	dma = dma_map_single(tx_ring->dev, data, size, DMA_TO_DEVICE);
+
+	data_len = skb->data_len;
+	tx_buffer = first;
+
+	for (frag = &skb_shinfo(skb)->frags[0];; frag++) {
+		if (dma_mapping_error(tx_ring->dev, dma))
+			goto dma_error;
+
+		/* record length, and DMA address */
+		dma_unmap_len_set(tx_buffer, len, size);
+		dma_unmap_addr_set(tx_buffer, dma, dma);
+
+		while (unlikely(size > FM10K_MAX_DATA_PER_TXD)) {
+			if (fm10k_tx_desc_push(tx_ring, tx_desc++, i++, dma,
+					       FM10K_MAX_DATA_PER_TXD, flags)) {
+				tx_desc = FM10K_TX_DESC(tx_ring, 0);
+				i = 0;
+			}
+
+			dma += FM10K_MAX_DATA_PER_TXD;
+			size -= FM10K_MAX_DATA_PER_TXD;
+		}
+
+		if (likely(!data_len))
+			break;
+
+		if (fm10k_tx_desc_push(tx_ring, tx_desc++, i++,
+				       dma, size, flags)) {
+			tx_desc = FM10K_TX_DESC(tx_ring, 0);
+			i = 0;
+		}
+
+		size = skb_frag_size(frag);
+		data_len -= size;
+
+		dma = skb_frag_dma_map(tx_ring->dev, frag, 0, size,
+				       DMA_TO_DEVICE);
+
+		tx_buffer = &tx_ring->tx_buffer[i];
+	}
+
+	/* write last descriptor with LAST bit set */
+	flags |= FM10K_TXD_FLAG_LAST;
+
+	if (fm10k_tx_desc_push(tx_ring, tx_desc, i++, dma, size, flags))
+		i = 0;
+
+	/* record bytecount for BQL */
+	netdev_tx_sent_queue(txring_txq(tx_ring), first->bytecount);
+
+	/* record SW timestamp if HW timestamp is not available */
+	skb_tx_timestamp(first->skb);
+
+	/* Force memory writes to complete before letting h/w know there
+	 * are new descriptors to fetch.  (Only applicable for weak-ordered
+	 * memory model archs, such as IA-64).
+	 *
+	 * We also need this memory barrier to make certain all of the
+	 * status bits have been updated before next_to_watch is written.
+	 */
+	wmb();
+
+	/* set next_to_watch value indicating a packet is present */
+	first->next_to_watch = tx_desc;
+
+	tx_ring->next_to_use = i;
+
+	/* notify HW of packet */
+	writel(i, tx_ring->tail);
+
+	/* we need this if more than one processor can write to our tail
+	 * at a time, it synchronizes IO on IA64/Altix systems
+	 */
+	mmiowb();
+
+	return;
+dma_error:
+	dev_err(tx_ring->dev, "TX DMA map failed\n");
+
+	/* clear dma mappings for failed tx_buffer map */
+	for (;;) {
+		tx_buffer = &tx_ring->tx_buffer[i];
+		fm10k_unmap_and_free_tx_resource(tx_ring, tx_buffer);
+		if (tx_buffer == first)
+			break;
+		if (i == 0)
+			i = tx_ring->count;
+		i--;
+	}
+
+	tx_ring->next_to_use = i;
+}
+
+static int __fm10k_maybe_stop_tx(struct fm10k_ring *tx_ring, u16 size)
+{
+	netif_stop_subqueue(tx_ring->netdev, tx_ring->queue_index);
+
+	smp_mb();
+
+	/* We need to check again in a case another CPU has just
+	 * made room available. */
+	if (likely(fm10k_desc_unused(tx_ring) < size))
+		return -EBUSY;
+
+	/* A reprieve! - use start_queue because it doesn't call schedule */
+	netif_start_subqueue(tx_ring->netdev, tx_ring->queue_index);
+	++tx_ring->tx_stats.restart_queue;
+	return 0;
+}
+
+static inline int fm10k_maybe_stop_tx(struct fm10k_ring *tx_ring, u16 size)
+{
+	if (likely(fm10k_desc_unused(tx_ring) >= size))
+		return 0;
+	return __fm10k_maybe_stop_tx(tx_ring, size);
+}
+
+netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
+				  struct fm10k_ring *tx_ring)
+{
+	struct fm10k_tx_buffer *first;
+	u32 tx_flags = 0;
+#if PAGE_SIZE > FM10K_MAX_DATA_PER_TXD
+	unsigned short f;
+#endif
+	u16 count = TXD_USE_COUNT(skb_headlen(skb));
+
+	/* need: 1 descriptor per page * PAGE_SIZE/FM10K_MAX_DATA_PER_TXD,
+	 *       + 1 desc for skb_headlen/FM10K_MAX_DATA_PER_TXD,
+	 *       + 2 desc gap to keep tail from touching head
+	 * otherwise try next time
+	 */
+#if PAGE_SIZE > FM10K_MAX_DATA_PER_TXD
+	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
+		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
+#else
+	count += skb_shinfo(skb)->nr_frags;
+#endif
+	if (fm10k_maybe_stop_tx(tx_ring, count + 3)) {
+		tx_ring->tx_stats.tx_busy++;
+		return NETDEV_TX_BUSY;
+	}
+
+	/* record the location of the first descriptor for this packet */
+	first = &tx_ring->tx_buffer[tx_ring->next_to_use];
+	first->skb = skb;
+	first->bytecount = max_t(unsigned int, skb->len, ETH_ZLEN);
+	first->gso_segs = 1;
+
+	/* record initial flags and protocol */
+	first->tx_flags = tx_flags;
+
+	fm10k_tx_map(tx_ring, first);
+
+	fm10k_maybe_stop_tx(tx_ring, DESC_NEEDED);
+
+	return NETDEV_TX_OK;
+}
+
+static u64 fm10k_get_tx_completed(struct fm10k_ring *ring)
+{
+	return ring->stats.packets;
+}
+
+static u64 fm10k_get_tx_pending(struct fm10k_ring *ring)
+{
+	/* use SW head and tail until we have real hardware */
+	u32 head = ring->next_to_clean;
+	u32 tail = ring->next_to_use;
+
+	return ((head <= tail) ? tail : tail + ring->count) - head;
+}
+
+bool fm10k_check_tx_hang(struct fm10k_ring *tx_ring)
+{
+	u32 tx_done = fm10k_get_tx_completed(tx_ring);
+	u32 tx_done_old = tx_ring->tx_stats.tx_done_old;
+	u32 tx_pending = fm10k_get_tx_pending(tx_ring);
+
+	clear_check_for_tx_hang(tx_ring);
+
+	/* Check for a hung queue, but be thorough. This verifies
+	 * that a transmit has been completed since the previous
+	 * check AND there is at least one packet pending. By
+	 * requiring this to fail twice we avoid races with
+	 * clearing the ARMED bit and conditions where we
+	 * run the check_tx_hang logic with a transmit completion
+	 * pending but without time to complete it yet.
+	 */
+	if (!tx_pending || (tx_done_old != tx_done)) {
+		/* update completed stats and continue */
+		tx_ring->tx_stats.tx_done_old = tx_done;
+		/* reset the countdown */
+		clear_bit(__FM10K_HANG_CHECK_ARMED, &tx_ring->state);
+
+		return false;
+	}
+
+	/* make sure it is true for two checks in a row */
+	return test_and_set_bit(__FM10K_HANG_CHECK_ARMED, &tx_ring->state);
+}
+
+/**
+ * fm10k_tx_timeout_reset - initiate reset due to Tx timeout
+ * @interface: driver private struct
+ **/
+void fm10k_tx_timeout_reset(struct fm10k_intfc *interface)
+{
+	/* Do the reset outside of interrupt context */
+	if (!test_bit(__FM10K_DOWN, &interface->state)) {
+		netdev_err(interface->netdev, "Reset interface\n");
+		interface->tx_timeout_count++;
+		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
+		fm10k_service_event_schedule(interface);
+	}
+}
+
+/**
+ * fm10k_clean_tx_irq - Reclaim resources after transmit completes
+ * @q_vector: structure containing interrupt and ring information
+ * @tx_ring: tx ring to clean
+ **/
+static bool fm10k_clean_tx_irq(struct fm10k_q_vector *q_vector,
+			       struct fm10k_ring *tx_ring)
+{
+	struct fm10k_intfc *interface = q_vector->interface;
+	struct fm10k_tx_buffer *tx_buffer;
+	struct fm10k_tx_desc *tx_desc;
+	unsigned int total_bytes = 0, total_packets = 0;
+	unsigned int budget = q_vector->tx.work_limit;
+	unsigned int i = tx_ring->next_to_clean;
+
+	if (test_bit(__FM10K_DOWN, &interface->state))
+		return true;
+
+	tx_buffer = &tx_ring->tx_buffer[i];
+	tx_desc = FM10K_TX_DESC(tx_ring, i);
+	i -= tx_ring->count;
+
+	do {
+		struct fm10k_tx_desc *eop_desc = tx_buffer->next_to_watch;
+
+		/* if next_to_watch is not set then there is no work pending */
+		if (!eop_desc)
+			break;
+
+		/* prevent any other reads prior to eop_desc */
+		read_barrier_depends();
+
+		/* if DD is not set pending work has not been completed */
+		if (!(eop_desc->flags & FM10K_TXD_FLAG_DONE))
+			break;
+
+		/* clear next_to_watch to prevent false hangs */
+		tx_buffer->next_to_watch = NULL;
+
+		/* update the statistics for this packet */
+		total_bytes += tx_buffer->bytecount;
+		total_packets += tx_buffer->gso_segs;
+
+		/* free the skb */
+		dev_consume_skb_any(tx_buffer->skb);
+
+		/* unmap skb header data */
+		dma_unmap_single(tx_ring->dev,
+				 dma_unmap_addr(tx_buffer, dma),
+				 dma_unmap_len(tx_buffer, len),
+				 DMA_TO_DEVICE);
+
+		/* clear tx_buffer data */
+		tx_buffer->skb = NULL;
+		dma_unmap_len_set(tx_buffer, len, 0);
+
+		/* unmap remaining buffers */
+		while (tx_desc != eop_desc) {
+			tx_buffer++;
+			tx_desc++;
+			i++;
+			if (unlikely(!i)) {
+				i -= tx_ring->count;
+				tx_buffer = tx_ring->tx_buffer;
+				tx_desc = FM10K_TX_DESC(tx_ring, 0);
+			}
+
+			/* unmap any remaining paged data */
+			if (dma_unmap_len(tx_buffer, len)) {
+				dma_unmap_page(tx_ring->dev,
+					       dma_unmap_addr(tx_buffer, dma),
+					       dma_unmap_len(tx_buffer, len),
+					       DMA_TO_DEVICE);
+				dma_unmap_len_set(tx_buffer, len, 0);
+			}
+		}
+
+		/* move us one more past the eop_desc for start of next pkt */
+		tx_buffer++;
+		tx_desc++;
+		i++;
+		if (unlikely(!i)) {
+			i -= tx_ring->count;
+			tx_buffer = tx_ring->tx_buffer;
+			tx_desc = FM10K_TX_DESC(tx_ring, 0);
+		}
+
+		/* issue prefetch for next Tx descriptor */
+		prefetch(tx_desc);
+
+		/* update budget accounting */
+		budget--;
+	} while (likely(budget));
+
+	i += tx_ring->count;
+	tx_ring->next_to_clean = i;
+	u64_stats_update_begin(&tx_ring->syncp);
+	tx_ring->stats.bytes += total_bytes;
+	tx_ring->stats.packets += total_packets;
+	u64_stats_update_end(&tx_ring->syncp);
+	q_vector->tx.total_bytes += total_bytes;
+	q_vector->tx.total_packets += total_packets;
+
+	if (check_for_tx_hang(tx_ring) && fm10k_check_tx_hang(tx_ring)) {
+		/* schedule immediate reset if we believe we hung */
+		struct fm10k_hw *hw = &interface->hw;
+
+		netif_err(interface, drv, tx_ring->netdev,
+			  "Detected Tx Unit Hang\n"
+			  "  Tx Queue             <%d>\n"
+			  "  TDH, TDT             <%x>, <%x>\n"
+			  "  next_to_use          <%x>\n"
+			  "  next_to_clean        <%x>\n",
+			  tx_ring->queue_index,
+			  fm10k_read_reg(hw, FM10K_TDH(tx_ring->reg_idx)),
+			  fm10k_read_reg(hw, FM10K_TDT(tx_ring->reg_idx)),
+			  tx_ring->next_to_use, i);
+
+		netif_stop_subqueue(tx_ring->netdev,
+				    tx_ring->queue_index);
+
+		netif_info(interface, probe, tx_ring->netdev,
+			   "tx hang %d detected on queue %d, resetting interface\n",
+			   interface->tx_timeout_count + 1,
+			   tx_ring->queue_index);
+
+		fm10k_tx_timeout_reset(interface);
+
+		/* the netdev is about to reset, no point in enabling stuff */
+		return true;
+	}
+
+	/* notify netdev of completed buffers */
+	netdev_tx_completed_queue(txring_txq(tx_ring),
+				  total_packets, total_bytes);
+
+#define TX_WAKE_THRESHOLD min_t(u16, FM10K_MIN_TXD - 1, DESC_NEEDED * 2)
+	if (unlikely(total_packets && netif_carrier_ok(tx_ring->netdev) &&
+		     (fm10k_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD))) {
+		/* Make sure that anybody stopping the queue after this
+		 * sees the new next_to_clean.
+		 */
+		smp_mb();
+		if (__netif_subqueue_stopped(tx_ring->netdev,
+					     tx_ring->queue_index) &&
+		    !test_bit(__FM10K_DOWN, &interface->state)) {
+			netif_wake_subqueue(tx_ring->netdev,
+					    tx_ring->queue_index);
+			++tx_ring->tx_stats.restart_queue;
+		}
+	}
+
+	return !!budget;
+}
+
 /**
  * fm10k_update_itr - update the dynamic ITR value based on packet size
  *
@@ -137,6 +1052,28 @@ static int fm10k_poll(struct napi_struct *napi, int budget)
 {
 	struct fm10k_q_vector *q_vector =
 			       container_of(napi, struct fm10k_q_vector, napi);
+	struct fm10k_ring *ring;
+	int per_ring_budget;
+	bool clean_complete = true;
+
+	fm10k_for_each_ring(ring, q_vector->tx)
+		clean_complete &= fm10k_clean_tx_irq(q_vector, ring);
+
+	/* attempt to distribute budget to each queue fairly, but don't
+	 * allow the budget to go below 1 because we'll exit polling
+	 */
+	if (q_vector->rx.count > 1)
+		per_ring_budget = max(budget/q_vector->rx.count, 1);
+	else
+		per_ring_budget = budget;
+
+	fm10k_for_each_ring(ring, q_vector->rx)
+		clean_complete &= fm10k_clean_rx_irq(q_vector, ring,
+						     per_ring_budget);
+
+	/* If all work not completed, return budget and keep polling */
+	if (!clean_complete)
+		return budget;
 
 	/* all work done, exit the polling mode */
 	napi_complete(napi);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index f9b085e..85789b8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -450,8 +450,66 @@ int fm10k_close(struct net_device *netdev)
 
 static netdev_tx_t fm10k_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 {
-	dev_kfree_skb_any(skb);
-	return NETDEV_TX_OK;
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	unsigned int r_idx = 0;
+	int err;
+
+	if ((skb->protocol ==  htons(ETH_P_8021Q)) &&
+	    !vlan_tx_tag_present(skb)) {
+		/* FM10K only supports hardware tagging, any tags in frame
+		 * are considered 2nd level or "outer" tags
+		 */
+		struct vlan_hdr *vhdr;
+		__be16 proto;
+
+		/* make sure skb is not shared */
+		skb = skb_share_check(skb, GFP_ATOMIC);
+		if (!skb)
+			return NETDEV_TX_OK;
+
+		/* make sure there is enough room to move the ethernet header */
+		if (unlikely(!pskb_may_pull(skb, VLAN_ETH_HLEN)))
+			return NETDEV_TX_OK;
+
+		/* verify the skb head is not shared */
+		err = skb_cow_head(skb, 0);
+		if (err)
+			return NETDEV_TX_OK;
+
+		/* locate vlan header */
+		vhdr = (struct vlan_hdr *)(skb->data + ETH_HLEN);
+
+		/* pull the 2 key pieces of data out of it */
+		__vlan_hwaccel_put_tag(skb,
+				       htons(ETH_P_8021Q),
+				       ntohs(vhdr->h_vlan_TCI));
+		proto = vhdr->h_vlan_encapsulated_proto;
+		skb->protocol = (ntohs(proto) >= 1536) ? proto :
+							 htons(ETH_P_802_2);
+
+		/* squash it by moving the ethernet addresses up 4 bytes */
+		memmove(skb->data + VLAN_HLEN, skb->data, 12);
+		__skb_pull(skb, VLAN_HLEN);
+		skb_reset_mac_header(skb);
+	}
+
+	/* The minimum packet size for a single buffer is 17B so pad the skb
+	 * in order to meet this minimum size requirement.
+	 */
+	if (unlikely(skb->len < 17)) {
+		int pad_len = 17 - skb->len;
+
+		if (skb_pad(skb, pad_len))
+			return NETDEV_TX_OK;
+		__skb_put(skb, pad_len);
+	}
+
+	if (r_idx >= interface->num_tx_queues)
+		r_idx %= interface->num_tx_queues;
+
+	err = fm10k_xmit_frame_ring(skb, interface->tx_ring[r_idx]);
+
+	return err;
 }
 
 static int fm10k_change_mtu(struct net_device *dev, int new_mtu)
@@ -464,6 +522,37 @@ static int fm10k_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+/**
+ * fm10k_tx_timeout - Respond to a Tx Hang
+ * @netdev: network interface device structure
+ **/
+static void fm10k_tx_timeout(struct net_device *netdev)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	bool real_tx_hang = false;
+	int i;
+
+#define TX_TIMEO_LIMIT 16000
+	for (i = 0; i < interface->num_tx_queues; i++) {
+		struct fm10k_ring *tx_ring = interface->tx_ring[i];
+
+		if (check_for_tx_hang(tx_ring) && fm10k_check_tx_hang(tx_ring))
+			real_tx_hang = true;
+	}
+
+	if (real_tx_hang) {
+		fm10k_tx_timeout_reset(interface);
+	} else {
+		netif_info(interface, drv, netdev,
+			   "Fake Tx hang detected with timeout of %d seconds\n",
+			   netdev->watchdog_timeo/HZ);
+
+		/* fake Tx hang - increase the kernel timeout */
+		if (netdev->watchdog_timeo < TX_TIMEO_LIMIT)
+			netdev->watchdog_timeo *= 2;
+	}
+}
+
 static int fm10k_uc_vlan_unsync(struct net_device *netdev,
 				const unsigned char *uc_addr)
 {
@@ -890,6 +979,7 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_start_xmit		= fm10k_xmit_frame,
 	.ndo_set_mac_address	= fm10k_set_mac,
 	.ndo_change_mtu		= fm10k_change_mtu,
+	.ndo_tx_timeout		= fm10k_tx_timeout,
 	.ndo_vlan_rx_add_vid	= fm10k_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= fm10k_vlan_rx_kill_vid,
 	.ndo_set_rx_mode	= fm10k_set_rx_mode,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index c53307d..93b4802 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -661,6 +661,9 @@ static void fm10k_configure_rx_ring(struct fm10k_intfc *interface,
 
 	/* enable queue */
 	fm10k_write_reg(hw, FM10K_RXQCTL(reg_idx), rxqctl);
+
+	/* place buffers on ring for receive data */
+	fm10k_alloc_rx_buffers(ring, fm10k_desc_unused(ring));
 }
 
 /**
