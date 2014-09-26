From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net-next PATCH 1/4] net: sched: make bstats per cpu and estimator
 RCU safe
Date: Fri, 26 Sep 2014 11:21:47 -0700
Message-ID: <5425AEBB.4030509@intel.com>
References: <20140926181346.28430.19380.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>,
	xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11864 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755222AbaIZSV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Sep 2014 14:21:58 -0400
In-Reply-To: <20140926181346.28430.19380.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/2014 11:13 AM, John Fastabend wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> 
> In order to run qdisc's without locking statistics and estimators
> need to be handled correctly.
> 
> To resolve bstats make the statistics per cpu. And because this is
> only needed for qdiscs that are running without locks which is not
> the case for most qdiscs in the near future only create percpu
> stats when qdiscs set the TCQ_F_CPUSTATS flag.
> 
> Next because estimators use the bstats to calculate packets per
> second and bytes per second the estimator code paths are updated
> to use the per cpu statistics.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---


[...]

>  	return 0;
> diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
> index 37e7d25..2f0ecd7 100644
> --- a/net/sched/sch_mqprio.c
> +++ b/net/sched/sch_mqprio.c
> @@ -234,8 +234,8 @@ static int mqprio_dump(struct Qdisc *sch, struct sk_buff *skb)
>  		qdisc = rtnl_dereference(netdev_get_tx_queue(dev, i)->qdisc);
>  		spin_lock_bh(qdisc_lock(qdisc));
>  		sch->q.qlen		+= qdisc->q.qlen;
> -		sch->bstats.bytes	+= qdisc->bstats.bytes;
> -		sch->bstats.packets	+= qdisc->bstats.packets;
> +		sch->bstats->bytes	+= qdisc->bstats.bytes;
> +		sch->bstats->packets	+= qdisc->bstats.packets;
>  		sch->qstats.qlen	+= qdisc->qstats.qlen;
>  		sch->qstats.backlog	+= qdisc->qstats.backlog;

OK v2 coming this patch got messed up and then fixed in the third
patch.

If you look at the bstats definition you'll see this obviously
wont compile. The end result is good but it wont bisect.

.John
