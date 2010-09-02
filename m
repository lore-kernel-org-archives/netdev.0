From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-next 4/4] cxgb3: Avoid flush_workqueue() deadlock.
Date: Thu,  2 Sep 2010 16:07:32 -0700
Message-ID: <1283468852-1010-4-git-send-email-leedom@chelsio.com>
References: <241D2F16-4F92-48DD-A904-832771B2F4B4@chelsio.com>
Cc: Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31635 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756748Ab0IBXHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 19:07:39 -0400
In-Reply-To: <241D2F16-4F92-48DD-A904-832771B2F4B4@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't call flush_workqueue() on the cxgb3 Work Queue in cxgb_down() when
we're being called from the fatal error task ... which is executing on the
cxgb3 Work Queue.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb3/cxgb3_main.c |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index ad19585..1ecf53d 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1286,7 +1286,7 @@ irq_err:
 /*
  * Release resources when all the ports and offloading have been stopped.
  */
-static void cxgb_down(struct adapter *adapter)
+static void cxgb_down(struct adapter *adapter, int on_wq)
 {
 	t3_sge_stop(adapter);
 	spin_lock_irq(&adapter->work_lock);	/* sync with PHY intr task */
@@ -1296,7 +1296,8 @@ static void cxgb_down(struct adapter *adapter)
 	free_irq_resources(adapter);
 	quiesce_rx(adapter);
 	t3_sge_stop(adapter);
-	flush_workqueue(cxgb3_wq);	/* wait for external IRQ handler */
+	if (!on_wq)
+		flush_workqueue(cxgb3_wq);/* wait for external IRQ handler */
 }
 
 static void schedule_chk_task(struct adapter *adap)
@@ -1374,7 +1375,7 @@ static int offload_close(struct t3cdev *tdev)
 	clear_bit(OFFLOAD_DEVMAP_BIT, &adapter->open_device_map);
 
 	if (!adapter->open_device_map)
-		cxgb_down(adapter);
+		cxgb_down(adapter, 0);
 
 	cxgb3_offload_deactivate(adapter);
 	return 0;
@@ -1409,7 +1410,7 @@ static int cxgb_open(struct net_device *dev)
 	return 0;
 }
 
-static int cxgb_close(struct net_device *dev)
+static int __cxgb_close(struct net_device *dev, int on_wq)
 {
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
@@ -1436,12 +1437,17 @@ static int cxgb_close(struct net_device *dev)
 		cancel_delayed_work_sync(&adapter->adap_check_task);
 
 	if (!adapter->open_device_map)
-		cxgb_down(adapter);
+		cxgb_down(adapter, on_wq);
 
 	cxgb3_event_notify(&adapter->tdev, OFFLOAD_PORT_DOWN, pi->port_id);
 	return 0;
 }
 
+static int cxgb_close(struct net_device *dev)
+{
+	return __cxgb_close(dev, 0);
+}
+
 static struct net_device_stats *cxgb_get_stats(struct net_device *dev)
 {
 	struct port_info *pi = netdev_priv(dev);
@@ -2862,7 +2868,7 @@ void t3_os_link_fault_handler(struct adapter *adapter, int port_id)
 	spin_unlock(&adapter->work_lock);
 }
 
-static int t3_adapter_error(struct adapter *adapter, int reset)
+static int t3_adapter_error(struct adapter *adapter, int reset, int on_wq)
 {
 	int i, ret = 0;
 
@@ -2877,7 +2883,7 @@ static int t3_adapter_error(struct adapter *adapter, int reset)
 		struct net_device *netdev = adapter->port[i];
 
 		if (netif_running(netdev))
-			cxgb_close(netdev);
+			__cxgb_close(netdev, on_wq);
 	}
 
 	/* Stop SGE timers */
@@ -2948,7 +2954,7 @@ static void fatal_error_task(struct work_struct *work)
 	int err = 0;
 
 	rtnl_lock();
-	err = t3_adapter_error(adapter, 1);
+	err = t3_adapter_error(adapter, 1, 1);
 	if (!err)
 		err = t3_reenable_adapter(adapter);
 	if (!err)
@@ -2998,7 +3004,7 @@ static pci_ers_result_t t3_io_error_detected(struct pci_dev *pdev,
 	if (state == pci_channel_io_perm_failure)
 		return PCI_ERS_RESULT_DISCONNECT;
 
-	ret = t3_adapter_error(adapter, 0);
+	ret = t3_adapter_error(adapter, 0, 0);
 
 	/* Request a slot reset. */
 	return PCI_ERS_RESULT_NEED_RESET;
-- 
1.7.0.4

