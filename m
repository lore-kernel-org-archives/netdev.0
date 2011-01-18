From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for single TCP session balancing
Date: Tue, 18 Jan 2011 12:24:28 -0800
Message-ID: <28837.1295382268@death>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Oleg V. Ukhno" <olegu@yandex-team.ru>,
	John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?us-ascii?Q?=3D=3FUTF-8=3FB=3FU8OpYmFzdGllbiBCYXJyw6k=3D=3F=3D?=
	<sebastien.barre@uclouvain.be>,
	Christophe Paasch <christoph.paasch@uclouvain.be>
To: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTmljb2xhcyBkZSBQZXNsb8O8YW4=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:33171 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911Ab1ARUYj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 15:24:39 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0IKJfsA015102
	for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 13:19:41 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0IKOVnw155754
	for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 13:24:34 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0IKT0PI014346
	for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 13:29:00 -0700
In-reply-to: <4D35BED5.7040301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com> wrote:

>Le 18/01/2011 16:28, Oleg V. Ukhno a =C3=A9crit :
>> On 01/18/2011 05:54 PM, Nicolas de Peslo=C3=BCan wrote:
>>> I remember a topology (described by Jay, for as far as I remember),
>>> where two hosts were connected through two distinct VLANs. In such
>>> topology:
>>> - it is possible to detect path failure using arp monitoring instea=
d of
>>> miimon.

	I don't think this is true, at least not for the case of
balance-rr.  Using ARP monitoring with any sort of load balance scheme
is problematic, because the replies may be balanced to a different slav=
e
than the sender.

>>> - changing the destination MAC address of egress packets are not
>>> necessary, because egress path selection force ingress path selecti=
on
>>> due to the VLAN.

	This is true, with one comment: Oleg's proposal we're discussing
changes the source MAC address of outgoing packets, not the destination=
=2E
The purpose being to manipulate the src-mac balancing algorithm on the
switch when the packets are hashed at the egress port channel group.
The packets (for a particular destination) all bear the same destinatio=
n
MAC, but (as I understand it) are manually assigned tailored source MAC
addresses that hash to sequential values.

>> In case with two VLANs - yes, this shouldn't be necessary(but needs =
to
>> be tested, I am not sure), but within one - it is essential for corr=
ect
>> rx load striping.
>
>Changing the destination MAC address is definitely not required if you
>segregate each path in a distinct VLAN.
>
>            +-------------------+     +-------------------+
>    +-------|switch 1 - vlan 100|-----|switch 2 - vlan 100|-------+
>    |       +-------------------+     +-------------------+       |
>+------+              |                         |              +------=
+
>|host A|              |                         |              |host B=
|
>+------+              |                         |              +------=
+
>    |       +-------------------+     +-------------------+       |
>    +-------|switch 3 - vlan 200|-----|switch 4 - vlan 200|-------+
>            +-------------------+     +-------------------+
>
>Even in the present of ISL between some switches, packet sent through =
host
>A interface connected to vlan 100 will only enter host B using the
>interface connected to vlan 100. So every slaves of the bonding interf=
ace
>can use the same MAC address.

	That's true.  The big problem with the "VLAN tunnel" approach is
that it's not tolerant of link failures.

>Of course, changing the destination address would be required in order=
 to
>achieve ingress load balancing on a *single* LAN. But, as Jay noted at=
 the
>beginning of this thread, this would violate 802.3ad.
>
>>> I think the only point is whether we need a new xmit_hash_policy fo=
r
>>> mode=3D802.3ad or whether mode=3Dbalance-rr could be enough.
>> May by, but it seems to me fair enough not to restrict this feature =
only
>> to non-LACP aggregate links; dynamic aggregation may be useful(it he=
lps
>> to avoid switch misconfiguration(misconfigured slaves on switch side=
)
>> sometimes without loss of service).
>
>You are right, but such LAN setup need to be carefully designed and
>built. I'm not sure that an automatic channel aggregation system is th=
e
>right way to do it. Hence the reason why I suggest to use balance-rr w=
ith
>VLANs.

	The "VLAN tunnel" approach is a derivative of an actual switch
topology that balance-rr was originally intended for, many moons ago.
This is described in the current bonding.txt; I'll cut & paste a bit
here:

12.2 Maximum Throughput in a Multiple Switch Topology
-----------------------------------------------------

        Multiple switches may be utilized to optimize for throughput
when they are configured in parallel as part of an isolated network
between two or more systems, for example:

                       +-----------+
                       |  Host A   |=20
                       +-+---+---+-+
                         |   |   |
                +--------+   |   +---------+
                |            |             |
         +------+---+  +-----+----+  +-----+----+
         | Switch A |  | Switch B |  | Switch C |
         +------+---+  +-----+----+  +-----+----+
                |            |             |
                +--------+   |   +---------+
                         |   |   |
                       +-+---+---+-+
                       |  Host B   |=20
                       +-----------+

        In this configuration, the switches are isolated from one
another.  One reason to employ a topology such as this is for an
isolated network with many hosts (a cluster configured for high
performance, for example), using multiple smaller switches can be more
cost effective than a single larger switch, e.g., on a network with 24
hosts, three 24 port switches can be significantly less expensive than
a single 72 port switch.

        If access beyond the network is required, an individual host
can be equipped with an additional network device connected to an
external network; this host then additionally acts as a gateway.

	[end of cut]

	This was described to me some time ago as an early usage model
for balance-rr using multiple 10 Mb/sec switches.  It has the same link
monitoring problems as the "VLAN tunnel" approach, although modern
switches with "trunk failover" type of functionality may be able to
mitigate the problem.

>>> Oleg, would you mind trying the above "two VLAN" topology" with
>>> mode=3Dbalance-rr and report any results ? For high-availability pu=
rpose,
>>> it's obviously necessary to setup those VLAN on distinct switches.
>> I'll do it, but it will take some time to setup test environment,
>> several days may be.
>
>Thanks. For testing purpose, it is enough to setup those VLAN on a sin=
gle
>switch if it is easier for you to do.
>
>> You mean following topology:
>
>See above.
>
>> (i'm sure it will work as desired if each host is connected to each
>> switch with only one slave link, if there are more slaves in each sw=
itch
>> - unsure)?
>
>If you want to use more than 2 slaves per host, then you need more tha=
n 2
>VLAN. You also need to have the exact same number of slaves on all hos=
ts,
>as egress path selection cause ingress path selection at the other sid=
e.
>
>            +-------------------+     +-------------------+
>    +-------|switch 1 - vlan 100|-----|switch 2 - vlan 100|-------+
>    |       +-------------------+     +-------------------+       |
>+------+              |                         |              +------=
+
>|host A|              |                         |              |host B=
|
>+------+              |                         |              +------=
+
>  | |       +-------------------+     +-------------------+       | |
>  | +-------|switch 3 - vlan 200|-----|switch 4 - vlan 200|-------+ |
>  |         +-------------------+     +-------------------+         |
>  |                   |                         |                   |
>  |                   |                         |                   |
>  |         +-------------------+     +-------------------+         |
>  +---------|switch 5 - vlan 300|-----|switch 6 - vlan 300|---------+
>            +-------------------+     +-------------------+
>
>Of course, you can add others host to vlan 100, 200 and 300, with the
>exact same configuration at host A or host B.

	This is essentially the same thing as the diagram I pasted in up
above, except with VLANs and an additional layer of switches between th=
e
hosts.  The multiple VLANs take the place of multiple discrete switches=
=2E

	This could also be accomplished via bridge groups (in
Cisco-speak).  For example, instead of VLAN 100, that could be bridge
group X, VLAN 200 is bridge group Y, and so on.

	Neither the VLAN nor the bridge group methods handle link
failures very well; if, in the above diagram, the link from "switch 2
vlan 100" to "host B" fails, there's no way for host A to know to stop
sending to "switch 1 vlan 100," and there's no backup path for VLAN 100
to "host B."

	One item I'd like to see some more data on is the level of
reordering at the receiver in Oleg's system.

	One of the reasons round robin isn't as useful as it once was is
due to the rise of NAPI and interrupt coalescing, both of which will
tend to increase the reordering of packets at the receiver when the
packets are evenly striped.  In the old days, it was one interrupt, one
packet.  Now, it's one interrupt or NAPI poll, many packets.  With the
packets striped across interfaces, this will tend to increase
reordering.  E.g.,

	slave 1		slave 2		slave 3
	Packet 1	P2		P3
	P4		P5		P6
	P7		P8		P9

	and so on.  A poll of slave 1 will get packets 1, 4 and 7 (and
probably several more), then a poll of slave 2 will get 2, 5 and 8, etc=
=2E

	I haven't done much testing with this lately, but I suspect this
behavior hasn't really changed.  Raising the tcp_reordering sysctl valu=
e
can mitigate this somewhat (by making TCP more tolerant of this), but
that doesn't help non-TCP protocols.

	Barring evidence to the contrary, I presume that Oleg's system
delivers out of order at the receiver.  That's not automatically a
reason to reject it, but this entire proposal is sufficiently complex t=
o
configure that very explicit documentation will be necessary.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
