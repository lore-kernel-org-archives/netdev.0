From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 7/8] netpoll queue cleanup
Date: Thu, 26 Oct 2006 15:46:55 -0700
Message-ID: <20061026225646.542975736@osdl.org>
References: <20061026225535.443288276@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:13499 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423683AbWJZXBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:01:03 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=netpoll-queue-clean.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The beast had a long and not very happy history. At one
point, a friend (netdump) had asked that he open up a little.
Well, the friend was long gone now, and the beast had
this dangling piece hanging (netpoll_queue).

It wasn't hard to stitch the netpoll_queue back in
where it belonged and make everything tidy.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 drivers/net/netconsole.c |    1 -
 include/linux/netpoll.h  |    4 ++--
 net/core/netpoll.c       |   23 +++--------------------
 3 files changed, 5 insertions(+), 23 deletions(-)

--- linux-2.6.orig/drivers/net/netconsole.c
+++ linux-2.6/drivers/net/netconsole.c
@@ -60,7 +60,6 @@ static struct netpoll np = {
 	.local_port = 6665,
 	.remote_port = 6666,
 	.remote_mac = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff},
-	.drop = netpoll_queue,
 };
 static int configured = 0;
 
--- linux-2.6.orig/include/linux/netpoll.h
+++ linux-2.6/include/linux/netpoll.h
@@ -18,7 +18,7 @@ struct netpoll {
 	struct net_device *dev;
 	char dev_name[16], *name;
 	void (*rx_hook)(struct netpoll *, int, char *, int);
-	void (*drop)(struct sk_buff *skb);
+
 	u32 local_ip, remote_ip;
 	u16 local_port, remote_port;
 	unsigned char local_mac[6], remote_mac[6];
@@ -44,7 +44,7 @@ int netpoll_trap(void);
 void netpoll_set_trap(int trap);
 void netpoll_cleanup(struct netpoll *np);
 int __netpoll_rx(struct sk_buff *skb);
-void netpoll_queue(struct sk_buff *skb);
+
 
 #ifdef CONFIG_NETPOLL
 static inline int netpoll_rx(struct sk_buff *skb)
--- linux-2.6.orig/net/core/netpoll.c
+++ linux-2.6/net/core/netpoll.c
@@ -77,19 +77,6 @@ static void queue_process(void *p)
 	}
 }
 
-void netpoll_queue(struct sk_buff *skb)
-{
-	struct net_device *dev = skb->dev;
-	struct netpoll_info *npinfo = dev->npinfo;
-
-	if (!npinfo)
-		kfree_skb(skb);
-	else {
-		skb_queue_tail(&npinfo->txq, skb);
-		schedule_work(&npinfo->tx_work);
-	}
-}
-
 static int checksum_udp(struct sk_buff *skb, struct udphdr *uh,
 			     unsigned short ulen, u32 saddr, u32 daddr)
 {
@@ -253,7 +240,7 @@ static void netpoll_send_skb(struct netp
  	}
 
 	/* don't get messages out of order, and no recursion */
-	if ( !(np->drop == netpoll_queue && skb_queue_len(&npinfo->txq))
+	if ( skb_queue_len(&npinfo->txq) == 0
 	     && npinfo->poll_owner != smp_processor_id()
 	     && netif_tx_trylock(dev)) {
 
@@ -274,11 +261,8 @@ static void netpoll_send_skb(struct netp
 	}
 
 	if (status != NETDEV_TX_OK) {
-		/* requeue for later */
-		if (np->drop)
-			np->drop(skb);
-		else
-			__kfree_skb(skb);
+		skb_queue_tail(&npinfo->txq, skb);
+		schedule_work(&npinfo->tx_work);
 	}
 }
 
@@ -800,4 +784,3 @@ EXPORT_SYMBOL(netpoll_setup);
 EXPORT_SYMBOL(netpoll_cleanup);
 EXPORT_SYMBOL(netpoll_send_udp);
 EXPORT_SYMBOL(netpoll_poll);
-EXPORT_SYMBOL(netpoll_queue);

--
Stephen Hemminger <shemminger@osdl.org>

