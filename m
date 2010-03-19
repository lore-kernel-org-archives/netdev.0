From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 09:27:57 +0200
Message-ID: <4BA3277D.10609@iki.fi>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100317130704.GA2601@gondor.apana.org.au> <4BA0E435.6090801@iki.fi> <20100317145850.GA4257@gondor.apana.org.au> <4BA0FBB6.10208@iki.fi> <4BA27F72.40901@iki.fi> <20100319003130.GA20227@gondor.apana.org.au> <4BA31049.7030005@iki.fi> <20100319060322.GA22319@gondor.apana.org.au> <4BA317CE.4050503@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:32908 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323Ab0CSH2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 03:28:01 -0400
Received: by ewy8 with SMTP id 8so1586242ewy.28
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 00:27:58 -0700 (PDT)
In-Reply-To: <4BA317CE.4050503@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Herbert Xu wrote:
>> On Fri, Mar 19, 2010 at 07:48:57AM +0200, Timo Ter=E4s wrote:
>>> But it always matches. The caching happens using the inner
>>> flow. Inner flow always matches with the same bundle unless
>>> the bundle expires or goes stale. What happens is that I get
>>> multiple cache entries per-inner flow each referencing to the
>>> same bundle.
>>
>> Sorry for being slow, but if it always matches, doesn't that mean
>> you'll only have a single bundle in the policy bundle list? IOW
>> why do we need this at all?
>=20
> No. The bundle created for specific flow, matches always later
> that flow.

Just figured that's it's easier to explain with an example.

We have SPD:
	10.1.0.0/16 - 10.2.0.0/16 tunnel
		1.2.3.4 - 4.3.2.1

Now we get n+1 clients to connect to server in 10.2.0.1.
They each get separate bundle, since the xfrm_dst will be
created and search using flow id's like:
	src 10.1.x.x dst 10.2.0.1

So there's one xfrm_policy and xfrm_state, but n+1
xfrm_dst's.

Since the flow cache caches the result of lookups on the
inner flow "10.1.x.x->10.2.0.1" basis, it always returns
matching valid bundle in O(1) time unless the xfrm_dst
expired.

Currently it's looked up with O(n) search in find_bundle.

Same thing happens with wildcard transport mode SPD's.

E.g. SPD:
	0.0.0.0/0 - 0.0.0.0/0 proto gre, transport

We are talking with gre to n+1 tunnel destinations.
We get n+1 xfrm_dst's in that xfrm_policy. Flow cache
works on inner flow using flows like:
	src 1.2.3.4 dst 4.3.2.1 proto gre
And can keep in cache the right policy always, and
the bundle to use as long as it stays valid.

Hopefully this explains why I think the patch is
useful.

- Timo

