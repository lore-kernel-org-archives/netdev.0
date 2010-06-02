From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cls_u32: use skb_copy_bits() to dereference data safely
Date: Wed, 02 Jun 2010 05:45:20 -0700 (PDT)
Message-ID: <20100602.054520.228955151.davem@davemloft.net>
References: <AANLkTilkweiJPmQOUv78lKL9ohZo1StzlJcBw0johYi0@mail.gmail.com>
	<1275481219.14363.6.camel@bigi>
	<1275481538.14363.10.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51148
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758048Ab0FBMpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 08:45:11 -0400
In-Reply-To: <1275481538.14363.10.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Wed, 02 Jun 2010 08:25:38 -0400

> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -135,6 +135,9 @@ next_knode:
>  
>  for (i = n->sel.nkeys; i>0; i--, key++) {
>  
> +        int toff = key->off+(off2&key->offmask)- 4;
> +        if (unlikely(toff > skb->len))
> +              /* bailout here - needs some thought */
>          if ((*(__be32*)(ptr+key->off+(off2&key->offmask))^key->v

I don't think it's that simple.

You can't dereference from the skb->data linear area if your offset is
beyond "skb->len - skb->data_len" (aka. skb_headlen()) since that's
where the paged or fragmented portion starts.

We really need to use skb_copy_bits() if we want to allow
any offset into the SKB, and because of all the ways
packets can be transformed and constructed we absolutely
have to.

