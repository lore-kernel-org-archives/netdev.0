From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for single TCP session balancing
Date: Tue, 18 Jan 2011 17:45:45 -0800
Message-ID: <5613.1295401545@death>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death> <4D360408.1080104@gmail.com>
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
Received: from e4.ny.us.ibm.com ([32.97.182.144]:52085 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751Ab1ASBpu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 20:45:50 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0J1RkQt024156
	for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 20:27:46 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 944084DE8026
	for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 20:42:32 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0J1jmOI2600994
	for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 20:45:48 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0J1jlkS007749
	for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 20:45:48 -0500
In-reply-to: <4D360408.1080104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com> wrote:

>Le 18/01/2011 21:24, Jay Vosburgh a =C3=A9crit :
>> Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>  wrote:
>
>>>>> - it is possible to detect path failure using arp monitoring inst=
ead of
>>>>> miimon.
>>
>> 	I don't think this is true, at least not for the case of
>> balance-rr.  Using ARP monitoring with any sort of load balance sche=
me
>> is problematic, because the replies may be balanced to a different s=
lave
>> than the sender.
>
>Cannot we achieve the expected arp monitoring by using the exact same
>artifice that Oleg suggested: using a different source MAC per slave f=
or
>arp monitoring, so that return path match sending path ?

	It's not as simple with ARP, because it's a control protocol
that has side effects.

	First, the MAC level broadcast ARP probes from bonding would
have to be round robined in such a manner that they regularly arrive at
every possible slave.  A single broadcast won't be sent to more than on=
e
member of the channel group by the switch.  We can't do multiple unicas=
t
ARPs with different destination MAC addresses, because we'd have to
track all of those MACs somewhere (keep track of the MAC of every slave
on each peer we're monitoring).  I suspect that snooping switches will
get all whiny about port flapping and the like.

	We could have a separate IP address per slave, used only for
link monitoring, but that's a huge headache.  Actually, it's a lot like
the multi-link stuff I've been working on (and posted RFC of in
December), but that doesn't use ARP (it segregates slaves by IP subnet,
and balances at the IP layer).  Basically, you need a overlaying active
protocol to handle the map of which slave goes where (which multi-link
has).

	So, maybe we have the ARP replies massaged such that the
Ethernet header source and ARP target hardware address don't match.

	So the probes from bonding currently look like this:

MAC-A > ff:ff:ff:ff:ff:ff Request who-has 10.0.4.2 tell 10.0.1.1

	Where MAC-A is the bond's MAC address.  And the replies now look
like this:

MAC-B > MAC-A, Reply 10.0.4.2 is-at MAC-B

	Where MAC-B is the MAC of the peer's bond.  The massaged replies
would be of the form:

MAC-C > MAC-A, Reply 10.0.4.2 is-at MAC-B

	where MAC-C is the slave "permanent" address (which is really a
fake address to manipulate the switch's hash), and MAC-B is whatever th=
e
real MAC of the bond is.  I don't think we can mess with MAC-B in the
reply (the "is-at" part), because that would update ARP tables and such=
=2E
If we change MAC-A in the reply, they're liable to be filtered out.  I
really don't know if putting MAC-C in there as the source would confuse
snooping switches or not.

	One other thought I had while chewing on this is to run the LACP
protocol exchange between the bonding peers directly, instead of betwee=
n
each bond and each switch.  I have no idea if this would work or not,
but the theory would look something like the "VLAN tunnel" topology for
the switches, but the bonds at the ends are configured for 802.3ad.  To
make this work, bonding would have to be able to run mutiple LACP
instances (one for each bonding peer on the network) over a single
aggregator (or permit slaves to belong to multiple active aggregators).
This would basically be the same as the multi-link business, except
using LACP for the active protocol to build the map.

	A distinguished correspondent (who may confess if he so chooses)
also suggested 802.2 LLC XID or TEST frames, which have been discussed
in the past.  Those don't have side effects, but I'm not sure if either
is technically feasible, or if we really want bonding to have a
dependency on llc.  They would also only interop with hosts that respon=
d
to the XID or TEST.  I haven't thought about this in detail for a numbe=
r
of years, but I think the LLC DSAP / SSAP space is pretty small.

>>>>> - changing the destination MAC address of egress packets are not
>>>>> necessary, because egress path selection force ingress path selec=
tion
>>>>> due to the VLAN.
>>
>> 	This is true, with one comment: Oleg's proposal we're discussing
>> changes the source MAC address of outgoing packets, not the destinat=
ion.
>> The purpose being to manipulate the src-mac balancing algorithm on t=
he
>> switch when the packets are hashed at the egress port channel group.
>> The packets (for a particular destination) all bear the same destina=
tion
>> MAC, but (as I understand it) are manually assigned tailored source =
MAC
>> addresses that hash to sequential values.
>
>Yes, you're right.
>
>> 	That's true.  The big problem with the "VLAN tunnel" approach is
>> that it's not tolerant of link failures.
>
>Yes, except if we find a way to make arp monitoring reliable in load b=
alancing situation.
>
>[snip]
>
>> 	This is essentially the same thing as the diagram I pasted in up
>> above, except with VLANs and an additional layer of switches between=
 the
>> hosts.  The multiple VLANs take the place of multiple discrete switc=
hes.
>>
>> 	This could also be accomplished via bridge groups (in
>> Cisco-speak).  For example, instead of VLAN 100, that could be bridg=
e
>> group X, VLAN 200 is bridge group Y, and so on.
>>
>> 	Neither the VLAN nor the bridge group methods handle link
>> failures very well; if, in the above diagram, the link from "switch =
2
>> vlan 100" to "host B" fails, there's no way for host A to know to st=
op
>> sending to "switch 1 vlan 100," and there's no backup path for VLAN =
100
>> to "host B."
>
>Can't we imagine to "arp monitor" the destination MAC address of host =
B,
>on both paths ? That way, host A would know that a given path is down,
>because return path would be the same. The target host should send the
>reply on the slave on which it receive the request, which is the norma=
l
>way to reply to arp request.

	I think you can only get away with this if each slave set (where
a "set" is one slave from each bond that's attending our little load
balancing party) is on a separate switch domain, and the switch domains
are not bridged together.  Otherwise the switches will flap their MAC
tables as they update from each probe that they see.

	As for the reply going out the same slave, to do that, bonding
would have to intercept the ARP traffic (because ARPs arriving on slave=
s
are normally assigned to the bond itself, not the slave) and track and
tweak them.

	Lastly, bonding would again have to maintain a map, showing
which destinations are reachable via which set of slaves.  All peer
systems (needing to have per-slave link monitoring) would have to be AR=
P
targets.

>> 	One item I'd like to see some more data on is the level of
>> reordering at the receiver in Oleg's system.
>
>This is exactly the reason why I asked Oleg to do some test with
>balance-rr. I cannot find a good reason for a possibly new
>xmit_hash_policy to provide better throughput than current balance-rr.=
 If
>the throughput increase by, let's say, less than 20%, whatever
>tcp_reordering value, then it is probably a dead end way.

	Well, the point of making a round robin xmit_hash_policy isn't
that the throughput will be better than the existing round robin, it's
to make round-robin accessible to the 802.3ad mode.

>> 	One of the reasons round robin isn't as useful as it once was is
>> due to the rise of NAPI and interrupt coalescing, both of which will
>> tend to increase the reordering of packets at the receiver when the
>> packets are evenly striped.  In the old days, it was one interrupt, =
one
>> packet.  Now, it's one interrupt or NAPI poll, many packets.  With t=
he
>> packets striped across interfaces, this will tend to increase
>> reordering.  E.g.,
>>
>> 	slave 1		slave 2		slave 3
>> 	Packet 1	P2		P3
>> 	P4		P5		P6
>> 	P7		P8		P9
>>
>> 	and so on.  A poll of slave 1 will get packets 1, 4 and 7 (and
>> probably several more), then a poll of slave 2 will get 2, 5 and 8, =
etc.
>
>Any chance to receive P1, P2, P3 on slave 1, P4, P5, P6 on slave 2 et =
P7,
>P8, P9 on slave3, possibly by sending grouped packets, changing the
>sending slave every N packets instead of every packet ? I think we alr=
eady
>discussed this possibility a few months or years ago in bonding-devel
>ML. For as far as I remember, the idea was not developed because it wa=
s
>not easy to find the number of packets to send through the same
>slave. Anyway, this might help reduce out of order delivery.

	Yes, this came up several years ago, and, basically, there's no
way to do it perfectly.  An interesting experiment would be to see if
sending groups (perhaps close to the NAPI weight of the receiver) would
reduce reordering.

>> 	Barring evidence to the contrary, I presume that Oleg's system
>> delivers out of order at the receiver.  That's not automatically a
>> reason to reject it, but this entire proposal is sufficiently comple=
x to
>> configure that very explicit documentation will be necessary.
>
>Yes, and this is already true for some bonding modes and in particular=
 for balance-rr.

	I don't think any modes other than balance-rr will deliver out
of order normally.  It can happen during edge cases, e.g., alb
rebalance, or the layer3+4 hash with IP fragments, but I'd expect those
to be at a much lower rate than what round robin causes.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
