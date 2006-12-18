From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/5] myri10ge: move request_irq to myri10ge_open
Date: Mon, 18 Dec 2006 11:50:40 +0100
Message-ID: <45867280.4020500@myri.com>
References: <45867228.1090406@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:41358 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753841AbWLRLVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 06:21:39 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <45867228.1090406@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Request IRQ in myri10ge_open() and free in close() instead of probe()
and remove() to eliminate potential race between the watchdog and the
interrupt handler. Additionaly, the interrupt handler won't get called
on shared irq anymore when the interface is down.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   98 ++++++++++++++++++++++------------------
 1 file changed, 54 insertions(+), 44 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2006-12-17 22:14:10.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2006-12-17 22:14:43.000000000 +0100
@@ -721,12 +721,10 @@
 	status |=
 	    myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_IRQ_ACK_OFFSET, &cmd, 0);
 	mgp->irq_claim = (__iomem __be32 *) (mgp->sram + cmd.data0);
-	if (!mgp->msi_enabled) {
-		status |= myri10ge_send_cmd
-		    (mgp, MXGEFW_CMD_GET_IRQ_DEASSERT_OFFSET, &cmd, 0);
-		mgp->irq_deassert = (__iomem __be32 *) (mgp->sram + cmd.data0);
+	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_IRQ_DEASSERT_OFFSET,
+				    &cmd, 0);
+	mgp->irq_deassert = (__iomem __be32 *) (mgp->sram + cmd.data0);
 
-	}
 	status |= myri10ge_send_cmd
 	    (mgp, MXGEFW_CMD_GET_INTR_COAL_DELAY_OFFSET, &cmd, 0);
 	mgp->intr_coal_delay_ptr = (__iomem __be32 *) (mgp->sram + cmd.data0);
@@ -1619,6 +1617,41 @@
 	mgp->tx.req_list = NULL;
 }
 
+static int myri10ge_request_irq(struct myri10ge_priv *mgp)
+{
+	struct pci_dev *pdev = mgp->pdev;
+	int status;
+
+	if (myri10ge_msi) {
+		status = pci_enable_msi(pdev);
+		if (status != 0)
+			dev_err(&pdev->dev,
+				"Error %d setting up MSI; falling back to xPIC\n",
+				status);
+		else
+			mgp->msi_enabled = 1;
+	} else {
+		mgp->msi_enabled = 0;
+	}
+	status = request_irq(pdev->irq, myri10ge_intr, IRQF_SHARED,
+			     mgp->dev->name, mgp);
+	if (status != 0) {
+		dev_err(&pdev->dev, "failed to allocate IRQ\n");
+		if (mgp->msi_enabled)
+			pci_disable_msi(pdev);
+	}
+	return status;
+}
+
+static void myri10ge_free_irq(struct myri10ge_priv *mgp)
+{
+	struct pci_dev *pdev = mgp->pdev;
+
+	free_irq(pdev->irq, mgp);
+	if (mgp->msi_enabled)
+		pci_disable_msi(pdev);
+}
+
 static int myri10ge_open(struct net_device *dev)
 {
 	struct myri10ge_priv *mgp;
@@ -1634,10 +1667,13 @@
 	status = myri10ge_reset(mgp);
 	if (status != 0) {
 		printk(KERN_ERR "myri10ge: %s: failed reset\n", dev->name);
-		mgp->running = MYRI10GE_ETH_STOPPED;
-		return -ENXIO;
+		goto abort_with_nothing;
 	}
 
+	status = myri10ge_request_irq(mgp);
+	if (status != 0)
+		goto abort_with_nothing;
+
 	/* decide what small buffer size to use.  For good TCP rx
 	 * performance, it is important to not receive 1514 byte
 	 * frames into jumbo buffers, as it confuses the socket buffer
@@ -1677,7 +1713,7 @@
 		       "myri10ge: %s: failed to get ring sizes or locations\n",
 		       dev->name);
 		mgp->running = MYRI10GE_ETH_STOPPED;
-		return -ENXIO;
+		goto abort_with_irq;
 	}
 
 	if (mgp->mtrr >= 0) {
@@ -1708,7 +1744,7 @@
 
 	status = myri10ge_allocate_rings(dev);
 	if (status != 0)
-		goto abort_with_nothing;
+		goto abort_with_irq;
 
 	/* now give firmware buffers sizes, and MTU */
 	cmd.data0 = dev->mtu + ETH_HLEN + VLAN_HLEN;
@@ -1771,6 +1807,9 @@
 abort_with_rings:
 	myri10ge_free_rings(dev);
 
+abort_with_irq:
+	myri10ge_free_irq(mgp);
+
 abort_with_nothing:
 	mgp->running = MYRI10GE_ETH_STOPPED;
 	return -ENOMEM;
@@ -1807,7 +1846,7 @@
 		printk(KERN_ERR "myri10ge: %s never got down irq\n", dev->name);
 
 	netif_tx_disable(dev);
-
+	myri10ge_free_irq(mgp);
 	myri10ge_free_rings(dev);
 
 	mgp->running = MYRI10GE_ETH_STOPPED;
@@ -2529,7 +2568,6 @@
 		rtnl_unlock();
 	}
 	myri10ge_dummy_rdma(mgp, 0);
-	free_irq(pdev->irq, mgp);
 	myri10ge_save_state(mgp);
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
@@ -2565,13 +2603,6 @@
 
 	pci_set_master(pdev);
 
-	status = request_irq(pdev->irq, myri10ge_intr, IRQF_SHARED,
-			     netdev->name, mgp);
-	if (status != 0) {
-		dev_err(&pdev->dev, "failed to allocate IRQ\n");
-		goto abort_with_enabled;
-	}
-
 	myri10ge_reset(mgp);
 	myri10ge_dummy_rdma(mgp, 1);
 
@@ -2581,8 +2612,11 @@
 
 	if (netif_running(netdev)) {
 		rtnl_lock();
-		myri10ge_open(netdev);
+		status = myri10ge_open(netdev);
 		rtnl_unlock();
+		if (status != 0)
+			goto abort_with_enabled;
+
 	}
 	netif_device_attach(netdev);
 
@@ -2860,23 +2894,6 @@
 		goto abort_with_firmware;
 	}
 
-	if (myri10ge_msi) {
-		status = pci_enable_msi(pdev);
-		if (status != 0)
-			dev_err(&pdev->dev,
-				"Error %d setting up MSI; falling back to xPIC\n",
-				status);
-		else
-			mgp->msi_enabled = 1;
-	}
-
-	status = request_irq(pdev->irq, myri10ge_intr, IRQF_SHARED,
-			     netdev->name, mgp);
-	if (status != 0) {
-		dev_err(&pdev->dev, "failed to allocate IRQ\n");
-		goto abort_with_firmware;
-	}
-
 	pci_set_drvdata(pdev, mgp);
 	if ((myri10ge_initial_mtu + ETH_HLEN) > MYRI10GE_MAX_ETHER_MTU)
 		myri10ge_initial_mtu = MYRI10GE_MAX_ETHER_MTU - ETH_HLEN;
@@ -2913,8 +2930,7 @@
 		dev_err(&pdev->dev, "register_netdev failed: %d\n", status);
 		goto abort_with_state;
 	}
-	dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
-		 (mgp->msi_enabled ? "MSI" : "xPIC"),
+	dev_info(dev, "%d, tx bndry %d, fw %s, WC %s\n",
 		 pdev->irq, mgp->tx.boundary, mgp->fw_name,
 		 (mgp->mtrr >= 0 ? "Enabled" : "Disabled"));
 
@@ -2922,9 +2938,6 @@
 
 abort_with_state:
 	myri10ge_restore_state(mgp);
-	free_irq(pdev->irq, mgp);
-	if (mgp->msi_enabled)
-		pci_disable_msi(pdev);
 
 abort_with_firmware:
 	myri10ge_dummy_rdma(mgp, 0);
@@ -2975,9 +2988,6 @@
 	flush_scheduled_work();
 	netdev = mgp->dev;
 	unregister_netdev(netdev);
-	free_irq(pdev->irq, mgp);
-	if (mgp->msi_enabled)
-		pci_disable_msi(pdev);
 
 	myri10ge_dummy_rdma(mgp, 0);
 


