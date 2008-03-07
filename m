From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCHv8 1/2] Interface group: core and netlink part
Date: Fri, 07 Mar 2008 13:40:11 +0100
Message-ID: <47D137AB.9040305@balabit.hu>
References: <12048121721361-git-send-email-panther@balabit.hu>	<1204812239968-git-send-email-panther@balabit.hu> <20080306.111519.46454329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:50180 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757489AbYCGMkR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Mar 2008 07:40:17 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 32E41C141E
	for <netdev@vger.kernel.org>; Fri,  7 Mar 2008 13:40:15 +0100 (CET)
In-Reply-To: <20080306.111519.46454329.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller =EDrta:
> From: Laszlo Attila Toth <panther@balabit.hu>
> Date: Thu,  6 Mar 2008 15:03:58 +0100
>=20
>> Interface groups let handle different interfaces together.
>> Modified net device structure and netlink interface.
>>
>> Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
>=20
> I can't say whether this makes sense without seeing how
> it will actually be used.

The userspace has two parts, one is in iproute2:

  ip link set dev eth0 group 4

  ip link show dev eth0
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast=20
group 0x04 qlen 1000
     link/ether 00:0c:29:97:52:99 brd ff:ff:ff:ff:ff:ff

This is still nothing special.

Where can it be used? The netfilter part is an ifgroup match:

  ifgroup -A INPUT -m ifgroup --ifgroup-in 4/0xf ...
  ifgroup -A OUTPUT -m ifgroup --ifgroup-out 4/0xf ...

Also multiple devices can be grouped and handled with one rule. Althoug=
h=20
  the interfaces can be named as the user wants, it is not always enoug=
h=20
(I mean for instance:  iptables ... -i ppp+ ...).


Consider the following example (a bit complex, I think): a VPN server=20
has many clients but not all services and networks has to be accessible=
=20
for each clients, also an ACL is needed (Or the same situation on a=20
router with several interfaces) The ifgroup value has 32 bits also 32=20
different rule can be set up. The only necessary thing for the=20
corresponding "if-up" scripts to calculate the value corresponding to=20
the acl list and set this as an ifgroup value for the device. Next in=20
the netfilter rules  access to unneeded services can be rejected with a=
=20
single rule:

   iptables -A PREROUTING -m ifgroup --ifgroup-in 0/0x4 ... -j REJECT .=
=2E.

Also the ifgroup match helps iptables rules to be simplier. Whithout it=
=20
a new chain is necessary and on every interface change a new rule has t=
o=20
be added/removed. If two iptables commands are running, AFAIK a=20
concurrency problem can be occured because two iptables command=20
downloads the ruleset, change it and uploaded. But only one of them is=20
taken into account.


Another possible use case is - I have no patch yet:
currently the ip command can access information of exactly one device o=
r=20
all of them, but only a few of them cannot be used. With ifgroup this=20
problem can be solved, also instead of:

  ip link show dev eth0

use

   ip link show group 3

and so on.


> If that's all it is, userland can record such mappings
> in the filesystem or elsewhere such that multiple
> applications can work with and maintain the relationships.
> There is zero reason to add this bloat to the kernel in
> such a case.

Yeah, without the netfilter rules this would be unnecessary in the=20
kernel but it depends on it.

--
Attila


