From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's source MAC
Date: Tue, 01 Mar 2011 14:25:31 -0800
Message-ID: <20893.1299018331@death>
References: <1298668408-14849-1-git-send-email-andy@greyhouse.net> <4D68276B.90104@gmail.com> <20110225222455.GI11864@gospo.rdu.redhat.com> <4D683653.4050409@gmail.com> <20110228163255.GJ11864@gospo.rdu.redhat.com> <4D6C1764.1040008@gmail.com> <20110301023525.GK11864@gospo.rdu.redhat.com> <9882.1298958366@death> <20110301181624.GM11864@gospo.rdu.redhat.com> <4D6D658C.90300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jiri Pirko <jpirko@redhat.com>
To: =?us-ascii?Q?=3D=3FISO-8859-1=3FQ=3FNicolas=5Fde=5FPeslo=3DFCan=3F=3D?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:48809 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756445Ab1CAWZf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 17:25:35 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p21MFqCq020668
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2011 17:15:52 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id BAB006E8036
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2011 17:25:34 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p21MPYRm174098
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2011 17:25:34 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p21MUEcI017586
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2011 15:30:15 -0700
In-reply-to: <4D6D658C.90300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@gmail.com> wrote:

>Le 01/03/2011 19:16, Andy Gospodarek a =C3=A9crit :
>
>[snip]
>
>> Knowing that I'm using an unmanaged switch with balance-rr probably
>> helps understand how this is happening.  I'll clarify this however, =
so
>> we are all on the same page.
>>
>> In my situation, eth2 and eth3 are in bond0.  When bond0 transmits t=
he
>> NS, let's say it goes out eth3.  Since it is a multicast frame my sw=
itch
>> will broadcast this to all ports and eth2 will receive the frame wit=
h
>> the source MAC address being the same as bond0's MAC address.  This
>> frame is passed up the stack to the ipv6 layer and appears to be a
>> response to the NS from another host and is dropped.
>
>'sounds perfectly normal.
>
>This problem is described in detail in chapter 5.4.3 and appendix A of
>RFC4862 "IPv6 Stateless Address Autoconfiguration".
>
>As this is clearly IPv6 related, it sounds normal from my point of vie=
w to
>fix it at the ndisc_recv_ns() level.

	Andy's immediate problem is IPv6 related, but the issue itself
is generic: how to deal with broadcast / multicasts arriving at a -rr o=
r
-xor bond, because we do not and cannot know if the switch is going to
flood to the slaves or not.  There may be other instances wherein that
bonus copy of some packet confuses things.

	My view is that -rr and -xor are intended to interoperate with
Etherchannel.  Yes, they will often work tolerably well when connected
to a non-Etherchannel switch.  But, if the host and the switch are not
in agreement on the link aggregation status of the ports, some level of
misbehavior is expected.  If that misbehavior can be corrected without
adversely affecting a properly configured host and switch, then I don't
see much problem with fixing it.

	For the IPv6 case here, I think there's a problem with any fix,
and that is that there's no way for bonding to know if the switch ports
are configured properly or not.  I'm using "properly" to mean that the
switch ports corresponding to the bonding slaves are configured into an
Etherchannel-type channel group.

	If the switch ports are grouped, then if IPv6 sees one of these
messages coming in, it's actually a duplicate detection.  This because
the switch won't loop the broadcast / multicast back around to a member
of the channel group.

	If the switch ports are not grouped, then the switch will
happily send broadcasts and multicasts to all ports of the bond, becaus=
e
it doesn't know about the aggregation.  In this case, I suspect there's
no way to reliably determine if the incoming packet is a switch artifac=
t
or an actual duplicate detection.  Anybody know for sure if this is the
case?

	For the generic case, I'm not seeing a way to distinguish actual
repeated packets from switch artifact duplicate packets without adding
another knob to bonding to tell it if the switch does etherchannel or
not (which I'm not in favor of doing).

>Quoting the RFC:
>
>  "In those cases where the hardware cannot suppress loopbacks, howeve=
r,
>   one possible software heuristic to filter out unwanted loopbacks is
>   to discard any received packet whose link-layer source address is t=
he
>   same as the receiving interface's.  There is even a link-layer
>   specification that requires that any such packets be discarded
>   [IEEE802.11].  Unfortunately, use of that criteria also results in
>   the discarding of all packets sent by another node using the same
>   link-layer address.  Duplicate Address Detection will fail on
>   interfaces that filter received packets in this manner:
>
>   [snip]
>
>   Thus, to perform Duplicate Address Detection correctly in the case
>   where two interfaces are using the same link-layer address, an
>   implementation must have a good understanding of the interface's
>   multicast loopback semantics, and the interface cannot discard
>   received packets simply because the source link-layer address is th=
e
>   same as the interface's."
>
>So, simply dropping frames whose source MAC =3D=3D local MAC is appare=
ntly not the right solution.

	I tend to agree here, because this would break DAD for properly
configured (meaning etherchannel on the switch ports) installations.

	Is there a way to fix bonding and/or ndisc_recv_ns to work
correctly for both cases (have/don't have etherchannel on the switch)?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
