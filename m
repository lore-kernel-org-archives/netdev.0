From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG net-next-2.6] Had to revert bonding: allow arp_ip_targets on
 separate vlans to use arp validation
Date: Wed, 06 Jan 2010 22:10:03 +0100
Message-ID: <4B44FC2B.4090505@gmail.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com>	 <20091120154046.67252d23@nehalam>	 <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com> <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com> <4B44258C.2050302@gmail.com> <4B44D89B.8070006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60604 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932827Ab0AFVKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 16:10:15 -0500
In-Reply-To: <4B44D89B.8070006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/01/2010 19:38, Eric Dumazet a =E9crit :
>=20
> (net-next-2.6 doesnt work well on my bond/vlan setup, I suspect I nee=
d a bisection)

David, I had to revert 1f3c8804acba841b5573b953f5560d2683d2db0d
(bonding: allow arp_ip_targets on separate vlans to use arp validation)

Or else, my vlan devices dont work (unfortunatly I dont have much time
these days to debug the thing)

My config :

              +---------+
vlan.103 -----+ bond0   +--- eth1 (bnx2)
              |         +
vlan.825 -----+         +--- eth2 (tg3)
              +---------+

$ cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth2
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

Slave Interface: eth1  (bnx2)
MII Status: down
Link Failure Count: 1
Permanent HW addr: 00:1e:0b:ec:d3:d2

Slave Interface: eth2   (tg3)
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:1e:0b:92:78:50




author	Andy Gospodarek <andy@greyhouse.net>=09
	Mon, 14 Dec 2009 10:48:58 +0000 (10:48 +0000)
committer	David S. Miller <davem@davemloft.net>=09
	Mon, 4 Jan 2010 05:17:16 +0000 (21:17 -0800)
commit	1f3c8804acba841b5573b953f5560d2683d2db0d
tree	453fae141b4a37e72ee0513ea1816fbff8f1cf8a=09
parent	3a999e6eb5d277cd6a321dcda3fc43c3d9e4e4b8=09
bonding: allow arp_ip_targets on separate vlans to use arp validation

This allows a bond device to specify an arp_ip_target as a host that is
not on the same vlan as the base bond device and still use arp
validation.  A configuration like this, now works:

BONDING_OPTS=3D"mode=3Dactive-backup arp_interval=3D1000 arp_ip_target=3D=
10.0.100.1 arp_validate=3D3"

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_f=
ast master bond0 qlen 1000
    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
3: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_f=
ast master bond0 qlen 1000
    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
8: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noque=
ue
    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::213:21ff:febe:33e9/64 scope link
       valid_lft forever preferred_lft forever
9: bond0.100@bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 q=
disc noqueue
    link/ether 00:13:21:be:33:e9 brd ff:ff:ff:ff:ff:ff
    inet 10.0.100.2/24 brd 10.0.100.255 scope global bond0.100
    inet6 fe80::213:21ff:febe:33e9/64 scope link
       valid_lft forever preferred_lft forever

Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth1
MII Status: up
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0
ARP Polling Interval (ms): 1000
ARP IP target/s (n.n.n.n form): 10.0.100.1

Slave Interface: eth1
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:40:05:30:ff:30

Slave Interface: eth0
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:13:21:be:33:e9

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
