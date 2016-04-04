From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] ixgbevf: use bit operations for setting and checking resets
Date: Mon,  4 Apr 2016 15:14:45 -0700
Message-ID: <1459808097-26409-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459808097-26409-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:51308 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754070AbcDDWPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2016 18:15:03 -0400
In-Reply-To: <1459808097-26409-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Move the reset flags to adapter->state in order to make use of bit
operations.

This is an alternative patch to the one previously submitted by
John Greene.

Suggested-by: Alexander Duyck <aduyck@mirantis.com>
Reported-by: Scott Otto <otts62@yahoo.com>
Reported-by: John Greene <jogreene@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  9 ++-------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 15 ++++++---------
 2 files changed, 8 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 991eeae..5ac60ee 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -403,13 +403,6 @@ struct ixgbevf_adapter {
 	u32 alloc_rx_page_failed;
 	u32 alloc_rx_buff_failed;
 
-	/* Some features need tri-state capability,
-	 * thus the additional *_CAPABLE flags.
-	 */
-	u32 flags;
-#define IXGBEVF_FLAG_RESET_REQUESTED		(u32)(1)
-#define IXGBEVF_FLAG_QUEUE_RESET_REQUESTED	(u32)(1 << 2)
-
 	struct msix_entry *msix_entries;
 
 	/* OS defined structs */
@@ -461,6 +454,8 @@ enum ixbgevf_state_t {
 	__IXGBEVF_REMOVING,
 	__IXGBEVF_SERVICE_SCHED,
 	__IXGBEVF_SERVICE_INITED,
+	__IXGBEVF_RESET_REQUESTED,
+	__IXGBEVF_QUEUE_RESET_REQUESTED,
 };
 
 enum ixgbevf_boards {
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index b0edae9..9a2eed0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -268,7 +268,7 @@ static void ixgbevf_tx_timeout_reset(struct ixgbevf_adapter *adapter)
 {
 	/* Do the reset outside of interrupt context */
 	if (!test_bit(__IXGBEVF_DOWN, &adapter->state)) {
-		adapter->flags |= IXGBEVF_FLAG_RESET_REQUESTED;
+		set_bit(__IXGBEVF_RESET_REQUESTED, &adapter->state);
 		ixgbevf_service_event_schedule(adapter);
 	}
 }
@@ -1984,7 +1984,7 @@ static int ixgbevf_configure_dcb(struct ixgbevf_adapter *adapter)
 		hw->mbx.timeout = 0;
 
 		/* wait for watchdog to come around and bail us out */
-		adapter->flags |= IXGBEVF_FLAG_QUEUE_RESET_REQUESTED;
+		set_bit(__IXGBEVF_QUEUE_RESET_REQUESTED, &adapter->state);
 	}
 
 	return 0;
@@ -2749,11 +2749,9 @@ static void ixgbevf_service_timer(unsigned long data)
 
 static void ixgbevf_reset_subtask(struct ixgbevf_adapter *adapter)
 {
-	if (!(adapter->flags & IXGBEVF_FLAG_RESET_REQUESTED))
+	if (!test_and_clear_bit(__IXGBEVF_RESET_REQUESTED, &adapter->state))
 		return;
 
-	adapter->flags &= ~IXGBEVF_FLAG_RESET_REQUESTED;
-
 	/* If we're already down or resetting, just bail */
 	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
 	    test_bit(__IXGBEVF_RESETTING, &adapter->state))
@@ -2821,7 +2819,7 @@ static void ixgbevf_watchdog_update_link(struct ixgbevf_adapter *adapter)
 
 	/* if check for link returns error we will need to reset */
 	if (err && time_after(jiffies, adapter->last_reset + (10 * HZ))) {
-		adapter->flags |= IXGBEVF_FLAG_RESET_REQUESTED;
+		set_bit(__IXGBEVF_RESET_REQUESTED, &adapter->state);
 		link_up = false;
 	}
 
@@ -3222,11 +3220,10 @@ static void ixgbevf_queue_reset_subtask(struct ixgbevf_adapter *adapter)
 {
 	struct net_device *dev = adapter->netdev;
 
-	if (!(adapter->flags & IXGBEVF_FLAG_QUEUE_RESET_REQUESTED))
+	if (!test_and_clear_bit(__IXGBEVF_QUEUE_RESET_REQUESTED,
+				&adapter->state))
 		return;
 
-	adapter->flags &= ~IXGBEVF_FLAG_QUEUE_RESET_REQUESTED;
-
 	/* if interface is down do nothing */
 	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
 	    test_bit(__IXGBEVF_RESETTING, &adapter->state))
-- 
2.5.5
