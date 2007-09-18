From: Patrick McHardy <kaber@trash.net>
Subject: Re: SFQ qdisc crashes with limit of 2 packets
Date: Tue, 18 Sep 2007 21:15:28 +0200
Message-ID: <46F023D0.7030307@trash.net>
References: <46F0087A.3080104@redhat.com> <46F00B80.7050901@trash.net> <46F0117A.4060807@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030901010308030208080502"
Cc: Netdev <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44492 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758750AbXIRTWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 15:22:11 -0400
In-Reply-To: <46F0117A.4060807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030901010308030208080502
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Never mind, I found the reason. When enqueuing the packet, sfq_enqueue
> contains an off-by-one in the limit check (which IIRC is there for a
> reason, but I can't remember right now) and drops the packet again.
> dev_queue_xmit() calls qdisc_run() anyway and the empty qdisc is
> dequeued, which is not handled by SFQ.
> 
> I see three possibilities to fix this (in my preferred order):
> 
> 1) figure out why the off-by-one is there, if not needed remove
> 2) don't dequeue qdiscs even once if empty
> 3) check for NULL in sfq_dequeue
> 
> So I'll try to remeber why the off-by-one is there ..


OK the off-by-one prevents an out-of-bounds array access, which
would cause a crash itself. Despite what I said above, sfq does
try to handle dequeues while empty, but forgets to update q->tail
when dropping the last packet from the only active queue, probably
because it wasn't expected that the queue length is too small to
queue even a single packet (and that really doesn't make much sense).

So one possibility for fixing this is to update q->tail in sfq_drop
when dropping the last packet, but that would still leave the qdisc
non-functional because of the off-by-one. I chose a different way:
cap the limit at SFQ_DEPTH-1 and remove the off-by-one, which should
have no effect on the max (still 127), but prevents the crash since
we can now queue at least a single packet and q->tail is properly
updated in sfq_dequeue().

CCed Alexey just to be safe, but I think the patch should be fine.

Signed-off-by: Patrick McHardy <kaber@trash.net>

--------------030901010308030208080502
Content-Type: text/plain;
 name="y"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="y"

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 9579573..cbf8089 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -270,7 +270,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc* sch)
 			q->tail = x;
 		}
 	}
-	if (++sch->q.qlen < q->limit-1) {
+	if (++sch->q.qlen < q->limit) {
 		sch->bstats.bytes += skb->len;
 		sch->bstats.packets++;
 		return 0;
@@ -306,7 +306,7 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc* sch)
 			q->tail = x;
 		}
 	}
-	if (++sch->q.qlen < q->limit - 1) {
+	if (++sch->q.qlen < q->limit) {
 		sch->qstats.requeues++;
 		return 0;
 	}
@@ -391,10 +391,10 @@ static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
 	q->quantum = ctl->quantum ? : psched_mtu(sch->dev);
 	q->perturb_period = ctl->perturb_period*HZ;
 	if (ctl->limit)
-		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH);
+		q->limit = min_t(u32, ctl->limit, SFQ_DEPTH - 1);
 
 	qlen = sch->q.qlen;
-	while (sch->q.qlen >= q->limit-1)
+	while (sch->q.qlen >= q->limit)
 		sfq_drop(sch);
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
 
@@ -423,7 +423,7 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
 		q->dep[i+SFQ_DEPTH].next = i+SFQ_DEPTH;
 		q->dep[i+SFQ_DEPTH].prev = i+SFQ_DEPTH;
 	}
-	q->limit = SFQ_DEPTH;
+	q->limit = SFQ_DEPTH - 1;
 	q->max_depth = 0;
 	q->tail = SFQ_DEPTH;
 	if (opt == NULL) {

--------------030901010308030208080502--
