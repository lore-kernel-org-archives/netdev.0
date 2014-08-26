From: "Fedor Babkin" <fedor.babkin@gmx.net>
Subject: Aw: Re: Routes with unreachable gateways are staying in the routing
 table and they are functional
Date: Tue, 26 Aug 2014 09:53:15 +0200
Message-ID: <trinity-760989cf-0ea4-496a-9992-02ed85a5ffe5-1409039594977@3capp-gmx-bs38>
References: <trinity-f1954363-c4ef-47d2-9508-7174b7e2501e-1408720289787@3capp-gmx-bs15>,
 <alpine.LFD.2.11.1408221856210.7852@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Julian Anastasov" <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:51533 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932290AbaHZHxR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 03:53:17 -0400
In-Reply-To: <alpine.LFD.2.11.1408221856210.7852@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Julian,

Thanks for your feedback. For IPv4 the situation is clear, you have to =
configure more that one subnet to the interface in order to start exper=
iencing this issue. However exactly the same issue exists in IPv6, wher=
e once you configure a single address, you have to count on effectively=
 having 2 addresses on the interface, due to the presence of a link-loc=
al address fe80::xxxx. Moreover with IPv6 stateless address autoconfigu=
ration (RFC 4862), there is more address configuration dynamics in IPv6=
 comparing to IPv4. I would say this issue has a higher visibility and =
side-effect potential. Is there anyone looking into this issue from IPv=
6 perspective?

Thanks,
=46edor


	Hello,

On Fri, 22 Aug 2014, Fedor Babkin wrote:

> Hello,
>=20
> I noticed that in case a network interface has two addresses assigned=
 (no matter if IPv4 or IPv6) from subnets A and B, the route to reach s=
ubnet C via the gateway in A is staying configured and functional when =
subnet A is removed from the interface. Let me illustrate the behavior =
with IPv4 example.
>=20
> Starting point. eth0 has 2 subnets, the route to reach 3-rd subnet vi=
a gw in one of them is present:
> eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast sta=
te UP group default qlen 1000
>     link/ether 52:54:00:12:34:57 brd ff:ff:ff:ff:ff:ff
>     inet 10.20.10.3/24 brd 10.20.10.255 scope global eth0
>        valid_lft forever preferred_lft forever
>     inet 10.30.10.3/24 brd 10.30.10.255 scope global eth0
>        valid_lft forever preferred_lft forever
>     inet6 fe80::5054:ff:fe12:3457/64 scope link
>        valid_lft forever preferred_lft forever
> root@...ntu14-4-vm:~# ip ro ls
> 10.11.10.0/24 via 10.30.10.1 dev eth0
> 10.20.10.0/24 dev eth0  proto kernel  scope link  src 10.20.10.3
> 10.30.10.0/24 dev eth0  proto kernel  scope link  src 10.30.10.3
>=20
> Delete 10.30.10.3/24, the indirect route persists:
> root@...ntu14-4-vm:~# ip ro ls
> 10.11.10.0/24 via 10.30.10.1 dev eth0
> 10.20.10.0/24 dev eth0  proto kernel  scope link  src 10.20.10.3
>=20
> Ping to destinations in 10.11.10.0/24 works, unreachable gateway 10.3=
0.10.1 is resolved, even recovers in case of neighbor flushes.
> root@...ntu14-4-vm:~# ping 10.11.10.1
> PING 10.11.10.1 (10.11.10.1) 56(84) bytes of data.
> 64 bytes from 10.11.10.1: icmp_seq=3D1 ttl=3D64 time=3D0.706 ms
> root@...ntu14-4-vm:~# ip n l
> 10.30.10.1 dev eth0 lladdr 52:54:00:12:34:56 REACHABLE
>=20
> The above was observed with kernel version 2.6.32 and confirmed with =
3.13.0 In case of IPv6 this behavior is more disturbing as there is alw=
ays LLA assigned, so applications have to orchestrate the removal of un=
reachable routes.=20
> If it's an intended implementation, would be helpful to know a reason=
 behind it. Thanks for your support.

	It is expensive to implement solution for this
problem. If we try to be very strict by handling it
at FIB level (catch route removal) simple operations
like secondary address promotion or route replacement
can lead to cascade of route removals. At the end,
it is again the user who have to take care to add
all lost routes back. So, it is a complex task to
solve.

	Here is recent discussion on such topic:

http://marc.info/?t=3D139030500700005&r=3D1&w=3D2
http://marc.info/?t=3D139055890700002&r=3D1&w=3D2

Regards

--
Julian Anastasov
--
=C2=A0
=C2=A0

Gesendet:=C2=A0Freitag, 22. August 2014 um 18:28 Uhr
Von:=C2=A0"Julian Anastasov" <ja@ssi.bg>
An:=C2=A0"Fedor Babkin" <fedor.babkin@gmx.net>
Cc:=C2=A0netdev@vger.kernel.org
Betreff:=C2=A0Re: Routes with unreachable gateways are staying in the r=
outing table and they are functional
Hello, On Fri, 22 Aug 2014, Fedor Babkin wrote: > Hello, > > I noticed =
that in case a network interface has two addresses assigned (no matter =
if IPv4 or IPv6) from subnets A and B, the route to reach subnet C via =
the gateway in A is staying configured and functional when subnet A is =
removed from the interface. Let me illustrate the behavior with IPv4 ex=
ample. > > Starting point. eth0 has 2 subnets, the route to reach 3-rd =
subnet via gw in one of them is present: > eth0: mtu 1500 qdisc pfifo_f=
ast state UP group default qlen 1000 > link/ether 52:54:00:12:34:57 brd=
 ff:ff:ff:ff:ff:ff > inet 10.20.10.3/24 brd 10.20.10.255 scope global e=
th0 > valid_lft forever preferred_lft forever > inet 10.30.10.3/24 brd =
10.30.10.255 scope global eth0 > valid_lft forever preferred_lft foreve=
r > inet6 fe80::5054:ff:fe12:3457/64 scope link > valid_lft forever pre=
ferred_lft forever > root@ubuntu14-4-vm:~# ip ro ls > 10.11.10.0/24 via=
 10.30.10.1 dev eth0 > 10.20.10.0/24 dev eth0 proto kernel scope link s=
rc 10.20.10.3 > 10.30.10.0/24 dev eth0 proto kernel scope link src 10.3=
0.10.3 > > Delete 10.30.10.3/24, the indirect route persists: > root@ub=
untu14-4-vm:~# ip ro ls > 10.11.10.0/24 via 10.30.10.1 dev eth0 > 10.20=
=2E10.0/24 dev eth0 proto kernel scope link src 10.20.10.3 > > Ping to =
destinations in 10.11.10.0/24 works, unreachable gateway 10.30.10.1 is =
resolved, even recovers in case of neighbor flushes. > root@ubuntu14-4-=
vm:~# ping 10.11.10.1 > PING 10.11.10.1 (10.11.10.1) 56(84) bytes of da=
ta. > 64 bytes from 10.11.10.1: icmp_seq=3D1 ttl=3D64 time=3D0.706 ms >=
 root@ubuntu14-4-vm:~# ip n l > 10.30.10.1 dev eth0 lladdr 52:54:00:12:=
34:56 REACHABLE > > The above was observed with kernel version 2.6.32 a=
nd confirmed with 3.13.0 In case of IPv6 this behavior is more disturbi=
ng as there is always LLA assigned, so applications have to orchestrate=
 the removal of unreachable routes. > If it's an intended implementatio=
n, would be helpful to know a reason behind it. Thanks for your support=
=2E It is expensive to implement solution for this problem. If we try t=
o be very strict by handling it at FIB level (catch route removal) simp=
le operations like secondary address promotion or route replacement can=
 lead to cascade of route removals. At the end, it is again the user wh=
o have to take care to add all lost routes back. So, it is a complex ta=
sk to solve. Here is recent discussion on such topic: http://marc.info/=
?t=3D139030500700005&r=3D1&w=3D2 http://marc.info/?t=3D139055890700002&=
r=3D1&w=3D2 Regards -- Julian Anastasov
