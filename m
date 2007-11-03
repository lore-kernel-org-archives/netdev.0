From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 11/11] netpoll: rx use RCU
Date: Sat, 03 Nov 2007 11:43:25 -0700
Message-ID: <20071103184339.039313598@linux-foundation.org>
References: <20071103184314.216145305@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39942 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757618AbXKCXjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:39:15 -0400
Content-Disposition: inline; filename=netpoll-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get rid of rx_lock and use Read-Copy-Update to make sure
that netpoll info and rx handle are not used after free.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/include/linux/netpoll.h	2007-11-03 11:08:36.000000000 -0700
+++ b/include/linux/netpoll.h	2007-11-03 11:15:11.000000000 -0700
@@ -23,7 +23,6 @@ struct netpoll {
 
 struct netpoll_info {
 	atomic_t refcnt;
-	spinlock_t rx_lock;
 	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
 	struct sk_buff_head arp_tx; /* list of arp requests to reply to */
 	struct sk_buff_head txq;
--- a/net/core/netpoll.c	2007-11-03 11:08:36.000000000 -0700
+++ b/net/core/netpoll.c	2007-11-03 11:15:29.000000000 -0700
@@ -463,15 +463,15 @@ bool __netpoll_rx(struct sk_buff *skb)
 	int proto, len, ulen;
 	struct iphdr *iph;
 	struct udphdr *uh;
-	struct netpoll_info *npi = skb->dev->npinfo;
+	struct netpoll_info *npi;
 	struct netpoll *np;
-	unsigned long flags;
 
+	rcu_read_lock();
+	npi = rcu_dereference(skb->dev->npinfo);
 	if (!npi)
-		return false;
+		goto out;
 
-	spin_lock_irqsave(&npi->rx_lock, flags);
-	np = npi->rx_np;
+	np = rcu_dereference(npi->rx_np);
 	if (!np)
 		goto out;
 
@@ -535,13 +535,13 @@ bool __netpoll_rx(struct sk_buff *skb)
 	np->rx_hook(np, ntohs(uh->source),
 		    (char *)(uh+1),
 		    ulen - sizeof(struct udphdr));
-	spin_unlock_irqrestore(&npi->rx_lock, flags);
+	rcu_read_unlock();
 
 	kfree_skb(skb);
 	return true;
 
 out:
-	spin_unlock_irqrestore(&npi->rx_lock, flags);
+	rcu_read_unlock();
 	/* If packet received while already in poll then just
 	 * silently drop.
 	 */
@@ -678,7 +678,6 @@ int netpoll_setup(struct netpoll *np, st
 
 		npinfo->rx_np = NULL;
 
-		spin_lock_init(&npinfo->rx_lock);
 		skb_queue_head_init(&npinfo->arp_tx);
 		skb_queue_head_init(&npinfo->txq);
 		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
@@ -755,11 +754,8 @@ int netpoll_setup(struct netpoll *np, st
 		       HIPQUAD(np->local_ip));
 	}
 
-	if (np->rx_hook) {
-		spin_lock_irqsave(&npinfo->rx_lock, flags);
-		npinfo->rx_np = np;
-		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-	}
+	if (np->rx_hook)
+		rcu_assign_pointer(npinfo->rx_np, np);
 
 	/* fill up the skb queue */
 	refill_skbs();
@@ -794,21 +790,21 @@ void netpoll_cleanup(struct netpoll *np)
 	if (np->dev) {
 		npinfo = np->dev->npinfo;
 		if (npinfo) {
-			if (npinfo->rx_np == np) {
-				spin_lock_irqsave(&npinfo->rx_lock, flags);
-				npinfo->rx_np = NULL;
-				spin_unlock_irqrestore(&npinfo->rx_lock, flags);
-			}
+			if (npinfo->rx_np == np)
+				rcu_assign_pointer(npinfo->rx_np, NULL);
 
 			if (atomic_dec_and_test(&npinfo->refcnt)) {
+
 				skb_queue_purge(&npinfo->arp_tx);
 				skb_queue_purge(&npinfo->txq);
 				cancel_rearming_delayed_work(&npinfo->tx_work);
 
 				/* clean after last, unfinished work */
 				__skb_queue_purge(&npinfo->txq);
+
+				rcu_assign_pointer(np->dev->npinfo, NULL);
+				synchronize_net();
 				kfree(npinfo);
-				np->dev->npinfo = NULL;
 			}
 		}
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

