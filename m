From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v5 15/16] net: sched: make qstats per cpu
Date: Fri, 12 Sep 2014 16:55:45 -0700
Message-ID: <1410566145.7106.119.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140912162748.19588.39677.stgit@nitbit.x32>
	 <20140912163453.19588.6775.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:37617 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbaILXzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 19:55:46 -0400
Received: by mail-pd0-f180.google.com with SMTP id ft15so2241531pdb.39
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 16:55:46 -0700 (PDT)
In-Reply-To: <20140912163453.19588.6775.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-12 at 09:34 -0700, John Fastabend wrote:
> Now that we run qdisc without locked the qstats need to handle the
> case where multiple cpus are receiving or transmiting a skb. For now
> the only qdisc that supports running without locks is the ingress
> qdisc which increments the 32-bit drop counter.
> 
> When the stats are collected the summation of all CPUs is collected
> and returned in the dump tlv.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  include/net/codel.h       |    4 ++--
>  include/net/gen_stats.h   |    2 ++
>  include/net/sch_generic.h |   19 +++++++++++--------
>  net/core/gen_stats.c      |   30 +++++++++++++++++++++++++++++-
>  net/sched/sch_api.c       |   31 ++++++++++++++++++++++++++-----
>  net/sched/sch_atm.c       |    2 +-
>  net/sched/sch_cbq.c       |   10 +++++-----
>  net/sched/sch_choke.c     |   15 ++++++++-------
>  net/sched/sch_codel.c     |    2 +-
>  net/sched/sch_drr.c       |    8 ++++----
>  net/sched/sch_dsmark.c    |    2 +-
>  net/sched/sch_fifo.c      |    6 ++++--
>  net/sched/sch_fq.c        |    4 ++--
>  net/sched/sch_fq_codel.c  |    8 ++++----
>  net/sched/sch_generic.c   |    8 +++++---
>  net/sched/sch_gred.c      |   10 +++++-----
>  net/sched/sch_hfsc.c      |   15 ++++++++-------
>  net/sched/sch_hhf.c       |    8 ++++----
>  net/sched/sch_htb.c       |    6 +++---
>  net/sched/sch_ingress.c   |    4 +++-
>  net/sched/sch_mq.c        |   23 ++++++++++++++---------
>  net/sched/sch_mqprio.c    |   35 ++++++++++++++++++++++-------------
>  net/sched/sch_multiq.c    |    8 ++++----
>  net/sched/sch_netem.c     |   17 +++++++++--------
>  net/sched/sch_pie.c       |    8 ++++----
>  net/sched/sch_plug.c      |    2 +-
>  net/sched/sch_prio.c      |    8 ++++----
>  net/sched/sch_qfq.c       |    8 ++++----
>  net/sched/sch_red.c       |   13 +++++++------
>  net/sched/sch_sfb.c       |   13 +++++++------
>  net/sched/sch_sfq.c       |   19 ++++++++++---------
>  net/sched/sch_tbf.c       |   11 ++++++-----
>  32 files changed, 220 insertions(+), 139 deletions(-)
> 
> diff --git a/include/net/codel.h b/include/net/codel.h
> index aeee280..72d37a4 100644
> --- a/include/net/codel.h
> +++ b/include/net/codel.h
> @@ -228,13 +228,13 @@ static bool codel_should_drop(const struct sk_buff *skb,
>  	}
>  
>  	vars->ldelay = now - codel_get_enqueue_time(skb);
> -	sch->qstats.backlog -= qdisc_pkt_len(skb);
> +	sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);
>  
>  	if (unlikely(qdisc_pkt_len(skb) > stats->maxpacket))
>  		stats->maxpacket = qdisc_pkt_len(skb);
>  
>  	if (codel_time_before(vars->ldelay, params->target) ||
> -	    sch->qstats.backlog <= stats->maxpacket) {
> +	    sch->qstats_qdisc.qstats.backlog <= stats->maxpacket) {
>  		/* went below - stay below for at least interval */
>  		vars->first_above_time = 0;
>  		return false;
> diff --git a/include/net/gen_stats.h b/include/net/gen_stats.h
> index 4b7ca2b..d548dc9 100644
> --- a/include/net/gen_stats.h
> +++ b/include/net/gen_stats.h
> @@ -44,6 +44,8 @@ int gnet_stats_copy_rate_est(struct gnet_dump *d,
>  			     const struct gnet_stats_basic_cpu __percpu *cpu_b,
>  			     struct gnet_stats_rate_est64 *r);
>  int gnet_stats_copy_queue(struct gnet_dump *d, struct gnet_stats_queue *q);
> +int gnet_stats_copy_queue_cpu(struct gnet_dump *d,
> +			      struct gnet_stats_queue __percpu *q);
>  int gnet_stats_copy_app(struct gnet_dump *d, void *st, int len);
>  
>  int gnet_stats_finish_copy(struct gnet_dump *d);
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 54e318f..518be3b 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -92,7 +92,10 @@ struct Qdisc {
>  		struct gnet_stats_basic_cpu __percpu *cpu_bstats;
>  	} bstats_qdisc;
>  	unsigned int		__state;
> -	struct gnet_stats_queue	qstats;
> +	union {
> +		struct gnet_stats_queue qstats;
> +		struct gnet_stats_queue __percpu *cpu_qstats;
> +	} qstats_qdisc;
>  	struct rcu_head		rcu_head;
>  	int			padded;
>  	atomic_t		refcnt;
> @@ -538,7 +541,7 @@ static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
>  				       struct sk_buff_head *list)
>  {
>  	__skb_queue_tail(list, skb);
> -	sch->qstats.backlog += qdisc_pkt_len(skb);
> +	sch->qstats_qdisc.qstats.backlog += qdisc_pkt_len(skb);

I am a bit lost :(

Probably a helper could make this cleaner.

>  
>  	return NET_XMIT_SUCCESS;
>  }
> @@ -554,7 +557,7 @@ static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
>  	struct sk_buff *skb = __skb_dequeue(list);
>  
>  	if (likely(skb != NULL)) {
> -		sch->qstats.backlog -= qdisc_pkt_len(skb);
> +		sch->qstats_qdisc.qstats.backlog -= qdisc_pkt_len(skb);

because this kind of patch in the future could be easier : only change
the helper ;)


Please split this patch in 2 parts :

1) Add clean helpers/macros (no functional change)

2) Make the percpu changes 
