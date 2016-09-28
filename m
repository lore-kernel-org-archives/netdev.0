From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] net: phy: Add PHY Auto/Mdi/Mdix set driver
 for Microsemi PHYs.
Date: Wed, 28 Sep 2016 22:24:51 +0200
Message-ID: <20160928202451.GC30728@lunn.ch>
References: <1475064078-22310-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <1475064078-22310-3-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        Allan.Nielsen@microsemi.com
To: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35419 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752784AbcI1UYz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 16:24:55 -0400
Content-Disposition: inline
In-Reply-To: <1475064078-22310-3-git-send-email-Raju.Lakkaraju@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	reg_val = phy_read(phydev, MSCC_PHY_BYPASS_CONTROL);
> +	if ((mdix == ETH_TP_MDI) || (mdix == ETH_TP_MDI_X)) {
> +		reg_val |= (DISABLE_PAIR_SWAP_CORR_MASK |
> +			    DISABLE_POLARITY_CORR_MASK  |
> +			    DISABLE_HP_AUTO_MDIX_MASK);
> +	} else {
> +		reg_val &= ~(DISABLE_PAIR_SWAP_CORR_MASK |
> +			     DISABLE_POLARITY_CORR_MASK  |
> +			     DISABLE_HP_AUTO_MDIX_MASK);
> +	}
> +	rc = phy_write(phydev, MSCC_PHY_BYPASS_CONTROL, reg_val);
> +	if (rc != 0)
> +		goto out_unlock;
> +
> +	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_EXTENDED);
> +	if (rc != 0)
> +		goto out_unlock;
> +
> +	reg_val = phy_read(phydev, MSCC_PHY_EXT_MODE_CNTL);
> +	reg_val &= ~(FORCE_MDI_CROSSOVER_MASK);
> +	if (mdix == ETH_TP_MDI)
> +		reg_val |= FORCE_MDI_CROSSOVER_MDI;
> +	else if (mdix == ETH_TP_MDI_X)
> +		reg_val |= FORCE_MDI_CROSSOVER_MDIX;
> +	rc = phy_write(phydev, MSCC_PHY_EXT_MODE_CNTL, reg_val);
> +	if (rc != 0)
> +		goto out_unlock;
> +
> +	rc = vsc85xx_phy_page_set(phydev, MSCC_PHY_PAGE_STANDARD);
> +
> +out_unlock:

out_unlock seems a bit of an odd name, since you are not unlocking
anything.

I also wonder if you should try to reset to MSCC_PHY_PAGE_STANDARD in
the error condition?

> +
> +	return rc;
> +}
> +
>  static int vsc85xx_wol_set(struct phy_device *phydev,
>  			   struct ethtool_wolinfo *wol)
>  {
> @@ -227,6 +281,7 @@ static int vsc85xx_default_config(struct phy_device *phydev)
>  	int rc;
>  	u16 reg_val;
>  
> +	phydev->mdix = ETH_TP_MDI_AUTO;

Humm, interesting. The only other driver supporting mdix is the
Marvell one. It does not do this, it leaves it to its default value of
ETH_TP_MDI_INVALID. It does however interpret ETH_TP_MDI_INVALID as
meaning as ETH_TP_MDI_AUTO.

There needs to be consistency here. You either need to do the same as
the Marvell driver, or you need to modify the Marvell driver to also
set phydev->mdix to ETH_TP_MDI_AUTO.

I don't yet know which of these two is the right thing to do.

Florian?

	Andrew
