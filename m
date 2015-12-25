From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 00/28] DSA: Restructure probing
Date: Fri, 25 Dec 2015 12:31:23 +0100
Message-ID: <20151225113123.GA7422@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
 <567B07CB.5080308@gmail.com>
 <20151223223303.GD25485@lunn.ch>
 <567B2A89.7000803@gmail.com>
 <20151224125812.GB29139@lunn.ch>
 <567CA01F.6010604@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: narmstrong@baylibre.com, vivien.didelot@savoirfairelinux.com,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49549 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204AbbLYLb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Dec 2015 06:31:26 -0500
Content-Disposition: inline
In-Reply-To: <567CA01F.6010604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > One of my aims is to abstract away the MDIO bus from DSA. How you talk
> > to the switch is a switch device property. SF2 has a different way to
> > talk to the switch, memory mapped IO, etc.
> 
> I appreciate you trying to see my point of view and mentioning the
> driver that I care about, but I am not just after SF2 here, just any
> kind of switch in general: PCIe, SPI, I2C, GPIO, MDIO, MMIO is precisely
> what I would like to solve instead of narrow MDIO and distributed case
> that DSA currently deals with, and MMIO with some help from the of_*
> routines which do not need any kind of bus probing and struct device
> creation (most often).

And this is achieved with the new structure. How you access the switch
is part of the switch device binding, be it an MDIO bus/addr, an MMIO
reg property, or an i2c client, etc. The switch driver registers a set
of ops which are neutral to the switch access mechanism.

In the DSA node, the mdio bus is now only required when using
backwards compatibility. The reg property is a bit odd, since it is
used for linking DSA ports together. So currently it is kept, but only
one of the two fields is used. We could in a later patchset change
this, since there are currently no in kernel devices with multiple
switches, so we don't have to worry about breaking the binding.

> > Anyway, who do you think the device tree binding will look? Maybe take
> > the .dts file in patches 2 and 20 to build an example?
> 
> The binding would look pretty much the same as what the current DSA and
> your proposed binding look like, except that instead of encoding the
> MDIO address *and* the switch index in tree in the same "reg" properties
> (which was wrong along, but I did not really knew it back in 2009 or
> so), the two would be different properties.

Agreed, as explained above.
 
> When you parse the Device Tree you can determine what is the position of
> the switch in the switch tree by looking at its ports sub-nodes and see
> if they have a "link" property which links them to another device,
> eventually, in case where there is not a one to one, but one to many
> connection, an additional property can help you figure out how to
> flatten things out.
> 
> So in practical terms, this could wind up looking like this:
> 
> mdio_bus@deadbeef {
> 	compatible = "acme,mdiobus";
> 	..
> 	switch0@0 {
> 		compatible = "marvell,mv88e6131";
> 		reg = <0>;
> 		dsa,addr = <1>;

This is not sufficient. It does not tell you which DSA cluster this
switch belongs to.

> 
> 		switch0port5: port@5 {
> 				reg = <5>;
> 				label = "dsa";
> 				link = <&switch1port9>;
> 			};
> 		};
> 	};
> };

Just for clarification, where are the cpu ports and normal user ports?
Here as well?

Making MDIO controlled switches hang of MDIO can be done, but it does
require some bigger changes to the mdio code. I will need to look at
this again, but i think it starts in of_mdiobus_register_phy() which
needs to look a the compatibility field, and do something different to
phy_device_register(). mdio_unregister() will also need some work,
since it only expects phy devices on the mdio bus.

	Andrew
