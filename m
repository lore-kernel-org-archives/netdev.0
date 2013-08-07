From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2][net-next] gianfar: Add ethtool -A support for pause
 frame
Date: Wed, 7 Aug 2013 21:12:55 +0200
Message-ID: <1375902775.2644.98.camel@deadeye.wl.decadent.org.uk>
References: <1375871056-10420-1-git-send-email-claudiu.manoil@freescale.com>
	 <1375871056-10420-2-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:59020 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757051Ab3HGTNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 15:13:00 -0400
In-Reply-To: <1375871056-10420-2-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-07 at 13:24 +0300, Claudiu Manoil wrote:
> Allow Rx/Tx pause frame configuration via ethtool.
> The gfar devices feature link autonegotioation by default.

So the MAC configuration bits are actually copied to the PHY autoneg
basic page, and then the PHY autoneg result is automatically used by the
MAC?

This is of course possible to do in hardware, but... since this MAC is
not smart enough to ignore pause settings when running in half-duplex
mode, I seriously doubt it is doing all this by itself.

> The device is being configured with the new pause frame
> parameters if the link is up, depending on link duplex (no
> pause frames for half-duplex links), or during link autoneg
> (see adjust_link()).
[...]
> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
> @@ -535,6 +535,34 @@ static int gfar_sringparam(struct net_device *dev,
>  	return err;
>  }
>  
> +static void gfar_gpauseparam(struct net_device *dev,
> +			     struct ethtool_pauseparam *pause)
> +{
> +	struct gfar_private *priv = netdev_priv(dev);
> +
> +	pause->autoneg = AUTONEG_ENABLE;
> +	if (priv->rx_pause)
> +		pause->rx_pause = 1;
> +	if (priv->tx_pause)
> +		pause->tx_pause = 1;
> +}
> +
> +static int gfar_spauseparam(struct net_device *dev,
> +			    struct ethtool_pauseparam *pause)
> +{
> +	struct gfar_private *priv = netdev_priv(dev);
> +	struct phy_device *phydev = priv->phydev;

You need to reject an unsupported setting of pause->autoneg here.

Ben.

> +	priv->rx_pause = !!pause->rx_pause;
> +	priv->tx_pause = !!pause->tx_pause;
> +
> +	/* update h/w settings, if link is up */
> +	if (phydev && phydev->link)
> +		gfar_configure_pause(priv, !!phydev->duplex);
> +
> +	return 0;
> +}
> +
>  int gfar_set_features(struct net_device *dev, netdev_features_t features)
>  {
>  	struct gfar_private *priv = netdev_priv(dev);
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
