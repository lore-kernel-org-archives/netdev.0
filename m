From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH 2/5] net: phy: hook up clause 45 autonegotiation restart
Date: Thu, 1 Jun 2017 13:51:32 +0100
Message-ID: <20170601125132.GY22219@n2100.armlinux.org.uk>
References: <20170601102327.GF27796@n2100.armlinux.org.uk>
 <E1dGNJM-00043g-KJ@rmk-PC.armlinux.org.uk>
 <20170601122350.GA9282@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:54742 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751078AbdFAMvi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 08:51:38 -0400
Content-Disposition: inline
In-Reply-To: <20170601122350.GA9282@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 01, 2017 at 02:23:50PM +0200, Andrew Lunn wrote:
> On Thu, Jun 01, 2017 at 11:26:36AM +0100, Russell King wrote:
> > genphy_restart_aneg() can only restart autonegotiation on clause 22
> > PHYs.  Add a phy_restart_aneg() function which selects between the
> > clause 22 and clause 45 restart functionality depending on the PHY
> > type.
> > 
> > Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
> > ---
> >  drivers/net/phy/phy.c | 23 +++++++++++++++++++++--
> >  include/linux/phy.h   |  1 +
> >  2 files changed, 22 insertions(+), 2 deletions(-)
> > 
> > diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> > index 82ab8fb82587..25b24789a409 100644
> > --- a/drivers/net/phy/phy.c
> > +++ b/drivers/net/phy/phy.c
> > @@ -149,6 +149,25 @@ static int phy_config_interrupt(struct phy_device *phydev, u32 interrupts)
> >  	return 0;
> >  }
> >  
> > +/**
> > + * phy_restart_aneg - restart auto-negotiation
> > + * @phydev: target phy_device struct
> > + *
> > + * Restart the autonegotiation on @phydev.  Returns >= 0 on success or
> > + * negative errno on error.
> > + */
> > +int phy_restart_aneg(struct phy_device *phydev)
> > +{
> > +	int ret;
> > +
> > +	if (phydev->is_c45)
> > +		ret = genphy_c45_restart_aneg(phydev);
> > +	else
> > +		ret = genphy_restart_aneg(phydev);
> > +
> > +	return ret;
> > +}
> > +EXPORT_SYMBOL_GPL(phy_restart_aneg);
> 
> Hi Russell
> 
> Isn't the same sort of thing needed in phy_aneg_done()?

No, because phy_aneg_done() already has hooks in it which PHY drivers
can use to override the default C22 implementation.

I did toy with providing a similar conditional in phy_aneg_done(), but
decided it was better to use the existing hooks where present, rather
than needlessly adding additional code.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
