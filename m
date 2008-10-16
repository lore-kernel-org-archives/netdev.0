From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 0/6] Add qdisc->ops->peek() support.
Date: Fri, 17 Oct 2008 00:09:05 +0200
Message-ID: <20081016220905.GA2747@ami.dom.local>
References: <48F735C7.6050808@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:33709 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757000AbYJPWIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 18:08:15 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1880500ugf.37
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 15:08:12 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F735C7.6050808@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote, On 10/16/2008 02:38 PM:

> Jarek Poplawski wrote:
...
>> PS: after this patchset only netem_enqueue() needs qdisc->requeue(),
>> but I hope this won't take too long.
> 
> Assuming work-conserving qdiscs are used with netem, the currently
> code will always send out a reorder packet immediately. This behaviour
> is trivial to implement without ->requeue. The problematic case is
> non-work-conserving inner qdiscs, but that doesn't seem important
> at all since you'd usually add it as parent of netem, which still
> works.

How about something like this (example only)?

Jarek P.
---

 include/net/sch_generic.h |    1 +
 net/sched/sch_netem.c     |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

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
index 3080bd6..6ac8efc 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -233,7 +233,9 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		 */
 		cb->time_to_send = psched_get_time();
 		q->counter = 0;
-		ret = q->qdisc->ops->requeue(skb, q->qdisc);
+		q->qdisc->flags |= TCQ_F_REQUEUE;
+		ret = qdisc_equeue(skb, q->qdisc);
+		q->qdisc->flags &= ~TCQ_F_REQUEUE;
 	}
 
 	if (likely(ret == NET_XMIT_SUCCESS)) {
@@ -478,6 +480,9 @@ static int tfifo_enqueue(struct sk_buff *nskb, struct Qdisc *sch)
 	psched_time_t tnext = netem_skb_cb(nskb)->time_to_send;
 	struct sk_buff *skb;
 
+	if (unlikely(sch->flags & TCQ_F_REQUEUE))
+		return qdisc_requeue(nskb, sch);
+
 	if (likely(skb_queue_len(list) < q->limit)) {
 		/* Optimize for add at tail */
 		if (likely(skb_queue_empty(list) || tnext >= q->oldest)) {
