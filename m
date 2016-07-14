From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH v2 08/10] net: sched: pfifo_fast use alf_queue
Date: Thu, 14 Jul 2016 17:11:48 +0200
Message-ID: <20160714171148.3bb7b47b@redhat.com>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
	<20160714062312.8270.65942.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751051AbcGNPLx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 11:11:53 -0400
In-Reply-To: <20160714062312.8270.65942.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Jul 2016 23:23:12 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> This converts the pfifo_fast qdisc to use the alf_queue enqueue and
> dequeue routines then sets the NOLOCK bit.

Should have said skb_array, not alf_queue ;-)

 > This also removes the logic used to pick the next band to dequeue from
> and instead just checks each alf_queue for packets from top priority
> to lowest. This might need to be a bit more clever but seems to work
> for now.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  net/sched/sch_generic.c |  131 +++++++++++++++++++++++++++--------------------
>  1 file changed, 75 insertions(+), 56 deletions(-)
> 
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 7dcd066..2ac3eb9 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -26,6 +26,7 @@
>  #include <linux/list.h>
>  #include <linux/slab.h>
>  #include <linux/if_vlan.h>
> +#include <linux/skb_array.h>
>  #include <net/sch_generic.h>
>  #include <net/pkt_sched.h>
>  #include <net/dst.h>
> @@ -555,88 +556,79 @@ static const u8 prio2band[TC_PRIO_MAX + 1] = {
>  
>  /*
>   * Private data for a pfifo_fast scheduler containing:
> - * 	- queues for the three band
> - * 	- bitmap indicating which of the bands contain skbs
> + *	- rings for priority bands
>   */
>  struct pfifo_fast_priv {
> -	u32 bitmap;
> -	struct sk_buff_head q[PFIFO_FAST_BANDS];
> +	struct skb_array q[PFIFO_FAST_BANDS];
>  };
>  
> -/*
> - * Convert a bitmap to the first band number where an skb is queued, where:
> - * 	bitmap=0 means there are no skbs on any band.
> - * 	bitmap=1 means there is an skb on band 0.
> - *	bitmap=7 means there are skbs on all 3 bands, etc.
> - */
> -static const int bitmap2band[] = {-1, 0, 1, 0, 2, 0, 1, 0};
> -
> -static inline struct sk_buff_head *band2list(struct pfifo_fast_priv *priv,
> -					     int band)
> +static inline struct skb_array *band2list(struct pfifo_fast_priv *priv,
> +					  int band)
>  {
> -	return priv->q + band;
> +	return &priv->q[band];
>  }
>  
>  static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
>  			      struct sk_buff **to_free)
>  {
> -	if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) {
> -		int band = prio2band[skb->priority & TC_PRIO_MAX];
> -		struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
> -		struct sk_buff_head *list = band2list(priv, band);
> -
> -		priv->bitmap |= (1 << band);
> -		qdisc->q.qlen++;
> -		return __qdisc_enqueue_tail(skb, qdisc, list);
> -	}
> +	int band = prio2band[skb->priority & TC_PRIO_MAX];
> +	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
> +	struct skb_array *q = band2list(priv, band);
> +	int err;
>  
> -	return qdisc_drop(skb, qdisc, to_free);
> +	err = skb_array_produce_bh(q, skb);

Do you need the _bh variant here?  (Doesn't the qdisc run with BH disabled?)


> +
> +	if (unlikely(err))
> +		return qdisc_drop_cpu(skb, qdisc, to_free);
> +
> +	qdisc_qstats_cpu_qlen_inc(qdisc);
> +	qdisc_qstats_cpu_backlog_inc(qdisc, skb);
> +	return NET_XMIT_SUCCESS;
>  }
>  
>  static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
>  {
>  	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
> -	int band = bitmap2band[priv->bitmap];
> +	struct sk_buff *skb = NULL;
> +	int band;
>  
> -	if (likely(band >= 0)) {
> -		struct sk_buff_head *list = band2list(priv, band);
> -		struct sk_buff *skb = __qdisc_dequeue_head(qdisc, list);
> +	for (band = 0; band < PFIFO_FAST_BANDS && !skb; band++) {
> +		struct skb_array *q = band2list(priv, band);
>  
> -		qdisc->q.qlen--;
> -		if (skb_queue_empty(list))
> -			priv->bitmap &= ~(1 << band);
> +		if (__skb_array_empty(q))
> +			continue;
>  
> -		return skb;
> +		skb = skb_array_consume_bh(q);

Also _bh variant.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
