From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Tue, 14 Oct 2008 22:44:13 +0200
Message-ID: <48F5049D.1000306@trash.net>
References: <20081014175649.GA2548@ami.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090504080006020906090604"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46227 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbYJNUoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 16:44:17 -0400
In-Reply-To: <20081014175649.GA2548@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090504080006020906090604
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Jarek Poplawski wrote:
>> The main difference results from the fact that higher priority
>> packets can't preempt "peeked" lower priority packets anymore.
>> The difference this causes obviously depends on the bandwidth,
>> but in my opinion the impact (as mentioned. 12ms delay for
>> 1500b, 1mbit, rises linearly with bigger packets/less bandwidth)
>> is large enough to speak against these changes.
> 
> Actually, I think I had similar doubts one or two months ago, but I
> can remember mainly your discussion on peek with Herbert, and not
> much about something like above, but probably I didn't pay enough
> attention.
> 
> Anyway, the main source of my misleading seems to be HFSC... So do you
> mean it's OK to use this kind of requeuing in hfsc_requeue(), but not
> elsewhere? Maybe I miss something, but if some other qdisc is used as
> a parent of HFSC, and does something like qdisc_peek_len(), it gets
> just what you're against above?

I think we really need a peek operation since most qdiscs do have
some internal priorization. The question is whether all qdiscs need
it; I tend to think no. Plugging two non-work-conserving qdiscs
together doesn't make much sense, so we could just prevent this.
This means we would only need to add ->peek support to the
work-conserving qdiscs, which looks pretty easy in all cases.
We actually don't even have to prevent plugging two non-work-conserving
qdiscs, the ones that need the peek operation could just check whether
the inner qdisc supports it.

Just as a demonstration how easy adding a peek operation to the
work-conserving qdiscs actually is. It doesn't need to keep or change
any internal state in many cases thanks to the guarantee that the
packet will either be dequeued or, if another packet arrives, the
upper qdisc will immediately ->peek again to reevaluate the state.



--------------090504080006020906090604
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index e556962..5462c50 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -431,6 +431,11 @@ static inline struct sk_buff *qdisc_dequeue_tail(struct Qdisc *sch)
 	return __qdisc_dequeue_tail(sch, &sch->q);
 }
 
+static inline struct sk_buff *qdisc_peek_head(struct Qdisc *sch)
+{
+	return skb_peek(&sch->q);
+}
+
 static inline int __qdisc_requeue(struct sk_buff *skb, struct Qdisc *sch,
 				  struct sk_buff_head *list)
 {
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 23d258b..8825e88 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -83,6 +83,7 @@ struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	pfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_head,
 	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
@@ -98,6 +99,7 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	bfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_head,
 	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index a6697c6..8411472 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -120,6 +120,19 @@ prio_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	return ret;
 }
 
+static struct sk_buff *prio_peek(struct Qdisc *sch)
+{
+	struct prio_sched_data *q = qdisc_priv(sch);
+	int prio;
+
+	for (prio = 0; prio < q->bands; prio++) {
+		struct Qdisc *qdisc = q->queues[prio];
+		struct sk_buff *skb = qdisc->peek(qdisc);
+		if (skb)
+			return skb;
+	}
+	return NULL;
+}
 
 static struct sk_buff *prio_dequeue(struct Qdisc* sch)
 {
@@ -425,6 +438,7 @@ static struct Qdisc_ops prio_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct prio_sched_data),
 	.enqueue	=	prio_enqueue,
 	.dequeue	=	prio_dequeue,
+	.peek		=	prio_peek,
 	.requeue	=	prio_requeue,
 	.drop		=	prio_drop,
 	.init		=	prio_init,
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 6e041d1..282a96c 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -391,8 +391,20 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_CN;
 }
 
+static struct sk_buff *
+sfq_peek(struct Qdisc *sch)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	struct sk_buff *skb;
+	sfq_index a;
 
+	/* No active slots */
+	if (q->tail == SFQ_DEPTH)
+		return NULL;
 
+	a = q->next[q->tail];
+	return skb_peek(&q->qs[a]);
+}
 
 static struct sk_buff *
 sfq_dequeue(struct Qdisc *sch)
@@ -624,6 +636,7 @@ static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct sfq_sched_data),
 	.enqueue	=	sfq_enqueue,
 	.dequeue	=	sfq_dequeue,
+	.peek		=	sfq_peek,
 	.requeue	=	sfq_requeue,
 	.drop		=	sfq_drop,
 	.init		=	sfq_init,

--------------090504080006020906090604--
