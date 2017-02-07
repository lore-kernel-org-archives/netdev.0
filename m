From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [RFC net-next] net: phy: Allow splitting MDIO bus/device support
 from PHYs
Date: Tue, 7 Feb 2017 00:19:27 +0000
Message-ID: <20170207001927.GO27312@n2100.armlinux.org.uk>
References: <20170131032931.1494-1-f.fainelli@gmail.com>
 <34f35da1-086a-0809-b962-7d0dbcf9df8d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:52036 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751447AbdBGATi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 19:19:38 -0500
Content-Disposition: inline
In-Reply-To: <34f35da1-086a-0809-b962-7d0dbcf9df8d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 06, 2017 at 04:01:27PM -0800, Florian Fainelli wrote:
> On 01/30/2017 07:29 PM, Florian Fainelli wrote:
> > Introduce a new configuration symbol: MDIO_DEVICE which allows building
> > the MDIO devices and bus code, without pulling in the entire Ethernet
> > PHY library and devices code.
> > 
> > PHYLIB nows select MDIO_DEVICE and the relevant Makefile files are
> > updated to reflect that.
> > 
> > Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Andrew, Russell, does that seem sensible to you, shall I re-submit this
> as a proper patch?

I think the only comment I have is that I'd recommend that mdio_bus
and mdio_device end up as one module rather than two for these reasons:

1. they're each relatively small on their own
2. their functionality is tightly related
3. I wonder about the safety of having mdio_device_release() in a
   separate module from the bus_type stuff.

as far as (3) goes, there isn't a good way to ensure that the last
device has been released, and bus_type's (even though they normally
end up as static data) are refcounted objects just like devices, so
I wonder whether allowing driver model bus stuff to be removable is
a good idea.

To that end, I'd add a module_init() for mdio_bus_init() but remove
mdio_bus_exit() entirely, which should mean that the module loader
considers the module non-removable.

Lastly, as this is becoming (a) separate module(s), MODULE_LICENSE()
as an absolute minimum will be required.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
