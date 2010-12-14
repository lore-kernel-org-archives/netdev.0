From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 08/12] cxgb4: remove the name field from the adapter structure
Date: Tue, 14 Dec 2010 12:18:12 -0800
Message-ID: <1292357896-14339-9-git-send-email-dm@chelsio.com>
References: <1292357896-14339-1-git-send-email-dm@chelsio.com>
 <1292357896-14339-2-git-send-email-dm@chelsio.com>
 <1292357896-14339-3-git-send-email-dm@chelsio.com>
 <1292357896-14339-4-git-send-email-dm@chelsio.com>
 <1292357896-14339-5-git-send-email-dm@chelsio.com>
 <1292357896-14339-6-git-send-email-dm@chelsio.com>
 <1292357896-14339-7-git-send-email-dm@chelsio.com>
 <1292357896-14339-8-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12173 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759843Ab0LNU0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 15:26:39 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBEKQcRK031245
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 12:26:38 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBEKIHaG014464
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 12:18:17 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBEKIHeJ014463
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 12:18:17 -0800
In-Reply-To: <1292357896-14339-8-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove a field the driver uses to keep track of the name of the first
netdev it manages to register.  Do this by changing the registration
loop to stop the first time it fails so the first registered device is
trivial to tell.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h      |    1 -
 drivers/net/cxgb4/cxgb4_main.c |   37 +++++++++++++++----------------------
 2 files changed, 15 insertions(+), 23 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index f3d9f64..9caf95f 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -486,7 +486,6 @@ struct adapter {
 	unsigned int fn;
 	unsigned int flags;
 
-	const char *name;
 	int msg_enable;
 
 	struct adapter_params params;
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index ba9a67a..3db21d1 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -525,10 +525,11 @@ static void name_msix_vecs(struct adapter *adap)
 	int i, j, msi_idx = 2, n = sizeof(adap->msix_info[0].desc);
 
 	/* non-data interrupts */
-	snprintf(adap->msix_info[0].desc, n, "%s", adap->name);
+	snprintf(adap->msix_info[0].desc, n, "%s", adap->port[0]->name);
 
 	/* FW events */
-	snprintf(adap->msix_info[1].desc, n, "%s-FWeventq", adap->name);
+	snprintf(adap->msix_info[1].desc, n, "%s-FWeventq",
+		 adap->port[0]->name);
 
 	/* Ethernet queues */
 	for_each_port(adap, j) {
@@ -543,11 +544,11 @@ static void name_msix_vecs(struct adapter *adap)
 	/* offload queues */
 	for_each_ofldrxq(&adap->sge, i)
 		snprintf(adap->msix_info[msi_idx].desc, n, "%s-ofld%d",
-			 adap->name, i);
+			 adap->port[0]->name, i);
 
 	for_each_rdmarxq(&adap->sge, i)
 		snprintf(adap->msix_info[msi_idx].desc, n, "%s-rdma%d",
-			 adap->name, i);
+			 adap->port[0]->name, i);
 }
 
 static int request_msix_queue_irqs(struct adapter *adap)
@@ -2664,7 +2665,7 @@ static int cxgb_up(struct adapter *adap)
 	} else {
 		err = request_irq(adap->pdev->irq, t4_intr_handler(adap),
 				  (adap->flags & USING_MSI) ? 0 : IRQF_SHARED,
-				  adap->name, adap);
+				  adap->port[0]->name, adap);
 		if (err)
 			goto irq_err;
 	}
@@ -3627,7 +3628,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 	adapter->pdev_dev = &pdev->dev;
 	adapter->fn = func;
-	adapter->name = pci_name(pdev);
 	adapter->msg_enable = dflt_msg_enable;
 	memset(adapter->chan_map, 0xff, sizeof(adapter->chan_map));
 
@@ -3724,26 +3724,19 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 		err = register_netdev(adapter->port[i]);
 		if (err)
-			dev_warn(&pdev->dev,
-				 "cannot register net device %s, skipping\n",
-				 adapter->port[i]->name);
-		else {
-			/*
-			 * Change the name we use for messages to the name of
-			 * the first successfully registered interface.
-			 */
-			if (!adapter->registered_device_map)
-				adapter->name = adapter->port[i]->name;
-
-			__set_bit(i, &adapter->registered_device_map);
-			adapter->chan_map[pi->tx_chan] = i;
-			print_port_info(adapter->port[i]);
-		}
+			break;
+		__set_bit(i, &adapter->registered_device_map);
+		adapter->chan_map[pi->tx_chan] = i;
+		print_port_info(adapter->port[i]);
 	}
-	if (!adapter->registered_device_map) {
+	if (i == 0) {
 		dev_err(&pdev->dev, "could not register any net devices\n");
 		goto out_free_dev;
 	}
+	if (err) {
+		dev_warn(&pdev->dev, "only %d net devices registered\n", i);
+		err = 0;
+	};
 
 	if (cxgb4_debugfs_root) {
 		adapter->debugfs_root = debugfs_create_dir(pci_name(pdev),
-- 
1.5.4

