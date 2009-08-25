From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: iproute2 / tbf with large burst seems broken again
Date: Tue, 25 Aug 2009 12:13:44 +0000
Message-ID: <20090825121344.GA12320@ff.dom.local>
References: <20090825062203.GA5381@ff.dom.local> <20090825090035.GB7879@ff.dom.local> <20090825094120.GA11478@ff.dom.local> <200908251416.13888.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:34408 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbZHYMNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 08:13:48 -0400
Received: by bwz19 with SMTP id 19so2022487bwz.37
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 05:13:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200908251416.13888.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2009 at 02:16:13PM +0300, Denys Fedoryschenko wrote:
> Done, tested, it doesn't stale and fix the issue but:
> 
> PPPoE_146 ~ # ./tc qdisc del dev ppp13 root;./tc qdisc add dev ppp13 root tbf 
> rate 96000 burst 2048000 latency 500ms                                               
> 
> This one is ok
> PPPoE_146 ~ # ./tc -s -d qdisc show dev ppp13
> qdisc tbf 8005: root rate 96000bit burst 2000Kb/8 mpu 0b lat 500.0ms
>  Sent 55260 bytes 65 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc ingress ffff: parent ffff:fff1 ----------------
>  Sent 641055 bytes 2485 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> 
> PPPoE_146 ~ # ./tc qdisc del dev ppp13 root;./tc qdisc add dev ppp13 root tbf 
> rate 96000 burst 4096000 latency 500ms                                               
> 
> But this one maybe will overflow because of limitations in iproute2.

Sure, as I wrote before:
"It shouldn't be so difficult just for 2000kb buffer here, but of course
there're some limits."
I tried to optimize sch_tbf variables usage only, but this is still
mostly within 32 bits.

> 
> PPoE_146 ~ # ./tc -s -d qdisc show dev ppp13
> qdisc tbf 8004: root rate 96000bit burst 797465b/8 mpu 0b lat 275.4s
>  Sent 82867 bytes 123 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> qdisc ingress ffff: parent ffff:fff1 ----------------
>  Sent 506821 bytes 1916 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 0bit 0pps backlog 0b 0p requeues 0
> 
> So maybe all of that just wrong way of using TBF.
> At same time this means, if HTB and policers in filters done same way, that 
> QoS in Linux cannot do similar to squid delay pools feature:
> 
> First 10Mb give with 1Mbit/s, then slow 64Kbit/s. If user use less than 64K - 
> recharge with that unused bandwidth a "10 Mb / 1Mbit bucket".

I'll need to find more time to rethink your problem (and this patch),
because it really looks like your tbf usage is very uncommon. Anyway,
I guess these changes aren't for 2.6.31, unless there're similar
requests from other users soon.

Thanks for testing,
Jarek P.

> 
> On Tuesday 25 August 2009 12:41:20 Jarek Poplawski wrote:
> > On Tue, Aug 25, 2009 at 09:00:35AM +0000, Jarek Poplawski wrote:
> > > On Tue, Aug 25, 2009 at 08:43:06AM +0000, Jarek Poplawski wrote:
> > > ...
> > >
> > > > since these 64 bits will be needed soon for higher rates anyway, I
> > > > guess we could try some change like the patch below, if you find it
> > > > works for you (I didn't test it yet.)
> >
> > I hope this time it works...
> >
> > Jarek P.
> >
> > --- (take 2)
> >
> >  net/sched/sch_tbf.c |   14 +++++++-------
> >  1 files changed, 7 insertions(+), 7 deletions(-)
> >
> > diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> > index e22dfe8..7d0fe69 100644
> > --- a/net/sched/sch_tbf.c
> > +++ b/net/sched/sch_tbf.c
> > @@ -108,8 +108,8 @@ struct tbf_sched_data
> >  	struct qdisc_rate_table	*P_tab;
> >
> >  /* Variables */
> > -	long	tokens;			/* Current number of B tokens */
> > -	long	ptokens;		/* Current number of P tokens */
> > +	u32	tokens;			/* Current number of B tokens */
> > +	u32	ptokens;		/* Current number of P tokens */
> >  	psched_time_t	t_c;		/* Time check-point */
> >  	struct Qdisc	*qdisc;		/* Inner qdisc, default - bfifo queue */
> >  	struct qdisc_watchdog watchdog;	/* Watchdog timer */
> > @@ -160,21 +160,21 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
> >
> >  	if (skb) {
> >  		psched_time_t now;
> > -		long toks;
> > -		long ptoks = 0;
> > +		long long toks;
> > +		long long ptoks = 0;
> >  		unsigned int len = qdisc_pkt_len(skb);
> >
> >  		now = psched_get_time();
> > -		toks = psched_tdiff_bounded(now, q->t_c, q->buffer);
> > +		toks = min_t(u32, now - q->t_c, q->buffer);
> >
> >  		if (q->P_tab) {
> >  			ptoks = toks + q->ptokens;
> > -			if (ptoks > (long)q->mtu)
> > +			if (ptoks > q->mtu)
> >  				ptoks = q->mtu;
> >  			ptoks -= L2T_P(q, len);
> >  		}
> >  		toks += q->tokens;
> > -		if (toks > (long)q->buffer)
> > +		if (toks > q->buffer)
> >  			toks = q->buffer;
> >  		toks -= L2T(q, len);
> 
> 
