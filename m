From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 22/22] ne2k: convert to net_device_ops
Date: Fri, 21 Nov 2008 15:22:00 -0800
Message-ID: <20081121232240.762641910@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57079 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755411AbYKUXXj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:39 -0500
Content-Disposition: inline; filename=ne2k.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert driver to new net_device_ops. Compile tested only.
This required some additional work to export common code ei_XXX.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/8390.h     |    4 ++++
 drivers/net/lib8390.c  |   15 ++++++++-------
 drivers/net/ne2k-pci.c |   19 ++++++++++++++-----
 3 files changed, 26 insertions(+), 12 deletions(-)

--- a/drivers/net/8390.h	2008-11-21 15:01:21.000000000 -0800
+++ b/drivers/net/8390.h	2008-11-21 15:01:53.000000000 -0800
@@ -33,6 +33,11 @@ extern void ei_poll(struct net_device *d
 extern void eip_poll(struct net_device *dev);
 #endif
 
+extern void ei_tx_timeout(struct net_device *dev);
+extern int ei_start_xmit(struct sk_buff *skb, struct net_device *dev);
+extern void ei_set_multicast_list(struct net_device *dev);
+extern struct net_device_stats *ei_get_stats(struct net_device *dev);
+
 /* Without I/O delay - non ISA or later chips */
 extern void NS8390_init(struct net_device *dev, int startp);
 extern int ei_open(struct net_device *dev);
--- a/drivers/net/lib8390.c	2008-11-21 15:01:21.000000000 -0800
+++ b/drivers/net/lib8390.c	2008-11-21 15:11:11.000000000 -0800
@@ -108,14 +108,13 @@ int ei_debug = 1;
 /* Index to functions. */
 static void ei_tx_intr(struct net_device *dev);
 static void ei_tx_err(struct net_device *dev);
-static void ei_tx_timeout(struct net_device *dev);
+void ei_tx_timeout(struct net_device *dev);
 static void ei_receive(struct net_device *dev);
 static void ei_rx_overrun(struct net_device *dev);
 
 /* Routines generic to NS8390-based boards. */
 static void NS8390_trigger_send(struct net_device *dev, unsigned int length,
 								int start_page);
-static void set_multicast_list(struct net_device *dev);
 static void do_set_multicast_list(struct net_device *dev);
 static void __NS8390_init(struct net_device *dev, int startp);
 
@@ -208,8 +207,10 @@ static int __ei_open(struct net_device *
 
 	/* The card I/O part of the driver (e.g. 3c503) can hook a Tx timeout
 	    wrapper that does e.g. media check & then calls ei_tx_timeout. */
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
 	if (dev->tx_timeout == NULL)
 		 dev->tx_timeout = ei_tx_timeout;
+#endif
 	if (dev->watchdog_timeo <= 0)
 		 dev->watchdog_timeo = TX_TIMEOUT;
 
@@ -258,7 +259,7 @@ static int __ei_close(struct net_device 
  * completed (or failed) - i.e. never posted a Tx related interrupt.
  */
 
-static void ei_tx_timeout(struct net_device *dev)
+void ei_tx_timeout(struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
@@ -295,6 +296,7 @@ static void ei_tx_timeout(struct net_dev
 	enable_irq_lockdep(dev->irq);
 	netif_wake_queue(dev);
 }
+EXPORT_SYMBOL_GPL(ei_tx_timeout);
 
 /**
  * ei_start_xmit - begin packet transmission
@@ -304,7 +306,7 @@ static void ei_tx_timeout(struct net_dev
  * Sends a packet to an 8390 network device.
  */
 
-static int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
+int ei_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
@@ -421,6 +423,7 @@ static int ei_start_xmit(struct sk_buff 
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(ei_start_xmit);
 
 /**
  * ei_interrupt - handle the interrupts from an 8390
@@ -882,7 +885,7 @@ static void ei_rx_overrun(struct net_dev
  *	Collect the stats. This is called unlocked and from several contexts.
  */
 
-static struct net_device_stats *get_stats(struct net_device *dev)
+struct net_device_stats *ei_get_stats(struct net_device *dev)
 {
 	unsigned long ioaddr = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
@@ -901,6 +904,7 @@ static struct net_device_stats *get_stat
 
 	return &dev->stats;
 }
+EXPORT_SYMBOL_GPL(ei_get_stats);
 
 /*
  * Form the 64 bit 8390 multicast table from the linked list of addresses
@@ -991,7 +995,7 @@ static void do_set_multicast_list(struct
  *	not called too often. Must protect against both bh and irq users
  */
 
-static void set_multicast_list(struct net_device *dev)
+void ei_set_multicast_list(struct net_device *dev)
 {
 	unsigned long flags;
 	struct ei_device *ei_local = (struct ei_device*)netdev_priv(dev);
@@ -1000,6 +1004,7 @@ static void set_multicast_list(struct ne
 	do_set_multicast_list(dev);
 	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 }
+EXPORT_SYMBOL_GPL(ei_set_multicast_list);
 
 /**
  * ethdev_setup - init rest of 8390 device struct
@@ -1015,10 +1020,11 @@ static void ethdev_setup(struct net_devi
 	if (ei_debug > 1)
 		printk(version);
 
-	dev->hard_start_xmit = &ei_start_xmit;
-	dev->get_stats	= get_stats;
-	dev->set_multicast_list = &set_multicast_list;
-
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
+	dev->hard_start_xmit = ei_start_xmit;
+	dev->get_stats	= ei_get_stats;
+	dev->set_multicast_list = ei_set_multicast_list;
+#endif
 	ether_setup(dev);
 
 	spin_lock_init(&ei_local->page_lock);
--- a/drivers/net/ne2k-pci.c	2008-11-21 15:01:21.000000000 -0800
+++ b/drivers/net/ne2k-pci.c	2008-11-21 15:01:53.000000000 -0800
@@ -200,6 +200,19 @@ struct ne2k_pci_card {
   in the 'dev' and 'ei_status' structures.
 */
 
+static const struct net_device_ops ne2k_netdev_ops = {
+	.ndo_open		= ne2k_pci_open,
+	.ndo_stop		= ne2k_pci_close,
+	.ndo_start_xmit		= ei_start_xmit,
+	.ndo_tx_timeout		= ei_tx_timeout,
+	.ndo_get_stats		= ei_get_stats,
+	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller = ei_poll,
+#endif
+};
 
 static int __devinit ne2k_pci_init_one (struct pci_dev *pdev,
 				     const struct pci_device_id *ent)
@@ -265,6 +278,8 @@ static int __devinit ne2k_pci_init_one (
 		dev_err(&pdev->dev, "cannot allocate ethernet device\n");
 		goto err_out_free_res;
 	}
+	dev->netdev_ops = &ne2k_netdev_ops;
+
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/* Reset card. Who knows what dain-bramaged state it was left in. */
@@ -353,12 +368,8 @@ static int __devinit ne2k_pci_init_one (
 	ei_status.block_output = &ne2k_pci_block_output;
 	ei_status.get_8390_hdr = &ne2k_pci_get_8390_hdr;
 	ei_status.priv = (unsigned long) pdev;
-	dev->open = &ne2k_pci_open;
-	dev->stop = &ne2k_pci_close;
+
 	dev->ethtool_ops = &ne2k_pci_ethtool_ops;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = ei_poll;
-#endif
 	NS8390_init(dev, 0);
 
 	i = register_netdev(dev);

-- 

