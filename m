From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Fri, 4 Aug 2006 20:10:17 +1000
Message-ID: <20060804101017.GA17393@gondor.apana.org.au>
References: <E1G8dmn-0001hH-00@gondolin.me.apana.org.au> <Pine.WNT.4.63.0608030925100.3396@jbrandeb-desk.amr.corp.intel.com> <1154628302.3117.15.camel@rh4> <1154642918.5187.13.camel@jzny2> <1154650197.3117.32.camel@rh4> <20060804011027.GC12085@gondor.apana.org.au> <20060804083734.GA16082@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45585 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030329AbWHDKKm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 06:10:42 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <20060804083734.GA16082@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 04, 2006 at 06:37:34PM +1000, herbert wrote:
> 
> [NETDRV] e1000: Fix potential tx wake up race

Oops, I completely looked through netpoll_trap.  Hmm, someone should
really move the ifdef into netpoll_trap.  Stephen?

BTW, who uses netpoll_set_trap anyway? There seems to be no user in
the kernel tree.  Where's Adrian Bunk :)

[NETDRV] e1000: Fix potential tx wake up race

Jamal posted a patch which improved e1000 TX performance.  That in
turn spawned a discussion on potential tx wake up races caused by
the change.  During that discussion, Michael Chan posted the following
scenario (redrawn by me for e1000):

CPU0					CPU1
e1000_xmit_frame
	tx_lock
	if (tx_ring_empty)
					e1000_clean_tx_irq
						if (netif_queue_stopped)
							tx_lock
							netif_wake_queue
							tx_unlock
		netif_stop_queue
	tx_unlock

As you can see, even with the locks around netif_wake_queue this still
allows the race to occur because the netif_wake_queue code path is
conditional on netif_queue_stopped.

So here is a patch that uses the memory barriers rather than spin locks
to solve the problem.

First of all I've made netif_wake_queue independent of netif_queue_stopped.
This means that we operate on the stopped bit only once which closes a race
window.

Furthermore, netif_wake_queue itself is already a memory barrier because
it does a test_and_clear_bit.  This means that if the other side can
observe the netif_wake_queue then it can observe the extra room we've
made on the
queue.

On the e1000_xmit_frame side, I've changed netif_stop_queue into a new
function netif_test_and_stop_queue which does test_and_set_bit.  This
means that it also is a full memory barrier.

In order to close the race then, we simply recheck the tx queue size
if netif_test_and_stop_queue returns 0 indicating that the queue was
previously started.  There are two possibilities:

1) netif_wake_queue is about to occur.  In this case it doesn't really
matter what we do as netif_wake_queue will always wake the queue for us.
In the worst case, it'll wake up the queue with too little room but that's
really uncommon and we can cope with that anyway.

2) netif_wake_queue has just occured.  Because it is a memory barrier,
when we recheck the queue size we're guaranteed to see the new indices
which means that we'll see the extra room it has made for us.  As a
result we'll simply restart the queue.

The one wart in the patch is that we now have an unconditional atomic
operation in e1000_clean_tx_irq (netif_wake_queue).  If anyone can
think of a way to get rid of it without opening up the race, please
let us know.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 627f224..a22c01f 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2861,6 +2861,34 @@ e1000_transfer_dhcp_info(struct e1000_ad
 	return 0;
 }
 
+static int __e1000_maybe_stop_tx(struct net_device *netdev, int size)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
+
+	if (unlikely(netif_test_and_stop_queue(netdev)))
+		return -EBUSY;
+
+	/* netif_test_and_stop_queue acts as a memory barrier.
+	 * We need to check again in a case another CPU has just
+	 * made room available.
+	 */
+	if (likely(E1000_DESC_UNUSED(tx_ring) < size))
+		return -EBUSY;
+
+	/* A reprieve! */
+	netif_start_queue(netdev);
+	return 0;
+}
+
+static inline int e1000_maybe_stop_tx(struct net_device *netdev,
+				      struct e1000_tx_ring *tx_ring, int size)
+{
+	if (likely(E1000_DESC_UNUSED(tx_ring) >= size))
+		return 0;
+	return __e1000_maybe_stop_tx(netdev, size);
+}
+
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
 static int
 e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
@@ -2974,8 +3002,7 @@ #endif
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
-	if (unlikely(E1000_DESC_UNUSED(tx_ring) < count + 2)) {
-		netif_stop_queue(netdev);
+	if (unlikely(e1000_maybe_stop_tx(netdev, tx_ring, count + 2))) {
 		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
@@ -3022,8 +3049,7 @@ #endif
 	netdev->trans_start = jiffies;
 
 	/* Make sure there is space in the ring for the next send. */
-	if (unlikely(E1000_DESC_UNUSED(tx_ring) < MAX_SKB_FRAGS + 2))
-		netif_stop_queue(netdev);
+	e1000_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 2);
 
 	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 	return NETDEV_TX_OK;
@@ -3515,14 +3541,9 @@ #endif
 	tx_ring->next_to_clean = i;
 
 #define TX_WAKE_THRESHOLD 32
-	if (unlikely(cleaned && netif_queue_stopped(netdev) &&
-	             netif_carrier_ok(netdev))) {
-		spin_lock(&tx_ring->tx_lock);
-		if (netif_queue_stopped(netdev) &&
-		    (E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))
-			netif_wake_queue(netdev);
-		spin_unlock(&tx_ring->tx_lock);
-	}
+	if (unlikely(cleaned && netif_carrier_ok(netdev) &&
+		     E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD))
+		netif_wake_queue(netdev);
 
 	if (adapter->detect_tx_hung) {
 		/* Detect a transmit hang in hardware, this serializes the
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 75f02d8..c4b0de0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -657,6 +657,15 @@ static inline int netif_queue_stopped(co
 	return test_bit(__LINK_STATE_XOFF, &dev->state);
 }
 
+static inline int netif_test_and_stop_queue(struct net_device *dev)
+{
+#ifdef CONFIG_NETPOLL_TRAP
+	if (netpoll_trap())
+		return netif_queue_stopped(dev);
+#endif
+	return test_and_set_bit(__LINK_STATE_XOFF, &dev->state);
+}
+
 static inline int netif_running(const struct net_device *dev)
 {
 	return test_bit(__LINK_STATE_START, &dev->state);
