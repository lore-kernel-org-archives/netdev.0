From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [XEN 2/2] [NET] front: Replace user_state with netif_running
Date: Wed, 17 May 2006 21:34:57 +1000
Message-ID: <20060517113457.GA7144@gondor.apana.org.au>
References: <20060517113342.GA7081@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:15364 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932533AbWEQLe7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 07:34:59 -0400
To: Xen Development Mailing List <xen-devel@lists.xensource.com>,
	netdev@vger.kernel.org, Chris Wright <chrisw@sous-sol.org>
Content-Disposition: inline
In-Reply-To: <20060517113342.GA7081@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[NET] front: Replace user_state with netif_running

The user_state variable is simply replicating information that's already
present through netif_running.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff -r 588516fce414 -r 8cd36acf7609 linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c
--- a/linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c	Wed May 17 17:16:17 2006 +1000
+++ b/linux-2.6-xen-sparse/drivers/xen/netfront/netfront.c	Wed May 17 17:32:31 2006 +1000
@@ -97,11 +97,6 @@ struct netfront_info
 #define BEST_CONNECTED    2
 	unsigned int backend_state;
 
-	/* Is this interface open or closed (down or up)? */
-#define UST_CLOSED        0
-#define UST_OPEN          1
-	unsigned int user_state;
-
 	/* Receive-ring batched refills. */
 #define RX_MIN_TARGET 8
 #define RX_DFL_MIN_TARGET 64
@@ -445,8 +440,6 @@ static int network_open(struct net_devic
 	struct netfront_info *np = netdev_priv(dev);
 
 	memset(&np->stats, 0, sizeof(np->stats));
-
-	np->user_state = UST_OPEN;
 
 	network_alloc_rx_buffers(dev);
 	np->rx.sring->rsp_event = np->rx.rsp_cons + 1;
@@ -508,7 +501,7 @@ static void network_tx_buf_gc(struct net
 	if (unlikely(netif_queue_stopped(dev)) &&
 	    ((np->tx.sring->req_prod - prod) < NET_TX_RING_SIZE) &&
 	    !gnttab_empty_grant_references(&np->gref_tx_head)) {
-		if (np->user_state == UST_OPEN)
+		if (likely(netif_running(dev)))
 			netif_wake_queue(dev);
 	}
 }
@@ -730,7 +723,7 @@ static irqreturn_t netif_int(int irq, vo
 	spin_unlock_irqrestore(&np->tx_lock, flags);
 
 	if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx) &&
-	    (np->user_state == UST_OPEN))
+	    likely(netif_running(dev)))
 		netif_rx_schedule(dev);
 
 	return IRQ_HANDLED;
@@ -952,7 +945,6 @@ static int network_close(struct net_devi
 static int network_close(struct net_device *dev)
 {
 	struct netfront_info *np = netdev_priv(dev);
-	np->user_state = UST_CLOSED;
 	netif_stop_queue(np->netdev);
 	return 0;
 }
@@ -1051,7 +1043,7 @@ static void network_connect(struct net_d
 	notify_remote_via_irq(np->irq);
 	network_tx_buf_gc(dev);
 
-	if (np->user_state == UST_OPEN)
+	if (netif_running(dev))
 		netif_start_queue(dev);
 
 	spin_unlock(&np->rx_lock);
@@ -1065,7 +1057,7 @@ static void show_device(struct netfront_
 		IPRINTK("<vif handle=%u %s(%s) evtchn=%u tx=%p rx=%p>\n",
 			np->handle,
 			be_state_name[np->backend_state],
-			np->user_state ? "open" : "closed",
+			netif_running(np->netdev) ? "open" : "closed",
 			np->evtchn,
 			np->tx,
 			np->rx);
@@ -1116,7 +1108,6 @@ static int create_netdev(int handle, str
 
 	np                = netdev_priv(netdev);
 	np->backend_state = BEST_CLOSED;
-	np->user_state    = UST_CLOSED;
 	np->handle        = handle;
 	np->xbdev         = dev;
 
