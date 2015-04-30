From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 7/8] net: dsa: mv88e6060: make it a proper
 PHY driver
Date: Thu, 30 Apr 2015 09:46:11 -0700
Message-ID: <55425C53.6060509@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com> <1430359064-23454-8-git-send-email-f.fainelli@gmail.com> <554232E9.5080104@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, andrew@lunn.ch,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Guenter Roeck <linux@roeck-us.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:36619 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbbD3QqV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 12:46:21 -0400
Received: by pdea3 with SMTP id a3so65920014pde.3
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 09:46:20 -0700 (PDT)
In-Reply-To: <554232E9.5080104@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/15 06:49, Guenter Roeck wrote:
> On 04/29/2015 06:57 PM, Florian Fainelli wrote:
>> Convert the Marvell 88E6060 switch driver into a proper PHY library
>> driver that can be registered. To make sure we do not introduce
>> functional changes, the PHY driver provides autoneg and status callbacks
>> to make sure the attached Ethernet MAC driver still sees a link UP at
>> the CPU port full speed.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>   drivers/net/dsa/mv88e6060.c | 114
>> ++++++++++++++++++++++++++++++++++++++++++--
>>   1 file changed, 109 insertions(+), 5 deletions(-)
>>
> 
> The whole complexity added here makes me wonder if we are really on the
> right track.
> After all, switches are _not_ phy devices. Forcing them to register as
> phy devices
> just because they use mdio and just because the Linux mdio
> implementation assumes
> that anything connected to it is a phy seems odd.

The net advantage I see with this approach is that currently, with DSA,
you get to do the following:

- register a "dsa" platform device
- force your CPU Ethernet MAC to hardcode link parameters, either via a
"fixed PHY" or via custom settings (ala mv643xx_eth)
- probing needs to occur in a *very* specific order: MDIO first,
Ethernet device second, DSA last

Now, with this patchset, you don't need to have DSA awareness in
anything but the "provider" driver which in this case is a PHY driver
because it sits on the MDIO bus (see below on that topic) and things
tend to "flow" a bit more naturally one you do that.

> 
> A much better solution might be be to disconnect mdio from phy, ie to
> create a new
> mdio bus framework, as then use this framework for anything connected to
> an mdio bus.

So essentially end-up creating a separate class of MDIO addressable
devices which are switches? I guess we could try to do that. We would
still have to update existing Ethernet MAC drivers which speak phylib to
know what to do with their CPU port and set correct link parameters,
would we want to create a special PHY drivers for these, just for the
CPU port?

> 
> Does this make any sense, or am I completely off track ?

I think this is very valid, my main point behind this entire patch
series is to divorce from the special "dsa" platform_device for common
cases: MDIO or MMIO connected switches to a SoC, because it is
convoluted and prevents a lot of things from being done: module
unloading, proper device reference (and parenting), need for "out of
band" link information to be provided to unmodified Ethernet drivers etc...
-- 
Florian
