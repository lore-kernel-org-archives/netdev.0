From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Problems with dropped packets on bonded interface for 3.x
 kernels
Date: Mon, 21 Nov 2011 07:32:03 +0100
Message-ID: <1321857123.17419.2.camel@edumazet-laptop>
References: <20111121051603.GB3702@china>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51068 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294Ab1KUGcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 01:32:07 -0500
Received: by wwe5 with SMTP id 5so9909087wwe.1
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2011 22:32:06 -0800 (PST)
In-Reply-To: <20111121051603.GB3702@china>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 20 novembre 2011 =C3=A0 23:16 -0600, Albert Chin a =C3=A9cr=
it :
> I'm running Ubuntu 11.10 on an Intel SR2625URLXR system with an Intel
> S5520UR motherboard and an internal Intel E1G44HT (I340-T4) Quad Port
> Server Adapter. I am seeing dropped packets on a bonded interface,
> comprised of two GigE ports on the Intel E1G44HT Quad Port Server
> Adapter. The following kernels exhibit this problem:
>   3.0.0-12-server, 3.0.0-13-server, 3.1.0-2-server, 3.2.0-rc2
> Installing Fedora 16 with a 3.1.1-1.fc16.x86_64 also showed dropped
> packets.
>=20
> I also tried RHEL6 with a 2.6.32-131.17.1.el6.x86_64 kernel and didn'=
t
> see any dropped packets. Testing an older 2.6.32-28.55-generic Ubuntu
> kernel also didn't show any dropped packets.
>=20
> So, with 2.6, I don't see dropped packets, but everything including
> 3.0 and after show dropped packets.
>=20
> # ifconfig bond0
> bond0     Link encap:Ethernet  HWaddr 00:1b:21:d3:f6:0a =20
>           inet6 addr: fe80::21b:21ff:fed3:f60a/64 Scope:Link
>           UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
>           RX packets:225 errors:0 dropped:186 overruns:0 frame:0
>           TX packets:231 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0=20
>           RX bytes:25450 (25.4 KB)  TX bytes:28368 (28.3 KB)
>=20
> With lacp_rate=3Dfast, I see higher packet loss than with
> lacp_rate=3Dslow. I've tried bonding t
>=20
> This server has the following network controllers for the two interna=
l
> NICs:
>   # lspci -vv
>   01:00.0 Ethernet controller: Intel Corporation 82575EB Gigabit Netw=
ork Connection (rev 02)
>   01:00.1 Ethernet controller: Intel Corporation 82575EB Gigabit Netw=
ork Connection (rev 02)
>=20
> And it has the following network controllers for the four NICs on the
> I340-T4 PCI-E card:
>   # lspci -vv
>   0a:00.0 Ethernet controller: Intel Corporation 82580 Gigabit Networ=
k Connection (rev 01)
>   0a:00.1 Ethernet controller: Intel Corporation 82580 Gigabit Networ=
k Connection (rev 01)
>   0a:00.2 Ethernet controller: Intel Corporation 82580 Gigabit Networ=
k Connection (rev 01)
>   0a:00.3 Ethernet controller: Intel Corporation 82580 Gigabit Networ=
k Connection (rev 01)
>=20
> I tried bonding the two 82575EB NICs rather than two NICs on the 8258=
0
> but see the same dropped packet issue.
>=20
> I have replaced the cables, tested each port individually on the
> switch without bonding, and don't see any reason to expect hardware a=
s
> the issue. The switch is a Summit Extreme 400-48t.
>=20
> I am using a 802.3ad configuration:
> # cat /proc/net/bonding/bond0
> Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)
>=20
> Bonding Mode: IEEE 802.3ad Dynamic link aggregation
> Transmit Hash Policy: layer2 (0)
> MII Status: up
> MII Polling Interval (ms): 100
> Up Delay (ms): 200
> Down Delay (ms): 0
>=20
> 802.3ad info
> LACP rate: fast
> Aggregator selection policy (ad_select): stable
> Active Aggregator Info:
>         Aggregator ID: 1
>         Number of ports: 1
>         Actor Key: 17
>         Partner Key: 24
>         Partner Mac Address: 00:04:96:18:54:d5
>=20
> Slave Interface: eth4
> MII Status: up
> Speed: 1000 Mbps
> Duplex: full
> Link Failure Count: 0
> Permanent HW addr: 00:1b:21:d3:f6:0a
> Aggregator ID: 1
> Slave queue ID: 0
>=20
> Slave Interface: eth5
> MII Status: up
> Speed: 1000 Mbps
> Duplex: full
> Link Failure Count: 0
> Permanent HW addr: 00:1b:21:d3:f6:0b
> Aggregator ID: 2
> Slave queue ID: 0
>=20
> Anyone have any ideas?
>=20

Old kernels were dropping some packets (unknown protocols...) without
counting them.

So following patch was added in 2.6.37 :

You could use tcdpump to identify what are these dropped packets :)

commit caf586e5f23cebb2a68cbaf288d59dbbf2d74052
Author: Eric Dumazet <eric.dumazet@gmail.com>
Date:   Thu Sep 30 21:06:55 2010 +0000

    net: add a core netdev->rx_dropped counter
   =20
    In various situations, a device provides a packet to our stack and =
we
    drop it before it enters protocol stack :
    - softnet backlog full (accounted in /proc/net/softnet_stat)
    - bad vlan tag (not accounted)
    - unknown/unregistered protocol (not accounted)
   =20
    We can handle a per-device counter of such dropped frames at core l=
evel,
    and automatically adds it to the device provided stats (rx_dropped)=
, so
    that standard tools can be used (ifconfig, ip link, cat /proc/net/d=
ev)
   =20
    This is a generalization of commit 8990f468a (net: rx_dropped
    accounting), thus reverting it.
   =20
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
