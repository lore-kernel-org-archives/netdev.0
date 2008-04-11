From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 5/6] tc35815: Use generic PHY layer
Date: Sat, 12 Apr 2008 00:40:58 +0900 (JST)
Message-ID: <20080412.004058.88699680.anemo@mba.ocn.ne.jp>
References: <20080411.002523.18305938.anemo@mba.ocn.ne.jp>
	<4CD8B148-87DF-42C6-8A04-A6501109C1F2@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, jeff@garzik.org, netdev@vger.kernel.org
To: afleming@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:50164 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760637AbYDKPkI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2008 11:40:08 -0400
In-Reply-To: <4CD8B148-87DF-42C6-8A04-A6501109C1F2@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Apr 2008 14:58:28 -0500, Andy Fleming <afleming@freescale.com> wrote:
> Excellent, just a few quick (and hopefully easy to resolve) comments:

Thank you for review.

> > +	/* find the first phy */
> > +	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
> > +		if (lp->mii_bus.phy_map[phy_addr]) {
> > +			phydev = lp->mii_bus.phy_map[phy_addr];
> > +			break;
> > +		}
> > +	}
> 
> I'm always amazed that this works.  I have a board that has 4 PHYs for  
> two different ethernet controllers, and they are laid out thus:
> 
> 1: UCC2
> 2: eTSEC1
> 3: eTSEC2
> 7: UCC1
> 
> This isn't really a criticism, since this controller may very well  
> guarantee there's only one PHY on the bus, or that you only care about  
> the first one.  I'm just putting that out there to feel out how people  
> solve

Though I had never seen multple PHYs connected to this controller, it
might be better to check it instead of silently ignoreing others.
I'll add explicitly check.

> > +	/* attach the mac to the phy */
> > +	phydev = phy_connect(dev, phydev->dev.bus_id,
> > +			     &tc_handle_link_change, 0,
> > +			     lp->boardtype == TC35815_TX4939 ?
> > +			     PHY_INTERFACE_MODE_RMII : PHY_INTERFACE_MODE_MII);
> 
> Generally, it's preferred for boards to pass in the interface to the  
> driver, rather than have the ethernet driver have an awareness of what  
> boards it runs on.  I'm not familiar with this hardware, but it makes  
> porting to new boards much easier.

Well, the 'boardtype' variable was wrongly named.  It is actually
'chiptype'.  The board designeer cannot select MII/RMII.  So I'll
change the name of the variable.

> > +	/* mask with MAC supported features */
> > +	phydev->supported &= PHY_BASIC_FEATURES;
> > +	if (options.speed == 10)
> > +		phydev->supported &=
> > +			~(SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full);
> > +	else if (options.speed == 100)
> > +		phydev->supported &=
> > +			~(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full);
> > +	if (options.duplex == 1)
> > +		phydev->supported &=
> > +			~(SUPPORTED_10baseT_Full | SUPPORTED_100baseT_Full);
> > +	else if (options.duplex == 2)
> > +		phydev->supported &=
> > +			~(SUPPORTED_10baseT_Half | SUPPORTED_100baseT_Half);
> 
> Your controller only supports one speed or the other?  This is also a  
> little confusing to read.  It might be clearer if you build up a  
> bitmask of the supported options, and then mask phydev->supported.   
> That's just personal preference, though.

The purpose of original code is force speed/duplex setting by module
options, if specified.  Usually both 10/100 and half/full are
supported.  I'll try to make the code more readable.

> > +	lp->mii_bus.name = "tc35815_mii_bus",
> > +	lp->mii_bus.read = tc_mdio_read,
> > +	lp->mii_bus.write = tc_mdio_write,
> > +	lp->mii_bus.id = lp->pci_dev->devfn,
> 
> I just submitted a patch to change mii_bus.id to a char [].  It's an  
> easy fix:
> 
> snprintf(lp->mii_bus.id, PHY_BUS_ID_SIZE, "%x", lp->pci_dev->devfn);
> 
> Or you can come up with a string on your own.  I haven't looked  
> carefully to make sure you aren't using the number in some way.

OK, if your patch was merged to mainline or upstream tree, I'll adjust
for it.  And I noticed pci_dev->devfn seems not enough for mii_bus.id,
while we can have multiple PCI busses.  I'll use both pci_dev->bus->id
and pci_dev->devfn.

> > -	if (lp->mii_id[0] == 0x0016 && (lp->mii_id[1] & 0xfc00) == 0xf800) {
> > +	if (lp->phy_dev && (lp->phy_dev->phy_id & 0xfffffc00) !=  
> > 0x0016f800) {
> > 		/* Resetting PHY cause problem on some chip... (SEEQ 80221) */
> > -		do_phy_reset = 0;
> > -	}
> > -	if (do_phy_reset) {
> > 		int timeout;
> > -		tc_mdio_write(dev, pid, MII_BMCR, BMCR_RESET);
> > +
> > +		phy_write(lp->phy_dev, MII_BMCR, BMCR_RESET);
> > 		timeout = 100;
> > 		while (--timeout) {
> > -			if (!(tc_mdio_read(dev, pid, MII_BMCR) & BMCR_RESET))
> > +			if (!(phy_read(lp->phy_dev, MII_BMCR) & BMCR_RESET))
> > 				break;
> > 			udelay(1);
> > 		}
> 
> Hm.  We should probably come up with a way to handle this inside the  
> PHY driver, since the goal of the PHY Lib is to avoid having to know  
> what type of PHY you are connected to.

Agreed.  Actually, this hack for SEEQ PHY seems not needed.  I tried
today and works fine without this hack.  I'll remove it.

> > #ifdef WORKAROUND_LOSTCAR
> > 	/* WORKAROUND: ignore LostCrS in full duplex operation */
> > -	if ((lp->timer_state != asleep && lp->timer_state != lcheck)
> > -	    || lp->fullduplex)
> > +	if (!(lp->phy_dev->state == PHY_RUNNING ||
> > +	      lp->phy_dev->state == PHY_CHANGELINK) ||
> > +	    lp->duplex == DUPLEX_FULL)
> > 		status &= ~Tx_NCarr;
> 
> Are you sure those states are right?  I'm just asking because it seems  
> like an odd use of the phydev state.

Well, I think again. Just checking lp->link would be enough.  Thanks.

I will send an updated patch soon.

---
Atsushi Nemoto
