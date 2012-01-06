From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 2/6] net: pad skb data and shinfo as a whole rather than
 individually
Date: Fri, 6 Jan 2012 13:49:02 +0000
Message-ID: <1325857742.25206.508.camel@zakaz.uk.xensource.com>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	 <1325783624-14601-2-git-send-email-ian.campbell@citrix.com>
	 <1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325791164.29084.8.camel@dagon.hellion.org.uk>
	 <1325794968.2748.6.camel@edumazet-laptop>
	 <1325848815.25206.471.camel@zakaz.uk.xensource.com>
	 <1325853226.2999.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325856001.25206.493.camel@zakaz.uk.xensource.com>
	 <1325857030.2999.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:61188 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236Ab2AFNtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 08:49:04 -0500
In-Reply-To: <1325857030.2999.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-06 at 13:37 +0000, Eric Dumazet wrote:
> Le vendredi 06 janvier 2012 =C3=A0 13:20 +0000, Ian Campbell a =C3=A9=
crit :
> > On Fri, 2012-01-06 at 12:33 +0000, Eric Dumazet wrote:
> > > Le vendredi 06 janvier 2012 =C3=A0 11:20 +0000, Ian Campbell a =C3=
=A9crit :
> > >=20
> > > > It doesn't fit in a single cache line today.
> > >=20
> > > It really does, thanks to your (net: pack skb_shared_info more
> > > efficiently) previous patch.
> > >=20
> > > I dont understand your numbers, very hard to read.
> > >=20
> > > Current net-next :
> > >=20
> > > offsetof(struct skb_shared_info, nr_frags)=3D0x0
> > > offsetof(struct skb_shared_info, frags[1])=3D0x40   (0x30 on 32bi=
t arches)
> >=20
> > I see 0x48 here at cset 6386994e03ebbe60338ded3d586308a41e81c0dc:
>=20
> If you read my mail, I said "current net-next"=20
>=20
> Please "git pull" again ?

Oh, oops, I thought I'd checked I was up to date.

> Here I really have your commit 9f42f126154786e6e76df513004800c8c633f0=
20
> in.
>=20
>=20
>=20
> > (gdb) print &((struct skb_shared_info *)0)->nr_frags
> > $1 =3D (short unsigned int *) 0x0
> > (gdb) print &((struct skb_shared_info *)0)->frags[1]
> > $2 =3D (skb_frag_t *) 0x48
> > (gdb) print &((struct skb_shared_info *)0)->frags[0]
> > $3 =3D (skb_frag_t *) 0x38
> >=20
> > (it's 0x34 and 0x2c on 32 bit) and these numbers match what I poste=
d for
> > v3.1 (and I imagine earlier since this stuff doesn't seem to change=
 very
> > often).
> >=20
> > I provided the offsets of each field in struct skb_shared_info, whi=
ch
> > one do you think is wrong?
> >=20
> > Remember that the end shared info is explicitly aligned (to the end=
 of
> > the allocation =3D=3D a cache line) while the front just ends up at=
 wherever
> > the size dictates so you can't measure the alignment of the fields =
from
> > the beginning  of the struct, you need to measure from the end.
>=20
> You're mistaken. Really.
>=20
> Current code makes SURE skb->end starts at a cache line boundary
> (assuminf kmalloc() returned an aligned bloc, this might be not true
> with SLAB debugging)
>=20
> size =3D SKB_WITH_OVERHEAD(ksize(data));
> ...
> skb->end =3D skb->tail + size;
>=20
> So there is possibility of padding (less than 64 bytes) _after_
> skb_shared_info and before the end of allocated area.

Oh, I somehow missed the SKB_DATA_ALIGN inside SKB_WITH_OVERHEAD when I
was reasoning about the before case (even though I touched it in my
patch!) thanks for prodding me sufficiently...

I guess the comment preceeding "size =3D" is therefore slightly mislead=
ing
since shinfo isn't "exactly at the end" but rather "at the end but stil=
l
aligned"?
	/* kmalloc(size) might give us more room than requested.
	 * Put skb_shared_info exactly at the end of allocated zone,
	 * to allow max possible filling before reallocation.
	 */

Anyhow, despite this I think with the patch to move destructor_arg to
the front ontop of this series the hot fields are all in a single cache
line, including the first frag. is that sufficient to alleviate your
concerns?

Ian.

> After your 9f42f1261547 commit on 64bit, we have no padding anymore
> since sizeof(struct skb_shared_info)=3D0x140
>=20
>=20
>=20
