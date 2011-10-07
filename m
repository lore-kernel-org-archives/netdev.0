From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] e1000: convert hardware management from timers to threads
Date: Fri,  7 Oct 2011 00:18:35 -0700
Message-ID: <1317971926-23145-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34195 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758724Ab1JGHSt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 03:18:49 -0400
In-Reply-To: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Thomas Gleixner (tglx) reported that e1000 was delaying for many milliseconds
(using mdelay) from inside timer/interrupt context.  None of these paths are
performance critical and can be moved into threads/work items.  This patch
implements the work items and the next patch changes the mdelays to msleeps.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Tushar Dave <tushar.n.dave@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000.h      |   10 +-
 drivers/net/ethernet/intel/e1000/e1000_main.c |  129 ++++++++++---------------
 2 files changed, 55 insertions(+), 84 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 4ea87b1..fc6fbbd 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -214,9 +214,6 @@ struct e1000_rx_ring {
 /* board specific private data structure */
 
 struct e1000_adapter {
-	struct timer_list tx_fifo_stall_timer;
-	struct timer_list watchdog_timer;
-	struct timer_list phy_info_timer;
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 mng_vlan_id;
 	u32 bd_number;
@@ -237,7 +234,6 @@ struct e1000_adapter {
 	u16 tx_itr;
 	u16 rx_itr;
 
-	struct work_struct reset_task;
 	u8 fc_autoneg;
 
 	/* TX */
@@ -310,8 +306,10 @@ struct e1000_adapter {
 
 	bool discarding;
 
-	struct work_struct fifo_stall_task;
-	struct work_struct phy_info_task;
+	struct work_struct reset_task;
+	struct delayed_work watchdog_task;
+	struct delayed_work fifo_stall_task;
+	struct delayed_work phy_info_task;
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 4bbc05a..a0c5ea0 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -131,10 +131,8 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
 static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
                                 struct e1000_rx_ring *rx_ring);
 static void e1000_set_rx_mode(struct net_device *netdev);
-static void e1000_update_phy_info(unsigned long data);
 static void e1000_update_phy_info_task(struct work_struct *work);
-static void e1000_watchdog(unsigned long data);
-static void e1000_82547_tx_fifo_stall(unsigned long data);
+static void e1000_watchdog(struct work_struct *work);
 static void e1000_82547_tx_fifo_stall_task(struct work_struct *work);
 static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 				    struct net_device *netdev);
@@ -493,6 +491,15 @@ out:
 	return;
 }
 
+static void e1000_down_and_stop(struct e1000_adapter *adapter)
+{
+	set_bit(__E1000_DOWN, &adapter->flags);
+	cancel_work_sync(&adapter->reset_task);
+	cancel_delayed_work_sync(&adapter->watchdog_task);
+	cancel_delayed_work_sync(&adapter->phy_info_task);
+	cancel_delayed_work_sync(&adapter->fifo_stall_task);
+}
+
 void e1000_down(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
@@ -522,13 +529,9 @@ void e1000_down(struct e1000_adapter *adapter)
 	/*
 	 * Setting DOWN must be after irq_disable to prevent
 	 * a screaming interrupt.  Setting DOWN also prevents
-	 * timers and tasks from rescheduling.
+	 * tasks from rescheduling.
 	 */
-	set_bit(__E1000_DOWN, &adapter->flags);
-
-	del_timer_sync(&adapter->tx_fifo_stall_timer);
-	del_timer_sync(&adapter->watchdog_timer);
-	del_timer_sync(&adapter->phy_info_timer);
+	e1000_down_and_stop(adapter);
 
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
@@ -1120,21 +1123,12 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (!is_valid_ether_addr(netdev->perm_addr))
 		e_err(probe, "Invalid MAC Address\n");
 
-	init_timer(&adapter->tx_fifo_stall_timer);
-	adapter->tx_fifo_stall_timer.function = e1000_82547_tx_fifo_stall;
-	adapter->tx_fifo_stall_timer.data = (unsigned long)adapter;
-
-	init_timer(&adapter->watchdog_timer);
-	adapter->watchdog_timer.function = e1000_watchdog;
-	adapter->watchdog_timer.data = (unsigned long) adapter;
-
-	init_timer(&adapter->phy_info_timer);
-	adapter->phy_info_timer.function = e1000_update_phy_info;
-	adapter->phy_info_timer.data = (unsigned long)adapter;
 
-	INIT_WORK(&adapter->fifo_stall_task, e1000_82547_tx_fifo_stall_task);
+	INIT_DELAYED_WORK(&adapter->watchdog_task, e1000_watchdog);
+	INIT_DELAYED_WORK(&adapter->fifo_stall_task,
+			  e1000_82547_tx_fifo_stall_task);
+	INIT_DELAYED_WORK(&adapter->phy_info_task, e1000_update_phy_info_task);
 	INIT_WORK(&adapter->reset_task, e1000_reset_task);
-	INIT_WORK(&adapter->phy_info_task, e1000_update_phy_info_task);
 
 	e1000_check_options(adapter);
 
@@ -1279,13 +1273,7 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 
-	set_bit(__E1000_DOWN, &adapter->flags);
-	del_timer_sync(&adapter->tx_fifo_stall_timer);
-	del_timer_sync(&adapter->watchdog_timer);
-	del_timer_sync(&adapter->phy_info_timer);
-
-	cancel_work_sync(&adapter->reset_task);
-
+	e1000_down_and_stop(adapter);
 	e1000_release_manageability(adapter);
 
 	unregister_netdev(netdev);
@@ -1369,7 +1357,7 @@ static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
  * The open entry point is called when a network interface is made
  * active by the system (IFF_UP).  At this point all resources needed
  * for transmit and receive operations are allocated, the interrupt
- * handler is registered with the OS, the watchdog timer is started,
+ * handler is registered with the OS, the watchdog task is started,
  * and the stack is notified that the interface is ready.
  **/
 
@@ -2331,46 +2319,32 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 	kfree(mcarray);
 }
 
-/* Need to wait a few seconds after link up to get diagnostic information from
- * the phy */
-
-static void e1000_update_phy_info(unsigned long data)
-{
-	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
-	schedule_work(&adapter->phy_info_task);
-}
-
+/**
+ * e1000_update_phy_info_task - get phy info
+ * @work: work struct contained inside adapter struct
+ *
+ * Need to wait a few seconds after link up to get diagnostic information from
+ * the phy
+ */
 static void e1000_update_phy_info_task(struct work_struct *work)
 {
 	struct e1000_adapter *adapter = container_of(work,
-	                                             struct e1000_adapter,
-	                                             phy_info_task);
-	struct e1000_hw *hw = &adapter->hw;
-
+						     struct e1000_adapter,
+						     phy_info_task.work);
 	rtnl_lock();
-	e1000_phy_get_info(hw, &adapter->phy_info);
+	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
 	rtnl_unlock();
 }
 
 /**
- * e1000_82547_tx_fifo_stall - Timer Call-back
- * @data: pointer to adapter cast into an unsigned long
- **/
-static void e1000_82547_tx_fifo_stall(unsigned long data)
-{
-	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
-	schedule_work(&adapter->fifo_stall_task);
-}
-
-/**
  * e1000_82547_tx_fifo_stall_task - task to complete work
  * @work: work struct contained inside adapter struct
  **/
 static void e1000_82547_tx_fifo_stall_task(struct work_struct *work)
 {
 	struct e1000_adapter *adapter = container_of(work,
-	                                             struct e1000_adapter,
-	                                             fifo_stall_task);
+						     struct e1000_adapter,
+						     fifo_stall_task.work);
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	u32 tctl;
@@ -2393,7 +2367,7 @@ static void e1000_82547_tx_fifo_stall_task(struct work_struct *work)
 			atomic_set(&adapter->tx_fifo_stall, 0);
 			netif_wake_queue(netdev);
 		} else if (!test_bit(__E1000_DOWN, &adapter->flags)) {
-			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
+			schedule_delayed_work(&adapter->fifo_stall_task, 1);
 		}
 	}
 	rtnl_unlock();
@@ -2437,12 +2411,14 @@ bool e1000_has_link(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000_watchdog - Timer Call-back
- * @data: pointer to adapter cast into an unsigned long
+ * e1000_watchdog - work function
+ * @work: work struct contained inside adapter struct
  **/
-static void e1000_watchdog(unsigned long data)
+static void e1000_watchdog(struct work_struct *work)
 {
-	struct e1000_adapter *adapter = (struct e1000_adapter *)data;
+	struct e1000_adapter *adapter = container_of(work,
+						     struct e1000_adapter,
+						     watchdog_task.work);
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
@@ -2493,8 +2469,8 @@ static void e1000_watchdog(unsigned long data)
 
 			netif_carrier_on(netdev);
 			if (!test_bit(__E1000_DOWN, &adapter->flags))
-				mod_timer(&adapter->phy_info_timer,
-				          round_jiffies(jiffies + 2 * HZ));
+				schedule_delayed_work(&adapter->phy_info_task,
+						      2 * HZ);
 			adapter->smartspeed = 0;
 		}
 	} else {
@@ -2506,8 +2482,8 @@ static void e1000_watchdog(unsigned long data)
 			netif_carrier_off(netdev);
 
 			if (!test_bit(__E1000_DOWN, &adapter->flags))
-				mod_timer(&adapter->phy_info_timer,
-				          round_jiffies(jiffies + 2 * HZ));
+				schedule_delayed_work(&adapter->phy_info_task,
+						      2 * HZ);
 		}
 
 		e1000_smartspeed(adapter);
@@ -2563,10 +2539,9 @@ link_up:
 	/* Force detection of hung controller every watchdog period */
 	adapter->detect_tx_hung = true;
 
-	/* Reset the timer */
+	/* Reschedule the task */
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
-		mod_timer(&adapter->watchdog_timer,
-		          round_jiffies(jiffies + 2 * HZ));
+		schedule_delayed_work(&adapter->watchdog_task, 2 * HZ);
 }
 
 enum latency_range {
@@ -3206,14 +3181,12 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, count + 2)))
 		return NETDEV_TX_BUSY;
 
-	if (unlikely(hw->mac_type == e1000_82547)) {
-		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
-			netif_stop_queue(netdev);
-			if (!test_bit(__E1000_DOWN, &adapter->flags))
-				mod_timer(&adapter->tx_fifo_stall_timer,
-				          jiffies + 1);
-			return NETDEV_TX_BUSY;
-		}
+	if (unlikely((hw->mac_type == e1000_82547) &&
+		     (e1000_82547_fifo_workaround(adapter, skb)))) {
+		netif_stop_queue(netdev);
+		if (!test_bit(__E1000_DOWN, &adapter->flags))
+			schedule_delayed_work(&adapter->fifo_stall_task, 1);
+		return NETDEV_TX_BUSY;
 	}
 
 	if (vlan_tx_tag_present(skb)) {
@@ -3283,7 +3256,7 @@ static void e1000_reset_task(struct work_struct *work)
  * @netdev: network interface device structure
  *
  * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
+ * The statistics are actually updated from the watchdog.
  **/
 
 static struct net_device_stats *e1000_get_stats(struct net_device *netdev)
@@ -3551,7 +3524,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 		hw->get_link_status = 1;
 		/* guard against interrupt when we're going down */
 		if (!test_bit(__E1000_DOWN, &adapter->flags))
-			mod_timer(&adapter->watchdog_timer, jiffies + 1);
+			schedule_delayed_work(&adapter->watchdog_task, 1);
 	}
 
 	/* disable interrupts, without the synchronize_irq bit */
-- 
1.7.6.4
