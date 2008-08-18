From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]: Fix queueing return values...
Date: Mon, 18 Aug 2008 07:33:45 +0000
Message-ID: <20080818073344.GA5434@ff.dom.local>
References: <20080817.233211.84493222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.177]:18759 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbYHRHdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 03:33:51 -0400
Received: by ik-out-1112.google.com with SMTP id c28so2198402ika.5
        for <netdev@vger.kernel.org>; Mon, 18 Aug 2008 00:33:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080817.233211.84493222.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 11:32:11PM -0700, David Miller wrote:
> 
> I'm trying to make some further progress on this because it
> has been sitting for too long.
> 
> What I want to do at this point is fix the most obvious
> problems in order to fix those crashes that were reported,
> and do it in such a way that an easy 2.6.26-stable backport
> is there too.
> 
> After a first pass, just trying to sort out the worst cases,
> I came up with TBF and HTB that needed immediate fixes.
> 
> HTB's case has been discussed to death before, and my current
> fix is greatly simplified from my original patch.  I misread
> the logic and only that inner code block to the ->enqueue()
> and ->requeue() calls need to ensure proper return value
> propagation.  I moved all kinds of things around for no good
> reason in my original patch.
> 
> TBF is just a case of an improperly open-coded implementation
> of qdisc_reshape_fail() which corrupts the return value.
> 
> First the net-2.6 version then the version intended for
> 2.6.26-stable submission:
> 
> -------------------- net-2.6 --------------------
> pkt_sched: Fix return value corruption in HTB and TBF.
> 
> Packet schedulers should only return NET_XMIT_DROP iff
> the packet really was dropped.  If the packet does reach
> the device after we return NET_XMIT_DROP then TCP can
> crash because it depends upon the enqueue path return
> values being accurate.

I'm really happy I can see this patch at last, but it seems to miss
how it all begun, if you know what I mean:

http://marc.info/?l=linux-netdev&m=121768011703499&w=2

Jarek P.

> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 6febd24..0df0df2 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -577,7 +577,7 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  			sch->qstats.drops++;
>  			cl->qstats.drops++;
>  		}
> -		return NET_XMIT_DROP;
> +		return ret;
>  	} else {
>  		cl->bstats.packets +=
>  			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
> @@ -623,7 +623,7 @@ static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
>  			sch->qstats.drops++;
>  			cl->qstats.drops++;
>  		}
> -		return NET_XMIT_DROP;
> +		return ret;
>  	} else
>  		htb_activate(q, cl);
>  
> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index 7d3b7ff..94c6159 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
> @@ -123,15 +123,8 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>  	struct tbf_sched_data *q = qdisc_priv(sch);
>  	int ret;
>  
> -	if (qdisc_pkt_len(skb) > q->max_size) {
> -		sch->qstats.drops++;
> -#ifdef CONFIG_NET_CLS_ACT
> -		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
> -#endif
> -			kfree_skb(skb);
> -
> -		return NET_XMIT_DROP;
> -	}
> +	if (qdisc_pkt_len(skb) > q->max_size)
> +		return qdisc_reshape_fail(skb, sch);
>  
>  	ret = qdisc_enqueue(skb, q->qdisc);
>  	if (ret != 0) {
> 
> -------------------- 2.6.26-stable --------------------
> pkt_sched: Fix return value corruption in HTB and TBF.
> 
> Packet schedulers should only return NET_XMIT_DROP iff
> the packet really was dropped.  If the packet does reach
> the device after we return NET_XMIT_DROP then TCP can
> crash because it depends upon the enqueue path return
> values being accurate.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 3fb58f4..51c3f68 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -595,11 +595,13 @@ static int htb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  		kfree_skb(skb);
>  		return ret;
>  #endif
> -	} else if (cl->un.leaf.q->enqueue(skb, cl->un.leaf.q) !=
> +	} else if ((ret = cl->un.leaf.q->enqueue(skb, cl->un.leaf.q)) !=
>  		   NET_XMIT_SUCCESS) {
> -		sch->qstats.drops++;
> -		cl->qstats.drops++;
> -		return NET_XMIT_DROP;
> +		if (ret == NET_XMIT_DROP) {
> +			sch->qstats.drops++;
> +			cl->qstats.drops++;
> +		}
> +		return ret;
>  	} else {
>  		cl->bstats.packets +=
>  			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
> @@ -639,11 +641,13 @@ static int htb_requeue(struct sk_buff *skb, struct Qdisc *sch)
>  		kfree_skb(skb);
>  		return ret;
>  #endif
> -	} else if (cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q) !=
> +	} else if ((ret = cl->un.leaf.q->ops->requeue(skb, cl->un.leaf.q)) !=
>  		   NET_XMIT_SUCCESS) {
> -		sch->qstats.drops++;
> -		cl->qstats.drops++;
> -		return NET_XMIT_DROP;
> +		if (ret == NET_XMIT_DROP) {
> +			sch->qstats.drops++;
> +			cl->qstats.drops++;
> +		}
> +		return ret;
>  	} else
>  		htb_activate(q, cl);
>  
> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index 0b7d78f..fc6f8f3 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
> @@ -123,15 +123,8 @@ static int tbf_enqueue(struct sk_buff *skb, struct Qdisc* sch)
>  	struct tbf_sched_data *q = qdisc_priv(sch);
>  	int ret;
>  
> -	if (skb->len > q->max_size) {
> -		sch->qstats.drops++;
> -#ifdef CONFIG_NET_CLS_ACT
> -		if (sch->reshape_fail == NULL || sch->reshape_fail(skb, sch))
> -#endif
> -			kfree_skb(skb);
> -
> -		return NET_XMIT_DROP;
> -	}
> +	if (skb->len > q->max_size)
> +		return qdisc_reshape_fail(skb, sch);
>  
>  	if ((ret = q->qdisc->enqueue(skb, q->qdisc)) != 0) {
>  		sch->qstats.drops++;
> --------------------
