From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/3] myri10ge: allow to disable link status change reporting
Date: Mon, 14 Aug 2006 17:53:05 -0400
Message-ID: <44E0F0C1.8000408@myri.com>
References: <44E0DA08.9080304@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:39910 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1752065AbWHNVxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:53:16 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44E0DA08.9080304@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add myri10ge_verbose module parameter to disable reporting of
link status change since some Ethernet switches seem to generate
a lot of status changes under some circumstances and some people
want to avoid useless flooding in the logs.

Also add a counter for link status changes to statistics.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-08-14 14:22:07.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-08-14 14:30:50.000000000 -0400
@@ -192,6 +192,7 @@
 	u32 read_dma;
 	u32 write_dma;
 	u32 read_write_dma;
+	u32 link_changes;
 };
 
 static char *myri10ge_fw_unaligned = "myri10ge_ethp_z8e.dat";
@@ -257,6 +258,10 @@
 MODULE_PARM_DESC(myri10ge_max_irq_loops,
 		 "Set stuck legacy IRQ detection threshold\n");
 
+static int myri10ge_verbose = 1;
+module_param(myri10ge_verbose, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(myri10ge_verbose, "Enable verbose printing\n");
+
 #define MYRI10GE_FW_OFFSET 1024*1024
 #define MYRI10GE_HIGHPART_TO_U32(X) \
 (sizeof (X) == 8) ? ((u32)((u64)(X) >> 32)) : (0)
@@ -764,6 +769,7 @@
 	mgp->rx_small.cnt = 0;
 	mgp->rx_done.idx = 0;
 	mgp->rx_done.cnt = 0;
+	mgp->link_changes = 0;
 	status = myri10ge_update_mac_address(mgp, mgp->dev->dev_addr);
 	myri10ge_change_promisc(mgp, 0, 0);
 	myri10ge_change_pause(mgp, mgp->pause);
@@ -1085,13 +1091,19 @@
 		if (mgp->link_state != stats->link_up) {
 			mgp->link_state = stats->link_up;
 			if (mgp->link_state) {
-				printk(KERN_INFO "myri10ge: %s: link up\n",
-				       mgp->dev->name);
+				if (myri10ge_verbose)
+					printk(KERN_INFO
+					       "myri10ge: %s: link up\n",
+					       mgp->dev->name);
 				netif_carrier_on(mgp->dev);
+				mgp->link_changes++;
 			} else {
-				printk(KERN_INFO "myri10ge: %s: link down\n",
-				       mgp->dev->name);
+				if (myri10ge_verbose)
+					printk(KERN_INFO
+					       "myri10ge: %s: link down\n",
+					       mgp->dev->name);
 				netif_carrier_off(mgp->dev);
+				mgp->link_changes++;
 			}
 		}
 		if (mgp->rdma_tags_available !=
@@ -1293,8 +1305,9 @@
 	"serial_number", "tx_pkt_start", "tx_pkt_done",
 	"tx_req", "tx_done", "rx_small_cnt", "rx_big_cnt",
 	"wake_queue", "stop_queue", "watchdog_resets", "tx_linearized",
-	"link_up", "dropped_link_overflow", "dropped_link_error_or_filtered",
-	"dropped_runt", "dropped_overrun", "dropped_no_small_buffer",
+	"link_changes", "link_up", "dropped_link_overflow",
+	"dropped_link_error_or_filtered", "dropped_runt",
+	"dropped_overrun", "dropped_no_small_buffer",
 	"dropped_no_big_buffer"
 };
 
@@ -1345,6 +1358,7 @@
 	data[i++] = (unsigned int)mgp->stop_queue;
 	data[i++] = (unsigned int)mgp->watchdog_resets;
 	data[i++] = (unsigned int)mgp->tx_linearized;
+	data[i++] = (unsigned int)mgp->link_changes;
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->link_up);
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_link_overflow);
 	data[i++] =


