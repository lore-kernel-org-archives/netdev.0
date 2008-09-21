From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Sun, 21 Sep 2008 13:15:51 +0200
Message-ID: <20080921111551.GB2551@ami.dom.local>
References: <20080920234843.GA2531@ami.dom.local> <20080920.223538.130375517.davem@davemloft.net> <20080921095705.GA2551@ami.dom.local> <20080921.031829.86500526.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:1641 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052AbYIULON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 07:14:13 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1044808fgg.17
        for <netdev@vger.kernel.org>; Sun, 21 Sep 2008 04:14:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080921.031829.86500526.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 21, 2008 at 03:18:29AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sun, 21 Sep 2008 11:57:06 +0200
...
> > BTW, since this problem is strongly conected with the requeuing
> > policy, I wonder why you seemingly lost interest in this. I tried to
> > advocate for your simple, one level requeuing, but also Herbert's
> > peek, and Alexander's early detection, after some polish(!), should
> > make this initial test meaningless.
> 
> Yes, thanks for reminding me about the the multiq qdisc head of line
> blocking thing.
> 
> I really don't like the requeue/peek patches, because they resulted in
> so much code duplication in the CBQ and other classful qdiscs.
> 
> Alexander's patch has similar code duplication issues.

That's why I think you should reconsider this simple solution for now,
until somebody proves this is wrong or something else is better.

Jarek P.

[RESEND]
From: Jarek Poplawski <jarkao2@gmail.com>
Newsgroups: gmane.linux.network
Subject: Re: [RFC PATCH] sched: only dequeue if packet can be queued to
	hardware queue.
Date: Fri, 19 Sep 2008 09:17:53 +0000
Archived-At: <http://permalink.gmane.org/gmane.linux.network/106324>

On Thu, Sep 18, 2008 at 06:11:45PM -0700, Alexander Duyck wrote:
> Once again if you have a suggestion on approach feel free to modify
> the patch and see how it works for you.  My only concern is that there
> are several qdiscs which won't give you the same packet twice and so
> you don't know what is going to pop out until you go in and check.
...

Actually, here is my suggestion: I think, that your obviously more
complex solution should be compared with something simple which IMHO
has similar feature, i.e. limited overhead of requeuing.

My proposal is to use partly David's idea of killing ->ops->requeue(),
for now only the first two patches, so don't requeue back to the
qdiscs, but leave qdisc->ops->requeue() for internal usage (like in
HFSC's qdisc_peek_len() hack). Additionaly I use your idea of early
checking the state of tx queue to make this even lighter after
possibly removing the entry check from qdisc_run().

I attach my patch at the end, after original David's two patches.

Thanks,
Jarek P.

---------------> patch 1/3
Subject: [PATCH 1/9]: pkt_sched: Make qdisc->gso_skb a list.
Date: Mon, 18 Aug 2008 01:36:47 -0700 (PDT)
From: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
CC: jarkao2@gmail.com
Newsgroups: gmane.linux.network


pkt_sched: Make qdisc->gso_skb a list.

The idea is that we can use this to get rid of
->requeue().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/sch_generic.h |    2 +-
 net/sched/sch_generic.c   |   12 +++++++-----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 84d25f2..140c48b 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -52,7 +52,7 @@ struct Qdisc
 	u32			parent;
 	atomic_t		refcnt;
 	unsigned long		state;
-	struct sk_buff		*gso_skb;
+	struct sk_buff_head	requeue;
 	struct sk_buff_head	q;
 	struct netdev_queue	*dev_queue;
 	struct Qdisc		*next_sched;
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6f96b7b..39d969e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -45,7 +45,7 @@ static inline int qdisc_qlen(struct Qdisc *q)
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
 	if (unlikely(skb->next))
-		q->gso_skb = skb;
+		__skb_queue_head(&q->requeue, skb);
 	else
 		q->ops->requeue(skb, q);
 
@@ -57,9 +57,8 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 {
 	struct sk_buff *skb;
 
-	if ((skb = q->gso_skb))
-		q->gso_skb = NULL;
-	else
+	skb = __skb_dequeue(&q->requeue);
+	if (!skb)
 		skb = q->dequeue(q);
 
 	return skb;
@@ -328,6 +327,7 @@ struct Qdisc noop_qdisc = {
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noop_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noop_qdisc.list),
+	.requeue.lock	=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noop_qdisc.q.lock),
 	.dev_queue	=	&noop_netdev_queue,
 };
@@ -353,6 +353,7 @@ static struct Qdisc noqueue_qdisc = {
 	.flags		=	TCQ_F_BUILTIN,
 	.ops		=	&noqueue_qdisc_ops,
 	.list		=	LIST_HEAD_INIT(noqueue_qdisc.list),
+	.requeue.lock	=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.q.lock),
 	.q.lock		=	__SPIN_LOCK_UNLOCKED(noqueue_qdisc.q.lock),
 	.dev_queue	=	&noqueue_netdev_queue,
 };
@@ -473,6 +474,7 @@ struct Qdisc *qdisc_alloc(struct netdev_queue *dev_queue,
 	sch->padded = (char *) sch - (char *) p;
 
 	INIT_LIST_HEAD(&sch->list);
+	skb_queue_head_init(&sch->requeue);
 	skb_queue_head_init(&sch->q);
 	sch->ops = ops;
 	sch->enqueue = ops->enqueue;
@@ -543,7 +545,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	module_put(ops->owner);
 	dev_put(qdisc_dev(qdisc));
 
-	kfree_skb(qdisc->gso_skb);
+	__skb_queue_purge(&qdisc->requeue);
 
 	kfree((char *) qdisc - qdisc->padded);
 }


-------------> patch 2/3
Subject: [PATCH 2/9]: pkt_sched: Always use q->requeue in dev_requeue_skb().
Date: Mon, 18 Aug 2008 01:36:50 -0700 (PDT)
From: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
CC: jarkao2@gmail.com
Newsgroups: gmane.linux.network


pkt_sched: Always use q->requeue in dev_requeue_skb().

There is no reason to call into the complicated qdiscs
just to remember the last SKB where we found the device
blocked.

The SKB is outside of the qdiscs realm at this point.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_generic.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 39d969e..96d7d08 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -44,10 +44,7 @@ static inline int qdisc_qlen(struct Qdisc *q)
 
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
-	if (unlikely(skb->next))
-		__skb_queue_head(&q->requeue, skb);
-	else
-		q->ops->requeue(skb, q);
+	__skb_queue_head(&q->requeue, skb);
 
 	__netif_schedule(q);
 	return 0;


----------------> patch 3/3

pkt_sched: Check the state of tx_queue in dequeue_skb()

Check in dequeue_skb() the state of tx_queue for requeued skb to save
on locking and re-requeuing, and possibly remove the current check in
qdisc_run(). Based on the idea of Alexander Duyck.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

---

diff -Nurp net-next-2.6-/net/sched/sch_generic.c net-next-2.6+/net/sched/sch_generic.c
--- net-next-2.6-/net/sched/sch_generic.c	2008-09-19 07:21:44.000000000 +0000
+++ net-next-2.6+/net/sched/sch_generic.c	2008-09-19 07:49:15.000000000 +0000
@@ -52,11 +52,21 @@ static inline int dev_requeue_skb(struct
 
 static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
 {
-	struct sk_buff *skb;
+	struct sk_buff *skb = skb_peek(&q->requeue);
 
-	skb = __skb_dequeue(&q->requeue);
-	if (!skb)
+	if (unlikely(skb)) {
+		struct net_device *dev = qdisc_dev(q);
+		struct netdev_queue *txq;
+
+		/* check the reason of requeuing without tx lock first */
+		txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
+		if (!netif_tx_queue_stopped(txq) && !netif_tx_queue_frozen(txq))
+			__skb_unlink(skb, &q->requeue);
+		else
+			skb = NULL;
+	} else {
 		skb = q->dequeue(q);
+	}
 
 	return skb;
 }
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

