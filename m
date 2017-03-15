From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/12] i40e/i40evf: Add support for mapping pages with DMA attributes
Date: Wed, 15 Mar 2017 02:25:42 -0700
Message-ID: <20170315092545.63654-10-jeffrey.t.kirsher@intel.com>
References: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52220 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752566AbdCOJ0G (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Mar 2017 05:26:06 -0400
In-Reply-To: <20170315092545.63654-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for DMA_ATTR_SKIP_CPU_SYNC and
DMA_ATTR_WEAK_ORDERING. By enabling both of these for the Rx path we
are able to see performance improvements on architectures that implement
either one due to the fact that page mapping and unmapping only has to
sync what is actually being used instead of the entire buffer. In addition
by enabling the weak ordering attribute enables a performance improvement
for architectures that can associate a memory ordering with a DMA buffer
such as Sparc.

Change-ID: If176824e8231c5b24b8a5d55b339a6026738fc75
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 31 ++++++++++++++++++++++-----
 drivers/net/ethernet/intel/i40e/i40e_txrx.h   |  3 +++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 31 ++++++++++++++++++++++-----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.h |  3 +++
 4 files changed, 58 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 97d46058d71d..86e4991a03a7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1010,7 +1010,6 @@ int i40e_setup_tx_descriptors(struct i40e_ring *tx_ring)
  **/
 void i40e_clean_rx_ring(struct i40e_ring *rx_ring)
 {
-	struct device *dev = rx_ring->dev;
 	unsigned long bi_size;
 	u16 i;
 
@@ -1030,7 +1029,20 @@ void i40e_clean_rx_ring(struct i40e_ring *rx_ring)
 		if (!rx_bi->page)
 			continue;
 
-		dma_unmap_page(dev, rx_bi->dma, PAGE_SIZE, DMA_FROM_DEVICE);
+		/* Invalidate cache lines that may have been written to by
+		 * device so that we avoid corrupting memory.
+		 */
+		dma_sync_single_range_for_cpu(rx_ring->dev,
+					      rx_bi->dma,
+					      rx_bi->page_offset,
+					      I40E_RXBUFFER_2048,
+					      DMA_FROM_DEVICE);
+
+		/* free resources associated with mapping */
+		dma_unmap_page_attrs(rx_ring->dev, rx_bi->dma,
+				     PAGE_SIZE,
+				     DMA_FROM_DEVICE,
+				     I40E_RX_DMA_ATTR);
 		__free_pages(rx_bi->page, 0);
 
 		rx_bi->page = NULL;
@@ -1159,7 +1171,10 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 	}
 
 	/* map page for use */
-	dma = dma_map_page(rx_ring->dev, page, 0, PAGE_SIZE, DMA_FROM_DEVICE);
+	dma = dma_map_page_attrs(rx_ring->dev, page, 0,
+				 PAGE_SIZE,
+				 DMA_FROM_DEVICE,
+				 I40E_RX_DMA_ATTR);
 
 	/* if mapping failed free memory back to system since
 	 * there isn't much point in holding memory we can't use
@@ -1219,6 +1234,12 @@ bool i40e_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 		if (!i40e_alloc_mapped_page(rx_ring, bi))
 			goto no_buffers;
 
+		/* sync the buffer for use by the device */
+		dma_sync_single_range_for_device(rx_ring->dev, bi->dma,
+						 bi->page_offset,
+						 I40E_RXBUFFER_2048,
+						 DMA_FROM_DEVICE);
+
 		/* Refresh the desc even if buffer_addrs didn't change
 		 * because each write-back erases this info.
 		 */
@@ -1685,8 +1706,8 @@ struct sk_buff *i40e_fetch_rx_buffer(struct i40e_ring *rx_ring,
 		rx_ring->rx_stats.page_reuse_count++;
 	} else {
 		/* we are not reusing the buffer so unmap it */
-		dma_unmap_page(rx_ring->dev, rx_buffer->dma, PAGE_SIZE,
-			       DMA_FROM_DEVICE);
+		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma, PAGE_SIZE,
+				     DMA_FROM_DEVICE, I40E_RX_DMA_ATTR);
 	}
 
 	/* clear contents of buffer_info */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index f80979025c01..49c7b2089d8e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -133,6 +133,9 @@ enum i40e_dyn_idx_t {
 #define I40E_RX_HDR_SIZE I40E_RXBUFFER_256
 #define i40e_rx_desc i40e_32byte_rx_desc
 
+#define I40E_RX_DMA_ATTR \
+	(DMA_ATTR_SKIP_CPU_SYNC | DMA_ATTR_WEAK_ORDERING)
+
 /**
  * i40e_test_staterr - tests bits in Rx descriptor status and error fields
  * @rx_desc: pointer to receive descriptor (in le64 format)
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index c91fcf43ccbc..d7790c08e523 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -493,7 +493,6 @@ int i40evf_setup_tx_descriptors(struct i40e_ring *tx_ring)
  **/
 void i40evf_clean_rx_ring(struct i40e_ring *rx_ring)
 {
-	struct device *dev = rx_ring->dev;
 	unsigned long bi_size;
 	u16 i;
 
@@ -513,7 +512,20 @@ void i40evf_clean_rx_ring(struct i40e_ring *rx_ring)
 		if (!rx_bi->page)
 			continue;
 
-		dma_unmap_page(dev, rx_bi->dma, PAGE_SIZE, DMA_FROM_DEVICE);
+		/* Invalidate cache lines that may have been written to by
+		 * device so that we avoid corrupting memory.
+		 */
+		dma_sync_single_range_for_cpu(rx_ring->dev,
+					      rx_bi->dma,
+					      rx_bi->page_offset,
+					      I40E_RXBUFFER_2048,
+					      DMA_FROM_DEVICE);
+
+		/* free resources associated with mapping */
+		dma_unmap_page_attrs(rx_ring->dev, rx_bi->dma,
+				     PAGE_SIZE,
+				     DMA_FROM_DEVICE,
+				     I40E_RX_DMA_ATTR);
 		__free_pages(rx_bi->page, 0);
 
 		rx_bi->page = NULL;
@@ -642,7 +654,10 @@ static bool i40e_alloc_mapped_page(struct i40e_ring *rx_ring,
 	}
 
 	/* map page for use */
-	dma = dma_map_page(rx_ring->dev, page, 0, PAGE_SIZE, DMA_FROM_DEVICE);
+	dma = dma_map_page_attrs(rx_ring->dev, page, 0,
+				 PAGE_SIZE,
+				 DMA_FROM_DEVICE,
+				 I40E_RX_DMA_ATTR);
 
 	/* if mapping failed free memory back to system since
 	 * there isn't much point in holding memory we can't use
@@ -702,6 +717,12 @@ bool i40evf_alloc_rx_buffers(struct i40e_ring *rx_ring, u16 cleaned_count)
 		if (!i40e_alloc_mapped_page(rx_ring, bi))
 			goto no_buffers;
 
+		/* sync the buffer for use by the device */
+		dma_sync_single_range_for_device(rx_ring->dev, bi->dma,
+						 bi->page_offset,
+						 I40E_RXBUFFER_2048,
+						 DMA_FROM_DEVICE);
+
 		/* Refresh the desc even if buffer_addrs didn't change
 		 * because each write-back erases this info.
 		 */
@@ -1158,8 +1179,8 @@ struct sk_buff *i40evf_fetch_rx_buffer(struct i40e_ring *rx_ring,
 		rx_ring->rx_stats.page_reuse_count++;
 	} else {
 		/* we are not reusing the buffer so unmap it */
-		dma_unmap_page(rx_ring->dev, rx_buffer->dma, PAGE_SIZE,
-			       DMA_FROM_DEVICE);
+		dma_unmap_page_attrs(rx_ring->dev, rx_buffer->dma, PAGE_SIZE,
+				     DMA_FROM_DEVICE, I40E_RX_DMA_ATTR);
 	}
 
 	/* clear contents of buffer_info */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
index 8274ba68bd32..013512124e6a 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.h
@@ -120,6 +120,9 @@ enum i40e_dyn_idx_t {
 #define I40E_RX_HDR_SIZE I40E_RXBUFFER_256
 #define i40e_rx_desc i40e_32byte_rx_desc
 
+#define I40E_RX_DMA_ATTR \
+	(DMA_ATTR_SKIP_CPU_SYNC | DMA_ATTR_WEAK_ORDERING)
+
 /**
  * i40e_test_staterr - tests bits in Rx descriptor status and error fields
  * @rx_desc: pointer to receive descriptor (in le64 format)
-- 
2.12.0
