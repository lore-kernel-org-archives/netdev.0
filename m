From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Sat, 20 Mar 2010 23:17:51 +0800
Message-ID: <20100320151751.GB2950@gondor.apana.org.au>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100319072053.GA22913@gondor.apana.org.au> <4BA32C41.2020000@iki.fi> <20100319082909.GA23363@gondor.apana.org.au> <4BA337E6.4010508@iki.fi> <20100319084717.GA23567@gondor.apana.org.au> <4BA33FF5.8010104@iki.fi> <20100319093210.GA23895@gondor.apana.org.au> <4BA349A8.9050105@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37138 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752210Ab0CTPRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 11:17:54 -0400
Content-Disposition: inline
In-Reply-To: <4BA349A8.9050105@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 19, 2010 at 11:53:44AM +0200, Timo Ter=E4s wrote:
>
> But now, thinking more, it would probably make more sense to
> just cache xfrm_dst's and keep ref to the policy on them. So
> in general I agree with your recommendation. The only immediate
> problem I can think now is that the resolved would need to
> atomically check if xfrm_dst is valid, if not, resolve new one.
> But creating new xfrm_dst involves taking locks and can sleep
> so it cannot be inside the main resolver.

OK this brings out my favourite topic :)

The reason we have to sleep is to resolve the template.  So if
we had queueing for pending xfrm_dst objects, we wouldn't have
to sleep at all when creating the top-level xfrm_dst.

Packets using that xfrm_dst can wait in the queue until it is
fully resolved.  Now obviously this code doesn't exist so this
is all just a wet dream.

Setting my favourite topic aside, I have to come to the conclusion
that your patch still doesn't fully resolve the problem you set out
to fix.

The crux of the issue is the linked list of all bundles in a
policy and the obvious problems stemming from walking a linked
list that is unbounded.

The reason I think it doesn't fully resolve this is because of
the flow cache.  Being a per-cpu cache, when you create the xfrm
dst the first time around, you'll at most put it in one CPU's
cache.

The next CPU that comes along will still have to walk that same
bundle linked list.  So we're back to square one.

Now Dave, my impression is that we picked the per-cpu design
because it was the best data structure we had back in 2002,
right?

If so I'd like us to think about the possibility of switching
over to a different design, in particular, an RCU-based hash
table, similar to the one I just used for bridge multicasting.

This would eliminate the need for walking the bundle list apart
from the case when we're destroying the policy, which can be
done in process context.

Actually I just realised that the other way we can fix this is
to make xfrm_dst objects per-cpu just like IPv4 routes.  That
is, when you fail to find an xfrm_dst object in the per-cpu
cache, you dont' bother calling xfrm_find_bundle but just make
a new bundle.

This is probably much easier than replacing the whole flow cache.
Can any one think of any problems with duplicate xfrm_dst objects?

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
