From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH] 3c589_cs: re-initialize the multicast in the tc589_reset
Date: Mon, 20 Jul 2009 08:08:12 +0900
Message-ID: <20090720080812.49633622.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg502.nifty.com ([202.248.238.82]:59764 "EHLO
	userg502.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751821AbZGSXIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jul 2009 19:08:21 -0400
Received: from localhost.localdomain (eaoska170254.adsl.ppp.infoweb.ne.jp [219.116.19.254])by userg502.nifty.com with SMTP id n6JN8HFF000380
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2009 08:08:17 +0900
In-Reply-To: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


3c589_cs: 
re-initialize the multicast in the tc589_reset,
and spin_lock the set_multicast_list function.  

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.31-rc3/drivers/net/pcmcia/3c589_cs.c.orig	2009-07-19 19:13:10.000000000 +0900
+++ linux-2.6.31-rc3/drivers/net/pcmcia/3c589_cs.c	2009-07-19 19:26:40.000000000 +0900
@@ -156,6 +156,7 @@ static struct net_device_stats *el3_get_
 static int el3_rx(struct net_device *dev);
 static int el3_close(struct net_device *dev);
 static void el3_tx_timeout(struct net_device *dev);
+static void set_rx_mode(struct net_device *dev);
 static void set_multicast_list(struct net_device *dev);
 static const struct ethtool_ops netdev_ethtool_ops;
 
@@ -488,8 +489,7 @@ static void tc589_reset(struct net_devic
     /* Switch to register set 1 for normal use. */
     EL3WINDOW(1);
 
-    /* Accept b-cast and phys addr only. */
-    outw(SetRxFilter | RxStation | RxBroadcast, ioaddr + EL3_CMD);
+    set_rx_mode(dev);
     outw(StatsEnable, ioaddr + EL3_CMD); /* Turn on statistics. */
     outw(RxEnable, ioaddr + EL3_CMD); /* Enable the receiver. */
     outw(TxEnable, ioaddr + EL3_CMD); /* Enable transmitter. */
@@ -700,7 +700,7 @@ static irqreturn_t el3_interrupt(int irq
 		if (fifo_diag & 0x2000) {
 		    /* Rx underrun */
 		    tc589_wait_for_completion(dev, RxReset);
-		    set_multicast_list(dev);
+    		    set_rx_mode(dev);
 		    outw(RxEnable, ioaddr + EL3_CMD);
 		}
 		outw(AckIntr | AdapterFailure, ioaddr + EL3_CMD);
@@ -905,14 +905,11 @@ static int el3_rx(struct net_device *dev
     return 0;
 }
 
-static void set_multicast_list(struct net_device *dev)
+static void set_rx_mode(struct net_device *dev)
 {
-    struct el3_private *lp = netdev_priv(dev);
-    struct pcmcia_device *link = lp->p_dev;
     unsigned int ioaddr = dev->base_addr;
     u16 opts = SetRxFilter | RxStation | RxBroadcast;
 
-    if (!pcmcia_dev_present(link)) return;
     if (dev->flags & IFF_PROMISC)
 	opts |= RxMulticast | RxProm;
     else if (dev->mc_count || (dev->flags & IFF_ALLMULTI))
@@ -920,6 +917,16 @@ static void set_multicast_list(struct ne
     outw(opts, ioaddr + EL3_CMD);
 }
 
+static void set_multicast_list(struct net_device *dev)
+{
+    struct el3_private *priv = netdev_priv(dev);
+    unsigned long flags;
+
+    spin_lock_irqsave(&priv->lock, flags);    
+    set_rx_mode(dev);
+    spin_unlock_irqrestore(&priv->lock, flags);    
+}
+
 static int el3_close(struct net_device *dev)
 {
     struct el3_private *lp = netdev_priv(dev);
