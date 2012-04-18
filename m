From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid expensive pskb_expand_head() calls
Date: Wed, 18 Apr 2012 21:49:27 +0200
Message-ID: <1334778567.2472.330.camel@edumazet-glaptop>
References: <1334653608.6226.11.camel@edumazet-laptop>
	 <1334654187.2696.2.camel@jtkirshe-mobl> <4F8D93E1.9090000@intel.com>
	 <1334681204.2472.41.camel@edumazet-glaptop>
	 <1334698722.2472.71.camel@edumazet-glaptop>
	 <1334764184.2472.299.camel@edumazet-glaptop>
	 <CAGK4HS-jrsy2kxJUeYo+JR9CBfOFqyzBgqa+OzC85yQbaWmFoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:60620 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123Ab2DRTtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 15:49:33 -0400
Received: by bkcik5 with SMTP id ik5so5796734bkc.19
        for <netdev@vger.kernel.org>; Wed, 18 Apr 2012 12:49:31 -0700 (PDT)
In-Reply-To: <CAGK4HS-jrsy2kxJUeYo+JR9CBfOFqyzBgqa+OzC85yQbaWmFoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-18 at 12:41 -0700, Vijay Subramanian wrote:
> >  {
> >        if (skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
> >                return -ENOMEM;
> > @@ -1134,6 +1138,7 @@ int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
> >        __pskb_trim_head(skb, len);
> >
> >        TCP_SKB_CB(skb)->seq += len;
> > +       TCP_SKB_CB(skb)->header.offset_ack = 0;
> >        skb->ip_summed = CHECKSUM_PARTIAL;
> >
> >        skb->truesize        -= len;
> >
> 
> Eric,
> tcp_trim_head() also updates skb->truesize as above. But is this the
> right thing to do when only offsets/pointers are updated. If
> __pskb_trim_head() removes len bytes but does not actually free
> memory,
> should truesize be updated?  This could happen if data in the linear
> part is acked.  This behavior takes place currently even without your
> patch, by the way.
> 

Thats ok.

__pskb_trim_head() callers are responsible for taking care of truesize
changes.

By the way, its always complex to guess truesize changes. removing some
bytes in skb head doesnt free memory, so in fact we should not change
truesize in this case.

But only one skb in tcp write queue might have a slightly wrong
truesize, its not a big deal.

Problem with skb->truesize is mostly in input path, when first
skb->truesize is not correctly set by drivers, upper stack can
accumulate errors in socket receive queue.
