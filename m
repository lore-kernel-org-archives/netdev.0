From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.25] qdisc: new rate limiter
Date: Sat, 08 Dec 2007 03:57:08 +0100
Message-ID: <475A0804.1060006@trash.net>
References: <20071207162618.35715892@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47077 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbXLHC5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 21:57:44 -0500
In-Reply-To: <20071207162618.35715892@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> This is a time based rate limiter for use in network testing. When doing
> network tests it is often useful to test at reduced bandwidths. The existing
> Token Bucket Filter provides rate control, but causes bursty traffic that
> can cause different performance than real world. Another alternative is
> the PSPacer, but it depends on pause frames which may also cause issues.
>
> The qdisc depends on high resolution timers and clocks, so it will probably
> use more CPU than others making it a poor choice for use when doing traffic
> shaping for QOS. 
>
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>
> --- a/include/linux/pkt_sched.h	2007-10-30 09:18:29.000000000 -0700
> +++ b/include/linux/pkt_sched.h	2007-12-07 13:37:50.000000000 -0800
> @@ -475,4 +475,10 @@ struct tc_netem_corrupt
>  
>  #define NETEM_DIST_SCALE	8192
>  
> +struct tc_rlim_qopt
> +{
> +	__u32   limit;		/* fifo limit (packets) */
> +	__u32	rate;		/* bits per sec */
>   

This seems a bit small, 512mbit is the maximum rate.

> --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> +++ b/net/sched/sch_rlim.c	2007-12-07 16:22:10.000000000 -0800
> @@ -0,0 +1,350 @@
> +static struct sk_buff *rlim_dequeue(struct Qdisc *sch)
> +{
> +	struct rlim_sched_data *q = qdisc_priv(sch);
> +	struct sk_buff *skb;
> +	ktime_t now = ktime_get();
> +
> +	/* if haven't reached the correct time slot, start timer */
> +	if (now.tv64 < q->next_send.tv64) {
> +		sch->flags |= TCQ_F_THROTTLED;
> +		hrtimer_start(&q->watchdog.timer, q->next_send,
> +			      HRTIMER_MODE_ABS);
> +		return NULL;
> +	}
> +
> +	skb = q->qdisc->dequeue(q->qdisc);
> +	if (skb) {
> +		q->next_send = ktime_add_ns(now, pkt_time(q, skb));
> +		sch->flags &= ~TCQ_F_THROTTLED;
>   

qlen is not decremented here.
> +	}
> +	return skb;
> +}
> +
> +static int rlim_requeue(struct sk_buff *skb, struct Qdisc *sch)
> +{
> +	struct rlim_sched_data *q = qdisc_priv(sch);
> +	int ret;
> +
> +	ret = q->qdisc->ops->requeue(skb, q->qdisc);
> +	if (!ret) {
> +		q->next_send = ktime_sub_ns(q->next_send, pkt_time(q, skb));
> +		sch->q.qlen++;
> +		sch->qstats.requeues++;
> +	}
> +
> +	return ret;
> +}
> +
> +static void rlim_reset(struct Qdisc *sch)
> +{
> +	struct rlim_sched_data *q = qdisc_priv(sch);
> +
> +	qdisc_reset_queue(sch);
This should reset the child.

> +
> +	q->next_send = ktime_get();
> +	qdisc_watchdog_cancel(&q->watchdog);
> +}
> +
> +static int rlim_change(struct Qdisc *sch, struct rtattr *opt)
> +{
> +	struct rlim_sched_data *q = qdisc_priv(sch);
> +	const struct tc_rlim_qopt *qopt;
> +	int err;
> +
> +	if (opt == NULL || RTA_PAYLOAD(opt) < sizeof(struct tc_rlim_qopt))
> +		return -EINVAL;
> +
> +	qopt = RTA_DATA(opt);
>   

Using nested attributes would make sure we don't run into
problems with extensibility.

> +	err = set_fifo_limit(q->qdisc, qopt->limit);
> +	if (err)
> +		return err;
> +
> +	q->limit = qopt->limit;
> +	if (qopt->rate == 0)
> +		q->cost = 0;	/* unlimited */
> +	else {
> +		q->cost = (u64)NSEC_PER_SEC << NSEC_SCALE;
> +		do_div(q->cost, qopt->rate);
> +	}
> +
> +	pr_debug("rlim_change: rate=%u cost=%llu\n",
> +		 qopt->rate, q->cost);
> +
> +	return 0;
> +}
> +
> +static struct Qdisc_class_ops rlim_class_ops = {
>   

This can be const.

> +	.graft	   = rlim_graft,
> +	.leaf	   = rlim_leaf,
> +	.get	   = rlim_get,
> +	.put	   = rlim_put,
> +	.change	   = rlim_change_class,
> +	.delete	   = rlim_delete,
> +	.walk	   = rlim_walk,
> +	.tcf_chain = rlim_find_tcf,
> +	.dump	   = rlim_dump_class,
> +};
>
>
>   

