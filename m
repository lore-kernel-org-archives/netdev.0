From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 3/5] netxen: refactor netdev open close
Date: Mon,  9 Mar 2009 11:50:54 -0700
Message-ID: <1236624656-2082-3-git-send-email-dhananjay@netxen.com>
References: <1236624656-2082-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:43661 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753495AbZCISvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 14:51:03 -0400
In-Reply-To: <1236624656-2082-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rearrange open and close into hardware attach(), detach() and
nic up() and down(). this will be used for suspend/resume
subsequently.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |  302 +++++++++++++++++++---------------
 1 files changed, 166 insertions(+), 136 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f764eb2..084c0ed 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -94,20 +94,6 @@ static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
 
 MODULE_DEVICE_TABLE(pci, netxen_pci_tbl);
 
-/*
- * In netxen_nic_down(), we must wait for any pending callback requests into
- * netxen_watchdog_task() to complete; eg otherwise the watchdog_timer could be
- * reenabled right after it is deleted in netxen_nic_down().
- * FLUSH_SCHEDULED_WORK()  does this synchronization.
- *
- * Normally, schedule_work()/flush_scheduled_work() could have worked, but
- * netxen_nic_close() is invoked with kernel rtnl lock held. netif_carrier_off()
- * call in netxen_nic_close() triggers a schedule_work(&linkwatch_work), and a
- * subsequent call to flush_scheduled_work() in netxen_nic_down() would cause
- * linkwatch_event() to be executed which also attempts to acquire the rtnl
- * lock thus causing a deadlock.
- */
-
 static struct workqueue_struct *netxen_workq;
 #define SCHEDULE_WORK(tp)	queue_work(netxen_workq, tp)
 #define FLUSH_SCHEDULED_WORK()	flush_workqueue(netxen_workq)
@@ -719,6 +705,163 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 	return 0;
 }
 
+static int
+netxen_nic_request_irq(struct netxen_adapter *adapter)
+{
+	irq_handler_t handler;
+	unsigned long flags = IRQF_SAMPLE_RANDOM;
+	struct net_device *netdev = adapter->netdev;
+
+	if ((adapter->msi_mode != MSI_MODE_MULTIFUNC) ||
+		(adapter->intr_scheme != INTR_SCHEME_PERPORT)) {
+		printk(KERN_ERR "%s: Firmware interrupt scheme is "
+				"incompatible with driver\n",
+				netdev->name);
+		adapter->driver_mismatch = 1;
+		return -EINVAL;
+	}
+
+	if (adapter->flags & NETXEN_NIC_MSIX_ENABLED)
+		handler = netxen_msix_intr;
+	else if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
+		handler = netxen_msi_intr;
+	else {
+		flags |= IRQF_SHARED;
+		handler = netxen_intr;
+	}
+	adapter->irq = netdev->irq;
+
+	return request_irq(adapter->irq, handler,
+			  flags, netdev->name, adapter);
+}
+
+static int
+netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
+{
+	int err;
+
+	err = adapter->init_port(adapter, adapter->physical_port);
+	if (err) {
+		printk(KERN_ERR "%s: Failed to initialize port %d\n",
+				netxen_nic_driver_name, adapter->portnum);
+		return err;
+	}
+	adapter->macaddr_set(adapter, netdev->dev_addr);
+
+	netxen_nic_set_link_parameters(adapter);
+
+	netxen_set_multicast_list(netdev);
+	if (adapter->set_mtu)
+		adapter->set_mtu(adapter, netdev->mtu);
+
+	adapter->ahw.linkup = 0;
+	mod_timer(&adapter->watchdog_timer, jiffies);
+
+	napi_enable(&adapter->napi);
+	netxen_nic_enable_int(adapter);
+
+	return 0;
+}
+
+static void
+netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
+{
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+	napi_disable(&adapter->napi);
+
+	if (adapter->stop_port)
+		adapter->stop_port(adapter);
+
+	netxen_nic_disable_int(adapter);
+
+	netxen_release_tx_buffers(adapter);
+
+	FLUSH_SCHEDULED_WORK();
+	del_timer_sync(&adapter->watchdog_timer);
+}
+
+
+static int
+netxen_nic_attach(struct netxen_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+	int err, ctx, ring;
+
+	err = netxen_init_firmware(adapter);
+	if (err != 0) {
+		printk(KERN_ERR "Failed to init firmware\n");
+		return -EIO;
+	}
+
+	if (adapter->fw_major < 4)
+		adapter->max_rds_rings = 3;
+	else
+		adapter->max_rds_rings = 2;
+
+	err = netxen_alloc_sw_resources(adapter);
+	if (err) {
+		printk(KERN_ERR "%s: Error in setting sw resources\n",
+				netdev->name);
+		return err;
+	}
+
+	netxen_nic_clear_stats(adapter);
+
+	err = netxen_alloc_hw_resources(adapter);
+	if (err) {
+		printk(KERN_ERR "%s: Error in setting hw resources\n",
+				netdev->name);
+		goto err_out_free_sw;
+	}
+
+	if (adapter->fw_major < 4) {
+		adapter->crb_addr_cmd_producer =
+			crb_cmd_producer[adapter->portnum];
+		adapter->crb_addr_cmd_consumer =
+			crb_cmd_consumer[adapter->portnum];
+
+		netxen_nic_update_cmd_producer(adapter, 0);
+		netxen_nic_update_cmd_consumer(adapter, 0);
+	}
+
+	for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
+		for (ring = 0; ring < adapter->max_rds_rings; ring++)
+			netxen_post_rx_buffers(adapter, ctx, ring);
+	}
+
+	err = netxen_nic_request_irq(adapter);
+	if (err) {
+		dev_err(&pdev->dev, "%s: failed to setup interrupt\n",
+				netdev->name);
+		goto err_out_free_rxbuf;
+	}
+
+	adapter->is_up = NETXEN_ADAPTER_UP_MAGIC;
+	return 0;
+
+err_out_free_rxbuf:
+	netxen_release_rx_buffers(adapter);
+	netxen_free_hw_resources(adapter);
+err_out_free_sw:
+	netxen_free_sw_resources(adapter);
+	return err;
+}
+
+static void
+netxen_nic_detach(struct netxen_adapter *adapter)
+{
+	if (adapter->irq)
+		free_irq(adapter->irq, adapter);
+
+	netxen_release_rx_buffers(adapter);
+	netxen_free_hw_resources(adapter);
+	netxen_free_sw_resources(adapter);
+
+	adapter->is_up = 0;
+}
+
 static int __devinit
 netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
@@ -970,9 +1113,7 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 	unregister_netdev(netdev);
 
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
-		netxen_free_hw_resources(adapter);
-		netxen_release_rx_buffers(adapter);
-		netxen_free_sw_resources(adapter);
+		netxen_nic_detach(adapter);
 
 		if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 			netxen_p3_free_mac_list(adapter);
@@ -981,9 +1122,6 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 	if (adapter->portnum == 0)
 		netxen_free_adapter_offload(adapter);
 
-	if (adapter->irq)
-		free_irq(adapter->irq, adapter);
-
 	netxen_teardown_intr(adapter);
 
 	netxen_cleanup_pci_map(adapter);
@@ -995,125 +1133,30 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 }
 
-/*
- * Called when a network interface is made active
- * @returns 0 on success, negative value on failure
- */
 static int netxen_nic_open(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	int err = 0;
-	int ctx, ring;
-	irq_handler_t handler;
-	unsigned long flags = IRQF_SAMPLE_RANDOM;
 
 	if (adapter->driver_mismatch)
 		return -EIO;
 
 	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC) {
-		err = netxen_init_firmware(adapter);
-		if (err != 0) {
-			printk(KERN_ERR "Failed to init firmware\n");
-			return -EIO;
-		}
-
-		if (adapter->fw_major < 4)
-			adapter->max_rds_rings = 3;
-		else
-			adapter->max_rds_rings = 2;
-
-		err = netxen_alloc_sw_resources(adapter);
-		if (err) {
-			printk(KERN_ERR "%s: Error in setting sw resources\n",
-					netdev->name);
+		err = netxen_nic_attach(adapter);
+		if (err)
 			return err;
-		}
-
-		netxen_nic_clear_stats(adapter);
-
-		err = netxen_alloc_hw_resources(adapter);
-		if (err) {
-			printk(KERN_ERR "%s: Error in setting hw resources\n",
-					netdev->name);
-			goto err_out_free_sw;
-		}
-
-		if ((adapter->msi_mode != MSI_MODE_MULTIFUNC) ||
-			(adapter->intr_scheme != INTR_SCHEME_PERPORT)) {
-			printk(KERN_ERR "%s: Firmware interrupt scheme is "
-					"incompatible with driver\n",
-					netdev->name);
-			adapter->driver_mismatch = 1;
-			goto err_out_free_hw;
-		}
-
-		if (adapter->fw_major < 4) {
-			adapter->crb_addr_cmd_producer =
-				crb_cmd_producer[adapter->portnum];
-			adapter->crb_addr_cmd_consumer =
-				crb_cmd_consumer[adapter->portnum];
-
-			netxen_nic_update_cmd_producer(adapter, 0);
-			netxen_nic_update_cmd_consumer(adapter, 0);
-		}
-
-		for (ctx = 0; ctx < MAX_RCV_CTX; ++ctx) {
-			for (ring = 0; ring < adapter->max_rds_rings; ring++)
-				netxen_post_rx_buffers(adapter, ctx, ring);
-		}
-		if (adapter->flags & NETXEN_NIC_MSIX_ENABLED)
-			handler = netxen_msix_intr;
-		else if (adapter->flags & NETXEN_NIC_MSI_ENABLED)
-			handler = netxen_msi_intr;
-		else {
-			flags |= IRQF_SHARED;
-			handler = netxen_intr;
-		}
-		adapter->irq = netdev->irq;
-		err = request_irq(adapter->irq, handler,
-				  flags, netdev->name, adapter);
-		if (err) {
-			printk(KERN_ERR "request_irq failed with: %d\n", err);
-			goto err_out_free_rxbuf;
-		}
-
-		adapter->is_up = NETXEN_ADAPTER_UP_MAGIC;
 	}
 
-	/* Done here again so that even if phantom sw overwrote it,
-	 * we set it */
-	err = adapter->init_port(adapter, adapter->physical_port);
-	if (err) {
-		printk(KERN_ERR "%s: Failed to initialize port %d\n",
-				netxen_nic_driver_name, adapter->portnum);
-		goto err_out_free_irq;
-	}
-	adapter->macaddr_set(adapter, netdev->dev_addr);
-
-	netxen_nic_set_link_parameters(adapter);
-
-	netxen_set_multicast_list(netdev);
-	if (adapter->set_mtu)
-		adapter->set_mtu(adapter, netdev->mtu);
-
-	adapter->ahw.linkup = 0;
-	mod_timer(&adapter->watchdog_timer, jiffies);
-
-	napi_enable(&adapter->napi);
-	netxen_nic_enable_int(adapter);
+	err = netxen_nic_up(adapter, netdev);
+	if (err)
+		goto err_out;
 
 	netif_start_queue(netdev);
 
 	return 0;
 
-err_out_free_irq:
-	free_irq(adapter->irq, adapter);
-err_out_free_rxbuf:
-	netxen_release_rx_buffers(adapter);
-err_out_free_hw:
-	netxen_free_hw_resources(adapter);
-err_out_free_sw:
-	netxen_free_sw_resources(adapter);
+err_out:
+	netxen_nic_detach(adapter);
 	return err;
 }
 
@@ -1124,20 +1167,7 @@ static int netxen_nic_close(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 
-	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
-	napi_disable(&adapter->napi);
-
-	if (adapter->stop_port)
-		adapter->stop_port(adapter);
-
-	netxen_nic_disable_int(adapter);
-
-	netxen_release_tx_buffers(adapter);
-
-	FLUSH_SCHEDULED_WORK();
-	del_timer_sync(&adapter->watchdog_timer);
-
+	netxen_nic_down(adapter, netdev);
 	return 0;
 }
 
-- 
1.6.0.2

