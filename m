From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] netpoll: break recursive loop in netpoll rx path
Date: Mon, 12 Jun 2006 11:40:29 -0400
Message-ID: <20060612154029.GA3790@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mpm@selenic.com, jmoyer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-70-61-120-52.midsouth.biz.rr.com ([70.61.120.52]:48908
	"EHLO ra.tuxdriver.com") by vger.kernel.org with ESMTP
	id S1750850AbWFLPkt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 11:40:49 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey there-
	the netpoll system currently has a rx to tx path via:
netpoll_rx
 __netpoll_rx
  arp_reply
   netpoll_send_skb
    dev->hard_start_tx

	This rx->tx loop places network drivers at risk of inadvertently causing
a deadlock or BUG halt by recursively trying to acquire a spinlock that is used
in both their rx and tx paths (this problem was origionally reported to me in
the 3c59x driver, which shares a spinlock between the boomerang_interrupt and
boomerang_start_xmit routines).  This patch breaks this loop, by queueing arp
frames, so that they can be responded to after all receive operations have been
completed.  Tested by myself and the reported with successful results.

Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>



 include/linux/netpoll.h |    1 +
 net/core/netpoll.c      |   17 +++++++++++++++--
 2 files changed, 16 insertions(+), 2 deletions(-)



--- linux-2.6/include/linux/netpoll.h.orig	2006-06-12 09:11:01.000000000 -0400
+++ linux-2.6/include/linux/netpoll.h	2006-06-12 09:34:17.000000000 -0400
@@ -31,6 +31,7 @@ struct netpoll_info {
 	int rx_flags;
 	spinlock_t rx_lock;
 	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
+	struct sk_buff_head arp_tx; /* list of arp requests to reply to */
 };
 
 void netpoll_poll(struct netpoll *np);
--- linux-2.6/net/core/netpoll.c.orig	2006-06-12 09:11:01.000000000 -0400
+++ linux-2.6/net/core/netpoll.c	2006-06-12 11:10:13.000000000 -0400
@@ -54,6 +54,7 @@ static atomic_t trapped;
 				sizeof(struct iphdr) + sizeof(struct ethhdr))
 
 static void zap_completion_queue(void);
+static void arp_reply(struct sk_buff *skb);
 
 static void queue_process(void *p)
 {
@@ -155,14 +156,23 @@ static void poll_napi(struct netpoll *np
 
 void netpoll_poll(struct netpoll *np)
 {
+	struct sk_buff *skb;
+	struct netpoll_info *npi;
+
 	if(!np->dev || !netif_running(np->dev) || !np->dev->poll_controller)
 		return;
 
+	npi = np->dev->npinfo;
+
 	/* Process pending work on NIC */
 	np->dev->poll_controller(np->dev);
 	if (np->dev->poll)
 		poll_napi(np);
 
+	if (likely(npi))
+		while ((skb = skb_dequeue(&npi->arp_tx)) != NULL)
+			arp_reply(skb);
+
 	zap_completion_queue();
 }
 
@@ -449,7 +459,9 @@ int __netpoll_rx(struct sk_buff *skb)
 	int proto, len, ulen;
 	struct iphdr *iph;
 	struct udphdr *uh;
-	struct netpoll *np = skb->dev->npinfo->rx_np;
+	struct netpoll_info *npi = skb->dev->npinfo;
+	struct netpoll *np = npi->rx_np;
+
 
 	if (!np)
 		goto out;
@@ -459,7 +471,7 @@ int __netpoll_rx(struct sk_buff *skb)
 	/* check if netpoll clients need ARP */
 	if (skb->protocol == __constant_htons(ETH_P_ARP) &&
 	    atomic_read(&trapped)) {
-		arp_reply(skb);
+		skb_queue_tail(&npi->arp_tx, skb);
 		return 1;
 	}
 
@@ -654,6 +666,7 @@ int netpoll_setup(struct netpoll *np)
 		npinfo->poll_owner = -1;
 		npinfo->tries = MAX_RETRIES;
 		spin_lock_init(&npinfo->rx_lock);
+		skb_queue_head_init(&npinfo->arp_tx);
 	} else
 		npinfo = ndev->npinfo;
 
-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *gpg keyid: 1024D / 0x92A74FA1 - http://pgp.mit.edu
 ***************************************************/
