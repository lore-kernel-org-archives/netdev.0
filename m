From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: sch_netem: Limit packet re-ordering
	functionality to tfifo qdisc.
Date: Fri, 17 Oct 2008 22:12:10 +0200
Message-ID: <20081017201210.GA2527@ami.dom.local>
References: <20081016220905.GA2747@ami.dom.local> <48F88613.1060404@trash.net> <20081017130333.GA8297@ff.dom.local> <48F89D33.9090809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:47166 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755639AbYJQUKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 16:10:52 -0400
Received: by ey-out-2122.google.com with SMTP id 6so280873eyi.37
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2008 13:10:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F89D33.9090809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 17, 2008 at 04:12:03PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Fri, Oct 17, 2008 at 02:33:23PM +0200, Patrick McHardy wrote:
>>>> @@ -233,7 +233,9 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>>>  		 */
>>>>  		cb->time_to_send = psched_get_time();
>>>>  		q->counter = 0;
>>>> -		ret = q->qdisc->ops->requeue(skb, q->qdisc);
>>>> +		q->qdisc->flags |= TCQ_F_REQUEUE;
>>>> +		ret = qdisc_equeue(skb, q->qdisc);
>>>> +		q->qdisc->flags &= ~TCQ_F_REQUEUE;
>>> Well, the inner qdisc would still need to logic to order packets
>>> apprioriately.
>>
>> I'm not sure I was understood: the idea is to do something like
>> in this example in tfifo_enqueue() in all leaf qdiscs like fifo
>> etc. too, so to redirect their ->enqueue() to their ->requeue()
>> which usually is qdisc_requeue() (or to it directly if needed).
>
> Yes, I misunderstood this, I though the intention was to get
> rid of requeue entirely.

I was less ambitious and thought about simplifying this at least, but
if you think we can go further, it's OK with me. Then we can do it
only in tfifo. If qdisc_requeue() does the proper logic for it now,
I guess it should be enough to open code this into tfifo_enqueue()
(so we could kill qdisc_requeue() later). Using this TCQ_F_REQUEUE
flag only for this looks a bit wasteful, but I can't see anything
smarter at the moment. 

>>> Its probably not that hard, but as I said, I don't
>>> think its necessary at all. It only makes a difference with a
>>> non-work-conserving inner qdisc, but a lot of the functionality of
>>> netem requires the inner tfifo anyways and rate-limiting is usually
>>> done on top of netem. So I would suggest so either hard-wire the
>>> tfifo qdisc or at least make the assumption that inner qdiscs are
>>> work-conserving.

I think Stephen could be interested with this change so I added him to Cc.

Thanks,
Jarek P.
------------------->

pkt_sched: sch_netem: Limit packet re-ordering functionality to tfifo qdisc.

After introducing qdisc->ops->peek() method the only remaining user of
qdisc->ops->requeue() is netem_enqueue() using this for packet
re-ordering. According to Patrick McHardy: "a lot of the functionality
of netem requires the inner tfifo anyways and rate-limiting is usually
done on top of netem. So I would suggest so either hard-wire the tfifo
qdisc or at least make the assumption that inner qdiscs are work-
conserving." This patch tries the former.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 include/net/sch_generic.h |    1 +
 net/sched/sch_netem.c     |   18 +++++++++++++++++-
 2 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9dcb5bf..9157766 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -45,6 +45,7 @@ struct Qdisc
 #define TCQ_F_BUILTIN	1
 #define TCQ_F_THROTTLED	2
 #define TCQ_F_INGRESS	4
+#define TCQ_F_REQUEUE	8
 	int			padded;
 	struct Qdisc_ops	*ops;
 	struct qdisc_size_table	*stab;
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 3080bd6..a30f5b6 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -233,7 +233,14 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		 */
 		cb->time_to_send = psched_get_time();
 		q->counter = 0;
-		ret = q->qdisc->ops->requeue(skb, q->qdisc);
+		q->qdisc->flags |= TCQ_F_REQUEUE;
+		ret = qdisc_enqueue(skb, q->qdisc);
+		if (unlikely(q->qdisc->flags & TCQ_F_REQUEUE)) {
+			q->qdisc->flags &= ~TCQ_F_REQUEUE;
+			if (net_ratelimit())
+				printk(KERN_WARNING "netem_enqueue: re-ordering"
+				    " unsupported; use default (tfifo) qdisc.");
+		}
 	}
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
@@ -478,6 +485,15 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 	psched_time_t tnext = netem_skb_cb(nskb)->time_to_send;
 	struct sk_buff *skb;
 
+	if (sch->flags & TCQ_F_REQUEUE) {
+		sch->flags &= ~TCQ_F_REQUEUE;
+		__skb_queue_head(list, nskb);
+		sch->qstats.backlog += qdisc_pkt_len(nskb);
+		sch->qstats.requeues++;
+
+		return NET_XMIT_SUCCESS;
+	}
+
 	if (likely(skb_queue_len(list) < q->limit)) {
 		/* Optimize for add at tail */
 		if (likely(skb_queue_empty(list) || tnext >= q->oldest)) {
