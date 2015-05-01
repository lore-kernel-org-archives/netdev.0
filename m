From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 7/8] net: dsa: mv88e6060: make it a proper
 PHY driver
Date: Thu, 30 Apr 2015 23:41:28 -0700
Message-ID: <55432018.4070507@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com> <1430359064-23454-8-git-send-email-f.fainelli@gmail.com> <554232E9.5080104@roeck-us.net> <55425C53.6060509@gmail.com> <5542E4CF.50901@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:34540 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbbEAGlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 02:41:31 -0400
Received: by obfe9 with SMTP id e9so60740987obf.1
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 23:41:30 -0700 (PDT)
In-Reply-To: <5542E4CF.50901@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/30/15 19:28, Guenter Roeck a =C3=A9crit :
> On 04/30/2015 09:46 AM, Florian Fainelli wrote:
>> On 30/04/15 06:49, Guenter Roeck wrote:
>>> On 04/29/2015 06:57 PM, Florian Fainelli wrote:
>>>> Convert the Marvell 88E6060 switch driver into a proper PHY librar=
y
>>>> driver that can be registered. To make sure we do not introduce
>>>> functional changes, the PHY driver provides autoneg and status
>>>> callbacks
>>>> to make sure the attached Ethernet MAC driver still sees a link UP=
 at
>>>> the CPU port full speed.
>>>>
>>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>>> ---
>>>>    drivers/net/dsa/mv88e6060.c | 114
>>>> ++++++++++++++++++++++++++++++++++++++++++--
>>>>    1 file changed, 109 insertions(+), 5 deletions(-)
>>>>
>>>
>>> The whole complexity added here makes me wonder if we are really on=
 the
>>> right track.
>>> After all, switches are _not_ phy devices. Forcing them to register=
 as
>>> phy devices
>>> just because they use mdio and just because the Linux mdio
>>> implementation assumes
>>> that anything connected to it is a phy seems odd.
>>
>> The net advantage I see with this approach is that currently, with D=
SA,
>> you get to do the following:
>>
>> - register a "dsa" platform device
>> - force your CPU Ethernet MAC to hardcode link parameters, either vi=
a a
>> "fixed PHY" or via custom settings (ala mv643xx_eth)
>> - probing needs to occur in a *very* specific order: MDIO first,
>> Ethernet device second, DSA last
>>
>> Now, with this patchset, you don't need to have DSA awareness in
>> anything but the "provider" driver which in this case is a PHY drive=
r
>> because it sits on the MDIO bus (see below on that topic) and things
>> tend to "flow" a bit more naturally one you do that.
>>
>=20
> See, that is where I have the problem. The switch connects to the MDI=
O bus,
> and the Linux infrastructure therefore declares that it has to be a P=
HY
> chip, and that one must implement a phy driver to connect to it.
>=20
> But it isn't a PHY we are dealing with. It is a switch chip.
>=20
>>>
>>> A much better solution might be be to disconnect mdio from phy, ie =
to
>>> create a new
>>> mdio bus framework, as then use this framework for anything connect=
ed to
>>> an mdio bus.
>>
>> So essentially end-up creating a separate class of MDIO addressable
>> devices which are switches? I guess we could try to do that. We woul=
d
>=20
> Yes, that would be the idea. Instead of declaring that everything
> connected to MDIO must by definition be a PHY chip (and thus implemen=
t
> a phy driver), we could have a MDIO infrastructure and different type=
s
> of devices connect to it (such as phy and switch chips, and whatever
> else may be out there that uses MDIO).

Ok.

>=20
> In a way this is similar to other busses, such as I2C or SPI or PCIe.
> To me, modeling the switch driver as phy driver is kind of similar
> to modeling all I2C drivers as, say, EEPROMs.

Well that is true to some degree, switches do typically expose real PHY=
s
for their individual non-CPU ports, so they are kind of enhanced PHY
devices in some sense, but yet not quite full-featured Ethernet MACs as
well.

>=20
>> still have to update existing Ethernet MAC drivers which speak phyli=
b to
>> know what to do with their CPU port and set correct link parameters,
>> would we want to create a special PHY drivers for these, just for th=
e
>> CPU port?
>>
> Not sure I follow you here.

If you have an Ethernet MAC driver, e.g: mv643xx_eth, bcmgenet, mvneta
or others which are already using the PHY library via of_phy_connect()
for instance; if your switch driver is implemented as a PHY driver, you
get to discover this switch pretty much for free, just like if it was a
regular PHY. That is why I used this approach, and what others have don=
e
in OpenWrt as well, such that you can have mostly unmodified Ethernet
drivers transparently use MDIO-connected switches just like they would
do with an Ethernet PHY.

If we do not do that, which is certainly fine, I am more worried about
having to patch every single driver that knows phylib and teach them ho=
w
to speak to switches, a different class of devices. Maybe the PHY
library is pushing the abstraction a little to far, and what we need is
something that looks like the "old" style MII bus code that sb1250-mac.=
c
has for instance?

>=20
>>>
>>> Does this make any sense, or am I completely off track ?
>>
>> I think this is very valid, my main point behind this entire patch
>> series is to divorce from the special "dsa" platform_device for comm=
on
>> cases: MDIO or MMIO connected switches to a SoC, because it is
>> convoluted and prevents a lot of things from being done: module
>> unloading, proper device reference (and parenting), need for "out of
>> band" link information to be provided to unmodified Ethernet drivers
>> etc...
>>
>=20
> Oh, I absolutely agree that the current model has problems. I am just=
 not
> happy about modeling the switch drivers as phy driver.
>=20
> Thanks,
> Guenter
>=20


--=20
=46lorian
