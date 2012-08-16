From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net-next 4/9] ixgbe: Have the CPU take ownership of the buffers sooner
Date: Thu, 16 Aug 2012 15:48:33 -0700
Message-ID: <1345157318-23731-5-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53764 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755762Ab2HPWsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 18:48:51 -0400
In-Reply-To: <1345157318-23731-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch makes it so that we will always have ownership of the buffers by
the time we get to ixgbe_add_rx_frag. This is necessary as I am planning to
add a copy-break to ixgbe_add_rx_frag and in order for that to function
correctly we need the CPU to have ownership of the buffer.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 52 +++++++++++++++++++--------
 1 file changed, 38 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9305e9a..b0020fc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1458,6 +1458,36 @@ static bool ixgbe_is_non_eop(struct ixgbe_ring *rx_ring,
 }
 
 /**
+ * ixgbe_dma_sync_frag - perform DMA sync for first frag of SKB
+ * @rx_ring: rx descriptor ring packet is being transacted on
+ * @skb: pointer to current skb being updated
+ *
+ * This function provides a basic DMA sync up for the first fragment of an
+ * skb.  The reason for doing this is that the first fragment cannot be
+ * unmapped until we have reached the end of packet descriptor for a buffer
+ * chain.
+ */
+static void ixgbe_dma_sync_frag(struct ixgbe_ring *rx_ring,
+				struct sk_buff *skb)
+{
+	/* if the page was released unmap it, else just sync our portion */
+	if (unlikely(IXGBE_CB(skb)->page_released)) {
+		dma_unmap_page(rx_ring->dev, IXGBE_CB(skb)->dma,
+			       ixgbe_rx_pg_size(rx_ring), DMA_FROM_DEVICE);
+		IXGBE_CB(skb)->page_released = false;
+	} else {
+		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
+
+		dma_sync_single_range_for_cpu(rx_ring->dev,
+					      IXGBE_CB(skb)->dma,
+					      frag->page_offset,
+					      ixgbe_rx_bufsz(rx_ring),
+					      DMA_FROM_DEVICE);
+	}
+	IXGBE_CB(skb)->dma = 0;
+}
+
+/**
  * ixgbe_cleanup_headers - Correct corrupted or empty headers
  * @rx_ring: rx descriptor ring packet is being transacted on
  * @rx_desc: pointer to the EOP Rx descriptor
@@ -1484,20 +1514,6 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
 	unsigned char *va;
 	unsigned int pull_len;
 
-	/* if the page was released unmap it, else just sync our portion */
-	if (unlikely(IXGBE_CB(skb)->page_released)) {
-		dma_unmap_page(rx_ring->dev, IXGBE_CB(skb)->dma,
-			       ixgbe_rx_pg_size(rx_ring), DMA_FROM_DEVICE);
-		IXGBE_CB(skb)->page_released = false;
-	} else {
-		dma_sync_single_range_for_cpu(rx_ring->dev,
-					      IXGBE_CB(skb)->dma,
-					      frag->page_offset,
-					      ixgbe_rx_bufsz(rx_ring),
-					      DMA_FROM_DEVICE);
-	}
-	IXGBE_CB(skb)->dma = 0;
-
 	/* verify that the packet does not have any known errors */
 	if (unlikely(ixgbe_test_staterr(rx_desc,
 					IXGBE_RXDADV_ERR_FRAME_ERR_MASK) &&
@@ -1742,8 +1758,16 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			 * after the writeback.  Only unmap it when EOP is
 			 * reached
 			 */
+			if (likely(ixgbe_test_staterr(rx_desc,
+						      IXGBE_RXD_STAT_EOP)))
+				goto dma_sync;
+
 			IXGBE_CB(skb)->dma = rx_buffer->dma;
 		} else {
+			if (ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP))
+				ixgbe_dma_sync_frag(rx_ring, skb);
+
+dma_sync:
 			/* we are reusing so sync this buffer for CPU use */
 			dma_sync_single_range_for_cpu(rx_ring->dev,
 						      rx_buffer->dma,
-- 
1.7.11.2
