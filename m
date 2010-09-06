From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Mon, 06 Sep 2010 21:42:12 +0200
Message-ID: <1283802132.2585.4.camel@edumazet-laptop>
References: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Krzysztof Oledzki <ole@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58872 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883Ab0IFTmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 15:42:18 -0400
Received: by wwj40 with SMTP id 40so6994771wwj.1
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 12:42:16 -0700 (PDT)
In-Reply-To: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 septembre 2010 =C3=A0 19:11 +0200, Krzysztof Oledzki a =C3=A9=
crit :
> Hello,
>=20
> For the last two days I have been trying to track a starange problem =
I=20
> bumped into after upgrading my kernel from 2.6.31.12 to 2.6.34.6.
>=20
> The problem is that several times a day, nagios logs that plugins are=
 not=20
> able to resolve DNS hostnames of monitored hosts. The DNS service is=20
> provided locally by the host itself so all traffic is handled over a=20
> loopback interface. The host handles rather moderate traffic - ~1000p=
ps=20
> and ~30 DNS requests per second. This DNS service is also provided to=
=20
> other hosts that are also running 2.6.34.6 and are connected over a=20
> Ethernet network, but the problem exists only locally.
>=20
> After a long investigation I found that I'm able to reproduce this pr=
oblem=20
> by adding: "*.t IN A 127.0.0.1" to the "lan" zone and using the follo=
wing=20
> script:
>=20
> --- cut here ---
> a=3D0
> while strace -o /tmp/s.log.1 -s 1024  /usr/lib64/nagios/plugins/check=
_icmp -H $a.t.lan ; do
>   date
>   sleep 0.1
>   a=3D$((a+1))
> done
> -- cut here ---
>=20
> Strace shows that the problem is in receiving responses from the=20
> nameserver:
>=20
> socket(PF_INET, SOCK_DGRAM|SOCK_NONBLOCK, IPPROTO_IP) =3D 4
> connect(4, {sa_family=3DAF_INET, sin_port=3Dhtons(53), sin_addr=3Dine=
t_addr("192.168.130.53")}, 28) =3D 0
> poll([{fd=3D4, events=3DPOLLOUT}], 1, 0)    =3D 1 ([{fd=3D4, revents=3D=
POLLOUT}])
> sendto(4, "\333b\1\0\0\1\0\0\0\0\0\0\0041817\1t\3lan\0\0\1\0\1", 28, =
MSG_NOSIGNAL, NULL, 0) =3D 28
> poll([{fd=3D4, events=3DPOLLIN}], 1, 5000)  =3D 0 (Timeout)
> poll([{fd=3D4, events=3DPOLLOUT}], 1, 0)    =3D 1 ([{fd=3D4, revents=3D=
POLLOUT}])
> sendto(4, "\333b\1\0\0\1\0\0\0\0\0\0\0041817\1t\3lan\0\0\1\0\1", 28, =
MSG_NOSIGNAL, NULL, 0) =3D 28
> poll([{fd=3D4, events=3DPOLLIN}], 1, 5000)  =3D 0 (Timeout)
> close(4)                                =3D 0
>=20
> However, tcpdump attached to lo shows that both the request and=20
> the response are properly delivered:
>=20
> 03:00:47.181529 IP (tos 0x0, ttl 64, id 47869, offset 0, flags [DF], =
proto UDP (17), length 56)
>      192.168.130.53.41083 > 192.168.130.53.53: 56162+ A? 1817.t.lan. =
(28)
> 03:00:47.181585 IP (tos 0x0, ttl 64, id 29563, offset 0, flags [none]=
, proto UDP (17), length 112)
>      192.168.130.53.53 > 192.168.130.53.41083: 56162* 1/1/1 1817.t.la=
n. A 127.0.0.1 (84)
> --
> 03:00:52.186465 IP (tos 0x0, ttl 64, id 47870, offset 0, flags [DF], =
proto UDP (17), length 56)
>      192.168.130.53.41083 > 192.168.130.53.53: 56162+ A? 1817.t.lan. =
(28)
> 03:00:52.186580 IP (tos 0x0, ttl 64, id 29576, offset 0, flags [none]=
, proto UDP (17), length 112)
>      192.168.130.53.53 > 192.168.130.53.41083: 56162* 1/1/1 1817.t.la=
n. A 127.0.0.1 (84)
>=20
> 03:00:57.298221 IP (tos 0x0, ttl 64, id 57985, offset 0, flags [DF], =
proto UDP (17), length 60)
>      192.168.130.53.39370 > 192.168.130.53.53: 145+ A? 1817.t.lan.lan=
=2E (32)
> 03:00:57.298300 IP (tos 0x0, ttl 64, id 29584, offset 0, flags [none]=
, proto UDP (17), length 116)
>      192.168.130.53.53 > 192.168.130.53.39370: 145 NXDomain* 0/1/0 (8=
8)
>=20
> In most cases it takes from 2m to 15m to trigger this error and so fa=
r I=20
> have not been able to reproduce it on my lab environment. Downgrading=
=20
> the kernel back to 2.6.31 cures the issue.
>=20
> I have a very short service window so bisecting is nearly impossible.=
=20
> During the next few days I should be able to find if this problem was=
=20
> introduced in 2.6.32 or 2.6.33, but if you have clues what to check f=
irst=20
> or idea about some smart debug patches, I will be very grateful.

Do you have iptables and conntracking loaded ?

Maybe frame is droped by firewall on this particular port (39370 )



