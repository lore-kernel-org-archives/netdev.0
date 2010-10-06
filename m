From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Regarding to your linux kernel CL
Date: Wed, 6 Oct 2010 15:59:46 +0800
Message-ID: <20101006075946.GA5311@gondor.apana.org.au>
References: <AANLkTikdcL0JQgkR6u0qtmDu-phMZ6-Juq91B1N5GfiY@mail.gmail.com> <4CAC1F20.6070009@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?B?IkNodW5nLVlpaCBXYW5nICjnjovltIfmh78pIg==?=
	<cywang@google.com>, davem@davemloft.net, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40474 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756517Ab0JFH76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 03:59:58 -0400
Content-Disposition: inline
In-Reply-To: <4CAC1F20.6070009@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 06, 2010 at 10:02:56AM +0300, Timo Ter=E4s wrote:
>
> What's the problem here? sk_dst_check not honoring if dst->obsolete>0=
 ?
> Sounds like the sk_dst_check was buggy in the first place.

Well the problem is that before we changed ip4_dst_check, everything
worked properly.  With IPv6, whenever a route is released, the serial
number is always updated accordingly.  This means that ip6_dst_check
will always return NULL when obsolete > 1.

The old ip4_dst_check also satisfied this requirement since it always
returns NULL.

> Looks like there's still some code around that does not do what the
> obsolete field has been used for a long time.
>   obsolete =3D  0, dst entry is ok
>   obsolete =3D -1, you need to call ops->check for this entry
>   obsolete >  0, this entry is invalid
>=20
> So net/core/sock.c needs fixing. Just if we should change dst_check()
> too, I'm not sure.
>=20
> Should we fix sk_dst_check to use dst_check(), and dst_check() to che=
ck
> for dst->obsolete>0 ?

Yes this should work too.  However, I was never totally happy with
this new dst->obsolete logic which means that we're doing an
indirect call for every single packet which almost always does
nothing.

Perhaps we should move the genid/cookie logic into the dst so that
we can eliminate the dst->check call or at least make it a lot less
frequent.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
