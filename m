From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: routing bug?
Date: Fri, 18 Nov 2011 14:09:56 +0100
Message-ID: <1321621796.3277.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EC648C9.8080405@uhulinux.hu>
	 <alpine.DEB.2.02.1111181346480.17023@aurora>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Pozs=E1r_Bal=E1zs?= <pozsy@uhulinux.hu>,
	Linux-Kernel-Mailinglist <linux-kernel@vger.kernel.org>,
	=?ISO-8859-1?Q?Tam=E1si_J=E1nos?= <janusz@uhulinux.hu>,
	netdev@vger.kernel.org
To: Sven-Haegar Koch <haegar@sdinet.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1111181346480.17023@aurora>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 18 novembre 2011 =C3=A0 13:48 +0100, Sven-Haegar Koch a =C3=
=A9crit :
> Added netdev list to CC:, there you should have a higher chance of a
> usefull answer.
>=20
> On Fri, 18 Nov 2011, Pozs=C3=A1r Bal=C3=A1zs wrote:
>=20
> > Hi all,
> >=20
> > I have been struggling with this not easily reproducible issue sinc=
e a while.
> > I am using linux kernel v3.1.0, and sometimes routing to a few IP a=
ddresses
> > does not work. What seems to happen is that instead of sending the =
packet to
> > the gateway, the kernel treats the destination address as local, an=
d tries to
> > gets its MAC address via ARP.
> >=20
> > For example, now my current IP address is 172.16.1.104/24, the gate=
way is
> > 172.16.1.254:
> >=20
> > |# ifconfig eth0 eth0      Link encap:Ethernet  HWaddr 00:1B:63:97:=
=46C:DC
> >           inet addr:172.16.1.104  Bcast:172.16.1.255  Mask:255.255.=
255.0
> >           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
> >           RX packets:230772 errors:0 dropped:0 overruns:0 frame:0
> >           TX packets:171013 errors:0 dropped:0 overruns:0 carrier:0
> >           collisions:0 txqueuelen:1000
> >           RX bytes:191879370 (182.9 Mb)  TX bytes:47173253 (44.9 Mb=
)
> >           Interrupt:17
> >=20
> > # route -n
> > Kernel IP routing table
> > Destination     Gateway         Genmask         Flags Metric Ref   =
 Use Iface
> > 0.0.0.0         172.16.1.254    0.0.0.0         UG    0      0     =
   0 eth0
> > 172.16.1.0      0.0.0.0         255.255.255.0   U     1      0     =
   0 eth0
> > |
> >=20
> > I can ping a few addresses, but not 172.16.0.59:
> >=20
> > |# ping -c1 172.16.1.254
> > PING 172.16.1.254 (172.16.1.254) 56(84) bytes of data.
> > 64 bytes from 172.16.1.254: icmp_seq=3D1 ttl=3D64 time=3D0.383 ms
> >=20
> > --- 172.16.1.254 ping statistics ---
> > 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> > rtt min/avg/max/mdev =3D 0.383/0.383/0.383/0.000 ms
> > root@pozsybook:~# ping -c1 172.16.0.1
> > PING 172.16.0.1 (172.16.0.1) 56(84) bytes of data.
> > 64 bytes from 172.16.0.1: icmp_seq=3D1 ttl=3D63 time=3D5.54 ms
> >=20
> > --- 172.16.0.1 ping statistics ---
> > 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> > rtt min/avg/max/mdev =3D 5.545/5.545/5.545/0.000 ms
> > root@pozsybook:~# ping -c1 172.16.0.2
> > PING 172.16.0.2 (172.16.0.2) 56(84) bytes of data.
> > 64 bytes from 172.16.0.2: icmp_seq=3D1 ttl=3D62 time=3D7.92 ms
> >=20
> > --- 172.16.0.2 ping statistics ---
> > 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> > rtt min/avg/max/mdev =3D 7.925/7.925/7.925/0.000 ms
> > root@pozsybook:~# ping -c1 172.16.0.59
> > PING 172.16.0.59 (172.16.0.59) 56(84) bytes of data.
> > From 172.16.1.104 icmp_seq=3D1 Destination Host Unreachable
> >=20
> > --- 172.16.0.59 ping statistics ---
> > 1 packets transmitted, 0 received, +1 errors, 100% packet loss, tim=
e 0ms
> > |
> >=20
> > When trying to ping 172.16.0.59, I can see in tcpdump that an ARP r=
eq was
> > sent:
> >=20
> > |# tcpdump -n -i eth0|grep ARP
> > tcpdump: verbose output suppressed, use -v or -vv for full protocol=
 decode
> > listening on eth0, link-type EN10MB (Ethernet), capture size 96 byt=
es
> > 15:25:16.671217 ARP, Request who-has 172.16.0.59 tell 172.16.1.104,=
 length 28
> > |
> >=20
> > and /proc/net/arp has an incomplete entry for 172.16.0.59:
> >=20
> > |# grep 172.16.0.59 /proc/net/arp
> >=20
> > 172.16.0.59      0x1         0x0         00:00:00:00:00:00     *   =
     eth0
> > |
> >=20
> > Please note, that 172.16.0.59 /is/ accessible from this LAN from ot=
her
> > computers.
> >=20
> >=20
> > Does anyone have any idea of what's going on? Thanks,
> >=20
> >=20
> > Balazs Pozsar
> >=20
> > ps: I think it is related to this one: https://lkml.org/lkml/2011/1=
1/16/292
> >=20
> > --

Could you send us result of :

ip route get 172.16.0.59
ip route list cache match 172.16.0.59
