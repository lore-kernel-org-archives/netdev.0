From: akpm@osdl.org
Subject: [patch 3/6] netpoll: break recursive loop in netpoll rx path
Date: Sun, 25 Jun 2006 01:47:30 -0700
Message-ID: <200606250847.k5P8lUEX020903@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, nhorman@tuxdriver.com,
	mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18579 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751180AbWFYIrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2006 04:47:46 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Neil Horman <nhorman@tuxdriver.com>

The netpoll system currently has a rx to tx path via:

netpoll_rx
 __netpoll_rx
  arp_reply
   netpoll_send_skb
    dev->hard_start_tx

This rx->tx loop places network drivers at risk of inadvertently causing a
deadlock or BUG halt by recursively trying to acquire a spinlock that is
used in both their rx and tx paths (this problem was origionally reported
to me in the 3c59x driver, which shares a spinlock between the
boomerang_interrupt and boomerang_start_xmit routines).

This patch breaks this loop, by queueing arp frames, so that they can be
responded to after all receive operations have been completed.  Tested by
myself and the reported with successful results.

Specifically it was tested with netdump.  Heres the BZ with details:
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=194055

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Acked-by: Matt Mackall <mpm@selenic.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/linux/netpoll.h |    1 +
 net/core/netpoll.c      |   26 ++++++++++++++++++++++++--
 2 files changed, 25 insertions(+), 2 deletions(-)

diff -puN include/linux/netpoll.h~netpoll-break-recursive-loop-in-netpoll-rx-path include/linux/netpoll.h
--- a/include/linux/netpoll.h~netpoll-break-recursive-loop-in-netpoll-rx-path
+++ a/include/linux/netpoll.h
@@ -31,6 +31,7 @@ struct netpoll_info {
 	int rx_flags;
 	spinlock_t rx_lock;
 	struct netpoll *rx_np; /* netpoll that registered an rx_hook */
+	struct sk_buff_head arp_tx; /* list of arp requests to reply to */
 };
 
 void netpoll_poll(struct netpoll *np);
diff -puN net/core/netpoll.c~netpoll-break-recursive-loop-in-netpoll-rx-path net/core/netpoll.c
--- a/net/core/netpoll.c~netpoll-break-recursive-loop-in-netpoll-rx-path
+++ a/net/core/netpoll.c
@@ -54,6 +54,7 @@ static atomic_t trapped;
 				sizeof(struct iphdr) + sizeof(struct ethhdr))
 
 static void zap_completion_queue(void);
+static void arp_reply(struct sk_buff *skb);
 
 static void queue_process(void *p)
 {
@@ -153,6 +154,22 @@ static void poll_napi(struct netpoll *np
 	}
 }
 
+static void service_arp_queue(struct netpoll_info *npi)
+{
+	struct sk_buff *skb;
+
+	if (unlikely(!npi))
+		return;
+
+	skb = skb_dequeue(&npi->arp_tx);
+
+	while (skb != NULL) {
+		arp_reply(skb);
+		skb = skb_dequeue(&npi->arp_tx);
+	}
+	return;
+}
+
 void netpoll_poll(struct netpoll *np)
 {
 	if(!np->dev || !netif_running(np->dev) || !np->dev->poll_controller)
@@ -163,6 +180,8 @@ void netpoll_poll(struct netpoll *np)
 	if (np->dev->poll)
 		poll_napi(np);
 
+	service_arp_queue(np->dev->npinfo);
+
 	zap_completion_queue();
 }
 
@@ -442,7 +461,9 @@ int __netpoll_rx(struct sk_buff *skb)
 	int proto, len, ulen;
 	struct iphdr *iph;
 	struct udphdr *uh;
-	struct netpoll *np = skb->dev->npinfo->rx_np;
+	struct netpoll_info *npi = skb->dev->npinfo;
+	struct netpoll *np = npi->rx_np;
+
 
 	if (!np)
 		goto out;
@@ -452,7 +473,7 @@ int __netpoll_rx(struct sk_buff *skb)
 	/* check if netpoll clients need ARP */
 	if (skb->protocol == __constant_htons(ETH_P_ARP) &&
 	    atomic_read(&trapped)) {
-		arp_reply(skb);
+		skb_queue_tail(&npi->arp_tx, skb);
 		return 1;
 	}
 
@@ -647,6 +668,7 @@ int netpoll_setup(struct netpoll *np)
 		npinfo->poll_owner = -1;
 		npinfo->tries = MAX_RETRIES;
 		spin_lock_init(&npinfo->rx_lock);
+		skb_queue_head_init(&npinfo->arp_tx);
 	} else
 		npinfo = ndev->npinfo;
 
_
