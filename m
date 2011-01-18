From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Tue, 18 Jan 2011 22:20:08 +0100
Message-ID: <4D360408.1080104@gmail.com>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com> <28837.1295382268@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Oleg V. Ukhno" <olegu@yandex-team.ru>,
	John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>,
	Christophe Paasch <christoph.paasch@uclouvain.be>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:35000 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961Ab1ARVUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 16:20:11 -0500
Received: by wwi17 with SMTP id 17so3708531wwi.1
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 13:20:10 -0800 (PST)
In-Reply-To: <28837.1295382268@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/01/2011 21:24, Jay Vosburgh a =C3=A9crit :
> Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>  wrote:

>>>> - it is possible to detect path failure using arp monitoring inste=
ad of
>>>> miimon.
>
> 	I don't think this is true, at least not for the case of
> balance-rr.  Using ARP monitoring with any sort of load balance schem=
e
> is problematic, because the replies may be balanced to a different sl=
ave
> than the sender.

Cannot we achieve the expected arp monitoring by using the exact same a=
rtifice that Oleg suggested:=20
using a different source MAC per slave for arp monitoring, so that retu=
rn path match sending path ?

>>>> - changing the destination MAC address of egress packets are not
>>>> necessary, because egress path selection force ingress path select=
ion
>>>> due to the VLAN.
>
> 	This is true, with one comment: Oleg's proposal we're discussing
> changes the source MAC address of outgoing packets, not the destinati=
on.
> The purpose being to manipulate the src-mac balancing algorithm on th=
e
> switch when the packets are hashed at the egress port channel group.
> The packets (for a particular destination) all bear the same destinat=
ion
> MAC, but (as I understand it) are manually assigned tailored source M=
AC
> addresses that hash to sequential values.

Yes, you're right.

> 	That's true.  The big problem with the "VLAN tunnel" approach is
> that it's not tolerant of link failures.

Yes, except if we find a way to make arp monitoring reliable in load ba=
lancing situation.

[snip]

> 	This is essentially the same thing as the diagram I pasted in up
> above, except with VLANs and an additional layer of switches between =
the
> hosts.  The multiple VLANs take the place of multiple discrete switch=
es.
>
> 	This could also be accomplished via bridge groups (in
> Cisco-speak).  For example, instead of VLAN 100, that could be bridge
> group X, VLAN 200 is bridge group Y, and so on.
>
> 	Neither the VLAN nor the bridge group methods handle link
> failures very well; if, in the above diagram, the link from "switch 2
> vlan 100" to "host B" fails, there's no way for host A to know to sto=
p
> sending to "switch 1 vlan 100," and there's no backup path for VLAN 1=
00
> to "host B."

Can't we imagine to "arp monitor" the destination MAC address of host B=
, on both paths ? That way,=20
host A would know that a given path is down, because return path would =
be the same. The target host=20
should send the reply on the slave on which it receive the request, whi=
ch is the normal way to reply=20
to arp request.

> 	One item I'd like to see some more data on is the level of
> reordering at the receiver in Oleg's system.

This is exactly the reason why I asked Oleg to do some test with balanc=
e-rr. I cannot find a good=20
reason for a possibly new xmit_hash_policy to provide better throughput=
 than current balance-rr. If=20
the throughput increase by, let's say, less than 20%, whatever tcp_reor=
dering value, then it is=20
probably a dead end way.

> 	One of the reasons round robin isn't as useful as it once was is
> due to the rise of NAPI and interrupt coalescing, both of which will
> tend to increase the reordering of packets at the receiver when the
> packets are evenly striped.  In the old days, it was one interrupt, o=
ne
> packet.  Now, it's one interrupt or NAPI poll, many packets.  With th=
e
> packets striped across interfaces, this will tend to increase
> reordering.  E.g.,
>
> 	slave 1		slave 2		slave 3
> 	Packet 1	P2		P3
> 	P4		P5		P6
> 	P7		P8		P9
>
> 	and so on.  A poll of slave 1 will get packets 1, 4 and 7 (and
> probably several more), then a poll of slave 2 will get 2, 5 and 8, e=
tc.

Any chance to receive P1, P2, P3 on slave 1, P4, P5, P6 on slave 2 et P=
7, P8, P9 on slave3, possibly=20
by sending grouped packets, changing the sending slave every N packets =
instead of every packet ? I=20
think we already discussed this possibility a few months or years ago i=
n bonding-devel ML. For as=20
far as I remember, the idea was not developed because it was not easy t=
o find the number of packets=20
to send through the same slave. Anyway, this might help reduce out of o=
rder delivery.

> 	Barring evidence to the contrary, I presume that Oleg's system
> delivers out of order at the receiver.  That's not automatically a
> reason to reject it, but this entire proposal is sufficiently complex=
 to
> configure that very explicit documentation will be necessary.

Yes, and this is already true for some bonding modes and in particular =
for balance-rr.

	Nicolas.
