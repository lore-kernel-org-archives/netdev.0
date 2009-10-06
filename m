From: Brice Goglin <brice@myri.com>
Subject: [PATCH net-next] myri10ge: add adaptive coalescing
Date: Tue, 06 Oct 2009 18:52:43 +0200
Message-ID: <4ACB75DB.4060003@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	"Andrew J. Gallatin" <gallatin@myri.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1943 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757325AbZJFR0T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2009 13:26:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for adaptive interrupt coalescing to the
myri10ge driver. It is based on the host periodically look at
statistics and update the NIC coalescing accordingly.

The NIC only provides packet throughput and we feel that it is a
better heuristics than the packet rate heuristics currently used
in ethtool. Also, assuming that the packet packet rate heuristics
uses what is actually sent on the wire when using TSO, it would be
much more expensive to implement correctly, as the driver would
need to calculate how many packets were sent.

Signed-off-by: Andrew Gallatin <gallatin@myri.com>
Signed-off-by: Brice Goglin <brice@myri.com>

--- linux-tmp.20091006.1050.49/drivers/net/myri10ge/myri10ge.c	2009-10-06 10:50:28.000000000 +0200
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2009-10-06 17:17:08.000000000 +0200
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.5.0-1.432"
+#define MYRI10GE_VERSION_STR "1.5.1-1.446"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -83,6 +83,7 @@
 MODULE_LICENSE("Dual BSD/GPL");
 
 #define MYRI10GE_MAX_ETHER_MTU 9014
+#define MYRI10GE_INTR_COAL_PERIOD 4
 
 #define MYRI10GE_ETH_STOPPED 0
 #define MYRI10GE_ETH_STOPPING 1
@@ -197,6 +198,15 @@
 	char irq_desc[32];
 };
 
+struct myri10ge_adapt_intr_coal {
+	int enabled;
+	int usecs;
+	int big_usecs;
+	unsigned long old_tx_bytes;
+	unsigned long old_rx_bytes;
+	struct timer_list timer;
+};
+
 struct myri10ge_priv {
 	struct myri10ge_slice_state *ss;
 	int tx_boundary;	/* boundary transmits cannot cross */
@@ -228,6 +238,7 @@
 	unsigned int rdma_tags_available;
 	int intr_coal_delay;
 	__be32 __iomem *intr_coal_delay_ptr;
+	struct myri10ge_adapt_intr_coal adapt_coal;
 	int mtrr;
 	int wc_enabled;
 	int down_cnt;
@@ -292,6 +303,16 @@
 module_param(myri10ge_intr_coal_delay, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_intr_coal_delay, "Interrupt coalescing delay");
 
+static int myri10ge_adapt_med_thresh = 8 * 1024 * 1024;
+module_param(myri10ge_adapt_med_thresh, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(myri10ge_adapt_med_thresh,
+		 "Low latency limit, in bytes per second");
+
+static int myri10ge_adapt_big_thresh = 256 * 1024 * 1024;
+module_param(myri10ge_adapt_big_thresh, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(myri10ge_adapt_big_thresh,
+		 "Bulk latency limit, in bytes per second");
+
 static int myri10ge_flow_control = 1;
 module_param(myri10ge_flow_control, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_flow_control, "Pause parameter");
@@ -1054,6 +1075,9 @@
 		ss->tx.stop_queue = 0;
 	}
 
+	mgp->adapt_coal.usecs = -1;
+	mgp->adapt_coal.old_rx_bytes = 0;
+	mgp->adapt_coal.old_tx_bytes = 0;
 	status = myri10ge_update_mac_address(mgp, mgp->dev->dev_addr);
 	myri10ge_change_pause(mgp, mgp->pause);
 	myri10ge_set_multicast_list(mgp->dev);
@@ -1648,6 +1672,7 @@
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
 
 	coal->rx_coalesce_usecs = mgp->intr_coal_delay;
+	coal->use_adaptive_rx_coalesce = mgp->adapt_coal.enabled;
 	return 0;
 }
 
@@ -1655,6 +1680,20 @@
 myri10ge_set_coalesce(struct net_device *netdev, struct ethtool_coalesce *coal)
 {
 	struct myri10ge_priv *mgp = netdev_priv(netdev);
+	struct myri10ge_adapt_intr_coal *adapt = &mgp->adapt_coal;
+
+	if (coal->use_adaptive_rx_coalesce != adapt->enabled) {
+		adapt->enabled = coal->use_adaptive_rx_coalesce;
+		if (adapt->enabled) {
+			adapt->big_usecs = mgp->intr_coal_delay;
+			adapt->timer.expires =
+			    jiffies + HZ / MYRI10GE_INTR_COAL_PERIOD;
+			if (mgp->running)
+				add_timer(&adapt->timer);
+		} else {
+			del_timer_sync(&adapt->timer);
+		}
+	}
 
 	mgp->intr_coal_delay = coal->rx_coalesce_usecs;
 	put_be32(htonl(mgp->intr_coal_delay), mgp->intr_coal_delay_ptr);
@@ -2515,6 +2554,11 @@
 	mgp->running = MYRI10GE_ETH_RUNNING;
 	mgp->watchdog_timer.expires = jiffies + myri10ge_watchdog_timeout * HZ;
 	add_timer(&mgp->watchdog_timer);
+	if (mgp->adapt_coal.enabled) {
+		mgp->adapt_coal.timer.expires =
+		    jiffies + HZ / MYRI10GE_INTR_COAL_PERIOD;
+		add_timer(&mgp->adapt_coal.timer);
+	}
 	netif_tx_wake_all_queues(dev);
 
 	return 0;
@@ -2548,6 +2592,7 @@
 		return 0;
 
 	del_timer_sync(&mgp->watchdog_timer);
+	del_timer_sync(&mgp->adapt_coal.timer);
 	mgp->running = MYRI10GE_ETH_STOPPING;
 	for (i = 0; i < mgp->num_slices; i++) {
 		napi_disable(&mgp->ss[i].napi);
@@ -3009,6 +3054,46 @@
 	return stats;
 }
 
+static void myri10ge_intr_coal_timer(unsigned long arg)
+{
+	struct myri10ge_priv *mgp = (struct myri10ge_priv *)arg;
+	struct net_device_stats *stats = &mgp->stats;
+	struct myri10ge_adapt_intr_coal *adapt = &mgp->adapt_coal;
+	unsigned long bytes_per_sec, bytes, usecs;
+	unsigned long tx_bytes, rx_bytes;
+
+	if (adapt->enabled == 0)
+		return;
+
+	/* snapshot stats */
+	(void)myri10ge_get_stats(mgp->dev);
+
+	tx_bytes = stats->tx_bytes;
+	rx_bytes = stats->rx_bytes;
+
+	/* calculate bytes since last snapshot */
+	bytes = tx_bytes - adapt->old_tx_bytes;
+	bytes += rx_bytes - adapt->old_rx_bytes;
+
+	/* store snapshot for next time */
+	adapt->old_tx_bytes = tx_bytes;
+	adapt->old_rx_bytes = rx_bytes;
+
+	bytes_per_sec = bytes * MYRI10GE_INTR_COAL_PERIOD;
+	if (bytes_per_sec < myri10ge_adapt_med_thresh)
+		usecs = 0;
+	else if (bytes_per_sec < myri10ge_adapt_big_thresh)
+		usecs = adapt->big_usecs / 5;
+	else
+		usecs = adapt->big_usecs;
+
+	if (adapt->usecs != usecs) {
+		adapt->usecs = usecs;
+		put_be32(htonl(usecs), mgp->intr_coal_delay_ptr);
+	}
+	mod_timer(&adapt->timer, jiffies + HZ / MYRI10GE_INTR_COAL_PERIOD);
+}
+
 static void myri10ge_set_multicast_list(struct net_device *dev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
@@ -3969,6 +4054,8 @@
 	/* Setup the watchdog timer */
 	setup_timer(&mgp->watchdog_timer, myri10ge_watchdog_timer,
 		    (unsigned long)mgp);
+	setup_timer(&mgp->adapt_coal.timer, myri10ge_intr_coal_timer,
+		    (unsigned long)mgp);
 
 	spin_lock_init(&mgp->stats_lock);
 	SET_ETHTOOL_OPS(netdev, &myri10ge_ethtool_ops);


