From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 42012] New: regression on 2.6.39.3 with socket/bind;
 still there in 3.0.4
Date: Tue, 30 Aug 2011 18:11:48 +0200
Message-ID: <1314720708.2935.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20110830084742.26c72c20@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43960 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755493Ab1H3QLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 12:11:48 -0400
Received: by wyg24 with SMTP id 24so5043434wyg.19
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 09:11:46 -0700 (PDT)
In-Reply-To: <20110830084742.26c72c20@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 ao=C3=BBt 2011 =C3=A0 08:47 -0700, Stephen Hemminger a =C3=A9=
crit :
> Interesting? Does the kernel ABI include supporting buggy old proprie=
tary
> programs?
>=20
> Begin forwarded message:
>=20
> Date: Tue, 30 Aug 2011 02:59:32 GMT
> From: bugzilla-daemon@bugzilla.kernel.org
> To: shemminger@linux-foundation.org
> Subject: [Bug 42012] New: regression on 2.6.39.3 with socket/bind; st=
ill there in 3.0.4
>=20
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D42012
>=20
>            Summary: regression on 2.6.39.3 with socket/bind; still th=
ere
>                     in 3.0.4
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.39.3 - 3.0.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: r_meier@freenet.de
>         Regression: Yes
>=20
>=20
> Hi,
>=20
> the regression has been introduced in 2.6.39.3 with commit
> d0733d2e29b652b2e7b1438ececa732e4eed98eb. I experience this with a pr=
oprietary
> binary program. So I cant give you the source code which fails. This =
program
> used to work before but fails after applying this patch. As far as I =
understand
> the programm is using this code for ipc communication. I have recorde=
d the
> strace output of the relevant part of the program.
> strace without d0733d2e29b652b2e7b1438ececa732e4eed98eb on kernel 2.6=
=2E39.2
> ---------------
> 2056  socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 4
> 2056  bind(4, {sa_family=3DAF_UNSPEC, sa_data=3D"\0\0\0\0\0\0\0\0\0\0=
\0\0\0\0"},
> 16) =3D 0
> 2056  getsockname(4, {sa_family=3DAF_INET, sin_port=3Dhtons(33537),
> sin_addr=3Dinet_addr("0.0.0.0")}, [16]) =3D 0
> 2056  listen(4, 5)                      =3D 0
> 2056  setsockopt(4, SOL_TCP, TCP_NODELAY, [1], 4) =3D 0
> ---------------
>=20
> strace with d0733d2e29b652b2e7b1438ececa732e4eed98eb on kernel 2.6.39=
=2E2
> ---------------
> 6190  socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 4
> 6190  bind(4, {sa_family=3DAF_UNSPEC, sa_data=3D"\0\0\0\0\0\0\0\0\0\0=
\0\0\0\0"},
> 16) =3D -1 EINVAL (Invalid argument)
> 6190  dup(2)                            =3D 11
> 6190  fcntl64(11, F_GETFL)              =3D 0x8002 (flags O_RDWR|O_LA=
RGEFILE)
> 6190  fstat64(11, {st_mode=3DS_IFCHR|0600, st_rdev=3Dmakedev(136, 3),=
 ...}) =3D 0
> 6190  mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMO=
US, -1, 0)
> =3D 0x576ac000
> 6190  _llseek(11, 0, 0xffa03de4, SEEK_CUR) =3D -1 ESPIPE (Illegal see=
k)
> 6190  write(11, "ERROR: Failed to bind to interne"..., 66) =3D 66
> 6190  close(11)                         =3D 0
> ---------------
>=20
> Btw, i have not enough knowledge on this topic to decide whether its =
the
> programs fault or the kernels fault. The binary program is sybyl8.1 f=
rom
> tripos.
>=20
> Best regards, Rene
>=20

Yep, we should relax the check and accept AF_UNSPEC.

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1b745d4..60fd64e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -465,7 +465,7 @@ int inet_bind(struct socket *sock, struct sockaddr =
*uaddr, int addr_len)
 	if (addr_len < sizeof(struct sockaddr_in))
 		goto out;
=20
-	if (addr->sin_family !=3D AF_INET) {
+	if (addr->sin_family !=3D AF_INET && addr->sin_family !=3D AF_UNSPEC)=
 {
 		err =3D -EAFNOSUPPORT;
 		goto out;
 	}
