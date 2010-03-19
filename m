From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 11:12:21 +0200
Message-ID: <4BA33FF5.8010104@iki.fi>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100319072053.GA22913@gondor.apana.org.au> <4BA32C41.2020000@iki.fi> <20100319082909.GA23363@gondor.apana.org.au> <4BA337E6.4010508@iki.fi> <20100319084717.GA23567@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f216.google.com ([209.85.219.216]:41058 "EHLO
	mail-ew0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab0CSJMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 05:12:25 -0400
Received: by ewy8 with SMTP id 8so1613441ewy.28
        for <netdev@vger.kernel.org>; Fri, 19 Mar 2010 02:12:24 -0700 (PDT)
In-Reply-To: <20100319084717.GA23567@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Mar 19, 2010 at 10:37:58AM +0200, Timo Ter=E4s wrote:
>> But I changed that. the flow cache now does *not* call local_bh_enab=
le
>> if it returns something. This is deferred until corresponding _put
>> call. So bh's are disable while we are touching the lookup results.
>=20
> I'm sorry but making a function like flow_cache_lookup return with
> BH disabled is just wrong!
>=20
>> It'd probably make sense to remove that. And require _lookup to
>> be called with bh disabled so it's more obvious that bh's are
>> disabled when touching the cache entry.
>=20
> That would be better but it's still hacky.  Proper reference
> counting like we had before would be my preference.

Well, the cache entry is still referenced only very shortly,
I don't see why keeping bh disabled why doing it is considered
a hack. Refcounting the cache entries is trickier. Though,
it could be used to optimize the update process: we could safely
update it instead of doing now lookup later.

>> Not a race. We need to keep bh's disabled while touching fce
>> for various reasons.
>=20
> What are those reasons (apart from this race)?

This. And that the cache is synchronized by flow_cache_flush
executing stuff on other cpu's, ensuring that it's not running
any protected cache accessing code. See below.

>=20
>> Noone. When policy and dst is on cache there's no reference.
>> The cache generation id's ensure that the object exists when
>> they are in cache. It might make sense to add references to
>> both objects and do a BUG_ON if the flow cache flusher would
>> need to delete an object. I guess this would be the proper
>> way, since that's how the dst stuff works too.
>=20
> The cache genid is not enough:
>=20
> CPU1			CPU2
> check genid =3D=3D OK
> 			update genid
> 			kill policy
> 			kfree on policy
> use policy =3D=3D BOOM

The sequence goes currently.

CPU1			CPU2
disable_bh
check genid =3D=3D OK
			update genid
			call cache_flush
			blocks
use policy =3D=3D OK
and take refcount
enable_bh
cache_flush smpcall executes and ublocks cpu2
			returns from cache_flush
			kill policy
			kfree on policy

- Timo
