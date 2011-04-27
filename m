From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 4/4] ethtool: cosmetic: Use ethtool ethtool_cmd_speed
 API
Date: Wed, 27 Apr 2011 20:43:50 +0100
Message-ID: <1303933430.2875.145.camel@bwh-desktop>
References: <1303001651-4074-1-git-send-email-decot@google.com>
	 <1303929290-21037-5-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, mirq-linux@rere.qmqm.pl,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Decotigny <decot@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303929290-21037-5-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-04-27 at 11:34 -0700, David Decotigny wrote:
> This updates the network drivers so that they don't access the
> ethtool_cmd::speed field directly, but use ethtoo_cmd_speed() instead.
> 
> For most of the drivers, these changes are purely cosmetic and don't
> fix any problem, such as for those 1GbE/10GbE drivers that indirectly
> call their own ethtool get_settings()/mii_ethtool_gset(). The changes
> are meant to enforce code consistency and provide robustness with
> future larger throughputs, at the expense of a few CPU cycles for each
> ethtool operation.
> 
> All the drivers compiled with make allyesconfig ion x86_64 have been
> updated.
> 
> Tested: make allyesconfig on x86_64 + e1000e/bnx2x work
> Signed-off-by: David Decotigny <decot@google.com>
[...]
> --- a/drivers/net/mdio.c
> +++ b/drivers/net/mdio.c
> @@ -290,33 +290,36 @@ void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
>  		if (modes & (ADVERTISED_10000baseT_Full |
>  			     ADVERTISED_10000baseKX4_Full |
>  			     ADVERTISED_10000baseKR_Full)) {
> -			ecmd->speed = SPEED_10000;
> +			ethtool_cmd_speed_set(ecmd, SPEED_10000);
>  			ecmd->duplex = DUPLEX_FULL;
>  		} else if (modes & (ADVERTISED_1000baseT_Full |
>  				    ADVERTISED_1000baseT_Half |
>  				    ADVERTISED_1000baseKX_Full)) {
> -			ecmd->speed = SPEED_1000;
> +			ethtool_cmd_speed_set(ecmd, SPEED_1000);
>  			ecmd->duplex = !(modes & ADVERTISED_1000baseT_Half);
>  		} else if (modes & (ADVERTISED_100baseT_Full |
>  				    ADVERTISED_100baseT_Half)) {
> -			ecmd->speed = SPEED_100;
> +			ethtool_cmd_speed_set(ecmd, SPEED_100);
>  			ecmd->duplex = !!(modes & ADVERTISED_100baseT_Full);
>  		} else {
> -			ecmd->speed = SPEED_10;
> +			ethtool_cmd_speed_set(ecmd, SPEED_10);
>  			ecmd->duplex = !!(modes & ADVERTISED_10baseT_Full);
>  		}
>  	} else {
>  		/* Report forced settings */
> +		u32 speed;
>  		reg = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
>  				      MDIO_CTRL1);
> -		ecmd->speed = (((reg & MDIO_PMA_CTRL1_SPEED1000) ? 100 : 1) *
> -			       ((reg & MDIO_PMA_CTRL1_SPEED100) ? 100 : 10));
> +		speed = (((reg & MDIO_PMA_CTRL1_SPEED1000) ? 100 : 1)
> +			 * ((reg & MDIO_PMA_CTRL1_SPEED100) ? 100 : 10));
>  		ecmd->duplex = (reg & MDIO_CTRL1_FULLDPLX ||
> -				ecmd->speed == SPEED_10000);
> +				speed == SPEED_10000);
> +		ethtool_cmd_speed_set(ecmd, speed);
>  	}
>  
>  	/* 10GBASE-T MDI/MDI-X */
> -	if (ecmd->port == PORT_TP && ecmd->speed == SPEED_10000) {
> +	if (ecmd->port == PORT_TP
> +	    && (ethtool_cmd_speed(ecmd) == SPEED_10000)) {
>  		switch (mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_PMAPMD,
>  					MDIO_PMA_10GBT_SWAPPOL)) {
>  		case MDIO_PMA_10GBT_SWAPPOL_ABNX | MDIO_PMA_10GBT_SWAPPOL_CDNX:

It seems like the scope of speed should be the whole function.  Then you
could just have one call to ethtool_cmd_speed_set() after the
'if (ecmd->autoneg) ... else ...' statement, and no need to use
ethtool_cmd_speed().

[...]
> --- a/drivers/net/tulip/de2104x.c
> +++ b/drivers/net/tulip/de2104x.c
> @@ -1518,15 +1518,15 @@ static int __de_get_settings(struct de_private *de, struct ethtool_cmd *ecmd)
>  	switch (de->media_type) {
>  	case DE_MEDIA_AUI:
>  		ecmd->port = PORT_AUI;
> -		ecmd->speed = 5;
> +		ethtool_cmd_speed_set(ecmd, 5);
>  		break;
>  	case DE_MEDIA_BNC:
>  		ecmd->port = PORT_BNC;
> -		ecmd->speed = 2;
> +		ethtool_cmd_speed_set(ecmd, 2);
>  		break;
>  	default:
>  		ecmd->port = PORT_TP;
> -		ecmd->speed = SPEED_10;
> +		ethtool_cmd_speed_set(ecmd, SPEED_10);
>  		break;
>  	}
[...]

As I commented on the previous patch, this should always report a speed
of 10.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
