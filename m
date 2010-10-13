From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: Question about PHY-less board and "fixed_phy"
Date: Wed, 13 Oct 2010 12:06:18 -0700
Message-ID: <4CB6032A.8020908@caviumnetworks.com>
References: <i94oag$epv$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Grant Edwards <grant.b.edwards@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:1124 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484Ab0JMTGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 15:06:24 -0400
In-Reply-To: <i94oag$epv$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2010 09:55 AM, Grant Edwards wrote:
>
> I'm working with an Atmel ARM9 board (macb driver), that doesn't have
> a PHY.
>
> The MAC is connected to a switch via MII.  That MII link is hard-wired
> to be 100M full-duplex.
>
>> From what I've been able to google, the "fixed_phy" driver is intended
> for this situation.  But from looking at the fixed.c source code it
> appears to provide an emulated MDIO bus.
>
> I don't want an emulated MDIO bus.
>
> I have a real, working MDIO bus.
>
> What I don't have is a PHY.
>
> The switch presents a bunch of logical slave devices (23, IIRC)
> attached to the MDIO bus, and I need use the MDIO bus to access those
> "devices" (mainly from user-space via ioctl() calls).  If I use the
> fixed_phy driver, it appears that it will hide the real MDIO bus and
> replace it with a fake one that's connected to a fake set of PHY
> registers.  That means I won't be able to access the the registers in
> the switch to which my MAC is connected.
>
> The ethernet/phy architecture seems to be based on several assumptions
> that aren't true in my case:
>
>   1) Every MAC is connected to a PHY.

As long as you handle calling netif_carrier_{on,off}() and some of the 
ndo_do_ioctl commands, I don't think you need a PHY.

>
>   2) An MDIO bus is a point-to-point link between the MAC and the PHY.

This I don't think is the case.  See phy_connect() for example.  It 
certianly allows for multiple PHYs per bus.

We have a SOC device (Octeon) that has many PHYs on a single MDIO bus, 
and have a separate MDIO bus driver (mdio-octeon.c) that is shared 
between all the Ethernet devices/drivers.

>
>   3) The MDIO bus belongs to the PHY.
>

??, The mdio bus lock is taken for some operations, but how does it 
'belong to' the PHY?

>   4) It's OK to go out and read arbitrary registers from every device
>      on the MDIO bus when that bus is registered using mdiobus_register().
>

You can set the struct mii_bus phy_mask element to prevent probing of 
specific addresses.



> [Hmm, #4 may be true in my case, but it seems like a dangerous assumption.]
>
> Anyway, I'm confused on how the MAC/PHY architecture is meant to deal
> with the case where there is no PHY, but there are real devices
> attached to a real MDIO bus which needs to be accessed both from the
> Ethernet driver and from userspace using the normal user-space ioctl()
> call.
>
> Do I need to write my own "fixed_phy" driver that presents a virtual
> PHY without putting a fake MDIO bus in place?
>
> How _do_ you present a virtual PHY without faking an MDIO bus?
>
> Do I need _two_ MDIO buses, the real one that is used to communicate
> with the switch chip and a fake one that's used to talk to a fake PHY?
> If so, how do I associate two MDIO buses with a single Ethernet
> interface?
>
> How do you register an mdio bus without having every device on the bus
> accessed?
>
> Can anybody loan me a clue?
>
> Another thing I don't understand is that it looks to me like the
> ioctl() to access devices on the mdio bus is handled by the PHY driver
> when it should be handled by the Ethernet driver: the MDIO bus belongs
> to the MAC, not the PHY.
>
> The PHY driver apparently ignores the device ID specified by the user
> and forces the device ID to that of the PHY, thus cutting of access to
> any other devices on the bus.  [I've worked around that by kludging
> the Ethernet driver's mdio_read/write routines so that I can specify
> the device ID by placing it in the upper 8 bits of the 16-bit register
> number (which is left unchanged as it passes through the PHY driver).]
>
> This doesn't make sense to me.  Why provide a device ID in the ioctl()
> API, and then overwrite it as the request passes through the PHY
> driver to the Ethernet driver.  Why are ioctl() MDIO register
> read/write requests that are done on an Ethernet interface passed
> through the PHY driver?
>
> I've read and re-read the phy.txt file under Documentation, and I've
> looked at the fixed_phy source and sources of drivers where it is
> used, but I'm still in the dark...
>

