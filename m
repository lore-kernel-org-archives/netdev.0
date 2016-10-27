From: Jon Mason <jon.mason@broadcom.com>
Subject: Re: [PATCH 1/5] net: phy: broadcom: Add BCM54810 phy entry
Date: Thu, 27 Oct 2016 18:43:44 -0400
Message-ID: <20161027224341.GB25693@broadcom.com>
References: <1477510561-17035-1-git-send-email-jon.mason@broadcom.com>
 <1477510561-17035-2-git-send-email-jon.mason@broadcom.com>
 <20161027091505.GB12841@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, rafal@milecki.pl,
        Vikas Soni <vsoni@broadcom.com>,
        linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161027091505.GB12841@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 27, 2016 at 11:15:05AM +0200, Andrew Lunn wrote:
> On Wed, Oct 26, 2016 at 03:35:57PM -0400, Jon Mason wrote:
> > From: Vikas Soni <vsoni@broadcom.com>
> > 
> > Add BCM54810 phy entry
> 
> Hi Jon, Vikis
> 
> The subject line is a bit misleading. It does more than add a PHY ID
> entry.

All of the parts are related to adding the BCM54810 Phy, but I agree it
could be more verbose about what is happening.

> > Signed-off-by: Vikas Soni <vsoni@broadcom.com>
> > Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> > ---
> >  drivers/net/phy/Kconfig    |  2 +-
> >  drivers/net/phy/broadcom.c | 65 ++++++++++++++++++++++++++++++++++++++++++++++
> >  include/linux/brcmphy.h    |  7 +++++
> >  3 files changed, 73 insertions(+), 1 deletion(-)
> > 
> > diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> > index 45f68ea..31967ca 100644
> > --- a/drivers/net/phy/Kconfig
> > +++ b/drivers/net/phy/Kconfig
> > @@ -217,7 +217,7 @@ config BROADCOM_PHY
> >  	select BCM_NET_PHYLIB
> >  	---help---
> >  	  Currently supports the BCM5411, BCM5421, BCM5461, BCM54616S, BCM5464,
> > -	  BCM5481 and BCM5482 PHYs.
> > +	  BCM5481, BCM54810 and BCM5482 PHYs.
> >  
> >  config CICADA_PHY
> >  	tristate "Cicada PHYs"
> > diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
> > index 870327e..cdce761 100644
> > --- a/drivers/net/phy/broadcom.c
> > +++ b/drivers/net/phy/broadcom.c
> > @@ -35,6 +35,35 @@ static int bcm54xx_auxctl_write(struct phy_device *phydev, u16 regnum, u16 val)
> >  	return phy_write(phydev, MII_BCM54XX_AUX_CTL, regnum | val);
> >  }
> >  
> > +static int bcm54810_config(struct phy_device *phydev)
> > +{
> > +	int rc;
> > +
> > +	/* Disable BroadR-Reach */
> > +	rc = bcm_phy_write_exp(phydev, BCM54810_EXP_BROADREACH_LRE_MISC_CTL, 0);
> > +	if (rc < 0)
> > +		return rc;
> > +
> > +	/* SKEW DISABLE */
> > +	rc = bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
> > +				  0xF0E0);
> > +	if (rc < 0)
> > +		return rc;
> > +
> > +	/* DELAY DISABLE */
> > +	rc = bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
> > +				  0x7000);
> 
> This driver mostly uses symbolic names, not #defines. Please can you
> use #defines here and else were in this patch.

Will do.  After looking at this, this appears to be setup for a read
that doesn't follow.  I'll audit this, clean it up and resend.

 
> > +	if (rc < 0)
> > +		return rc;
> > +
> > +	/* DELAY DISABLE */
> > +	rc = bcm_phy_write_shadow(phydev, BCM54810_SHD_CLK_CTL, 0);
> > +	if (rc < 0)
> > +		return rc;
> 
> Twice the same comment?
>
> > +
> > +	return 0;
> > +}
> > +
> >  /* Needs SMDSP clock enabled via bcm54xx_phydsp_config() */
> >  static int bcm50610_a0_workaround(struct phy_device *phydev)
> >  {
> > @@ -207,6 +236,20 @@ static int bcm54xx_config_init(struct phy_device *phydev)
> >  	    (phydev->dev_flags & PHY_BRCM_AUTO_PWRDWN_ENABLE))
> >  		bcm54xx_adjust_rxrefclk(phydev);
> >  
> > +	if (BRCM_PHY_MODEL(phydev) == PHY_ID_BCM54810) {
> > +		err = bcm54810_config(phydev);
> > +		if (err)
> > +			return err;
> > +
> > +		reg = phy_read(phydev, MII_BMCR);
> > +		if (reg < 0)
> > +			return reg;
> > +
> > +		err = phy_write(phydev, MII_BMCR, reg & ~BMCR_PDOWN);
> > +		if (err)
> > +			return err;
> 
> This seems a bit odd. I would expect the PHY core correctly handles
> the PHY being powered down. Can you explain this a bit more, why it is
> needed.

I believe it was needed in earlier versions of the code, but doesn't
seem to be needed anymore.  Removing.

> 
> 	Thanks
> 		Andrew
