From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [PATCH 2/2] net: sfc: falcon: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 21 Dec 2016 14:38:38 +0000
Message-ID: <f08f69d5-f609-f1de-05d1-2a7a51ceeddc@solarflare.com>
References: <1482272667-1206-1-git-send-email-tremyfr@gmail.com>
 <1482272667-1206-2-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
        <linux-net-drivers@solarflare.com>, <ecree@solarflare.com>,
        <davem@davemloft.net>, <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482272667-1206-2-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20/12/16 22:24, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/ethernet/sfc/falcon/efx.c          |    2 +-
>  drivers/net/ethernet/sfc/falcon/ethtool.c      |   35 ++++++++++++-------
>  drivers/net/ethernet/sfc/falcon/mdio_10g.c     |   44 +++++++++++++++---------
>  drivers/net/ethernet/sfc/falcon/mdio_10g.h     |    3 +-
>  drivers/net/ethernet/sfc/falcon/net_driver.h   |   12 +++---
>  drivers/net/ethernet/sfc/falcon/qt202x_phy.c   |    9 +++--
>  drivers/net/ethernet/sfc/falcon/tenxpress.c    |   22 ++++++------
>  drivers/net/ethernet/sfc/falcon/txc43128_phy.c |    9 +++--
>  8 files changed, 80 insertions(+), 56 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sfc/falcon/efx.c b/drivers/net/ethernet/sfc/falcon/efx.c
> index 5c5cb3c..438ef9e 100644
> --- a/drivers/net/ethernet/sfc/falcon/efx.c
> +++ b/drivers/net/ethernet/sfc/falcon/efx.c
> @@ -986,7 +986,7 @@ void ef4_mac_reconfigure(struct ef4_nic *efx)
>  
>  /* Push loopback/power/transmit disable settings to the PHY, and reconfigure
>   * the MAC appropriately. All other PHY configuration changes are pushed
> - * through phy_op->set_settings(), and pushed asynchronously to the MAC
> + * through phy_op->set_link_ksettings(), and pushed asynchronously to the MAC
>   * through ef4_monitor().
>   *
>   * Callers must hold the mac_lock
> diff --git a/drivers/net/ethernet/sfc/falcon/ethtool.c b/drivers/net/ethernet/sfc/falcon/ethtool.c
> index 8e1929b..659ece7 100644
> --- a/drivers/net/ethernet/sfc/falcon/ethtool.c
> +++ b/drivers/net/ethernet/sfc/falcon/ethtool.c
> @@ -115,44 +115,53 @@ static int ef4_ethtool_phys_id(struct net_device *net_dev,
>  }
>  
>  /* This must be called with rtnl_lock held. */
> -static int ef4_ethtool_get_settings(struct net_device *net_dev,
> -				    struct ethtool_cmd *ecmd)
> +static int
> +ef4_ethtool_get_link_ksettings(struct net_device *net_dev,
> +			       struct ethtool_link_ksettings *cmd)
>  {
>  	struct ef4_nic *efx = netdev_priv(net_dev);
>  	struct ef4_link_state *link_state = &efx->link_state;
> +	u32 supported;
> +
> +	ethtool_convert_link_mode_to_legacy_u32(&supported,
> +						cmd->link_modes.supported);
>  
>  	mutex_lock(&efx->mac_lock);
> -	efx->phy_op->get_settings(efx, ecmd);
> +	efx->phy_op->get_link_ksettings(efx, cmd);
>  	mutex_unlock(&efx->mac_lock);
>  
>  	/* Both MACs support pause frames (bidirectional and respond-only) */
> -	ecmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
> +	supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
>  
>  	if (LOOPBACK_INTERNAL(efx)) {
> -		ethtool_cmd_speed_set(ecmd, link_state->speed);
> -		ecmd->duplex = link_state->fd ? DUPLEX_FULL : DUPLEX_HALF;
> +		cmd->base.speed = link_state->speed;
> +		cmd->base.duplex = link_state->fd ? DUPLEX_FULL : DUPLEX_HALF;
>  	}
>  
> +	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
> +						supported);
> +
>  	return 0;
>  }

This translates cmd->link_modes.supported in to the legacy supported
bitmap before we've actually read the values from the phy. Given we're
only using the legacy bitmap so we can add the pause frame settings, I
suggest something like:

ef4_ethtool_get_link_ksettings(struct net_device *net_dev,
			       struct ethtool_link_ksettings *cmd)
{
	struct ef4_nic *efx = netdev_priv(net_dev);
	struct ef4_link_state *link_state = &efx->link_state;

	mutex_lock(&efx->mac_lock);
	efx->phy_op->get_link_ksettings(efx, cmd);
	mutex_unlock(&efx->mac_lock);

	/* Both MACs support pause frames (bidirectional and respond-only) */
	ethtool_link_ksettings_add_link_mode(cmd, supported, Pause);
	ethtool_link_ksettings_add_link_mode(cmd, supported, Asym_Pause);

	if (LOOPBACK_INTERNAL(efx)) {
		cmd->base.speed = link_state->speed;
		cmd->base.duplex = link_state->fd ? DUPLEX_FULL : DUPLEX_HALF;
	}

	return 0;
}


Thanks,

Bert.
