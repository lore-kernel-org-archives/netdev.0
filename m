From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 05/11] netpoll: dont need rx_flags
Date: Sat, 03 Nov 2007 11:43:19 -0700
Message-ID: <20071103184338.692312004@linux-foundation.org>
References: <20071103184314.216145305@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54734 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758136AbXKCXgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:36:41 -0400
Content-Disposition: inline; filename=netpoll-enable-flag.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rx_flags variable is redundant. Turning rx on/off is done
via setting the rx_np pointer.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/include/linux/netpoll.h	2007-11-03 09:32:54.000000000 -0700
+++ b/include/linux/netpoll.h	2007-11-03 09:35:45.000000000 -0700
@@ -25,7 +25,6 @@ struct netpoll {
 
 struct netpoll_info {
 	atomic_t refcnt;
-	int rx_flags;
 	spinlock_t rx_lock;
 	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
 	struct sk_buff_head arp_tx; /* list of arp requests to reply to */
@@ -51,12 +50,11 @@ static inline int netpoll_rx(struct sk_b
 	unsigned long flags;
 	int ret = 0;
 
-	if (!npinfo || (!npinfo->rx_np && !npinfo->rx_flags))
+	if (!npinfo || !npinfo->rx_np)
 		return 0;
 
 	spin_lock_irqsave(&npinfo->rx_lock, flags);
-	/* check rx_flags again with the lock held */
-	if (npinfo->rx_flags && __netpoll_rx(skb))
+	if (__netpoll_rx(skb))
 		ret = 1;
 	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 
--- a/net/core/netpoll.c	2007-11-03 09:33:31.000000000 -0700
+++ b/net/core/netpoll.c	2007-11-03 09:35:45.000000000 -0700
@@ -39,7 +39,6 @@ static struct sk_buff_head skb_pool;
 static atomic_t trapped;
 
 #define USEC_PER_POLL	50
-#define NETPOLL_RX_ENABLED  1
 
 #define MAX_SKB_SIZE \
 		(MAX_UDP_CHUNK + sizeof(struct udphdr) + \
@@ -675,7 +674,6 @@ int netpoll_setup(struct netpoll *np)
 			goto release;
 		}
 
-		npinfo->rx_flags = 0;
 		npinfo->rx_np = NULL;
 
 		spin_lock_init(&npinfo->rx_lock);
@@ -757,7 +755,6 @@ int netpoll_setup(struct netpoll *np)
 
 	if (np->rx_hook) {
 		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
 		npinfo->rx_np = np;
 		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 	}
@@ -799,7 +796,6 @@ void netpoll_cleanup(struct netpoll *np)
 			if (npinfo->rx_np == np) {
 				spin_lock_irqsave(&npinfo->rx_lock, flags);
 				npinfo->rx_np = NULL;
-				npinfo->rx_flags &= ~NETPOLL_RX_ENABLED;
 				spin_unlock_irqrestore(&npinfo->rx_lock, flags);
 			}
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

