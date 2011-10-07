From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/13] e1000: convert to private mutex from rtnl
Date: Fri,  7 Oct 2011 00:18:37 -0700
Message-ID: <1317971926-23145-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34234 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758795Ab1JGHSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 03:18:51 -0400
In-Reply-To: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The e1000 driver when running with lockdep could run into
some possible deadlocks between the work items acquiring
rtnl and the rtnl lock being acquired before work items
were cancelled.

Use a private mutex to make sure lock ordering isn't violated.
The private mutex is only used to protect areas not generally
covered by the rtnl lock already.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: Tushar Dave <tushar.n.dave@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000.h      |    2 +
 drivers/net/ethernet/intel/e1000/e1000_main.c |   38 +++++++++++++++++++------
 2 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index fc6fbbd..1e15969 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -310,6 +310,8 @@ struct e1000_adapter {
 	struct delayed_work watchdog_task;
 	struct delayed_work fifo_stall_task;
 	struct delayed_work phy_info_task;
+
+	struct mutex mutex;
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 6d03d76..a42421f 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -546,10 +546,10 @@ static void e1000_reinit_safe(struct e1000_adapter *adapter)
 {
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
 		msleep(1);
-	rtnl_lock();
+	mutex_lock(&adapter->mutex);
 	e1000_down(adapter);
 	e1000_up(adapter);
-	rtnl_unlock();
+	mutex_unlock(&adapter->mutex);
 	clear_bit(__E1000_RESETTING, &adapter->flags);
 }
 
@@ -1317,6 +1317,7 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	e1000_irq_disable(adapter);
 
 	spin_lock_init(&adapter->stats_lock);
+	mutex_init(&adapter->mutex);
 
 	set_bit(__E1000_DOWN, &adapter->flags);
 
@@ -2331,9 +2332,11 @@ static void e1000_update_phy_info_task(struct work_struct *work)
 	struct e1000_adapter *adapter = container_of(work,
 						     struct e1000_adapter,
 						     phy_info_task.work);
-	rtnl_lock();
+	if (test_bit(__E1000_DOWN, &adapter->flags))
+		return;
+	mutex_lock(&adapter->mutex);
 	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
-	rtnl_unlock();
+	mutex_unlock(&adapter->mutex);
 }
 
 /**
@@ -2349,7 +2352,9 @@ static void e1000_82547_tx_fifo_stall_task(struct work_struct *work)
 	struct net_device *netdev = adapter->netdev;
 	u32 tctl;
 
-	rtnl_lock();
+	if (test_bit(__E1000_DOWN, &adapter->flags))
+		return;
+	mutex_lock(&adapter->mutex);
 	if (atomic_read(&adapter->tx_fifo_stall)) {
 		if ((er32(TDT) == er32(TDH)) &&
 		   (er32(TDFT) == er32(TDFH)) &&
@@ -2370,7 +2375,7 @@ static void e1000_82547_tx_fifo_stall_task(struct work_struct *work)
 			schedule_delayed_work(&adapter->fifo_stall_task, 1);
 		}
 	}
-	rtnl_unlock();
+	mutex_unlock(&adapter->mutex);
 }
 
 bool e1000_has_link(struct e1000_adapter *adapter)
@@ -2424,6 +2429,10 @@ static void e1000_watchdog(struct work_struct *work)
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	u32 link, tctl;
 
+	if (test_bit(__E1000_DOWN, &adapter->flags))
+		return;
+
+	mutex_lock(&adapter->mutex);
 	link = e1000_has_link(adapter);
 	if ((netif_carrier_ok(netdev)) && link)
 		goto link_up;
@@ -2512,8 +2521,8 @@ link_up:
 			 * (Do the reset outside of interrupt context). */
 			adapter->tx_timeout_count++;
 			schedule_work(&adapter->reset_task);
-			/* return immediately since reset is imminent */
-			return;
+			/* exit immediately since reset is imminent */
+			goto unlock;
 		}
 	}
 
@@ -2542,6 +2551,9 @@ link_up:
 	/* Reschedule the task */
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		schedule_delayed_work(&adapter->watchdog_task, 2 * HZ);
+
+unlock:
+	mutex_unlock(&adapter->mutex);
 }
 
 enum latency_range {
@@ -3248,6 +3260,8 @@ static void e1000_reset_task(struct work_struct *work)
 	struct e1000_adapter *adapter =
 		container_of(work, struct e1000_adapter, reset_task);
 
+	if (test_bit(__E1000_DOWN, &adapter->flags))
+		return;
 	e1000_reinit_safe(adapter);
 }
 
@@ -4702,6 +4716,8 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 	netif_device_detach(netdev);
 
+	mutex_lock(&adapter->mutex);
+
 	if (netif_running(netdev)) {
 		WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 		e1000_down(adapter);
@@ -4709,8 +4725,10 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 
 #ifdef CONFIG_PM
 	retval = pci_save_state(pdev);
-	if (retval)
+	if (retval) {
+		mutex_unlock(&adapter->mutex);
 		return retval;
+	}
 #endif
 
 	status = er32(STATUS);
@@ -4765,6 +4783,8 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 	if (netif_running(netdev))
 		e1000_free_irq(adapter);
 
+	mutex_unlock(&adapter->mutex);
+
 	pci_disable_device(pdev);
 
 	return 0;
-- 
1.7.6.4
