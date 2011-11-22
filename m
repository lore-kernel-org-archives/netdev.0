From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xfrm: optimize ipv4 selector matching
Date: Tue, 22 Nov 2011 16:10:52 +0100
Message-ID: <1321974652.2474.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111122144334.GA22824@p183.telecom.by>
	 <AE90C24D6B3A694183C094C60CF0A2F6D8AED7@saturn3.aculab.com>
	 <20111122145940.GA24909@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Laight <David.Laight@ACULAB.COM>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49205 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739Ab1KVPK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 10:10:57 -0500
Received: by bke11 with SMTP id 11so309123bke.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 07:10:56 -0800 (PST)
In-Reply-To: <20111122145940.GA24909@p183.telecom.by>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 novembre 2011 =C3=A0 17:59 +0300, Alexey Dobriyan a =C3=A9c=
rit :
> On Tue, Nov 22, 2011 at 02:50:59PM -0000, David Laight wrote:
> > =20
> > > +static inline int addr4_match(const __be32 a1, const __be32=20
> > > a2, const u8 prefixlen)
> > > +{
> > > +	/* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
> > > +	if (prefixlen =3D=3D 0) {
> > > +		/* Matching constants result in smaller assembly. */
> > > +		return 0xFFFFFFFFu;
> > > +	}
> > > +	return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
> > > +}
> > > +
> >=20
> > It would probably be clearer to 'return 1' when prefixlen is zero.
>=20
> "return 1" results in bigger code.
> This function used only in boolean context, so exact return value doe=
sn't matter.


Thats too ugly, sorry.

Also, using "const" attributes on integral types (not pointers) make
code less clear. Caller doesnt care if the implementation wants to
change a1 or a2 or prefixlen.

Please use :

+static inline bool addr4_match(__be32 a1, __be32 a2, u8 prefixlen)
+{
+       /* C99 6.5.7 (3): u32 << 32 is undefined behaviour */
+       if (prefixlen =3D=3D 0)
+               return true;
+       return !((a1 ^ a2) & htonl(0xFFFFFFFFu << (32 - prefixlen)));
+}
