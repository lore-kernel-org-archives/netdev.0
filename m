From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/2] netxen: remove netxen workqueue
Date: Thu, 13 Aug 2009 10:03:00 -0700
Message-ID: <1250182981-27594-2-git-send-email-dhananjay@netxen.com>
References: <1250182981-27594-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@qlogic.com>
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:27274 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1752399AbZHMRDC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Aug 2009 13:03:02 -0400
In-Reply-To: <1250182981-27594-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@qlogic.com>

o Remove private workqueue in the driver, move all
  scheduled tasks to keventd workqueues. This makes
  ports (interfaces) of same / different NIC boards
  independent, in terms of their link watchdog and
  reset tasks.

o Move quick checks for link status and temperature
  in timer callback, schedule watchdog task only if
  link status changed or temperature reached critical
  threshold.

This also fixes deadlock when thermal panic occurs,
watchdog work was flushing workqueue that it was
sitting on.

Signed-off-by: Amit Kumar Salecha <amit@qlogic.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    2 +-
 drivers/net/netxen/netxen_nic_main.c |   69 ++++++++++++++++++++--------------
 2 files changed, 42 insertions(+), 29 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index f86e050..a9c1fcc 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1254,7 +1254,7 @@ struct netxen_adapter {
 	u8 mc_enabled;
 	u8 max_mc_count;
 	u8 rss_supported;
-	u8 resv2;
+	u8 link_changed;
 	u32 resv3;
 
 	u8 has_link_events;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 70c05c4..d24e1cb 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -94,10 +94,6 @@ static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
 
 MODULE_DEVICE_TABLE(pci, netxen_pci_tbl);
 
-static struct workqueue_struct *netxen_workq;
-#define SCHEDULE_WORK(tp)	queue_work(netxen_workq, tp)
-#define FLUSH_SCHEDULED_WORK()	flush_workqueue(netxen_workq)
-
 static void netxen_watchdog(unsigned long);
 
 static uint32_t crb_cmd_producer[4] = {
@@ -880,7 +876,6 @@ netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 	spin_unlock(&adapter->tx_clean_lock);
 
 	del_timer_sync(&adapter->watchdog_timer);
-	FLUSH_SCHEDULED_WORK();
 }
 
 
@@ -1177,6 +1172,9 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 
+	cancel_work_sync(&adapter->watchdog_task);
+	cancel_work_sync(&adapter->tx_timeout_task);
+
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
 		netxen_nic_detach(adapter);
 	}
@@ -1211,6 +1209,9 @@ netxen_nic_suspend(struct pci_dev *pdev, pm_message_t state)
 	if (netif_running(netdev))
 		netxen_nic_down(adapter, netdev);
 
+	cancel_work_sync(&adapter->watchdog_task);
+	cancel_work_sync(&adapter->tx_timeout_task);
+
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC)
 		netxen_nic_detach(adapter);
 
@@ -1549,11 +1550,6 @@ static int netxen_nic_check_temp(struct netxen_adapter *adapter)
 		       "%s: Device temperature %d degrees C exceeds"
 		       " maximum allowed. Hardware has been shut down.\n",
 		       netdev->name, temp_val);
-
-		netif_device_detach(netdev);
-		netxen_nic_down(adapter, netdev);
-		netxen_nic_detach(adapter);
-
 		rv = 1;
 	} else if (temp_state == NX_TEMP_WARN) {
 		if (adapter->temp == NX_TEMP_NORMAL) {
@@ -1587,10 +1583,7 @@ void netxen_advert_link_change(struct netxen_adapter *adapter, int linkup)
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 		}
-
-		if (!adapter->has_link_events)
-			netxen_nic_set_link_parameters(adapter);
-
+		adapter->link_changed = !adapter->has_link_events;
 	} else if (!adapter->ahw.linkup && linkup) {
 		printk(KERN_INFO "%s: %s NIC Link is up\n",
 		       netxen_nic_driver_name, netdev->name);
@@ -1599,9 +1592,7 @@ void netxen_advert_link_change(struct netxen_adapter *adapter, int linkup)
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
 		}
-
-		if (!adapter->has_link_events)
-			netxen_nic_set_link_parameters(adapter);
+		adapter->link_changed = !adapter->has_link_events;
 	}
 }
 
@@ -1628,11 +1619,36 @@ static void netxen_nic_handle_phy_intr(struct netxen_adapter *adapter)
 	netxen_advert_link_change(adapter, linkup);
 }
 
+static void netxen_nic_thermal_shutdown(struct netxen_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+
+	netif_device_detach(netdev);
+	netxen_nic_down(adapter, netdev);
+	netxen_nic_detach(adapter);
+}
+
 static void netxen_watchdog(unsigned long v)
 {
 	struct netxen_adapter *adapter = (struct netxen_adapter *)v;
 
-	SCHEDULE_WORK(&adapter->watchdog_task);
+	if (netxen_nic_check_temp(adapter))
+		goto do_sched;
+
+	if (!adapter->has_link_events) {
+		netxen_nic_handle_phy_intr(adapter);
+
+		if (adapter->link_changed)
+			goto do_sched;
+	}
+
+	if (netif_running(adapter->netdev))
+		mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+
+	return;
+
+do_sched:
+	schedule_work(&adapter->watchdog_task);
 }
 
 void netxen_watchdog_task(struct work_struct *work)
@@ -1640,11 +1656,13 @@ void netxen_watchdog_task(struct work_struct *work)
 	struct netxen_adapter *adapter =
 		container_of(work, struct netxen_adapter, watchdog_task);
 
-	if (netxen_nic_check_temp(adapter))
+	if (adapter->temp == NX_TEMP_PANIC) {
+		netxen_nic_thermal_shutdown(adapter);
 		return;
+	}
 
-	if (!adapter->has_link_events)
-		netxen_nic_handle_phy_intr(adapter);
+	if (adapter->link_changed)
+		netxen_nic_set_link_parameters(adapter);
 
 	if (netif_running(adapter->netdev))
 		mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
@@ -1652,9 +1670,8 @@ void netxen_watchdog_task(struct work_struct *work)
 
 static void netxen_tx_timeout(struct net_device *netdev)
 {
-	struct netxen_adapter *adapter = (struct netxen_adapter *)
-						netdev_priv(netdev);
-	SCHEDULE_WORK(&adapter->tx_timeout_task);
+	struct netxen_adapter *adapter = netdev_priv(netdev);
+	schedule_work(&adapter->tx_timeout_task);
 }
 
 static void netxen_tx_timeout_task(struct work_struct *work)
@@ -1811,9 +1828,6 @@ static int __init netxen_init_module(void)
 {
 	printk(KERN_INFO "%s\n", netxen_nic_driver_string);
 
-	if ((netxen_workq = create_singlethread_workqueue("netxen")) == NULL)
-		return -ENOMEM;
-
 	return pci_register_driver(&netxen_driver);
 }
 
@@ -1822,7 +1836,6 @@ module_init(netxen_init_module);
 static void __exit netxen_exit_module(void)
 {
 	pci_unregister_driver(&netxen_driver);
-	destroy_workqueue(netxen_workq);
 }
 
 module_exit(netxen_exit_module);
-- 
1.6.0.2

