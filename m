From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/8] net: Add frag_list support to skb_segment
Date: Sat, 13 Dec 2008 08:41:25 +1100
Message-ID: <20081212214125.GA11046@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cv-0000qk-Ec@gondolin.me.apana.org.au> <20081212194618.GA27281@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56544 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753088AbYLLVld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 16:41:33 -0500
Content-Disposition: inline
In-Reply-To: <20081212194618.GA27281@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 10:46:18PM +0300, Evgeniy Polyakov wrote:
> 
> On Fri, Dec 12, 2008 at 04:31:49PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > @@ -2317,9 +2317,34 @@ struct sk_buff *skb_segment(struct sk_buff *skb, int features)
> >  		if (hsize > len || !sg)
> >  			hsize = len;
> >  
> > -		nskb = alloc_skb(hsize + doffset + headroom, GFP_ATOMIC);
> > -		if (unlikely(!nskb))
> > -			goto err;
> > +		if (!hsize && i >= nfrags) {
> > +			BUG_ON(fskb->len != len);
> > +
> > +			pos += len;
> > +			nskb = skb_clone(fskb, GFP_ATOMIC);
> > +			fskb = fskb->next;
> > +
> > +			if (unlikely(!nskb))
> > +				goto err;
> > +
> > +			hsize = skb_end_pointer(nskb) - nskb->head;
> > +			if (skb_cow_head(nskb, doffset + headroom))
> > +				goto err;
> 
> This should free nskb first.

Good catch! I'll get this fixed.

> > +			nskb->truesize += skb_end_pointer(nskb) - nskb->head -
> > +					  hsize;
> > +			skb_release_head_state(nskb);
> > +			__skb_push(nskb, doffset);
> > +		} else {
> > +			nskb = alloc_skb(hsize + doffset + headroom,
> > +					 GFP_ATOMIC);
> > +
> > +			if (unlikely(!nskb))
> > +				goto err;
> > +
> 
> The same.

nskb is NULL here.

> > +		if (pos < offset + len) {
> > +			struct sk_buff *fskb2 = fskb;
> > +
> > +			BUG_ON(pos + fskb->len != offset + len);
> > +
> > +			pos += fskb->len;
> > +			fskb = fskb->next;
> > +
> > +			if (fskb2->next) {
> > +				fskb2 = skb_clone(fskb2, GFP_ATOMIC);
> > +				if (!fskb2)
> > +					goto err;
> > +			} else
> > +				skb_get(fskb2);
> > +
> > +			skb_shinfo(nskb)->frag_list = fskb2;
> 
> Is it guaranteed that nskb does not have frags here?

This bit only gets executed the first time we hit the frag_list
in the original skb.  Therefore we've just allocated nskb for
the very first time.  I'll add a BUG_ON for you :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
