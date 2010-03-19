From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 08:21:02 +0200
Message-ID: <4BA317CE.4050503@iki.fi>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100317130704.GA2601@gondor.apana.org.au> <4BA0E435.6090801@iki.fi> <20100317145850.GA4257@gondor.apana.org.au> <4BA0FBB6.10208@iki.fi> <4BA27F72.40901@iki.fi> <20100319003130.GA20227@gondor.apana.org.au> <4BA31049.7030005@iki.fi> <20100319060322.GA22319@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:43235 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446Ab0CSGVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 02:21:04 -0400
Received: by ewy8 with SMTP id 8so1575027ewy.28
        for <netdev@vger.kernel.org>; Thu, 18 Mar 2010 23:21:02 -0700 (PDT)
In-Reply-To: <20100319060322.GA22319@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Mar 19, 2010 at 07:48:57AM +0200, Timo Ter=E4s wrote:
>> But it always matches. The caching happens using the inner
>> flow. Inner flow always matches with the same bundle unless
>> the bundle expires or goes stale. What happens is that I get
>> multiple cache entries per-inner flow each referencing to the
>> same bundle.
>=20
> Sorry for being slow, but if it always matches, doesn't that mean
> you'll only have a single bundle in the policy bundle list? IOW
> why do we need this at all?

No. The bundle created for specific flow, matches always later
that flow.

With transport mode wildcard policy, e.g. single policy saying
encrypt traffic with protocol X to all IP-address, you get a
separate bundle per-public IP destination. Bundle matches only
that specific IP since it gets a separate xfrm_state. But you
can talk to all the hosts in internet using same policy, so
you can end up with a whole lot of valid bundles in the same
policy.

I'm not sure how this works in tunnel mode. It might be that
single bundle can be reused for all packets. But I think the same
applies to tunnel mode. Since afinfo->fill_dst() puts the
inner flow to bundle xfrm_dst->u.rt.fl, which is later compared
against the inner flow by afinfo->find_bundle(). I think this
implies that for each flow traveling inside tunnel, it gets it's
separate xfrm_dst, so again you end up with a whole lot of
valid bundles in the same policy.

> Or have I misread your patch? You *are* proposing to cache the last
> used bundle in the policy, right?

Yes and no. The bundle used is cached on per-flow basis.
The flow cache can have lot of entries each referring to
same policy but separate bundle.

>> True. But if we go and prune a bundle due to it being bad or
>> needing garbage collection we need to invalidate all bundles
>> pointers, and we cannot access the back-pointer. Alternatively
>=20
> Why can't you access the back-pointer? You should always have
> a reference held on the policy, either explicit or implicit.
>=20
>> we need to keep xfrm_dst references again in the flow cache
>> requiring an expensive iteration of all flow cache entries
>> whenever a xfrm_dst needs to be deleted (which happens often).
>=20
> So does the IPv4 routing cache.  I think what this reflects is
> just that the IPsec garbage collection mechanism is broken.
>=20
> There is no point in doing a GC on every dst_alloc if we know
> that it isn't going to go below the threshold.  It should gain
> a minimum GC interval like IPv4.  Or perhaps we can move the
> minimum GC interval check into the dst core.

Yes, I reported xfrm_dst GC being broke in the earlier mail.

But keeping policy and bundle in cache is still a win. If we
kill the xfrm_dst due to GC, we will also lose the policy
the flow matched. We might need to kill xfrm_dst due to the
inside dst going old, but the flow cache would still give
hit with policy info (but no bundle) the next a packet comes
in using the same flow.

- Timo

