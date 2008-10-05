From: Arjan van de Ven <arjan@infradead.org>
Subject: [patch] uniquify the tx_timeout name
Date: Sun, 5 Oct 2008 10:35:05 -0700
Message-ID: <20081005103505.03313c9e@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54596 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838AbYJERfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 13:35:11 -0400
Received: from c-71-193-193-226.hsd1.or.comcast.net ([71.193.193.226] helo=localhost.localdomain)
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1KmXVc-0002lj-Vm
	for netdev@vger.kernel.org; Sun, 05 Oct 2008 17:35:09 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

there's several drivers that have use "tx_timeout" for the .. tx timeout function.
All fine with that, they're static, however for doing stats on how often which driver
hits the timeout it's a tad unfortunate. The patch below gives the ones I found
in the kerneloops.org database unique names.

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>


diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index 3c1364d..b455ae9 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -431,7 +431,7 @@ static void getlinktype(struct net_device *dev);
 static void getlinkstatus(struct net_device *dev);
 static void netdev_timer(unsigned long data);
 static void reset_timer(unsigned long data);
-static void tx_timeout(struct net_device *dev);
+static void fealnx_tx_timeout(struct net_device *dev);
 static void init_ring(struct net_device *dev);
 static int start_tx(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t intr_handler(int irq, void *dev_instance);
@@ -658,7 +658,7 @@ static int __devinit fealnx_init_one(struct pci_dev *pdev,
 	dev->set_multicast_list = &set_rx_mode;
 	dev->do_ioctl = &mii_ioctl;
 	dev->ethtool_ops = &netdev_ethtool_ops;
-	dev->tx_timeout = &tx_timeout;
+	dev->tx_timeout = &fealnx_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	err = register_netdev(dev);
@@ -1198,7 +1198,7 @@ static void reset_timer(unsigned long data)
 }
 
 
-static void tx_timeout(struct net_device *dev)
+static void fealnx_tx_timeout(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem *ioaddr = np->mem;
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index b238ed0..f7fa394 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -612,7 +612,7 @@ static void undo_cable_magic(struct net_device *dev);
 static void check_link(struct net_device *dev);
 static void netdev_timer(unsigned long data);
 static void dump_ring(struct net_device *dev);
-static void tx_timeout(struct net_device *dev);
+static void ns_tx_timeout(struct net_device *dev);
 static int alloc_ring(struct net_device *dev);
 static void refill_rx(struct net_device *dev);
 static void init_ring(struct net_device *dev);
@@ -920,7 +920,7 @@ static int __devinit natsemi_probe1 (struct pci_dev *pdev,
 	dev->set_multicast_list = &set_rx_mode;
 	dev->change_mtu = &natsemi_change_mtu;
 	dev->do_ioctl = &netdev_ioctl;
-	dev->tx_timeout = &tx_timeout;
+	dev->tx_timeout = &ns_tx_timeout;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1875,7 +1875,7 @@ static void dump_ring(struct net_device *dev)
 	}
 }
 
-static void tx_timeout(struct net_device *dev)
+static void ns_tx_timeout(struct net_device *dev)
 {
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
@@ -3232,7 +3232,7 @@ static void __devexit natsemi_remove1 (struct pci_dev *pdev)
  * suspend/resume synchronization:
  * entry points:
  *   netdev_open, netdev_close, netdev_ioctl, set_rx_mode, intr_handler,
- *   start_tx, tx_timeout
+ *   start_tx, ns_tx_timeout
  *
  * No function accesses the hardware without checking np->hands_off.
  *	the check occurs under spin_lock_irq(&np->lock);
diff --git a/drivers/net/pcmcia/xirc2ps_cs.c b/drivers/net/pcmcia/xirc2ps_cs.c
index f6c4698..c33a3d5 100644
--- a/drivers/net/pcmcia/xirc2ps_cs.c
+++ b/drivers/net/pcmcia/xirc2ps_cs.c
@@ -353,7 +353,7 @@ typedef struct local_info_t {
  * Some more prototypes
  */
 static int do_start_xmit(struct sk_buff *skb, struct net_device *dev);
-static void do_tx_timeout(struct net_device *dev);
+static void xirc_tx_timeout(struct net_device *dev);
 static void xirc2ps_tx_timeout_task(struct work_struct *work);
 static struct net_device_stats *do_get_stats(struct net_device *dev);
 static void set_addresses(struct net_device *dev);
@@ -590,7 +590,7 @@ xirc2ps_probe(struct pcmcia_device *link)
     dev->open = &do_open;
     dev->stop = &do_stop;
 #ifdef HAVE_TX_TIMEOUT
-    dev->tx_timeout = do_tx_timeout;
+    dev->tx_timeout = xirc_tx_timeout;
     dev->watchdog_timeo = TX_TIMEOUT;
     INIT_WORK(&local->tx_timeout_task, xirc2ps_tx_timeout_task);
 #endif
@@ -1335,7 +1335,7 @@ xirc2ps_tx_timeout_task(struct work_struct *work)
 }
 
 static void
-do_tx_timeout(struct net_device *dev)
+xirc_tx_timeout(struct net_device *dev)
 {
     local_info_t *lp = netdev_priv(dev);
     lp->stats.tx_errors++;

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
