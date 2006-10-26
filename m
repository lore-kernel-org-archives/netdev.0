From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 6/8] netpoll retry cleanup
Date: Thu, 26 Oct 2006 15:46:54 -0700
Message-ID: <20061026225646.363340682@osdl.org>
References: <20061026225535.443288276@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15291 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423685AbWJZXBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:01:04 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=netpoll-retry-cleanup.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The netpoll beast was still not happy. If the beast got
clogged pipes, it tended to stare blankly off in space
for a long time.

The problem couldn't be completely fixed because the
beast talked with irq's disabled. But it could be made
less painful and shorter.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 include/linux/netpoll.h |    1 
 net/core/netpoll.c      |   71 ++++++++++++++++++++++--------------------------
 2 files changed, 33 insertions(+), 39 deletions(-)

--- linux-2.6.orig/net/core/netpoll.c
+++ linux-2.6/net/core/netpoll.c
@@ -34,12 +34,12 @@
 #define MAX_UDP_CHUNK 1460
 #define MAX_SKBS 32
 #define MAX_QUEUE_DEPTH (MAX_SKBS / 2)
-#define MAX_RETRIES 20000
 
 static struct sk_buff_head skb_pool;
 
 static atomic_t trapped;
 
+#define USEC_PER_POLL	50
 #define NETPOLL_RX_ENABLED  1
 #define NETPOLL_RX_DROP     2
 
@@ -72,6 +72,7 @@ static void queue_process(void *p)
 			schedule_delayed_work(&npinfo->tx_work, HZ/10);
 			return;
 		}
+
 		netif_tx_unlock_bh(dev);
 	}
 }
@@ -241,50 +242,44 @@ repeat:
 
 static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 {
-	int status;
-	struct netpoll_info *npinfo;
+	int status = NETDEV_TX_BUSY;
+	unsigned long tries;
+ 	struct net_device *dev = np->dev;
+ 	struct netpoll_info *npinfo = np->dev->npinfo;
+
+ 	if (!npinfo || !netif_running(dev) || !netif_device_present(dev)) {
+ 		__kfree_skb(skb);
+ 		return;
+ 	}
+
+	/* don't get messages out of order, and no recursion */
+	if ( !(np->drop == netpoll_queue && skb_queue_len(&npinfo->txq))
+	     && npinfo->poll_owner != smp_processor_id()
+	     && netif_tx_trylock(dev)) {
+
+		/* try until next clock tick */
+		for(tries = jiffies_to_usecs(1)/USEC_PER_POLL; tries > 0; --tries) {
+			if (!netif_queue_stopped(dev))
+				status = dev->hard_start_xmit(skb, dev);
 
-	if (!np || !np->dev || !netif_running(np->dev)) {
-		__kfree_skb(skb);
-		return;
-	}
+			if (status == NETDEV_TX_OK)
+				break;
+
+			/* tickle device maybe there is some cleanup */
+			netpoll_poll(np);
 
-	npinfo = np->dev->npinfo;
+			udelay(USEC_PER_POLL);
+		}
+		netif_tx_unlock(dev);
+	}
 
-	/* avoid recursion */
-	if (npinfo->poll_owner == smp_processor_id() ||
-	    np->dev->xmit_lock_owner == smp_processor_id()) {
+	if (status != NETDEV_TX_OK) {
+		/* requeue for later */
 		if (np->drop)
 			np->drop(skb);
 		else
 			__kfree_skb(skb);
-		return;
 	}
-
-	do {
-		npinfo->tries--;
-		netif_tx_lock(np->dev);
-
-		/*
-		 * network drivers do not expect to be called if the queue is
-		 * stopped.
-		 */
-		status = NETDEV_TX_BUSY;
-		if (!netif_queue_stopped(np->dev))
-			status = np->dev->hard_start_xmit(skb, np->dev);
-
-		netif_tx_unlock(np->dev);
-
-		/* success */
-		if(!status) {
-			npinfo->tries = MAX_RETRIES; /* reset */
-			return;
-		}
-
-		/* transmit busy */
-		netpoll_poll(np);
-		udelay(50);
-	} while (npinfo->tries > 0);
 }
 
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
@@ -640,7 +635,7 @@ int netpoll_setup(struct netpoll *np)
 		npinfo->rx_np = NULL;
 		spin_lock_init(&npinfo->poll_lock);
 		npinfo->poll_owner = -1;
-		npinfo->tries = MAX_RETRIES;
+
 		spin_lock_init(&npinfo->rx_lock);
 		skb_queue_head_init(&npinfo->arp_tx);
 		skb_queue_head_init(&npinfo->txq);
--- linux-2.6.orig/include/linux/netpoll.h
+++ linux-2.6/include/linux/netpoll.h
@@ -28,7 +28,6 @@ struct netpoll_info {
 	atomic_t refcnt;
 	spinlock_t poll_lock;
 	int poll_owner;
-	int tries;
 	int rx_flags;
 	spinlock_t rx_lock;
 	struct netpoll *rx_np; /* netpoll that registered an rx_hook */

--
Stephen Hemminger <shemminger@osdl.org>

