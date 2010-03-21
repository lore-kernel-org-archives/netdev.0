From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Sun, 21 Mar 2010 10:31:23 +0200
Message-ID: <4BA5D95B.4020004@iki.fi>
References: <20100319072053.GA22913@gondor.apana.org.au> <4BA32C41.2020000@iki.fi> <20100319082909.GA23363@gondor.apana.org.au> <4BA337E6.4010508@iki.fi> <20100319084717.GA23567@gondor.apana.org.au> <4BA33FF5.8010104@iki.fi> <20100319093210.GA23895@gondor.apana.org.au> <4BA349A8.9050105@iki.fi> <20100320151751.GB2950@gondor.apana.org.au> <4BA4F718.3020700@iki.fi> <20100321004659.GA5895@gondor.apana.org.au> <4BA5CC16.9040606@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:64922 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab0CUIbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 04:31:23 -0400
Received: by ewy8 with SMTP id 8so385654ewy.28
        for <netdev@vger.kernel.org>; Sun, 21 Mar 2010 01:31:21 -0700 (PDT)
In-Reply-To: <4BA5CC16.9040606@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Herbert Xu wrote:
>> On Sat, Mar 20, 2010 at 06:26:00PM +0200, Timo Ter=E4s wrote:
>>> So should go ahead and:
>>> 1. modify flow cache to be more generic (have virtual put and get
>>>   for each object; and remove the atomic_t pointer)
>>> 2. modify flow cache to have slow and fast resolvers so we can
>>>   copy with the current sleeping requirement
>>
>> I don't think we need either of these.  To support the sleep
>> requirement, just return -EAGAIN from the resolver when the
>> template can't be resolved.  Then the caller of flow_cache_lookup
>> can sleep as it does now.  It simply has to repeat the flow
>> cache lookup afterwards.
>=20
> Ok, we can do that to skip 2. But I think 1 would be still useful.
> It'd probably be good to actually have flow_cache_ops pointer in
> each entry instead of the atomic_t pointer.
>=20
> The reasoning:
> - we can then have type-based checks that the reference count
>  is valid (e.g. policy's refcount must not go to zero, it's bug,
>  and we can call dst_release which warns if refcount goes to
>  negative); imho it's hack to call atomic_dec instead of the
>  real type's xxx_put
> - the flow cache needs to somehow know if the entry is stale so
>  it'll try to refresh it atomically; e.g. if there's no
>  check for 'stale', the lookup returns stale xfrm_dst. we'd
>  then need new api to update the stale entry, or flush it out
>  and repeat the lookup. the virtual get could check for it being
>  stale (if so release the entry) and then return null for the
>  generic code to call the resolver atomically
> - for paranoia we can actually check the type of the object in
>  cache via the ops (if needed)

- could cache bundle OR policy for outgoing stuff. it's useful
  to cache the policy in case we need to sleep, or if it's a
  policy forbidding traffic. in those cases there's no bundle
  to cache at all. alternatively we can make dummy bundles that
  are marked invalid and are just used to keep a reference to
  the policy.

Oh, this also implies that the resolver function should be
changed to get the old stale object so it can re-use it to
get the policy object instead of searching it all over again.

- Timo

