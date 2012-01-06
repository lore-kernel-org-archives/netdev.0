From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 2/6] net: pad skb data and shinfo as a whole rather than
 individually
Date: Fri, 6 Jan 2012 13:29:45 +0000
Message-ID: <1325856585.25206.498.camel@zakaz.uk.xensource.com>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	 <1325783624-14601-2-git-send-email-ian.campbell@citrix.com>
	 <1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325791164.29084.8.camel@dagon.hellion.org.uk>
	 <1325794968.2748.6.camel@edumazet-laptop>
	 <1325848815.25206.471.camel@zakaz.uk.xensource.com>
	 <1325853226.2999.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:9821 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751673Ab2AFN3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 08:29:47 -0500
In-Reply-To: <1325853226.2999.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-06 at 12:33 +0000, Eric Dumazet wrote:
> Le vendredi 06 janvier 2012 =C3=A0 11:20 +0000, Ian Campbell a =C3=A9=
crit :
>=20
> > It doesn't fit in a single cache line today.
>=20
> It really does, thanks to your (net: pack skb_shared_info more
> efficiently) previous patch.
>=20
> I dont understand your numbers, very hard to read.
>=20
> Current net-next :
>=20
> offsetof(struct skb_shared_info, nr_frags)=3D0x0
> offsetof(struct skb_shared_info, frags[1])=3D0x40   (0x30 on 32bit ar=
ches)
>=20
> So _all_ fields, including one frag, are included in a single cache l=
ine
> on most machines (64-bytes cache line),

BTW, this is also true with my patch + put destructor_arg first in the
struct (at least for all interesting fields, since I chose
destructor_arg specifically because it did not seem interesting for
these purposes -- do you disagree?)

(gdb) print &((struct skb_shared_info *)0)->frags[1]
$1 =3D (skb_frag_t *) 0x48
but there is a cacheline boundary just before nr_frags:
(gdb) print &((struct skb_shared_info *)0)->nr_frags
$3 =3D (unsigned char *) 0x8

So the interesting fields total 0x48-0x8 =3D 0x40 bytes and the alignme=
nt
is such that this is a single cache line.

>  IF struct skb_shared_info is
> aligned.

Obviously the conditions for the above are a little different but they
are, AFAIK, met.

Ian.

>=20
> Your patch obviously breaks this on 64bit arches, unless you make sur=
e
> sizeof(struct skb_shared_info) is a multiple of cache line.
>=20
> [BTW, it is incidentaly the case after your 1/6 patch]
>=20
> fields reordering is not going to change anything on this.
>=20
> Or maybe I misread your patch ?
>=20
> At least you claimed in Changelog :=20
>=20
> <quote>
>  Reducing this overhead means that sometimes the tail end of
>  the data can end up in the same cache line as the beginning of the s=
hinfo but
>  in many cases the allocation slop means that there is no overlap.
> </quote>
>=20
>=20
>=20
