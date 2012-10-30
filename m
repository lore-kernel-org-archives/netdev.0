From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] ixgbe: Do not decrement budget in ixgbe_clean_rx_irq
Date: Tue, 30 Oct 2012 00:04:23 -0700
Message-ID: <1351580670-8292-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:5842 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755240Ab2J3HEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2012 03:04:36 -0400
In-Reply-To: <1351580670-8292-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that compare the total_rx_packets cleaned to budget
instead of decrementing budget.  The advantage to this approach is that budget
can now be const and we only end up modifying total_rx_packets instead of
modifying both it and budget.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ceab142..a34ee7d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1794,7 +1794,7 @@ dma_sync:
  **/
 static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			       struct ixgbe_ring *rx_ring,
-			       int budget)
+			       const int budget)
 {
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 #ifdef IXGBE_FCOE
@@ -1845,7 +1845,6 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 
 		/* probably a little skewed due to removing CRC */
 		total_rx_bytes += skb->len;
-		total_rx_packets++;
 
 		/* populate checksum, timestamp, VLAN, and protocol */
 		ixgbe_process_skb_fields(rx_ring, rx_desc, skb);
@@ -1878,8 +1877,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		ixgbe_rx_skb(q_vector, skb);
 
 		/* update budget accounting */
-		budget--;
-	} while (likely(budget));
+		total_rx_packets++;
+	} while (likely(total_rx_packets < budget));
 
 	u64_stats_update_begin(&rx_ring->syncp);
 	rx_ring->stats.packets += total_rx_packets;
@@ -1891,7 +1890,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	if (cleaned_count)
 		ixgbe_alloc_rx_buffers(rx_ring, cleaned_count);
 
-	return !!budget;
+	return (total_rx_packets < budget);
 }
 
 /**
-- 
1.7.11.7
