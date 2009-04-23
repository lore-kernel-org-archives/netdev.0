From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bond interface arp, vlan and trunk / network question
Date: Thu, 23 Apr 2009 08:38:31 -0700
Message-ID: <16084.1240501111@death.nxdomain.ibm.com>
References: <1ef444010904201050g72651387se3feca3fbd68ce30@mail.gmail.com> <49ECBBF0.80202@cosmosbay.com> <30257.1240252651@death.nxdomain.ibm.com> <1ef444010904201300r43268672sb74277f4a0242236@mail.gmail.com> <7609.1240259780@death.nxdomain.ibm.com> <1ef444010904201403s5d583750i1ce3a5da6c6f4059@mail.gmail.com> <13606.1240262581@death.nxdomain.ibm.com> <1ef444010904201439i60f9e918j760d94eeca428ece@mail.gmail.com> <22462.1240272112@death.nxdomain.ibm.com> <1ef444010904220129l24a74f07q8f32edfabe603436@mail.gmail.com> <32563.1240449149@death.nxdomain.ibm.com> <49F0039D.3040707@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stefan novak <lms.brubaker@gmail.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:51952 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495AbZDWPi3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 11:38:29 -0400
In-reply-to: <49F0039D.3040707@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <dada1@cosmosbay.com> wrote:

>Jay Vosburgh a =C3=A9crit :
>> stefan novak <lms.brubaker@gmail.com> wrote:
>>=20
>>> so its a bug in kernel?
>>=20
>> 	Yes.  I think the following patch should add support for
>> arp_validate over VLANs, could you test this?  This is still a work =
in
>> progress, so it's pretty rough around the edges, but the core
>> functionality should be there.
>>=20
>> 	This works by moving the skb_bond_should_drop logic around, and
>> replaces the current inline code with a hook into bonding to do all =
of
>> that, plus additional logic.  The reason for a hook is to get the
>> skb_bond_should_drop callers from the VLAN input path before the inp=
ut
>> device is assigned to the VLAN device.
>>=20
>> 	-J
>
>Hi Jay
>
>I wanted to test your patch and setup such VLAN config, and not yet ap=
plied your patch.
>
># cat /proc/net/bonding/bond1
>Ethernet Channel Bonding Driver: v3.5.0 (November 4, 2008)
>
>Bonding Mode: fault-tolerance (active-backup)
>Primary Slave: None
>Currently Active Slave: eth2
>MII Status: up
>MII Polling Interval (ms): 0
>Up Delay (ms): 0
>Down Delay (ms): 0
>ARP Polling Interval (ms): 250
>ARP IP target/s (n.n.n.n form): 192.168.20.254
>
>Slave Interface: eth1
>MII Status: up
>Link Failure Count: 8
>Permanent HW addr: 00:1e:0b:ec:d3:d2
>
>Slave Interface: eth2
>MII Status: up
>Link Failure Count: 11
>Permanent HW addr: 00:1e:0b:92:78:50
>
># grep . /sys/class/net/bond1/bonding/*
>/sys/class/net/bond1/bonding/active_slave:eth2
>/sys/class/net/bond1/bonding/ad_select:stable 0
>/sys/class/net/bond1/bonding/arp_interval:250
>/sys/class/net/bond1/bonding/arp_ip_target:192.168.20.254
>/sys/class/net/bond1/bonding/arp_validate:none 0

	To test this patch, you'll need to set arp_validate to all.
Well, insuring that nothing breaks without arp_validate is good, too,
but the patch is supposed to make arp_validate function with an
arp_ip_target accessed via a VLAN.

>/sys/class/net/bond1/bonding/downdelay:0
>/sys/class/net/bond1/bonding/fail_over_mac:none 0
>/sys/class/net/bond1/bonding/lacp_rate:slow 0
>/sys/class/net/bond1/bonding/miimon:0
>/sys/class/net/bond1/bonding/mii_status:up
>/sys/class/net/bond1/bonding/mode:active-backup 1
>/sys/class/net/bond1/bonding/num_grat_arp:1
>/sys/class/net/bond1/bonding/num_unsol_na:1
>/sys/class/net/bond1/bonding/slaves:eth1 eth2
>/sys/class/net/bond1/bonding/updelay:0
>/sys/class/net/bond1/bonding/use_carrier:1
>/sys/class/net/bond1/bonding/xmit_hash_policy:layer2 0
>
>
>
>So active slave is eth2. Still I receive trafic on eth1, according to =
ifconfig :
># ifconfig eth1|grep packets;sleep 10;ifconfig eth1|grep packets
>          RX packets:2098122 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:2053085 errors:0 dropped:0 overruns:0 carrier:0
>          RX packets:2098162 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:2053085 errors:0 dropped:0 overruns:0 carrier:0
>
>exactly 4 packets per second.

	This is expected, these are the broadcast ARP_REQUEST packets
the bond issues as probes, every 250 ms as specified by your
arp_interval.  Any broadcasts on the switch or other traffic flooded to
all ports will come into the slave device, and (for the active-backup
inactive slave case) all of it is thrown away.  There's some trickery i=
n
netif_receive_skb for sockets that bind directly to the slave, but that
doesn't seem to affect tcpdump.

># ifconfig eth2|grep packets;sleep 10;ifconfig eth2|grep packets
>          RX packets:3695512 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:3683799 errors:0 dropped:0 overruns:0 carrier:0
>          RX packets:3695554 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:3683841 errors:0 dropped:0 overruns:0 carrier:0
>
>I also receive arp answers on eth2 (quite normal)
>
>I wanted to tcpdump on eth1 but got nothing :
>
># tcpdump -p -n -s 0 -i eth1
>tcpdump: WARNING: eth1: no IPv4 address assigned
>tcpdump: verbose output suppressed, use -v or -vv for full protocol de=
code
>listening on eth1, link-type EN10MB (Ethernet), capture size 65535 byt=
es

	This is normal, as incoming traffic is assigned to the master
before the packet capture gets a look.

># tcpdump -p -n -s 0 -i eth2
>tcpdump: WARNING: eth2: no IPv4 address assigned
>tcpdump: verbose output suppressed, use -v or -vv for full protocol de=
code
>listening on eth2, link-type EN10MB (Ethernet), capture size 65535 byt=
es
>07:54:48.430982 arp who-has 192.168.20.254 tell 192.168.20.110
>07:54:48.680980 arp who-has 192.168.20.254 tell 192.168.20.110
>07:54:48.930981 arp who-has 192.168.20.254 tell 192.168.20.110
>07:54:49.180980 arp who-has 192.168.20.254 tell 192.168.20.110
>07:54:49.430980 arp who-has 192.168.20.254 tell 192.168.20.110
>07:54:49.680980 arp who-has 192.168.20.254 tell 192.168.20.110

	This is also normal (seeing only outbound traffic) for the same
reason as above.

># tcpdump -p -n -s 0 -i bond1
>tcpdump: WARNING: bond1: no IPv4 address assigned
>tcpdump: verbose output suppressed, use -v or -vv for full protocol de=
code
>listening on bond1, link-type EN10MB (Ethernet), capture size 65535 by=
tes
>07:55:28.681491 arp reply 192.168.20.254 is-at 00:00:0c:07:ac:01
>07:55:28.931493 arp reply 192.168.20.254 is-at 00:00:0c:07:ac:01
>07:55:29.181466 arp reply 192.168.20.254 is-at 00:00:0c:07:ac:01
>07:55:29.431496 arp reply 192.168.20.254 is-at 00:00:0c:07:ac:01
>07:55:29.681487 arp reply 192.168.20.254 is-at 00:00:0c:07:ac:01
>07:55:29.931492 arp reply 192.168.20.254 is-at 00:00:0c:07:ac:01
>
># tcpdump -p -n -s 0 -i bond1.103
>tcpdump: verbose output suppressed, use -v or -vv for full protocol de=
code
>listening on bond1.103, link-type EN10MB (Ethernet), capture size 6553=
5 bytes
>07:55:58.681521 arp reply 192.168.20.254 is-at 00:00:0c:07:ac:01
>07:55:58.931636 arp reply 192.168.20.254 is-at 00:00:0c:07:ac:01
>07:55:59.181495 arp reply 192.168.20.254 is-at 00:00:0c:07:ac:01
>07:55:59.431496 arp reply 192.168.20.254 is-at 00:00:0c:07:ac:01
>07:55:59.681499 arp reply 192.168.20.254 is-at 00:00:0c:07:ac:01
>07:55:59.931499 arp reply 192.168.20.254 is-at 00:00:0c:07:ac:01
>
>Configuration script is=20
>
>ip link set eth1 up
>ip link set eth2 up
>
>ip addr flush dev eth1
>ip addr flush dev eth2
>
>ip link set eth1 up
>ip link set eth2 up
>
>modprobe bond1
>
>ifconfig bond1 down
>
># test du arp_check toutes les 250ms, en choissant l'HSRP du vlan 103 =
comme IP
>echo +192.168.20.254 >/sys/class/net/bond1/bonding/arp_ip_target
>echo 250 >/sys/class/net/bond1/bonding/arp_interval
>
># mode actif/passif (active-backup)
>echo 1 >/sys/class/net/bond1/bonding/mode
>
>ifconfig bond1 up
>
>ifenslave bond1 eth1 eth2
>
>ip link set eth1 up
>ip link set eth2 up
>
>ip link add link bond1 bond1.103 txqueuelen 100 type vlan id 103
>ip addr add 192.168.20.110/24 dev bond1.103
>ip link set bond1.103 up
>
>ip link add link bond1 bond1.825 txqueuelen 1000 type vlan id 825
>ip addr add 10.170.73.123/25 dev bond1.825
>ip link set bond1.825 up
>
>
>
>Is this setup OK to test your patch ?

	I believe so, provided you enable arp_validate as mentioned
above.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

