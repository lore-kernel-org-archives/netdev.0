From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 11:52:23 +0100
Message-ID: <1229511143.13305.23.camel@nathan.suse.cz>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi>
	 <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au>
	 <20081217103129.GA17248@gondor.apana.org.au>
	 <20081217104254.GA17407@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:46281 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755313AbYLQKwZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 05:52:25 -0500
In-Reply-To: <20081217104254.GA17407@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu p=C3=AD=C5=A1e v St 17. 12. 2008 v 21:42 +1100:
> On Wed, Dec 17, 2008 at 09:31:29PM +1100, Herbert Xu wrote:
> >
> > Oh I see what you mean now.  Yes this isn't as easy as it appears.
>=20
> Reading RFC 793 again, it seems that what we're doing may not be
> correct.  It would appear that the intention is to flag urgent mode
> as soon as urgent data appears from the user, regardless of whether
> it's 64K or more beyond the current sequence number.
>=20
> The fact that the pointer is 16 bits long is not an issue.  We
> should setting it to 0xffff.

You might read it this way, but this would have some undesired
consequences in practise. Both Linux and *BSD interprets the offset as =
a
pointer to the first byte after the "out-of-band" data. So, they remove
the immediately preceding byte from the TCP stream (unless you set
MSG_OOB_INLINE, but that's not on by default).

Additionally, whenever the urgent pointer (the absolute offset in the
stream) changes, Linux (and maybe also *BSD -- not tested) sends a
SIGURG to the process.

In short, if you keep urg_ptr at 0xffff while moving forward in the
stream, the receiving side will interpret it as multiple urgent data.
Not quite what you want, I think.

Petr Tesarik

> The way we do it currently means that if there is loads of data
> in the pipe then we don't signal urgent mode at all until we're
> within 64K of snd.up, which defeats the whole point of urgent
> mode.
>=20
> Cheers,

