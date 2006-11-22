From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] ieee80211: Provide generic get_stats implementation
Date: Tue, 21 Nov 2006 21:32:50 -0600
Message-ID: <4563C4E2.3090109@lwfinger.net>
References: <20061122031546.4C1767B40A0@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, mb@bu3sch.de,
	ipw2100-admin@linux.intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:36065 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S967034AbWKVDdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 22:33:20 -0500
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20061122031546.4C1767B40A0@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Drake wrote:
> bcm43xx and ipw2100 currently duplicate the same simplistic get_stats handler.
> Additionally, zd1211rw requires the same handler to fix a bug where all stats
> are reported as 0.
> 
> This patch adds a generic implementation to the ieee80211 layer, which drivers
> are free to override.
> 
> Signed-off-by: Daniel Drake <dsd@gentoo.org>

ACK for the bcm43xx and ieee80211 parts. I cannot test the ipw2100 section.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> 
> ---
> 
> Sorry for sending twice, forgot to CC netdev the first time
> 
> Index: linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> ===================================================================
> --- linux.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> +++ linux/drivers/net/wireless/bcm43xx/bcm43xx_main.c
> @@ -4045,11 +4045,6 @@ static int bcm43xx_ieee80211_hard_start_
>  	return NETDEV_TX_OK;
>  }
>  
> -static struct net_device_stats * bcm43xx_net_get_stats(struct net_device *net_dev)
> -{
> -	return &(bcm43xx_priv(net_dev)->ieee->stats);
> -}
> -
>  static void bcm43xx_net_tx_timeout(struct net_device *net_dev)
>  {
>  	struct bcm43xx_private *bcm = bcm43xx_priv(net_dev);
> @@ -4163,7 +4158,6 @@ static int __devinit bcm43xx_init_one(st
>  
>  	net_dev->open = bcm43xx_net_open;
>  	net_dev->stop = bcm43xx_net_stop;
> -	net_dev->get_stats = bcm43xx_net_get_stats;
>  	net_dev->tx_timeout = bcm43xx_net_tx_timeout;
>  #ifdef CONFIG_NET_POLL_CONTROLLER
>  	net_dev->poll_controller = bcm43xx_net_poll_controller;
> Index: linux/drivers/net/wireless/ipw2100.c
> ===================================================================
> --- linux.orig/drivers/net/wireless/ipw2100.c
> +++ linux/drivers/net/wireless/ipw2100.c
> @@ -5827,19 +5827,6 @@ static void ipw2100_tx_timeout(struct ne
>  	schedule_reset(priv);
>  }
>  
> -/*
> - * TODO: reimplement it so that it reads statistics
> - *       from the adapter using ordinal tables
> - *       instead of/in addition to collecting them
> - *       in the driver
> - */
> -static struct net_device_stats *ipw2100_stats(struct net_device *dev)
> -{
> -	struct ipw2100_priv *priv = ieee80211_priv(dev);
> -
> -	return &priv->ieee->stats;
> -}
> -
>  static int ipw2100_wpa_enable(struct ipw2100_priv *priv, int value)
>  {
>  	/* This is called when wpa_supplicant loads and closes the driver
> @@ -6022,7 +6009,6 @@ static struct net_device *ipw2100_alloc_
>  	dev->open = ipw2100_open;
>  	dev->stop = ipw2100_close;
>  	dev->init = ipw2100_net_init;
> -	dev->get_stats = ipw2100_stats;
>  	dev->ethtool_ops = &ipw2100_ethtool_ops;
>  	dev->tx_timeout = ipw2100_tx_timeout;
>  	dev->wireless_handlers = &ipw2100_wx_handler_def;
> Index: linux/net/ieee80211/ieee80211_module.c
> ===================================================================
> --- linux.orig/net/ieee80211/ieee80211_module.c
> +++ linux/net/ieee80211/ieee80211_module.c
> @@ -126,6 +126,13 @@ static int ieee80211_change_mtu(struct n
>  	return 0;
>  }
>  
> +static struct net_device_stats *ieee80211_generic_get_stats(
> +	struct net_device *dev)
> +{
> +	struct ieee80211_device *ieee = netdev_priv(dev);
> +	return &ieee->stats;
> +}
> +
>  struct net_device *alloc_ieee80211(int sizeof_priv)
>  {
>  	struct ieee80211_device *ieee;
> @@ -143,6 +150,10 @@ struct net_device *alloc_ieee80211(int s
>  	dev->hard_start_xmit = ieee80211_xmit;
>  	dev->change_mtu = ieee80211_change_mtu;
>  
> +	/* Drivers are free to override this if the generic implementation
> +	 * does not meet their needs. */
> +	dev->get_stats = ieee80211_generic_get_stats;
> +
>  	ieee->dev = dev;
>  
>  	err = ieee80211_networks_allocate(ieee);
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

