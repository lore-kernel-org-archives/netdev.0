From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: Simplify dev_requeue_skb and dequeue_skb
Date: Mon, 6 Oct 2008 19:38:42 +0200
Message-ID: <20081006173842.GA2610@ami.dom.local>
References: <20081005132410.3a6faf95@osprey.hogchain.net> <20081006094543.GA6405@ff.dom.local> <20081006.095501.128868430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jcliburn@gmail.com, netdev@vger.kernel.org, jacliburn@bellsouth.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:20767 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953AbYJFRiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 13:38:06 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1082550nfc.21
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2008 10:38:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081006.095501.128868430.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 06, 2008 at 09:55:01AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Mon, 6 Oct 2008 09:45:43 +0000
> 
> > pkt_sched: Fix handling of gso skbs on requeuing
> > 
> > Jay Cliburn noticed and diagnosed a bug triggered in
> > dev_gso_skb_destructor() after last change from qdisc->gso_skb
> > to qdisc->requeue list. Since gso_segmented skbs can't be queued
> > to another list this patch brings back qdisc->gso_skb for them.
> > 
> > Reported-by: Jay Cliburn <jcliburn@gmail.com>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> Applied thanks Jarek.


Actually, I was just about to send take 2...

So, here is some PS.

Thanks,
Jarek P.
 
--------------------->

pkt_sched: Simplify dev_requeue_skb and dequeue_skb

qdisc->requeue was planned to universally replace all requeuing code,
but at the top level we never requeue more than one skb, so qdisc->
gso_skb is enough for this. qdisc->requeue would be used on the lower
levels only for one level deep requeuing (like in sch_hfsc) after
finishing all the changes.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

diff -Nurp a/net/sched/sch_generic.c b/net/sched/sch_generic.c
--- a/net/sched/sch_generic.c	2008-10-06 19:07:28.000000000 +0200
+++ b/net/sched/sch_generic.c	2008-10-06 18:26:29.000000000 +0200
@@ -44,12 +44,9 @@ static inline int qdisc_qlen(struct Qdis
 
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
-	if (unlikely(skb->next))
-		q->gso_skb = skb;
-	else
-		__skb_queue_head(&q->requeue, skb);
-
+	q->gso_skb = skb;
 	__netif_schedule(q);
+
 	return 0;
 }
 
@@ -57,24 +54,16 @@ static inline struct sk_buff *dequeue_sk
 {
 	struct sk_buff *skb = q->gso_skb;
 
-	if (!skb)
-		skb = skb_peek(&q->requeue);
-
 	if (unlikely(skb)) {
 		struct net_device *dev = qdisc_dev(q);
 		struct netdev_queue *txq;
 
 		/* check the reason of requeuing without tx lock first */
 		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
-		if (!netif_tx_queue_stopped(txq) &&
-		    !netif_tx_queue_frozen(txq)) {
-			if (q->gso_skb)
-				q->gso_skb = NULL;
-			else
-				__skb_unlink(skb, &q->requeue);
-		} else {
+		if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
+			q->gso_skb = NULL;
+		else
 			skb = NULL;
-		}
 	} else {
 		skb = q->dequeue(q);
 	}
