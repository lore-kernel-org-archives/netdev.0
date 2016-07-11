From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] net: ethernet: bcmgenet: use
 phy_ethtool_{get|set}_link_ksettings
Date: Sun, 10 Jul 2016 19:30:00 -0700
Message-ID: <578304A8.9000904@gmail.com>
References: <1467560037-21784-1-git-send-email-tremyfr@gmail.com>
 <1467560037-21784-2-git-send-email-tremyfr@gmail.com>
 <20160704.160300.953705748553101659.davem@davemloft.net>
 <577B37CC.80807@gmail.com> <577C2189.8090604@gmail.com>
 <577C2380.4000007@gmail.com> <1467754810.4204.17.camel@decadent.org.uk>
 <5782D120.9020605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36265 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757287AbcGKCaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 22:30:04 -0400
In-Reply-To: <5782D120.9020605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/07/2016 15:50, Philippe Reynes a =C3=A9crit :
> Hi all,
>=20
>=20
> On 05/07/16 23:40, Ben Hutchings wrote:
>> On Tue, 2016-07-05 at 14:15 -0700, Florian Fainelli wrote:
>>> On 07/05/2016 02:07 PM, Philippe Reynes wrote:
>>>> Hi Florian,
>>>>
>>>> On 05/07/16 06:30, Florian Fainelli wrote:
>>>>> Le 04/07/2016 16:03, David Miller a =C3=A9crit :
>>>>>> From: Philippe Reynes<tremyfr@gmail.com>
>>>>>> Date: Sun,  3 Jul 2016 17:33:57 +0200
>>>>>>
>>>>>>> There are two generics functions
>>>>>>> phy_ethtool_{get|set}_link_ksettings,
>>>>>>> so we can use them instead of defining the same code in the dri=
ver.
>>>>>>>
>>>>>>> Signed-off-by: Philippe Reynes<tremyfr@gmail.com>
>>>>>>
>>>>>> Applied.
>>>>>>
>>>>>
>>>>> The transformation is not equivalent, we lost the checks on
>>>>> netif_running() in the process, and those are here for a reason, =
if
>>>>> the
>>>>> interface is down and therefore clock gated, MDIO accesses to the=
 PHY
>>>>> will simply fail outright and cause bus errors.
>>>>
>>>> Oh, I see, I've missed this. Sorry for this mistake.
>>>> We should revert this path.
>>>
>>> Well, maybe better than that, actually put the check in the generic
>>> functions, because if the link is down, aka netif_running() returns
>>> false, link parameters cannot be reliably queried and they are inva=
lid.
>=20
> In my understanding, if the link is down, the pointer phydev in the
> struct net_device is NULL. So generic functions
> phy_ethtool_{get|set}_link_ksetting
> should return -ENODEV.

This pointer is NULL only when phy_detach() is called typically by
phy_disconnect(), but remains and needs to be valid reference throughou=
t
the entire time the network interface is open regardless of the link st=
ate.

One of the reasons why some drivers are checking for the phydev pointer
to be NULL is because you can have one process open the network
interface, attaching to the PHY at some point in that ndo_open, and
another one calling in ethtool_get_settings for instance and this secon=
d
process can see a transient state where the PHY device is not yet
attached (aka NULL).

>=20
> If I'm wrong, and it everybody agree, I'll send a patch that add a ch=
eck
> on netif_running.
>=20
>> Either the hardware or the driver needs to remember:
>>
>> - Is auto-negotiation enabled
>> - If so, which modes are advertised
>> - If not, which mode is forced
>>
>> And it should still be possible to get or set that information when =
the
>> interface is down.
>=20
> It could be possible to save the set_link_ksettings request if the li=
nk
> is down, and apply it when the link become up.
> It also could be possible to save the last state of the link before i=
t
> goes to down, and return it to a get_link_ksettings when the link is =
down.
> But what happen if the link was never up before the first
> get_link_kettings ?

Humm, sure, I would take a few examples first and see how consistent
they are with allowing these operations while the link is down and move
from there.

Thanks!
--=20
=46lorian
