From: alekcejk@googlemail.com
Subject: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 21 Feb 2012 19:19:18 +0200
Message-ID: <2604639.CVkfrWv5sk@localhost.localdomain>
References: <8633039.fHPLx6GNq3@localhost.localdomain> <5196304.nDv69tPK8W@localhost.localdomain> <1329842751.18384.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:56358 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752672Ab2BURTr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 12:19:47 -0500
Received: by bkcjm19 with SMTP id jm19so5543818bkc.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 09:19:45 -0800 (PST)
In-Reply-To: <1329842751.18384.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D0=92 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B8 =D0=BE=D1=
=82 =D0=92=D1=82=D0=BE=D1=80=D0=BD=D0=B8=D0=BA 21 =D1=84=D0=B5=D0=B2=D1=
=80=D0=B0=D0=BB=D1=8F 2012 17:45:51 =D0=B2=D1=8B =D0=BD=D0=B0=D0=BF=D0=B8=
=D1=81=D0=B0=D0=BB=D0=B8:
> Le mardi 21 f=C3=A9vrier 2012 =C3=A0 06:21 +0200, alekcejk@googlemail=
=2Ecom a
>=20
> > I tested last released 3.2.7 kernel (2.6.42.7-1.fc15.i686).
> > Speed problems in 3.2.7 the same as in 3.2.6.
>=20
> I am not sure what you expected from 3.2.7, given we still are
> discussing of issues.
>=20
> > I also have Fedora Rawhide installed in virtual machine (e1000 driv=
er used there)
> > running on host with 3.1.10 kernel.
> > And I noticed that after one of 3.3 rc's (or even rc's of 3.2) kern=
el updates download speed of
> > updates from dl.fedoraproject.org in VM became extremely slow - abo=
ut 160 kilobytes/sec
> > instead of 1,2 megabytes/sec as it was before.
> > But recently (somewhere between 3.3 rc3 and rc4) speed became again
> > as it should 1,2 MB/s.
> >=20
> > Don't know is this problem related with speed in 3.2.x kernels
> > and it is hard to debug this now.
>=20
> We have a pretty clear idea of what happens, we have to decide if we
> must change kernel defaults now or not.
>=20
> On prior kernels, memory accounting was wrong, and a socket could
> consume far more memory than the limit given.
>=20
> See the 3rd column in :
>=20
> net.ipv4.tcp_wmem =3D 4096        16384   897664
> net.ipv4.tcp_rmem =3D 4096        87380   897664
>=20
> We now have a more correct 'truesize' accounting, and this means a
> socket cannot lie anymore : Instead of consuming 1.200.000 bytes for =
receive
> buffers, it really cannot consume more than 897664 bytes.
> (unless yet another driver try to lie)
>=20
> On your 32bit kernel, this means the tcp_rmem[2] (897664) really
> can be too small for your case with a 50 ms RTT, since memory/rtt is
> limiting the bandwidth.
>=20
> On a 64bit kernel, we hit the memory/rtt limit less often because
> tcp_rmem[2] default value is 4127616, unless you have very small
> available memory.
>=20
> Maybe we should default tcp_rmem[2] to 4Mbytes, even on 32bit kernel.
>=20
> Could you try :
>=20
> sysctl net.ipv4.tcp_rmem=3D"4096 87380 4127616"
> or
> echo "4096 87380 4127616" >/proc/sys/net/ipv4/tcp_rmem

Download speed from ftp3.de.freebsd.org increases from 5 MB/s to 10 MB/=
s
after I set "sysctl net.ipv4.tcp_rmem=3D"4096 87380 4127616""" in 3.2.7=
 kernel.

--2012-02-21 18:56:36--  ftp://ftp3.de.freebsd.org/pub/FreeBSD/ISO-IMAG=
ES-i386/8.2/FreeBSD-8.2-RELEASE-i386-dvd1.iso.xz
100%[=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D>] 2 066 424 512 10,3M/=
s  in 3m 17s
2012-02-21 18:59:56 (9,99 MB/s) - =C2=AB/dev/null=C2=BB saved [20664245=
12]

But maximum speed in 3.1.10 kernel (without this sysctl settings) still
a bit more than in 3.2.7 - 11 MB/s instead of 10.3 MB/s.

--2012-02-21 18:56:36--  ftp://ftp3.de.freebsd.org/pub/FreeBSD/ISO-IMAG=
ES-i386/8.2/FreeBSD-8.2-RELEASE-i386-dvd1.iso.xz
100%[=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D>] 2 066 424 512 11,0M/=
s   in 3m 30s  =20
2012-02-21 19:13:55 (9,39 MB/s) - =C2=AB/dev/null=C2=BB saved [20664245=
12]
