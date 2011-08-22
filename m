From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next 3/5] be2net: fix erx->rx_drops_no_frags wrap
 around
Date: Mon, 22 Aug 2011 14:44:47 +0200
Message-ID: <1314017087.2307.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1314011613-4519-1-git-send-email-sathya.perla@emulex.com>
	 <1314011613-4519-4-git-send-email-sathya.perla@emulex.com>
	 <1314013414.2307.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1314013658.2307.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <3367B80B08154D42A3B2BC708B5D41F642D8EDB85A@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53812 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040Ab1HVMoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2011 08:44:46 -0400
Received: by wyg24 with SMTP id 24so3451579wyg.19
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2011 05:44:45 -0700 (PDT)
In-Reply-To: <3367B80B08154D42A3B2BC708B5D41F642D8EDB85A@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 22 ao=C3=BBt 2011 =C3=A0 05:15 -0700, Sathya.Perla@Emulex.Com =
a =C3=A9crit :
> >-----Original Message-----
> >From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
> >Sent: Monday, August 22, 2011 5:18 PM
> >
> >Le lundi 22 ao=C3=BBt 2011 =C3=A0 13:43 +0200, Eric Dumazet a =C3=A9=
crit :
> >
> >> This adds a race for lockless SNMP readers (in be_get_stats64())
> >>
> >> They can see the 32bit value going backward.
> >>
> >> You have to be very careful to read the *acc once, and write it on=
ce.
> >
> >The "write once" is the only requirement.
> >
> >Something like :
> >
> >u32 newval =3D hi(*acc) + val;
> >
> >if (wrapped)
> >	newval +=3D 65536;
> >ACCESS_ONCE(*acc) =3D newval;
> >
>=20
> Eric,
>=20
> I'm wondering why you'd need ACCESS_ONCE() here? Wouldn't using the t=
emp variable (newval) as you suggested,
> ensure that the reader doesn't see a half-baked value?
>=20

If you write :

u32 newval =3D hi(*acc) + val;
if (wrapped)
	newval +=3D 65536;
*acc =3D newval;


C compiler (gcc) is free to eliminate the temp variable and to generate
same code than :

*acc =3D hi(*acc) + val;
if (wrapped)
	*acc +=3D 65536;

ACCESS_ONCE() here is the clean way (and self explanatory/documented) t=
o
keep compiler to write to *acc twice.



