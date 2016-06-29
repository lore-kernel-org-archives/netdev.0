From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] igb: Only DMA sync frame length
Date: Wed, 29 Jun 2016 14:33:02 -0700
Message-ID: <1467235982-55437-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3817 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751793AbcF2VdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 17:33:09 -0400
In-Reply-To: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>

On some platforms, syncing a buffer for DMA is expensive. Rather than
sync the whole 2K receive buffer, only synchronise the length of the
frame, which will typically be the MTU, or a much smaller TCP ACK.

For an IMX6Q, this gives around 6% increased TCP receive performance,
which is cache operations bound and reduces CPU load for TCP transmit.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a15f826..9bcba42 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -6856,12 +6856,12 @@ static bool igb_can_reuse_rx_page(struct igb_rx_buffer *rx_buffer,
  **/
 static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 			    struct igb_rx_buffer *rx_buffer,
+			    unsigned int size,
 			    union e1000_adv_rx_desc *rx_desc,
 			    struct sk_buff *skb)
 {
 	struct page *page = rx_buffer->page;
 	unsigned char *va = page_address(page) + rx_buffer->page_offset;
-	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = IGB_RX_BUFSZ;
 #else
@@ -6913,6 +6913,7 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 					   union e1000_adv_rx_desc *rx_desc,
 					   struct sk_buff *skb)
 {
+	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
 	struct igb_rx_buffer *rx_buffer;
 	struct page *page;
 
@@ -6948,11 +6949,11 @@ static struct sk_buff *igb_fetch_rx_buffer(struct igb_ring *rx_ring,
 	dma_sync_single_range_for_cpu(rx_ring->dev,
 				      rx_buffer->dma,
 				      rx_buffer->page_offset,
-				      IGB_RX_BUFSZ,
+				      size,
 				      DMA_FROM_DEVICE);
 
 	/* pull page into skb */
-	if (igb_add_rx_frag(rx_ring, rx_buffer, rx_desc, skb)) {
+	if (igb_add_rx_frag(rx_ring, rx_buffer, size, rx_desc, skb)) {
 		/* hand second half of page back to the ring */
 		igb_reuse_rx_page(rx_ring, rx_buffer);
 	} else {
-- 
2.5.5
