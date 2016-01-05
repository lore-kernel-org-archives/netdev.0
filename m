From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 00/24] Support MDIO devices
Date: Tue, 5 Jan 2016 03:57:53 +0100
Message-ID: <20160105025753.GH7485@lunn.ch>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
 <568B28BB.60804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35910 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751925AbcAEC5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 21:57:54 -0500
Content-Disposition: inline
In-Reply-To: <568B28BB.60804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> - what kind of API do we need to offer to Ethernet MAC driver? Would
> attach/detach and maybe adjust_link be good enough?

I was not going to offer it any! At least not at the MDIO layer.

Maybe i have DSA too much in mind. But all we need for DSA is probe
and remove. When the MDIO device is probed, based on DT information,
it registers its DSA OPs with the DSA framework. When the device is
removed, it unregisters its DSA ops. Nothing else is needed.

Also, don't forget you can have an MDIO bus without an MII bus. The
classic examples are using a couple of gpio lines to bit bang, or
using a mux to give you multiple MDIO busses from one real MDIO bus
and some gpio pins.
 
> - should we consider modeling a MDIO connected switch as a MDIO device
> (responding at the pseudo PHY address on the MDIO bus) which then
> eventually creates a child MDIO bus and per-port individual PHY devices?

Sort of. The Marvell switch actually take up quite a few addresses on
the MDIO bus, not just the one listed in the DT. By convention, if the
address is zero, the switch is assumed to be in single chip mode, and
will respond to 10 or more different addresses. Depending on the
switch model, some of those addresses are actually phys, and should be
listed in DT as phys.

If the address is not zero, the switch is in multi-chip mode, and it
will respond to registers 0x00 and 0x01 on that one address. These two
registers give an indirect access to all the other registers.
 
> - for MDIO switches with a data-path to an Ethernet MAC (which is
> probably 99% of the cases, are there some which do not have such a thing
> and are still managed switches?), how much of the existing PHY device
> properties (speed, duplex, interface, pause capability) should we think
> about moving to the common MDIO device structure? Then this kind of
> circles back to the first question about the Ethernet MAC interface API [1]

To me, MII and MDIO are separate busses and should not be mixed
together. Think about the case of a switch with two MII busses for
greater frame throughput, but only one MDIO bus for management?  Some
of the Marvell switches can also be manged using messages in Ethernet
frames. So you could even have a switch with only MII and no MDIO!

What also comes to play here is Russell Kings phylink code.

We have this 20+ part patchset. This gives us enough we can look at
integrating the 20+ part DSA probing patchset and then look at RMKs
20+ patchset. That alone should keep us busy for a while without
needed to add yet more.

       Andrew
