From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: implement basic garbage collection for bundles
Date: Sat, 20 Mar 2010 15:34:46 +0200
Message-ID: <4BA4CEF6.9090807@iki.fi>
References: <1269087341-7009-1-git-send-email-timo.teras@iki.fi> <20100320123247.GB1930@gondor.apana.org.au> <4BA4C29A.8000806@iki.fi> <20100320124919.GA2243@gondor.apana.org.au> <4BA4C587.60504@iki.fi> <20100320131340.GB2243@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:65047 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab0CTNer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 09:34:47 -0400
Received: by ewy8 with SMTP id 8so243885ewy.28
        for <netdev@vger.kernel.org>; Sat, 20 Mar 2010 06:34:46 -0700 (PDT)
In-Reply-To: <20100320131340.GB2243@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Sat, Mar 20, 2010 at 02:54:31PM +0200, Timo Ter=E4s wrote:
>> Those are more or less timer based too. I guess it would be
>> better to put to dst core's function then. It can see hanging
>> refs, and call xfrm gc in that case.
>=20
> The IPv4 one appears to be invoked from dst_alloc just like
> xfrm.

Yes. But under normal circumstances that's not used. It also
has a separate timer based gc that goes through the buckets
periodically. That e.g. how the expired pmtu routes are kicked
out and how routes with old genid are purged before we start
to reach the gc_thresh limit. This happens in=20
rt_worker_func() which is called every ip_rt_gc_interval
(defaults to one minute).
=20
>> To even minimize that it would help a lot if xfrm_bundle_ok
>> could release (or swap to dummies) the referenced dst->route
>> and dst->child entries. xfrm_bundle_ok is mostly called for
>> all bundles regularly by xfrm_find_bundle before new ones are
>> created.
>=20
> Yes I agree that's what we should do once your other patch is
> applied.
>=20
> So every top-level xfrm_dst that's not referenced by some user
> should sit in the flow cache.  When it's needed and we find it
> to be stale we kick it out of the cache and free it along with
> the rest of its constituents.

Right. Ok, just to get road map of what I should do and in which
order and how.

xfrm gc:
  - should dst core call it?
  - should xfrm do it periodically?
  - or do we rely that we get new bundles and let
    xfrm[46]_find_bundle do the clean up?
  - should xfrm_bundle_ok() release the inner dst's right away
    instead of waiting any of the above to happen?

caching of bundles instead of policies for outgoing traffic:
  - should flow cache be per-netns?
  - since it will now have two types of objects, would it make
    sense to have virtual put and get callbacks instead of
    atomic_t pointer. this way qw can BUG_ON() if the refcount
    goes to zero unexpectedly (or call the appropriate destructor)
    and call the real _put function anway (e.g. dst_release does
    WARN_ON stuff); the _get function can also do additional
    checking if the object is valid or not; this way the flow
    cache resolver output is always a valid object
  - resolver to have "resolve_fast" and "resolve_slow". if fast
    fails, the slow gets called with bh enabled so it can sleep,
    since bundle creation needs that.
  - it would probably be then useful to have dummy xfrm_dst for
    policy reference when the policy forbids traffic?

- Timo

