From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH 2/4] net: sched: implement qstat helper routines
Date: Fri, 26 Sep 2014 11:36:41 -0700
Message-ID: <1411756601.16953.136.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140926181346.28430.19380.stgit@nitbit.x32>
	 <20140926181440.28430.71445.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:64708 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770AbaIZSgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 14:36:42 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so1565941pdj.13
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 11:36:42 -0700 (PDT)
In-Reply-To: <20140926181440.28430.71445.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-26 at 11:14 -0700, John Fastabend wrote:
> This adds helpers to manipulate qstats logic and replaces locations
> that touch the counters directly. This simplifies future patches
> to push qstats onto per cpu counters.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  include/net/sch_generic.h |   43 +++++++++++++++++++++++++++++++++++--------
>  net/sched/sch_api.c       |    2 +-
>  net/sched/sch_atm.c       |    2 +-
>  net/sched/sch_cbq.c       |   10 +++++-----
>  net/sched/sch_choke.c     |   14 +++++++-------
>  net/sched/sch_codel.c     |    2 +-
>  net/sched/sch_drr.c       |    4 ++--
>  net/sched/sch_dsmark.c    |    2 +-
>  net/sched/sch_fifo.c      |    2 +-
>  net/sched/sch_fq.c        |    4 ++--
>  net/sched/sch_fq_codel.c  |    8 ++++----
>  net/sched/sch_gred.c      |    4 ++--
>  net/sched/sch_hfsc.c      |    8 ++++----
>  net/sched/sch_hhf.c       |    8 ++++----
>  net/sched/sch_htb.c       |    6 +++---
>  net/sched/sch_ingress.c   |    2 +-
>  net/sched/sch_multiq.c    |    4 ++--
>  net/sched/sch_netem.c     |   15 +++++++--------
>  net/sched/sch_pie.c       |    2 +-
>  net/sched/sch_prio.c      |    4 ++--
>  net/sched/sch_qfq.c       |    4 ++--
>  net/sched/sch_red.c       |    8 ++++----
>  net/sched/sch_sfb.c       |   10 +++++-----
>  net/sched/sch_sfq.c       |   17 +++++++++--------
>  net/sched/sch_tbf.c       |    8 ++++----
>  25 files changed, 110 insertions(+), 83 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 4b93511..5609844 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -521,11 +521,39 @@ static inline void qdisc_bstats_update(struct Qdisc *sch,
>  	bstats_update(&sch->bstats, skb);
>  }
>  
> +static inline void qdisc_qstats_backlog(struct Qdisc *sch,
> +				       const struct sk_buff *skb)

qdisc_qstats_backlog_dec() to be consistent with
qdisc_qstats_backlog_dec() ?

> +{
> +	sch->qstats.backlog -= qdisc_pkt_len(skb);
> +}
> +
> +static inline void qdisc_qstats_backlog_inc(struct Qdisc *sch,
> +					    const struct sk_buff *skb)
> +{
> +
> +	sch->qstats.backlog += qdisc_pkt_len(skb);
> +}
> +
> +static inline void __qdisc_qstats_drop(struct Qdisc *sch, int count)
> +{
> +	sch->qstats.drops += count;
> +}
> +
> +static inline void qdisc_qstats_drop(struct Qdisc *sch)
> +{
> +	sch->qstats.drops++;
> +}
> +
> +static inline void qdisc_qstats_overlimit(struct Qdisc *sch)
> +{
> +	sch->qstats.overlimits++;
> +}
> +
>  static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
>  				       struct sk_buff_head *list)
>  {
>  	__skb_queue_tail(list, skb);
> -	sch->qstats.backlog += qdisc_pkt_len(skb);
> +	qdisc_qstats_backlog_inc(sch, skb);
>  
>  	return NET_XMIT_SUCCESS;
>  }
> @@ -541,7 +569,7 @@ static inline struct sk_buff *__qdisc_dequeue_head(struct Qdisc *sch,
>  	struct sk_buff *skb = __skb_dequeue(list);
>  
>  	if (likely(skb != NULL)) {
> -		sch->qstats.backlog -= qdisc_pkt_len(skb);
> +		qdisc_qstats_backlog(sch, skb);
>  		qdisc_bstats_update(sch, skb);
>  	}
>  
> @@ -559,10 +587,9 @@ static inline unsigned int __qdisc_queue_drop_head(struct Qdisc *sch,
>  	struct sk_buff *skb = __skb_dequeue(list);
>  
>  	if (likely(skb != NULL)) {
> -		unsigned int len = qdisc_pkt_len(skb);
> -		sch->qstats.backlog -= len;
> +		qdisc_qstats_backlog(sch, skb);
>  		kfree_skb(skb);
> -		return len;
> +		return qdisc_pkt_len(skb);

Well, you just added a use after free.

>  	}
>  
>  	return 0;
> @@ -579,7 +606,7 @@ static inline struct sk_buff *__qdisc_dequeue_tail(struct Qdisc *sch,
>  	struct sk_buff *skb = __skb_dequeue_tail(list);
>  
>  	if (likely(skb != NULL))


Rest of the patch seems fine, thanks !
