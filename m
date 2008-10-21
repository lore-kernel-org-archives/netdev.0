From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] e1000e: get rid of wasted space
Date: Mon, 20 Oct 2008 19:11:49 -0700
Message-ID: <20081020191149.1dbf8e3b@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56787 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752058AbYJUCLw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2008 22:11:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The name in the ring is only used once during setup so it shouldn't
be in the data structure.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/e1000e/e1000.h	2008-10-20 18:13:53.000000000 -0700
+++ b/drivers/net/e1000e/e1000.h	2008-10-20 18:18:30.000000000 -0700
@@ -153,7 +153,6 @@ struct e1000_ring {
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
 
-	char name[IFNAMSIZ + 5];
 	u32 ims_val;
 	u32 itr_val;
 	u16 itr_register;
--- a/drivers/net/e1000e/netdev.c	2008-10-20 18:19:22.000000000 -0700
+++ b/drivers/net/e1000e/netdev.c	2008-10-20 18:21:00.000000000 -0700
@@ -1473,27 +1473,20 @@ static int e1000_request_msix(struct e10
 {
 	struct net_device *netdev = adapter->netdev;
 	int err = 0, vector = 0;
+	char irqname[IFNAMSIZ+5];
 
-	if (strlen(netdev->name) < (IFNAMSIZ - 5))
-		sprintf(adapter->rx_ring->name, "%s-rx0", netdev->name);
-	else
-		memcpy(adapter->rx_ring->name, netdev->name, IFNAMSIZ);
+	snprintf(irqname, sizeof(irqname), "%s-rx0", netdev->name);
 	err = request_irq(adapter->msix_entries[vector].vector,
-			  &e1000_intr_msix_rx, 0, adapter->rx_ring->name,
-			  netdev);
+			  &e1000_intr_msix_rx, 0, irqname, netdev);
 	if (err)
 		goto out;
 	adapter->rx_ring->itr_register = E1000_EITR_82574(vector);
 	adapter->rx_ring->itr_val = adapter->itr;
 	vector++;
 
-	if (strlen(netdev->name) < (IFNAMSIZ - 5))
-		sprintf(adapter->tx_ring->name, "%s-tx0", netdev->name);
-	else
-		memcpy(adapter->tx_ring->name, netdev->name, IFNAMSIZ);
+	snprintf(irqname, sizeof(irqname), "%s-tx0", netdev->name);
 	err = request_irq(adapter->msix_entries[vector].vector,
-			  &e1000_intr_msix_tx, 0, adapter->tx_ring->name,
-			  netdev);
+			  &e1000_intr_msix_tx, 0, irqname, netdev);
 	if (err)
 		goto out;
 	adapter->tx_ring->itr_register = E1000_EITR_82574(vector);
