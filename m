From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/5] netpoll: cleanup transmit retry logic
Date: Mon, 23 Oct 2006 12:03:11 -0700
Message-ID: <20061023120311.0f23fcee@dxpl.pdx.osdl.net>
References: <20061020134826.75dd1cba@freekitty>
 <20061020.140149.125893169.davem@davemloft.net>
 <20061020153027.3bed8c86@dxpl.pdx.osdl.net>
 <20061022.204220.78710782.davem@davemloft.net>
 <20061023115337.1f636ffb@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49573 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965068AbWJWTEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2006 15:04:48 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061023115337.1f636ffb@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change netpoll transmit logic so:
 * retries are per attempt not global. don't want to start drop
   packets just because of temporary blockage.
 * acquire xmit_lock correctly
 * if device is not available just drop
 * always queue if send fails, don't drop

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- netpoll.orig/include/linux/netpoll.h
+++ netpoll/include/linux/netpoll.h
@@ -27,7 +27,6 @@ struct netpoll {
 struct netpoll_info {
 	spinlock_t poll_lock;
 	int poll_owner;
-	int tries;
 	int rx_flags;
 	spinlock_t rx_lock;
 	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
--- netpoll.orig/net/core/netpoll.c
+++ netpoll/net/core/netpoll.c
@@ -250,50 +250,42 @@ static struct sk_buff * find_skb(struct 
 
 static void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
 {
-	int status;
-	struct netpoll_info *npinfo;
-
-	if (!np || !np->dev || !netif_running(np->dev))
-		goto free_skb;
+	struct net_device *dev = np->dev;
+	int tries = MAX_RETRIES;
 
-	npinfo = np->dev->npinfo;
+	do {
+		int status;
 
-	/* avoid recursion */
-	if (npinfo->poll_owner == smp_processor_id() ||
-	    np->dev->xmit_lock_owner == smp_processor_id()) {
-		if (np->drop)
-			np->drop(skb);
-		else
+		/* if device is offline, give up */
+		if (!netif_running(dev) || !netif_device_present(dev)) {
 			__kfree_skb(skb);
-		return;
-	}
+			return;
+		}
 
-	do {
-		npinfo->tries--;
-		netif_tx_lock(np->dev);
+		/* grap tx lock, but avoid recursion problems */
+		if (!netif_tx_trylock(dev))
+			break;
+
+		/* drivers do not expect to be called if queue is stopped. */
+		if (netif_queue_stopped(dev))
+			status = NETDEV_TX_BUSY;
+		else
+			status = dev->hard_start_xmit(skb, dev);
+		netif_tx_unlock(dev);
 
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
+		/* succesfull send */
+		if (status == NETDEV_TX_OK)
 			return;
-		}
 
-		/* transmit busy */
+		/* transmit busy, maybe cleaning up will help */
 		netpoll_poll(np);
 		udelay(50);
-	} while (npinfo->tries > 0);
-free_skb:
-	__kfree_skb(skb);
+	} while (--tries > 0);
+
+	if (np->drop)
+		np->drop(skb);
+	else
+		__kfree_skb(skb);
 }
 
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len)
@@ -646,7 +638,7 @@ int netpoll_setup(struct netpoll *np)
 		npinfo->rx_np = NULL;
 		spin_lock_init(&npinfo->poll_lock);
 		npinfo->poll_owner = -1;
-		npinfo->tries = MAX_RETRIES;
+
 		spin_lock_init(&npinfo->rx_lock);
 		skb_queue_head_init(&npinfo->arp_tx);
 	} else


