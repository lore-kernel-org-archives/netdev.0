From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv4 regression in 2.6.31 ?
Date: Mon, 14 Sep 2009 18:10:21 +0200
Message-ID: <4AAE6AED.1070609@gmail.com>
References: <20090914150935.cc895a3c.skraw@ithnet.com>	<4AAE4BAF.2010406@gmail.com> <20090914175505.a3f132ee.skraw@ithnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephan von Krawczynski <skraw@ithnet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39473 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbZINQKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 12:10:24 -0400
In-Reply-To: <20090914175505.a3f132ee.skraw@ithnet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan von Krawczynski a =E9crit :
> On Mon, 14 Sep 2009 15:57:03 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> Stephan von Krawczynski a =E9crit :
>>> Hello all,
>>>
>>> today we experienced some sort of regression in 2.6.31 ipv4 impleme=
ntation, or
>>> at least some incompatibility with former 2.6.30.X kernels.
>>>
>>> We have the following situation:
>>>
>>>                                        ---------- vlan1@eth0 192.16=
8.2.1/24
>>>                                       /
>>> host A 192.168.1.1/24 eth0  -------<router>            host B
>>>                                       \
>>>                                        ---------- eth1 192.168.3.1/=
24
>>>
>>>
>>> Now, if you route 192.168.1.0/24 via interface vlan1@eth0 on host B=
 and let
>>> host A ping 192.168.2.1 everything works. But if you route 192.168.=
1.0/24 via
>>> interface eth1 on host B and let host A ping 192.168.2.1 you get no=
 reply.
>>> With tcpdump we see the icmp packets arrive at vlan1@eth0, but no i=
cmp echo
>>> reply being generated neither on vlan1 nor eth1.
>>> Kernels 2.6.30.X and below do not show this behaviour.
>>> Is this intended? Do we need to reconfigure something to restore th=
e old
>>> behaviour?
>>>
>> Asymetric routing ?
>>
>> Check your rp_filter settings
>>
>> grep . `find /proc/sys/net -name rp_filter`
>>
>> rp_filter - INTEGER
>>         0 - No source validation.
>>         1 - Strict mode as defined in RFC3704 Strict Reverse Path
>>             Each incoming packet is tested against the FIB and if th=
e interface
>>             is not the best reverse path the packet check will fail.
>>             By default failed packets are discarded.
>>         2 - Loose mode as defined in RFC3704 Loose Reverse Path
>>             Each incoming packet's source address is also tested aga=
inst the FIB
>>             and if the source address is not reachable via any inter=
face
>>             the packet check will fail.
>>
>>         Current recommended practice in RFC3704 is to enable strict =
mode
>>         to prevent IP spoofing from DDos attacks. If using asymmetri=
c routing
>>         or other complicated routing, then loose mode is recommended=
=2E
>>
>>         conf/all/rp_filter must also be set to non-zero to do source=
 validation
>>         on the interface
>>
>>         Default value is 0. Note that some distributions enable it
>>         in startup scripts.
>=20
> Ok, here you can see 2.6.31 values from the discussed box:
> (remember, no ping reply in this setup)
>=20
> /proc/sys/net/ipv4/conf/all/rp_filter:1
> /proc/sys/net/ipv4/conf/default/rp_filter:0
> /proc/sys/net/ipv4/conf/lo/rp_filter:0
> /proc/sys/net/ipv4/conf/eth2/rp_filter:0
> /proc/sys/net/ipv4/conf/eth0/rp_filter:0
> /proc/sys/net/ipv4/conf/eth1/rp_filter:0
> /proc/sys/net/ipv4/conf/vlan1/rp_filter:0
>=20
>=20
> And these are from the same box with 2.6.30.5:
> (ping reply works)
>=20
> /proc/sys/net/ipv4/conf/all/rp_filter:1
> /proc/sys/net/ipv4/conf/default/rp_filter:0
> /proc/sys/net/ipv4/conf/lo/rp_filter:0
> /proc/sys/net/ipv4/conf/eth2/rp_filter:0
> /proc/sys/net/ipv4/conf/eth0/rp_filter:0
> /proc/sys/net/ipv4/conf/eth1/rp_filter:0
> /proc/sys/net/ipv4/conf/vlan1/rp_filter:0
>=20
> As you can see they're all the same. Does this mean that rp_filter ne=
ver
> really worked as intended before 2.6.31 ? Or does it mean that rp_fil=
ter=3D0
> (eth1 and vlan1) gets overriden by all/rp_filter=3D1 in 2.6.31 and no=
t before?
>

Yes, previous kernels ignored /proc/sys/net/ipv4/conf/all/rp_filter val=
ue, it was a bug.

commit 27fed4175acf81ddd91d9a4ee2fd298981f60295
Author: Stephen Hemminger <shemminger@vyatta.com>
Date:   Mon Jul 27 18:39:45 2009 -0700

    ip: fix logic of reverse path filter sysctl

    Even though reverse path filter was changed from simple boolean to
    trinary control, the loose mode only works if both all and device a=
re
    configured because of this logic error.

    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


In your case, you *need*
echo 0 >/proc/sys/net/ipv4/conf/all/rp_filter
or
echo 2 >/proc/sys/net/ipv4/conf/all/rp_filter

