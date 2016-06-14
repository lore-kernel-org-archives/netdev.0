From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 5/9] liquidio: RX desc alloc changes
Date: Tue, 14 Jun 2016 16:54:47 -0700
Message-ID: <1465948491-10541-6-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0069.outbound.protection.outlook.com ([65.55.169.69]:47712
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752314AbcFOAKT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 20:10:19 -0400
In-Reply-To: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add page based buffers for receive side descriptors of
the driver and separate free routines for rx and tx buffers.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  34 +++-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 132 +++++++------
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h |  18 ++
 .../net/ethernet/cavium/liquidio/octeon_network.h  | 215 +++++++++++++++++++--
 4 files changed, 316 insertions(+), 83 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 0daa89a..3a4f31f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1439,7 +1439,7 @@ static void free_netbuf(void *buf)
 
 	check_txq_state(lio, skb);
 
-	recv_buffer_free((struct sk_buff *)skb);
+	tx_buffer_free(skb);
 }
 
 /**
@@ -1484,7 +1484,7 @@ static void free_netsgbuf(void *buf)
 
 	check_txq_state(lio, skb);     /* mq support: sub-queue state check */
 
-	recv_buffer_free((struct sk_buff *)skb);
+	tx_buffer_free(skb);
 }
 
 /**
@@ -1862,6 +1862,32 @@ liquidio_push_packet(u32 octeon_id,
 		skb->dev = netdev;
 
 		skb_record_rx_queue(skb, droq->q_no);
+		if (likely(len > MIN_SKB_SIZE)) {
+			struct octeon_skb_page_info *pg_info;
+			unsigned char *va;
+
+			pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+			if (pg_info->page) {
+				/* For Paged allocation use the frags */
+				va = page_address(pg_info->page) +
+					pg_info->page_offset;
+				memcpy(skb->data, va, MIN_SKB_SIZE);
+				skb_put(skb, MIN_SKB_SIZE);
+				skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags,
+						pg_info->page,
+						pg_info->page_offset +
+						MIN_SKB_SIZE,
+						len - MIN_SKB_SIZE,
+						LIO_RXBUFFER_SZ);
+			}
+		} else {
+			struct octeon_skb_page_info *pg_info =
+				((struct octeon_skb_page_info *)(skb->cb));
+			skb_copy_to_linear_data(skb, page_address(pg_info->page)
+						+ pg_info->page_offset, len);
+			skb_put(skb, len);
+			put_page(pg_info->page);
+		}
 
 		if (rh->r_dh.has_hwtstamp) {
 			/* timestamp is included from the hardware at the
@@ -2612,7 +2638,7 @@ static void handle_timestamp(struct octeon_device *oct,
 	}
 
 	octeon_free_soft_command(oct, sc);
-	recv_buffer_free(skb);
+	tx_buffer_free(skb);
 }
 
 /* \brief Send a data packet that will be timestamped
@@ -3001,7 +3027,7 @@ lio_xmit_failed:
 		   iq_no, stats->tx_dropped);
 	dma_unmap_single(&oct->pci_dev->dev, ndata.cmd.dptr,
 			 ndata.datasize, DMA_TO_DEVICE);
-	recv_buffer_free(skb);
+	tx_buffer_free(skb);
 	return NETDEV_TX_OK;
 }
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 1f648dc..a12beaa 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -151,22 +151,26 @@ octeon_droq_destroy_ring_buffers(struct octeon_device *oct,
 				 struct octeon_droq *droq)
 {
 	u32 i;
+	struct octeon_skb_page_info *pg_info;
 
 	for (i = 0; i < droq->max_count; i++) {
-		if (droq->recv_buf_list[i].buffer) {
-			if (droq->desc_ring) {
-				lio_unmap_ring_info(oct->pci_dev,
-						    (u64)droq->
-						    desc_ring[i].info_ptr,
-						    OCT_DROQ_INFO_SIZE);
-				lio_unmap_ring(oct->pci_dev,
-					       (u64)droq->desc_ring[i].
-					       buffer_ptr,
-					       droq->buffer_size);
-			}
-			recv_buffer_free(droq->recv_buf_list[i].buffer);
-			droq->recv_buf_list[i].buffer = NULL;
-		}
+		pg_info = &droq->recv_buf_list[i].pg_info;
+
+		if (pg_info->dma)
+			lio_unmap_ring(oct->pci_dev,
+				       (u64)pg_info->dma);
+		pg_info->dma = 0;
+
+		if (pg_info->page)
+			recv_buffer_destroy(droq->recv_buf_list[i].buffer,
+					    pg_info);
+
+		if (droq->desc_ring && droq->desc_ring[i].info_ptr)
+			lio_unmap_ring_info(oct->pci_dev,
+					    (u64)droq->
+					    desc_ring[i].info_ptr,
+					    OCT_DROQ_INFO_SIZE);
+		droq->recv_buf_list[i].buffer = NULL;
 	}
 
 	octeon_droq_reset_indices(droq);
@@ -181,11 +185,12 @@ octeon_droq_setup_ring_buffers(struct octeon_device *oct,
 	struct octeon_droq_desc *desc_ring = droq->desc_ring;
 
 	for (i = 0; i < droq->max_count; i++) {
-		buf = recv_buffer_alloc(oct, droq->q_no, droq->buffer_size);
+		buf = recv_buffer_alloc(oct, &droq->recv_buf_list[i].pg_info);
 
 		if (!buf) {
 			dev_err(&oct->pci_dev->dev, "%s buffer alloc failed\n",
 				__func__);
+			droq->stats.rx_alloc_failure++;
 			return -ENOMEM;
 		}
 
@@ -197,9 +202,7 @@ octeon_droq_setup_ring_buffers(struct octeon_device *oct,
 		/* map ring buffers into memory */
 		desc_ring[i].info_ptr = lio_map_ring_info(droq, i);
 		desc_ring[i].buffer_ptr =
-			lio_map_ring(oct->pci_dev,
-				     droq->recv_buf_list[i].buffer,
-				     droq->buffer_size);
+			lio_map_ring(droq->recv_buf_list[i].buffer);
 	}
 
 	octeon_droq_reset_indices(droq);
@@ -372,6 +375,7 @@ static inline struct octeon_recv_info *octeon_create_recv_info(
 	struct octeon_recv_pkt *recv_pkt;
 	struct octeon_recv_info *recv_info;
 	u32 i, bytes_left;
+	struct octeon_skb_page_info *pg_info;
 
 	info = &droq->info_list[idx];
 
@@ -389,9 +393,14 @@ static inline struct octeon_recv_info *octeon_create_recv_info(
 	bytes_left = (u32)info->length;
 
 	while (buf_cnt) {
-		lio_unmap_ring(octeon_dev->pci_dev,
-			       (u64)droq->desc_ring[idx].buffer_ptr,
-			       droq->buffer_size);
+		{
+			pg_info = &droq->recv_buf_list[idx].pg_info;
+
+			lio_unmap_ring(octeon_dev->pci_dev,
+				       (u64)pg_info->dma);
+			pg_info->page = NULL;
+			pg_info->dma = 0;
+		}
 
 		recv_pkt->buffer_size[i] =
 			(bytes_left >=
@@ -463,6 +472,7 @@ octeon_droq_refill(struct octeon_device *octeon_dev, struct octeon_droq *droq)
 	void *buf = NULL;
 	u8 *data;
 	u32 desc_refilled = 0;
+	struct octeon_skb_page_info *pg_info;
 
 	desc_ring = droq->desc_ring;
 
@@ -472,13 +482,22 @@ octeon_droq_refill(struct octeon_device *octeon_dev, struct octeon_droq *droq)
 		 * the buffer, else allocate.
 		 */
 		if (!droq->recv_buf_list[droq->refill_idx].buffer) {
-			buf = recv_buffer_alloc(octeon_dev, droq->q_no,
-						droq->buffer_size);
+			pg_info =
+				&droq->recv_buf_list[droq->refill_idx].pg_info;
+			/* Either recycle the existing pages or go for
+			 * new page alloc
+			 */
+			if (pg_info->page)
+				buf = recv_buffer_reuse(octeon_dev, pg_info);
+			else
+				buf = recv_buffer_alloc(octeon_dev, pg_info);
 			/* If a buffer could not be allocated, no point in
 			 * continuing
 			 */
-			if (!buf)
+			if (!buf) {
+				droq->stats.rx_alloc_failure++;
 				break;
+			}
 			droq->recv_buf_list[droq->refill_idx].buffer =
 				buf;
 			data = get_rbd(buf);
@@ -490,11 +509,8 @@ octeon_droq_refill(struct octeon_device *octeon_dev, struct octeon_droq *droq)
 		droq->recv_buf_list[droq->refill_idx].data = data;
 
 		desc_ring[droq->refill_idx].buffer_ptr =
-			lio_map_ring(octeon_dev->pci_dev,
-				     droq->recv_buf_list[droq->
-				     refill_idx].buffer,
-				     droq->buffer_size);
-
+			lio_map_ring(droq->recv_buf_list[droq->
+				     refill_idx].buffer);
 		/* Reset any previous values in the length field. */
 		droq->info_list[droq->refill_idx].length = 0;
 
@@ -600,6 +616,8 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 	for (pkt = 0; pkt < pkt_count; pkt++) {
 		u32 pkt_len = 0;
 		struct sk_buff *nicbuf = NULL;
+		struct octeon_skb_page_info *pg_info;
+		void *buf;
 
 		info = &droq->info_list[droq->read_idx];
 		octeon_swap_8B_data((u64 *)info, 2);
@@ -619,7 +637,6 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 		rh = &info->rh;
 
 		total_len += (u32)info->length;
-
 		if (OPCODE_SLOW_PATH(rh)) {
 			u32 buf_cnt;
 
@@ -628,50 +645,44 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 			droq->refill_count += buf_cnt;
 		} else {
 			if (info->length <= droq->buffer_size) {
-				lio_unmap_ring(oct->pci_dev,
-					       (u64)droq->desc_ring[
-					       droq->read_idx].buffer_ptr,
-					       droq->buffer_size);
 				pkt_len = (u32)info->length;
 				nicbuf = droq->recv_buf_list[
 					droq->read_idx].buffer;
+				pg_info = &droq->recv_buf_list[
+					droq->read_idx].pg_info;
+				if (recv_buffer_recycle(oct, pg_info))
+					pg_info->page = NULL;
 				droq->recv_buf_list[droq->read_idx].buffer =
 					NULL;
 				INCR_INDEX_BY1(droq->read_idx, droq->max_count);
-				skb_put(nicbuf, pkt_len);
 				droq->refill_count++;
 			} else {
-				nicbuf = octeon_fast_packet_alloc(oct, droq,
-								  droq->q_no,
-								  (u32)
+				nicbuf = octeon_fast_packet_alloc((u32)
 								  info->length);
 				pkt_len = 0;
 				/* nicbuf allocation can fail. We'll handle it
 				 * inside the loop.
 				 */
 				while (pkt_len < info->length) {
-					int cpy_len;
+					int cpy_len, idx = droq->read_idx;
 
-					cpy_len = ((pkt_len +
-						droq->buffer_size) >
-						info->length) ?
+					cpy_len = ((pkt_len + droq->buffer_size)
+						   > info->length) ?
 						((u32)info->length - pkt_len) :
 						droq->buffer_size;
 
 					if (nicbuf) {
-						lio_unmap_ring(oct->pci_dev,
-							       (u64)
-							       droq->desc_ring
-							       [droq->read_idx].
-							       buffer_ptr,
-							       droq->
-							       buffer_size);
 						octeon_fast_packet_next(droq,
 									nicbuf,
 									cpy_len,
-									droq->
-									read_idx
-									);
+									idx);
+						buf = droq->recv_buf_list[idx].
+							buffer;
+						recv_buffer_fast_free(buf);
+						droq->recv_buf_list[idx].buffer
+							= NULL;
+					} else {
+						droq->stats.rx_alloc_failure++;
 					}
 
 					pkt_len += cpy_len;
@@ -682,12 +693,13 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 			}
 
 			if (nicbuf) {
-				if (droq->ops.fptr)
+				if (droq->ops.fptr) {
 					droq->ops.fptr(oct->octeon_id,
-					nicbuf, pkt_len,
-					rh, &droq->napi);
-				else
+						       nicbuf, pkt_len,
+						       rh, &droq->napi);
+				} else {
 					recv_buffer_free(nicbuf);
+				}
 			}
 		}
 
@@ -695,16 +707,16 @@ octeon_droq_fast_process_packets(struct octeon_device *oct,
 			int desc_refilled = octeon_droq_refill(oct, droq);
 
 			/* Flush the droq descriptor data to memory to be sure
-			* that when we update the credits the data in memory
-			* is accurate.
-			*/
+			 * that when we update the credits the data in memory
+			 * is accurate.
+			 */
 			wmb();
 			writel((desc_refilled), droq->pkts_credit_reg);
 			/* make sure mmio write completes */
 			mmiowb();
 		}
 
-	}                       /* for ( each packet )... */
+	}                       /* for (each packet)... */
 
 	/* Increment refill_count by the number of buffers processed. */
 	droq->stats.pkts_received += pkt;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
index 7940cce..91c365c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
@@ -65,6 +65,17 @@ struct octeon_droq_info {
 
 #define OCT_DROQ_INFO_SIZE   (sizeof(struct octeon_droq_info))
 
+struct octeon_skb_page_info {
+	/* DMA address for the page */
+	dma_addr_t dma;
+
+	/* Page for the rx dma  **/
+	struct page *page;
+
+	/** which offset into page */
+	unsigned int page_offset;
+};
+
 /** Pointer to data buffer.
  *  Driver keeps a pointer to the data buffer that it made available to
  *  the Octeon device. Since the descriptor ring keeps physical (bus)
@@ -77,6 +88,9 @@ struct octeon_recv_buffer {
 
 	/** Data in the packet buffer.  */
 	u8 *data;
+
+	/** pg_info **/
+	struct octeon_skb_page_info pg_info;
 };
 
 #define OCT_DROQ_RECVBUF_SIZE    (sizeof(struct octeon_recv_buffer))
@@ -106,6 +120,10 @@ struct oct_droq_stats {
 
 	/** Num of Packets dropped due to receive path failures. */
 	u64 rx_dropped;
+
+	/** Num of failures of recv_buffer_alloc() */
+	u64 rx_alloc_failure;
+
 };
 
 #define POLL_EVENT_INTR_ARRIVED  1
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 0a50bac..0267fff 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -131,14 +131,30 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr);
  */
 void liquidio_set_ethtool_ops(struct net_device *netdev);
 
-static inline void
-*recv_buffer_alloc(struct octeon_device *oct __attribute__((unused)),
-		   u32 q_no __attribute__((unused)), u32 size)
-{
 #define SKB_ADJ_MASK  0x3F
 #define SKB_ADJ       (SKB_ADJ_MASK + 1)
 
-	struct sk_buff *skb = dev_alloc_skb(size + SKB_ADJ);
+#define MIN_SKB_SIZE       256 /* 8 bytes and more - 8 bytes for PTP */
+#define LIO_RXBUFFER_SZ    2048
+
+static inline void
+*recv_buffer_alloc(struct octeon_device *oct,
+		   struct octeon_skb_page_info *pg_info)
+{
+	struct page *page;
+	struct sk_buff *skb;
+	struct octeon_skb_page_info *skb_pg_info;
+
+	page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+	if (unlikely(!page))
+		return NULL;
+
+	skb = dev_alloc_skb(MIN_SKB_SIZE + SKB_ADJ);
+	if (unlikely(!skb)) {
+		__free_page(page);
+		pg_info->page = NULL;
+		return NULL;
+	}
 
 	if ((unsigned long)skb->data & SKB_ADJ_MASK) {
 		u32 r = SKB_ADJ - ((unsigned long)skb->data & SKB_ADJ_MASK);
@@ -146,11 +162,151 @@ static inline void
 		skb_reserve(skb, r);
 	}
 
+	skb_pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+	/* Get DMA info */
+	pg_info->dma = dma_map_page(&oct->pci_dev->dev, page, 0,
+				    PAGE_SIZE, DMA_FROM_DEVICE);
+
+	/* Mapping failed!! */
+	if (dma_mapping_error(&oct->pci_dev->dev, pg_info->dma)) {
+		__free_page(page);
+		dev_kfree_skb_any((struct sk_buff *)skb);
+		pg_info->page = NULL;
+		return NULL;
+	}
+
+	pg_info->page = page;
+	pg_info->page_offset = 0;
+	skb_pg_info->page = page;
+	skb_pg_info->page_offset = 0;
+	skb_pg_info->dma = pg_info->dma;
+
 	return (void *)skb;
 }
 
+static inline void
+*recv_buffer_fast_alloc(u32 size)
+{
+	struct sk_buff *skb;
+	struct octeon_skb_page_info *skb_pg_info;
+
+	skb = dev_alloc_skb(size + SKB_ADJ);
+	if (unlikely(!skb))
+		return NULL;
+
+	if ((unsigned long)skb->data & SKB_ADJ_MASK) {
+		u32 r = SKB_ADJ - ((unsigned long)skb->data & SKB_ADJ_MASK);
+
+		skb_reserve(skb, r);
+	}
+
+	skb_pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+	skb_pg_info->page = NULL;
+	skb_pg_info->page_offset = 0;
+	skb_pg_info->dma = 0;
+
+	return skb;
+}
+
+static inline int
+recv_buffer_recycle(struct octeon_device *oct, void *buf)
+{
+	struct octeon_skb_page_info *pg_info = buf;
+
+	if (!pg_info->page) {
+		dev_err(&oct->pci_dev->dev, "%s: pg_info->page NULL\n",
+			__func__);
+		return -ENOMEM;
+	}
+
+	if (unlikely(page_count(pg_info->page) != 1) ||
+	    unlikely(page_to_nid(pg_info->page)	!= numa_node_id())) {
+		dma_unmap_page(&oct->pci_dev->dev,
+			       pg_info->dma, (PAGE_SIZE << 0),
+			       DMA_FROM_DEVICE);
+		pg_info->dma = 0;
+		pg_info->page = NULL;
+		pg_info->page_offset = 0;
+		return -ENOMEM;
+	}
+
+	/* Flip to other half of the buffer */
+	if (pg_info->page_offset == 0)
+		pg_info->page_offset = LIO_RXBUFFER_SZ;
+	else
+		pg_info->page_offset = 0;
+	page_ref_inc(pg_info->page);
+
+	return 0;
+}
+
+static inline void
+*recv_buffer_reuse(struct octeon_device *oct, void *buf)
+{
+	struct octeon_skb_page_info *pg_info = buf, *skb_pg_info;
+	struct sk_buff *skb;
+
+	skb = dev_alloc_skb(MIN_SKB_SIZE + SKB_ADJ);
+	if (unlikely(!skb)) {
+		dma_unmap_page(&oct->pci_dev->dev,
+			       pg_info->dma, (PAGE_SIZE << 0),
+			       DMA_FROM_DEVICE);
+		return NULL;
+	}
+
+	if ((unsigned long)skb->data & SKB_ADJ_MASK) {
+		u32 r = SKB_ADJ - ((unsigned long)skb->data & SKB_ADJ_MASK);
+
+		skb_reserve(skb, r);
+	}
+
+	skb_pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+	skb_pg_info->page = pg_info->page;
+	skb_pg_info->page_offset = pg_info->page_offset;
+	skb_pg_info->dma = pg_info->dma;
+
+	return skb;
+}
+
+static inline void
+recv_buffer_destroy(void *buffer, struct octeon_skb_page_info *pg_info)
+{
+	struct sk_buff *skb = (struct sk_buff *)buffer;
+
+	put_page(pg_info->page);
+	pg_info->dma = 0;
+	pg_info->page = NULL;
+	pg_info->page_offset = 0;
+
+	if (skb)
+		dev_kfree_skb_any(skb);
+}
+
 static inline void recv_buffer_free(void *buffer)
 {
+	struct sk_buff *skb = (struct sk_buff *)buffer;
+	struct octeon_skb_page_info *pg_info;
+
+	pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+
+	if (pg_info->page) {
+		put_page(pg_info->page);
+		pg_info->dma = 0;
+		pg_info->page = NULL;
+		pg_info->page_offset = 0;
+	}
+
+	dev_kfree_skb_any((struct sk_buff *)buffer);
+}
+
+static inline void
+recv_buffer_fast_free(void *buffer)
+{
+	dev_kfree_skb_any((struct sk_buff *)buffer);
+}
+
+static inline void tx_buffer_free(void *buffer)
+{
 	dev_kfree_skb_any((struct sk_buff *)buffer);
 }
 
@@ -159,7 +315,17 @@ static inline void recv_buffer_free(void *buffer)
 #define lio_dma_free(oct, size, virt_addr, dma_addr) \
 	dma_free_coherent(&oct->pci_dev->dev, size, virt_addr, dma_addr)
 
-#define   get_rbd(ptr)      (((struct sk_buff *)(ptr))->data)
+static inline
+void *get_rbd(struct sk_buff *skb)
+{
+	struct octeon_skb_page_info *pg_info;
+	unsigned char *va;
+
+	pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+	va = page_address(pg_info->page) + pg_info->page_offset;
+
+	return va;
+}
 
 static inline u64
 lio_map_ring_info(struct octeon_droq *droq, u32 i)
@@ -183,33 +349,44 @@ lio_unmap_ring_info(struct pci_dev *pci_dev,
 }
 
 static inline u64
-lio_map_ring(struct pci_dev *pci_dev,
-	     void *buf, u32 size)
+lio_map_ring(void *buf)
 {
 	dma_addr_t dma_addr;
 
-	dma_addr = dma_map_single(&pci_dev->dev, get_rbd(buf), size,
-				  DMA_FROM_DEVICE);
+	struct sk_buff *skb = (struct sk_buff *)buf;
+	struct octeon_skb_page_info *pg_info;
 
-	BUG_ON(dma_mapping_error(&pci_dev->dev, dma_addr));
+	pg_info = ((struct octeon_skb_page_info *)(skb->cb));
+	if (!pg_info->page) {
+		pr_err("%s: pg_info->page NULL\n", __func__);
+		WARN_ON(1);
+	}
+
+	/* Get DMA info */
+	dma_addr = pg_info->dma;
+	if (!pg_info->dma) {
+		pr_err("%s: ERROR it should be already available\n",
+		       __func__);
+		WARN_ON(1);
+	}
+	dma_addr += pg_info->page_offset;
 
 	return (u64)dma_addr;
 }
 
 static inline void
 lio_unmap_ring(struct pci_dev *pci_dev,
-	       u64 buf_ptr, u32 size)
+	       u64 buf_ptr)
+
 {
-	dma_unmap_single(&pci_dev->dev,
-			 buf_ptr, size,
-			 DMA_FROM_DEVICE);
+	dma_unmap_page(&pci_dev->dev,
+		       buf_ptr, (PAGE_SIZE << 0),
+		       DMA_FROM_DEVICE);
 }
 
-static inline void *octeon_fast_packet_alloc(struct octeon_device *oct,
-					     struct octeon_droq *droq,
-					     u32 q_no, u32 size)
+static inline void *octeon_fast_packet_alloc(u32 size)
 {
-	return recv_buffer_alloc(oct, q_no, size);
+	return recv_buffer_fast_alloc(size);
 }
 
 static inline void octeon_fast_packet_next(struct octeon_droq *droq,
-- 
1.8.3.1
