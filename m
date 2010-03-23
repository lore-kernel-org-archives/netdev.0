From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Tue, 23 Mar 2010 09:28:33 +0200
Message-ID: <4BA86DA1.7090707@iki.fi>
References: <4BA337E6.4010508@iki.fi> <20100319084717.GA23567@gondor.apana.org.au> <4BA33FF5.8010104@iki.fi> <20100319093210.GA23895@gondor.apana.org.au> <4BA349A8.9050105@iki.fi> <20100320151751.GB2950@gondor.apana.org.au> <4BA4F718.3020700@iki.fi> <20100321004659.GA5895@gondor.apana.org.au> <4BA5CC16.9040606@iki.fi> <4BA5D95B.4020004@iki.fi> <20100322035201.GA14457@gondor.apana.org.au> <4BA7B10A.1030302@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:14018 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984Ab0CWH2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Mar 2010 03:28:37 -0400
Received: by ey-out-2122.google.com with SMTP id d26so547561eyd.19
        for <netdev@vger.kernel.org>; Tue, 23 Mar 2010 00:28:36 -0700 (PDT)
In-Reply-To: <4BA7B10A.1030302@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Herbert Xu wrote:
>> On Sun, Mar 21, 2010 at 10:31:23AM +0200, Timo Ter=E4s wrote:
>>>> Ok, we can do that to skip 2. But I think 1 would be still useful.
>>>> It'd probably be good to actually have flow_cache_ops pointer in
>>>> each entry instead of the atomic_t pointer.
>>>>
>>>> The reasoning:
>>>> - we can then have type-based checks that the reference count
>>>>  is valid (e.g. policy's refcount must not go to zero, it's bug,
>>>>  and we can call dst_release which warns if refcount goes to
>>>>  negative); imho it's hack to call atomic_dec instead of the
>>>>  real type's xxx_put
>>>> - the flow cache needs to somehow know if the entry is stale so
>>>>  it'll try to refresh it atomically; e.g. if there's no
>>>>  check for 'stale', the lookup returns stale xfrm_dst. we'd
>>>>  then need new api to update the stale entry, or flush it out
>>>>  and repeat the lookup. the virtual get could check for it being
>>>>  stale (if so release the entry) and then return null for the
>>>>  generic code to call the resolver atomically
>>>> - for paranoia we can actually check the type of the object in
>>>>  cache via the ops (if needed)
>>
>> The reason I'd prefer to keep the current scheme is to avoid
>> an additional indirect function call on each packet.
>>
>> The way it would work is (we need flow_cache_lookup to return
>> fle instead of the object):
>>
>>     fle =3D flow_cache_lookup
>>     xdst =3D fle->object
>>     if (xdst is stale) {
>>         flow_cache_mark_obsolete(fle)
>>         fle =3D flow_cache_lookup
>>         xdst =3D fle->object
>>         if (xdst is stale)
>>             return error
>>     }

I've been thinking more about doing this. And I think this
approach is fundamentally racy.

Underlying fle->object can be changed underneath as since
bh are not disabled. This means the refcounting needs to
be done on fle level, and additional measures are needed
to ensure that fle->object is as expected.

Additionally, the second flow_cache_lookup can happen
on another cpu, and could return a stale object that
indeed would need refreshing instead of generating an
error.

Options:
1. return fle and fle->object separately, refcount both
2. call flow_cache_lookup with bh disabled
3. use flow_cache_entry_ops and virtualize put/get

Since 2. was previously said to leak generic code,
it does not sound good.

On 1 vs 3, I'd still choose 3 since:
- adding one more refcount means more atomic calls
  which have same (or more) overhead as indirect call
- two refcounts sounds more complicated than one
- exposing fle and touching it without bh's disabled
  requires a whole lot of more extra care; doing
  3 is simpler

So, should I go ahead and do the virtualization of the
getters and putters?

- Timo
