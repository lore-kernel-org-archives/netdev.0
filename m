From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] netpoll: tx lock deadlock fix
Date: Tue, 29 May 2007 17:32:21 -0700
Message-ID: <20070529173221.5c2dd261@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:46716 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750924AbXE3Anp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 20:43:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If sky2 device poll routine is called from netpoll_send_skb, it
would deadlock. The netpoll_send_skb held the netif_tx_lock, and the
poll routine could acquire it to clean up skb's. Other drivers
might use same locking model.

The driver is correct, netpoll should not introduce more locking problems
than it causes already. So change the code to drop lock before calling
poll handler.

Signed-off-by: Stephen Hemminger <shemminger@linux.foundation.org>


--- a/net/core/netpoll.c	2007-05-08 14:19:32.000000000 -0700
+++ b/net/core/netpoll.c	2007-05-29 15:28:22.000000000 -0700
@@ -250,22 +250,23 @@ static void netpoll_send_skb(struct netp
 		unsigned long flags;
 
 		local_irq_save(flags);
-		if (netif_tx_trylock(dev)) {
-			/* try until next clock tick */
-			for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
-					tries > 0; --tries) {
+		/* try until next clock tick */
+		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
+		     tries > 0; --tries) {
+			if (netif_tx_trylock(dev)) {
 				if (!netif_queue_stopped(dev))
 					status = dev->hard_start_xmit(skb, dev);
+				netif_tx_unlock(dev);
 
 				if (status == NETDEV_TX_OK)
 					break;
 
-				/* tickle device maybe there is some cleanup */
-				netpoll_poll(np);
-
-				udelay(USEC_PER_POLL);
 			}
-			netif_tx_unlock(dev);
+
+			/* tickle device maybe there is some cleanup */
+			netpoll_poll(np);
+
+			udelay(USEC_PER_POLL);
 		}
 		local_irq_restore(flags);
 	}
