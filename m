From: Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>
Subject: Re: [net-next PATCH v2 3/3] drivers: net: cpsw: Add support for
 multicast/broadcast rate limit
Date: Wed, 9 Jul 2014 19:09:58 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1407091904170.16937@ws.cisco>
References: <1404890050-4020-1-git-send-email-mugunthanvnm@ti.com> <1404890050-4020-4-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1404890050-4020-4-git-send-email-mugunthanvnm-l0cyMroinI0@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On Wed, 9 Jul 2014, Mugunthan V N wrote:

> Add support for multicast/broadcast rate limit feature via ethtool coalesce.
>
> Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
> ---
> drivers/net/ethernet/ti/cpsw.c | 80 ++++++++++++++++++++++++++++++++++++++++--
> 1 file changed, 78 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index a6117e6..2a984e6 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -403,6 +403,8 @@ struct cpsw_priv {
> 	bool irq_enabled;
> 	struct cpts *cpts;
> 	u32 emac_port;
> +	u32 rx_max_mcast;
> +	u32 rx_max_bcast;
> };
>
> struct cpsw_stats {
> @@ -871,11 +873,13 @@ static int cpsw_get_coalesce(struct net_device *ndev,
> 	struct cpsw_priv *priv = netdev_priv(ndev);
>
> 	coal->rx_coalesce_usecs = priv->coal_intvl;
> +	coal->rx_max_mcast = priv->rx_max_mcast;
> +	coal->rx_max_bcast = priv->rx_max_bcast;
> 	return 0;
> }
>
> -static int cpsw_set_coalesce(struct net_device *ndev,
> -				struct ethtool_coalesce *coal)
> +static int cpsw_set_coalesce_usecs(struct net_device *ndev,
> +				   struct ethtool_coalesce *coal)
> {
> 	struct cpsw_priv *priv = netdev_priv(ndev);
> 	u32 int_ctrl;
> @@ -933,6 +937,74 @@ static int cpsw_set_coalesce(struct net_device *ndev,
> 	return 0;
> }
>
> +static int cpsw_set_coalesce_mcast(struct net_device *ndev,
> +				   struct ethtool_coalesce *coal)
> +{
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +	int port;
> +
> +	priv->rx_max_mcast = coal->rx_max_mcast;
> +
> +	if (priv->data.dual_emac)
> +		port = priv->emac_port;
> +	else
> +		port = priv->data.active_slave;
> +
> +	cpsw_ale_control_set(priv->ale, port, ALE_PORT_MCAST_LIMIT,
> +			     coal->rx_max_mcast);
> +
> +	dev_dbg(priv->dev, "rx_max_mcast set to %d\n", priv->rx_max_mcast);
> +	return 0;
> +}
> +
> +static int cpsw_set_coalesce_bcast(struct net_device *ndev,
> +				   struct ethtool_coalesce *coal)
> +{
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +	int port;
> +
> +	priv->rx_max_bcast = coal->rx_max_bcast;
> +
> +	if (priv->data.dual_emac)
> +		port = priv->emac_port + 1;
> +	else
> +		port = priv->data.active_slave + 1;
> +
> +	cpsw_ale_control_set(priv->ale, port, ALE_PORT_BCAST_LIMIT,
> +			     coal->rx_max_bcast);

Both cpsw_set_coalesce_bcast & cpsw_set_coalesce_mcast always return 0.
May be you can return result of cpsw_ale_control_set()?

> +
> +	dev_dbg(priv->dev, "rx_max_mcast set to %d\n", priv->rx_max_bcast);
> +	return 0;
> +}
> +
> +static int cpsw_set_coalesce(struct net_device *ndev,
> +			     struct ethtool_coalesce *coal)
> +{
> +	int ret = -EINVAL;
> +
> +	if (coal->rx_coalesce_usecs) {
> +		ret = cpsw_set_coalesce_usecs(ndev, coal);
> +		if (ret) {
> +			dev_err(&ndev->dev, "set rx-usecs failed\n");
> +			return ret;
> +		}
> +	}
> +
> +	ret = cpsw_set_coalesce_mcast(ndev, coal);
> +	if (ret) {
> +		dev_err(&ndev->dev, "set coalesce rx-max-mcast failed\n");
> +		return ret;
> +	}

So that ret check here will be meaningful.

thanks
> +
> +	ret = cpsw_set_coalesce_bcast(ndev, coal);
> +	if (ret) {
> +		dev_err(&ndev->dev, "set coalesce rx-max-bcast failed\n");
> +		return ret;
> +	}
> +
> +	return ret;
> +}
> +
> static int cpsw_get_sset_count(struct net_device *ndev, int sset)
> {
> 	switch (sset) {
> @@ -1227,6 +1299,10 @@ static int cpsw_ndo_open(struct net_device *ndev)
> 		/* enable statistics collection only on all ports */
> 		__raw_writel(0x7, &priv->regs->stat_port_en);
>
> +		/* Enable rate limit feature in the switch for rx only */
> +		cpsw_ale_control_set(priv->ale, 0, ALE_RATE_LIMIT, 1);
> +		cpsw_ale_control_set(priv->ale, 0, ALE_RATE_LIMIT_TX, 0);
> +
> 		if (WARN_ON(!priv->data.rx_descs))
> 			priv->data.rx_descs = 128;
>
> -- 
> 2.0.0.390.gcb682f8
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
