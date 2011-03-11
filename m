From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 03/11] ixgbevf: remove Tx hang detection
Date: Fri, 11 Mar 2011 03:06:22 -0800
Message-ID: <1299841590-30676-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Lior Levy <lior.levy@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59823 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754490Ab1CKLGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 06:06:48 -0500
In-Reply-To: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lior Levy <lior.levy@intel.com>

Removed Tx hang detection mechanism from ixgbevf.
This mechanism has no affect and can cause false alarm messages in some
cases. Especially when VF Tx rate limit is turned on.

The same mechanism was removed recently from igbvf.

Signed-off-by: Lior Levy <lior.levy@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbevf/ixgbevf.h      |    1 -
 drivers/net/ixgbevf/ixgbevf_main.c |   50 ------------------------------------
 2 files changed, 0 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf.h b/drivers/net/ixgbevf/ixgbevf.h
index a63efcb..b703f60 100644
--- a/drivers/net/ixgbevf/ixgbevf.h
+++ b/drivers/net/ixgbevf/ixgbevf.h
@@ -207,7 +207,6 @@ struct ixgbevf_adapter {
 	u64 hw_tso_ctxt;
 	u64 hw_tso6_ctxt;
 	u32 tx_timeout_count;
-	bool detect_tx_hung;
 
 	/* RX */
 	struct ixgbevf_ring *rx_ring;	/* One per active queue */
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 8276881..c1fb2c1 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -162,40 +162,6 @@ static void ixgbevf_unmap_and_free_tx_resource(struct ixgbevf_adapter *adapter,
 	/* tx_buffer_info must be completely set up in the transmit path */
 }
 
-static inline bool ixgbevf_check_tx_hang(struct ixgbevf_adapter *adapter,
-					 struct ixgbevf_ring *tx_ring,
-					 unsigned int eop)
-{
-	struct ixgbe_hw *hw = &adapter->hw;
-	u32 head, tail;
-
-	/* Detect a transmit hang in hardware, this serializes the
-	 * check with the clearing of time_stamp and movement of eop */
-	head = readl(hw->hw_addr + tx_ring->head);
-	tail = readl(hw->hw_addr + tx_ring->tail);
-	adapter->detect_tx_hung = false;
-	if ((head != tail) &&
-	    tx_ring->tx_buffer_info[eop].time_stamp &&
-	    time_after(jiffies, tx_ring->tx_buffer_info[eop].time_stamp + HZ)) {
-		/* detected Tx unit hang */
-		printk(KERN_ERR "Detected Tx Unit Hang\n"
-		       "  Tx Queue             <%d>\n"
-		       "  TDH, TDT             <%x>, <%x>\n"
-		       "  next_to_use          <%x>\n"
-		       "  next_to_clean        <%x>\n"
-		       "tx_buffer_info[next_to_clean]\n"
-		       "  time_stamp           <%lx>\n"
-		       "  jiffies              <%lx>\n",
-		       tx_ring->queue_index,
-		       head, tail,
-		       tx_ring->next_to_use, eop,
-		       tx_ring->tx_buffer_info[eop].time_stamp, jiffies);
-		return true;
-	}
-
-	return false;
-}
-
 #define IXGBE_MAX_TXD_PWR	14
 #define IXGBE_MAX_DATA_PER_TXD	(1 << IXGBE_MAX_TXD_PWR)
 
@@ -291,16 +257,6 @@ static bool ixgbevf_clean_tx_irq(struct ixgbevf_adapter *adapter,
 #endif
 	}
 
-	if (adapter->detect_tx_hung) {
-		if (ixgbevf_check_tx_hang(adapter, tx_ring, i)) {
-			/* schedule immediate reset if we believe we hung */
-			printk(KERN_INFO
-			       "tx hang %d detected, resetting adapter\n",
-			       adapter->tx_timeout_count + 1);
-			ixgbevf_tx_timeout(adapter->netdev);
-		}
-	}
-
 	/* re-arm the interrupt */
 	if ((count >= tx_ring->work_limit) &&
 	    (!test_bit(__IXGBEVF_DOWN, &adapter->state))) {
@@ -2412,9 +2368,6 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 			       10 : 1);
 			netif_carrier_on(netdev);
 			netif_tx_wake_all_queues(netdev);
-		} else {
-			/* Force detection of hung controller */
-			adapter->detect_tx_hung = true;
 		}
 	} else {
 		adapter->link_up = false;
@@ -2429,9 +2382,6 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 	ixgbevf_update_stats(adapter);
 
 pf_has_reset:
-	/* Force detection of hung controller every watchdog period */
-	adapter->detect_tx_hung = true;
-
 	/* Reset the timer */
 	if (!test_bit(__IXGBEVF_DOWN, &adapter->state))
 		mod_timer(&adapter->watchdog_timer,
-- 
1.7.4

