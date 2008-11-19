From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 30/33] tg3: convert to net_device_ops
Date: Wed, 19 Nov 2008 13:04:47 -0800
Message-ID: <20081119210447.GA26448@xw6200.broadcom.net>
References: <20081117234207.854110282@vyatta.com>
 <20081117234357.345529638@vyatta.com> <20081117173706.31960184@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3151 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753085AbYKSVEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 16:04:54 -0500
In-Reply-To: <20081117173706.31960184@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 17, 2008 at 05:37:06PM -0800, Stephen Hemminger wrote:
> Convert this driver to network device ops.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> Handle non-vlan build.
> 
> --- a/drivers/net/tg3.c	2008-11-17 17:21:58.000000000 -0800
> +++ b/drivers/net/tg3.c	2008-11-17 17:26:45.000000000 -0800
> @@ -13343,6 +13343,24 @@ static void __devinit tg3_init_coal(stru
>  	}
>  }
>  
> +static const struct net_device_ops tg3_netdev_ops = {
> +	.open			= tg3_open,
> +	.stop			= tg3_close,

One more completely trivial nit.  Is there a reason why you chose
the verbs to be "open" and "stop" rather than "open" and "close" or
"start" and "stop"?

> +	.get_stats		= tg3_get_stats,
> +	.validate_addr		= eth_validate_addr,
> +	.set_multicast_list	= tg3_set_rx_mode,
> +	.set_mac_address	= tg3_set_mac_addr,
> +	.do_ioctl		= tg3_ioctl,
> +	.tx_timeout		= tg3_tx_timeout,
> +	.change_mtu		= tg3_change_mtu,
> +#if TG3_VLAN_TAG_USED
> +	.vlan_rx_register	= tg3_vlan_rx_register,
> +#endif
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	.poll_controller	= tg3_poll_controller,
> +#endif
> +};
> +
>  static int __devinit tg3_init_one(struct pci_dev *pdev,
>  				  const struct pci_device_id *ent)
>  {
> @@ -13400,7 +13418,6 @@ static int __devinit tg3_init_one(struct
>  
>  #if TG3_VLAN_TAG_USED
>  	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
> -	dev->vlan_rx_register = tg3_vlan_rx_register;
>  #endif
>  
>  	tp = netdev_priv(dev);
> @@ -13458,21 +13475,11 @@ static int __devinit tg3_init_one(struct
>  	tp->rx_jumbo_pending = TG3_DEF_RX_JUMBO_RING_PENDING;
>  	tp->tx_pending = TG3_DEF_TX_RING_PENDING;
>  
> -	dev->open = tg3_open;
> -	dev->stop = tg3_close;
> -	dev->get_stats = tg3_get_stats;
> -	dev->set_multicast_list = tg3_set_rx_mode;
> -	dev->set_mac_address = tg3_set_mac_addr;
> -	dev->do_ioctl = tg3_ioctl;
> -	dev->tx_timeout = tg3_tx_timeout;
> +	dev->netdev_ops = &tg3_netdev_ops;
>  	netif_napi_add(dev, &tp->napi, tg3_poll, 64);
>  	dev->ethtool_ops = &tg3_ethtool_ops;
>  	dev->watchdog_timeo = TG3_TX_TIMEOUT;
> -	dev->change_mtu = tg3_change_mtu;
>  	dev->irq = pdev->irq;
> -#ifdef CONFIG_NET_POLL_CONTROLLER
> -	dev->poll_controller = tg3_poll_controller;
> -#endif
>  
>  	err = tg3_get_invariants(tp);
>  	if (err) {
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


