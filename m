From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9811] New: Loopback address to eth0 interface
 changes scope permanently
Date: Fri, 25 Jan 2008 02:50:16 -0800
Message-ID: <20080125025016.f6b08754.akpm@linux-foundation.org>
References: <bug-9811-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bugme-daemon@bugzilla.kernel.org, bjorn@mork.no
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36808 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751101AbYAYKua convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2008 05:50:30 -0500
In-Reply-To: <bug-9811-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Fri, 25 Jan 2008 02:04:04 -0800 (PST) bugme-daemon@bugzilla.kernel=
=2Eorg wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=3D9811
>=20
>            Summary: Loopback address to eth0 interface changes scope
>                     permanently
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24-rc8
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: bjorn@mork.no
>=20
>=20
> Latest working kernel version: none
> Earliest failing kernel version: 2.6.18 (verified, but most likely "a=
ny")
> Distribution: Debian
> Hardware Environment:=20
> Software Environment:
> Problem Description:=20
>=20
> >From gary.manchon@gmail.com :
>=20
> After a bad network interface configuration (ifconfig eth0 127.0.0.1)=
,
> I cannot recover the network without rebooting the kernel.
>=20
> This is my working configuration :
>=20
> # ifconfig
> eth0      Link encap:Ethernet  HWaddr 00:90:3E:1F:1C:17
>           inet addr:192.168.240.195  Bcast:192.168.247.255  Mask:255.=
255.248.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:26 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:2633 (2.5 KiB)  TX bytes:0 (0.0 B)
>=20
> lo        Link encap:Local Loopback
>           inet addr:127.0.0.1  Mask:255.0.0.0
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0
>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>=20
> # route
> Kernel IP routing table
> Destination     Gateway         Genmask         Flags Metric Ref    U=
se Iface
> 192.168.240.0   *               255.255.248.0   U     0      0       =
 0 eth0
> default         192.168.240.1   0.0.0.0         UG    0      0       =
 0 eth0
>=20
> # ping -c 1 66.102.11.99
> PING 66.102.11.99 (66.102.11.99): 56 data bytes
> 64 bytes from 66.102.11.99: icmp_seq=3D0 ttl=3D63 time=3D4.5 ms
>=20
> --- 66.102.11.99 ping statistics ---
> 1 packets transmitted, 1 packets received, 0% packet loss
> round-trip min/avg/max =3D 4.5/4.5/4.5 ms
>=20
> Steps to reproduce:
>=20
> # ifconfig eth0 127.0.0.1
> # ifconfig eth0 192.168.240.195 netmask 255.255.248.0
> # route add default gw 192.168.240.1
>=20
>=20
> >From Bj=F8rn Mork <bjorn@mork.no> :
>=20
> I suspect that the problem might be this code in net/ipv4/devinet.c ,
> which sets ifa_scope to RT_SCOPE_HOST if you configure a loopback
> address (127/8) on any interface.  I guess it's there to protect us f=
rom
> sending packets with a loopback source address, which woulnd't look t=
oo
> good:
>=20
> static int inet_set_ifa(struct net_device *dev, struct in_ifaddr *ifa=
)
> {
>         struct in_device *in_dev =3D __in_dev_get_rtnl(dev);
>=20
>         ASSERT_RTNL();
>=20
>         if (!in_dev) {
>                 inet_free_ifa(ifa);
>                 return -ENOBUFS;
>         }
>         ipv4_devconf_setall(in_dev);
>         if (ifa->ifa_dev !=3D in_dev) {
>                 BUG_TRAP(!ifa->ifa_dev);
>                 in_dev_hold(in_dev);
>                 ifa->ifa_dev =3D in_dev;
>         }
>         if (LOOPBACK(ifa->ifa_local))
>                 ifa->ifa_scope =3D RT_SCOPE_HOST;
>         return inet_insert_ifa(ifa);
> }
>=20
>=20
>=20
> The real problem is that there's never anything resetting this scope =
if
> you change the address later.  The attached patch fixes this.
>=20
>=20
> dhcp232:~# ip addr show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qle=
n 1000
>     link/ether 00:aa:00:ff:00:ff brd ff:ff:ff:ff:ff:ff
>     inet 192.168.3.232/24 brd 192.168.3.255 scope global eth0
>     inet6 2001:16d8:ffb4:0:2aa:ff:feff:ff/64 scope global dynamic=20
>        valid_lft 2591971sec preferred_lft 604771sec
>     inet6 fe80::2aa:ff:feff:ff/64 scope link=20
>        valid_lft forever preferred_lft forever
> dhcp232:~# ifconfig eth0 127.0.0.1
> dhcp232:~# ip addr show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qle=
n 1000
>     link/ether 00:aa:00:ff:00:ff brd ff:ff:ff:ff:ff:ff
>     inet 127.0.0.1/8 brd 127.255.255.255 scope host eth0
>     inet6 2001:16d8:ffb4:0:2aa:ff:feff:ff/64 scope global dynamic=20
>        valid_lft 2591951sec preferred_lft 604751sec
>     inet6 fe80::2aa:ff:feff:ff/64 scope link=20
>        valid_lft forever preferred_lft forever
> dhcp232:~# ifconfig eth0 192.168.3.232
> dhcp232:~# ip addr show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qle=
n 1000
>     link/ether 00:aa:00:ff:00:ff brd ff:ff:ff:ff:ff:ff
>     inet 192.168.3.232/24 brd 192.168.3.255 scope host eth0
>     inet6 2001:16d8:ffb4:0:2aa:ff:feff:ff/64 scope global dynamic=20
>        valid_lft 2591933sec preferred_lft 604733sec
>     inet6 fe80::2aa:ff:feff:ff/64 scope link=20
>        valid_lft forever preferred_lft forever
>=20
>=20
>=20
> Notice how the scope changes from "global" to "host" when configuring
> 127.0.0.1, and just never changes back.  It will stay that way foreve=
r,
> or until something changes the scope or deletes the address.
>=20
> Deleting the addresss and re-adding it will work around the problem:
>=20
> dhcp232:~# ip addr del 192.168.3.232/24 dev eth0
> dhcp232:~# ifconfig eth0 192.168.3.232
> dhcp232:~# ip addr show dev eth0
> 2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qle=
n 1000
>     link/ether 00:aa:00:ff:00:ff brd ff:ff:ff:ff:ff:ff
>     inet 192.168.3.232/24 brd 192.168.3.255 scope global eth0
>     inet6 2001:16d8:ffb4:0:2aa:ff:feff:ff/64 scope global dynamic=20
>        valid_lft 2591963sec preferred_lft 604763sec
>     inet6 fe80::2aa:ff:feff:ff/64 scope link=20
>        valid_lft forever preferred_lft forever
>=20
>=20
> Bj=F8rn
