From: Florian Westphal <fw@strlen.de>
Subject: [PATCH V2 6/7] e1000: convert to build_skb
Date: Tue,  2 Sep 2014 14:24:49 +0200
Message-ID: <1409660690-10391-7-git-send-email-fw@strlen.de>
References: <1409660690-10391-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1409660690-10391-1-git-send-email-fw@strlen.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

instead of preallocating rx skbs, allocate them right before sending
inbound packet up the stack.

e1000-kvm, mtu1500, netperf TCP_STREAM:
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec
old: 87380  16384  16384    60.00    4532.40
new: 87380  16384  16384    60.00    4599.05

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 no changes since v1.
 drivers/net/ethernet/intel/e1000/e1000.h         |   6 +-
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c |  29 +--
 drivers/net/ethernet/intel/e1000/e1000_main.c    | 216 ++++++++++++-----------
 3 files changed, 131 insertions(+), 120 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 4c2a102..6970710 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -160,9 +160,11 @@ struct e1000_tx_buffer {
 };
 
 struct e1000_rx_buffer {
-	struct sk_buff *skb;
+	union {
+		struct page *page; /* jumbo: alloc_page */
+		u8 *data; /* else, netdev_alloc_frag */
+	} rxbuf;
 	dma_addr_t dma;
-	struct page *page;
 };
 
 struct e1000_tx_ring {
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 380a730..ee139bf 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -974,8 +974,7 @@ static void e1000_free_desc_rings(struct e1000_adapter *adapter)
 						 rxdr->buffer_info[i].dma,
 						 E1000_RXBUFFER_2048,
 						 DMA_FROM_DEVICE);
-			if (rxdr->buffer_info[i].skb)
-				dev_kfree_skb(rxdr->buffer_info[i].skb);
+			kfree(rxdr->buffer_info[i].rxbuf.data);
 		}
 	}
 
@@ -1099,24 +1098,25 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 
 	for (i = 0; i < rxdr->count; i++) {
 		struct e1000_rx_desc *rx_desc = E1000_RX_DESC(*rxdr, i);
-		struct sk_buff *skb;
+		u8 *buf;
 
-		skb = alloc_skb(E1000_RXBUFFER_2048 + NET_IP_ALIGN, GFP_KERNEL);
-		if (!skb) {
+		buf = kzalloc(E1000_RXBUFFER_2048 + NET_SKB_PAD + NET_IP_ALIGN,
+			      GFP_KERNEL);
+		if (!buf) {
 			ret_val = 7;
 			goto err_nomem;
 		}
-		skb_reserve(skb, NET_IP_ALIGN);
-		rxdr->buffer_info[i].skb = skb;
+		rxdr->buffer_info[i].rxbuf.data = buf;
+
 		rxdr->buffer_info[i].dma =
-			dma_map_single(&pdev->dev, skb->data,
+			dma_map_single(&pdev->dev,
+				       buf + NET_SKB_PAD + NET_IP_ALIGN,
 				       E1000_RXBUFFER_2048, DMA_FROM_DEVICE);
 		if (dma_mapping_error(&pdev->dev, rxdr->buffer_info[i].dma)) {
 			ret_val = 8;
 			goto err_nomem;
 		}
 		rx_desc->buffer_addr = cpu_to_le64(rxdr->buffer_info[i].dma);
-		memset(skb->data, 0x00, skb->len);
 	}
 
 	return 0;
@@ -1390,13 +1390,13 @@ static void e1000_create_lbtest_frame(struct sk_buff *skb,
 	memset(&skb->data[frame_size / 2 + 12], 0xAF, 1);
 }
 
-static int e1000_check_lbtest_frame(struct sk_buff *skb,
+static int e1000_check_lbtest_frame(const unsigned char *data,
 				    unsigned int frame_size)
 {
 	frame_size &= ~1;
-	if (*(skb->data + 3) == 0xFF) {
-		if ((*(skb->data + frame_size / 2 + 10) == 0xBE) &&
-		   (*(skb->data + frame_size / 2 + 12) == 0xAF)) {
+	if (*(data + 3) == 0xFF) {
+		if ((*(data + frame_size / 2 + 10) == 0xBE) &&
+		    (*(data + frame_size / 2 + 12) == 0xAF)) {
 			return 0;
 		}
 	}
@@ -1447,7 +1447,8 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 						DMA_FROM_DEVICE);
 
 			ret_val = e1000_check_lbtest_frame(
-					rxdr->buffer_info[l].skb,
+					rxdr->buffer_info[l].rxbuf.data +
+					NET_SKB_PAD + NET_IP_ALIGN,
 					1024);
 			if (!ret_val)
 				good_cnt++;
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 73cd509..9ac9a77 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2054,6 +2054,28 @@ void e1000_free_all_rx_resources(struct e1000_adapter *adapter)
 		e1000_free_rx_resources(adapter, &adapter->rx_ring[i]);
 }
 
+#define E1000_HEADROOM (NET_SKB_PAD + NET_IP_ALIGN)
+static unsigned int e1000_frag_len(const struct e1000_adapter *a)
+{
+	return SKB_DATA_ALIGN(a->rx_buffer_len + E1000_HEADROOM) +
+		SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
+}
+
+static void *e1000_alloc_frag(const struct e1000_adapter *a)
+{
+	unsigned int len = e1000_frag_len(a);
+	u8 *data = netdev_alloc_frag(len);
+
+	if (likely(data))
+		data += E1000_HEADROOM;
+	return data;
+}
+
+static void e1000_free_frag(const void *data)
+{
+	put_page(virt_to_head_page(data));
+}
+
 /**
  * e1000_clean_rx_ring - Free Rx Buffers per Queue
  * @adapter: board private structure
@@ -2068,30 +2090,30 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 	unsigned long size;
 	unsigned int i;
 
-	/* Free all the Rx ring sk_buffs */
+	/* Free all the rx netfrags */
 	for (i = 0; i < rx_ring->count; i++) {
 		buffer_info = &rx_ring->buffer_info[i];
-		if (buffer_info->dma &&
-		    adapter->clean_rx == e1000_clean_rx_irq) {
-			dma_unmap_single(&pdev->dev, buffer_info->dma,
-					 adapter->rx_buffer_len,
-					 DMA_FROM_DEVICE);
-		} else if (buffer_info->dma &&
-		           adapter->clean_rx == e1000_clean_jumbo_rx_irq) {
-			dma_unmap_page(&pdev->dev, buffer_info->dma,
-				       adapter->rx_buffer_len,
-				       DMA_FROM_DEVICE);
+		if (adapter->clean_rx == e1000_clean_rx_irq) {
+			if (buffer_info->dma)
+				dma_unmap_single(&pdev->dev, buffer_info->dma,
+						 adapter->rx_buffer_len,
+						 DMA_FROM_DEVICE);
+			if (buffer_info->rxbuf.data) {
+				e1000_free_frag(buffer_info->rxbuf.data);
+				buffer_info->rxbuf.data = NULL;
+			}
+		} else if (adapter->clean_rx == e1000_clean_jumbo_rx_irq) {
+			if (buffer_info->dma)
+				dma_unmap_page(&pdev->dev, buffer_info->dma,
+					       adapter->rx_buffer_len,
+					       DMA_FROM_DEVICE);
+			if (buffer_info->rxbuf.page) {
+				put_page(buffer_info->rxbuf.page);
+				buffer_info->rxbuf.page = NULL;
+			}
 		}
 
 		buffer_info->dma = 0;
-		if (buffer_info->page) {
-			put_page(buffer_info->page);
-			buffer_info->page = NULL;
-		}
-		if (buffer_info->skb) {
-			dev_kfree_skb(buffer_info->skb);
-			buffer_info->skb = NULL;
-		}
 	}
 
 	/* there also may be some cached data from a chained receive */
@@ -3427,7 +3449,7 @@ rx_ring_summary:
 
 		pr_info("R[0x%03X]     %016llX %016llX %016llX %p %s\n",
 			i, le64_to_cpu(u->a), le64_to_cpu(u->b),
-			(u64)buffer_info->dma, buffer_info->skb, type);
+			(u64)buffer_info->dma, buffer_info->rxbuf.data, type);
 	} /* for */
 
 	/* dump the descriptor caches */
@@ -3947,12 +3969,12 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 }
 
 /**
- * e1000_consume_page - helper function
+ * e1000_consume_page - helper function for jumbo rx path
  **/
 static void e1000_consume_page(struct e1000_rx_buffer *bi, struct sk_buff *skb,
 			       u16 length)
 {
-	bi->page = NULL;
+	bi->rxbuf.page = NULL;
 	skb->len += length;
 	skb->data_len += length;
 	skb->truesize += PAGE_SIZE;
@@ -4108,6 +4130,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 	int cleaned_count = 0;
 	bool cleaned = false;
 	unsigned int total_rx_bytes=0, total_rx_packets=0;
+	static const unsigned int bufsz = 256 - 16; /* for skb_reserve */
 
 	i = rx_ring->next_to_clean;
 	rx_desc = E1000_RX_DESC(*rx_ring, i);
@@ -4123,8 +4146,6 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		rmb(); /* read descriptor and rx_buffer_info after status DD */
 
 		status = rx_desc->status;
-		skb = buffer_info->skb;
-		buffer_info->skb = NULL;
 
 		if (++i == rx_ring->count) i = 0;
 		next_rxd = E1000_RX_DESC(*rx_ring, i);
@@ -4143,7 +4164,7 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 		/* errors is only valid for DD + EOP descriptors */
 		if (unlikely((status & E1000_RXD_STAT_EOP) &&
 		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK))) {
-			u8 *mapped = page_address(buffer_info->page);
+			u8 *mapped = page_address(buffer_info->rxbuf.page);
 
 			if (e1000_tbi_should_accept(adapter, status,
 						    rx_desc->errors,
@@ -4152,8 +4173,6 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
 			} else if (netdev->features & NETIF_F_RXALL) {
 				goto process_skb;
 			} else {
-				/* recycle both page and skb */
-				buffer_info->skb = skb;
 				/* an error means any chain goes out the window
 				 * too
 				 */
@@ -4170,16 +4189,18 @@ process_skb:
 			/* this descriptor is only the beginning (or middle) */
 			if (!rxtop) {
 				/* this is the beginning of a chain */
-				rxtop = skb;
-				skb_fill_page_desc(rxtop, 0, buffer_info->page,
+				rxtop = e1000_alloc_rx_skb(adapter, bufsz);
+				if (!rxtop)
+					break;
+
+				skb_fill_page_desc(rxtop, 0,
+						   buffer_info->rxbuf.page,
 						   0, length);
 			} else {
 				/* this is the middle of a chain */
 				skb_fill_page_desc(rxtop,
 				    skb_shinfo(rxtop)->nr_frags,
-				    buffer_info->page, 0, length);
-				/* re-use the skb, only consumed the page */
-				buffer_info->skb = skb;
+				    buffer_info->rxbuf.page, 0, length);
 			}
 			e1000_consume_page(buffer_info, rxtop, length);
 			goto next_desc;
@@ -4188,32 +4209,33 @@ process_skb:
 				/* end of the chain */
 				skb_fill_page_desc(rxtop,
 				    skb_shinfo(rxtop)->nr_frags,
-				    buffer_info->page, 0, length);
-				/* re-use the current skb, we only consumed the
-				 * page
-				 */
-				buffer_info->skb = skb;
+				    buffer_info->rxbuf.page, 0, length);
 				skb = rxtop;
 				rxtop = NULL;
 				e1000_consume_page(buffer_info, skb, length);
 			} else {
+				struct page *p;
 				/* no chain, got EOP, this buf is the packet
 				 * copybreak to save the put_page/alloc_page
 				 */
+				skb = e1000_alloc_rx_skb(adapter, bufsz);
+				if (!skb)
+					break;
+				p = buffer_info->rxbuf.page;
 				if (length <= copybreak &&
 				    skb_tailroom(skb) >= length) {
 					u8 *vaddr;
-					vaddr = kmap_atomic(buffer_info->page);
+
+					vaddr = kmap_atomic(p);
 					memcpy(skb_tail_pointer(skb), vaddr,
 					       length);
 					kunmap_atomic(vaddr);
 					/* re-use the page, so don't erase
-					 * buffer_info->page
+					 * buffer_info->rxbuf.page
 					 */
 					skb_put(skb, length);
 				} else {
-					skb_fill_page_desc(skb, 0,
-							   buffer_info->page, 0,
+					skb_fill_page_desc(skb, 0, p, 0,
 							   length);
 					e1000_consume_page(buffer_info, skb,
 							   length);
@@ -4318,6 +4340,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 	while (rx_desc->status & E1000_RXD_STAT_DD) {
 		struct sk_buff *skb;
+		u8 *data;
 		u8 status;
 
 		if (*work_done >= work_to_do)
@@ -4328,16 +4351,24 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		status = rx_desc->status;
 		length = le16_to_cpu(rx_desc->length);
 
-		prefetch(buffer_info->skb->data - NET_IP_ALIGN);
-		skb = e1000_copybreak(adapter, buffer_info, length,
-				      buffer_info->skb->data);
+		data = buffer_info->rxbuf.data;
+		prefetch(data);
+		skb = e1000_copybreak(adapter, buffer_info, length, data);
 		if (!skb) {
-			skb = buffer_info->skb;
-			buffer_info->skb = NULL;
+			unsigned int frag_len = e1000_frag_len(adapter);
+
+			skb = build_skb(data - E1000_HEADROOM, frag_len);
+			if (!skb) {
+				adapter->alloc_rx_buff_failed++;
+				break;
+			}
+
+			skb_reserve(skb, E1000_HEADROOM);
 			dma_unmap_single(&pdev->dev, buffer_info->dma,
 					 adapter->rx_buffer_len,
 					 DMA_FROM_DEVICE);
 			buffer_info->dma = 0;
+			buffer_info->rxbuf.data = NULL;
 		}
 
 		if (++i == rx_ring->count) i = 0;
@@ -4370,7 +4401,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		if (unlikely(rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK)) {
 			if (e1000_tbi_should_accept(adapter, status,
 						    rx_desc->errors,
-						    length, skb->data)) {
+						    length, data)) {
 				length--;
 			} else if (netdev->features & NETIF_F_RXALL) {
 				goto process_skb;
@@ -4390,7 +4421,7 @@ process_skb:
 			 */
 			length -= 4;
 
-		if (buffer_info->skb == NULL)
+		if (buffer_info->rxbuf.data == NULL)
 			skb_put(skb, length);
 		else /* copybreak skb */
 			skb_trim(skb, length);
@@ -4439,37 +4470,19 @@ static void
 e1000_alloc_jumbo_rx_buffers(struct e1000_adapter *adapter,
 			     struct e1000_rx_ring *rx_ring, int cleaned_count)
 {
-	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc;
 	struct e1000_rx_buffer *buffer_info;
-	struct sk_buff *skb;
 	unsigned int i;
-	unsigned int bufsz = 256 - 16 /*for skb_reserve */ ;
 
 	i = rx_ring->next_to_use;
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while (cleaned_count--) {
-		skb = buffer_info->skb;
-		if (skb) {
-			skb_trim(skb, 0);
-			goto check_page;
-		}
-
-		skb = netdev_alloc_skb_ip_align(netdev, bufsz);
-		if (unlikely(!skb)) {
-			/* Better luck next round */
-			adapter->alloc_rx_buff_failed++;
-			break;
-		}
-
-		buffer_info->skb = skb;
-check_page:
 		/* allocate a new page if necessary */
-		if (!buffer_info->page) {
-			buffer_info->page = alloc_page(GFP_ATOMIC);
-			if (unlikely(!buffer_info->page)) {
+		if (!buffer_info->rxbuf.page) {
+			buffer_info->rxbuf.page = alloc_page(GFP_ATOMIC);
+			if (unlikely(!buffer_info->rxbuf.page)) {
 				adapter->alloc_rx_buff_failed++;
 				break;
 			}
@@ -4477,17 +4490,15 @@ check_page:
 
 		if (!buffer_info->dma) {
 			buffer_info->dma = dma_map_page(&pdev->dev,
-							buffer_info->page, 0,
-							PAGE_SIZE,
+							buffer_info->rxbuf.page, 0,
+							adapter->rx_buffer_len,
 							DMA_FROM_DEVICE);
 			if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
-				put_page(buffer_info->page);
-				dev_kfree_skb(skb);
-				buffer_info->page = NULL;
-				buffer_info->skb = NULL;
+				put_page(buffer_info->rxbuf.page);
+				buffer_info->rxbuf.page = NULL;
 				buffer_info->dma = 0;
 				adapter->alloc_rx_buff_failed++;
-				break; /* while !buffer_info->skb */
+				break;
 			}
 		}
 
@@ -4523,11 +4534,9 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 				   int cleaned_count)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc;
 	struct e1000_rx_buffer *buffer_info;
-	struct sk_buff *skb;
 	unsigned int i;
 	unsigned int bufsz = adapter->rx_buffer_len;
 
@@ -4535,55 +4544,52 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 	buffer_info = &rx_ring->buffer_info[i];
 
 	while (cleaned_count--) {
-		skb = buffer_info->skb;
-		if (skb) {
-			skb_trim(skb, 0);
+		void *data;
+
+		if (buffer_info->rxbuf.data)
 			goto skip;
-		}
 
-		skb = netdev_alloc_skb_ip_align(netdev, bufsz);
-		if (unlikely(!skb)) {
+		data = e1000_alloc_frag(adapter);
+		if (!data) {
 			/* Better luck next round */
 			adapter->alloc_rx_buff_failed++;
 			break;
 		}
 
 		/* Fix for errata 23, can't cross 64kB boundary */
-		if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
-			struct sk_buff *oldskb = skb;
+		if (!e1000_check_64k_bound(adapter, data, bufsz)) {
+			void *olddata = data;
 			e_err(rx_err, "skb align check failed: %u bytes at "
-			      "%p\n", bufsz, skb->data);
+			      "%p\n", bufsz, data);
 			/* Try again, without freeing the previous */
-			skb = netdev_alloc_skb_ip_align(netdev, bufsz);
+			data = e1000_alloc_frag(adapter);
 			/* Failed allocation, critical failure */
-			if (!skb) {
-				dev_kfree_skb(oldskb);
+			if (!data) {
+				e1000_free_frag(olddata);
 				adapter->alloc_rx_buff_failed++;
 				break;
 			}
 
-			if (!e1000_check_64k_bound(adapter, skb->data, bufsz)) {
+			if (!e1000_check_64k_bound(adapter, data, bufsz)) {
 				/* give up */
-				dev_kfree_skb(skb);
-				dev_kfree_skb(oldskb);
+				e1000_free_frag(data);
+				e1000_free_frag(olddata);
 				adapter->alloc_rx_buff_failed++;
-				break; /* while !buffer_info->skb */
+				break;
 			}
 
 			/* Use new allocation */
-			dev_kfree_skb(oldskb);
+			e1000_free_frag(olddata);
 		}
-		buffer_info->skb = skb;
 		buffer_info->dma = dma_map_single(&pdev->dev,
-						  skb->data,
+						  data,
 						  adapter->rx_buffer_len,
 						  DMA_FROM_DEVICE);
 		if (dma_mapping_error(&pdev->dev, buffer_info->dma)) {
-			dev_kfree_skb(skb);
-			buffer_info->skb = NULL;
+			e1000_free_frag(data);
 			buffer_info->dma = 0;
 			adapter->alloc_rx_buff_failed++;
-			break; /* while !buffer_info->skb */
+			break;
 		}
 
 		/* XXX if it was allocated cleanly it will never map to a
@@ -4597,21 +4603,23 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 			e_err(rx_err, "dma align check failed: %u bytes at "
 			      "%p\n", adapter->rx_buffer_len,
 			      (void *)(unsigned long)buffer_info->dma);
-			dev_kfree_skb(skb);
-			buffer_info->skb = NULL;
 
 			dma_unmap_single(&pdev->dev, buffer_info->dma,
 					 adapter->rx_buffer_len,
 					 DMA_FROM_DEVICE);
+
+			e1000_free_frag(data);
+			buffer_info->rxbuf.data = NULL;
 			buffer_info->dma = 0;
 
 			adapter->alloc_rx_buff_failed++;
-			break; /* while !buffer_info->skb */
+			break;
 		}
+		buffer_info->rxbuf.data = data;
+ skip:
 		rx_desc = E1000_RX_DESC(*rx_ring, i);
 		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
 
-skip:
 		if (unlikely(++i == rx_ring->count))
 			i = 0;
 		buffer_info = &rx_ring->buffer_info[i];
-- 
1.8.1.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
