From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH] netxen: drop redudant spinlock
Date: Fri, 27 Jul 2007 23:12:11 +0530 (IST)
Message-ID: <Pine.LNX.4.64.0707272257090.27724@stellar.unminc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:41256 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759372AbXG0Rsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 13:48:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some leftover code that makes use of adapter->lock in tx_timeout function,
which resets the interface under this lock. In close() when the workqueue
is flushed, prints the warning about sleeping with interrupts disabled
(when spinlock debug is enabled). The lock was required with private netxen
IOCTLs, which were removed a while ago.

Index: netdev-2.6/drivers/net/netxen/netxen_nic_main.c
===================================================================
--- netdev-2.6.orig/drivers/net/netxen/netxen_nic_main.c
+++ netdev-2.6/drivers/net/netxen/netxen_nic_main.c
@@ -335,7 +335,6 @@ netxen_nic_probe(struct pci_dev *pdev, c
 	adapter->ahw.pdev = pdev;
 	adapter->ahw.pci_func  = pci_func_id;
 	spin_lock_init(&adapter->tx_lock);
-	spin_lock_init(&adapter->lock);
 
 	/* remap phys address */
 	mem_base = pci_resource_start(pdev, 0);	/* 0 is for BAR 0 */
@@ -1228,15 +1227,12 @@ static void netxen_tx_timeout_task(struc
 {
 	struct netxen_adapter *adapter = 
 		container_of(work, struct netxen_adapter, tx_timeout_task);
-	unsigned long flags;
 
 	printk(KERN_ERR "%s %s: transmit timeout, resetting.\n",
 	       netxen_nic_driver_name, adapter->netdev->name);
 
-	spin_lock_irqsave(&adapter->lock, flags);
 	netxen_nic_close(adapter->netdev);
 	netxen_nic_open(adapter->netdev);
-	spin_unlock_irqrestore(&adapter->lock, flags);
 	adapter->netdev->trans_start = jiffies;
 	netif_wake_queue(adapter->netdev);
 }
