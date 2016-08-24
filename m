From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 05/15] net: sched: a dflt qdisc may be used
 with per cpu stats
Date: Wed, 24 Aug 2016 09:41:38 -0700
Message-ID: <1472056898.14381.95.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
         <20160823202445.14368.4352.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, davem@davemloft.net, brouer@redhat.com,
        xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34484 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756227AbcHXQlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 12:41:50 -0400
Received: by mail-pa0-f66.google.com with SMTP id hh10so1471790pac.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 09:41:40 -0700 (PDT)
In-Reply-To: <20160823202445.14368.4352.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-23 at 13:24 -0700, John Fastabend wrote:
> Enable dflt qdisc support for per cpu stats before this patch a
> dflt qdisc was required to use the global statistics qstats and
> bstats.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/sch_generic.c |   24 ++++++++++++++++++++----
>  1 file changed, 20 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 80544c2..910b4d15 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -646,18 +646,34 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
>  	struct Qdisc *sch;
>  
>  	if (!try_module_get(ops->owner))
> -		goto errout;
> +		return NULL;
>  
>  	sch = qdisc_alloc(dev_queue, ops);
>  	if (IS_ERR(sch))
> -		goto errout;
> +		return NULL;
>  	sch->parent = parentid;
>  
> -	if (!ops->init || ops->init(sch, NULL) == 0)
> +	if (!ops->init)
>  		return sch;
>  
> -	qdisc_destroy(sch);
> +	if (ops->init(sch, NULL))
> +		goto errout;
> +
> +	/* init() may have set percpu flags so init data structures */
> +	if (qdisc_is_percpu_stats(sch)) {
> +		sch->cpu_bstats =
> +			netdev_alloc_pcpu_stats(struct gnet_stats_basic_cpu);
> +		if (!sch->cpu_bstats)
> +			goto errout;
> +
> +		sch->cpu_qstats = alloc_percpu(struct gnet_stats_queue);
> +		if (!sch->cpu_qstats)
> +			goto errout;
> +	}
> +

Why are you attempting these allocations here instead of qdisc_alloc()

This looks weird, I would expect base qdisc being fully allocated before
ops->init() is attempted.
