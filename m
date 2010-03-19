From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 17:32:10 +0800
Message-ID: <20100319093210.GA23895@gondor.apana.org.au>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100319072053.GA22913@gondor.apana.org.au> <4BA32C41.2020000@iki.fi> <20100319082909.GA23363@gondor.apana.org.au> <4BA337E6.4010508@iki.fi> <20100319084717.GA23567@gondor.apana.org.au> <4BA33FF5.8010104@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39556 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750747Ab0CSJcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 05:32:14 -0400
Content-Disposition: inline
In-Reply-To: <4BA33FF5.8010104@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 19, 2010 at 11:12:21AM +0200, Timo Ter=E4s wrote:
>
>> That would be better but it's still hacky.  Proper reference
>> counting like we had before would be my preference.
>
> Well, the cache entry is still referenced only very shortly,
> I don't see why keeping bh disabled why doing it is considered
> a hack. Refcounting the cache entries is trickier. Though,
> it could be used to optimize the update process: we could safely
> update it instead of doing now lookup later.

Well we had a nicely type-agnostic cache which is self-contained,
but your patch is bleeding generic code into xfrm_policy.c, that's
why I felt it to be hacky :)

Anyway I see how your scheme works now as far as object life
is concerned, and I agree that it is safe.

However, I wonder if we could do it while still leaving all the
object life-cycle management stuff (and the BH disabling bits)
in flow.c

The crux of the issue is that you now have two objects to track
instead of one.  As the direction is a key in the lookup, we're
really only worried about the outbound case here.

So how about going back to what I suggested earlier, and keeping
a back-pointer from xfrm_dst to the policy? Of course xfrm_dst
would also hold a ref count on the policy.  You'd only have to
do it for the top-level xfrm_dst.

It does mean that you'll need to write a different resolver for
outbound vs. inbound/forward, but that makes sense because we
only use bundles for outbound policies.

What do you think?

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
