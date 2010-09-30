From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet time delays on multi-core systems
Date: Thu, 30 Sep 2010 20:03:02 +0200
Message-ID: <1285869782.2615.920.camel@edumazet-laptop>
References: <20100929191851.GC86786@beaver.vrungel.ru>
	 <1285796721.5211.156.camel@edumazet-laptop>
	 <20100930062419.GD86786@beaver.vrungel.ru>
	 <1285828432.5211.812.camel@edumazet-laptop>
	 <20100930122321.GA1575@beaver.vrungel.ru>
	 <1285850669.2615.426.camel@edumazet-laptop>
	 <20100930173732.GB4094@beaver.vrungel.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Alexey Vlasov <renton@renton.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100930173732.GB4094@beaver.vrungel.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 30 septembre 2010 =C3=A0 21:37 +0400, Alexey Vlasov a =C3=A9cr=
it :
> On Thu, Sep 30, 2010 at 02:44:29PM +0200, Eric Dumazet wrote:
> > Le jeudi 30 septembre 2010 ?? 16:23 +0400, Alexey Vlasov a ??crit :
> > > On Thu, Sep 30, 2010 at 08:33:52AM +0200, Eric Dumazet wrote:
> > > > Le jeudi 30 septembre 2010 ?? 10:24 +0400, Alexey Vlasov a ??cr=
it :
> > > > > Here I found some dude with the same problem:
> > > > > http://lkml.org/lkml/2010/7/9/340
> > > =20
> > > Well I put interrups from NIC, namely tx/rx query, to different
> > > processors and got normal pings by adding LOG rule.
> > >=20
> > > I also found that overruns is constantly growing, I don't know if=
 these are connected.
> > > RX packets:2831439546 errors:0 dropped:134726 overruns:947671733 =
frame:0
> > > TX packets:2880849825 errors:0 dropped:0 overruns:0 carrier:0
> > >=20
>=20
> Too early to be happy, concerning one rule- the situation got better,=
 but still
> there are some time delays. But adding one more rule:
> -A INPUT -p all -m state --state INVALID -j LOG --log-prefix
> "ipsec:IN-INVALID "
> it got totally wrecked:
> ...
> 64 bytes from (10.0.2.17): icmp_seq=3D24 ttl=3D64 time=3D0.342 ms
> 64 bytes from (10.0.2.17): icmp_seq=3D25 ttl=3D64 time=3D1868 ms
> 64 bytes from (10.0.2.17): icmp_seq=3D26 ttl=3D64 time=3D1448 ms
> 64 bytes from (10.0.2.17): icmp_seq=3D27 ttl=3D64 time=3D447 ms
> 64 bytes from (10.0.2.17): icmp_seq=3D28 ttl=3D64 time=3D0.196 ms
> ...
> 100 packets transmitted, 100 received, 0% packet loss, time 99990ms
> rtt min/avg/max/mdev =3D 0.108/39.068/1868.663/237.507 ms, pipe 2
>=20
> # iptables -L -v -n
> Chain INPUT (policy ACCEPT 601K packets, 475M bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>   275 11096 LOG        all  --  *      *       0.0.0.0/0            0=
=2E0.0.0/0           state INVALID LOG flags 0 level 4 prefix `ipsec:IN=
-INVALID '
>=20
> Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
>=20
> Chain OUTPUT (policy ACCEPT 529K packets, 561M bytes)
>  pkts bytes target     prot opt in     out     source               d=
estination
> 13979  839K LOG        tcp  --  *      *       0.0.0.0/0            0=
=2E0.0.0/0           tcp dpt:80 flags:0x17/0x02 LOG flags 8 level 4 pre=
fix `ipsec:SYN-OUTPUT-DROP '
> =20
> > > Here goes the typical distribution of interrups on new servers:
> > >            CPU0    CPU1    CPU2    CPU3 ... CPU23
> > > 752:         11       0       0       0 ...     0 PCI-MSI-edge et=
h0
> > > 753: 2799366721       0       0       0 ...     0 PCI-MSI-edge et=
h0-rx3
> > > 754: 2821840553       0       0       0 ...     0 PCI-MSI-edge et=
h0-rx2
> > > 755: 2786117044       0       0       0 ...     0 PCI-MSI-edge et=
h0-rx1
> > > 756: 2896099336       0       0       0 ...     0 PCI-MSI-edge et=
h0-rx0
> > > 757: 1808404680       0       0       0 ...     0 PCI-MSI-edge et=
h0-tx3
> > > 758: 1797855130       0       0       0 ...     0 PCI-MSI-edge et=
h0-tx2
> > > 759: 1807222032       0       0       0 ...     0 PCI-MSI-edge et=
h0-tx1
> > > 760: 1820309360       0       0       0 ...     0 PCI-MSI-edge et=
h0-tx0
> > >=20
> >=20
> > echo 01 >/proc/irq/*/eth0-rx0/../smp_affinity
> > echo 02 >/proc/irq/*/eth0-rx1/../smp_affinity
> > echo 04 >/proc/irq/*/eth0-rx2/../smp_affinity
> > echo 08 >/proc/irq/*/eth0-rx3/../smp_affinity
> >=20
> >=20
> > cat /proc/irq/*/eth0-rx0/../smp_affinity
> > cat /proc/irq/*/eth0-rx1/../smp_affinity
> > cat /proc/irq/*/eth0-rx2/../smp_affinity
> > cat /proc/irq/*/eth0-rx3/../smp_affinity
> =20
> The last test were made already concerning such rx queue binding:
> # cat /proc/irq/60/smp_affinity
> 001000
> # cat /proc/irq/61/smp_affinity
> 010000
> # cat /proc/irq/62/smp_affinity
> 080000
> # cat /proc/irq/63/smp_affinity
> 800000
>=20

Why 60, 61, 62, 63 ? This should be 753, 754, 755, 756



> Now ksoftirqd eats not only one processor but all oness where I assig=
ned the IRQs.
>=20
> > > On the old ones:
> > >            CPU0       CPU1       CPU2  ...      CPU8
> > > 502:  522320256  522384039  522327386  ... 522380267 PCI-MSI-edge=
 eth0
> > >=20
> >=20
> > What network driver is it (newbox), was it (old box) ?
>=20
> newbox:
> 01:00.0 Ethernet controller: Intel Corporation 82575EB Gigabit Networ=
k
> Connection (rev 02)
> driver: igb
> version: 1.3.16-k2
> firmware-version: 2.1-0
> bus-info: 0000:01:00.0
>=20
> oldbox:
> 05:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
> Ethernet Controller (Copper) (rev 01)
> driver: e1000e
> version: 0.3.3.3-k6
> firmware-version: 1.0-0
> bus-info: 0000:05:00.0
>=20
