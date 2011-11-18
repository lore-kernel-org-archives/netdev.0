From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow the RFC 4942 recommendation
Date: Fri, 18 Nov 2011 11:15:23 +0100
Message-ID: <87sjll7n44.fsf@nemi.mork.no>
References: <1320417988.69298.YahooMailNeo@web126013.mail.ne1.yahoo.com>
	<1320423860.16609.4.camel@edumazet-laptop>
	<1320482392.98040.YahooMailNeo@web126003.mail.ne1.yahoo.com>
	<1320484852.16908.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34718 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752435Ab1KRKWW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 05:22:22 -0500
In-Reply-To: <1320484852.16908.0.camel@edumazet-laptop> (Eric Dumazet's
	message of "Sat, 05 Nov 2011 10:20:52 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> Le samedi 05 novembre 2011 =C3=A0 01:39 -0700, Fran=C3=A7ois-Xavier L=
e Bail a
> =C3=A9crit :
>
>> Agreed, but remain the case of ICMPv6 echo request/reply, which I th=
ink is in kernel.
>
> Yes, please describe your setup and how to reproduce the problem.

I agree with Fran=C3=A7ois-Xavier that the current behaviour is confusi=
ng. An
anycast address should really not be treated different from any other
global unicast address by the kernel.


1) The router anycast address does not show up in the list of local
   addresses:

router:~$ ip -6 addr show dev br0.666
15: br0.666@br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500=20
    inet6 2001:db8:9:29a::1/64 scope global=20
       valid_lft forever preferred_lft forever
    inet6 fe80::215:17ff:fe1e:5e35/64 scope link=20
       valid_lft forever preferred_lft forever



2) pinging the anycast address will produce a reply from another
address:=20

frtest1:~# ping6 -n -c1 2001:db8:9:29a:: =20
PING 2001:db8:9:29a::(2001:db8:9:29a::) 56 data bytes
64 bytes from 2001:db8:9:29a::1: icmp_seq=3D1 ttl=3D64 time=3D0.275 ms

--- 2001:db8:9:29a:: ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 0.275/0.275/0.275/0.000 ms
frtest1:~# ping6 -n -c1 2001:db8:9:29a::1 =20
PING 2001:db8:9:29a::1(2001:db8:9:29a::1) 56 data bytes
64 bytes from 2001:db8:9:29a::1: icmp_seq=3D1 ttl=3D64 time=3D0.229 ms

--- 2001:db8:9:29a::1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 0.229/0.229/0.229/0.000 ms



3) the previous issue will become even more obviously buggy if we add a
second address to the router, in the same subnet while pinging the
anycast address.  Here I'm doing=20

  router:/tmp# ip addr add 2001:db8:9:29a::5/64 dev br0.666

on the router while I'm pinging the anycast address from a another host=
:


frtest1:~# ping6 -n  2001:db8:9:29a:: =20
PING 2001:db8:9:29a::(2001:db8:9:29a::) 56 data bytes
64 bytes from 2001:db8:9:29a::1: icmp_seq=3D1 ttl=3D64 time=3D330 ms
64 bytes from 2001:db8:9:29a::1: icmp_seq=3D2 ttl=3D64 time=3D0.268 ms
64 bytes from 2001:db8:9:29a::1: icmp_seq=3D3 ttl=3D64 time=3D0.234 ms
64 bytes from 2001:db8:9:29a::5: icmp_seq=3D4 ttl=3D64 time=3D0.232 ms
64 bytes from 2001:db8:9:29a::5: icmp_seq=3D5 ttl=3D64 time=3D0.298 ms
64 bytes from 2001:db8:9:29a::5: icmp_seq=3D6 ttl=3D64 time=3D0.279 ms


Now, THAT doesn't look good, does it?


4) just to add to issue 2.  After adding the second address on the
router, we have 3 global unicast addresses in the same subnet. You woul=
d
then expect the kernel to either use the destionation address of the
incoming requests as source, or always select the same address as
source.

It does neither.  This is inconsistent, unless you treat the router
anycast address as something special.  Which you should not:


frtest1:~# ping-n -c1 2001:db8:9:29a:: =20
PING 2001:db8:9:29a::(2001:db8:9:29a::) 56 data bytes
64 bytes from 2001:db8:9:29a::5: icmp_seq=3D1 ttl=3D64 time=3D337 ms

--- 2001:db8:9:29a:: ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 337.251/337.251/337.251/0.000 ms
frtest1:~# ping6 -n -c1 2001:db8:9:29a::1 =20
PING 2001:db8:9:29a::1(2001:db8:9:29a::1) 56 data bytes
64 bytes from 2001:db8:9:29a::1: icmp_seq=3D1 ttl=3D64 time=3D0.163 ms

--- 2001:db8:9:29a::1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 0.163/0.163/0.163/0.000 ms
frtest1:~# ping6 -n -c1 2001:db8:9:29a::5=20
PING 2001:db8:9:29a::5(2001:db8:9:29a::5) 56 data bytes
64 bytes from 2001:db8:9:29a::5: icmp_seq=3D1 ttl=3D64 time=3D3.87 ms

--- 2001:db8:9:29a::5 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 3.873/3.873/3.873/0.000 ms





Bj=C3=B8rn
