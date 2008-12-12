From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/8] ipv4: Add GRO infrastructure
Date: Sat, 13 Dec 2008 10:04:10 +1100
Message-ID: <20081212230410.GC11636@gondor.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cy-0000rD-Pr@gondolin.me.apana.org.au> <1229122540.3051.78.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35229 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751061AbYLLXEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 18:04:16 -0500
Content-Disposition: inline
In-Reply-To: <1229122540.3051.78.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 10:55:40PM +0000, Ben Hutchings wrote:
>
> > +	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
> > +		goto out;
> > +
> > +	iph = ip_hdr(skb);
> > +	proto = iph->protocol & (MAX_INET_PROTOS - 1);
> > +
> > +	rcu_read_lock();
> > +	ops = rcu_dereference(inet_protos[proto]);
> > +	if (!ops || !ops->gro_receive)
> > +		goto out_unlock;
> > +
> > +	if (iph->version != 4 || iph->ihl != 5)
> > +		goto out_unlock;
> > +
> > +	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
> > +		goto out_unlock;
> 
> Don't we also need to check that skb->len >= iph->ihl * 4?

We already did through pskb_may_pull and iph->ihl != 5.

> > +		if (iph->protocol != iph2->protocol ||
> > +		    memcmp(&iph->saddr, &iph2->saddr, 8)) {
> > +			NAPI_GRO_CB(p)->same_flow = 0;
> > +			continue;
> > +		}
> > +
> > +		/* All fields must match except length and checksum. */
> > +		NAPI_GRO_CB(p)->flush |=
> > +			memcmp(&iph->frag_off, &iph2->frag_off, 4) ||
> 
> This covers frag_off, ttl and protocol.  But frag_off and protocol have
> already been covered, and tos seems to have been missed.

No we haven't checked frag_off yet, we've only checked the DF bit.
In any case, checking twice doesn't hurt.  Good catch on the missing
tos check though.  I'll get that added.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
