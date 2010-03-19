From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 11:53:44 +0200
Message-ID: <4BA349A8.9050105@iki.fi>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100319072053.GA22913@gondor.apana.org.au> <4BA32C41.2020000@iki.fi> <20100319082909.GA23363@gondor.apana.org.au> <4BA337E6.4010508@iki.fi> <20100319084717.GA23567@gondor.apana.org.au> <4BA33FF5.8010104@iki.fi> <20100319093210.GA23895@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:49345 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab0CSJxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 05:53:53 -0400
Received: by ewy8 with SMTP id 8so1625546ewy.28
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 02:53:51 -0700 (PDT)
In-Reply-To: <20100319093210.GA23895@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Mar 19, 2010 at 11:12:21AM +0200, Timo Ter=E4s wrote:
>>> That would be better but it's still hacky.  Proper reference
>>> counting like we had before would be my preference.
>> Well, the cache entry is still referenced only very shortly,
>> I don't see why keeping bh disabled why doing it is considered
>> a hack. Refcounting the cache entries is trickier. Though,
>> it could be used to optimize the update process: we could safely
>> update it instead of doing now lookup later.
>=20
> Well we had a nicely type-agnostic cache which is self-contained,
> but your patch is bleeding generic code into xfrm_policy.c, that's
> why I felt it to be hacky :)
>=20
> Anyway I see how your scheme works now as far as object life
> is concerned, and I agree that it is safe.
>=20
> However, I wonder if we could do it while still leaving all the
> object life-cycle management stuff (and the BH disabling bits)
> in flow.c
>=20
> The crux of the issue is that you now have two objects to track
> instead of one.  As the direction is a key in the lookup, we're
> really only worried about the outbound case here.
>=20
> So how about going back to what I suggested earlier, and keeping
> a back-pointer from xfrm_dst to the policy? Of course xfrm_dst
> would also hold a ref count on the policy.  You'd only have to
> do it for the top-level xfrm_dst.
>=20
> It does mean that you'll need to write a different resolver for
> outbound vs. inbound/forward, but that makes sense because we
> only use bundles for outbound policies.
>=20
> What do you think?

When I first started reading the code, I got confused slightly
on how the garbage collection is happening. What I did not like
in current is the atomic_dec() in flow.c that does not check if
it was turned to zero. Because on policy objects it means you
need to delete it (which would a bug if it happened in flow.c;
the policy gc calls flush before releasing it's own reference),
but on xfrm_dst it's perfectly ok to do atomic_dec() and the
dst core will garbage collect items.

But now, thinking more, it would probably make more sense to
just cache xfrm_dst's and keep ref to the policy on them. So
in general I agree with your recommendation. The only immediate
problem I can think now is that the resolved would need to
atomically check if xfrm_dst is valid, if not, resolve new one.
But creating new xfrm_dst involves taking locks and can sleep
so it cannot be inside the main resolver.

Alternatively, we'd need to:
a) still expose flow cache entry structs and do locking or
   refcounting on them
b) have two version of flow lookup: one that calls resolver
   with bh disabled and can atomically lookup and update entry
   and a second version that lookups, calls validation, if
   not-valid it calls resolver with bh enabled and does a new
   flow cache lookup to update cache

Also, relatedly. Is there way to release xfrm_dst's child and
route refs when xfrm_bundle_ok fails? This would improve GC
collection of the ipv4 rtable entries they referenced.

- Timo
