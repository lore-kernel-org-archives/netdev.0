From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH] csum: Update csum_block_add to use rotate
 instead of byteswap
Date: Tue, 08 Mar 2016 21:50:47 -0800
Message-ID: <1457502647.4067.38.camel@perches.com>
References: <20160308224238.16551.73881.stgit@localhost.localdomain>
	 <1457479557.4067.9.camel@perches.com>
	 <CAKgT0Uc94UgzzcNXeFDvA4NKJN78hi-n7d2ar9YFiR8yGhW8Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0135.hostedemail.com ([216.40.44.135]:60767 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750823AbcCIFuw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 00:50:52 -0500
In-Reply-To: <CAKgT0Uc94UgzzcNXeFDvA4NKJN78hi-n7d2ar9YFiR8yGhW8Gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-03-08 at 21:23 -0800, Alexander Duyck wrote:
> On Tue, Mar 8, 2016 at 3:25 PM, Joe Perches <joe@perches.com> wrote:
> > On Tue, 2016-03-08 at 14:42 -0800, Alexander Duyck wrote:
> > > The code for csum_block_add was doing a funky byteswap to swap th=
e even and
> > > odd bytes of the checksum if the offset was odd.=A0=A0Instead of =
doing this we
> > > can save ourselves some trouble and just shift by 8 as this shoul=
d have the
> > > same effect in terms of the final checksum value and only require=
s one
> > > instruction.
> > 3 instructions?
> I was talking about just the one ror vs mov, shl, shr, and ,and, add.
>=20
> I assume when you say 3 you are including the test and either some
> form of conditional move or jump?

Yeah, instruction count also depends on architecture (arm/x86/ppc...)

> > > diff --git a/include/net/checksum.h b/include/net/checksum.h
[]
> > > @@ -88,8 +88,10 @@ static inline __wsum
> > > =A0csum_block_add(__wsum csum, __wsum csum2, int offset)
> > > =A0{
> > > =A0=A0=A0=A0=A0=A0u32 sum =3D (__force u32)csum2;
> > > -=A0=A0=A0=A0=A0if (offset&1)
> > > -=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sum =3D ((sum&0xFF00FF)<<=
8)+((sum>>8)&0xFF00FF);
> > > +
> > > +=A0=A0=A0=A0=A0if (offset & 1)
> > > +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sum =3D (sum << 24) + (su=
m >> 8);
> > Maybe use ror32(sum, 8);
> I was actually thinking I could use something like this.=A0=A0I didn'=
t
> realize it was even available.

Now you know: bitops.h

> > or maybe something like:
> >=20
> > {
> > =A0=A0=A0=A0=A0=A0=A0=A0u32 sum;
> >=20
> > =A0=A0=A0=A0=A0=A0=A0=A0/* rotated csum2 of odd offset will be the =
right checksum */
> > =A0=A0=A0=A0=A0=A0=A0=A0if (offset & 1)
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sum =3D ror32((__fo=
rce u32)csum2, 8);
> > =A0=A0=A0=A0=A0=A0=A0=A0else
> > =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sum =3D (__force u3=
2)csum2;
> >=20
> Any specific reason for breaking it up like this?=A0=A0It seems like =
it
> was easier to just have sum be assigned first and then rotating it if
> needed.=A0=A0What is gained by splitting the assignment up over two
> different calls?

It's only for reader clarity where a comment could be useful.
The compiler output shouldn't change.
