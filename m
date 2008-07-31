From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net-sched: add packet length pointer parameter for
	qdisc_enqueue
Date: Thu, 31 Jul 2008 07:02:33 +0000
Message-ID: <20080731070233.GA4769@ff.dom.local>
References: <20080730185542.23727.5949.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.191]:25098 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885AbYGaG5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 02:57:17 -0400
Received: by fk-out-0910.google.com with SMTP id 18so329562fkq.5
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2008 23:57:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080730185542.23727.5949.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30-07-2008 20:55, Jussi Kivilinna wrote:
> Pass packet length to caller through pointer so that length is
> available to caller even if inner qdisc frees skb.
...
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index b5f40d7..a428b93 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -331,19 +331,22 @@ static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
>  	return qdisc_skb_cb(skb)->pkt_len;
>  }
>  
> -static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> +static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch,
> +				unsigned int *pkt_len)
>  {
>  #ifdef CONFIG_NET_SCHED
>  	if (sch->stab)
>  		qdisc_calculate_pkt_len(skb, sch->stab);
>  #endif
> +	if (likely(pkt_len != NULL))
> +		*pkt_len = qdisc_pkt_len(skb);
>  	return sch->enqueue(skb, sch);
>  }

As I've written before, IMHO using an skb after enqueuing should be
avoided unless we refcounted it or the returned code is clear enough,
so the idea of this patch could be right to me. But, I guess, you are
changing here the way it's done: the size is calculated before the
current enqueing instead of after the last one.

BTW, since I don't really get this "stab" idea enough, I wonder how
it is expected to be used: with a top qdisc, a leaf one or some
summing?

Jarek P.
