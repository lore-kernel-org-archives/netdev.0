From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/4] e1000e: Remove legacy jumbo frame receive code
Date: Thu, 25 Oct 2007 13:58:03 -0700
Message-ID: <20071025205803.32645.76781.stgit@localhost.localdomain>
References: <20071025205744.32645.59503.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32383 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754431AbXJYU6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 16:58:05 -0400
In-Reply-To: <20071025205744.32645.59503.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The legacy jumbo frame receive code is no longer needed since all
hardware can do packet split and we're no longer offering a bypass
kernel config option to disable packet split. Remove the unused code.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/e1000.h  |    1 
 drivers/net/e1000e/netdev.c |  282 -------------------------------------------
 2 files changed, 1 insertions(+), 282 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 811eada..473f78d 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -122,7 +122,6 @@ struct e1000_buffer {
 			u16 next_to_watch;
 		};
 		/* RX */
-		struct page *page;
 		/* arrays of page information for packet split */
 		struct e1000_ps_page *ps_pages;
 	};
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 03fcc70..4fd2e23 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -333,94 +333,6 @@ no_buffers:
 }
 
 /**
- * e1000_alloc_rx_buffers_jumbo - Replace used jumbo receive buffers
- *
- * @adapter: address of board private structure
- * @cleaned_count: number of buffers to allocate this pass
- **/
-static void e1000_alloc_rx_buffers_jumbo(struct e1000_adapter *adapter,
-					 int cleaned_count)
-{
-	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
-	struct e1000_ring *rx_ring = adapter->rx_ring;
-	struct e1000_rx_desc *rx_desc;
-	struct e1000_buffer *buffer_info;
-	struct sk_buff *skb;
-	unsigned int i;
-	unsigned int bufsz = 256 -
-			     16 /*for skb_reserve */ -
-			     NET_IP_ALIGN;
-
-	i = rx_ring->next_to_use;
-	buffer_info = &rx_ring->buffer_info[i];
-
-	while (cleaned_count--) {
-		skb = buffer_info->skb;
-		if (skb) {
-			skb_trim(skb, 0);
-			goto check_page;
-		}
-
-		skb = netdev_alloc_skb(netdev, bufsz);
-		if (!skb) {
-			/* Better luck next round */
-			adapter->alloc_rx_buff_failed++;
-			break;
-		}
-
-		/* Make buffer alignment 2 beyond a 16 byte boundary
-		 * this will result in a 16 byte aligned IP header after
-		 * the 14 byte MAC header is removed
-		 */
-		skb_reserve(skb, NET_IP_ALIGN);
-
-		buffer_info->skb = skb;
-check_page:
-		/* allocate a new page if necessary */
-		if (!buffer_info->page) {
-			buffer_info->page = alloc_page(GFP_ATOMIC);
-			if (!buffer_info->page) {
-				adapter->alloc_rx_buff_failed++;
-				break;
-			}
-		}
-
-		if (!buffer_info->dma)
-			buffer_info->dma = pci_map_page(pdev,
-							buffer_info->page, 0,
-							PAGE_SIZE,
-							PCI_DMA_FROMDEVICE);
-		if (pci_dma_mapping_error(buffer_info->dma)) {
-			dev_err(&adapter->pdev->dev, "RX DMA page map failed\n");
-			adapter->rx_dma_failed++;
-			break;
-		}
-
-		rx_desc = E1000_RX_DESC(*rx_ring, i);
-		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
-
-		i++;
-		if (i == rx_ring->count)
-			i = 0;
-		buffer_info = &rx_ring->buffer_info[i];
-	}
-
-	if (rx_ring->next_to_use != i) {
-		rx_ring->next_to_use = i;
-		if (i-- == 0)
-			i = (rx_ring->count - 1);
-
-		/* Force memory writes to complete before letting h/w
-		 * know there are new descriptors to fetch.  (Only
-		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64). */
-		wmb();
-		writel(i, adapter->hw.hw_addr + rx_ring->tail);
-	}
-}
-
-/**
  * e1000_clean_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
  *
@@ -549,15 +461,6 @@ next_desc:
 	return cleaned;
 }
 
-static void e1000_consume_page(struct e1000_buffer *bi, struct sk_buff *skb,
-			       u16 length)
-{
-	bi->page = NULL;
-	skb->len += length;
-	skb->data_len += length;
-	skb->truesize += length;
-}
-
 static void e1000_put_txbuf(struct e1000_adapter *adapter,
 			     struct e1000_buffer *buffer_info)
 {
@@ -694,174 +597,6 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000_clean_rx_irq_jumbo - Send received data up the network stack; legacy
- * @adapter: board private structure
- *
- * the return value indicates whether actual cleaning was done, there
- * is no guarantee that everything was cleaned
- **/
-static bool e1000_clean_rx_irq_jumbo(struct e1000_adapter *adapter,
-				     int *work_done, int work_to_do)
-{
-	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
-	struct e1000_ring *rx_ring = adapter->rx_ring;
-	struct e1000_rx_desc *rx_desc, *next_rxd;
-	struct e1000_buffer *buffer_info, *next_buffer;
-	u32 length;
-	unsigned int i;
-	int cleaned_count = 0;
-	bool cleaned = 0;
-	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
-
-	i = rx_ring->next_to_clean;
-	rx_desc = E1000_RX_DESC(*rx_ring, i);
-	buffer_info = &rx_ring->buffer_info[i];
-
-	while (rx_desc->status & E1000_RXD_STAT_DD) {
-		struct sk_buff *skb;
-		u8 status;
-
-		if (*work_done >= work_to_do)
-			break;
-		(*work_done)++;
-
-		status = rx_desc->status;
-		skb = buffer_info->skb;
-		buffer_info->skb = NULL;
-
-		i++;
-		if (i == rx_ring->count)
-			i = 0;
-		next_rxd = E1000_RX_DESC(*rx_ring, i);
-		prefetch(next_rxd);
-
-		next_buffer = &rx_ring->buffer_info[i];
-
-		cleaned = 1;
-		cleaned_count++;
-		pci_unmap_page(pdev,
-			       buffer_info->dma,
-			       PAGE_SIZE,
-			       PCI_DMA_FROMDEVICE);
-		buffer_info->dma = 0;
-
-		length = le16_to_cpu(rx_desc->length);
-
-		/* errors is only valid for DD + EOP descriptors */
-		if ((status & E1000_RXD_STAT_EOP) &&
-		    (rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK)) {
-			/* recycle both page and skb */
-			buffer_info->skb = skb;
-			/* an error means any chain goes out the window too */
-			if (rx_ring->rx_skb_top)
-				dev_kfree_skb(rx_ring->rx_skb_top);
-			rx_ring->rx_skb_top = NULL;
-			goto next_desc;
-		}
-
-#define rxtop rx_ring->rx_skb_top
-		if (!(status & E1000_RXD_STAT_EOP)) {
-			/* this descriptor is only the beginning (or middle) */
-			if (!rxtop) {
-				/* this is the beginning of a chain */
-				rxtop = skb;
-				skb_fill_page_desc(rxtop, 0, buffer_info->page,
-						   0, length);
-			} else {
-				/* this is the middle of a chain */
-				skb_fill_page_desc(rxtop,
-						   skb_shinfo(rxtop)->nr_frags,
-						   buffer_info->page, 0,
-						   length);
-				/* re-use the skb, only consumed the page */
-				buffer_info->skb = skb;
-			}
-			e1000_consume_page(buffer_info, rxtop, length);
-			goto next_desc;
-		} else {
-			if (rxtop) {
-				/* end of the chain */
-				skb_fill_page_desc(rxtop,
-				    skb_shinfo(rxtop)->nr_frags,
-				    buffer_info->page, 0, length);
-				/* re-use the current skb, we only consumed the
-				 * page */
-				buffer_info->skb = skb;
-				skb = rxtop;
-				rxtop = NULL;
-				e1000_consume_page(buffer_info, skb, length);
-			} else {
-				/* no chain, got EOP, this buf is the packet
-				 * copybreak to save the put_page/alloc_page */
-				if (length <= copybreak &&
-				    skb_tailroom(skb) >= length) {
-					u8 *vaddr;
-					vaddr = kmap_atomic(buffer_info->page,
-							   KM_SKB_DATA_SOFTIRQ);
-					memcpy(skb_tail_pointer(skb),
-					       vaddr, length);
-					kunmap_atomic(vaddr,
-						      KM_SKB_DATA_SOFTIRQ);
-					/* re-use the page, so don't erase
-					 * buffer_info->page */
-					skb_put(skb, length);
-				} else {
-					skb_fill_page_desc(skb, 0,
-							   buffer_info->page, 0,
-							   length);
-					e1000_consume_page(buffer_info, skb,
-							   length);
-				}
-			}
-		}
-
-		/* Receive Checksum Offload XXX recompute due to CRC strip? */
-		e1000_rx_checksum(adapter,
-				  (u32)(status) |
-				  ((u32)(rx_desc->errors) << 24),
-				  le16_to_cpu(rx_desc->csum), skb);
-
-		pskb_trim(skb, skb->len - 4);
-
-		/* probably a little skewed due to removing CRC */
-		total_rx_bytes += skb->len;
-		total_rx_packets++;
-
-		/* eth type trans needs skb->data to point to something */
-		if (!pskb_may_pull(skb, ETH_HLEN)) {
-			ndev_err(netdev, "__pskb_pull_tail failed.\n");
-			dev_kfree_skb(skb);
-			goto next_desc;
-		}
-
-		e1000_receive_skb(adapter, netdev, skb,status,rx_desc->special);
-
-next_desc:
-		rx_desc->status = 0;
-
-		/* return some buffers to hardware, one at a time is too slow */
-		if (cleaned_count >= E1000_RX_BUFFER_WRITE) {
-			adapter->alloc_rx_buf(adapter, cleaned_count);
-			cleaned_count = 0;
-		}
-
-		/* use prefetched values */
-		rx_desc = next_rxd;
-		buffer_info = next_buffer;
-	}
-	rx_ring->next_to_clean = i;
-
-	cleaned_count = e1000_desc_unused(rx_ring);
-	if (cleaned_count)
-		adapter->alloc_rx_buf(adapter, cleaned_count);
-
-	adapter->total_rx_packets += total_rx_packets;
-	adapter->total_rx_bytes += total_rx_bytes;
-	return cleaned;
-}
-
-/**
  * e1000_clean_rx_irq_ps - Send received data up the network stack; packet split
  * @adapter: board private structure
  *
@@ -1043,9 +778,6 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 				pci_unmap_single(pdev, buffer_info->dma,
 						 adapter->rx_buffer_len,
 						 PCI_DMA_FROMDEVICE);
-			else if (adapter->clean_rx == e1000_clean_rx_irq_jumbo)
-				pci_unmap_page(pdev, buffer_info->dma,
-					       PAGE_SIZE, PCI_DMA_FROMDEVICE);
 			else if (adapter->clean_rx == e1000_clean_rx_irq_ps)
 				pci_unmap_single(pdev, buffer_info->dma,
 						 adapter->rx_ps_bsize0,
@@ -1053,11 +785,6 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter)
 			buffer_info->dma = 0;
 		}
 
-		if (buffer_info->page) {
-			put_page(buffer_info->page);
-			buffer_info->page = NULL;
-		}
-
 		if (buffer_info->skb) {
 			dev_kfree_skb(buffer_info->skb);
 			buffer_info->skb = NULL;
@@ -2072,11 +1799,6 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 			sizeof(union e1000_rx_desc_packet_split);
 		adapter->clean_rx = e1000_clean_rx_irq_ps;
 		adapter->alloc_rx_buf = e1000_alloc_rx_buffers_ps;
-	} else if (adapter->netdev->mtu > ETH_FRAME_LEN + VLAN_HLEN + 4) {
-		rdlen = rx_ring->count *
-			sizeof(struct e1000_rx_desc);
-		adapter->clean_rx = e1000_clean_rx_irq_jumbo;
-		adapter->alloc_rx_buf = e1000_alloc_rx_buffers_jumbo;
 	} else {
 		rdlen = rx_ring->count *
 			sizeof(struct e1000_rx_desc);
@@ -3623,9 +3345,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	/* NOTE: netdev_alloc_skb reserves 16 bytes, and typically NET_IP_ALIGN
 	 * means we reserve 2 more, this pushes us to allocate from the next
 	 * larger slab size.
-	 * i.e. RXBUFFER_2048 --> size-4096 slab
-	 *  however with the new *_jumbo* routines, jumbo receives will use
-	 *  fragmented skbs */
+	 * i.e. RXBUFFER_2048 --> size-4096 slab */
 
 	if (max_frame <= 256)
 		adapter->rx_buffer_len = 256;
