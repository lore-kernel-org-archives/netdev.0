From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 44/77] axnet: convert ot net_device_ops
Date: Fri, 20 Mar 2009 22:36:11 -0700
Message-ID: <20090321053715.870152738@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36641 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753848AbZCUFsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:18 -0400
Content-Disposition: inline; filename=axnet.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/pcmcia/axnet_cs.c	2009-03-20 16:06:45.275902397 -0700
+++ b/drivers/net/pcmcia/axnet_cs.c	2009-03-20 16:27:39.823027704 -0700
@@ -35,6 +35,7 @@
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/crc32.h>
 #include "../8390.h"
 
@@ -91,6 +92,10 @@ static void axnet_release(struct pcmcia_
 static int axnet_open(struct net_device *dev);
 static int axnet_close(struct net_device *dev);
 static int axnet_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+static int axnet_start_xmit(struct sk_buff *skb, struct net_device *dev);
+static struct net_device_stats *get_stats(struct net_device *dev);
+static void set_multicast_list(struct net_device *dev);
+static void axnet_tx_timeout(struct net_device *dev);
 static const struct ethtool_ops netdev_ethtool_ops;
 static irqreturn_t ei_irq_wrapper(int irq, void *dev_id);
 static void ei_watchdog(u_long arg);
@@ -108,7 +113,6 @@ static void block_output(struct net_devi
 
 static void axnet_detach(struct pcmcia_device *p_dev);
 
-static void axdev_setup(struct net_device *dev);
 static void AX88190_init(struct net_device *dev, int startp);
 static int ax_open(struct net_device *dev);
 static int ax_close(struct net_device *dev);
@@ -134,6 +138,19 @@ static inline axnet_dev_t *PRIV(struct n
 	return p;
 }
 
+static const struct net_device_ops axnet_netdev_ops = {
+	.ndo_open 		= axnet_open,
+	.ndo_stop		= axnet_close,
+	.ndo_do_ioctl		= axnet_ioctl,
+	.ndo_start_xmit		= axnet_start_xmit,
+	.ndo_tx_timeout		= axnet_tx_timeout,
+	.ndo_get_stats		= get_stats,
+	.ndo_set_multicast_list = set_multicast_list,
+	.ndo_change_mtu		= eth_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
+
 /*======================================================================
 
     axnet_attach() creates an "instance" of the driver, allocating
@@ -146,15 +163,17 @@ static int axnet_probe(struct pcmcia_dev
 {
     axnet_dev_t *info;
     struct net_device *dev;
+    struct ei_device *ei_local;
 
     DEBUG(0, "axnet_attach()\n");
 
-    dev = alloc_netdev(sizeof(struct ei_device) + sizeof(axnet_dev_t),
-			"eth%d", axdev_setup);
-
+    dev = alloc_etherdev(sizeof(struct ei_device) + sizeof(axnet_dev_t));
     if (!dev)
 	return -ENOMEM;
 
+    ei_local = netdev_priv(dev);
+    spin_lock_init(&ei_local->page_lock);
+
     info = PRIV(dev);
     info->p_dev = link;
     link->priv = dev;
@@ -163,10 +182,10 @@ static int axnet_probe(struct pcmcia_dev
     link->conf.Attributes = CONF_ENABLE_IRQ;
     link->conf.IntType = INT_MEMORY_AND_IO;
 
-    dev->open = &axnet_open;
-    dev->stop = &axnet_close;
-    dev->do_ioctl = &axnet_ioctl;
+    dev->netdev_ops = &axnet_netdev_ops;
+
     SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
+    dev->watchdog_timeo = TX_TIMEOUT;
 
     return axnet_config(link);
 } /* axnet_attach */
@@ -905,14 +924,12 @@ int ei_debug = 1;
 /* Index to functions. */
 static void ei_tx_intr(struct net_device *dev);
 static void ei_tx_err(struct net_device *dev);
-static void axnet_tx_timeout(struct net_device *dev);
 static void ei_receive(struct net_device *dev);
 static void ei_rx_overrun(struct net_device *dev);
 
 /* Routines generic to NS8390-based boards. */
 static void NS8390_trigger_send(struct net_device *dev, unsigned int length,
 								int start_page);
-static void set_multicast_list(struct net_device *dev);
 static void do_set_multicast_list(struct net_device *dev);
 
 /*
@@ -954,15 +971,6 @@ static int ax_open(struct net_device *de
 	unsigned long flags;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
 
-#ifdef HAVE_TX_TIMEOUT
-	/* The card I/O part of the driver (e.g. 3c503) can hook a Tx timeout
-	    wrapper that does e.g. media check & then calls axnet_tx_timeout. */
-	if (dev->tx_timeout == NULL)
-		 dev->tx_timeout = axnet_tx_timeout;
-	if (dev->watchdog_timeo <= 0)
-		 dev->watchdog_timeo = TX_TIMEOUT;
-#endif
-
 	/*
 	 *	Grab the page lock so we own the register set, then call
 	 *	the init function.
@@ -1701,30 +1709,6 @@ static void set_multicast_list(struct ne
 	spin_unlock_irqrestore(&dev_lock(dev), flags);
 }	
 
-/**
- * axdev_setup - init rest of 8390 device struct
- * @dev: network device structure to init
- *
- * Initialize the rest of the 8390 device structure.  Do NOT __init
- * this, as it is used by 8390 based modular drivers too.
- */
-
-static void axdev_setup(struct net_device *dev)
-{
-	struct ei_device *ei_local;
-	if (ei_debug > 1)
-		printk(version_8390);
-    
-	ei_local = (struct ei_device *)netdev_priv(dev);
-	spin_lock_init(&ei_local->page_lock);
-    
-	dev->hard_start_xmit = &axnet_start_xmit;
-	dev->get_stats	= get_stats;
-	dev->set_multicast_list = &set_multicast_list;
-
-	ether_setup(dev);
-}
-
 /* This page of functions should be 8390 generic */
 /* Follow National Semi's recommendations for initializing the "NIC". */
 

-- 

