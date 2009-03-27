From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 04/30] appletalk: convert cops to internal net_device_stats
Date: Thu, 26 Mar 2009 18:11:18 -0700
Message-ID: <20090327011255.240441939@linux-foundation.org>
References: <20090327011114.169107105@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:39801 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753527AbZC0BXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 21:23:08 -0400
Content-Disposition: inline; filename=cop-stats.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/appletalk/cops.c	2009-03-21 12:36:56.000000000 -0700
+++ b/drivers/net/appletalk/cops.c	2009-03-26 17:04:03.622371138 -0700
@@ -171,7 +171,6 @@ static unsigned int cops_debug = COPS_DE
 
 struct cops_local
 {
-        struct net_device_stats stats;
         int board;			/* Holds what board type is. */
 	int nodeid;			/* Set to 1 once have nodeid. */
         unsigned char node_acquire;	/* Node ID when acquired. */
@@ -197,7 +196,6 @@ static int  cops_send_packet (struct sk_
 static void set_multicast_list (struct net_device *dev);
 static int  cops_ioctl (struct net_device *dev, struct ifreq *rq, int cmd);
 static int  cops_close (struct net_device *dev);
-static struct net_device_stats *cops_get_stats (struct net_device *dev);
 
 static void cleanup_card(struct net_device *dev)
 {
@@ -337,7 +335,6 @@ static int __init cops_probe1(struct net
 	dev->tx_timeout		= cops_timeout;
 	dev->watchdog_timeo	= HZ * 2;
 
-        dev->get_stats          = cops_get_stats;
 	dev->open               = cops_open;
         dev->stop               = cops_close;
         dev->do_ioctl           = cops_ioctl;
@@ -797,7 +794,7 @@ static void cops_rx(struct net_device *d
         {
                 printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n",
 			dev->name);
-                lp->stats.rx_dropped++;
+                dev->stats.rx_dropped++;
                 while(pkt_len--)        /* Discard packet */
                         inb(ioaddr);
                 spin_unlock_irqrestore(&lp->lock, flags);
@@ -819,7 +816,7 @@ static void cops_rx(struct net_device *d
         {
 		printk(KERN_WARNING "%s: Bad packet length of %d bytes.\n", 
 			dev->name, pkt_len);
-                lp->stats.tx_errors++;
+                dev->stats.tx_errors++;
                 dev_kfree_skb_any(skb);
                 return;
         }
@@ -836,7 +833,7 @@ static void cops_rx(struct net_device *d
         if(rsp_type != LAP_RESPONSE)
         {
                 printk(KERN_WARNING "%s: Bad packet type %d.\n", dev->name, rsp_type);
-                lp->stats.tx_errors++;
+                dev->stats.tx_errors++;
                 dev_kfree_skb_any(skb);
                 return;
         }
@@ -846,8 +843,8 @@ static void cops_rx(struct net_device *d
         skb_reset_transport_header(skb);    /* Point to data (Skip header). */
 
         /* Update the counters. */
-        lp->stats.rx_packets++;
-        lp->stats.rx_bytes += skb->len;
+        dev->stats.rx_packets++;
+        dev->stats.rx_bytes += skb->len;
 
         /* Send packet to a higher place. */
         netif_rx(skb);
@@ -858,7 +855,7 @@ static void cops_timeout(struct net_devi
         struct cops_local *lp = netdev_priv(dev);
         int ioaddr = dev->base_addr;
 
-	lp->stats.tx_errors++;
+	dev->stats.tx_errors++;
         if(lp->board==TANGENT)
         {
 		if((inb(ioaddr+TANG_CARD_STATUS)&TANG_TX_READY)==0)
@@ -916,8 +913,8 @@ static int cops_send_packet(struct sk_bu
 	spin_unlock_irqrestore(&lp->lock, flags);	/* Restore interrupts. */
 
 	/* Done sending packet, update counters and cleanup. */
-	lp->stats.tx_packets++;
-	lp->stats.tx_bytes += skb->len;
+	dev->stats.tx_packets++;
+	dev->stats.tx_bytes += skb->len;
 	dev->trans_start = jiffies;
 	dev_kfree_skb (skb);
         return 0;
@@ -986,15 +983,6 @@ static int cops_close(struct net_device 
         return 0;
 }
 
-/*
- *      Get the current statistics.
- *      This may be called with the card open or closed.
- */
-static struct net_device_stats *cops_get_stats(struct net_device *dev)
-{
-        struct cops_local *lp = netdev_priv(dev);
-        return &lp->stats;
-}
 
 #ifdef MODULE
 static struct net_device *cops_dev;


