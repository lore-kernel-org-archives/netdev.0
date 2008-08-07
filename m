From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb
Date: Thu, 7 Aug 2008 06:24:36 +0000
Message-ID: <20080807062436.GA4256@ff.dom.local>
References: <20080806224248.18266k9ahc5nkk8w@hayate.ip6> <20080806215258.GA3306@ami.dom.local> <20080806.202636.246995904.davem@davemloft.net> <20080806.220911.91192536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jussi.kivilinna@mbnet.fi, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:18486 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbYHGGTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 02:19:10 -0400
Received: by ug-out-1314.google.com with SMTP id h2so298667ugf.16
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2008 23:19:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080806.220911.91192536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 06, 2008 at 10:09:11PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 06 Aug 2008 20:26:36 -0700 (PDT)
> 
> > 
> > I still haven't seen anyone suggest creating a __NET_XMIT_KFREE_SKB to
> > fix this most rediculious problem.
> > 
> > I'm still waiting...
> 
> Here is what it might look like.  I haven't tried to boot this,
> but the only non-trivial case was SFQ's congestion drop code.
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index a7abfda..4bfee1b 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -347,6 +347,7 @@ static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
>  enum net_xmit_qdisc_t {
>  	__NET_XMIT_STOLEN = 0x00010000,
>  	__NET_XMIT_BYPASS = 0x00020000,
> +	__NET_XMIT_KFREE  = 0x00040000,
>  };
>  
>  #ifdef CONFIG_NET_CLS_ACT
> @@ -366,8 +367,15 @@ static inline int qdisc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>  
>  static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
>  {
> +	int ret;
> +
>  	qdisc_skb_cb(skb)->pkt_len = skb->len;
> -	return qdisc_enqueue(skb, sch) & NET_XMIT_MASK;
> +	ret = qdisc_enqueue(skb, sch);
> +
> +	if (unlikely(ret & __NET_XMIT_KFREE))
> +		kfree_skb(skb);

Looks very interesting, but isn't there possible a little optimization?
If (almost?) everything not NET_XMIT_SUCCESS does this maybe?:

 	if (unlikely(ret != NET_XMIT_SUCCESS))
 		kfree_skb(skb);
or:
 	if (unlikely(ret != NET_XMIT_SUCCESS &&
			 !(ret & __NET_XMIT_SKIP_KFREE)))
 		kfree_skb(skb);

Anyway, it's quite a bit of change, so I definitely need more time to
check this (after awakening...).

Jarek P.

> +
> +	return ret & NET_XMIT_MASK;
>  }
...
