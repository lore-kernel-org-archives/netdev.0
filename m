From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [XEN 1/2] [NET] front: Remove tx_full and unnecessary queue operations
Date: Wed, 17 May 2006 21:33:42 +1000
Message-ID: <20060517113342.GA7081@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:7428 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932181AbWEQLds
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 07:33:48 -0400
To: Xen Development Mailing List <xen-devel@lists.xensource.com>,
	netdev@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[NET] front: Remove tx_full and unnecessary queue operations

The tx_full variable merely mirrors information already present in
the XOFF bit on the net device.  The net device architecture itself
is quite mature and can be trusted by Xen to maintain its state
correctly.

Also, it's pointless to stop the queue in close_netdev since it can
be waken up anyway since there could be a softirq running on another
CPU.  All of this is handled by unregister_netdev anyway.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff -r 7cbc1fc8dbea -r 588516fce414 linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c
--- a/linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c	Tue May 16 19:54:41 2006 +0100
+++ b/linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c	Wed May 17 17:16:17 2006 +1000
@@ -81,7 +81,6 @@ struct netfront_info
 	struct net_device *netdev;
 
 	struct net_device_stats stats;
-	unsigned int tx_full;
 
 	netif_tx_front_ring_t tx;
 	netif_rx_front_ring_t rx;
@@ -506,10 +505,9 @@ static void network_tx_buf_gc(struct net
 	} while (prod != np->tx.sring->rsp_prod);
 
  out:
-	if ((np->tx_full) &&
+	if (unlikely(netif_queue_stopped(dev)) &&
 	    ((np->tx.sring->req_prod - prod) < NET_TX_RING_SIZE) &&
 	    !gnttab_empty_grant_references(&np->gref_tx_head)) {
-		np->tx_full = 0;
 		if (np->user_state == UST_OPEN)
 			netif_wake_queue(dev);
 	}
@@ -650,13 +648,6 @@ static int network_start_xmit(struct sk_
 	unsigned long mfn;
 	int notify;
 
-	if (unlikely(np->tx_full)) {
-		printk(KERN_ALERT "%s: full queue wasn't stopped!\n",
-		       dev->name);
-		netif_stop_queue(dev);
-		goto drop;
-	}
-
 	if (unlikely((((unsigned long)skb->data & ~PAGE_MASK) + skb->len) >=
 		     PAGE_SIZE)) {
 		struct sk_buff *nskb;
@@ -712,7 +703,6 @@ static int network_start_xmit(struct sk_
 
 	if (RING_FULL(&np->tx) ||
 	    gnttab_empty_grant_references(&np->gref_tx_head)) {
-		np->tx_full = 1;
 		netif_stop_queue(dev);
 	}
 
@@ -987,11 +977,8 @@ static void network_connect(struct net_d
 
 	/* Recovery procedure: */
 
-	/* Step 1: Reinitialise variables. */
-	np->tx_full = 0;
-
 	/*
-	 * Step 2: Rebuild the RX and TX ring contents.
+	 * Step 1: Rebuild the RX and TX ring contents.
 	 * NB. We could just free the queued TX packets now but we hope
 	 * that sending them out might do some good.  We have to rebuild
 	 * the RX ring because some of our pages are currently flipped out
@@ -1055,7 +1042,7 @@ static void network_connect(struct net_d
 	RING_PUSH_REQUESTS(&np->rx);
 
 	/*
-	 * Step 3: All public and private state should now be sane.  Get
+	 * Step 2: All public and private state should now be sane.  Get
 	 * ready to start sending and receiving packets and give the driver
 	 * domain a kick because we've probably just requeued some
 	 * packets.
@@ -1266,10 +1253,6 @@ static int netfront_remove(struct xenbus
 
 static void close_netdev(struct netfront_info *info)
 {
-	spin_lock_irq(&info->netdev->xmit_lock);
-	netif_stop_queue(info->netdev);
-	spin_unlock_irq(&info->netdev->xmit_lock);
-
 #ifdef CONFIG_PROC_FS
 	xennet_proc_delif(info->netdev);
 #endif
