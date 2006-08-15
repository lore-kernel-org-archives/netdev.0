From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 2/3] myri10ge: allow to disable link status change reporting
Date: Tue, 15 Aug 2006 08:46:22 -0400
Message-ID: <44E1C21E.2080308@myri.com>
References: <44E0DA08.9080304@myri.com> <44E0F0C1.8000408@myri.com> <44E0F2F6.7020403@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:2224 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S965086AbWHOMqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 08:46:43 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44E0F2F6.7020403@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> Brice Goglin wrote:
>> Add myri10ge_verbose module parameter to disable reporting of
>> link status change since some Ethernet switches seem to generate
>> a lot of status changes under some circumstances and some people
>> want to avoid useless flooding in the logs.
>>
>> Also add a counter for link status changes to statistics.
>>
>> Signed-off-by: Brice Goglin <brice@myri.com>
>
> NAK - use the standard netif_msg_xxx and the msg_enable style variable
> found in many drivers.  No need for a module parameter, ethtool
> already covers this type of need.

Oh right, didn't know that, thanks.
Actually, most of the drivers I looked at also define an additional
module parameter "debug" (to initialize their "msg_enable") :) I
copied-pasted and did the same in the following patch. Would it be ok?
Once this is commited, we will probably use the other netif_msg_xxx()
later to disable/enable some other messages.

>From Brice Goglin <brice@myri.com>

[PATCH] myri10ge: use netif_msg_link

Add msg_enable and use netif_msg_link to enable/disable reporting
of link status changes since some Ethernet switches seem to generate
a lot of status changes under some circumstances and some people
want to avoid useless flooding in the logs.

Also add a counter for link status changes to statistics.
---
 drivers/net/myri10ge/myri10ge.c |   46 +++++++++++++++++++++++++++++++++-------
 1 file changed, 39 insertions(+), 7 deletions(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-08-14 21:48:14.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-08-14 22:13:17.000000000 -0400
@@ -192,6 +192,8 @@
 	u32 read_dma;
 	u32 write_dma;
 	u32 read_write_dma;
+	u32 link_changes;
+	u32 msg_enable;
 };
 
 static char *myri10ge_fw_unaligned = "myri10ge_ethp_z8e.dat";
@@ -257,6 +259,12 @@
 MODULE_PARM_DESC(myri10ge_max_irq_loops,
 		 "Set stuck legacy IRQ detection threshold\n");
 
+#define MYRI10GE_MSG_DEFAULT NETIF_MSG_LINK
+
+static int myri10ge_debug = -1;		/* defaults above */
+module_param(myri10ge_debug, int, 0);
+MODULE_PARM_DESC(myri10ge_debug, "Debug level (0=none,...,16=all)");
+
 #define MYRI10GE_FW_OFFSET 1024*1024
 #define MYRI10GE_HIGHPART_TO_U32(X) \
 (sizeof (X) == 8) ? ((u32)((u64)(X) >> 32)) : (0)
@@ -764,6 +772,7 @@
 	mgp->rx_small.cnt = 0;
 	mgp->rx_done.idx = 0;
 	mgp->rx_done.cnt = 0;
+	mgp->link_changes = 0;
 	status = myri10ge_update_mac_address(mgp, mgp->dev->dev_addr);
 	myri10ge_change_promisc(mgp, 0, 0);
 	myri10ge_change_pause(mgp, mgp->pause);
@@ -1085,13 +1094,19 @@
 		if (mgp->link_state != stats->link_up) {
 			mgp->link_state = stats->link_up;
 			if (mgp->link_state) {
-				printk(KERN_INFO "myri10ge: %s: link up\n",
-				       mgp->dev->name);
+				if (netif_msg_link(mgp))
+					printk(KERN_INFO
+					       "myri10ge: %s: link up\n",
+					       mgp->dev->name);
 				netif_carrier_on(mgp->dev);
+				mgp->link_changes++;
 			} else {
-				printk(KERN_INFO "myri10ge: %s: link down\n",
-				       mgp->dev->name);
+				if (netif_msg_link(mgp))
+					printk(KERN_INFO
+					       "myri10ge: %s: link down\n",
+					       mgp->dev->name);
 				netif_carrier_off(mgp->dev);
+				mgp->link_changes++;
 			}
 		}
 		if (mgp->rdma_tags_available !=
@@ -1293,8 +1308,9 @@
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
 
@@ -1345,6 +1361,7 @@
 	data[i++] = (unsigned int)mgp->stop_queue;
 	data[i++] = (unsigned int)mgp->watchdog_resets;
 	data[i++] = (unsigned int)mgp->tx_linearized;
+	data[i++] = (unsigned int)mgp->link_changes;
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->link_up);
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_link_overflow);
 	data[i++] =
@@ -1355,6 +1372,18 @@
 	data[i++] = (unsigned int)ntohl(mgp->fw_stats->dropped_no_big_buffer);
 }
 
+static void myri10ge_set_msglevel(struct net_device *netdev, u32 value)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	mgp->msg_enable = value;
+}
+
+static u32 myri10ge_get_msglevel(struct net_device *netdev)
+{
+	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	return mgp->msg_enable;
+}
+
 static struct ethtool_ops myri10ge_ethtool_ops = {
 	.get_settings = myri10ge_get_settings,
 	.get_drvinfo = myri10ge_get_drvinfo,
@@ -1375,7 +1404,9 @@
 #endif
 	.get_strings = myri10ge_get_strings,
 	.get_stats_count = myri10ge_get_stats_count,
-	.get_ethtool_stats = myri10ge_get_ethtool_stats
+	.get_ethtool_stats = myri10ge_get_ethtool_stats,
+	.set_msglevel = myri10ge_set_msglevel,
+	.get_msglevel = myri10ge_get_msglevel
 };
 
 static int myri10ge_allocate_rings(struct net_device *dev)
@@ -2580,6 +2611,7 @@
 	mgp->csum_flag = MXGEFW_FLAGS_CKSUM;
 	mgp->pause = myri10ge_flow_control;
 	mgp->intr_coal_delay = myri10ge_intr_coal_delay;
+	mgp->msg_enable = netif_msg_init(myri10ge_debug, MYRI10GE_MSG_DEFAULT);
 	init_waitqueue_head(&mgp->down_wq);
 
 	if (pci_enable_device(pdev)) {


