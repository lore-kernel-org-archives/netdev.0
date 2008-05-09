From: Brice Goglin <brice@myri.com>
Subject: [PATCH 12/16] myri10ge: fix the number of interrupt slots
Date: Fri, 09 May 2008 02:20:47 +0200
Message-ID: <482398DF.8030901@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1856 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753818AbYEIAU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:20:27 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a long-standing bug/misunderstanding between the
driver and the firmware.  The size of the interrupt
queue must be set to the number of rx slots (big + small),
and it should never have been a tunable.
Setting it too small results in chaos.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:11:37.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:12:46.000000000 +0200
@@ -253,10 +253,6 @@
 module_param(myri10ge_ecrc_enable, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_ecrc_enable, "Enable Extended CRC on PCI-E");
 
-static int myri10ge_max_intr_slots = 1024;
-module_param(myri10ge_max_intr_slots, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_max_intr_slots, "Interrupt queue slots");
-
 static int myri10ge_small_bytes = -1;	/* -1 == auto */
 module_param(myri10ge_small_bytes, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_small_bytes, "Threshold of small packets");
@@ -879,7 +875,7 @@
 
 	/* Now exchange information about interrupts  */
 
-	bytes = myri10ge_max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
+	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
 	memset(mgp->ss.rx_done.entry, 0, bytes);
 	cmd.data0 = (u32) bytes;
 	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_SIZE, &cmd, 0);
@@ -1217,7 +1213,7 @@
 		rx_packets += rx_ok;
 		rx_bytes += rx_ok * (unsigned long)length;
 		cnt++;
-		idx = cnt & (myri10ge_max_intr_slots - 1);
+		idx = cnt & (mgp->max_intr_slots - 1);
 		work_done++;
 	}
 	rx_done->idx = idx;
@@ -3218,7 +3214,7 @@
 		netdev->dev_addr[i] = mgp->mac_addr[i];
 
 	/* allocate rx done ring */
-	bytes = myri10ge_max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
+	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
 	mgp->ss.rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
 						&mgp->ss.rx_done.bus, GFP_KERNEL);
 	if (mgp->ss.rx_done.entry == NULL)
@@ -3295,7 +3291,7 @@
 	myri10ge_dummy_rdma(mgp, 0);
 
 abort_with_rx_done:
-	bytes = myri10ge_max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
+	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
 	dma_free_coherent(&pdev->dev, bytes,
 			  mgp->ss.rx_done.entry, mgp->ss.rx_done.bus);
 
@@ -3346,7 +3342,7 @@
 	/* avoid a memory leak */
 	pci_restore_state(pdev);
 
-	bytes = myri10ge_max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
+	bytes = mgp->max_intr_slots * sizeof(*mgp->ss.rx_done.entry);
 	dma_free_coherent(&pdev->dev, bytes,
 			  mgp->ss.rx_done.entry, mgp->ss.rx_done.bus);
 


