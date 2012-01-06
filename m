From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/6] net: pad skb data and shinfo as a whole rather than
 individually
Date: Fri, 06 Jan 2012 14:37:10 +0100
Message-ID: <1325857030.2999.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	 <1325783624-14601-2-git-send-email-ian.campbell@citrix.com>
	 <1325785607.4759.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325791164.29084.8.camel@dagon.hellion.org.uk>
	 <1325794968.2748.6.camel@edumazet-laptop>
	 <1325848815.25206.471.camel@zakaz.uk.xensource.com>
	 <1325853226.2999.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325856001.25206.493.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:38311 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225Ab2AFNhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 08:37:14 -0500
Received: by werm1 with SMTP id m1so1114550wer.19
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2012 05:37:13 -0800 (PST)
In-Reply-To: <1325856001.25206.493.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 06 janvier 2012 =C3=A0 13:20 +0000, Ian Campbell a =C3=A9cr=
it :
> On Fri, 2012-01-06 at 12:33 +0000, Eric Dumazet wrote:
> > Le vendredi 06 janvier 2012 =C3=A0 11:20 +0000, Ian Campbell a =C3=A9=
crit :
> >=20
> > > It doesn't fit in a single cache line today.
> >=20
> > It really does, thanks to your (net: pack skb_shared_info more
> > efficiently) previous patch.
> >=20
> > I dont understand your numbers, very hard to read.
> >=20
> > Current net-next :
> >=20
> > offsetof(struct skb_shared_info, nr_frags)=3D0x0
> > offsetof(struct skb_shared_info, frags[1])=3D0x40   (0x30 on 32bit =
arches)
>=20
> I see 0x48 here at cset 6386994e03ebbe60338ded3d586308a41e81c0dc:

If you read my mail, I said "current net-next"=20

Please "git pull" again ?


Here I really have your commit 9f42f126154786e6e76df513004800c8c633f020
in.



> (gdb) print &((struct skb_shared_info *)0)->nr_frags
> $1 =3D (short unsigned int *) 0x0
> (gdb) print &((struct skb_shared_info *)0)->frags[1]
> $2 =3D (skb_frag_t *) 0x48
> (gdb) print &((struct skb_shared_info *)0)->frags[0]
> $3 =3D (skb_frag_t *) 0x38
>=20
> (it's 0x34 and 0x2c on 32 bit) and these numbers match what I posted =
for
> v3.1 (and I imagine earlier since this stuff doesn't seem to change v=
ery
> often).
>=20
> I provided the offsets of each field in struct skb_shared_info, which
> one do you think is wrong?
>=20
> Remember that the end shared info is explicitly aligned (to the end o=
f
> the allocation =3D=3D a cache line) while the front just ends up at w=
herever
> the size dictates so you can't measure the alignment of the fields fr=
om
> the beginning  of the struct, you need to measure from the end.

You're mistaken. Really.

Current code makes SURE skb->end starts at a cache line boundary
(assuminf kmalloc() returned an aligned bloc, this might be not true
with SLAB debugging)

size =3D SKB_WITH_OVERHEAD(ksize(data));
=2E..
skb->end =3D skb->tail + size;

So there is possibility of padding (less than 64 bytes) _after_
skb_shared_info and before the end of allocated area.

After your 9f42f1261547 commit on 64bit, we have no padding anymore
since sizeof(struct skb_shared_info)=3D0x140
