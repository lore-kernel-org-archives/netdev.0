From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 10:37:58 +0200
Message-ID: <4BA337E6.4010508@iki.fi>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100319072053.GA22913@gondor.apana.org.au> <4BA32C41.2020000@iki.fi> <20100319082909.GA23363@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:52351 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963Ab0CSIiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 04:38:00 -0400
Received: by ewy8 with SMTP id 8so1602832ewy.28
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 01:37:58 -0700 (PDT)
In-Reply-To: <20100319082909.GA23363@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Mar 19, 2010 at 09:48:17AM +0200, Timo Ter=E4s wrote:
>> But flow_cache_lookup disables pre-emption until _put is called.
>> So it should work. Would there be a cleaner way?
>=20
> Previously the flow cache returned a policy directly which works
> because whenever we modify that policy we'd take the appropriate
> lock.
>
> Your patch changes it so that it now returns an fce.  But nothing
> is guarding the code that modifies fce.  So two CPUs may end up
> modifying the same fce.

But I changed that. the flow cache now does *not* call local_bh_enable
if it returns something. This is deferred until corresponding _put
call. So bh's are disable while we are touching the lookup results.

It'd probably make sense to remove that. And require _lookup to
be called with bh disabled so it's more obvious that bh's are
disabled when touching the cache entry.

> However, it would appear that this race could be harmless, provided
> that you are careful about dereferencing fce->policy and fce->dst.
>=20
> IOW, this is not OK
>=20
> 	if (fce->policy)
> 		use fce->policy;
>=20
> and this should work
>=20
> 	policy =3D fce->policy;
> 	if (policy)
> 		use policy;

Not a race. We need to keep bh's disabled while touching fce
for various reasons.

> Actually on second tought, even this isn't totally safe.  Who
> is taking a reference count on the policy and dst? I see a ref
> count on the fce, but nothing on fce->dst and fce->policy.  Do
> you have an implicit reference on them?

Noone. When policy and dst is on cache there's no reference.
The cache generation id's ensure that the object exists when
they are in cache. It might make sense to add references to
both objects and do a BUG_ON if the flow cache flusher would
need to delete an object. I guess this would be the proper
way, since that's how the dst stuff works too.

- Timo
