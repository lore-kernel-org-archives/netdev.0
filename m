From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet: dont set inet_rcv_saddr in connect()
Date: Wed, 08 Sep 2010 16:27:02 +0200
Message-ID: <1283956022.2748.56.camel@edumazet-laptop>
References: <1283895316.2634.248.camel@edumazet-laptop>
	 <4C86F653.6070707@hp.com> <1283921857.2634.747.camel@edumazet-laptop>
	 <20100907.223654.70187707.davem@davemloft.net>
	 <1283925171.2634.838.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brian.haley@hp.com, ole@ans.pl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:59718 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751299Ab0IHO1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 10:27:10 -0400
Received: by fxm16 with SMTP id 16so90590fxm.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 07:27:09 -0700 (PDT)
In-Reply-To: <1283925171.2634.838.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 septembre 2010 =C3=A0 07:52 +0200, Eric Dumazet a =C3=A9=
crit :
> Le mardi 07 septembre 2010 =C3=A0 22:36 -0700, David Miller a =C3=A9c=
rit :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 08 Sep 2010 06:57:37 +0200
> >=20
> > >    Document that connect() also sets local address, and that befo=
re
> > > doing a second connect() to change remote address, its mandatory =
to
> > > first issue a connect(AF_UNSPEC) to clear local address (if not l=
ocked
> > > by a prior bind() call)
> >=20
> > For connectionless sockets, the application may connect() as many
> > times as it wishes to change the remote address.  The local address
> > remains set if it were set before such a re-associating connect().
> >=20
> > It need only issue a connect(AF_UNSPEC) to make the socket have no
> > remote association, and as you state this operation will also wipe =
out
> > any local address settings not created by a bind() call.
> >=20
> > And nicely our man pages are very clear about this :-) as is BSD an=
d
> > Steven's volume 2.
> >=20
> > This has been legal for decades, so we have to keep working this wa=
y.
>=20
> Yes, its also buggy, if 2nd remote address is not reachable on same i=
nterface.
> Even if we try a connect(AF_UNSPEC), the local address stay as is :
>=20
> after bind(port 5555) local addr=3D0x0:5555=20
> after connect(123) local addr=3D0x7f000001:5555 remote addr=3D0x7f000=
001:123=20
> Could not connect, errno=3D22
> after connect(AF_UNSPEC) local addr=3D0x7f000001:5555=20
> connect: Invalid argument
>=20

I run the program on FreeBSD 8.1, and this OS
does change the source address at connect() time.
It also change it each time connect() is called, not only once.

fd =3D socket()
connect(fd, "127.0.0.1:ntp")
system("netstat -p udp | grep udp")
connect(fd, "192.168.20.110:ntp")
system("netstat -p udp | grep udp")

->

udp4  0  0 127.0.0.1.35974       127.0.0.1.ntp

udp4  0  0 192.168.20.80.35974   192.168.20.110.ntp

while on Linux we refuse the second connect() -> EINVAL
(Because no route can be found from 127.0.0.1 to 192.168.20.110)



