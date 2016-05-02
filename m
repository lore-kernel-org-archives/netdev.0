From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] fq_codel: add batch ability to fq_codel_drop()
Date: Mon, 2 May 2016 09:49:54 +0200
Message-ID: <20160502094954.24cc9549@redhat.com>
References: <1462146446.5535.236.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Dave Taht <dave.taht@gmail.com>,
	Jonathan Morton <chromatix99@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36177 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164AbcEBHuA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 May 2016 03:50:00 -0400
In-Reply-To: <1462146446.5535.236.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 01 May 2016 16:47:26 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> In presence of inelastic flows and stress, we can call
> fq_codel_drop() for every packet entering fq_codel qdisc.
> 
> fq_codel_drop() is quite expensive, as it does a linear scan
> of 4 KB of memory to find a fat flow.
> Once found, it drops the oldest packet of this flow.
> 
> Instead of dropping a single packet, try to drop 50% of the backlog
> of this fat flow, with a configurable limit of 64 packets per round.
> 
> TCA_FQ_CODEL_DROP_BATCH_SIZE is the new attribute to make this
> limit configurable.
> 
> With this strategy the 4 KB search is amortized to a single cache line
> per drop [1], so fq_codel_drop() no longer appears at the top of kernel
> profile in presence of few inelastic flows.
> 
> [1] Assuming a 64byte cache line, and 1024 buckets
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dave Taht <dave.taht@gmail.com>
> Cc: Jonathan Morton <chromatix99@gmail.com>
> ---
>  include/uapi/linux/pkt_sched.h |    1 
>  net/sched/sch_fq_codel.c       |   64 +++++++++++++++++++++----------
>  2 files changed, 46 insertions(+), 19 deletions(-)
> 
> diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
> index 1c78c7454c7c..a11afecd4482 100644
> --- a/include/uapi/linux/pkt_sched.h
> +++ b/include/uapi/linux/pkt_sched.h
> @@ -718,6 +718,7 @@ enum {
>  	TCA_FQ_CODEL_FLOWS,
>  	TCA_FQ_CODEL_QUANTUM,
>  	TCA_FQ_CODEL_CE_THRESHOLD,
> +	TCA_FQ_CODEL_DROP_BATCH_SIZE,
>  	__TCA_FQ_CODEL_MAX
>  };
>  
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index a5e420b3d4ab..e7b42b0d5145 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -59,6 +59,7 @@ struct fq_codel_sched_data {
>  	u32		flows_cnt;	/* number of flows */
>  	u32		perturbation;	/* hash perturbation */
>  	u32		quantum;	/* psched_mtu(qdisc_dev(sch)); */
> +	u32		drop_batch_size;
>  	struct codel_params cparams;
>  	struct codel_stats cstats;
>  	u32		drop_overlimit;
> @@ -135,17 +136,20 @@ static inline void flow_queue_add(struct fq_codel_flow *flow,
>  	skb->next = NULL;
>  }
>  
> -static unsigned int fq_codel_drop(struct Qdisc *sch)
> +static unsigned int fq_codel_drop(struct Qdisc *sch, unsigned int max_packets)
>  {
>  	struct fq_codel_sched_data *q = qdisc_priv(sch);
>  	struct sk_buff *skb;
>  	unsigned int maxbacklog = 0, idx = 0, i, len;
>  	struct fq_codel_flow *flow;
> +	unsigned int threshold;
>  
> -	/* Queue is full! Find the fat flow and drop packet from it.
> +	/* Queue is full! Find the fat flow and drop packet(s) from it.
>  	 * This might sound expensive, but with 1024 flows, we scan
>  	 * 4KB of memory, and we dont need to handle a complex tree
>  	 * in fast path (packet queue/enqueue) with many cache misses.
> +	 * In stress mode, we'll try to drop 64 packets from the flow,
> +	 * amortizing this linear lookup to one cache line per drop.
>  	 */
>  	for (i = 0; i < q->flows_cnt; i++) {
>  		if (q->backlogs[i] > maxbacklog) {
> @@ -153,15 +157,24 @@ static unsigned int fq_codel_drop(struct Qdisc *sch)
>  			idx = i;
>  		}
>  	}
> +
> +	/* Our goal is to drop half of this fat flow backlog */
> +	threshold = maxbacklog >> 1;
> +
>  	flow = &q->flows[idx];
> -	skb = dequeue_head(flow);
> -	len = qdisc_pkt_len(skb);
> +	len = 0;
> +	i = 0;
> +	do {
> +		skb = dequeue_head(flow);
> +		len += qdisc_pkt_len(skb);
> +		kfree_skb(skb);
> +	} while (++i < max_packets && len < threshold);
> +
> +	flow->dropped += i;

What about using bulk free of SKBs here?

There is a very high probability that we are hitting SLUB slowpath,
which involves an expensive locked cmpxchg_double per packet.  Instead
we can amortize this cost via kmem_cache_free_bulk().

Maybe extend kfree_skb_list() to hide the slab/kmem_cache call?


>  	q->backlogs[idx] -= len;
> -	sch->q.qlen--;
> -	qdisc_qstats_drop(sch);
> -	qdisc_qstats_backlog_dec(sch, skb);
> -	kfree_skb(skb);
> -	flow->dropped++;
> +	sch->qstats.drops += i;
> +	sch->qstats.backlog -= len;
> +	sch->q.qlen -= i;
>  	return idx;
>  }
>  

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
