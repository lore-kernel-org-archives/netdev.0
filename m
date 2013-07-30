From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [RFC PATCH 1/3] of: provide a binding for the 'fixed-link'
 property
Date: Tue, 30 Jul 2013 11:16:04 +0200
Message-ID: <20130730111604.76fd5b6e@skate>
References: <1373902450-11857-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1373902450-11857-2-git-send-email-thomas.petazzoni@free-electrons.com>
	<20130723112259.GE4833@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>,
	"rob.herring@calxeda.com" <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:39959 "EHLO
	mail.free-electrons.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758365Ab3G3JQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 05:16:09 -0400
In-Reply-To: <20130723112259.GE4833@e106331-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Mark Rutland,

On Tue, 23 Jul 2013 12:22:59 +0100, Mark Rutland wrote:

> > +Some Ethernet MACs have a "fixed link", and are not connected to a
> > +normal MDIO-managed PHY device. For those situations, a Device Tree
> > +binding allows to describe a "fixed link".
> 
> Are partictular MACs fixed link, or can some either be either fixed link
> or wired to an MDIO-managed PHY? i.e. can we assume a given MAC is
> fixed-link from its compatible string?

No, you can't. The case that I have is that the mvneta Ethernet MAC
(of Marvell 370/XP SOCs) is sometimes used with a MDIO-managed PHY, and
sometimes used with a switch that isn't manageable at all and should be
considered as a fixed link.

So no, the compatible string of the Ethernet MAC cannot be used to
determine whether we're wired fixed link or to a classical MDIO-managed
PHY.

> > +Such a fixed link situation is described within an Ethernet device
> > +Device Tree node using a 'fixed-link' property, composed of 5
> > +elements:
> 
> I'm not sure grouping these values together is the best way of handling
> this. It's rather opaque, and inflexible for future extension.

That's the DT binding that has been used by PowerPC platforms since
several years, and I've simply re-used it. See 'git grep fixed-link
arch/powerpc/boot/dts'.

I have nothing against creating another DT binding, but for a start, I
thought using existing bindings would be the best idea.

> > + 1. A fake PHY ID, which must be unique accross all fixed-link PHYs in
> > +    the system.
> 
> Is there any reason this couldn't be allocated dynamically within the
> kernel as needed? I don't see why an arbitrary unique value should be a
> dt binding requirement; it seems like a leak of Linux implementation
> details.

As I pointed out in my reply to Grant, this value is used both as the
PHY address on the fake fixed MDIO bus, and as the PHY identifier as
reported by MII registers PHYS_ID1 and PHYS_ID2. If we can get assigned
a proper PHY identifier that is used statically by the driver (it
doesn't have to be different per fixed PHY instance), then we can
allocate the PHY address dynamically. It requires a little bit of API
changes but that's certainly doable. See my reply to Grant for a
proposal about this.

> > + 2. The duplex (1 for full-duplex, 0 for half-duplex)
> 
> Will this change for a given MAC?
> 
> Could we not have a boolean property for each of these, and require one
> to be present?
> 
> Possibly fixed-link-full-duplex / fix-link-half-duplex?
> 
> > + 3. The speed (10, 100, 1000)
> 
> fixed-link-speed?
> 
> > + 4. The pause setting (1 for enabled, 0 for disabled)
> > + 5. The asym pause setting (1 for enabled, 0 for disabled)
> 
> Boolean properties for both of these?

As Florian already answered, he already proposed something like this in
the past, and it was rejected because a fixed PHY is not a piece of
hardware and should therefore not be represented in the Device Tree.
However, the fact that the MAC is not connected to a MDIO-manageable
PHY but to some fixed-link thing is a property of the MAC hardware
layout, and can therefore be expressed as a property of the MAC
hardware.

See the thread that starts at
http://article.gmane.org/gmane.linux.network/275771, and specifically
Grant answers to Florian suggestions of having DT nodes to represent
fixed PHY: http://article.gmane.org/gmane.linux.network/276208. Grant's
answer was:

"""
I think this discussion is going in the wrong direction. The concept
of a dummy phy is really a Linux kernel internal detail. Creating some
kind of dummy MDIO bus node does not describe the hardware. There is
already support in the kernel for Ethernet MACs connected directly to
a switch or other device. It is far better to describe how the MAC
needs to be configured than to invent a non-existent phy. Search for
"fixed-link" in the kernel tree to see how it is used.
"""

Best regards,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
