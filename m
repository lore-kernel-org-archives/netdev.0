From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Tue, 18 Jan 2011 17:24:53 +0100
Message-ID: <4D35BED5.7040301@gmail.com>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?UTF-8?B?U8OpYmFzdGllbiBCYXJyw6k=?= <sebastien.barre@uclouvain.be>,
	Christophe Paasch <christoph.paasch@uclouvain.be>
To: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:56960 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122Ab1ARQY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 11:24:57 -0500
Received: by fxm20 with SMTP id 20so7376589fxm.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 08:24:56 -0800 (PST)
In-Reply-To: <4D35B1B0.2090905@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/01/2011 16:28, Oleg V. Ukhno a =C3=A9crit :
> On 01/18/2011 05:54 PM, Nicolas de Peslo=C3=BCan wrote:
>> I remember a topology (described by Jay, for as far as I remember),
>> where two hosts were connected through two distinct VLANs. In such
>> topology:
>> - it is possible to detect path failure using arp monitoring instead=
 of
>> miimon.
>> - changing the destination MAC address of egress packets are not
>> necessary, because egress path selection force ingress path selectio=
n
>> due to the VLAN.
>
> In case with two VLANs - yes, this shouldn't be necessary(but needs t=
o
> be tested, I am not sure), but within one - it is essential for corre=
ct
> rx load striping.

Changing the destination MAC address is definitely not required if you =
segregate each path in a=20
distinct VLAN.

             +-------------------+     +-------------------+
     +-------|switch 1 - vlan 100|-----|switch 2 - vlan 100|-------+
     |       +-------------------+     +-------------------+       |
+------+              |                         |              +------+
|host A|              |                         |              |host B|
+------+              |                         |              +------+
     |       +-------------------+     +-------------------+       |
     +-------|switch 3 - vlan 200|-----|switch 4 - vlan 200|-------+
             +-------------------+     +-------------------+

Even in the present of ISL between some switches, packet sent through h=
ost A interface connected to=20
vlan 100 will only enter host B using the interface connected to vlan 1=
00. So every slaves of the=20
bonding interface can use the same MAC address.

Of course, changing the destination address would be required in order =
to achieve ingress load=20
balancing on a *single* LAN. But, as Jay noted at the beginning of this=
 thread, this would violate=20
802.3ad.

>> I think the only point is whether we need a new xmit_hash_policy for
>> mode=3D802.3ad or whether mode=3Dbalance-rr could be enough.
> May by, but it seems to me fair enough not to restrict this feature o=
nly
> to non-LACP aggregate links; dynamic aggregation may be useful(it hel=
ps
> to avoid switch misconfiguration(misconfigured slaves on switch side)
> sometimes without loss of service).

You are right, but such LAN setup need to be carefully designed and bui=
lt. I'm not sure that an=20
automatic channel aggregation system is the right way to do it. Hence t=
he reason why I suggest to=20
use balance-rr with VLANs.

>> Oleg, would you mind trying the above "two VLAN" topology" with
>> mode=3Dbalance-rr and report any results ? For high-availability pur=
pose,
>> it's obviously necessary to setup those VLAN on distinct switches.
> I'll do it, but it will take some time to setup test environment,
> several days may be.

Thanks. For testing purpose, it is enough to setup those VLAN on a sing=
le switch if it is easier for=20
you to do.

> You mean following topology:

See above.

> (i'm sure it will work as desired if each host is connected to each
> switch with only one slave link, if there are more slaves in each swi=
tch
> - unsure)?

If you want to use more than 2 slaves per host, then you need more than=
 2 VLAN. You also need to=20
have the exact same number of slaves on all hosts, as egress path selec=
tion cause ingress path=20
selection at the other side.

             +-------------------+     +-------------------+
     +-------|switch 1 - vlan 100|-----|switch 2 - vlan 100|-------+
     |       +-------------------+     +-------------------+       |
+------+              |                         |              +------+
|host A|              |                         |              |host B|
+------+              |                         |              +------+
   | |       +-------------------+     +-------------------+       | |
   | +-------|switch 3 - vlan 200|-----|switch 4 - vlan 200|-------+ |
   |         +-------------------+     +-------------------+         |
   |                   |                         |                   |
   |                   |                         |                   |
   |         +-------------------+     +-------------------+         |
   +---------|switch 5 - vlan 300|-----|switch 6 - vlan 300|---------+
             +-------------------+     +-------------------+

Of course, you can add others host to vlan 100, 200 and 300, with the e=
xact same configuration at=20
host A or host B.

	Nicolas.
