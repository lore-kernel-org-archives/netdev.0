From: Ian Molton <ian.molton@codethink.co.uk>
Subject: Re: [PATCH v3 0/7] mv643xx.c: Add basic device tree support.
Date: Mon, 13 Aug 2012 11:00:32 +0100
Message-ID: <5028D040.60604@codethink.co.uk>
References: <1344350092-24050-1-git-send-email-ian.molton@codethink.co.uk> <201208091143.32972.arnd@arndb.de> <5023D577.8090001@codethink.co.uk> <201208101049.57586.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	ben.dooks@codethink.co.uk, dale@farnsworth.org,
	linuxppc-dev@lists.ozlabs.org, David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([37.128.190.40]:45304 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601Ab2HMKAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2012 06:00:47 -0400
In-Reply-To: <201208101049.57586.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/08/12 11:49, Arnd Bergmann wrote:
> On Thursday 09 August 2012, Ian Molton wrote:
>>>  The driver
>>> already knows all those offsets and they are always the same
>>> for all variants of mv643xx, right?
>> Yes, but its not clean. And no amount of refactoring is
>> really going to make a nice driver that also fits the ancient
>> (and badly thought out) OF bindings.
> In what way is it badly though out, or not clean? The use of
> underscores in the properties, and the way that the sram
> is configured is problematic, I agree. But The way that
> the three ports are addressed and how the PHY is found
> seems quite clever.

It forces one to load the MDIO driver first, because it maps ALL the
registers for both itself and all the ports, and the MDIO driver has no
way of knowing how many ethernet blocks are present (I have a device
here with two, and another with four). Thats anywhere from 1 to 12
ports, split across 1 to 4 address ranges, and theres a big gap in the
address range between controllers 0,1 and 2,3. *ALL* the devices on the
board are sharing ethernet block 0's MDIO bus. By pure luck it happens
to work, because the blocks 2,3 have an alias of the MDIO registers from
blocks 0,1.

Having the MDIO driver map the ethernet drivers memory is a terrible
solution, IMO. Ethernet drivers should map their own memory, and that
introduces the n-ports-per-block problem, because their address ranges
overlap.

I think the best solution is to make each ethernet block register 3 ports.

the PPC code can simply generate different fixups so that instead of
creating 3 devices, it creates one, with three ports.

>> If we have to break things, we can at least go for a nice
>> clean design, surely?
>>
>> The ports arent really child devices of the MAC. The MAC
>> just has 3 ports.
> I don't see the difference between those two things.

The ports are at best 'pseudodevices'. Real devices have registers of
their own.

>> We're going to have to maintain a legacy
>> platform_device -> DT bindings hack somewhere anyway,
>> at least until the remaining other users of the driver
>> convert to D-T.
> I don't understand why you describe the method used in
> powerpc as a hack. It was the normal way to introduce
> DT support for platform devices back when it was implemented.

Just because its normal doesn't mean its not a hack :)

> It also had the advantage of not requiring any modifications
> to the generic driver, because it was shared between one
> architecture using DT (powerpc) and one that didn't (ARM).

It /did/ spawn a pretty hideous driver, though...

-Ian
