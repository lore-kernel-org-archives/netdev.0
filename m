From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 2/6] net: pad skb data and shinfo as a whole rather than
 individually
Date: Fri, 6 Jan 2012 13:20:01 +0000
Message-ID: <1325856001.25206.493.camel@zakaz.uk.xensource.com>
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
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:13330 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090Ab2AFNUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 08:20:03 -0500
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

I see 0x48 here at cset 6386994e03ebbe60338ded3d586308a41e81c0dc:
(gdb) print &((struct skb_shared_info *)0)->nr_frags
$1 =3D (short unsigned int *) 0x0
(gdb) print &((struct skb_shared_info *)0)->frags[1]
$2 =3D (skb_frag_t *) 0x48
(gdb) print &((struct skb_shared_info *)0)->frags[0]
$3 =3D (skb_frag_t *) 0x38

(it's 0x34 and 0x2c on 32 bit) and these numbers match what I posted fo=
r
v3.1 (and I imagine earlier since this stuff doesn't seem to change ver=
y
often).

I provided the offsets of each field in struct skb_shared_info, which
one do you think is wrong?

Remember that the end shared info is explicitly aligned (to the end of
the allocation =3D=3D a cache line) while the front just ends up at whe=
rever
the size dictates so you can't measure the alignment of the fields from
the beginning  of the struct, you need to measure from the end.

Ian.

> So _all_ fields, including one frag, are included in a single cache l=
ine
> on most machines (64-bytes cache line), IF struct skb_shared_info is
> aligned.
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
