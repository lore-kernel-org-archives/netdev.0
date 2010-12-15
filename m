From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net_sched: sch_sfq: fix allot handling
Date: Wed, 15 Dec 2010 17:03:14 +0100
Message-ID: <4D08E6C2.804@trash.net>
References: <1292421783.3427.232.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54159 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565Ab0LOQDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 11:03:17 -0500
In-Reply-To: <1292421783.3427.232.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.12.2010 15:03, Eric Dumazet wrote:
> When deploying SFQ/IFB here at work, I found the allot management was
> pretty wrong in sfq, even changing allot from short to int...
> 
> We should init allot for each new flow turn, not using a previous value,
> or else small packets can easily make allot overflow.
> 
> Before patch, I saw burst of several packets per flow, apparently
> denying the "allot 1514" limit I had on my SFQ class.
> 
> class sfq 11:1 parent 11: 
>  (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 7p requeues 0 
>  allot 11546 
> 
> class sfq 11:46 parent 11: 
>  (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 1p requeues 0 
>  allot -23873 
> 
> class sfq 11:78 parent 11: 
>  (dropped 0, overlimits 0 requeues 0) 
>  backlog 0b 5p requeues 0 
>  allot 11393 

These values definitely look wrong.

> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
> index 3cf478d..8c8a190 100644
> --- a/net/sched/sch_sfq.c
> +++ b/net/sched/sch_sfq.c
> @@ -270,7 +270,7 @@ static unsigned int sfq_drop(struct Qdisc *sch)
>  		/* It is difficult to believe, but ALL THE SLOTS HAVE LENGTH 1. */
>  		d = q->next[q->tail];
>  		q->next[q->tail] = q->next[d];
> -		q->allot[q->next[d]] += q->quantum;
> +		q->allot[q->next[d]] = q->quantum;
>  		skb = q->qs[d].prev;
>  		len = qdisc_pkt_len(skb);
>  		__skb_unlink(skb, &q->qs[d]);

I'm not sure about this part, but lets ignore that for now since it
shouldn't affect your testcase unless you're using CBQ.

> @@ -321,14 +321,13 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  	sfq_inc(q, x);
>  	if (q->qs[x].qlen == 1) {		/* The flow is new */
>  		if (q->tail == SFQ_DEPTH) {	/* It is the first flow */
> -			q->tail = x;
>  			q->next[x] = x;
> -			q->allot[x] = q->quantum;
>  		} else {
>  			q->next[x] = q->next[q->tail];
>  			q->next[q->tail] = x;
> -			q->tail = x;
>  		}
> +		q->tail = x;
> +		q->allot[x] = q->quantum;
>  	}

This looks correct, for new flows allot should be initialized from
scratch.

>  	if (++sch->q.qlen <= q->limit) {
>  		sch->bstats.bytes += qdisc_pkt_len(skb);
> @@ -382,11 +381,11 @@ sfq_dequeue(struct Qdisc *sch)
>  			return skb;
>  		}
>  		q->next[q->tail] = a;
> -		q->allot[a] += q->quantum;
> +		q->allot[a] = q->quantum;

The allot initialization doesn't seem necessary anymore at all
now that you're reinitalizing allot for flows that became active
unconditionally in sfq_enqueue().

>  	} else if ((q->allot[a] -= qdisc_pkt_len(skb)) <= 0) {
>  		q->tail = a;
>  		a = q->next[a];
> -		q->allot[a] += q->quantum;
> +		q->allot[a] = q->quantum;

This seems to break long-term fairness for active flows by not
accounting for overshooting the allotment in the next round
anymore.

I think either the change in sfq_enqueue() or the first change
in sfq_dequeue() should be enough to fix the problem you're seeing.
Basically what needs to be done is initialize allot once from
scratch when the flow becomes active, then add one quantum per
round while it stays active.
