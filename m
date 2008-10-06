From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] Re: [net-next-2.6] Null pointer dereference in
	dev_gso_skb_destructor()
Date: Mon, 6 Oct 2008 09:45:43 +0000
Message-ID: <20081006094543.GA6405@ff.dom.local>
References: <20081005132410.3a6faf95@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jacliburn@bellsouth.net
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:56961 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684AbYJFJpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 05:45:51 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1596559ugf.37
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2008 02:45:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081005132410.3a6faf95@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05-10-2008 20:24, Jay Cliburn wrote:
> It appears as though the following net-next-2.6 commit (pulled Oct 1
> 2008) exposes a null pointer dereference in
> dev.c:dev_gso_skb_destructor().
> 
> commit 242f8bfefe4bed626df4e4727ac8f315d80b567a
> Author: David S. Miller <davem@davemloft.net>
> Date:   Mon Sep 22 22:15:30 2008 -0700
> 
>     pkt_sched: Make qdisc->gso_skb a list.

I think, this should help.

Thanks,
Jarek P.

--------------------->

pkt_sched: Fix handling of gso skbs on requeuing

Jay Cliburn noticed and diagnosed a bug triggered in
dev_gso_skb_destructor() after last change from qdisc->gso_skb
to qdisc->requeue list. Since gso_segmented skbs can't be queued
to another list this patch brings back qdisc->gso_skb for them.

Reported-by: Jay Cliburn <jcliburn@gmail.com>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

 include/net/sch_generic.h |    1 +
 net/sched/sch_generic.c   |   22 +++++++++++++++++-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 3b983e8..3fe49d8 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -52,6 +52,7 @@ struct Qdisc
 	u32			parent;
 	atomic_t		refcnt;
 	unsigned long		state;
+	struct sk_buff		*gso_skb;
 	struct sk_buff_head	requeue;
 	struct sk_buff_head	q;
 	struct netdev_queue	*dev_queue;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5e7e0bd..3db4cf1 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -44,7 +44,10 @@ static inline int qdisc_qlen(struct Qdisc *q)
 
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
-	__skb_queue_head(&q->requeue, skb);
+	if (unlikely(skb->next))
+		q->gso_skb = skb;
+	else
+		__skb_queue_head(&q->requeue, skb);
 
 	__netif_schedule(q);
 	return 0;
@@ -52,7 +55,10 @@ static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 
 static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 {
-	struct sk_buff *skb = skb_peek(&q->requeue);
+	struct sk_buff *skb = q->gso_skb;
+
+	if (!skb)
+		skb = skb_peek(&q->requeue);
 
 	if (unlikely(skb)) {
 		struct net_device *dev = qdisc_dev(q);
@@ -60,10 +66,15 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 
 		/* check the reason of requeuing without tx lock first */
 		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
-		if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
-			__skb_unlink(skb, &q->requeue);
-		else
+		if (!netif_tx_queue_stopped(txq) &&
+		    !netif_tx_queue_frozen(txq)) {
+			if (q->gso_skb)
+				q->gso_skb = NULL;
+			else
+				__skb_unlink(skb, &q->requeue);
+		} else {
 			skb = NULL;
+		}
 	} else {
 		skb = q->dequeue(q);
 	}
@@ -548,6 +559,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	module_put(ops->owner);
 	dev_put(qdisc_dev(qdisc));
 
+	kfree_skb(qdisc->gso_skb);
 	__skb_queue_purge(&qdisc->requeue);
 
 	kfree((char *) qdisc - qdisc->padded);
