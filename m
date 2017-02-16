From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] ixgbe: Only DMA sync frame length
Date: Thu, 16 Feb 2017 04:50:32 -0800
Message-ID: <20170216125041.46668-6-jeffrey.t.kirsher@intel.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:18210 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754505AbdBPMuq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:46 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

On some platforms, syncing a buffer for DMA is expensive. Rather than
sync the whole 2K receive buffer, only synchronise the length of the
frame, which will typically be the MTU, or a much smaller TCP ACK.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a19dda5711ae..dde2c852e01d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1841,7 +1841,7 @@ static void ixgbe_dma_sync_frag(struct ixgbe_ring *rx_ring,
 		dma_sync_single_range_for_cpu(rx_ring->dev,
 					      IXGBE_CB(skb)->dma,
 					      frag->page_offset,
-					      ixgbe_rx_bufsz(rx_ring),
+					      skb_frag_size(frag),
 					      DMA_FROM_DEVICE);
 	}
 	IXGBE_CB(skb)->dma = 0;
@@ -1983,12 +1983,11 @@ static bool ixgbe_can_reuse_rx_page(struct ixgbe_ring *rx_ring,
  **/
 static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 			      struct ixgbe_rx_buffer *rx_buffer,
-			      union ixgbe_adv_rx_desc *rx_desc,
+			      unsigned int size,
 			      struct sk_buff *skb)
 {
 	struct page *page = rx_buffer->page;
 	unsigned char *va = page_address(page) + rx_buffer->page_offset;
-	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = ixgbe_rx_bufsz(rx_ring);
 #else
@@ -2020,6 +2019,7 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
 					     union ixgbe_adv_rx_desc *rx_desc)
 {
+	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
 	struct ixgbe_rx_buffer *rx_buffer;
 	struct sk_buff *skb;
 	struct page *page;
@@ -2074,14 +2074,14 @@ static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
 		dma_sync_single_range_for_cpu(rx_ring->dev,
 					      rx_buffer->dma,
 					      rx_buffer->page_offset,
-					      ixgbe_rx_bufsz(rx_ring),
+					      size,
 					      DMA_FROM_DEVICE);
 
 		rx_buffer->skb = NULL;
 	}
 
 	/* pull page into skb */
-	if (ixgbe_add_rx_frag(rx_ring, rx_buffer, rx_desc, skb)) {
+	if (ixgbe_add_rx_frag(rx_ring, rx_buffer, size, skb)) {
 		/* hand second half of page back to the ring */
 		ixgbe_reuse_rx_page(rx_ring, rx_buffer);
 	} else if (IXGBE_CB(skb)->dma == rx_buffer->dma) {
-- 
2.11.0
