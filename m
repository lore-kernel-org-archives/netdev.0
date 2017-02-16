From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] ixgbe: Make use of order 1 pages and 3K buffers independent of FCoE
Date: Thu, 16 Feb 2017 04:50:35 -0800
Message-ID: <20170216125041.46668-9-jeffrey.t.kirsher@intel.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:18210 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754648AbdBPMur (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:47 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

In order to support build_skb with jumbo frames it will be necessary to use
3K buffers for the Rx path with 8K pages backing them.  This is needed on
architectures that implement 4K pages because we can't support 2K buffers
plus padding in a 4K page.

In the case of systems that support page sizes larger than 4K the 3K
attribute will only be applied to FCoE as we can fall back to using just 2K
buffers and adding the padding.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 20 +++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 19 +++++++++++++------
 2 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index d765db6bd8b2..f3515ce8894d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -226,13 +226,14 @@ struct ixgbe_rx_queue_stats {
 #define IXGBE_TS_HDR_LEN 8
 
 enum ixgbe_ring_state_t {
+	__IXGBE_RX_3K_BUFFER,
+	__IXGBE_RX_RSC_ENABLED,
+	__IXGBE_RX_CSUM_UDP_ZERO_ERR,
+	__IXGBE_RX_FCOE,
 	__IXGBE_TX_FDIR_INIT_DONE,
 	__IXGBE_TX_XPS_INIT_DONE,
 	__IXGBE_TX_DETECT_HANG,
 	__IXGBE_HANG_CHECK_ARMED,
-	__IXGBE_RX_RSC_ENABLED,
-	__IXGBE_RX_CSUM_UDP_ZERO_ERR,
-	__IXGBE_RX_FCOE,
 };
 
 struct ixgbe_fwd_adapter {
@@ -344,19 +345,16 @@ struct ixgbe_ring_feature {
  */
 static inline unsigned int ixgbe_rx_bufsz(struct ixgbe_ring *ring)
 {
-#ifdef IXGBE_FCOE
-	if (test_bit(__IXGBE_RX_FCOE, &ring->state))
-		return (PAGE_SIZE < 8192) ? IXGBE_RXBUFFER_4K :
-					    IXGBE_RXBUFFER_3K;
-#endif
+	if (test_bit(__IXGBE_RX_3K_BUFFER, &ring->state))
+		return IXGBE_RXBUFFER_3K;
 	return IXGBE_RXBUFFER_2K;
 }
 
 static inline unsigned int ixgbe_rx_pg_order(struct ixgbe_ring *ring)
 {
-#ifdef IXGBE_FCOE
-	if (test_bit(__IXGBE_RX_FCOE, &ring->state))
-		return (PAGE_SIZE < 8192) ? 1 : 0;
+#if (PAGE_SIZE < 8192)
+	if (test_bit(__IXGBE_RX_3K_BUFFER, &ring->state))
+		return 1;
 #endif
 	return 0;
 }
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e4487109292a..415e5ad1485a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1604,6 +1604,7 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
 	u16 i = rx_ring->next_to_use;
+	u16 bufsz;
 
 	/* nothing to do */
 	if (!cleaned_count)
@@ -1613,14 +1614,15 @@ void ixgbe_alloc_rx_buffers(struct ixgbe_ring *rx_ring, u16 cleaned_count)
 	bi = &rx_ring->rx_buffer_info[i];
 	i -= rx_ring->count;
 
+	bufsz = ixgbe_rx_bufsz(rx_ring);
+
 	do {
 		if (!ixgbe_alloc_mapped_page(rx_ring, bi))
 			break;
 
 		/* sync the buffer for use by the device */
 		dma_sync_single_range_for_device(rx_ring->dev, bi->dma,
-						 bi->page_offset,
-						 ixgbe_rx_bufsz(rx_ring),
+						 bi->page_offset, bufsz,
 						 DMA_FROM_DEVICE);
 
 		/*
@@ -2000,9 +2002,9 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 	struct page *page = rx_buffer->page;
 	unsigned char *va = page_address(page) + rx_buffer->page_offset;
 #if (PAGE_SIZE < 8192)
-	unsigned int truesize = ixgbe_rx_bufsz(rx_ring);
+	unsigned int truesize = ixgbe_rx_pg_size(rx_ring) / 2;
 #else
-	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
+	unsigned int truesize = SKB_DATA_ALIGN(size);
 #endif
 
 	if (unlikely(skb_is_nonlinear(skb)))
@@ -3866,10 +3868,15 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 	 */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		rx_ring = adapter->rx_ring[i];
+
+		clear_ring_rsc_enabled(rx_ring);
+		clear_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state);
+
 		if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
 			set_ring_rsc_enabled(rx_ring);
-		else
-			clear_ring_rsc_enabled(rx_ring);
+
+		if (test_bit(__IXGBE_RX_FCOE, &rx_ring->state))
+			set_bit(__IXGBE_RX_3K_BUFFER, &rx_ring->state);
 	}
 }
 
-- 
2.11.0
