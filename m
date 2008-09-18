From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] sched: only dequeue if packet can be queued to
	hardware queue.
Date: Thu, 18 Sep 2008 21:44:19 +0200
Message-ID: <20080918194419.GA2982@ami.dom.local>
References: <20080918063036.27934.91273.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, kaber@trash.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.187]:36903 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754288AbYIRTnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 15:43:10 -0400
Received: by fk-out-0910.google.com with SMTP id 18so54229fkq.5
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2008 12:43:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080918063036.27934.91273.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck wrote, On 09/18/2008 08:43 AM:
...
> ---
> This patch changes the behavior of the sch->dequeue to only
> dequeue a packet if the queue it is bound for is not currently
> stopped.  This functionality is provided via a new op called
> smart_dequeue.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---

I think, these changes make sense only if they don't add more then give,
and two dequeues (and still no way to kill requeue) is IMHO too much.
(I mean the maintenance.) As far as I can see it's mainly for HFSC's
qdisc_peek_len(), anyway this looks like main issue to me.

Below a few small doubts. (I need to find some time for details yet.)
BTW, this patch needs a checkpatch run.

---
diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index b786a5b..4082f39 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -90,10 +90,7 @@ extern void __qdisc_run(struct Qdisc *q);
 
 static inline void qdisc_run(struct Qdisc *q)
 {
-	struct netdev_queue *txq = q->dev_queue;
-
-	if (!netif_tx_queue_stopped(txq) &&

I think, there is no reason to do a full dequeue try each time instead
of this check, even if we save on requeuing now. We could try to save
the result of the last dequeue, e.g. a number or some mask of a few
tx_queues which prevented dequeuing, and check for the change of state
only. (Or alternatively, what I mentioned before: a flag set with the
full stop or freeze.)

-	    !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
+	if (!test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
 		__qdisc_run(q);
 }
 
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e556962..4400a18 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
...
+static inline struct sk_buff *__qdisc_smart_dequeue(struct Qdisc *sch,
+						    struct sk_buff_head *list)
+{
+	struct sk_buff *skb = skb_peek(list);

Since success is much more likely here, __skb_dequeue() with
__skb_queue_head() on fail looks better to me.

Of course, it's a matter of taste, but (if we really need these two
dequeues) maybe qdisc_dequeue_smart() would be more in line with
qdisc_dequeue_head()? (And similarly smart names below.)

+	struct netdev_queue *txq;
+
+	if (!skb)
+		return NULL;
+
+	txq = netdev_get_tx_queue(qdisc_dev(sch), skb_get_queue_mapping(skb));
+	if (netif_tx_queue_stopped(txq) || netif_tx_queue_frozen(txq)) {
+		sch->flags |= TCQ_F_STOPPED;
+		return NULL;
+	}
+	__skb_unlink(skb, list);
+	sch->qstats.backlog -= qdisc_pkt_len(skb);
+	sch->flags &= ~TCQ_F_STOPPED;

This clearing is probably needed in ->reset() and in ->drop() too.
(Or above, after if (!skb))

...
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d14f020..4da1a85 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
...
+static struct sk_buff *htb_smart_dequeue(struct Qdisc *sch)
+{
+	struct sk_buff *skb = NULL;
+	struct htb_sched *q = qdisc_priv(sch);
+	int level, stopped = false;
+	psched_time_t next_event;
+
+	/* try to dequeue direct packets as high prio (!) to minimize cpu work */
+	skb = skb_peek(&q->direct_queue);

As above: __skb_dequeue()?

Thanks,
Jarek P.
