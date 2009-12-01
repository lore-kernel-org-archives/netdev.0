From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] bonding: allow arp_ip_targets to be on a
 separate vlan from bond device
Date: Tue, 01 Dec 2009 05:11:24 +0100
Message-ID: <4B14976C.6070701@gmail.com>
References: <20091130201453.GF1639@gospo.rdu.redhat.com> <29892.1259625638@death.nxdomain.ibm.com> <20091201012145.GH1639@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42821 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283AbZLAELY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 23:11:24 -0500
In-Reply-To: <20091201012145.GH1639@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek a =E9crit :
> On Mon, Nov 30, 2009 at 04:00:38PM -0800, Jay Vosburgh wrote:
>> Andy Gospodarek <andy@greyhouse.net> wrote:
>>
>>> This allows a bond device to specify an arp_ip_target as a host tha=
t is
>>> not on the same vlan as the base bond device.  A configuration like
>>> this, now works:
>>>
>>> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
>>>    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>>>    inet 127.0.0.1/8 scope host lo
>>>    inet6 ::1/128 scope host
>>>       valid_lft forever preferred_lft forever
>>> 2: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfi=
fo_fast master bond0 qlen 1000
>>>    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
>>> 3: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfi=
fo_fast master bond0 qlen 1000
>>>    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
>>> 8: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc n=
oqueue
>>>    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
>>>    inet6 fe80::213:21ff:febe:33e9/64 scope link
>>>       valid_lft forever preferred_lft forever
>>> 9: bond0.100@bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 15=
00 qdisc noqueue
>>>    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
>>>    inet 10.0.100.2/24 brd 10.0.100.255 scope global bond0.100
>>>    inet6 fe80::213:21ff:febe:33e9/64 scope link
>>>       valid_lft forever preferred_lft forever
>> 	I'm not quite clear here on exactly what it is that doesn't
>> work.
>>
>> 	Putting the arp_ip_target on a VLAN destination already works
>> (and has for a long time); I just checked against a 2.6.32-rc to mak=
e
>> sure I wasn't misremembering.
>>
>> 	Perhaps there's some nuance of "not on the same vlan as the base
>> bond device" that I'm missing.  What I see working before me is, e.g=
=2E, a
>> bond0.777 VLAN interface atop a regular bond0 active-backup with a
>> couple of slaves; bond0 may or may not have an IP address of its own=
=2E
>> The arp_ip_target destination is on VLAN 777 somewhere.
>=20
> Do you have net.ipv4.conf.all.arp_ignore set to 0 and/or an IP addres=
s
> assigned on bond0?  I can easily reproduce this with no IP on bond0 a=
nd
> net.ipv4.conf.all.arp_ignore =3D 1.
>=20
> I can't say for sure that the sysctl setting makes a difference, but =
I
> have that on all my test rigs, so it's worth mentioning.
>=20
>> 	Is this what your patch is meant to enable, or is it something
>> different?  I'm pulling down today's net-next to see if this is
>> something that broke recently.
>>
>=20
> I first tested and found the problem while running 2.6.30-rc series
> after it was reported to be a problem on RHEL5.  It's not clear how l=
ong
> it has been broken, but this situation is odd enough that it probably
> never worked as it was never tested.
>=20

Strange, I cannot reproduce the problem here, with bnx2/tg3 adapters,
and net-next-2.6. What is your NIC driver ?

# ifconfig bond0
bond0     Link encap:Ethernet  HWaddr 00:1E:0B:EC:D3:D2
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:61787693 errors:0 dropped:0 overruns:0 frame:0
          TX packets:61894413 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:750916661 (716.1 Mb)  TX bytes:991607878 (945.6 Mb)

# ifconfig vlan.103
vlan.103  Link encap:Ethernet  HWaddr 00:1E:0B:EC:D3:D2
          inet addr:192.168.20.110  Bcast:0.0.0.0  Mask:255.255.255.0
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:236770 errors:0 dropped:0 overruns:0 frame:0
          TX packets:182838 errors:0 dropped:6 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:13697089 (13.0 Mb)  TX bytes:206093300 (196.5 Mb)

# ifconfig vlan.825
vlan.825  Link encap:Ethernet  HWaddr 00:1E:0B:EC:D3:D2
          inet addr:10.170.73.123  Bcast:0.0.0.0  Mask:255.255.255.128
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:61549795 errors:0 dropped:0 overruns:0 frame:0
          TX packets:61584427 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:3672807415 (3502.6 Mb)  TX bytes:283329099 (270.2 Mb=
)

# ifconfig eth1   (bnx2)
eth1      Link encap:Ethernet  HWaddr 00:1E:0B:EC:D3:D2
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:1596 errors:0 dropped:0 overruns:0 frame:0
          TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:110466 (107.8 Kb)  TX bytes:512 (512.0 b)
          Interrupt:16 Memory:fa000000-fa012800

# ifconfig eth2    (tg3)
eth2      Link encap:Ethernet  HWaddr 00:1E:0B:EC:D3:D2
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:61786578 errors:0 dropped:0 overruns:0 frame:0
          TX packets:61894510 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:750842426 (716.0 Mb)  TX bytes:991618552 (945.6 Mb)
          Interrupt:19

# cat /proc/sys/net/ipv4/conf/all/arp_ignore
1
# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth2
MII Status: up
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0
ARP Polling Interval (ms): 1000
ARP IP target/s (n.n.n.n form): 192.168.20.254

Slave Interface: eth1
MII Status: up
Link Failure Count: 9
Permanent HW addr: 00:1e:0b:ec:d3:d2

Slave Interface: eth2
MII Status: up
Link Failure Count: 6
Permanent HW addr: 00:1e:0b:92:78:50
