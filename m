From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sch_htb: ix the deficit overflows
Date: Sat, 28 Nov 2009 01:04:01 +0100
Message-ID: <20091128000401.GA3713@ami.dom.local>
References: <4B0F8A5D.1040806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:33405 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbZK1AEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 19:04:08 -0500
Received: by fg-out-1718.google.com with SMTP id 19so344697fgg.1
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2009 16:04:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4B0F8A5D.1040806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote, On 11/27/2009 09:14 AM:

> fix the deficit overflows.
> 
> HTB uses WDRR(Weighted Deficit Round Robin) algorithm to schedule the spare
> bandwidth, but it doesn't check if the deficit is big enough for the skb when
> dequeuing skb from a class. In some case(the quantum is smaller than the
> packet size), the deficit will be decreased, even when it is smaller than
> ZERO. At last, the deficit will overflows, and become MAX_INT.

This case of the quantum smaller than the packet size should be treated
as a broken config, so I don't think it's worth to do such a deep change
with additional delays and cpu cycles for all to fix it. A warning or
lower limit should be enough (if necessary at all).

Jarek P.

> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ----
>  sch_htb.c |   25 ++++++++++++++++++++-----
>  1 file changed, 20 insertions(+), 5 deletions(-)
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 2e38d1a..293983e 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -783,6 +783,7 @@ static struct sk_buff *htb_dequeue_tree(struct htb_sched *q, int prio,
>  {
>  	struct sk_buff *skb = NULL;
>  	struct htb_class *cl, *start;
> +	unsigned int len;
>  	/* look initial class up in the row */
>  	start = cl = htb_lookup_leaf(q->row[level] + prio, prio,
>  				     q->ptr[level] + prio,
> @@ -815,9 +816,23 @@ next:
>  			goto next;
>  		}
>  
> -		skb = cl->un.leaf.q->dequeue(cl->un.leaf.q);
> -		if (likely(skb != NULL))
> -			break;
> +		skb = cl->un.leaf.q->ops->peek(cl->un.leaf.q);
> +		if (likely(skb != NULL)) {
> +			len = qdisc_pkt_len(skb);
> +			if (len <= cl->un.leaf.deficit[level]) {
> +				skb = qdisc_dequeue_peeked(cl->un.leaf.q);
> +				break;
> +			}
> +			skb = NULL;
> +			cl->un.leaf.deficit[level] += cl->quantum;
> +			htb_next_rb_node((level ? cl->parent->un.inner.ptr :
> +					  q->ptr[0]) + prio);
> +			cl = htb_lookup_leaf(q->row[level] + prio, prio,
> +					     q->ptr[level] + prio,
> +					     q->last_ptr_id[level] + prio);
> +			start = cl;
> +			goto next;
> +		}
>  
>  		qdisc_warn_nonwc("htb", cl->un.leaf.q);
>  		htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
> @@ -829,8 +844,8 @@ next:
>  	} while (cl != start);
>  
>  	if (likely(skb != NULL)) {
> -		cl->un.leaf.deficit[level] -= qdisc_pkt_len(skb);
> -		if (cl->un.leaf.deficit[level] < 0) {
> +		cl->un.leaf.deficit[level] -= len;
> +		if (cl->un.leaf.deficit[level] <= 0) {
>  			cl->un.leaf.deficit[level] += cl->quantum;
>  			htb_next_rb_node((level ? cl->parent->un.inner.ptr : q->
>  					  ptr[0]) + prio);
> 
> --
