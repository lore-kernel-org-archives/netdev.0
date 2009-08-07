From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: improve parity error detection and recovery
Date: Fri, 07 Aug 2009 22:44:22 +0200
Message-ID: <4A7C9226.80401@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1782 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752682AbZHGVJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2009 17:09:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improve myri10ge parity error detection and recovery:
1) Don't restore PCI config space to a rebooted NIC until AFTER the
   host is quiescent.
2) Let myri10ge_close() know the NIC is dead, so it won't waste time
   waiting for a dead nic to respond to MXGEFW_CMD_ETHERNET_DOWN
3) When the NIC is quiet (link down, or otherwise idle link) use
   a pci config space read to detect a rebooted NIC.  Otherwise
   we might never notice that a NIC rebooted

Signed-off-by: Andrew Gallatin <gallatin@myri.com>
Signed-off-by: Brice Goglin <brice@myri.com>

diff -ur /home/bgoglin/src/git/net-next-2.6/drivers/net/myri10ge/myri10ge.c linux-tmp/drivers/net/myri10ge/myri10ge.c
--- net-next-2.6/drivers/net/myri10ge/myri10ge.c	2009-07-22 14:39:45.000000000 +0200
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2009-08-07 22:30:05.000000000 +0200
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.5.0-1.418"
+#define MYRI10GE_VERSION_STR "1.5.0-1.432"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -188,6 +188,7 @@
 	dma_addr_t fw_stats_bus;
 	int watchdog_tx_done;
 	int watchdog_tx_req;
+	int watchdog_rx_done;
 #ifdef CONFIG_MYRI10GE_DCA
 	int cached_dca_tag;
 	int cpu;
@@ -256,6 +257,7 @@
 	u32 link_changes;
 	u32 msg_enable;
 	unsigned int board_number;
+	int rebooted;
 };
 
 static char *myri10ge_fw_unaligned = "myri10ge_ethp_z8e.dat";
@@ -2552,17 +2554,22 @@
 	netif_carrier_off(dev);
 
 	netif_tx_stop_all_queues(dev);
-	old_down_cnt = mgp->down_cnt;
-	mb();
-	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_DOWN, &cmd, 0);
-	if (status)
-		printk(KERN_ERR "myri10ge: %s: Couldn't bring down link\n",
-		       dev->name);
-
-	wait_event_timeout(mgp->down_wq, old_down_cnt != mgp->down_cnt, HZ);
-	if (old_down_cnt == mgp->down_cnt)
-		printk(KERN_ERR "myri10ge: %s never got down irq\n", dev->name);
+	if (mgp->rebooted == 0) {
+		old_down_cnt = mgp->down_cnt;
+		mb();
+		status =
+		    myri10ge_send_cmd(mgp, MXGEFW_CMD_ETHERNET_DOWN, &cmd, 0);
+		if (status)
+			printk(KERN_ERR
+			       "myri10ge: %s: Couldn't bring down link\n",
+			       dev->name);
 
+		wait_event_timeout(mgp->down_wq, old_down_cnt != mgp->down_cnt,
+				   HZ);
+		if (old_down_cnt == mgp->down_cnt)
+			printk(KERN_ERR "myri10ge: %s never got down irq\n",
+			       dev->name);
+	}
 	netif_tx_disable(dev);
 	myri10ge_free_irq(mgp);
 	for (i = 0; i < mgp->num_slices; i++)
@@ -3427,12 +3434,13 @@
 	    container_of(work, struct myri10ge_priv, watchdog_work);
 	struct myri10ge_tx_buf *tx;
 	u32 reboot;
-	int status;
+	int status, rebooted;
 	int i;
 	u16 cmd, vendor;
 
 	mgp->watchdog_resets++;
 	pci_read_config_word(mgp->pdev, PCI_COMMAND, &cmd);
+	rebooted = 0;
 	if ((cmd & PCI_COMMAND_MASTER) == 0) {
 		/* Bus master DMA disabled?  Check to see
 		 * if the card rebooted due to a parity error
@@ -3444,9 +3452,12 @@
 		       myri10ge_reset_recover ? " " : " not");
 		if (myri10ge_reset_recover == 0)
 			return;
-
+		rtnl_lock();
+		mgp->rebooted = 1;
+		rebooted = 1;
+		myri10ge_close(mgp->dev);
 		myri10ge_reset_recover--;
-
+		mgp->rebooted = 0;
 		/*
 		 * A rebooted nic will come back with config space as
 		 * it was after power was applied to PCIe bus.
@@ -3494,8 +3505,10 @@
 		}
 	}
 
-	rtnl_lock();
-	myri10ge_close(mgp->dev);
+	if (!rebooted) {
+		rtnl_lock();
+		myri10ge_close(mgp->dev);
+	}
 	status = myri10ge_load_firmware(mgp, 1);
 	if (status != 0)
 		printk(KERN_ERR "myri10ge: %s: failed to load firmware\n",
@@ -3516,12 +3529,14 @@
 {
 	struct myri10ge_priv *mgp;
 	struct myri10ge_slice_state *ss;
-	int i, reset_needed;
+	int i, reset_needed, busy_slice_cnt;
 	u32 rx_pause_cnt;
+	u16 cmd;
 
 	mgp = (struct myri10ge_priv *)arg;
 
 	rx_pause_cnt = ntohl(mgp->ss[0].fw_stats->dropped_pause);
+	busy_slice_cnt = 0;
 	for (i = 0, reset_needed = 0;
 	     i < mgp->num_slices && reset_needed == 0; ++i) {
 
@@ -3559,8 +3574,22 @@
 				reset_needed = 1;
 			}
 		}
+		if (ss->watchdog_tx_done != ss->tx.done ||
+		    ss->watchdog_rx_done != ss->rx_done.cnt) {
+			busy_slice_cnt++;
+		}
 		ss->watchdog_tx_done = ss->tx.done;
 		ss->watchdog_tx_req = ss->tx.req;
+		ss->watchdog_rx_done = ss->rx_done.cnt;
+	}
+	/* if we've sent or received no traffic, poll the NIC to
+	 * ensure it is still there.  Otherwise, we risk not noticing
+	 * an error in a timely fashion */
+	if (busy_slice_cnt == 0) {
+		pci_read_config_word(mgp->pdev, PCI_COMMAND, &cmd);
+		if ((cmd & PCI_COMMAND_MASTER) == 0) {
+			reset_needed = 1;
+		}
 	}
 	mgp->watchdog_pause = rx_pause_cnt;
 


