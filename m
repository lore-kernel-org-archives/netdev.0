From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Support for non-HW interrupt devices
Date: Thu, 07 Jan 2016 18:08:27 -0800
Message-ID: <568F1A1B.1040808@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D40493795@CHN-SV-EXMX02.mchp-main.com> <20160108004238.GD4389@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>, Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36240 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753721AbcAHCJC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 21:09:02 -0500
Received: by mail-pf0-f171.google.com with SMTP id n128so2196028pfn.3
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 18:09:01 -0800 (PST)
In-Reply-To: <20160108004238.GD4389@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/16 16:42, Andrew Lunn wrote:
> On Thu, Jan 07, 2016 at 11:14:19PM +0000, Woojung.Huh@microchip.com wrote:
>> This patch introduces PHY_PSEUDO_INTERRUPT and routines to
>> handle pseudo (not-real-hardware) interrupt such as USB interrupt pipe for
>> USB-to-Ethernet device.
>>
>> Unless having real hardware interrupt handler registered by request_irq(),
>> phy_state_machine() can't avoid calling phy_read_status()
>> to monitor link changes. This especially prevents USB-to-Ethernet device
>> from going to auto suspend to save power.

Well, this surely is something that can be fixed.

> 
> Hi Woojung
> 
> Do you have an example PHY driver making use of this. At the moment i
> don't see how it works.

I would assume that the changes would be in the Ethernet portion of the
driver and maybe also in the PHY driver to ack/configure interrupts. As
Andrew indicated, you probably want to post the full patch series to
show how this will be used.

> 
> There is possibly a cleaner way to do this. I've some unpublished work
> where i added interrupt support for the Marvell switches. These
> switches can have embedded PHYs, and the interrupts from these PHYs go
> into the switchers interrupt controller. From that one line comes out
> and is connected to a GPIO line. To support this, i've implemented a
> Linux chained interrupt driver within the switch driver. PHY
> interrupts then become normal Linux interrupts which the PHY library
> can make use of.

That seems like an elegant way to solve the problem, without adding code
in the PHY library that does not use the interrupt API, but it also
seems to me like there are some other potential issues associated with
doing that:

- if a Switch/Ethernet controller has several interrupt bits
corresponding to a built-in PHY (link UP, DOWN, Energy detect), PHYLIB
still requests only one interrupt, and expects it to be able to read the
interrupt cause and do something with it, if you interface an interrupt
controller in the middle, that might go against being able to do that?

- does that scheme work well with Device Tree if you dynamically
register an interrupt domain? of_mdiobus_register_phy() will try to
parse a standard "interrupts" property for the PHY device, and fill in
the mii_bus->irq for that PHY address, sure you could still override
that later with an interrupt domain, but that sounds a little error probe

- this adds a bit of complexity to an Ethernet/Switch driver to get PHY
devices to be probed successfully, since you now need to register an
interrupt controller driver/domain, and do that before your MDIO bus
driver is probed and your Ethernet MAC issues a phy_connect(), not
impossible to get right, just a bit more complex

Do not get me wrong, I do believe using the existing interrupt
abstraction is the right answer, I am just wondering how we should be
dealing with that at the PHY library level, in the case where there are
different interrupt sources available (the most common being link
UP/DOWN events) and how nice would that play with different drivers out
there.

> 
> So, maybe your USB driver should implemented a Linux interrupt
> controller. USB interrupt pipe transactions result in the interrupt
> controller triggering the normal Linux interrupt mechanism, and so no
> need to change PHYLIB.

Right, that seems like a potential option here. phy_mac_interrupt() was
intended to be used for that kind of situation where the interrupt for
the PHY is outside of the control of the PHY driver, but unfortunately I
think it still makes the PHY library poll the PHY, which should
definitively be fixed.
-- 
Florian
