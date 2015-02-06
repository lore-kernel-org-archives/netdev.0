From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 14/16] ixgbevf: rewrite watchdog task to function similar to igbvf
Date: Thu,  5 Feb 2015 20:31:23 -0800
Message-ID: <1423197085-32270-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423197085-32270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	kernel-team@fb.com, Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49678 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754715AbbBFEbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2015 23:31:44 -0500
In-Reply-To: <1423197085-32270-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch cleans up the logic dealing with link down/up by breaking down the
link detection and up/down events into separate functions - similar to how these
events are handled in other drivers.

CC: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 187 +++++++++++++---------
 2 files changed, 113 insertions(+), 75 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 65c2aee..a41ab37 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -436,6 +436,7 @@ struct ixgbevf_adapter {
 	bool link_up;
 
 	spinlock_t mbx_lock;
+	unsigned long last_reset;
 
 	struct work_struct watchdog_task;
 };
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 87f9f86..c110065 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2231,6 +2231,8 @@ void ixgbevf_reset(struct ixgbevf_adapter *adapter)
 		memcpy(netdev->perm_addr, adapter->hw.mac.addr,
 		       netdev->addr_len);
 	}
+
+	adapter->last_reset = jiffies;
 }
 
 static int ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
@@ -2684,7 +2686,8 @@ void ixgbevf_update_stats(struct ixgbevf_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i;
 
-	if (!adapter->link_up)
+	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
+	    test_bit(__IXGBEVF_RESETTING, &adapter->state))
 		return;
 
 	UPDATE_VF_COUNTER_32bit(IXGBE_VFGPRC, adapter->stats.last_vfgprc,
@@ -2714,17 +2717,45 @@ void ixgbevf_update_stats(struct ixgbevf_adapter *adapter)
 static void ixgbevf_watchdog(unsigned long data)
 {
 	struct ixgbevf_adapter *adapter = (struct ixgbevf_adapter *)data;
+
+	/* Do the reset outside of interrupt context */
+	schedule_work(&adapter->watchdog_task);
+}
+
+static void ixgbevf_reset_task(struct work_struct *work)
+{
+	struct ixgbevf_adapter *adapter;
+
+	adapter = container_of(work, struct ixgbevf_adapter, reset_task);
+
+	/* If we're already down or resetting, just bail */
+	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
+	    test_bit(__IXGBEVF_RESETTING, &adapter->state))
+		return;
+
+	adapter->tx_timeout_count++;
+
+	ixgbevf_reinit_locked(adapter);
+}
+
+/* ixgbevf_check_hang_subtask - check for hung queues and dropped interrupts
+ * @adapter - pointer to the device adapter structure
+ *
+ * This function serves two purposes.  First it strobes the interrupt lines
+ * in order to make certain interrupts are occurring.  Secondly it sets the
+ * bits needed to check for TX hangs.  As a result we should immediately
+ * determine if a hang has occurred.
+ */
+static void ixgbevf_check_hang_subtask(struct ixgbevf_adapter *adapter)
+{
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 eics = 0;
 	int i;
 
-	/*
-	 * Do the watchdog outside of interrupt context due to the lovely
-	 * delays that some of the newer hardware requires
-	 */
-
-	if (test_bit(__IXGBEVF_DOWN, &adapter->state))
-		goto watchdog_short_circuit;
+	/* If we're down or resetting, just bail */
+	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
+	    test_bit(__IXGBEVF_RESETTING, &adapter->state))
+		return;
 
 	/* Force detection of hung controller */
 	if (netif_carrier_ok(adapter->netdev)) {
@@ -2739,26 +2770,80 @@ static void ixgbevf_watchdog(unsigned long data)
 			eics |= 1 << i;
 	}
 
+	/* Cause software interrupt to ensure rings are cleaned */
 	IXGBE_WRITE_REG(hw, IXGBE_VTEICS, eics);
+}
 
-watchdog_short_circuit:
-	schedule_work(&adapter->watchdog_task);
+/**
+ * ixgbevf_watchdog_update_link - update the link status
+ * @adapter - pointer to the device adapter structure
+ **/
+static void ixgbevf_watchdog_update_link(struct ixgbevf_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 link_speed = adapter->link_speed;
+	bool link_up = adapter->link_up;
+	s32 err;
+
+	spin_lock_bh(&adapter->mbx_lock);
+
+	err = hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
+
+	spin_unlock_bh(&adapter->mbx_lock);
+
+	/* if check for link returns error we will need to reset */
+	if (err && time_after(jiffies, adapter->last_reset + (10 * HZ))) {
+		schedule_work(&adapter->reset_task);
+		link_up = false;
+	}
+
+	adapter->link_up = link_up;
+	adapter->link_speed = link_speed;
 }
 
-static void ixgbevf_reset_task(struct work_struct *work)
+/**
+ * ixgbevf_watchdog_link_is_up - update netif_carrier status and
+ *				 print link up message
+ * @adapter - pointer to the device adapter structure
+ **/
+static void ixgbevf_watchdog_link_is_up(struct ixgbevf_adapter *adapter)
 {
-	struct ixgbevf_adapter *adapter;
-	adapter = container_of(work, struct ixgbevf_adapter, reset_task);
+	struct net_device *netdev = adapter->netdev;
 
-	/* If we're already down or resetting, just bail */
-	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
-	    test_bit(__IXGBEVF_REMOVING, &adapter->state) ||
-	    test_bit(__IXGBEVF_RESETTING, &adapter->state))
+	/* only continue if link was previously down */
+	if (netif_carrier_ok(netdev))
 		return;
 
-	adapter->tx_timeout_count++;
+	dev_info(&adapter->pdev->dev, "NIC Link is Up %s\n",
+		 (adapter->link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
+		 "10 Gbps" :
+		 (adapter->link_speed == IXGBE_LINK_SPEED_1GB_FULL) ?
+		 "1 Gbps" :
+		 (adapter->link_speed == IXGBE_LINK_SPEED_100_FULL) ?
+		 "100 Mbps" :
+		 "unknown speed");
 
-	ixgbevf_reinit_locked(adapter);
+	netif_carrier_on(netdev);
+}
+
+/**
+ * ixgbevf_watchdog_link_is_down - update netif_carrier status and
+ *				   print link down message
+ * @adapter - pointer to the adapter structure
+ **/
+static void ixgbevf_watchdog_link_is_down(struct ixgbevf_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	adapter->link_speed = 0;
+
+	/* only continue if link was up previously */
+	if (!netif_carrier_ok(netdev))
+		return;
+
+	dev_info(&adapter->pdev->dev, "NIC Link is Down\n");
+
+	netif_carrier_off(netdev);
 }
 
 /**
@@ -2770,11 +2855,7 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 	struct ixgbevf_adapter *adapter = container_of(work,
 						       struct ixgbevf_adapter,
 						       watchdog_task);
-	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
-	u32 link_speed = adapter->link_speed;
-	bool link_up = adapter->link_up;
-	s32 need_reset;
 
 	if (IXGBE_REMOVED(hw->hw_addr)) {
 		if (!test_bit(__IXGBEVF_DOWN, &adapter->state)) {
@@ -2784,66 +2865,22 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 		}
 		return;
 	}
+
 	ixgbevf_queue_reset_subtask(adapter);
 
 	adapter->flags |= IXGBE_FLAG_IN_WATCHDOG_TASK;
 
-	/*
-	 * Always check the link on the watchdog because we have
-	 * no LSC interrupt
-	 */
-	spin_lock_bh(&adapter->mbx_lock);
-
-	need_reset = hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
-
-	spin_unlock_bh(&adapter->mbx_lock);
-
-	if (need_reset) {
-		adapter->link_up = link_up;
-		adapter->link_speed = link_speed;
-		netif_carrier_off(netdev);
-		netif_tx_stop_all_queues(netdev);
-		schedule_work(&adapter->reset_task);
-		goto pf_has_reset;
-	}
-	adapter->link_up = link_up;
-	adapter->link_speed = link_speed;
+	ixgbevf_watchdog_update_link(adapter);
 
-	if (link_up) {
-		if (!netif_carrier_ok(netdev)) {
-			char *link_speed_string;
-			switch (link_speed) {
-			case IXGBE_LINK_SPEED_10GB_FULL:
-				link_speed_string = "10 Gbps";
-				break;
-			case IXGBE_LINK_SPEED_1GB_FULL:
-				link_speed_string = "1 Gbps";
-				break;
-			case IXGBE_LINK_SPEED_100_FULL:
-				link_speed_string = "100 Mbps";
-				break;
-			default:
-				link_speed_string = "unknown speed";
-				break;
-			}
-			dev_info(&adapter->pdev->dev,
-				"NIC Link is Up, %s\n", link_speed_string);
-			netif_carrier_on(netdev);
-			netif_tx_wake_all_queues(netdev);
-		}
-	} else {
-		adapter->link_up = false;
-		adapter->link_speed = 0;
-		if (netif_carrier_ok(netdev)) {
-			dev_info(&adapter->pdev->dev, "NIC Link is Down\n");
-			netif_carrier_off(netdev);
-			netif_tx_stop_all_queues(netdev);
-		}
-	}
+	if (adapter->link_up)
+		ixgbevf_watchdog_link_is_up(adapter);
+	else
+		ixgbevf_watchdog_link_is_down(adapter);
 
 	ixgbevf_update_stats(adapter);
 
-pf_has_reset:
+	ixgbevf_check_hang_subtask(adapter);
+
 	/* Reset the timer */
 	if (!test_bit(__IXGBEVF_DOWN, &adapter->state) &&
 	    !test_bit(__IXGBEVF_REMOVING, &adapter->state))
-- 
1.9.3
