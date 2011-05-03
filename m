From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: ehea: fix wrongly-reported supported modes
Date: Tue, 03 May 2011 21:16:15 +0100
Message-ID: <1304453775.2873.17.camel@bwh-desktop>
References: <1304451745.6899.15.camel@dream>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13546 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754668Ab1ECUQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 16:16:18 -0400
In-Reply-To: <1304451745.6899.15.camel@dream>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-03 at 16:42 -0300, Kleber Sacilotto de Souza wrote:
> Currently EHEA reports to ethtool as supporting 10000baseT_Full and
> FIBRE independent of the hardware configuration. However, these
> capabilities should be reported only if the physical port and
> the medium support them, which is the case where the physical port
> is connected at 10Gb.
>
> Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
> ---
>  drivers/net/ehea/ehea_ethtool.c |   21 ++++++++++++++-------
>  1 files changed, 14 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
> index 3e2e734..04716c2 100644
> --- a/drivers/net/ehea/ehea_ethtool.c
> +++ b/drivers/net/ehea/ehea_ethtool.c
> @@ -55,15 +55,22 @@ static int ehea_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
>  		cmd->duplex = -1;
>  	}
> 
> -	cmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_1000baseT_Full
> -		       | SUPPORTED_100baseT_Full |  SUPPORTED_100baseT_Half
> -		       | SUPPORTED_10baseT_Full | SUPPORTED_10baseT_Half
> -		       | SUPPORTED_Autoneg | SUPPORTED_FIBRE);
> +	cmd->supported = (SUPPORTED_1000baseT_Full | SUPPORTED_100baseT_Full
> +		       | SUPPORTED_100baseT_Half | SUPPORTED_10baseT_Full
> +		       | SUPPORTED_10baseT_Half | SUPPORTED_Autoneg);
> 
> -	cmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_Autoneg
> -			 | ADVERTISED_FIBRE);
> +	cmd->advertising = ADVERTISED_Autoneg;
> +
> +	if (cmd->speed == SPEED_10000) {
> +		cmd->supported |= (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
> +		cmd->advertising |= (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
> +		cmd->port = PORT_FIBRE;
> +	} else {
> +		cmd->supported |= SUPPORTED_TP;
> +		cmd->advertising |= (ADVERTISED_1000baseT_Full | ADVERTISED_TP);
> +		cmd->port = PORT_TP;
> +	}

This doesn't make any sense.  If the current speed is 10G, then the
driver also claims to support speeds of 10M, 100M, 1G and 10G.  But then
if the speed actually is <10G, the driver claims to support TP.  What's
going on here?

(Also, claiming to support BASE-T modes on non-TP media is bogus, though
I understand why people are doing it.)

Ben.

> -	cmd->port = PORT_FIBRE;
>  	cmd->autoneg = port->autoneg == 1 ? AUTONEG_ENABLE : AUTONEG_DISABLE;
> 
>  	return 0;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

