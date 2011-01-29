From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Bonding on bond
Date: Fri, 28 Jan 2011 16:38:48 -0800
Message-ID: <15526.1296261528@death>
References: <4D374A8F.2020303@gmail.com> <20110120153110.GA3931@midget.suse.cz> <4D385F0B.1010000@gmail.com> <4202.1295553193@death> <4D3B60D2.30309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Bohac <jbohac@suse.cz>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?us-ascii?Q?=3D=3FUTF-8=3FB=3FTmljb2xhcyBkZSBQZXNsb8O8YW4=3D=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:38688 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369Ab1A2Aiy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 19:38:54 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0T0Oc6h029797
	for <netdev@vger.kernel.org>; Fri, 28 Jan 2011 17:24:38 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0T0coJo103982
	for <netdev@vger.kernel.org>; Fri, 28 Jan 2011 17:38:51 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0T0co0K026710
	for <netdev@vger.kernel.org>; Fri, 28 Jan 2011 17:38:50 -0700
In-reply-to: <4D3B60D2.30309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan <nicolas.2p.debian@gmail.com> wrote:

>Le 20/01/2011 20:53, Jay Vosburgh a =C3=A9crit :
>> 	I'm in agreement that, by and large, nesting of bonds is
>> pointless.  However, I suspect that there are users out in the world=
 who
>> are happily doing so, and this patch may shut them down.
>
>Hi Jay,
>
>I tested the following nested bonding configuration:
>
>bond1 : eth1 + eth3, in balance-rr mode.
>bond2 : eth0 + eth2, in balance-rr mode.
>bond0 : bond1 + bond2, in active-backup mode.
>
>The egress path apparently works not so bad, even if I didn't take tim=
e
>yet to check proper load balancing nor fail over.
>
>However, the ingress path doesn't work at all. bond0 is unable to rece=
ive any packets (ARP or IP).

	In light of this, I don't see a problem with disallowing nesting
of bonds.  It should be documented in bonding.txt.

>It doesn't sound surprising to me, having a look at the current code i=
n __netif_receive_skb() :
>
>>         /*
>>          * bonding note: skbs received on inactive slaves should onl=
y
>>          * be delivered to pkt handlers that are exact matches.  Als=
o
>>          * the deliver_no_wcard flag will be set.  If packet handler=
s
>>          * are sensitive to duplicate packets these skbs will need t=
o
>>          * be dropped at the handler.
>>          */
>>         null_or_orig =3D NULL;
>>         orig_dev =3D skb->dev;
>>         master =3D ACCESS_ONCE(orig_dev->master);
>>         if (skb->deliver_no_wcard)
>>                 null_or_orig =3D orig_dev;
>>         else if (master) {
>>                 if (skb_bond_should_drop(skb, master)) {
>>                         skb->deliver_no_wcard =3D 1;
>>                         null_or_orig =3D orig_dev; /* deliver only e=
xact match */
>>                 } else
>>                         skb->dev =3D master;
>>         }
>
>The skb_bond_should_drop() and skb->dev =3D master logic is only appli=
ed at a single level.
>
>After this code, skb->dev is the master dev of the receiving dev, but
>skb->dev->master can be !=3D NULL, if another level of bonding
>exists. Nothing obvious would cause the packet to be delivered to this
>possible higher level bonding interface (skb->dev->master).
>
>Is something else expected to call __netif_receive_skb() again, with t=
he
>current skb, to cause another level of bonding to be reachable? For as=
 far
>as I understand, nothing will, but I might have missed something.
>
>> 	I've not tested with nesting in a while; I know it used to work
>> (at least for limited cases, typically an active-backup bond with a =
pair
>> of balance-xor or balance-rr or sometimes 802.3ad enslaved to it), b=
ut
>> has never really been a deliberate feature.  Is nesting now utterly
>> broken, as suggested by the list of problems above?
>
>I don't know whether someone really use nested bonding, but I can hard=
ly
>imagine how one can have it works with current kernel, except for a pu=
re
>egress application, without any feedback from the network. And such ve=
ry
>specific application wouldn't even be able to receive an ARP reply...
>
>> 	If nesting really doesn't work and is going to be disabled, then
>> at a minimum it should also have an update to the documentation
>> explaining this.
>
>At least, we should explain that nesting bonding interfaces is known t=
o be
>mostly broken and unsupported.
>
>That being said, we still miss a way to achieve a simple configuration
>with several links doing load balancing to a switch and one or several
>links doing fail over to another switch, both switches *not* being 802=
=2E3ad
>capable.

	This is a harder problem, but it's something that doesn't work
today (and I suspect hasn't for a long time, so if somebody was using
this, I think there would have been some discussion).

>Should we arrange for bonding to be allowed to nest, for this purpose,=
 or
>should we find a way to setup this configuration with a single level o=
f
>bonding ? I would prefer the second, but...

	I'm not sure that either is necessary; 802.3ad will do this
today, and few current production switches lack 802.3ad support.

	Adding support for etherchannel (i.e., not 802.3ad) gang
failover is nontrivial, because the multiple etherchannel port groups
will have to be managed separately, and most likely assigned manually.
Sure, it'd be nice to have, but I'm not sure if it's a benefit worth th=
e
effort.

	Either way, for now, since I recall you mentioned in another
email that you'd crashed the system from nesting bonds, I don't see a
problem with disallowing nesting and updating the documentation with a
bit of this discussion (e.g., "nesting doesn't work, you're probably
trying to do gang failover, which 802.3ad already does for you").

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
