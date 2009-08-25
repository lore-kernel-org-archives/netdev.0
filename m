From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: iproute2 / tbf with large burst seems broken again
Date: Tue, 25 Aug 2009 13:29:55 +0300
Message-ID: <200908251329.55761.denys@visp.net.lb>
References: <20090825062203.GA5381@ff.dom.local> <20090825090035.GB7879@ff.dom.local> <20090825094120.GA11478@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:44035 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754799AbZHYKcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 06:32:50 -0400
In-Reply-To: <20090825094120.GA11478@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks a lot for your help! 
I will try now.

On Tuesday 25 August 2009 12:41:20 Jarek Poplawski wrote:
> On Tue, Aug 25, 2009 at 09:00:35AM +0000, Jarek Poplawski wrote:
> > On Tue, Aug 25, 2009 at 08:43:06AM +0000, Jarek Poplawski wrote:
> > ...
> >
> > > since these 64 bits will be needed soon for higher rates anyway, I
> > > guess we could try some change like the patch below, if you find it
> > > works for you (I didn't test it yet.)
>
> I hope this time it works...
>
> Jarek P.
>
> --- (take 2)
>
>  net/sched/sch_tbf.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index e22dfe8..7d0fe69 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
> @@ -108,8 +108,8 @@ struct tbf_sched_data
>  	struct qdisc_rate_table	*P_tab;
>
>  /* Variables */
> -	long	tokens;			/* Current number of B tokens */
> -	long	ptokens;		/* Current number of P tokens */
> +	u32	tokens;			/* Current number of B tokens */
> +	u32	ptokens;		/* Current number of P tokens */
>  	psched_time_t	t_c;		/* Time check-point */
>  	struct Qdisc	*qdisc;		/* Inner qdisc, default - bfifo queue */
>  	struct qdisc_watchdog watchdog;	/* Watchdog timer */
> @@ -160,21 +160,21 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
>
>  	if (skb) {
>  		psched_time_t now;
> -		long toks;
> -		long ptoks = 0;
> +		long long toks;
> +		long long ptoks = 0;
>  		unsigned int len = qdisc_pkt_len(skb);
>
>  		now = psched_get_time();
> -		toks = psched_tdiff_bounded(now, q->t_c, q->buffer);
> +		toks = min_t(u32, now - q->t_c, q->buffer);
>
>  		if (q->P_tab) {
>  			ptoks = toks + q->ptokens;
> -			if (ptoks > (long)q->mtu)
> +			if (ptoks > q->mtu)
>  				ptoks = q->mtu;
>  			ptoks -= L2T_P(q, len);
>  		}
>  		toks += q->tokens;
> -		if (toks > (long)q->buffer)
> +		if (toks > q->buffer)
>  			toks = q->buffer;
>  		toks -= L2T(q, len);


