From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 2/2] phy: fixed-phy: Allow DT description of
 an MDIO bus and PHYs.
Date: Sat, 12 Mar 2016 01:05:28 +0100
Message-ID: <20160312000528.GD23969@lunn.ch>
References: <1457737726-23907-1-git-send-email-andrew@lunn.ch>
 <1457737726-23907-3-git-send-email-andrew@lunn.ch>
 <56E35530.6000009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55280 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720AbcCLAFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 19:05:30 -0500
Content-Disposition: inline
In-Reply-To: <56E35530.6000009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +Child nodes represent PHYs on this mdio bus. Standard properties for
> > +fixed links, 'speed', 'full-duplex', 'pause', 'asym-pause',
> > +'link-gpios', as defined above are used. Additionally a 'reg' property
> > +is required for the address of the PHY on the bus. This should be of
> > +value 0 to 31.
> 
> This is a virtual bus, the only limitation is because we re-use to the
> maximum permission extent the real MDIO bus code, and this is putting a
> SW constraint on something that does not have one here.

True. I was too lazy to audit the phy and mdio code to see if it
actually allows phy_addr >= 32. And it is easy to instantiate another
bus if you need it.
 
> > +
> > +Example
> > +-------
> > +
> > +mdio {
> > +	compatible = "linux,mdio-fixed-phy";
> > +	#address-cells = <1>;
> > +	#size-cells = <0>;
> > +
> > +	phy0: phy@0 {
> > +		reg = <0>;
> > +		speed = <1000>;
> > +		pause;
> > +		link-gpios = <&gpio0 12 GPIO_ACTIVE_HIGH>;
> > +	};
> > +
> > +	phy1: phy@8 {
> > +		reg = <8>;
> > +		speed = <100>;
> > +		full-duplex;
> > +	};
> 
> The 'fixed-link' property, although it suffers from one basic issue
> which is that it is placed on the consumer of it (e.g: an Ethernet MAC
> Device Tree node) while being a two-headed snake (you actually describe
> a data-pipe with a fixed-link) is not quite perfect, but this does not
> seem to look any better.

It is actually just the same. Not worse, not better.

I see the real benefit in the drivers. They get fixed-phy for
free. Cleanup on release just works, which most drivers don't even do
now, so leak a fixed phy every time they are unloaded. DSA has some
messy code, which has had a number of bugs, handling fixed phys. By
adding this extra code, which i hope is reasonably simple to
understand and review, we make the MAC drivers a lot simpler and less
error prone.
 
> One thing that Thomas solved nicely was avoid the need for allocating an
> address on the virtual MDIO bus, but this is coming back here, which
> does not seem needed except for correctness wrt. how real MDIO buses.

Actually Thomas's code is broken. Fixed phy addresses are allocated
incrementally. When a fixed phy is released, its address is not
re-used. So as soon as you have gone through 32 alloc/free cycles, all
further allocs fail. This is however fixable.

	Andrew
