From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 04 Apr 2010 09:07:12 +0300
Message-ID: <4BB82C90.70809@iki.fi>
References: <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100403033857.GA2205@gondor.apana.org.au> <20100403083609.GA3654@gondor.apana.org.au> <4BB74790.7070109@iki.fi> <20100403141709.GA5165@gondor.apana.org.au> <4BB74FF8.2020303@iki.fi> <20100403155353.GA5618@gondor.apana.org.au> <4BB7A2B8.4040405@iki.fi> <20100404020657.GA8520@gondor.apana.org.au> <4BB828B1.5090109@iki.fi> <20100404055830.GA9484@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:48513 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140Ab0DDGHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 02:07:16 -0400
Received: by ewy20 with SMTP id 20so844756ewy.1
        for <netdev@vger.kernel.org>; Sat, 03 Apr 2010 23:07:15 -0700 (PDT)
In-Reply-To: <20100404055830.GA9484@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sun, Apr 04, 2010 at 08:50:41AM +0300, Timo Ter=E4s wrote:
>> For the common case:
>>
>> 1. Policy deleted; policy->walk.dead set, policy->genid incremented
>> 2. NETDEV_DOWN hook called, calls flow_cache_flush()
>> 3. flow_cache_flush enumerates all policy and bundle refs
>>   in it's cache
>> 4. for each bundle xfrm_bundle_check_fce() is called, which
>>   calls stale_bundle()
>> 5. all bundles using stale policy, fail that check because
>>     xdst->policy_genid !=3D xdst->pols[0]->genid
>>   (checked in xfrm_bundle_ok)
>> 6. flow cache calls entry's ->delete which is dst_free for bundles
>> 7. flow_cache_flush() returns
>=20
> Ah, you're doing it in 2/4.  Can we please have each patch be
> a self-contained unit? It should be possible to apply 1/4 and
> have a resulting kernel that works properly without having to
> apply the rest of your patches.

With 1/4 only, the bundle deletion is not touched. In that case
the policy GC deletes explicitly the bundles. The bundles get
deleted immediately, and only the struct xfrm_policy might get
held up allocated longer.

The code flow would be:
 1. xfrm_policy_kill() queues to GC
 2. xfrm_policy_gc_kill() called from xfrm_policy_gc_task()
    frees all bundles in that policy
 3. xfrm_policy_gc_kill() releases it's reference
 4. ... time passes (flush, randomization, or flow hit occurs)
 5. flow cache releases it's final reference, calls
    xfrm_policy_destroy() which only frees the xfrm_policy memory
