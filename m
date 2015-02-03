From: shengyong <shengyong1@huawei.com>
Subject: Re: Question: should local address be expired when updating PMTU?
Date: Tue, 3 Feb 2015 18:54:19 +0800
Message-ID: <54D0A8DB.4010106@huawei.com>
References: <54CF3348.40207@huawei.com> <20150203092845.GT13046@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<yangyingliang@huawei.com>, <hannes@redhat.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:36810 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbbBCKyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 05:54:49 -0500
In-Reply-To: <20150203092845.GT13046@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



=E5=9C=A8 2015/2/3 17:28, Steffen Klassert =E5=86=99=E9=81=93:
> On Mon, Feb 02, 2015 at 04:20:24PM +0800, shengyong wrote:
>> Hi, David Miller
>> Since commit 81aded246 (ipv6: Handle PMTU in ICMP error handlers), t=
he entries
>> in neigh table may get expired. But in the situation:
>>
>>           Host only
>>     PC <------------> Virtual Machine
>>
>> a packet is sent from PC to VM, and the packet looks like:
>> -----------------------------------
>> | IPv6 (src=3DPC-addr, dst=3DVM-addr) |
>> |---------------------------------|
>> |     ICMPv6 (Packet Too Big)     |
>> |---------------------------------|
>> | IPv6 (src=3DVM-addr, dst=3DVM-addr) |
>> |---------------------------------|
>> | ICMPv6 (Neighbor Advertisement) |
>> -----------------------------------
>>
>> Then the local addr on VM will be updated with an expire value. Afte=
r the
>> lifetime of the local addr is expired, the VM is unreachable from PC=
=2E
>>
>> 	# ip -6 route list table local
>> 	local fe80::1 dev lo  metric 0 *expire 596*
>=20
> We first need to find out why you receive this Packet Too Big message=
,
The packet is sent by a commercial-off-the-shelf testcase, and I can re=
produce the
situation by using scapy and creating a packet as the following:

	$ cat packet-too-big.py
	#!/usr/bin/python
=09
	from scapy.all import *

	# fe80::800:27ff:fe00:0 is linklocal addr of PC
	# fe80::a00:27ff:fe1a:e2a0 is linklocal addr of VM
	base=3DIPv6(src=3D'fe80::800:27ff:fe00:0',dst=3D'fe80::a00:27ff:fe1a:e=
2a0')
	pkt_too_big=3DICMPv6PacketTooBig(mtu=3D1024)
	ext_base=3DIPv6(src=3D'fe80::a00:27ff:fe1a:e2a0',dst=3D'fe80::a00:27ff=
:fe1a:e2a0',plen=3D24)
	ext_nd_na=3DICMPv6ND_NA()
=09
	packet=3Dbase/pkt_too_big/ext_base/ext_nd_na
	send(packet)

> can you capture this packet somehow?=20
I captured the packet in wireshark, it is exact the packet created by t=
he script.
> Then we have to see why this loopback
> route gets a pmtu update from that packet.
I tried to print info when the VM receives pkt-too-big packet. The call=
ing stack is
icmpv6_rcv->icmpv6_notify->icmpv6_err->ip6_update_pmtu->ip6_rt_update_p=
mtu->rt6_update_expires.
In ip6_update_pmtu, ip6_route_output looks up the route table, and retu=
rns the dst_entry of the
linklocal addr. Then it is set to expire.
> Is the destination address
> of the Packet Too Big message really fe80::1?
In fact, if the dst of the above `ext_base' is the local addr of the VM=
, the local addr on VM
will be expired.

thx,
Sheng

>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20
