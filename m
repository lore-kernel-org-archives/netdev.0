From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Microsemi VSC 8531/41 PHY Driver
Date: Tue, 26 Jul 2016 14:43:47 +0200
Message-ID: <20160726124347.GD11538@lunn.ch>
References: <646450A91FAED74E85C6E9C4D6E936A145329E4A@avsrvexchmbx1.microsemi.net>
 <20160726115556.GC11538@lunn.ch>
 <646450A91FAED74E85C6E9C4D6E936A145329E97@avsrvexchmbx1.microsemi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	Allan Nielsen <Allan.Nielsen@microsemi.com>
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50981 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754225AbcGZMnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 08:43:51 -0400
Content-Disposition: inline
In-Reply-To: <646450A91FAED74E85C6E9C4D6E936A145329E97@avsrvexchmbx1.microsemi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* RGMII Rx Clock delay value change with board lay-out */
> +static u8 rgmii_rx_clk_delay = RGMII_RX_CLK_DELAY_1_1_NS;

Doesn't this stop you from having a board with two PHYs with different
layouts? You should be getting this value from the device tree.

> +	phydev->supported = (SUPPORTED_1000baseT_Full |
> +			     SUPPORTED_1000baseT_Half |
> +			     SUPPORTED_100baseT_Full  |
> +			     SUPPORTED_100baseT_Half  |
> +			     SUPPORTED_10baseT_Full   |
> +			     SUPPORTED_10baseT_Half   |
> +			     SUPPORTED_Autoneg        |
> +			     SUPPORTED_Pause          |
> +			     SUPPORTED_Asym_Pause     |
> +			     SUPPORTED_TP);
> +
> +	phydev->speed = SPEED_1000;
> +	phydev->duplex = DUPLEX_FULL;
> +	phydev->pause = 0;
> +	phydev->asym_pause = 0;
> +	phydev->interface = PHY_INTERFACE_MODE_RGMII;
> +	phydev->mdix = ETH_TP_MDI_AUTO;

Why are you setting all these? This is not normal, if you look at
other drivers.

> +
> +	mutex_lock(&phydev->lock);

What are you locking against?

> +	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED_2);
> +	if (rc != 0) {
> +		rc = -EINVAL;

Why do you overwrite the error code vsc85xx_phy_page_set gives you?

> +		goto out_unlock;
> +	}
> +	reg_val = phy_read(phydev, MSCC_PHY_RGMII_CNTL);
> +	reg_val &= ~(RGMII_RX_CLK_DELAY_MASK);
> +	reg_val |= (rgmii_rx_clk_delay << RGMII_RX_CLK_DELAY_POS);
> +	phy_write(phydev, MSCC_PHY_RGMII_CNTL, reg_val);
> +	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
> +	if (rc != 0)
> +		rc = -EINVAL;

Same here.

> +
> +out_unlock:
> +	mutex_unlock(&phydev->lock);
> +
> +	return rc;
> +}
> +
> +static int vsc85xx_config_init(struct phy_device *phydev)
> +{
> +	int rc = 0;

No need to initialise rc.

> +	rc = vsc85xx_default_config(phydev);

  	if (rc)
    		return rc;

> +	rc = genphy_config_init(phydev);
> +
> +	return rc;

Or just 
	return genphy_config_init(phydev);

> +}
> +
> +static int vsc85xx_ack_interrupt(struct phy_device *phydev)
> +{
> +	int rc = 0;
> +
> +	if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
> +		rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
> +
> +	return (rc < 0) ? rc : 0;
> +}
> +
> +static int vsc85xx_config_intr(struct phy_device *phydev)
> +{
> +	int rc;
> +
> +	if (phydev->interrupts == PHY_INTERRUPT_ENABLED) {
> +		rc = phy_write(phydev, MII_VSC85XX_INT_MASK,
> +			       MII_VSC85XX_INT_MASK_MASK);
> +	} else {
> +		rc = phy_read(phydev, MII_VSC85XX_INT_STATUS);
> +		if (rc < 0)
> +			return rc;

And the purpose of this read is? I assume it clears an outstanding
interrupt? If so, shouldn't you do it after disabling interrupts, not
before? Otherwise you have a race condition.

> +		rc = phy_write(phydev, MII_VSC85XX_INT_MASK, 0);
> +	}
> +
> +	return rc;

  Andrew
