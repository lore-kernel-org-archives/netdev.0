From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [1/2] [NET] link_watch: Move link watch list into net_device
Date: Tue, 08 May 2007 13:19:33 -0700
Message-ID: <4640DB55.1050608@goop.org>
References: <20070504232051.411946839@goop.org> <20070504232121.492190579@goop.org> <20070505091624.GA8890@infradead.org> <463C56D3.8060609@goop.org> <20070505102305.GA12771@gondor.apana.org.au> <463F95C3.60407@goop.org> <20070508121322.GA21647@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@infradead.org>, Andi Kleen <ak@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	virtualization@lists.osdl.org, lkml <linux-kernel@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Stephen Hemminger <shemminge@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:56767 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968261AbXEHUTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 16:19:44 -0400
In-Reply-To: <20070508121322.GA21647@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Sorry, I had forgotten that I've already concluded previously that
> this doesn't work because we don't want to prevent the interface
> from being brought up (and other reasons).  My memory is failing me :)
>
> So I think the best option now is to get rid of the delay on carrier
> on events for everyone.
>   

Sounds good to me.  So I'll use this change instead.

Subject: xen: go back to using normal network stack carriers

This effectively reverts xen-unstable change
14280:42b29f084c31. Herbert has changed the behaviour of the core
networking to not delay an initial down->up transition, and so the
timing concern has been solved.

Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>

diff -r 282bef511e66 drivers/net/xen-netfront.c
--- a/drivers/net/xen-netfront.c	Tue May 08 13:11:18 2007 -0700
+++ b/drivers/net/xen-netfront.c	Tue May 08 13:14:47 2007 -0700
@@ -95,7 +95,6 @@ struct netfront_info {
 
 	unsigned int evtchn;
 	unsigned int copying_receiver;
-	unsigned int carrier;
 
 	/* Receive-ring batched refills. */
 #define RX_MIN_TARGET 8
@@ -142,15 +141,6 @@ struct netfront_rx_info {
 };
 
 /*
- * Implement our own carrier flag: the network stack's version causes delays
- * when the carrier is re-enabled (in particular, dev_activate() may not
- * immediately be called, which can cause packet loss).
- */
-#define netfront_carrier_on(netif)	((netif)->carrier = 1)
-#define netfront_carrier_off(netif)	((netif)->carrier = 0)
-#define netfront_carrier_ok(netif)	((netif)->carrier)
-
-/*
  * Access macros for acquiring freeing slots in tx_skbs[].
  */
 
@@ -241,7 +231,7 @@ static void xennet_alloc_rx_buffers(stru
 	int nr_flips;
 	struct xen_netif_rx_request *req;
 
-	if (unlikely(!netfront_carrier_ok(np)))
+	if (unlikely(!netif_carrier_ok(dev)))
 		return;
 
 	/*
@@ -380,7 +370,7 @@ static int xennet_open(struct net_device
 	memset(&np->stats, 0, sizeof(np->stats));
 
 	spin_lock_bh(&np->rx_lock);
-	if (netfront_carrier_ok(np)) {
+	if (netif_carrier_ok(dev)) {
 		xennet_alloc_rx_buffers(dev);
 		np->rx.sring->rsp_event = np->rx.rsp_cons + 1;
 		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
@@ -400,7 +390,7 @@ static void xennet_tx_buf_gc(struct net_
 	struct netfront_info *np = netdev_priv(dev);
 	struct sk_buff *skb;
 
-	BUG_ON(!netfront_carrier_ok(np));
+	BUG_ON(!netif_carrier_ok(dev));
 
 	do {
 		prod = np->tx.sring->rsp_prod;
@@ -540,7 +530,7 @@ static int xennet_start_xmit(struct sk_b
 
 	spin_lock_irq(&np->tx_lock);
 
-	if (unlikely(!netfront_carrier_ok(np) ||
+	if (unlikely(!netif_carrier_ok(dev) ||
 		     (frags > 1 && !xennet_can_sg(dev)) ||
 		     netif_needs_gso(dev, skb))) {
 		spin_unlock_irq(&np->tx_lock);
@@ -973,7 +963,7 @@ static int xennet_poll(struct net_device
 
 	spin_lock(&np->rx_lock);
 
-	if (unlikely(!netfront_carrier_ok(np))) {
+	if (unlikely(!netif_carrier_ok(dev))) {
 		spin_unlock(&np->rx_lock);
 		return 0;
 	}
@@ -1308,7 +1298,7 @@ static struct net_device * __devinit xen
 
 	np->netdev = netdev;
 
-	netfront_carrier_off(np);
+	netif_carrier_off(netdev);
 
 	return netdev;
 
@@ -1376,7 +1366,7 @@ static void xennet_disconnect_backend(st
 	/* Stop old i/f to prevent errors whilst we rebuild the state. */
 	spin_lock_bh(&info->rx_lock);
 	spin_lock_irq(&info->tx_lock);
-	netfront_carrier_off(info);
+	netif_carrier_off(info->netdev);
 	spin_unlock_irq(&info->tx_lock);
 	spin_unlock_bh(&info->rx_lock);
 
@@ -1440,7 +1430,7 @@ static irqreturn_t xennet_interrupt(int 
 
 	spin_lock_irqsave(&np->tx_lock, flags);
 
-	if (likely(netfront_carrier_ok(np))) {
+	if (likely(netif_carrier_ok(dev))) {
 		xennet_tx_buf_gc(dev);
 		/* Under tx_lock: protects access to rx shared-ring indexes. */
 		if (RING_HAS_UNCONSUMED_RESPONSES(&np->rx))
@@ -1728,7 +1718,7 @@ static int xennet_connect(struct net_dev
 	 * domain a kick because we've probably just requeued some
 	 * packets.
 	 */
-	netfront_carrier_on(np);
+	netif_carrier_on(np->netdev);
 	notify_remote_via_irq(np->netdev->irq);
 	xennet_tx_buf_gc(dev);
 	xennet_alloc_rx_buffers(dev);


