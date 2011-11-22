From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] xfrm: optimize ipv4 selector matching
Date: Tue, 22 Nov 2011 18:47:55 +0300
Message-ID: <20111122154755.GB25127@p183.telecom.by>
References: <20111122144334.GA22824@p183.telecom.by>
 <AE90C24D6B3A694183C094C60CF0A2F6D8AED7@saturn3.aculab.com>
 <20111122145940.GA24909@p183.telecom.by>
 <1321974652.2474.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34316 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754882Ab1KVPsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 10:48:00 -0500
Received: by fagn18 with SMTP id n18so546246fag.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 07:47:59 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1321974652.2474.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 22, 2011 at 04:10:52PM +0100, Eric Dumazet wrote:
> Le mardi 22 novembre 2011 =E0 17:59 +0300, Alexey Dobriyan a =E9crit =
:
> > On Tue, Nov 22, 2011 at 02:50:59PM -0000, David Laight wrote:
> > > =20
> > > > +static inline int addr4_match(const __be32 a1, const __be32=20
> > > > a2, const u8 prefixlen)
> > > > +{
> > > > +	/* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
> > > > +	if (prefixlen =3D=3D 0) {
> > > > +		/* Matching constants result in smaller assembly. */
> > > > +		return 0xFFFFFFFFu;
> > > > +	}
> > > > +	return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
> > > > +}
> > > > +
> > >=20
> > > It would probably be clearer to 'return 1' when prefixlen is zero=
=2E
> >=20
> > "return 1" results in bigger code.
> > This function used only in boolean context, so exact return value d=
oesn't matter.
>=20
>=20
> Thats too ugly, sorry.
>=20
> Also, using "const" attributes on integral types (not pointers) make
> code less clear.

No. it doesn't.
It signals to programmer that functions doesn't change its arguments.

> Caller doesnt care if the implementation wants to
> change a1 or a2 or prefixlen.

const is never about caller.
Millions of const qualifiers were injected already, so who cares.

> Please use :
>=20
> +static inline bool addr4_match(__be32 a1, __be32 a2, u8 prefixlen)
> +{
> +       /* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
> +       if (prefixlen =3D=3D 0)
> +               return true;
> +       return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
> +}

hmm, bool results in smaller code for -Os, so I'll resend.
