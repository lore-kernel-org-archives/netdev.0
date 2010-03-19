From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 07:48:57 +0200
Message-ID: <4BA31049.7030005@iki.fi>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100317130704.GA2601@gondor.apana.org.au> <4BA0E435.6090801@iki.fi> <20100317145850.GA4257@gondor.apana.org.au> <4BA0FBB6.10208@iki.fi> <4BA27F72.40901@iki.fi> <20100319003130.GA20227@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:58055 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865Ab0CSFtA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 01:49:00 -0400
Received: by ewy8 with SMTP id 8so1570326ewy.28
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 22:48:59 -0700 (PDT)
In-Reply-To: <20100319003130.GA20227@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Mar 18, 2010 at 09:30:58PM +0200, Timo Ter=E4s wrote:
>> Now, these created xfrm_dst gets cached in policy->bundles
>> with ref count zero and not deleted until garbage collection
>> is required. That's how xfrm_find_bundle tries to reuse them
>> (but it does O(n) lookup).
>=20
> Yes but the way you're caching it in the policy means that it
> only helps if two consecutive packets happen to match the same
> bundle.  If your traffic mix was such that each packet required
> a different bundle, then we're back to where we started.
>=20
> That's why I was asking for you to directly cache the xfrm_dst
> objects in the flow cache.

But it always matches. The caching happens using the inner
flow. Inner flow always matches with the same bundle unless
the bundle expires or goes stale. What happens is that I get
multiple cache entries per-inner flow each referencing to the
same bundle.

And this is even more useful with the gre+esp. No matter what
I send inside gre (with private IPs), it ends up being routed
to more limited set of outer public IP parties. The bundle
lookup happens with the public-IP flow, so the speed up works
even better.

>> Actually no. As the pmtu case showed, it's more likely that
>> xfrm_dst needs to be regenerated, but the policy stays the
>> same since policy db isn't touched that often. If we keep
>> them separately we can almost most of the time avoid doing
>> policy lookup which is also O(n). Also the currently cache
>> entry validation is needs to check policy's bundles_genid
>> before allowing touching of xfrm_dst. Otherwise we would have
>> to keep global bundle_genid, and we'd lose the parent pointer
>> on cache miss.
> A back-pointer does not require an O(n) lookup.

True. But if we go and prune a bundle due to it being bad or
needing garbage collection we need to invalidate all bundles
pointers, and we cannot access the back-pointer. Alternatively
we need to keep xfrm_dst references again in the flow cache
requiring an expensive iteration of all flow cache entries
whenever a xfrm_dst needs to be deleted (which happens often).

- Timo
