From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] igb: move TX hang check flag into ring->flags
Date: Tue, 11 Oct 2011 08:45:51 -0700
Message-ID: <1318347952-25068-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29971 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754952Ab1JKPp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 11:45:59 -0400
In-Reply-To: <1318347952-25068-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change moves the Tx hang check into the ring flags.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |    1 -
 drivers/net/ethernet/intel/igb/igb_main.c |    6 +++---
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 04dd6d7..5def94c 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -230,7 +230,6 @@ struct igb_ring {
 			struct igb_tx_queue_stats tx_stats;
 			struct u64_stats_sync tx_syncp;
 			struct u64_stats_sync tx_syncp2;
-			bool detect_tx_hung;
 		};
 		/* RX */
 		struct {
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 689c2c2..c4c3acf 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3684,7 +3684,7 @@ static void igb_watchdog_task(struct work_struct *work)
 		}
 
 		/* Force detection of hung controller every watchdog period */
-		tx_ring->detect_tx_hung = true;
+		set_bit(IGB_RING_FLAG_TX_DETECT_HANG, &tx_ring->flags);
 	}
 
 	/* Cause software interrupt to ensure rx ring is cleaned */
@@ -5651,14 +5651,14 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 	q_vector->tx.total_bytes += total_bytes;
 	q_vector->tx.total_packets += total_packets;
 
-	if (tx_ring->detect_tx_hung) {
+	if (test_bit(IGB_RING_FLAG_TX_DETECT_HANG, &tx_ring->flags)) {
 		struct e1000_hw *hw = &adapter->hw;
 
 		eop_desc = tx_buffer->next_to_watch;
 
 		/* Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
-		tx_ring->detect_tx_hung = false;
+		clear_bit(IGB_RING_FLAG_TX_DETECT_HANG, &tx_ring->flags);
 		if (eop_desc &&
 		    time_after(jiffies, tx_buffer->time_stamp +
 			       (adapter->tx_timeout_factor * HZ)) &&
-- 
1.7.6.4
