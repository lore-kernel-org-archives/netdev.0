From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next V2 1/2] ethtool: Support for configurable RSS
 hash function
Date: Tue, 2 Dec 2014 15:14:20 +0000
Message-ID: <547DD74C.9070603@solarflare.com>
References: <1417530049-6943-1-git-send-email-amirv@mellanox.com> <1417530049-6943-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>,
	"Solarflare linux maintainers" <linux-net-drivers@solarflare.com>,
	Shradha Shah <sshah@solarflare.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:32277 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752874AbaLBPOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 10:14:38 -0500
In-Reply-To: <1417530049-6943-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/14 14:20, Amir Vadai wrote:
> diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
> index cad258a..2ac07c9 100644
> --- a/drivers/net/ethernet/sfc/ethtool.c
> +++ b/drivers/net/ethernet/sfc/ethtool.c
> @@ -1086,19 +1086,29 @@ static u32 efx_ethtool_get_rxfh_indir_size(struct net_device *net_dev)
>  		0 : ARRAY_SIZE(efx->rx_indir_table));
>  }
>  
> -static int efx_ethtool_get_rxfh(struct net_device *net_dev, u32 *indir, u8 *key)
> +static int efx_ethtool_get_rxfh(struct net_device *net_dev, u32 *indir, u8 *key,
> +				u8 *hfunc)
>  {
>  	struct efx_nic *efx = netdev_priv(net_dev);
>  
> -	memcpy(indir, efx->rx_indir_table, sizeof(efx->rx_indir_table));
> +	if (hfunc)
> +		*hfunc = ETH_RSS_HASH_UNKNOWN;
This should be ETH_RSS_HASH_TOP, especially as that's what you test
against in the _set_ function below.
(I don't know if we responded to your query.  If not, I can confirm
we're using Toeplitz.)
> +	if (indir)
> +		memcpy(indir, efx->rx_indir_table, sizeof(efx->rx_indir_table));
>  	return 0;
>  }
>  
> -static int efx_ethtool_set_rxfh(struct net_device *net_dev,
> -				const u32 *indir, const u8 *key)
> +static int efx_ethtool_set_rxfh(struct net_device *net_dev, const u32 *indir,
> +				const u8 *key, const u8 hfunc)
>  {
>  	struct efx_nic *efx = netdev_priv(net_dev);
>  
> +	/* We do not allow change in unsupported parameters */
> +	if (key ||
> +	    (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP))
> +		return -EOPNOTSUPP;
> +	if (!indir)
> +		return 0;
>  	memcpy(efx->rx_indir_table, indir, sizeof(efx->rx_indir_table));
>  	efx->type->rx_push_rss_config(efx);
>  	return 0;
-Edward
