From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCHv3 5/5] [NET] dsa: add support for the Marvell 88E6060 switch chip
Date: Wed, 8 Oct 2008 10:49:03 +0200
Message-ID: <20081008084903.GE23326@xi.wantstofly.org>
References: <20081007234622.GF23200@xi.wantstofly.org> <Pine.LNX.4.64.0810071725300.4731@k.domain.actdsltmp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Trent Piepho <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:47389 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257AbYJHItI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 04:49:08 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0810071725300.4731@k.domain.actdsltmp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 05:45:41PM -0700, Trent Piepho wrote:

> > +static int reg_read(struct dsa_switch *ds, int addr, int reg)
> > +{
> > +	return mdiobus_read(ds->master_mii_bus, addr, reg);
> > +}
> 
> Instead of all the code to add the mdio buses to the device tree and exporting
> mdiobus_read(), could you have just added the switch chip as a "phy" on the
> mdio bus?  Then used phy_read/write() on it?  I know it's not a phy, but you
> don't need to use the phy state machine and so on.

At least the switches that are supported now don't take up only
one MII bus address, but use all 32, so I wouldn't be able to use
phy_{read,write}() on them.

And the first 5-10 of those addresses generally look like normal PHYs,
but you wouldn't want to attach PHY drivers to them directly (since you
need to wrap accesses to the PHYs on some switches to disable the
internal PHY polling that the switch does first), which would complicate
autoprobing quite a bit.


> Freescale gianfar MACs configure the serdes for SGMII using a virtual
> "TBI" device on the MDIO bus.  Supposedly Andy has patch that adds
> them as devices on the MDIO bus, isn't of the gianfar specific MDIO
> back-door they currently use.

I think with gianfar, the MDIO bus drivers are separate platform
devices, and you can then get at the struct mii_bus * by taking the
platform device private data pointer -- which is a bit of an ugly way
of doing it, IMHO.


> > +#define REG_READ(addr, reg)					\
> > +	({							\
> > +		int __ret;					\
> > +								\
> > +		__ret = reg_read(ds, addr, reg);		\
> > +		if (__ret < 0)					\
> > +			return __ret;				\
> > +		__ret;						\
> > +	})
> 
> Macro with a hidden use of a local ('ds') and a hidden return?  The
> former is discouraged (but can sure save a lot of typing) but the
> latter seems like it's just begging to cause a missing unlock or
> free on an error path.

Yeah, well, that was intentional (Nicolas Pitre suggested it, and I
figured it made sense to do it).  I think there are a couple more places
in the tree that do this, and it very much increases readability because
you no longer need to check the return value explicitly every single
time you do an MII access.
