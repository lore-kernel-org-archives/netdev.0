From: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Tue, 18 Jan 2011 19:57:27 +0300
Message-ID: <4D35C677.1020909@yandex-team.ru>
References: <20110114190714.GA11655@yandex-team.ru> <17405.1295036019@death> <4D30D37B.6090908@yandex-team.ru> <26330.1295049912@death> <4D35060D.5080004@intel.com> <4D358A47.4020009@yandex-team.ru> <4D35A9B4.7030701@gmail.com> <4D35B1B0.2090905@yandex-team.ru> <4D35BED5.7040301@gmail.com>
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
To: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from archeopterix.yandex.ru ([93.158.136.52]:8947 "EHLO
	archeopterix.yandex.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220Ab1ARQ5a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 11:57:30 -0500
In-Reply-To: <4D35BED5.7040301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2011 07:24 PM, Nicolas de Peslo=C3=BCan wrote:
> Le 18/01/2011 16:28, Oleg V. Ukhno a =C3=A9crit :
>> On 01/18/2011 05:54 PM, Nicolas de Peslo=C3=BCan wrote:
>>> I remember a topology (described by Jay, for as far as I remember),
>>> where two hosts were connected through two distinct VLANs. In such
>>> topology:
>>> - it is possible to detect path failure using arp monitoring instea=
d of
>>> miimon.
>>> - changing the destination MAC address of egress packets are not
>>> necessary, because egress path selection force ingress path selecti=
on
>>> due to the VLAN.
>>
>> In case with two VLANs - yes, this shouldn't be necessary(but needs =
to
>> be tested, I am not sure), but within one - it is essential for corr=
ect
>> rx load striping.
>
> Changing the destination MAC address is definitely not required if yo=
u
> segregate each path in a distinct VLAN.
Yes, such L2 network topology should provide necessary high-availabilit=
y=20
and load striping without need to change MAC addresses. But it is more=20
difficult to maintain and to understand, in my opinion(when there are=20
just several configurations like this - it's ok, but when you have 50 o=
r=20
more?) - this is why I've chosen 802.3ad.

> Even in the present of ISL between some switches, packet sent through
> host A interface connected to vlan 100 will only enter host B using t=
he
> interface connected to vlan 100. So every slaves of the bonding
> interface can use the same MAC address.
>
> Of course, changing the destination address would be required in orde=
r
> to achieve ingress load balancing on a *single* LAN. But, as Jay note=
d
> at the beginning of this thread, this would violate 802.3ad.
>

I think receiving same MAC-addresses on different ports on same host=20
will just make any troubleshooting much harder, won't it? With differen=
t=20
MACs it takes little time to find out where the problem is, usually.
I think that implementing choice for choosing whether use single MAC=20
address in etherchannel or just use slave's real MAC adresses, won't=20
harm anything for both 802.3ad and balance-rr modes, but will simplify=20
it's usage without doing any evil, when documented properly.

>
> You are right, but such LAN setup need to be carefully designed and
> built. I'm not sure that an automatic channel aggregation system is t=
he
> right way to do it. Hence the reason why I suggest to use balance-rr
> with VLANs.
>
>>> Oleg, would you mind trying the above "two VLAN" topology" with
>>> mode=3Dbalance-rr and report any results ? For high-availability pu=
rpose,
>>> it's obviously necessary to setup those VLAN on distinct switches.
>> I'll do it, but it will take some time to setup test environment,
>> several days may be.
>
> Thanks. For testing purpose, it is enough to setup those VLAN on a
> single switch if it is easier for you to do.
Well, I'll do it with 2 switches :)
>
>> You mean following topology:
>
> See above.
>
>> (i'm sure it will work as desired if each host is connected to each
>> switch with only one slave link, if there are more slaves in each sw=
itch
>> - unsure)?
>
> If you want to use more than 2 slaves per host, then you need more th=
an
> 2 VLAN.

That's what I don't like in this solution. Within one LAN is is simplie=
r=20
and requires less configuration efforts.

You also need to have the exact same number of slaves on all
> hosts, as egress path selection cause ingress path selection at the
> other side.
>

Well, and here's one difference from bonding with my patch. In case of=20
my patch applied, it is not required to have equal number of slaves, it=
=20
is enough to have *even* number of slaves, this almost always(so far I=20
haven't seen opposite) gurarntees good rx(ingress) load striping.

>
> Nicolas.
>


--=20
=D0=A1 =D1=83=D0=B2=D0=B0=D0=B6=D0=B5=D0=BD=D0=B8=D0=B5=D0=BC,
=D1=80=D1=83=D0=BA=D0=BE=D0=B2=D0=BE=D0=B4=D0=B8=D1=82=D0=B5=D0=BB=D1=8C=
 =D1=81=D0=BB=D1=83=D0=B6=D0=B1=D1=8B
=D1=8D=D0=BA=D1=81=D0=BF=D0=BB=D1=83=D0=B0=D1=82=D0=B0=D1=86=D0=B8=D0=B8=
 =D0=BA=D0=BE=D0=BC=D0=BC=D0=B5=D1=80=D1=87=D0=B5=D1=81=D0=BA=D0=B8=D1=85=
 =D0=B8 =D1=84=D0=B8=D0=BD=D0=B0=D0=BD=D1=81=D0=BE=D0=B2=D1=8B=D1=85 =D1=
=81=D0=B5=D1=80=D0=B2=D0=B8=D1=81=D0=BE=D0=B2
=D0=9E=D0=9E=D0=9E =D0=AF=D0=BD=D0=B4=D0=B5=D0=BA=D1=81

=D0=9E=D0=BB=D0=B5=D0=B3 =D0=AE=D1=85=D0=BD=D0=BE


