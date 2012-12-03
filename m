From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/3] net: cpsw: implement ioctl for MII
Date: Mon, 3 Dec 2012 14:16:51 +0000
Message-ID: <1354544211.7030.32.camel@deadeye.wl.decadent.org.uk>
References: <1354542569-6165-1-git-send-email-jlu@pengutronix.de>
	 <1354542569-6165-3-git-send-email-jlu@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: Jan Luebbe <jlu@pengutronix.de>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1354542569-6165-3-git-send-email-jlu@pengutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-12-03 at 14:49 +0100, Jan Luebbe wrote:
> This allows using tools like mii-diag on CPSW.
> 
> Signed-off-by: Jan Luebbe <jlu@pengutronix.de>
> ---
>  drivers/net/ethernet/ti/cpsw.c |   15 +++++++++++++++
>  1 file changed, 15 insertions(+)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 8de3e92..f476c03 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -629,6 +629,20 @@ static void cpsw_ndo_change_rx_flags(struct net_device *ndev, int flags)
>  		dev_err(&ndev->dev, "multicast traffic cannot be filtered!\n");
>  }
>  
> +static int cpsw_ndo_do_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
> +{
> +	struct cpsw_priv *priv = netdev_priv(ndev);
> +	struct phy_device *phy = priv->slaves[0].phy;
> +
> +	if (!netif_running(ndev))
> +		return -EINVAL;

This is consistent with other drivers, and I'm not going to object to
one more instance, but I don't think this is the proper error code - we
don't know that there's anything wrong with the arguments, it's just
that the *device* is in the wrong state.  I don't know what the right
error code is, though.  Really I would prefer that MDIO would work even
when the device is down, unless you know that all MDIO-manageable
devices are powered off.

Ben.

> +	if (!phy)
> +		return -ENODEV;
> +
> +	return phy_mii_ioctl(phy, rq, cmd);
> +}
> +
>  static void cpsw_ndo_tx_timeout(struct net_device *ndev)
>  {
>  	struct cpsw_priv *priv = netdev_priv(ndev);
> @@ -670,6 +684,7 @@ static const struct net_device_ops cpsw_netdev_ops = {
>  	.ndo_start_xmit		= cpsw_ndo_start_xmit,
>  	.ndo_change_rx_flags	= cpsw_ndo_change_rx_flags,
>  	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_do_ioctl		= cpsw_ndo_do_ioctl,
>  	.ndo_change_mtu		= eth_change_mtu,
>  	.ndo_tx_timeout		= cpsw_ndo_tx_timeout,
>  	.ndo_get_stats		= cpsw_ndo_get_stats,

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

