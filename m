From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH 09/13] net: phy: Add Meson GXL Internal PHY driver
Date: Fri, 21 Oct 2016 13:56:30 -0700
Message-ID: <0ea5a7a8-3913-0e6a-6ff2-9f34015ea071@gmail.com>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
 <1477060838-14164-10-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org,
        carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org, linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477060838-14164-10-git-send-email-narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/21/2016 07:40 AM, Neil Armstrong wrote:
> Add driver for the Internal RMII PHY found in the Amlogic Meson GXL SoCs.
> 
> This PHY seems to only implement some standard registers and need some
> workarounds to provide autoneg values from vendor registers.
> 
> Some magic values are currently used to configure the PHY, and this a
> temporary setup until clarification about these registers names and
> registers fields are provided by Amlogic.
> 
> Signed-off-by: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
> ---
> +
> +static int meson_gxl_config_init(struct phy_device *phydev)
> +{
> +	int val;
> +	u32 features;
> +
> +	meson_gxl_phy_config(phydev);
> +
> +	features = SUPPORTED_MII;

This does not really belong in the PHY driver, and this is statically
assigned, I would just drop this.

> +
> +	/* Do we support autonegotiation? */
> +	val = phy_read(phydev, MII_BMSR);
> +	if (val < 0)
> +		return val;
> +
> +	if (val & BMSR_ANEGCAPABLE)
> +		features |= SUPPORTED_Autoneg;
> +	if (val & BMSR_100FULL)
> +		features |= SUPPORTED_100baseT_Full;
> +	if (val & BMSR_100HALF)
> +		features |= SUPPORTED_100baseT_Half;
> +	if (val & BMSR_10FULL)
> +		features |= SUPPORTED_10baseT_Full;
> +	if (val & BMSR_10HALF)
> +		features |= SUPPORTED_10baseT_Half;
> +
> +	phydev->supported = features;
> +	phydev->advertising = features;

This is redundant with what PHYLIB will determine for the PHY.

> +
> +	return 0;
> +}
> +
> +static int meson_gxl_phy_read_status(struct phy_device *phydev)
> +{
> +	int err;
> +
> +	/* Update the link, but return if there was an error */
> +	err = genphy_update_link(phydev);
> +	if (err)
> +		return err;
> +
> +	phydev->lp_advertising = 0;
> +	phydev->pause = 0;
> +	phydev->asym_pause = 0;
> +
> +	if (phydev->autoneg == AUTONEG_ENABLE) {
> +		unsigned int speed;
> +		int reg = phy_read(phydev, GXL_REG_ANEG);

Is all of this really necessary? This should all be reflected in the
standard BMSR register, is not this the case here that we have to read
this non-standard register?

You use genphy_config_aneg(), so surely, the standard auto-negotiation
part works somehow?

> +
> +		if (reg < 0)
> +			return reg;
> +
> +		speed = reg & REG_ANEG_SPEED_MASK;
> +
> +		if (reg & REG_ANEG_FDUPLEX)
> +			phydev->duplex = DUPLEX_FULL;
> +		else
> +			phydev->duplex = DUPLEX_HALF;
> +
> +		if ((reg & REG_ANEG_SPEED_MASK) == REG_ANEG_SPEED10)
> +			phydev->speed = SPEED_10;
> +		else if ((reg & REG_ANEG_SPEED_MASK) == REG_ANEG_SPEED100)
> +			phydev->speed = SPEED_100;
> +	} else {
> +		int bmcr = phy_read(phydev, MII_BMCR);
> +
> +		if (bmcr < 0)
> +			return bmcr;
> +
> +		if (bmcr & BMCR_FULLDPLX)
> +			phydev->duplex = DUPLEX_FULL;
> +		else
> +			phydev->duplex = DUPLEX_HALF;
> +
> +		if (bmcr & BMCR_SPEED1000)
> +			phydev->speed = SPEED_1000;
> +		else if (bmcr & BMCR_SPEED100)
> +			phydev->speed = SPEED_100;
> +		else
> +			phydev->speed = SPEED_10;
> +	}

> +
> +	return 0;
> +}
> +
> +static struct phy_driver meson_gxl_phy = {
> +	.phy_id		= 0x01814400,
> +	.name		= "Meson GXL Internal PHY",
> +	.phy_id_mask	= 0x0fffffff,

Usually the last 4 bits are 0, since that's where the revision part is
located.

> +	.features	= 0,

You should set PHY_GBIT_FEATURES and set .flags to PHY_IS_INTERNAL since
this is an internal PHY?
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
