From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Fix slab corruption with netem
Date: Sat, 15 Jul 2006 08:49:32 -0700
Message-ID: <44B90E8C.5090400@osdl.org>
References: <44B8395A.1050602@yahoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16329 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750712AbWGOPtq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jul 2006 11:49:46 -0400
To: Guillaume Chazarain <guichaz@yahoo.fr>
In-Reply-To: <44B8395A.1050602@yahoo.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Guillaume Chazarain wrote:
> Hello,
>
> CONFIG_DEBUG_SLAB found the following bug:
> netem_enqueue() in sch_netem.c gets a pointer inside a slab object: 
> struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
> But then, the slab object may be freed: skb = skb_unshare(skb, 
> GFP_ATOMIC)
> cb is still pointing inside the freed skb, so here is a patch to 
> initialize cb later, and make it clear
> that initializing it sooner is a bad idea.
>
> Thanks.
>
> ------------------------------------------------------------------------
>
> --- a/net/sched/sch_netem.c
> +++ b/net/sched/sch_netem.c
> @@ -148,7 +148,8 @@ static int netem_enqueue(struct sk_buff 
>  static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  {
>  	struct netem_sched_data *q = qdisc_priv(sch);
> -	struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
> +	/* We don't fill cb now as skb_unshare() may invalidate it */
> +	struct netem_skb_cb *cb = NULL;
>   
Would rather leave it unitialized, rather than setting to NULL.
>  	struct sk_buff *skb2;
>  	int ret;
>  	int count = 1;
> @@ -200,6 +201,7 @@ static int netem_enqueue(struct sk_buff 
>  		skb->data[net_random() % skb_headlen(skb)] ^= 1<<(net_random() % 8);
>  	}
>  
> +	cb = (struct netem_skb_cb *)skb->cb;
>  	if (q->gap == 0 		/* not doing reordering */
>  	    || q->counter < q->gap 	/* inside last reordering gap */
>  	    || q->reorder < get_crandom(&q->reorder_cor)) {
>
>   

