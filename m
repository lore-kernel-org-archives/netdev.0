From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Mon, 22 Mar 2010 20:03:54 +0200
Message-ID: <4BA7B10A.1030302@iki.fi>
References: <4BA337E6.4010508@iki.fi> <20100319084717.GA23567@gondor.apana.org.au> <4BA33FF5.8010104@iki.fi> <20100319093210.GA23895@gondor.apana.org.au> <4BA349A8.9050105@iki.fi> <20100320151751.GB2950@gondor.apana.org.au> <4BA4F718.3020700@iki.fi> <20100321004659.GA5895@gondor.apana.org.au> <4BA5CC16.9040606@iki.fi> <4BA5D95B.4020004@iki.fi> <20100322035201.GA14457@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:59263 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967Ab0CVSEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 14:04:04 -0400
Received: by ewy8 with SMTP id 8so292144ewy.28
        for <netdev@vger.kernel.org>; Mon, 22 Mar 2010 11:04:01 -0700 (PDT)
In-Reply-To: <20100322035201.GA14457@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sun, Mar 21, 2010 at 10:31:23AM +0200, Timo Ter=E4s wrote:
>>> Ok, we can do that to skip 2. But I think 1 would be still useful.
>>> It'd probably be good to actually have flow_cache_ops pointer in
>>> each entry instead of the atomic_t pointer.
>>>
>>> The reasoning:
>>> - we can then have type-based checks that the reference count
>>>  is valid (e.g. policy's refcount must not go to zero, it's bug,
>>>  and we can call dst_release which warns if refcount goes to
>>>  negative); imho it's hack to call atomic_dec instead of the
>>>  real type's xxx_put
>>> - the flow cache needs to somehow know if the entry is stale so
>>>  it'll try to refresh it atomically; e.g. if there's no
>>>  check for 'stale', the lookup returns stale xfrm_dst. we'd
>>>  then need new api to update the stale entry, or flush it out
>>>  and repeat the lookup. the virtual get could check for it being
>>>  stale (if so release the entry) and then return null for the
>>>  generic code to call the resolver atomically
>>> - for paranoia we can actually check the type of the object in
>>>  cache via the ops (if needed)
>=20
> The reason I'd prefer to keep the current scheme is to avoid
> an additional indirect function call on each packet.
>=20
> The way it would work is (we need flow_cache_lookup to return
> fle instead of the object):
>=20
> 	fle =3D flow_cache_lookup
> 	xdst =3D fle->object
> 	if (xdst is stale) {
> 		flow_cache_mark_obsolete(fle)
> 		fle =3D flow_cache_lookup
> 		xdst =3D fle->object
> 		if (xdst is stale)
> 			return error
> 	}
>=20
> Where flow_cache_mark_obsolete would set a flag in the fle that's
> checked by flow_cache_lookup.  To prevent the very rare case
> where we mark an entry obsolete incorrectly, the resolver function
> should double-check that the existing entry is indeed obsolete
> before making a new one.
>=20
> This way we give the overhead over to the slow path where the
> bundle is stale.

Well, yes. The fast past would be slightly faster.

However, I still find the indirect call based thingy more elegant.=20
We would also get more common code, as flow_cache_lookup could then
figure out from the virtual call if the entry needs refreshing or
not. And doing just atomic_dec instead of the type based thingy
feels slightly kludgy. I don't think the speed difference between
direct/indirect call is that significant.

Also the fle would just need "struct flow_cache_ops *". And have
wrappers that use container_of to figure out the real address of
the cached struct. This would allow real type agnostic cache.
So we'd just need the 'ops' pointer instead of the current
object pointer and atomic_t pointer, saving in fle size.
But yes, it does impose the small speed penalty of indirect call.

I prefer the 'ops' thingy, but have no strong feelings either way.
Do you fell strongly to go with the current scheme here?

> You were saying that our bundles are going stale very frequently,
> that would sound like a bug that we should look into.  The whole
> caching scheme is pointless if the bundle is going stale every
> other packet.

I mean frequently as in 'minutes' not as in 'milliseconds'. The=20
bundles goes stale only when the policy (mostly by user action) or
ip route (pmtu / minutes) changes. So no biggie here.

>> - could cache bundle OR policy for outgoing stuff. it's useful
>>  to cache the policy in case we need to sleep, or if it's a
>>  policy forbidding traffic. in those cases there's no bundle
>>  to cache at all. alternatively we can make dummy bundles that
>>  are marked invalid and are just used to keep a reference to
>>  the policy.
>=20
> My instinct is to go with dummy bundles.  That way given the
> direction we know exactly what object type it is.  Having mixed
> object types is just too much of a pain.

Sounds good.

>> Oh, this also implies that the resolver function should be
>> changed to get the old stale object so it can re-use it to
>> get the policy object instead of searching it all over again.
>=20
> That should be easy to implement.  Just prefill the obj argument
> to the resolver with either NULL or the stale object.
>=20
> For the bundle resolver, it should also remove the stale bundle
> from the policy bundle list and drop its reference.

Yup.

Cheers,
 Timo
