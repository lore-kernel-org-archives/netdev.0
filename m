From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bridging + load balancing bonding
Date: Thu, 22 Oct 2009 10:36:00 -0700
Message-ID: <347.1256232960@death.nxdomain.ibm.com>
References: <20091022122339.GA20148@spaans.fox.local> <4AE07D3C.3040702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jasper Spaans <spaans@fox-it.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:32778 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752615AbZJVRgG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 13:36:06 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n9MHSlBL010322
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 13:28:47 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9MHa9rN1233060
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 13:36:10 -0400
Received: from d01av01.pok.ibm.com (d03av01 [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9MHa9XN019181
	for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 13:36:09 -0400
In-reply-to: <4AE07D3C.3040702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

>Jasper Spaans a =C3=A9crit :
>> Hi,
>>=20
>> We're using the following setup for bonding and bridging, to be able=
 to put
>> large amounts of data through multiple IDS analyzers:
>>=20
>>                              +---[br0]----+     +--- eth1 ---(IDS ma=
chine 1)
>> (Span port from switch) -- eth0          bond0--+
>>                                                 +--- eth2 ---(IDS ma=
chine 2)
>>=20
>> eth0 receives network traffic, which should be passed to machines wh=
ich are
>> connected to eth1 and eth2. These machines run an IDS package, and t=
here are
>> two of those for performance reasons.
>>=20
>> bond0 is configured to load balance the packets using "balance-xor",=
 in this
>> case combined with xmit_hash_policy layer2.
>>=20
>> However, we're seeing problems: packets from one flow do not end up =
at the
>> same IDS machine.  This is because this selection is not based on th=
e source
>> _and_ destination mac addresses of the original packet, but on the m=
ac
>> address of the bonding device and the destination mac address of the
>> package.

	By "packets from one flow" do you really mean that packets from
a given "flow" (TCP connection, UDP "stream", etc) are not always
delivered to the same bonding port?  I.e., that two packets from the
same "flow" will be delivered to different ports?  I'm not sure how
that's possible unless the source MAC in the packets changes during the
course of the flow.

	Or is your problem really that the balance algorithm on the
bonding send side doesn't match the algorithm used on the other side of
the IDS machines coming the other direction (and, thus, packets for a
given flow going in one direction end up at a different IDS than the
packets going the other direction)?

>> This is also clear in the code:
>> For example, in bond_main.c, in bond_xmit_hash_policy_l2:
>> 	return (data->h_dest[5] ^ bond_dev->dev_addr[5]) % count;
>>=20
>> Changing this to
>> 	return (data->h_dest[5] ^ data->h_source[5]) % count;
>> fixes our problems, but is this harmful for packets originating loca=
lly (or
>> being routed?)
>>=20
>> If not, can this be applied? Or does anyone have other ideas?
>>=20
>
>Hi Jasper
>
>Very nice setup, and nice finding.
>
>Dont locally generated (or outed) packets have h_source set to
>bond_dev->dev_addr anyway ?

	Locally generated packets do, but he's got a bridge in there, so
the traffic they're balancing is presumably not locally generated (i.e.=
,
is being forwarded by the bridge, in which case they'll still bear the
source MAC of the originating node on the subnet).  If the packets were
being routed instead of bridged, then, yah, they'd have the bond's
source MAC.

>So your solution might be the right fix...

	Yes, I think he's found a legitimate bug, one that only will
manifest when balancing bridged traffic.  I had to think for a minute i=
f
this change would break anything, and I'm coming up empty.  Locally
generated or routed traffic won't see a change, and bridged traffic wil=
l
be correctly balanced according to the "source MAC XOR destination MAC"
forumla described in the documentation.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
