From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/7] igb: Change Tx cleanup loop to do/while instead of for
Date: Sat, 22 Sep 2012 03:30:33 -0700
Message-ID: <1348309836-7107-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18439 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755258Ab2IVKbH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Sep 2012 06:31:07 -0400
In-Reply-To: <1348309836-7107-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that Tx cleanup is done in a do/while loop instead
of a for loop.  The main motivation behind this is the fact that we should
never be invoked with a budget less than 1 so we can skip checking the
budget before processing the first descriptor.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 28 ++++++++++++++++------------
 1 file changed, 16 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index c9997d8..91f542c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -5690,7 +5690,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 	struct igb_adapter *adapter = q_vector->adapter;
 	struct igb_ring *tx_ring = q_vector->tx.ring;
 	struct igb_tx_buffer *tx_buffer;
-	union e1000_adv_tx_desc *tx_desc, *eop_desc;
+	union e1000_adv_tx_desc *tx_desc;
 	unsigned int total_bytes = 0, total_packets = 0;
 	unsigned int budget = q_vector->tx.work_limit;
 	unsigned int i = tx_ring->next_to_clean;
@@ -5702,16 +5702,16 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 	tx_desc = IGB_TX_DESC(tx_ring, i);
 	i -= tx_ring->count;
 
-	for (; budget; budget--) {
-		eop_desc = tx_buffer->next_to_watch;
-
-		/* prevent any other reads prior to eop_desc */
-		rmb();
+	do {
+		union e1000_adv_tx_desc *eop_desc = tx_buffer->next_to_watch;
 
 		/* if next_to_watch is not set then there is no work pending */
 		if (!eop_desc)
 			break;
 
+		/* prevent any other reads prior to eop_desc */
+		rmb();
+
 		/* if DD is not set pending work has not been completed */
 		if (!(eop_desc->wb.status & cpu_to_le32(E1000_TXD_STAT_DD)))
 			break;
@@ -5767,7 +5767,13 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 			tx_buffer = tx_ring->tx_buffer_info;
 			tx_desc = IGB_TX_DESC(tx_ring, 0);
 		}
-	}
+
+		/* issue prefetch for next Tx descriptor */
+		prefetch(tx_desc);
+
+		/* update budget accounting */
+		budget--;
+	} while (likely(budget));
 
 	netdev_tx_completed_queue(txring_txq(tx_ring),
 				  total_packets, total_bytes);
@@ -5783,12 +5789,10 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 	if (test_bit(IGB_RING_FLAG_TX_DETECT_HANG, &tx_ring->flags)) {
 		struct e1000_hw *hw = &adapter->hw;
 
-		eop_desc = tx_buffer->next_to_watch;
-
 		/* Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		clear_bit(IGB_RING_FLAG_TX_DETECT_HANG, &tx_ring->flags);
-		if (eop_desc &&
+		if (tx_buffer->next_to_watch &&
 		    time_after(jiffies, tx_buffer->time_stamp +
 			       (adapter->tx_timeout_factor * HZ)) &&
 		    !(rd32(E1000_STATUS) & E1000_STATUS_TXOFF)) {
@@ -5812,9 +5816,9 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 				tx_ring->next_to_use,
 				tx_ring->next_to_clean,
 				tx_buffer->time_stamp,
-				eop_desc,
+				tx_buffer->next_to_watch,
 				jiffies,
-				eop_desc->wb.status);
+				tx_buffer->next_to_watch->wb.status);
 			netif_stop_subqueue(tx_ring->netdev,
 					    tx_ring->queue_index);
 
-- 
1.7.11.4
