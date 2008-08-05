From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Tue, 5 Aug 2008 17:50:01 +0200
Message-ID: <20080805155001.GA2526@ami.dom.local>
References: <20080731171431.GA9464@ami.dom.local> <4892AA16.40706@trash.net> <20080801101929.GA12735@ff.dom.local> <20080803.182524.240976246.davem@davemloft.net> <20080804062813.GA4570@ff.dom.local> <20080804213535.14214iqhxkx3v3so@hayate.ip6> <20080804210333.GA2849@ami.dom.local> <20080805154350.27523juch31xgjcw@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:1393 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761077AbYHEPuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 11:50:06 -0400
Received: by nf-out-0910.google.com with SMTP id d3so939018nfc.21
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 08:50:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080805154350.27523juch31xgjcw@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 05, 2008 at 03:43:50PM +0300, Jussi Kivilinna wrote:
> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
>
>> On Mon, Aug 04, 2008 at 09:35:35PM +0300, Jussi Kivilinna wrote:
>>> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
>>>
>>> This seems to also make sure that when returning 'full'
>>> NET_XMIT_SUCCESS, skb pointer is safe(r?) to use now.
>>
>> I guess so... At least theoretically - I was mainly afraid of
>> redirecting, which isn't fully implemented yet. On the other hand,
>> outwards of qdiscs there is still no difference.
>>
>
> How about making skb shared before passing into qdisc tree?
> That would make skb usage safe after qdisc enqueues.

It's a bit costly (atomics), so there should be a good reason for this.
It should be first checked if there is real danger. And if it's only
for more exact stats, I'm not sure it's worth of it.

Jarek P.

>
> ---
>
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index c5bb130..9cf06fc 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -352,10 +352,16 @@ static inline int qdisc_enqueue(struct sk_buff  
> *skb, struct Qdisc *sch)
>         return sch->enqueue(skb, sch);
>  }
>
> -static inline int qdisc_enqueue_root(struct sk_buff *skb, struct Qdisc *sch)
> +static inline int qdisc_enqueue_root(struct sk_buff *__skb, struct  
> Qdisc *sch)
>  {
> +       struct sk_buff *skb = skb_get(__skb);
> +       int ret;
> +
>         qdisc_skb_cb(skb)->pkt_len = skb->len;
> -       return qdisc_enqueue(skb, sch);
> +       ret = qdisc_enqueue(skb, sch);
> +       kfree_skb(skb);
> +
> +       return ret;
>  }
>
>  static inline int __qdisc_enqueue_tail(struct sk_buff *skb, struct  
> Qdisc *sch,
>
