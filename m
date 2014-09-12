From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: connect returns EADDRNOTAVAIL on ~600k+ sockets host
Date: Sat, 13 Sep 2014 00:09:21 +0300
Message-ID: <9a6fe925901b2259a573bcf1e57cf2de@visp.net.lb>
References: <d9db14adbac97234729b112ebfa87c91@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:53270 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbaILVJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 17:09:23 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id F31424823EB
	for <netdev@vger.kernel.org>; Sat, 13 Sep 2014 00:09:21 +0300 (EEST)
Received: from webmail.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id AB6894823EB
	for <netdev@vger.kernel.org>; Sat, 13 Sep 2014 00:09:21 +0300 (EEST)
In-Reply-To: <d9db14adbac97234729b112ebfa87c91@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After some "printk" debugging, also found additional information,
error is returned in __inet_hash_connect, as i understand because it=20
can't find
free local port.
But i dont think correct, that on such loaded server basic=20
socket/connect sequence will not work, while there is for sure free=20
ports on ips used for outgoing connection.

On 2014-09-12 21:18, Denys Fedoryshchenko wrote:
> Hi
>=20
> I noticed strange behaviour on loaded server (haproxy), while it is
> handling load for https traffic well, tcp monitoring started to give
> false alerts. And here what i found:
>=20
> HTTPS-BALANCER ~ # telnet 127.0.0.1 23
> telnet: can't connect to remote host (127.0.0.1): Cannot assign
> requested address
> HTTPS-BALANCER ~ # nc -v 127.0.0.1 23
> 127.0.0.1 (127.0.0.1:23) open
> =EF=BF=BD=EF=BF=BD=01=EF=BF=BD=EF=BF=BD=1F=EF=BF=BD=EF=BF=BD=01=EF=BF=
=BD=EF=BF=BD=03
> HTTPS-BALANCER login: ^Cpunt!
>=20
> The difference is (relevant lines from strace):
>=20
> socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 3
> setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> bind(3, {sa_family=3DAF_INET, sin_port=3Dhtons(0),
> sin_addr=3Dinet_addr("0.0.0.0")}, 16) =3D 0
> rt_sigaction(SIGALRM, {0x41ecfb, [ALRM], SA_RESTORER|SA_RESTART,
> 0x7f80725bf5b0}, {SIG_DFL, [], 0}, 8) =3D 0
> alarm(0)                                =3D 0
> connect(3, {sa_family=3DAF_INET, sin_port=3Dhtons(23),
> sin_addr=3Dinet_addr("127.0.0.1")}, 16) =3D 0
> rt_sigaction(SIGALRM, {SIG_IGN, [ALRM], SA_RESTORER|SA_RESTART,
> 0x7f80725bf5b0}, {0x41ecfb, [ALRM], SA_RESTORER|SA_RESTART, 0x7
>=20
>=20
> socket(PF_INET, SOCK_STREAM, IPPROTO_IP) =3D 3
> setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> connect(3, {sa_family=3DAF_INET, sin_port=3Dhtons(23),
> sin_addr=3Dinet_addr("127.0.0.1")}, 16) =3D -1 EADDRNOTAVAIL (Cannot
> assign requested address)
> write(2, "telnet: can't connect to remote host (127.0.0.1): Cannot
> assign requested address\n", 82telnet: can't connect to remote host
> (127.0.0.1): Cannot assign requested address
>=20
> So,
> bind(3, {sa_family=3DAF_INET, sin_port=3Dhtons(0),
> sin_addr=3Dinet_addr("0.0.0.0")}, 16) =3D 0
> is fixing issue, but is it really supposed to be like this?
>=20
> Just for information host load and some network stats:
> from /proc/net/protocols, i removed irrelevant zero values entries
>=20
> protocol  size sockets  memory press maxhdr  slab module     cl co di
> ac io in de sh ss gs se re sp bi br ha uh gp em
> UDP        816      1       0   NI       0   yes  kernel      y  y  y
> n  y  n  y  n  y  y  y  y  y  n  y  y  y  y  n
> TCP       1640 728255  751777   no     208   yes  kernel      y  y  y
> y  y  y  y  y  y  y  y  y  y  n  y  y  y  y  y
>=20
> sockets: used 674375
> TCP: inuse 727092 orphan 55119 tw 138533 alloc 729419 mem 745187
> UDP: inuse 1 mem 0
> UDPLITE: inuse 0
> RAW: inuse 0
> FRAG: inuse 0 memory 0
>=20
> 0.0.0.0 sockets:
> tcp        0      0 0.0.0.0:65530           0.0.0.0:*              =20
> LISTEN
> tcp        0      0 0.0.0.0:443             0.0.0.0:*              =20
> LISTEN
> tcp        0      0 0.0.0.0:8880            0.0.0.0:*              =20
> LISTEN
> tcp        0      0 0.0.0.0:22              0.0.0.0:*              =20
> LISTEN
> tcp        0      0 0.0.0.0:23              0.0.0.0:*              =20
> LISTEN
> udp        0      0 0.0.0.0:53073           0.0.0.0:*
>=20
> 127.0.0.1 sockets (this is watchdog, but if i disable, it wont change=
=20
> anything)
> tcp        0      0 127.0.0.1:65530         127.0.0.1:55649        =20
> TIME_WAIT
> tcp        0      0 127.0.0.1:65530         127.0.0.1:41762        =20
> FIN_WAIT2
> tcp        0      0 127.0.0.1:65530         127.0.0.1:36863        =20
> TIME_WAIT
> tcp        0      0 127.0.0.1:65530         127.0.0.1:34533        =20
> TIME_WAIT
> tcp        0      0 127.0.0.1:65530         127.0.0.1:35262        =20
> TIME_WAIT
> tcp        0      0 127.0.0.1:65530         127.0.0.1:45872        =20
> TIME_WAIT
