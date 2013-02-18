From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v5 10/11] tbf: take into account gso skbs
Date: Mon, 18 Feb 2013 10:58:37 +0100
Message-ID: <20130218095837.GA1566@minipsycho.orion>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
 <1360663929-1023-11-git-send-email-jiri@resnulli.us>
 <1360687182.6884.5.camel@edumazet-glaptop>
 <20130217161803.GB1931@minipsycho.orion>
 <1361123663.19353.94.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:47644 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753857Ab3BRJ6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 04:58:42 -0500
Received: by mail-ea0-f172.google.com with SMTP id f13so2276002eaa.3
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 01:58:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1361123663.19353.94.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Feb 17, 2013 at 06:54:23PM CET, eric.dumazet@gmail.com wrote:
>On Sun, 2013-02-17 at 17:18 +0100, Jiri Pirko wrote:
>
>> I'm going through this issue back and front and on the second thought,
>> I think this patch might not be so wrong after all.
>> 
>> "Accumulating" time in ptoks would effectively cause the skb to be sent
>> only in case time for whole skb is available (accumulated).
>> 
>> The re-segmenting will only cause the skb fragments sent in each time frame.
>> 
>> I can't see how the bigger bursts you are reffering to can happen.
>> 
>> Or am I missing something?
>
>Token Bucket Filter doesnt allow to accumulate tokens above a given
>threshold. Thats the whole point of the algo.
>
>After a one hour idle time, you don't want to allow your device sending
>a burst exceeding the constraint.

You are right, therefore I said "not so wrong". Let me illustrate my
thoughts. Here is a patch:

Subject: [patch net-next RFC] tbf: take into account gso skbs

Ignore max_size check for gso skbs. This check made bigger packets
incorrectly dropped. Remove this limitation for gso skbs.

Also for peaks, accumulate time for big gso skbs.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/sched/sch_tbf.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index c8388f3..bd36977 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -114,6 +114,8 @@ struct tbf_sched_data {
 	s64	t_c;			/* Time check-point */
 	struct Qdisc	*qdisc;		/* Inner qdisc, default - bfifo queue */
 	struct qdisc_watchdog watchdog;	/* Watchdog timer */
+	bool	last_dequeued;		/* Flag to indicate that a skb was
+					   returned by last dequeue */
 };
 
 static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
@@ -121,7 +123,7 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 	int ret;
 
-	if (qdisc_pkt_len(skb) > q->max_size)
+	if (qdisc_pkt_len(skb) > q->max_size && !skb_is_gso(skb))
 		return qdisc_reshape_fail(skb, sch);
 
 	ret = qdisc_enqueue(skb, q->qdisc);
@@ -164,10 +166,18 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 		toks = min_t(s64, now - q->t_c, q->buffer);
 
 		if (q->peak_present) {
+			s64 skb_ptoks = (s64) psched_l2t_ns(&q->peak, len);
+			bool big_gso = skb_is_gso(skb) && skb_ptoks > q->mtu;
+
 			ptoks = toks + q->ptokens;
-			if (ptoks > q->mtu)
+			/* In case we hit big GSO packet, don't cap to MTU
+			 * when skb is here for >= 2 time and rather accumulate
+			 * time over calls to send it as a whole.
+			 */
+			if (ptoks > q->mtu &&
+			    (!big_gso || q->last_dequeued))
 				ptoks = q->mtu;
-			ptoks -= (s64) psched_l2t_ns(&q->peak, len);
+			ptoks -= skb_ptoks;
 		}
 		toks += q->tokens;
 		if (toks > q->buffer)
@@ -177,7 +187,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 		if ((toks|ptoks) >= 0) {
 			skb = qdisc_dequeue_peeked(q->qdisc);
 			if (unlikely(!skb))
-				return NULL;
+				goto null_out;
 
 			q->t_c = now;
 			q->tokens = toks;
@@ -185,6 +195,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 			sch->q.qlen--;
 			qdisc_unthrottled(sch);
 			qdisc_bstats_update(sch, skb);
+			q->last_dequeued = true;
 			return skb;
 		}
 
@@ -204,6 +215,8 @@ static struct sk_buff *tbf_dequeue(struct Qdisc *sch)
 
 		sch->qstats.overlimits++;
 	}
+null_out:
+	q->last_dequeued = false;
 	return NULL;
 }
 
@@ -212,6 +225,7 @@ static void tbf_reset(struct Qdisc *sch)
 	struct tbf_sched_data *q = qdisc_priv(sch);
 
 	qdisc_reset(q->qdisc);
+	q->last_dequeued = false;
 	sch->q.qlen = 0;
 	q->t_c = ktime_to_ns(ktime_get());
 	q->tokens = q->buffer;
@@ -290,6 +304,7 @@ static int tbf_change(struct Qdisc *sch, struct nlattr *opt)
 		qdisc_tree_decrease_qlen(q->qdisc, q->qdisc->q.qlen);
 		qdisc_destroy(q->qdisc);
 		q->qdisc = child;
+		q->last_dequeued = false;
 	}
 	q->limit = qopt->limit;
 	q->mtu = PSCHED_TICKS2NS(qopt->mtu);
@@ -392,6 +407,7 @@ static int tbf_graft(struct Qdisc *sch, unsigned long arg, struct Qdisc *new,
 	q->qdisc = new;
 	qdisc_tree_decrease_qlen(*old, (*old)->q.qlen);
 	qdisc_reset(*old);
+	q->last_dequeued = false;
 	sch_tree_unlock(sch);
 
 	return 0;
-- 
1.8.1.2


This allows to send whole gso skb at once when enough time is accumulated:

let's say one gso skb would segment into seg1,seg2,seg3,seg4
compare table:
time  segs         gso skb
1     deq seg1     accumulate this time
2     deq seg2     accumulate this time
3     deq seg3     accumulate this time
4     deq seg4     deq skb
