From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH net-next 02/12] net: phy: bcm7xxx: add support for 28nm
 EPHY
Date: Tue, 14 Mar 2017 02:06:51 +0100
Message-ID: <20170314010651.GO15842@lunn.ch>
References: <20170314004142.4746-1-opendmb@gmail.com>
 <20170314004142.4746-3-opendmb@gmail.com>
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
In-Reply-To: <20170314004142.4746-3-opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 13, 2017 at 05:41:32PM -0700, Doug Berger wrote:
> +static int bcm7xxx_28nm_ephy_01_afe_config_init(struct phy_device *phydev)
> +{
> +	int ret;
> +
> +	/* set shadow mode 2 */
> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST,
> +			       MII_BCM7XXX_SHD_MODE_2, 0);
> +	if (ret < 0)
> +		return ret;
> +
> +	/* Set current trim values INT_trim = -1, Ext_trim =0 */
> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_BIAS_TRIM, 0x3BE0);
> +	if (ret < 0)
> +		goto reset_shadow_mode;
> +
> +	/* Cal reset */
> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
> +			MII_BCM7XXX_SHD_3_TL4);
> +	if (ret < 0)
> +		goto reset_shadow_mode;

Hi Doug

It would be nice to have a few blank lines here and there...

> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
> +			       MII_BCM7XXX_TL4_RST_MSK, 0);
> +	if (ret < 0)
> +		goto reset_shadow_mode;
> +
> +	/* Cal reset disable */
> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
> +			MII_BCM7XXX_SHD_3_TL4);
> +	if (ret < 0)
> +		goto reset_shadow_mode;

... just to break things up into readable chunks.

> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
> +			       0, MII_BCM7XXX_TL4_RST_MSK);
> +	if (ret < 0)
> +		goto reset_shadow_mode;
> +
> +reset_shadow_mode:
> +	/* reset shadow mode 2 */
> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST, 0,
> +			       MII_BCM7XXX_SHD_MODE_2);
> +	if (ret < 0)
> +		return ret;
> +
> +	return 0;

How about:

	return phy_set_clr_bits(phydev, MII_BCM7XXX_TEST, 0,
	       		        MII_BCM7XXX_SHD_MODE_2);

> +/* The 28nm EPHY does not support Clause 45 (MMD) used by bcm-phy-lib */
> +static int bcm7xxx_28nm_ephy_apd_enable(struct phy_device *phydev)
> +{
> +	int ret;
> +
> +	/* set shadow mode 1 */
> +	ret = phy_set_clr_bits(phydev, MII_BRCM_FET_BRCMTEST,
> +			       MII_BRCM_FET_BT_SRE, 0);
> +	if (ret < 0)
> +		return ret;
> +
> +	/* Enable auto-power down */
> +	ret = phy_set_clr_bits(phydev, MII_BRCM_FET_SHDW_AUXSTAT2,
> +			       MII_BRCM_FET_SHDW_AS2_APDE, 0);
> +	if (ret < 0)
> +		return ret;
> +
> +	/* reset shadow mode 1 */
> +	ret = phy_set_clr_bits(phydev, MII_BRCM_FET_BRCMTEST, 0,
> +			       MII_BRCM_FET_BT_SRE);
> +	if (ret < 0)
> +		return ret;
> +
> +	return 0;

How about just

    return phy_set_clr_bits(phydev, MII_BRCM_FET_BRCMTEST, 0,
    	   		       MII_BRCM_FET_BT_SRE);


> +}
> +
> +static int bcm7xxx_28nm_ephy_eee_enable(struct phy_device *phydev)
> +{
> +	int ret;
> +
> +	/* set shadow mode 2 */
> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST,
> +			       MII_BCM7XXX_SHD_MODE_2, 0);
> +	if (ret < 0)
> +		return ret;
> +
> +	/* Advertise supported modes */
> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
> +			MII_BCM7XXX_SHD_3_AN_EEE_ADV);
> +	if (ret < 0)
> +		goto reset_shadow_mode;

blank...

> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
> +			MDIO_EEE_100TX);
> +	if (ret < 0)
> +		goto reset_shadow_mode;
> +
> +	/* Restore Defaults */
> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
> +			MII_BCM7XXX_SHD_3_PCS_CTRL_2);
> +	if (ret < 0)
> +		goto reset_shadow_mode;
> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
> +			MII_BCM7XXX_PCS_CTRL_2_DEF);
> +	if (ret < 0)
> +		goto reset_shadow_mode;
> +
> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
> +			MII_BCM7XXX_SHD_3_EEE_THRESH);
> +	if (ret < 0)
> +		goto reset_shadow_mode;
> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
> +			MII_BCM7XXX_EEE_THRESH_DEF);
> +	if (ret < 0)
> +		goto reset_shadow_mode;
> +
> +	/* Enable EEE autonegotiation */
> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_ADDR_CTRL,
> +			MII_BCM7XXX_SHD_3_AN_STAT);
> +	if (ret < 0)
> +		goto reset_shadow_mode;
> +	ret = phy_write(phydev, MII_BCM7XXX_SHD_2_CTRL_STAT,
> +			(MII_BCM7XXX_AN_NULL_MSG_EN | MII_BCM7XXX_AN_EEE_EN));
> +	if (ret < 0)
> +		goto reset_shadow_mode;
> +
> +reset_shadow_mode:
> +	/* reset shadow mode 2 */
> +	ret = phy_set_clr_bits(phydev, MII_BCM7XXX_TEST, 0,
> +			       MII_BCM7XXX_SHD_MODE_2);
> +	if (ret < 0)
> +		return ret;
> +
> +	/* Restart autoneg */
> +	phy_write(phydev, MII_BMCR,
> +		  (BMCR_SPEED100 | BMCR_ANENABLE | BMCR_ANRESTART));
> +
> +	return 0;

  return phy_write(.....); ?

> +}

  Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
