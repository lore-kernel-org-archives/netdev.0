From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 08/13] ixgbe: merge reset task into service task
Date: Sat, 14 May 2011 18:23:42 -0700
Message-ID: <1305422627-9583-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1031 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759536Ab1EOBXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:53 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to further help to reduce possible configuration
collisions between the various tasklets.  This change combines the device
reset with the service task.  As a result it is now not possible to be
updating the link on the device while also resetting the part.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h      |    2 +-
 drivers/net/ixgbe/ixgbe_main.c |   60 ++++++++++++++++++++++++---------------
 2 files changed, 38 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 193c6c4..760b850 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -381,6 +381,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG2_TEMP_SENSOR_CAPABLE         (u32)(1 << 2)
 #define IXGBE_FLAG2_SEARCH_FOR_SFP              (u32)(1 << 4)
 #define IXGBE_FLAG2_SFP_NEEDS_RESET             (u32)(1 << 5)
+#define IXGBE_FLAG2_RESET_REQUESTED             (u32)(1 << 6)
 
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 bd_number;
@@ -454,7 +455,6 @@ struct ixgbe_adapter {
 	bool link_up;
 	unsigned long link_check_timeout;
 
-	struct work_struct reset_task;
 	struct work_struct fdir_reinit_task;
 	struct work_struct check_overtemp_task;
 	struct work_struct service_task;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d1e52b5..dbb20e5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -833,7 +833,19 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_ring *tx_ring)
 #define DESC_NEEDED (TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->data */ + \
 	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1) /* for context */
 
-static void ixgbe_tx_timeout(struct net_device *netdev);
+/**
+ * ixgbe_tx_timeout_reset - initiate reset due to Tx timeout
+ * @adapter: driver private struct
+ **/
+static void ixgbe_tx_timeout_reset(struct ixgbe_adapter *adapter)
+{
+
+	/* Do the reset outside of interrupt context */
+	if (!test_bit(__IXGBE_DOWN, &adapter->state)) {
+		adapter->flags2 |= IXGBE_FLAG2_RESET_REQUESTED;
+		ixgbe_service_event_schedule(adapter);
+	}
+}
 
 /**
  * ixgbe_clean_tx_irq - Reclaim resources after transmit completes
@@ -915,7 +927,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 			adapter->tx_timeout_count + 1, tx_ring->queue_index);
 
 		/* schedule immediate reset if we believe we hung */
-		ixgbe_tx_timeout(adapter->netdev);
+		ixgbe_tx_timeout_reset(adapter);
 
 		/* the adapter is about to reset, no point in enabling stuff */
 		return true;
@@ -4186,6 +4198,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	ixgbe_napi_disable_all(adapter);
 
+	adapter->flags2 &= ~IXGBE_FLAG2_RESET_REQUESTED;
 	adapter->flags &= ~IXGBE_FLAG_NEED_LINK_UPDATE;
 
 	del_timer_sync(&adapter->service_timer);
@@ -4288,25 +4301,8 @@ static void ixgbe_tx_timeout(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	adapter->tx_timeout_count++;
-
 	/* Do the reset outside of interrupt context */
-	schedule_work(&adapter->reset_task);
-}
-
-static void ixgbe_reset_task(struct work_struct *work)
-{
-	struct ixgbe_adapter *adapter;
-	adapter = container_of(work, struct ixgbe_adapter, reset_task);
-
-	/* If we're already down or resetting, just bail */
-	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
-	    test_bit(__IXGBE_RESETTING, &adapter->state))
-		return;
-
-	ixgbe_dump(adapter);
-	netdev_err(adapter->netdev, "Reset adapter\n");
-	ixgbe_reinit_locked(adapter);
+	ixgbe_tx_timeout_reset(adapter);
 }
 
 /**
@@ -6174,7 +6170,7 @@ static void ixgbe_watchdog_flush_tx(struct ixgbe_adapter *adapter)
 			 * to get done, so reset controller to flush Tx.
 			 * (Do the reset outside of interrupt context).
 			 */
-			schedule_work(&adapter->reset_task);
+			adapter->flags2 |= IXGBE_FLAG2_RESET_REQUESTED;
 		}
 	}
 }
@@ -6341,6 +6337,25 @@ static void ixgbe_service_timer(unsigned long data)
 	ixgbe_service_event_schedule(adapter);
 }
 
+static void ixgbe_reset_subtask(struct ixgbe_adapter *adapter)
+{
+	if (!(adapter->flags2 & IXGBE_FLAG2_RESET_REQUESTED))
+		return;
+
+	adapter->flags2 &= ~IXGBE_FLAG2_RESET_REQUESTED;
+
+	/* If we're already down or resetting, just bail */
+	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
+	    test_bit(__IXGBE_RESETTING, &adapter->state))
+		return;
+
+	ixgbe_dump(adapter);
+	netdev_err(adapter->netdev, "Reset adapter\n");
+	adapter->tx_timeout_count++;
+
+	ixgbe_reinit_locked(adapter);
+}
+
 /**
  * ixgbe_service_task - manages and runs subtasks
  * @work: pointer to work_struct containing our data
@@ -6351,6 +6366,7 @@ static void ixgbe_service_task(struct work_struct *work)
 						     struct ixgbe_adapter,
 						     service_task);
 
+	ixgbe_reset_subtask(adapter);
 	ixgbe_sfp_detection_subtask(adapter);
 	ixgbe_sfp_link_config_subtask(adapter);
 	ixgbe_watchdog_subtask(adapter);
@@ -7533,8 +7549,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	setup_timer(&adapter->service_timer, &ixgbe_service_timer,
 	            (unsigned long) adapter);
 
-	INIT_WORK(&adapter->reset_task, ixgbe_reset_task);
-
 	INIT_WORK(&adapter->service_task, ixgbe_service_task);
 	clear_bit(__IXGBE_SERVICE_SCHED, &adapter->state);
 
-- 
1.7.4.4

