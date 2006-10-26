From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/8] netpoll deferred transmit path
Date: Thu, 26 Oct 2006 15:46:53 -0700
Message-ID: <20061026225646.186971212@osdl.org>
References: <20061026225535.443288276@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12730 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1945981AbWJZXAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:00:00 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=netpoll-defer-tx.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the netpoll beast got busy, he tended to babble.
Instead of talking out of his large mouth as normal,
he tended to try to snort out other orifices. This lead
to words (skbs) ending up in odd places (like NIT) that
he did not intend.

The normal way of talking wouldn't work, but he could
at least change to using the same tone all the time.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 net/core/netpoll.c |   21 +++++++++++++++++++--
 1 file changed, 19 insertions(+), 2 deletions(-)

--- linux-2.6.orig/net/core/netpoll.c
+++ linux-2.6/net/core/netpoll.c
@@ -55,9 +55,25 @@ static void queue_process(void *p)
 	struct netpoll_info *npinfo = p;
 	struct sk_buff *skb;
 
-	while ((skb = skb_dequeue(&npinfo->txq)))
-		dev_queue_xmit(skb);
+	while ((skb = skb_dequeue(&npinfo->txq))) {
+		struct net_device *dev = skb->dev;
 
+		if (!netif_device_present(dev) || !netif_running(dev)) {
+			__kfree_skb(skb);
+			continue;
+		}
+
+		netif_tx_lock_bh(dev);
+		if (netif_queue_stopped(dev) ||
+		    dev->hard_start_xmit(skb, dev) != NETDEV_TX_OK) {
+			skb_queue_head(&npinfo->txq, skb);
+			netif_tx_unlock_bh(dev);
+
+			schedule_delayed_work(&npinfo->tx_work, HZ/10);
+			return;
+		}
+		netif_tx_unlock_bh(dev);
+	}
 }
 
 void netpoll_queue(struct sk_buff *skb)
@@ -756,6 +772,7 @@ void netpoll_cleanup(struct netpoll *np)
 			if (atomic_dec_and_test(&npinfo->refcnt)) {
 				skb_queue_purge(&npinfo->arp_tx);
  				skb_queue_purge(&npinfo->txq);
+				cancel_rearming_delayed_work(&npinfo->tx_work);
  				flush_scheduled_work();
 
 				kfree(npinfo);

--
Stephen Hemminger <shemminger@osdl.org>

