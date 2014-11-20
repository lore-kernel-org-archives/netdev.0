From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/15] ixgbevf: Cleanup variable usage, improve stack performance
Date: Thu, 20 Nov 2014 15:09:02 -0800
Message-ID: <1416524953-15161-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:43162 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756745AbaKTXJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2014 18:09:20 -0500
In-Reply-To: <1416524953-15161-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This change is meant to help cleanup the usage of temporary variables
within the Rx hot-path by removing unnecessary variables and reducing
the scope of variables that do not need to exist outside the main loop.

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 36b005e..f864da9 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -517,26 +517,28 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 				struct ixgbevf_ring *rx_ring,
 				int budget)
 {
-	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
-	struct ixgbevf_rx_buffer *rx_buffer_info, *next_buffer;
-	struct sk_buff *skb;
+	union ixgbe_adv_rx_desc *rx_desc;
 	unsigned int i;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 	u16 cleaned_count = ixgbevf_desc_unused(rx_ring);
 
 	i = rx_ring->next_to_clean;
 	rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
-	rx_buffer_info = &rx_ring->rx_buffer_info[i];
 
 	while (ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_DD)) {
+		union ixgbe_adv_rx_desc *next_rxd;
+		struct ixgbevf_rx_buffer *rx_buffer_info;
+		struct sk_buff *skb;
+
 		if (!budget)
 			break;
 		budget--;
 
 		rmb(); /* read descriptor and rx_buffer_info after status DD */
 
+		rx_buffer_info = &rx_ring->rx_buffer_info[i];
 		skb = rx_buffer_info->skb;
-		prefetch(skb->data - NET_IP_ALIGN);
+		prefetch(skb->data);
 		rx_buffer_info->skb = NULL;
 
 		dma_unmap_single(rx_ring->dev, rx_buffer_info->dma,
@@ -545,18 +547,17 @@ static int ixgbevf_clean_rx_irq(struct ixgbevf_q_vector *q_vector,
 		rx_buffer_info->dma = 0;
 		skb_put(skb, le16_to_cpu(rx_desc->wb.upper.length));
 
+		cleaned_count++;
+
 		i++;
 		if (i == rx_ring->count)
 			i = 0;
 
 		next_rxd = IXGBEVF_RX_DESC(rx_ring, i);
 		prefetch(next_rxd);
-		cleaned_count++;
-
-		next_buffer = &rx_ring->rx_buffer_info[i];
 
 		if (!(ixgbevf_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP))) {
-			skb->next = next_buffer->skb;
+			skb->next = rx_ring->rx_buffer_info[i].skb;
 			IXGBE_CB(skb->next)->prev = skb;
 			rx_ring->rx_stats.non_eop_descs++;
 			goto next_desc;
@@ -609,6 +610,7 @@ next_desc:
 		/* use prefetched values */
 		rx_desc = next_rxd;
 		rx_buffer_info = &rx_ring->rx_buffer_info[i];
+		rx_desc = IXGBEVF_RX_DESC(rx_ring, i);
 	}
 
 	rx_ring->next_to_clean = i;
-- 
1.9.3
