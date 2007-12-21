From: Bill Fink <billfink@mindspring.com>
Subject: Re: TSO trimming question
Date: Fri, 21 Dec 2007 03:06:48 -0500
Message-ID: <20071221030648.389669c4.billfink@mindspring.com>
References: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>
	<20071219.235450.170670042.davem@davemloft.net>
	<Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
	<20071220.035621.147230372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, jheffner@psc.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:60395 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750754AbXLUIG4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 03:06:56 -0500
In-Reply-To: <20071220.035621.147230372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Dec 2007, David Miller wrote:

> From: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 20 Dec 2007 13:40:51 +0200 (EET)
>=20
> > [PATCH] [TCP]: Fix TSO deferring
> >=20
> > I'd say that most of what tcp_tso_should_defer had in between
> > there was dead code because of this.
> >=20
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Yikes!!!!!
>=20
> John, we've been living a lie for more than a year. :-/
>=20
> On the bright side this explains a lot of small TSO frames I've been
> seeing in traces over the past year but never got a chance to
> investigate.
>=20
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index 8dafda9..693b9f6 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -1217,7 +1217,8 @@ static int tcp_tso_should_defer(struct sock *=
sk, struct sk_buff *skb)
> >  		goto send_now;
> > =20
> >  	/* Defer for less than two clock ticks. */
> > -	if (!tp->tso_deferred && ((jiffies<<1)>>1) - (tp->tso_deferred>>1=
) > 1)
> > +	if (tp->tso_deferred &&
> > +	    ((jiffies << 1) >> 1) - (tp->tso_deferred >> 1) > 1)
> >  		goto send_now;
> > =20
> >  	in_flight =3D tcp_packets_in_flight(tp);

I meant to ask about this a while back but then got distracted by
other things.  But now since the subject has come up, I had a couple
of more questions about this code.

What's with all the shifting back and forth?  Here with:

	((jiffies<<1)>>1) - (tp->tso_deferred>>1)

and later with:

	/* Ok, it looks like it is advisable to defer.  */
	tp->tso_deferred =3D 1 | (jiffies<<1);

Is this just done to try and avoid the special case of jiffies=3D=3D0=20
when the jiffies wrap?  If so it seems like a lot of unnecessary
work just to avoid a 1 in 4 billion event, since it's my understanding
that the whole tcp_tso_should_defer function is just an optimization
and not a criticality to the proper functioning of TCP, especially
considering it hasn't even been executing at all up to now.

My second question is more basic and if I'm not mistaken actually
relates to a remaining bug in the (corrected) test:

	/* Defer for less than two clock ticks. */
	if (tp->tso_deferred &&
	    ((jiffies << 1) >> 1) - (tp->tso_deferred >> 1) > 1)

Since jiffies is an unsigned long, which is 64-bits on a 64-bit system,
whereas tp->tso_deferred is a u32, once jiffies exceeds 31-bits, which
will happen in about 25 days if HZ=3D1000, won't the second part of the
test always be true after that?  Or am I missing something obvious?

						-Bill
