From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation (v2)
Date: Tue, 9 Nov 2010 16:20:00 -0500
Message-ID: <20101109212000.GA12350@hmsreliant.think-freely.org>
References: <1288033566-2091-1-git-send-email-nhorman@tuxdriver.com>
 <1289324799-2256-1-git-send-email-nhorman@tuxdriver.com>
 <AANLkTi=s9zr+yF-nr8MoHY6W6m=usR2fH=dPJx6voC34@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49230 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754759Ab0KIVWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 16:22:07 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTi=s9zr+yF-nr8MoHY6W6m=usR2fH=dPJx6voC34@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 09, 2010 at 01:07:32PM -0800, Maciej =C5=BBenczykowski wrot=
e:
> > +#define PGV_FROM_VMALLOC 1
>=20
> Why don't we always just use vmalloc, what's the benefit of get_user_=
pages?
>=20
Because of how vmalloc works.  It maps discontiguous pages into contigu=
ous
address space.  But we only have 128MB of that address space to work wi=
th by
default, so its quite possible that we won't be able to alloc all the m=
emory.

> > + =C2=A0 =C2=A0 =C2=A0 /*
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* vmalloc failed, lets dig into swap h=
ere
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> > + =C2=A0 =C2=A0 =C2=A0 *flags =3D 0;
>=20
> probably better to *flags &=3D ~PGV_FROM_VMALLOC;
> (since some flags could have been set before this function was called=
)
>=20
Well, if any other users of this field existed, I'd agree, but since we=
're the
only one, I think its ok, at least for now.

> > + =C2=A0 =C2=A0 =C2=A0 gfp_flags &=3D ~__GFP_NORETRY;
> > + =C2=A0 =C2=A0 =C2=A0 buffer =3D (char *)__get_free_pages(gfp_flag=
s, order);
>=20
> wouldn't this still cause problems because you're now requiring linea=
r
> memory again?
yes, its a last ditch effort after the other two options have been trie=
d.  Its
all thats left to do.

> Would it be better to just fail at this point?
Why?  If we can dig into swap and get the memory, we may as well try.  =
It would
be better if we didn't have to, but if the choice is between failing an=
d making
the system slow down....

Neil

>=20
