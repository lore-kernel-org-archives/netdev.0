From: xiaohui.xin@intel.com
Subject: [PATCH v13 15/16] An example how to modifiy NIC driver to use napi_gro_frags() interface
Date: Fri, 15 Oct 2010 17:12:16 +0800
Message-ID: <637787d5a390919dbefcd1ad31c724469cd27106.1287132437.git.xiaohui.xin@intel.com>
References: <1287133937-5538-1-git-send-email-xiaohui.xin@intel.com>
Cc: Xin Xiaohui <xiaohui.xin@intel.com>
To: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, mingo@elte.hu,
	davem@davemloft.net, herbert@gondor.apana.org.au,
	jdike@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1287133937-5538-1-git-send-email-xiaohui.xin@intel.com>
In-Reply-To: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1287132437.git.xiaohui.xin@intel.com>
References: <fc6e95d63a2c62aaf77f8ded22fc43ccefcdbbff.1287132437.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xin Xiaohui <xiaohui.xin@intel.com>

This example is made on ixgbe driver.
It provides API is_rx_buffer_mapped_as_page() to indicate
if the driver use napi_gro_frags() interface or not.
The example allocates 2 pages for DMA for one ring descriptor
using netdev_alloc_page(). When packets is coming, using
napi_gro_frags() to allocate skb and to receive the packets.

Signed-off-by: Xin Xiaohui <xiaohui.xin@intel.com>
---
 drivers/net/ixgbe/ixgbe.h      |    3 +
 drivers/net/ixgbe/ixgbe_main.c |  163 +++++++++++++++++++++++++++++++---------
 2 files changed, 131 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 9e15eb9..89367ca 100644
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
index e32af43..a4a5263 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1029,6 +1029,12 @@ static inline void ixgbe_release_rx_desc(struct ixgbe_hw *hw,
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
@@ -1045,13 +1051,17 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
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
@@ -1068,7 +1078,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 						    DMA_FROM_DEVICE);
 		}
 
-		if (!bi->skb) {
+		if (!bi->mapped_as_page && !bi->skb) {
 			struct sk_buff *skb;
 			/* netdev_alloc_skb reserves 32 bytes up front!! */
 			uint bufsz = rx_ring->rx_buf_len + SMP_CACHE_BYTES;
@@ -1088,6 +1098,19 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 			                         rx_ring->rx_buf_len,
 						 DMA_FROM_DEVICE);
 		}
+
+		if (bi->mapped_as_page && !bi->page_skb) {
+			bi->page_skb = netdev_alloc_page(adapter->netdev);
+			if (!bi->page_skb) {
+				adapter->alloc_rx_page_failed++;
+				goto no_buffers;
+			}
+			bi->page_skb_offset = 0;
+			bi->dma = dma_map_page(&pdev->dev, bi->page_skb,
+					bi->page_skb_offset,
+					(PAGE_SIZE / 2),
+					PCI_DMA_FROMDEVICE);
+		}
 		/* Refresh the desc even if buffer_addrs didn't change because
 		 * each write-back erases this info. */
 		if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
@@ -1165,6 +1188,13 @@ struct ixgbe_rsc_cb {
 	bool delay_unmap;
 };
 
+static bool is_no_buffer(struct ixgbe_rx_buffer *rx_buffer_info)
+{
+	return (!rx_buffer_info->skb ||
+		!rx_buffer_info->page_skb) &&
+		!rx_buffer_info->page;
+}
+
 #define IXGBE_RSC_CB(skb) ((struct ixgbe_rsc_cb *)(skb)->cb)
 
 static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
@@ -1174,6 +1204,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
+	struct napi_struct *napi = &q_vector->napi;
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
 	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
 	struct sk_buff *skb;
@@ -1211,32 +1242,68 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			len = le16_to_cpu(rx_desc->wb.upper.length);
 		}
 
+		if (is_no_buffer(rx_buffer_info))
+			break;
 		cleaned = true;
-		skb = rx_buffer_info->skb;
-		prefetch(skb->data);
-		rx_buffer_info->skb = NULL;
 
-		if (rx_buffer_info->dma) {
-			if ((adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
-			    (!(staterr & IXGBE_RXD_STAT_EOP)) &&
-				 (!(skb->prev))) {
-				/*
-				 * When HWRSC is enabled, delay unmapping
-				 * of the first packet. It carries the
-				 * header information, HW may still
-				 * access the header after the writeback.
-				 * Only unmap it when EOP is reached
-				 */
-				IXGBE_RSC_CB(skb)->delay_unmap = true;
-				IXGBE_RSC_CB(skb)->dma = rx_buffer_info->dma;
-			} else {
-				dma_unmap_single(&pdev->dev,
-				                 rx_buffer_info->dma,
-				                 rx_ring->rx_buf_len,
-				                 DMA_FROM_DEVICE);
+		if (!rx_buffer_info->mapped_as_page) {
+			skb = rx_buffer_info->skb;
+			prefetch(skb->data);
+			rx_buffer_info->skb = NULL;
+
+			if (rx_buffer_info->dma) {
+				if ((adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
+						(!(staterr & IXGBE_RXD_STAT_EOP)) &&
+						(!(skb->prev))) {
+					/*
+					 * When HWRSC is enabled, delay unmapping
+					 * of the first packet. It carries the
+					 * header information, HW may still
+					 * access the header after the writeback.
+					 * Only unmap it when EOP is reached
+					 */
+					IXGBE_RSC_CB(skb)->delay_unmap = true;
+					IXGBE_RSC_CB(skb)->dma = rx_buffer_info->dma;
+				} else
+					dma_unmap_single(&pdev->dev,
+							rx_buffer_info->dma,
+							rx_ring->rx_buf_len,
+							DMA_FROM_DEVICE);
+				rx_buffer_info->dma = 0;
+				skb_put(skb, len);
+			}
+		} else {
+			skb = napi_get_frags(napi);
+			prefetch(rx_buffer_info->page_skb_offset);
+			rx_buffer_info->skb = NULL;
+			if (rx_buffer_info->dma) {
+				if ((adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
+						(!(staterr & IXGBE_RXD_STAT_EOP)) &&
+						(!(skb->prev))) {
+					/*
+					 * When HWRSC is enabled, delay unmapping
+					 * of the first packet. It carries the
+					 * header information, HW may still
+					 * access the header after the writeback.
+					 * Only unmap it when EOP is reached
+					 */
+					IXGBE_RSC_CB(skb)->delay_unmap = true;
+					IXGBE_RSC_CB(skb)->dma = rx_buffer_info->dma;
+				} else
+					dma_unmap_page(&pdev->dev, rx_buffer_info->dma,
+							PAGE_SIZE / 2,
+							PCI_DMA_FROMDEVICE);
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
 			}
-			rx_buffer_info->dma = 0;
-			skb_put(skb, len);
 		}
 
 		if (upper_len) {
@@ -1283,10 +1350,16 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				skb = ixgbe_transform_rsc_queue(skb, &(rx_ring->rsc_count));
 			if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
 				if (IXGBE_RSC_CB(skb)->delay_unmap) {
-					dma_unmap_single(&pdev->dev,
-							 IXGBE_RSC_CB(skb)->dma,
-					                 rx_ring->rx_buf_len,
-							 DMA_FROM_DEVICE);
+					if (!rx_buffer_info->mapped_as_page)
+						dma_unmap_single(&pdev->dev,
+								IXGBE_RSC_CB(skb)->dma,
+								rx_ring->rx_buf_len,
+								DMA_FROM_DEVICE);
+					else
+						dma_unmap_page(&pdev->dev,
+								IXGBE_RSC_CB(skb)->dma,
+								PAGE_SIZE / 2,
+								DMA_FROM_DEVICE);
 					IXGBE_RSC_CB(skb)->dma = 0;
 					IXGBE_RSC_CB(skb)->delay_unmap = false;
 				}
@@ -1304,6 +1377,11 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 				rx_buffer_info->dma = next_buffer->dma;
 				next_buffer->skb = skb;
 				next_buffer->dma = 0;
+				if (rx_buffer_info->mapped_as_page) {
+					rx_buffer_info->page_skb =
+							next_buffer->page_skb;
+					next_buffer->page_skb = NULL;
+				}
 			} else {
 				skb->next = next_buffer->skb;
 				skb->next->prev = skb;
@@ -1323,7 +1401,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		total_rx_bytes += skb->len;
 		total_rx_packets++;
 
-		skb->protocol = eth_type_trans(skb, adapter->netdev);
+		if (!rx_buffer_info->mapped_as_page)
+			skb->protocol = eth_type_trans(skb, adapter->netdev);
 #ifdef IXGBE_FCOE
 		/* if ddp, not passing to ULD unless for FCP_RSP or error */
 		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
@@ -1332,7 +1411,14 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
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
@@ -3622,9 +3708,16 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 
 		rx_buffer_info = &rx_ring->rx_buffer_info[i];
 		if (rx_buffer_info->dma) {
-			dma_unmap_single(&pdev->dev, rx_buffer_info->dma,
-			                 rx_ring->rx_buf_len,
-					 DMA_FROM_DEVICE);
+			if (!rx_buffer_info->mapped_as_page)
+				dma_unmap_single(&pdev->dev, rx_buffer_info->dma,
+						rx_ring->rx_buf_len,
+						PCI_DMA_FROMDEVICE);
+			else {
+				dma_unmap_page(&pdev->dev, rx_buffer_info->dma,
+						PAGE_SIZE / 2,
+						PCI_DMA_FROMDEVICE);
+				rx_buffer_info->page_skb = NULL;
+			}
 			rx_buffer_info->dma = 0;
 		}
 		if (rx_buffer_info->skb) {
@@ -3651,7 +3744,7 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 				       PAGE_SIZE / 2, DMA_FROM_DEVICE);
 			rx_buffer_info->page_dma = 0;
 		}
-		put_page(rx_buffer_info->page);
+		netdev_free_page(adapter->netdev, rx_buffer_info->page);
 		rx_buffer_info->page = NULL;
 		rx_buffer_info->page_offset = 0;
 	}
-- 
1.7.3
