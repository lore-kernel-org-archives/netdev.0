From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [next PATCH 02/11] ixgbe: Only DMA sync frame length
Date: Fri, 06 Jan 2017 08:06:41 -0800
Message-ID: <20170106160639.1501.21842.stgit@localhost.localdomain>
References: <20170106155448.1501.31298.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33566 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966855AbdAFQGm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 11:06:42 -0500
Received: by mail-pg0-f65.google.com with SMTP id g1so44418556pgn.0
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 08:06:42 -0800 (PST)
In-Reply-To: <20170106155448.1501.31298.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

On some platforms, syncing a buffer for DMA is expensive. Rather than
sync the whole 2K receive buffer, only synchronise the length of the
frame, which will typically be the MTU, or a much smaller TCP ACK.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e80d885af4d3..dbbf5223ace2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1858,7 +1858,7 @@ static void ixgbe_dma_sync_frag(struct ixgbe_ring *rx_ring,
 		dma_sync_single_range_for_cpu(rx_ring->dev,
 					      IXGBE_CB(skb)->dma,
 					      frag->page_offset,
-					      ixgbe_rx_bufsz(rx_ring),
+					      skb_frag_size(frag),
 					      DMA_FROM_DEVICE);
 	}
 	IXGBE_CB(skb)->dma = 0;
@@ -1999,12 +1999,11 @@ static bool ixgbe_can_reuse_rx_page(struct ixgbe_rx_buffer *rx_buffer,
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
@@ -2036,6 +2035,7 @@ static bool ixgbe_add_rx_frag(struct ixgbe_ring *rx_ring,
 static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
 					     union ixgbe_adv_rx_desc *rx_desc)
 {
+	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
 	struct ixgbe_rx_buffer *rx_buffer;
 	struct sk_buff *skb;
 	struct page *page;
@@ -2090,14 +2090,14 @@ static struct sk_buff *ixgbe_fetch_rx_buffer(struct ixgbe_ring *rx_ring,
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
