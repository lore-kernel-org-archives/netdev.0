From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 16:29:09 +0800
Message-ID: <20100319082909.GA23363@gondor.apana.org.au>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100319072053.GA22913@gondor.apana.org.au> <4BA32C41.2020000@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35271 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752628Ab0CSI3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 04:29:12 -0400
Content-Disposition: inline
In-Reply-To: <4BA32C41.2020000@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 19, 2010 at 09:48:17AM +0200, Timo Ter=E4s wrote:
>
> But flow_cache_lookup disables pre-emption until _put is called.
> So it should work. Would there be a cleaner way?

Previously the flow cache returned a policy directly which works
because whenever we modify that policy we'd take the appropriate
lock.

Your patch changes it so that it now returns an fce.  But nothing
is guarding the code that modifies fce.  So two CPUs may end up
modifying the same fce.

However, it would appear that this race could be harmless, provided
that you are careful about dereferencing fce->policy and fce->dst.

IOW, this is not OK

	if (fce->policy)
		use fce->policy;

and this should work

	policy =3D fce->policy;
	if (policy)
		use policy;

Actually on second tought, even this isn't totally safe.  Who
is taking a reference count on the policy and dst? I see a ref
count on the fce, but nothing on fce->dst and fce->policy.  Do
you have an implicit reference on them?

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
