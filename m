From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: SFQ qdisc crashes with limit of 2 packets
Date: Wed, 19 Sep 2007 13:48:03 +0400
Message-ID: <20070919094803.GA17740@ms2.inr.ac.ru>
References: <46F0087A.3080104@redhat.com> <46F00B80.7050901@trash.net> <46F0117A.4060807@trash.net> <46F023D0.7030307@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Ebbert <cebbert@redhat.com>, Netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:54682 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752953AbXISJsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 05:48:11 -0400
Content-Disposition: inline
In-Reply-To: <46F023D0.7030307@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> OK the off-by-one prevents an out-of-bounds array access,

Yes, this is not off-by-one (off-by-two, to be more exact :-)).

Maximal queue length is really limited by SFQ_DEPTH-2, because:

1. SFQ keeps list of queue lengths in array of length SFQ_DEPTH.
   This means length of queue must be in range 0..SFQ_DEPTH-1.

2. SFQ enqueues incoming packet first, and drops something after this.
   This means it always needs a free slot in queue. So, SFQ_DEPTH-2.


> CCed Alexey just to be safe, but I think the patch should be fine.

Yes. But what'a about limit == 1? tc prohibits this case, but it is still
not nice to have the bug in kernel. Plus, code remains creepy, the check

+	if (++sch->q.qlen < q->limit) {

still looks as a scary off-by-one. I would go all the way: replace this
with natural:

	if (++sch->q.qlen <= q->limit) {

and maxed q->limit at SFQ_DEPTH-2. Patch enclosed.


Seems, it is easy to relax the limit to SFQ_DEPTH-1, item #2 is an artificial
limitation. If current queue already has SFQ_DEPTH-1 packets, we can
drop from tail of this queue and skip update of all the state. It is even
an optimization for the case when we have single flow. I am not 100% sure
about this, I'll try and report.



diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 9579573..cbf8089 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -270,7 +270,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 			q->tail = x;
 		}
 	}
-	if (++sch->q.qlen < q->limit-1) {
+	if (++sch->q.qlen <= q->limit) {
 		sch->bstats.bytes += skb->len;
 		sch->bstats.packets++;
 		return 0;
@@ -306,7 +306,7 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
 			q->tail = x;
 		}
 	}
-	if (++sch->q.qlen < q->limit - 1) {
+	if (++sch->q.qlen <= q->limit) {
 		sch->qstats.requeues++;
 		return 0;
 	}
@@ -391,10 +391,10 @@ static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
 	q->quantum = ctl->quantum ? : psched_mtu(sch->dev);
 	q->perturb_period = ctl->perturb_period*HZ;
 	if (ctl->limit)
-		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
+		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH - 2);
 
 	qlen = sch->q.qlen;
-	while (sch->q.qlen >= q->limit-1)
+	while (sch->q.qlen > q->limit)
 		sfq_drop(sch);
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
 
@@ -423,7 +423,7 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 		q->dep[i+SFQ_DEPTH].next = i+SFQ_DEPTH;
 		q->dep[i+SFQ_DEPTH].prev = i+SFQ_DEPTH;
 	}
-	q->limit = SFQ_DEPTH;
+	q->limit = SFQ_DEPTH - 2;
 	q->max_depth = 0;
 	q->tail = SFQ_DEPTH;
 	if (opt == NULL) {
