From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 16:47:17 +0800
Message-ID: <20100319084717.GA23567@gondor.apana.org.au>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100319072053.GA22913@gondor.apana.org.au> <4BA32C41.2020000@iki.fi> <20100319082909.GA23363@gondor.apana.org.au> <4BA337E6.4010508@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51810 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753083Ab0CSIrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 04:47:24 -0400
Content-Disposition: inline
In-Reply-To: <4BA337E6.4010508@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 19, 2010 at 10:37:58AM +0200, Timo Ter=E4s wrote:
>
> But I changed that. the flow cache now does *not* call local_bh_enabl=
e
> if it returns something. This is deferred until corresponding _put
> call. So bh's are disable while we are touching the lookup results.

I'm sorry but making a function like flow_cache_lookup return with
BH disabled is just wrong!

> It'd probably make sense to remove that. And require _lookup to
> be called with bh disabled so it's more obvious that bh's are
> disabled when touching the cache entry.

That would be better but it's still hacky.  Proper reference
counting like we had before would be my preference.

> Not a race. We need to keep bh's disabled while touching fce
> for various reasons.

What are those reasons (apart from this race)?

> Noone. When policy and dst is on cache there's no reference.
> The cache generation id's ensure that the object exists when
> they are in cache. It might make sense to add references to
> both objects and do a BUG_ON if the flow cache flusher would
> need to delete an object. I guess this would be the proper
> way, since that's how the dst stuff works too.

The cache genid is not enough:

CPU1			CPU2
check genid =3D=3D OK
			update genid
			kill policy
			kfree on policy
use policy =3D=3D BOOM

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
