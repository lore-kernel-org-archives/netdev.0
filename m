From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 16 Feb 2012 23:35:46 +0100
Message-ID: <1329431746.2438.8.camel@edumazet-laptop>
References: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <16215291.4ftfQWZto1@localhost.localdomain>
	 <1329429573.5450.2.camel@edumazet-laptop>
	 <1843012.xoR1aAbfqy@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63416 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708Ab2BPWfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 17:35:51 -0500
Received: by bkcjm19 with SMTP id jm19so2545113bkc.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 14:35:50 -0800 (PST)
In-Reply-To: <1843012.xoR1aAbfqy@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 f=C3=A9vrier 2012 =C3=A0 00:08 +0200, alekcejk@googlemai=
l.com a
=C3=A9crit :
> =D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=A7=D0=B5=D1=82=D0=B2=D0=B5=D1=80=D0=B3 16 =D1=84=D0=B5=D0=B2=D1=
=80=D0=B0=D0=BB=D1=8F 2012 22:59:33 =D0=B2=D1=8B =D0=BD=D0=B0=D0=BF=D0=B8=
=D1=81=D0=B0=D0=BB=D0=B8:
> > Le jeudi 16 f=C3=A9vrier 2012 =C3=A0 23:49 +0200, alekcejk@googlema=
il.com a
> >=20
> > =C3=A9crit :
> > > =D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=
=BE=D1=82 =D0=A7=D0=B5=D1=82=D0=B2=D0=B5=D1=80=D0=B3 16 =D1=84=D0=B5=D0=
=B2=D1=80=D0=B0=D0=BB=D1=8F 2012 13:19:58 =D0=B2=D1=8B =D0=BD=D0=B0=D0=BF=
=D0=B8=D1=81=D0=B0=D0=BB=D0=B8:
> > > > On Thu, Feb 16, 2012 at 12:54 PM,  <alekcejk@googlemail.com> wr=
ote:
> > > > I still think it would be useful to have these three pieces of =
data
> > > > for a slow/3.2.x transfer (from a geographically distant server=
) if
> > > > you have a sec:
> > > >=20
> > > > - tcpdump of first 300 or so packets to see SYN/SYNACK options =
and RTT
> > > >=20
> > > >=20
> > > > - summary of overall throughput wget sees on that transfer
> > >=20
> > > --2012-02-16 23:33:30--  http://speedtest.tele2.net/1GB.zip
> > > 100%[=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D>] 1 073 741 824 5,02M/s   in 3m 29s
> > > 2012-02-16 23:36:59 (4,90 MB/s) - =C2=AB/dev/null=C2=BB saved [10=
73741824/1073741824]
> > >=20
> > > > This should help establish whether the receiver window is reall=
y the
> > > > limiting factor in the slow cases.
> >=20
> > Is tweaking /proc/sys/net/ipv4/tcp_adv_win_scale changes the number=
s ?
>=20
> Yes.
> =20
> > try 1, -1 or -2
>=20
> With 1 and -1 maximum speed increased to 6,99 M/s, with -2 decreased =
to 3,3 M/s.
>=20

Thats indeed the problem.

An incoming skb is considered as "good citizen" in term of memory usage
if its truesize is no more than
len + len/4   (if adv_win_scale =3D=3D 2)

That was true when truesize was 1500+NET_SKB_PAD+sizeof(sk_buff),
but not true anymore when truesize is 2048+sizeof(sk_buff), or even mor=
e
when its 4096+sizeof(sk_buff)

So receiver doesnt increase rcv_ssthresh and cannot open its window.

tcp_grow_window() should be tweaked to :

1) Relax the requirements
2) Allow bigger increase in case of super packets (LRO/GRO)
