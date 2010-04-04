From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 04 Apr 2010 08:50:41 +0300
Message-ID: <4BB828B1.5090109@iki.fi>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100403033857.GA2205@gondor.apana.org.au> <20100403083609.GA3654@gondor.apana.org.au> <4BB74790.7070109@iki.fi> <20100403141709.GA5165@gondor.apana.org.au> <4BB74FF8.2020303@iki.fi> <20100403155353.GA5618@gondor.apana.org.au> <4BB7A2B8.4040405@iki.fi> <20100404020657.GA8520@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:45180 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186Ab0DDFuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 01:50:44 -0400
Received: by ewy20 with SMTP id 20so843901ewy.1
        for <netdev@vger.kernel.org>; Sat, 03 Apr 2010 22:50:43 -0700 (PDT)
In-Reply-To: <20100404020657.GA8520@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Apr 03, 2010 at 11:19:04PM +0300, Timo Ter=E4s wrote:
>> If someone is then removing a net driver, we still execute
>> flush on the 'device down' hook, and all stale bundles
>> get flushed.
>=20
> Not if the bundle belongs to a policy recently deleted.
>=20
>> But yes, this means that xfrm_policy struct can now be held
>> allocated up to ten extra minutes. But it's only memory that
>> it's holding, not any extra refs. And it's still reclaimable
>> by the GC.
>=20
> You also hold down the bundle xdst's along with it, which can
> hold netdev references preventing modules from being unloaded.
>=20
>> If this feels troublesome, we could add asynchronous flush
>> request that would be called on policy removal. Or even stick
>> to the synchronous one.
>=20
> How about change xfrm_flush_bundles to flush bundles from the
> cache instead of xfrm_policy?

=46or the common case:

1. Policy deleted; policy->walk.dead set, policy->genid incremented
2. NETDEV_DOWN hook called, calls flow_cache_flush()
3. flow_cache_flush enumerates all policy and bundle refs
   in it's cache
4. for each bundle xfrm_bundle_check_fce() is called, which
   calls stale_bundle()
5. all bundles using stale policy, fail that check because
     xdst->policy_genid !=3D xdst->pols[0]->genid
   (checked in xfrm_bundle_ok)
6. flow cache calls entry's ->delete which is dst_free for bundles
7. flow_cache_flush() returns

flow_cache_flush really frees the bundles in it on flush.

But now that I look my code again. Your statement is true for
per-socket bundles. They would not get deleted in this case.
I'll change NETDEV_DOWN to call garbage collect instead of
flow cache flush which will then also free the per-socket bundles.
