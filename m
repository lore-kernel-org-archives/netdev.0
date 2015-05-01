From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC PATCH net-next 7/8] net: dsa: mv88e6060: make it a proper
 PHY driver
Date: Thu, 30 Apr 2015 19:28:31 -0700
Message-ID: <5542E4CF.50901@roeck-us.net>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com> <1430359064-23454-8-git-send-email-f.fainelli@gmail.com> <554232E9.5080104@roeck-us.net> <55425C53.6060509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:49959 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219AbbEAC3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 22:29:19 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.85)
	(envelope-from <linux@roeck-us.net>)
	id 1Yo0ha-003Eg8-9b
	for netdev@vger.kernel.org; Fri, 01 May 2015 02:29:18 +0000
In-Reply-To: <55425C53.6060509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/30/2015 09:46 AM, Florian Fainelli wrote:
> On 30/04/15 06:49, Guenter Roeck wrote:
>> On 04/29/2015 06:57 PM, Florian Fainelli wrote:
>>> Convert the Marvell 88E6060 switch driver into a proper PHY library
>>> driver that can be registered. To make sure we do not introduce
>>> functional changes, the PHY driver provides autoneg and status callbacks
>>> to make sure the attached Ethernet MAC driver still sees a link UP at
>>> the CPU port full speed.
>>>
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>> ---
>>>    drivers/net/dsa/mv88e6060.c | 114
>>> ++++++++++++++++++++++++++++++++++++++++++--
>>>    1 file changed, 109 insertions(+), 5 deletions(-)
>>>
>>
>> The whole complexity added here makes me wonder if we are really on the
>> right track.
>> After all, switches are _not_ phy devices. Forcing them to register as
>> phy devices
>> just because they use mdio and just because the Linux mdio
>> implementation assumes
>> that anything connected to it is a phy seems odd.
>
> The net advantage I see with this approach is that currently, with DSA,
> you get to do the following:
>
> - register a "dsa" platform device
> - force your CPU Ethernet MAC to hardcode link parameters, either via a
> "fixed PHY" or via custom settings (ala mv643xx_eth)
> - probing needs to occur in a *very* specific order: MDIO first,
> Ethernet device second, DSA last
>
> Now, with this patchset, you don't need to have DSA awareness in
> anything but the "provider" driver which in this case is a PHY driver
> because it sits on the MDIO bus (see below on that topic) and things
> tend to "flow" a bit more naturally one you do that.
>

See, that is where I have the problem. The switch connects to the MDIO bus,
and the Linux infrastructure therefore declares that it has to be a PHY
chip, and that one must implement a phy driver to connect to it.

But it isn't a PHY we are dealing with. It is a switch chip.

>>
>> A much better solution might be be to disconnect mdio from phy, ie to
>> create a new
>> mdio bus framework, as then use this framework for anything connected to
>> an mdio bus.
>
> So essentially end-up creating a separate class of MDIO addressable
> devices which are switches? I guess we could try to do that. We would

Yes, that would be the idea. Instead of declaring that everything
connected to MDIO must by definition be a PHY chip (and thus implement
a phy driver), we could have a MDIO infrastructure and different types
of devices connect to it (such as phy and switch chips, and whatever
else may be out there that uses MDIO).

In a way this is similar to other busses, such as I2C or SPI or PCIe.
To me, modeling the switch driver as phy driver is kind of similar
to modeling all I2C drivers as, say, EEPROMs.

> still have to update existing Ethernet MAC drivers which speak phylib to
> know what to do with their CPU port and set correct link parameters,
> would we want to create a special PHY drivers for these, just for the
> CPU port?
>
Not sure I follow you here.

>>
>> Does this make any sense, or am I completely off track ?
>
> I think this is very valid, my main point behind this entire patch
> series is to divorce from the special "dsa" platform_device for common
> cases: MDIO or MMIO connected switches to a SoC, because it is
> convoluted and prevents a lot of things from being done: module
> unloading, proper device reference (and parenting), need for "out of
> band" link information to be provided to unmodified Ethernet drivers etc...
>

Oh, I absolutely agree that the current model has problems. I am just not
happy about modeling the switch drivers as phy driver.

Thanks,
Guenter
