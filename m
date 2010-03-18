From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Thu, 18 Mar 2010 21:30:58 +0200
Message-ID: <4BA27F72.40901@iki.fi>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100317130704.GA2601@gondor.apana.org.au> <4BA0E435.6090801@iki.fi> <20100317145850.GA4257@gondor.apana.org.au> <4BA0FBB6.10208@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:39020 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751317Ab0CRTbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 15:31:05 -0400
Received: by ewy8 with SMTP id 8so1439442ewy.28
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 12:31:03 -0700 (PDT)
In-Reply-To: <4BA0FBB6.10208@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> Herbert Xu wrote:
>> On Wed, Mar 17, 2010 at 04:16:21PM +0200, Timo Ter=E4s wrote:
>>> The problem is if I have multipoint gre1 and policy that says
>>> "encrypt all gre in transport mode".
>>>
>>> Thus for each public address, I get one bundle. But the
>>> xfrm_lookup() is called for each packet because ipgre_tunnel_xmit()
>>> calls ip_route_output_key() on per-packet basis.
>>>
>>> For my use-case it makes a huge difference.
>>
>> But if your traffic switches between those tunnels on each packet,
>> we're back to square one, right?
>=20
> Not to my understanding. Why would it change?

Here's how things go to my understanding.

When we are forwarding packets, each packet goes through
__xfrm_route_forward(). Or if we are sending from ip_gre (like in
my case), the packets go through ip_route_output_key().

Both of these call xfrm_lookup() to get the xfrm_dst instead
of the real rtable dst. This is done on per-packet basis.
Basically, the xfrm_dst is never kept referenced directly
on either code path. Instead it needs to be xfrm'ed per-packet.

Now, these created xfrm_dst gets cached in policy->bundles
with ref count zero and not deleted until garbage collection
is required. That's how xfrm_find_bundle tries to reuse them
(but it does O(n) lookup).

On the gre+esp case (should apply to any forward path too)
the caching of bundle speeds up the output path considerably
as there can be a lot of xfrm_dst's. Especially if it's a
wildcard transport mode policy which basically get's bundles
for each destination. So there can be a lot of xfrm_dst's
all valid, since they refer to unique xfrm_state on
per-destination basis.

Now, even more, since xfrm_dst needs to be regenerated if
the underlying ipv4 rtable entry has expired there can be
a lot of bundles. So the linear search is a major performance
killer.

Btw. it looks like the xfrm_dst garbage collection is broke.
It's only garbage collected if a network device goes down,
or dst_alloc calls it after gc threshold is exceeded. Since
gc threshold got dynamic not long ago, it can be very big.
This causes stale xfrm_dst's to be kept alive, and what is
worse their inner rtable dst is kept referenced. But as they
were expired and dst_free'd the dst core "free still referenced"
dst's goes through that list over and over again and will
kill the whole system performance when the list grows long.

I think as a minimum we should add 'do stale_bundle' check
to all xfrm_dst's every n minutes or so.

>>> Then we cannot maintain policy use time. But if it's not a
>>> requirement, we could drop the policy from cache.
>>
>> I don't see why we can't maintain the policy use time if we did
>> this, all you need is a back-pointer from the top xfrm_dst.
>=20
> Sure.

Actually no. As the pmtu case showed, it's more likely that
xfrm_dst needs to be regenerated, but the policy stays the
same since policy db isn't touched that often. If we keep
them separately we can almost most of the time avoid doing
policy lookup which is also O(n). Also the currently cache
entry validation is needs to check policy's bundles_genid
before allowing touching of xfrm_dst. Otherwise we would have
to keep global bundle_genid, and we'd lose the parent pointer
on cache miss.

Caching bundles be another win too. Since if do cache entries
like this, we could track how many cache miss xfrm_dst's
we've had and use that decide when to trigger xfrm_dst
garbage collector instead of (or in addition to) fixed timer.

- Timo
