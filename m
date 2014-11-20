From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 05/15] ixgbevf: reorder main loop in ixgbe_clean_rx_irq to allow for do/while/continue
Date: Thu, 20 Nov 2014 15:09:03 -0800
Message-ID: <1416524953-15161-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55349 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757591AbaKTXJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 18:09:20 -0500
In-Reply-To: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This change allows us to go from a loop based on the descriptor to one
primarily based on the budget. The advantage to this is that we can avoid
carrying too many values from one iteration to the next.

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 64 ++++++++++++-----------
 1 file changed, 34 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index f864da9..2206992 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -517,35 +517,48 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 				struct ixgbevf_ring *rx_ring,
 				int budget)
 {
-	union ixgbe_adv_rx_desc *rx_desc;
 	unsigned int i;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	u16 cleaned_count = ixgbevf_desc_unused(rx_ring);
 
 	i = rx_ring->next_to_clean;
-	rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
 
-	while (ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_DD)) {
-		union ixgbe_adv_rx_desc *next_rxd;
-		struct ixgbevf_rx_buffer *rx_buffer_info;
+	do {
+		union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
+		struct ixgbevf_rx_buffer *rx_buffer;
 		struct sk_buff *skb;
 
-		if (!budget)
+		/* return some buffers to hardware, one at a time is too slow */
+		if (cleaned_count >= IXGBEVF_RX_BUFFER_WRITE) {
+			ixgbevf_alloc_rx_buffers(rx_ring, cleaned_count);
+			cleaned_count = 0;
+		}
+
+		rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
+		rx_buffer = &rx_ring->rx_buffer_info[i];
+
+		if (!ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_DD))
 			break;
-		budget--;
 
-		rmb(); /* read descriptor and rx_buffer_info after status DD */
+		/* This memory barrier is needed to keep us from reading
+		 * any other fields out of the rx_desc until we know the
+		 * RXD_STAT_DD bit is set
+		 */
+		rmb();
 
-		rx_buffer_info = &rx_ring->rx_buffer_info[i];
-		skb = rx_buffer_info->skb;
+		skb = rx_buffer->skb;
 		prefetch(skb->data);
-		rx_buffer_info->skb = NULL;
 
-		dma_unmap_single(rx_ring->dev, rx_buffer_info->dma,
+		/* pull the header of the skb in */
+		__skb_put(skb, le16_to_cpu(rx_desc->wb.upper.length));
+
+		dma_unmap_single(rx_ring->dev, rx_buffer->dma,
 				 rx_ring->rx_buf_len,
 				 DMA_FROM_DEVICE);
-		rx_buffer_info->dma = 0;
-		skb_put(skb, le16_to_cpu(rx_desc->wb.upper.length));
+
+		/* clear skb reference in buffer info structure */
+		rx_buffer->skb = NULL;
+		rx_buffer->dma = 0;
 
 		cleaned_count++;
 
@@ -560,7 +573,7 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 			skb->next = rx_ring->rx_buffer_info[i].skb;
 			IXGBE_CB(skb->next)->prev = skb;
 			rx_ring->rx_stats.non_eop_descs++;
-			goto next_desc;
+			continue;
 		}
 
 		/* we should not be chaining buffers, if we did drop the skb */
@@ -570,14 +583,14 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 				skb = IXGBE_CB(skb)->prev;
 				dev_kfree_skb(this);
 			} while (skb);
-			goto next_desc;
+			continue;
 		}
 
 		/* ERR_MASK will only have valid bits if EOP set */
 		if (unlikely(ixgbevf_test_staterr(rx_desc,
 					    IXGBE_RXDADV_ERR_FRAME_ERR_MASK))) {
 			dev_kfree_skb_irq(skb);
-			goto next_desc;
+			continue;
 		}
 
 		/* probably a little skewed due to removing CRC */
@@ -592,7 +605,7 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		    ether_addr_equal(rx_ring->netdev->dev_addr,
 				     eth_hdr(skb)->h_source)) {
 			dev_kfree_skb_irq(skb);
-			goto next_desc;
+			continue;
 		}
 
 		/* populate checksum, VLAN, and protocol */
@@ -600,18 +613,9 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 
 		ixgbevf_rx_skb(q_vector, skb);
 
-next_desc:
-		/* return some buffers to hardware, one at a time is too slow */
-		if (cleaned_count >= IXGBEVF_RX_BUFFER_WRITE) {
-			ixgbevf_alloc_rx_buffers(rx_ring, cleaned_count);
-			cleaned_count = 0;
-		}
-
-		/* use prefetched values */
-		rx_desc = next_rxd;
-		rx_buffer_info = &rx_ring->rx_buffer_info[i];
-		rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
-	}
+		/* update budget accounting */
+		budget--;
+	} while (likely(budget));
 
 	rx_ring->next_to_clean = i;
 	u64_stats_update_begin(&rx_ring->syncp);
-- 
1.9.3
