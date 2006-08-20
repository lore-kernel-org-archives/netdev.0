From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] xirc2ps_cs: Cannot reset card in atomic context
Date: Sun, 20 Aug 2006 21:51:57 +0100 (BST)
Message-ID: <20060820205157.F0F137B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout03-winn.ispmail.ntl.com ([81.103.221.49]:47136 "EHLO
	mtaout03-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751319AbWHTUvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 16:51:16 -0400
To: jeff@garzik.org
Cc: joerg@hydrops.han.de
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joerg Ahrens <joerg@hydrops.han.de>

I am using a Xircom CEM33 pcmcia NIC which has occasional hardware problems.
If the netdev watchdog detects a transmit timeout, do_reset is called which
msleeps - this is illegal in atomic context.

This patch schedules the timeout handling as a workqueue item.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

--- linux-2.6.17-gentoo-r4_orig/drivers/net/pcmcia/xirc2ps_cs.c	2006-07-28 18:47:14.000000000 +0200
+++ linux-2.6.17-gentoo-r4/drivers/net/pcmcia/xirc2ps_cs.c	2006-08-19 01:00:52.000000000 +0200
@@ -345,6 +345,7 @@
     void __iomem *dingo_ccr; /* only used for CEM56 cards */
     unsigned last_ptr_value; /* last packets transmitted value */
     const char *manf_str;
+    struct work_struct tx_timeout_task;
 } local_info_t;
 
 /****************
@@ -352,6 +353,7 @@
  */
 static int do_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static void do_tx_timeout(struct net_device *dev);
+static void xirc2ps_tx_timeout_task(void *data);
 static struct net_device_stats *do_get_stats(struct net_device *dev);
 static void set_addresses(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
@@ -589,6 +591,7 @@
 #ifdef HAVE_TX_TIMEOUT
     dev->tx_timeout = do_tx_timeout;
     dev->watchdog_timeo = TX_TIMEOUT;
+    INIT_WORK(&local->tx_timeout_task, xirc2ps_tx_timeout_task, dev);
 #endif
 
     return xirc2ps_config(link);
@@ -1341,17 +1344,24 @@
 /*====================================================================*/
 
 static void
-do_tx_timeout(struct net_device *dev)
+xirc2ps_tx_timeout_task(void *data)
 {
-    local_info_t *lp = netdev_priv(dev);
-    printk(KERN_NOTICE "%s: transmit timed out\n", dev->name);
-    lp->stats.tx_errors++;
+    struct net_device *dev = data;
     /* reset the card */
     do_reset(dev,1);
     dev->trans_start = jiffies;
     netif_wake_queue(dev);
 }
 
+static void
+do_tx_timeout(struct net_device *dev)
+{
+    local_info_t *lp = netdev_priv(dev);
+    lp->stats.tx_errors++;
+    printk(KERN_NOTICE "%s: transmit timed out\n", dev->name);
+    schedule_work(&lp->tx_timeout_task);
+}
+
 static int
 do_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
