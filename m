From: xiaohui.xin@intel.com
Subject: [RFC PATCH v9 15/16] An example how to modifiy NIC driver to use napi_gro_frags() interface
Date: Fri,  6 Aug 2010 17:23:43 +0800
Message-ID: <1281086624-5765-16-git-send-email-xiaohui.xin@intel.com>
References: <1281086624-5765-1-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-2-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-3-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-4-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-5-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-6-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-7-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-8-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-9-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-10-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-11-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-12-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-13-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-14-git-send-email-xiaohui.xin@intel.com>
 <1281086624-5765-15-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281086624-5765-15-git-send-email-xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

This example is made on ixgbe driver.
It provides API is_rx_buffer_mapped_as_page() to indicate
if the driver use napi_gro_frags() interface or not.
The example allocates 2 pages for DMA for one ring descriptor
using netdev_alloc_page(). When packets is coming, using
napi_gro_frags() to allocate skb and to receive the packets.

---
 drivers/net/ixgbe/ixgbe.h      |    3 +
 drivers/net/ixgbe/ixgbe_main.c |  138 +++++++++++++++++++++++++++++++--------
 2 files changed, 112 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 79c35ae..fceffc5 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -131,6 +131,9 @@ struct ixgbe_rx_buffer {
 	struct page *page;
 	dma_addr_t page_dma;
 	unsigned int page_offset;
+	u16 mapped_as_page;
+	struct page *page_skb;
+	unsigned int page_skb_offset;
 };
 
 struct ixgbe_queue_stats {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 6c00ee4..cfe6853 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -688,6 +688,12 @@ static inline void ixgbe_release_rx_desc(struct ixgbe_hw *hw,
 	IXGBE_WRITE_REG(hw, IXGBE_RDT(rx_ring->reg_idx), val);
 }
 
+static bool is_rx_buffer_mapped_as_page(struct ixgbe_rx_buffer *bi,
+					struct net_device *dev)
+{
+	return true;
+}
+
 /**
  * ixgbe_alloc_rx_buffers - Replace used receive buffers; packet split
  * @adapter: address of board private structure
@@ -704,13 +710,17 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 	i = rx_ring->next_to_use;
 	bi = &rx_ring->rx_buffer_info[i];
 
+
 	while (cleaned_count--) {
 		rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
 
+		bi->mapped_as_page =
+			is_rx_buffer_mapped_as_page(bi, adapter->netdev);
+
 		if (!bi->page_dma &&
 		    (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)) {
 			if (!bi->page) {
-				bi->page = alloc_page(GFP_ATOMIC);
+				bi->page = netdev_alloc_page(adapter->netdev);
 				if (!bi->page) {
 					adapter->alloc_rx_page_failed++;
 					goto no_buffers;
@@ -727,7 +737,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 			                            PCI_DMA_FROMDEVICE);
 		}
 
-		if (!bi->skb) {
+		if (!bi->mapped_as_page && !bi->skb) {
 			struct sk_buff *skb;
 			/* netdev_alloc_skb reserves 32 bytes up front!! */
 			uint bufsz = rx_ring->rx_buf_len + SMP_CACHE_BYTES;
@@ -747,6 +757,19 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 			                         rx_ring->rx_buf_len,
 			                         PCI_DMA_FROMDEVICE);
 		}
+
+		if (bi->mapped_as_page && !bi->page_skb) {
+			bi->page_skb = netdev_alloc_page(adapter->netdev);
+			if (!bi->page_skb) {
+				adapter->alloc_rx_page_failed++;
+				goto no_buffers;
+			}
+			bi->page_skb_offset = 0;
+			bi->dma = pci_map_page(pdev, bi->page_skb,
+					bi->page_skb_offset,
+					(PAGE_SIZE / 2),
+					PCI_DMA_FROMDEVICE);
+		}
 		/* Refresh the desc even if buffer_addrs didn't change because
 		 * each write-back erases this info. */
 		if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
@@ -823,6 +846,13 @@ struct ixgbe_rsc_cb {
 	dma_addr_t dma;
 };
 
+static bool is_no_buffer(struct ixgbe_rx_buffer *rx_buffer_info)
+{
+	return ((!rx_buffer_info->skb ||
+		!rx_buffer_info->page_skb) &&
+		!rx_buffer_info->page);
+}
+
 #define IXGBE_RSC_CB(skb) ((struct ixgbe_rsc_cb *)(skb)->cb)
 
 static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
@@ -832,6 +862,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
+	struct napi_struct *napi = &q_vector->napi;
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
 	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
 	struct sk_buff *skb;
@@ -868,29 +899,57 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			len = le16_to_cpu(rx_desc->wb.upper.length);
 		}
 
+		if (is_no_buffer(rx_buffer_info))
+			break;
+
 		cleaned = true;
-		skb = rx_buffer_info->skb;
-		prefetch(skb->data);
-		rx_buffer_info->skb = NULL;
 
-		if (rx_buffer_info->dma) {
-			if ((adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
-			    (!(staterr & IXGBE_RXD_STAT_EOP)) &&
-				 (!(skb->prev)))
-				/*
-				 * When HWRSC is enabled, delay unmapping
-				 * of the first packet. It carries the
-				 * header information, HW may still
-				 * access the header after the writeback.
-				 * Only unmap it when EOP is reached
-				 */
-				IXGBE_RSC_CB(skb)->dma = rx_buffer_info->dma;
-			else
-				pci_unmap_single(pdev, rx_buffer_info->dma,
-				                 rx_ring->rx_buf_len,
-				                 PCI_DMA_FROMDEVICE);
-			rx_buffer_info->dma = 0;
-			skb_put(skb, len);
+		if (!rx_buffer_info->mapped_as_page) {
+			skb = rx_buffer_info->skb;
+			prefetch(skb->data);
+			rx_buffer_info->skb = NULL;
+
+			if (rx_buffer_info->dma) {
+				if ((adapter->flags2 &
+					IXGBE_FLAG2_RSC_ENABLED) &&
+					(!(staterr & IXGBE_RXD_STAT_EOP)) &&
+					(!(skb->prev)))
+					/*
+					 * When HWRSC is enabled, delay unmapping
+					 * of the first packet. It carries the
+					 * header information, HW may still
+					 * access the header after the writeback.
+					 * Only unmap it when EOP is reached
+					 */
+					IXGBE_RSC_CB(skb)->dma =
+							rx_buffer_info->dma;
+				else
+					pci_unmap_single(pdev,
+							rx_buffer_info->dma,
+							rx_ring->rx_buf_len,
+							PCI_DMA_FROMDEVICE);
+				rx_buffer_info->dma = 0;
+				skb_put(skb, len);
+			}
+		} else {
+			skb = napi_get_frags(napi);
+			prefetch(rx_buffer_info->page_skb_offset);
+			rx_buffer_info->skb = NULL;
+			if (rx_buffer_info->dma) {
+				pci_unmap_page(pdev, rx_buffer_info->dma,
+						PAGE_SIZE / 2,
+						PCI_DMA_FROMDEVICE);
+				rx_buffer_info->dma = 0;
+				skb_fill_page_desc(skb,
+						skb_shinfo(skb)->nr_frags,
+						rx_buffer_info->page_skb,
+						rx_buffer_info->page_skb_offset,
+						len);
+				rx_buffer_info->page_skb = NULL;
+				skb->len += len;
+				skb->data_len += len;
+				skb->truesize += len;
+			}
 		}
 
 		if (upper_len) {
@@ -956,6 +1015,12 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				rx_buffer_info->dma = next_buffer->dma;
 				next_buffer->skb = skb;
 				next_buffer->dma = 0;
+				if (rx_buffer_info->mapped_as_page) {
+					rx_buffer_info->page_skb =
+							next_buffer->page_skb;
+					next_buffer->page_skb = NULL;
+					next_buffer->skb = NULL;
+				}
 			} else {
 				skb->next = next_buffer->skb;
 				skb->next->prev = skb;
@@ -975,7 +1040,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
 
-		skb->protocol = eth_type_trans(skb, adapter->netdev);
+		if (!rx_buffer_info->mapped_as_page)
+			skb->protocol = eth_type_trans(skb, adapter->netdev);
 #ifdef IXGBE_FCOE
 		/* if ddp, not passing to ULD unless for FCP_RSP or error */
 		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
@@ -984,7 +1050,14 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				goto next_desc;
 		}
 #endif /* IXGBE_FCOE */
-		ixgbe_receive_skb(q_vector, skb, staterr, rx_ring, rx_desc);
+
+		if (!rx_buffer_info->mapped_as_page)
+			ixgbe_receive_skb(q_vector, skb, staterr,
+						rx_ring, rx_desc);
+		else {
+			skb_record_rx_queue(skb, rx_ring->queue_index);
+			napi_gro_frags(napi);
+		}
 
 next_desc:
 		rx_desc->wb.upper.status_error = 0;
@@ -3131,9 +3204,16 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 
 		rx_buffer_info = &rx_ring->rx_buffer_info[i];
 		if (rx_buffer_info->dma) {
-			pci_unmap_single(pdev, rx_buffer_info->dma,
-			                 rx_ring->rx_buf_len,
-			                 PCI_DMA_FROMDEVICE);
+			if (!rx_buffer_info->mapped_as_page) {
+				pci_unmap_single(pdev, rx_buffer_info->dma,
+						rx_ring->rx_buf_len,
+						PCI_DMA_FROMDEVICE);
+			} else {
+				pci_unmap_page(pdev, rx_buffer_info->dma,
+						PAGE_SIZE / 2,
+						PCI_DMA_FROMDEVICE);
+				rx_buffer_info->page_skb = NULL;
+			}
 			rx_buffer_info->dma = 0;
 		}
 		if (rx_buffer_info->skb) {
@@ -3158,7 +3238,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 			               PAGE_SIZE / 2, PCI_DMA_FROMDEVICE);
 			rx_buffer_info->page_dma = 0;
 		}
-		put_page(rx_buffer_info->page);
+		netdev_free_page(adapter->netdev, rx_buffer_info->page);
 		rx_buffer_info->page = NULL;
 		rx_buffer_info->page_offset = 0;
 	}
-- 
1.5.4.4
