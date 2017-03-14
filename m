From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next 02/12] net: phy: bcm7xxx: add support for 28nm
 EPHY
Date: Tue, 14 Mar 2017 03:43:20 +0100
Message-ID: <20170314024320.GQ15842@lunn.ch>
References: <20170314004142.4746-1-opendmb@gmail.com>
 <20170314004142.4746-3-opendmb@gmail.com>
 <20170314010651.GO15842@lunn.ch>
 <3e5f7ac9-7e97-60f1-3986-4045522a65f5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org, xow-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        joel-U3u1mxZcP9KHXe+LvDLADg@public.gmane.org, jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pgynther-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jaedon.shin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Doug Berger <opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <3e5f7ac9-7e97-60f1-3986-4045522a65f5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 13, 2017 at 07:06:25PM -0700, Doug Berger wrote:
> On 03/13/2017 06:06 PM, Andrew Lunn wrote:
> > On Mon, Mar 13, 2017 at 05:41:32PM -0700, Doug Berger wrote:
> >> +static int bcm7xxx_28nm_ephy_01_afe_config_init(struct phy_device *phydev)
> >> +{
> >> +	int ret;
> >> +
> >> +	/* set shadow mode 2 */
> >> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST,
> >> +			       MII_BCM7XXX_SHD_MODE_2, 0);
> >> +	if (ret < 0)
> >> +		return ret;
> >> +
> >> +	/* Set current trim values INT_trim = -1, Ext_trim =0 */
> >> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_BIAS_TRIM, 0x3BE0);
> >> +	if (ret < 0)
> >> +		goto reset_shadow_mode;
> >> +
> >> +	/* Cal reset */
> >> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
> >> +			MII_BCM7XXX_SHD_3_TL4);
> >> +	if (ret < 0)
> >> +		goto reset_shadow_mode;
> > 
> > Hi Doug
> > 
> > It would be nice to have a few blank lines here and there...
> > 
> Thanks for taking the time to review this.
> 
> In general I try to keep lines of related functionality together and use
> the blank lines to help identify boundaries.  In this particular case, I
> believe it is clearer to keep the code that may return an error code
> together with the code that tests for the error.

Hi Doug

I agree with that. Which is why i placed the comment between the goto
and the next block of code. This is where i think there should be a
blank line, to separate it from setting the trim values.

> > 	return phy_set_clr_bits(phydev, MII_BCM7XXX_TEST, 0,
> > 	       		        MII_BCM7XXX_SHD_MODE_2);
> > 
> The trouble here is that currently the phy_set_clr_bits() function
> returns the value written or a negative error and the function
> bcm7xxx_28nm_ephy_01_afe_config_init() is supposed to return 0 on
> success and non-zero on failure so this would not have the same
> functionality.

Ah, O.K. No problem.

> >> +	/* Advertise supported modes */
> >> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
> >> +			MII_BCM7XXX_SHD_3_AN_EEE_ADV);
> >> +	if (ret < 0)
> >> +		goto reset_shadow_mode;
> > 
> > blank...
> > 
> >> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
> >> +			MDIO_EEE_100TX);
> >> +	if (ret < 0)
> >> +		goto reset_shadow_mode;
> Here the two phy_write() calls are required to "/* Advertise supported
> modes */" (one sets an address and the other specifies the data to write
> to that address) so I kept them together to imply an association with
> the preceding comment.

O.K, i probably would if written a little helper function. And you
seem to have this repeated a few times, so the helper would be used a
few times.

> >> +
> >> +	/* Restore Defaults */
> >> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
> >> +			MII_BCM7XXX_SHD_3_PCS_CTRL_2);
> >> +	if (ret < 0)
> >> +		goto reset_shadow_mode;
> >> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
> >> +			MII_BCM7XXX_PCS_CTRL_2_DEF);
> >> +	if (ret < 0)
> >> +		goto reset_shadow_mode;
> Same here.
> 
> >> +
> >> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
> >> +			MII_BCM7XXX_SHD_3_EEE_THRESH);
> >> +	if (ret < 0)
> >> +		goto reset_shadow_mode;
> >> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
> >> +			MII_BCM7XXX_EEE_THRESH_DEF);
> >> +	if (ret < 0)
> >> +		goto reset_shadow_mode;
> Here...
> 
> >> +
> >> +	/* Enable EEE autonegotiation */
> >> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
> >> +			MII_BCM7XXX_SHD_3_AN_STAT);
> >> +	if (ret < 0)
> >> +		goto reset_shadow_mode;
> >> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
> >> +			(MII_BCM7XXX_AN_NULL_MSG_EN | MII_BCM7XXX_AN_EEE_EN));
> >> +	if (ret < 0)
> >> +		goto reset_shadow_mode;
> and here.
> 
> >> +
> >> +reset_shadow_mode:
> >> +	/* reset shadow mode 2 */
> >> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST, 0,
> >> +			       MII_BCM7XXX_SHD_MODE_2);
> >> +	if (ret < 0)
> >> +		return ret;
> >> +
> >> +	/* Restart autoneg */
> >> +	phy_write(phydev, MII_BMCR,
> >> +		  (BMCR_SPEED100 | BMCR_ANENABLE | BMCR_ANRESTART));
> >> +
> >> +	return 0;
> > 
> >   return phy_write(.....); ?
> > 
> I would feel more comfortable with this if the return value of the
> struct mii_bus write member function was more clearly defined.  In our
> case, we return 0 on success so I would consider this change, but I
> would prefer a consensus that all mii_bus write functions return 0 on
> success before doing so.

You are right in that this is not clearly defined. But i just looked
through all the mdio drivers in drivers/net/phy and they all do return
0 for their write operation.

  Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
