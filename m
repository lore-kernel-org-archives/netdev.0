From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v3] lxt PHY: Support for the buggy LXT973 rev A2
Date: Sat, 22 Sep 2012 19:32:25 +0200
Message-ID: <20120922173225.GA6796@netboy.at.omicron.at>
References: <201209221616.q8MGGnRc019864@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David S Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:58300 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752904Ab2IVRci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 13:32:38 -0400
Content-Disposition: inline
In-Reply-To: <201209221616.q8MGGnRc019864@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 22, 2012 at 06:16:49PM +0200, Christophe Leroy wrote:
> This patch adds proper handling of the buggy revision A2 of LXT973 phy, adding
> precautions linked to ERRATA Item 4:
> 
> Revision A2 of LXT973 chip randomly returns the contents of the previous even
> register when you read a odd register regularly

This patch does not apply to net-next.

Also, I have just a few stylistic comments, below.

> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> 
> diff -u linux-3.5-vanilla/drivers/net/phy/lxt.c linux-3.5/drivers/net/phy/lxt.c
> --- linux-3.5-vanilla/drivers/net/phy/lxt.c	2012-07-21 22:58:29.000000000 +0200
> +++ linux-3.5/drivers/net/phy/lxt.c	2012-09-15 19:20:34.000000000 +0200

...

> +int lxt973a2_read_status(struct phy_device *phydev)
> +{
> +	int adv;
> +	int err;
> +	int lpa;
> +	int lpagb = 0;
> +
> +	/* Update the link, but return if there was an error */
> +	err = lxt973a2_update_link(phydev);
> +	if (err)
> +		return err;
> +
> +	if (AUTONEG_ENABLE == phydev->autoneg) {
> +		int retry = 1;
> +
> +		adv = phy_read(phydev, MII_ADVERTISE);
> +
> +		if (adv < 0)
> +			return adv;
> +
> +		do {
> +			lpa = phy_read(phydev, MII_LPA);
> +
> +			if (lpa < 0)
> +				return lpa;
> +
> +			/* If both registers are equal, it is suspect but not
> +			* impossible, hence a new try
> +			*/
> +		} while (lpa == adv && retry--);
> +
> +		lpa &= adv;
> +
> +		phydev->speed = SPEED_10;
> +		phydev->duplex = DUPLEX_HALF;
> +		phydev->pause = phydev->asym_pause = 0;
> +
> +		if (lpagb & (LPA_1000FULL | LPA_1000HALF)) {
> +			phydev->speed = SPEED_1000;
> +
> +			if (lpagb & LPA_1000FULL)
> +				phydev->duplex = DUPLEX_FULL;
> +		} else if (lpa & (LPA_100FULL | LPA_100HALF)) {
> +			phydev->speed = SPEED_100;
> +
> +			if (lpa & LPA_100FULL)
> +				phydev->duplex = DUPLEX_FULL;
> +		} else
> +			if (lpa & LPA_10FULL)
> +				phydev->duplex = DUPLEX_FULL;

This last 'else' could use braces.

> +
> +		if (phydev->duplex == DUPLEX_FULL) {
> +			phydev->pause = lpa & LPA_PAUSE_CAP ? 1 : 0;
> +			phydev->asym_pause = lpa & LPA_PAUSE_ASYM ? 1 : 0;
> +		}
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
> +
> +		phydev->pause = phydev->asym_pause = 0;
> +	}
> +
> +	return 0;
> +}
> +
> +static int lxt973_read_status(struct phy_device *phydev)
> +{
> +	return (int)phydev->priv&PHYDEV_PRIV_REVA2 ?
> +			lxt973a2_read_status(phydev) :
> +			genphy_read_status(phydev);

Needs spacing, like this:

	return (int) phydev->priv & PHYDEV_PRIV_REVA2 ?
		lxt973a2_read_status(phydev) : genphy_read_status(phydev);

> +}
> +
>  static int lxt973_probe(struct phy_device *phydev)
>  {
>  	int val = phy_read(phydev, MII_LXT973_PCR);
> +	int priv = 0;
> +
> +	phydev->priv = NULL;
> +
> +	if (val < 0)
> +		return val;
>  
>  	if (val & PCR_FIBER_SELECT) {
>  		/*
> @@ -136,17 +272,26 @@
>  		val &= ~BMCR_ANENABLE;
>  		phy_write(phydev, MII_BMCR, val);
>  		/* Remember that the port is in fiber mode. */
> -		phydev->priv = lxt973_probe;
> -	} else {
> -		phydev->priv = NULL;
> +		priv |= PHYDEV_PRIV_FIBER;
> +	}
> +	val = phy_read(phydev, MII_PHYSID2);
> +
> +	if (val < 0)
> +		return val;
> +
> +	if ((val & 0xf) == 0) { /* rev A2 */
> +		dev_info(&phydev->dev, " LXT973 revision A2 has bugs\n");
> +		priv |= PHYDEV_PRIV_REVA2;
>  	}
> +	phydev->priv = (void *)priv;

One space after cast, please: (void *) priv;

>  	return 0;
>  }
>  
>  static int lxt973_config_aneg(struct phy_device *phydev)
>  {
>  	/* Do nothing if port is in fiber mode. */
> -	return phydev->priv ? 0 : genphy_config_aneg(phydev);
> +	return (int)phydev->priv&PHYDEV_PRIV_FIBER ?
> +			0 : genphy_config_aneg(phydev);

Same spacing issue again.

Thanks,
Richard
