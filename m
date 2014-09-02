From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [net-next PATCH 3/3] qdisc: sysctl to adjust bulk dequeue limit
Date: Tue, 02 Sep 2014 17:33:25 +0200
Message-ID: <5405E345.9010403@redhat.com>
References: <20140902143254.1918.8419.stgit@dragon> <20140902143553.1918.73632.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753703AbaIBPdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 11:33:38 -0400
In-Reply-To: <20140902143553.1918.73632.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2014 04:36 PM, Jesper Dangaard Brouer wrote:
> Allow userspace to adjust how many packet the qdisc is allowed to
> bulk dequeue.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>
> ---
> Question should we allow this to be adjusted?
>
>   include/net/sch_generic.h  |    2 ++
>   net/core/sysctl_net_core.c |    9 +++++++++
>   net/sched/sch_generic.c    |    4 +++-
>   3 files changed, 14 insertions(+), 1 deletions(-)
>
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index a3cfb8e..b0ac7b5 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -14,6 +14,8 @@ struct qdisc_walker;
>   struct tcf_walker;
>   struct module;
>
> +extern int qdisc_bulk_dequeue_limit;
> +
>   struct qdisc_rate_table {
>   	struct tc_ratespec rate;
>   	u32		data[256];
> diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
> index cf9cd13..5505841 100644
> --- a/net/core/sysctl_net_core.c
> +++ b/net/core/sysctl_net_core.c
> @@ -361,6 +361,15 @@ static struct ctl_table net_core_table[] = {
>   		.mode		= 0644,
>   		.proc_handler	= proc_dointvec
>   	},
> +	{
> +		.procname	= "qdisc_bulk_dequeue_limit",
> +		.data		= &qdisc_bulk_dequeue_limit,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.extra1		= &zero,

If zero, then this would bulk INT_MAX due to a wrap around in patch 2.

> +		.extra2		= &ushort_max,
> +		.proc_handler	= proc_dointvec_minmax
> +	},
>   	{ }
>   };
>
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 30814ef..9cb08c0 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -34,6 +34,8 @@
>   const struct Qdisc_ops *default_qdisc_ops = &pfifo_fast_ops;
>   EXPORT_SYMBOL(default_qdisc_ops);
>
> +int qdisc_bulk_dequeue_limit __read_mostly = 7;
> +

Just nit, but this should be adjusted plus the exit condition in
dequeue_skb() to work with 8 when you mention the max limit of 8
as bulk dequeue.

It would be great, if we could go with 0 knobs first, though.

>   /* Main transmission queue. */
>
>   /* Modifications to data participating in scheduling must be protected with
> @@ -81,7 +83,7 @@ static inline struct sk_buff *dequeue_skb(struct Qdisc *q)
>   			/* bulk dequeue */
>   			if (skb && !skb->next && (q->flags & TCQ_F_ONETXQUEUE)) {
>   				struct sk_buff *new, *head = skb;
> -				int limit = 7;
> +				int limit = qdisc_bulk_dequeue_limit;
>
>   				do {
>   					new = q->dequeue(q);
>
