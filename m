From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net_sched: factorize qdisc stats handling
Date: Sat, 08 Jan 2011 14:35:31 +0100
Message-ID: <4D286823.8050707@gmail.com>
References: <20110106195614.20dbc402@nehalam>	 <AANLkTi=pqZ3CwLTAZnhd-cyQNj8OSeBHsP_bFiH3hJ-_@mail.gmail.com>	 <20110107200234.3f5e7ff8@nehalam> <1294478789.2709.79.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	netdev@vger.kernel.org, Luigi Rizzo <rizzo@iet.unipi.it>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:58944 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752353Ab1AHNfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jan 2011 08:35:38 -0500
Received: by bwz15 with SMTP id 15so18028777bwz.19
        for <netdev@vger.kernel.org>; Sat, 08 Jan 2011 05:35:36 -0800 (PST)
In-Reply-To: <1294478789.2709.79.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
...
> -static inline void __qdisc_update_bstats(struct Qdisc *sch, unsigned int len)
> +
> +static inline void bstats_update(struct gnet_stats_basic_packed *bstats,
> +				 struct sk_buff *skb)
> +{
> +	bstats->bytes += qdisc_pkt_len(skb);
> +	bstats->packets += skb_is_gso(skb) ? skb_shinfo(skb)->gso_segs : 1;
> +}
> +
> +static inline void qdisc_bstats_update(struct Qdisc *sch, struct sk_buff *skb)
>  {
> -	sch->bstats.bytes += len;
> -	sch->bstats.packets++;
> +	bstats_update(&sch->bstats, skb);
>  }
>  
>  static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
> @@ -437,7 +444,7 @@ static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct Qdisc *sch,
>  {
>  	__skb_queue_tail(list, skb);
>  	sch->qstats.backlog += qdisc_pkt_len(skb);
> -	__qdisc_update_bstats(sch, qdisc_pkt_len(skb));
> +	qdisc_bstats_update(sch, skb);
>  
>  	return NET_XMIT_SUCCESS;
>  }
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a215269..ab60f58 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2301,7 +2301,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>  		 */
>  		if (!(dev->priv_flags & IFF_XMIT_DST_RELEASE))
>  			skb_dst_force(skb);
> -		__qdisc_update_bstats(q, skb->len);
> +		qdisc_bstats_update(q, skb);
>  		if (sch_direct_xmit(skb, q, dev, txq, root_lock)) {
>  			if (unlikely(contended)) {
>  				spin_unlock(&q->busylock);

I guess you can't use qdisc_pkt_len() without qdisc_enqueue_root().

Jarek P.
