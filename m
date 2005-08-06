From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [PATCH] emac: add support for platform-specific unsupported PHY features
Date: Fri, 5 Aug 2005 17:05:16 -0700
Message-ID: <20050806000516.GA19218@gate.ebshome.net>
References: <1123284725.27880.26.camel@rhino.az.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com,
        Matt Porter <mporter@kernel.crashing.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Wade Farnsworth <wfarnsworth@mvista.com>
Content-Disposition: inline
In-Reply-To: <1123284725.27880.26.camel@rhino.az.mvista.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Aug 05, 2005 at 04:32:05PM -0700, Wade Farnsworth wrote:
> Hello,
> 
> This patch adds support to the ibm_emac driver for platform-specific
> unsupported PHY features.
> 
> The patch attempts to determine the highest speed and duplex when
> autonegotiation is unsupported.

Looks good.

> 
> -Wade Farnsworth
> 
> Signed-off-by: Wade Farnsworth <wfarnsworth@mvista.com>

> diff -upr linux-2.6/drivers/net/ibm_emac/ibm_emac_core.c linux-2.6-dev/drivers/net/ibm_emac/ibm_emac_core.c
> --- linux-2.6/drivers/net/ibm_emac/ibm_emac_core.c	2005-08-03 13:33:42.000000000 -0700
> +++ linux-2.6-dev/drivers/net/ibm_emac/ibm_emac_core.c	2005-08-02 10:42:59.000000000 -0700
> @@ -1876,6 +1876,9 @@ static int emac_init_device(struct ocp_d
>  		rc = -ENODEV;
>  		goto bail;
>  	}
> +	
> +	/* Disable any PHY features not supported by the platform */
> +	ep->phy_mii.def->features &= ~emacdata->feat_unsupp;
>  
>  	/* Setup initial PHY config & startup aneg */
>  	if (ep->phy_mii.def->ops->init)
> @@ -1883,6 +1886,38 @@ static int emac_init_device(struct ocp_d
>  	netif_carrier_off(ndev);
>  	if (ep->phy_mii.def->features & SUPPORTED_Autoneg)
>  		ep->want_autoneg = 1;
> +	else {
> +		ep->want_autoneg = 0;
> +		
> +		/* Select highest supported speed/duplex */
> +		if (ep->phy_mii.def->features & SUPPORTED_10000baseT_Full) {
> +			ep->phy_mii.speed = SPEED_10000;
> +			ep->phy_mii.duplex = DUPLEX_FULL;

I think you are being too optimistic here :). EMAC doesn't support 10G 
Ethernet and will never will (at least sanely) given it's 
brain-damaged design. So I think it's safe to drop 
SUPPORTED_10000baseT_Full test.

I'll update my NAPI tree with similar code.

-- 
Eugene
