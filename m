From: Michael Leun <lkml20101129@newton.leun.net>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not
 used
Date: Sun, 5 Dec 2010 03:07:12 +0100
Message-ID: <20101205030712.36149bc2@xenia.leun.net>
References: <20101129201716.1d0257c4@xenia.leun.net>
	<4CF442FA.4070701@candelatech.com>
	<20101130095944.41b5f7b6@xenia.leun.net>
	<1291108809.2904.3.camel@edumazet-laptop>
	<20101201111716.424fb771@xenia.leun.net>
	<1291200914.2856.546.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>, stable@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291200914.2856.546.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 01 Dec 2010 11:55:14 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 01 d=E9cembre 2010 =E0 11:17 +0100, Michael Leun a =E9cri=
t :
>=20
> > Yup, from what I've tested this works (and tcpdump sees broadcast
> > packets even for vlans not configured at the moment including vlan
> > tag
> > - yipee!).
> >

This was tested on machine with
root@tp_z61m:~/src/tcpdump-4.1.1# lspci|grep Eth
02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5752M Gi=
gabit Ethernet PCI Express (rev 02)

There it works as I said.

But on

hpdl320g5:/home/ml # lspci | grep Eth
03:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5714 Gig=
abit Ethernet (rev a3)
03:04.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5714 Gig=
abit Ethernet (rev a3)

the good message is that it also does not crash, but with tcpdump I see
vlan tags when no vlan devices configured on the respective eth, if so
I do not see tags anymore vlan tags on the trunk interface.

hpdl320g5:/home/ml # ifconfig -a
[...]
eth1      Link encap:Ethernet  Hardware Adresse xx:xx:xx:xx:xx:xx =20
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 Sendewarteschlangenl=E4nge:1000=20
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Interrupt:17=20
[...]

hpdl320g5:/home/ml # tcpdump -i eth1 -n -e
tcpdump: WARNING: eth1: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
[...]
02:45:57.597640 xx:xx:xx:xx:xx:xx > ff:ff:ff:ff:ff:ff, ethertype 802.1Q=
 (0x8100), length 64: vlan 1505, p 0, ethertype 802.1Q, vlan 99, p 3, e=
thertype ARP, arp who-has 10.0.0.1 tell 10.0.0.2
02:45:57.622654 xx:xx:xx:xx:xx:xx > ff:ff:ff:ff:ff:ff, ethertype 802.1Q=
 (0x8100), length 64: vlan 1505, p 0, ethertype 802.1Q, vlan 99, p 3, e=
thertype ARP, arp who-has 10.0.0.1 tell 10.0.0.2
[...]

hpdl320g5:/home/ml # vconfig add eth1 2
WARNING:  Could not open /proc/net/vlan/config.  Maybe you need to load=
 the 8021q module, or maybe you are not using PROCFS??
Added VLAN with VID =3D=3D 2 to IF -:eth1:-
hpdl320g5:/home/ml # cat /proc/net/vlan/config=20
VLAN Dev name    | VLAN ID
Name-Type: VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD
eth1.2         | 2  | eth1
hpdl320g5:/home/ml # tcpdump -i eth1 -n -e
tcpdump: WARNING: eth1: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
[...]
02:50:18.095959 xx:xx:xx:xx:xx:xx > ff:ff:ff:ff:ff:ff, ethertype 802.1Q=
 (0x8100), length 60: vlan 99, p 3, ethertype ARP, arp who-has 10.0.0.1=
 tell 10.0.0.2
02:50:18.120989 xx:xx:xx:xx:xx:xx > ff:ff:ff:ff:ff:ff, ethertype 802.1Q=
 (0x8100), length 60: vlan 99, p 3, ethertype ARP, arp who-has 10.0.0.1=
 tell 10.0.0.2
[...]

The same packages we saw double vlan tagged a few minutes ago now appea=
r single vlan tagged (and of course, other packets that were shown sing=
le vlan tagged before are now shown without vlan tag / eth type 0x0800)=
=2E


On the other machine:

root@tp_z61m:~# cat /proc/net/vlan/config=20
VLAN Dev name    | VLAN ID
Name-Type: VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD
eth0.741       | 741  | eth0
eth0.2         | 2  | eth0
root@tp_z61m:~/src/tcpdump-4.1.1# ./tcpdump -i eth0 -n -e not port 22
tcpdump: WARNING: eth0: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol dec=
ode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 byte=
s
03:06:51.859016 xx:xx:xx:xx:xx:xx > ff:ff:ff:ff:ff:ff, ethertype 802.1Q=
 (0x8100), length 64: vlan 1505, p 0, ethertype 802.1Q, vlan 99, p 3, e=
thertype ARP, Request who-has 10.0.0.1 tell 10.0.0.2, length 42
03:06:51.883956 xx:xx:xx:xx:xx:xx > ff:ff:ff:ff:ff:ff, ethertype 802.1Q=
 (0x8100), length 64: vlan 1505, p 0, ethertype 802.1Q, vlan 99, p 3, e=
thertype ARP, Request who-has 10.0.0.1 tell 10.0.0.2, length 42



[...]
> Here is the revised patch again then for stable team, via David Mille=
r
> agreement.
[...]

--=20
MfG,

Michael Leun
