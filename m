From: David Miller <davem@davemloft.net>
Subject: Re: net_device_ops support in bridging and fec_mpc52xx.c
Date: Wed, 18 Feb 2009 13:48:52 -0800 (PST)
Message-ID: <20090218.134852.118040610.davem__29353.1294017614$1234993883$gmane$org@davemloft.net>
References: <ae4f76fd0902180241s28458450hd91ebf8da94ceb53@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, bridge@osdl.org, netdev@vger.kernel.org
To: henk.stegeman@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55592
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757691AbZBRVtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 16:49:09 -0500
In-Reply-To: <ae4f76fd0902180241s28458450hd91ebf8da94ceb53@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henk Stegeman <henk.stegeman@gmail.com>
Date: Wed, 18 Feb 2009 11:41:14 +0100

Please CC: netdev, now added, on all networking reports and patches.

Thank you.

> I discovered the hard way that because linux bridging uses
> net_device_ops, bridging only works with network drivers that publish
> their device operations trough net_device_ops.
> 
> In my case running:
> 
> brctl addif br0 eth0 (where eth0 fec_mpc52xx.c did not yet support
> net_device_ops) gave me a:
> 
> Unable to handle kernel paging request...
> 
> After changing fec_mpc52xx.c to support net_device_ops the problem was fixed.
> 
> If possible some kind of detection in the bridging software is i think
> mostly appreciated for early detection of this problem, as it is
> pretty hard to relate the error message to a not updated driver.
> 
> cheers,
> 
> Henk
> 
> diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
> index cd8e98b..a2841eb 100644
> --- a/drivers/net/fec_mpc52xx.c
> +++ b/drivers/net/fec_mpc52xx.c
> @@ -888,6 +888,22 @@ static int mpc52xx_fec_ioctl(struct net_device
> *dev, struct ifreq *rq, int cmd)
>  /* ======================================================================== */
>  /* OF Driver                                                                */
>  /* ======================================================================== */
> +static const struct net_device_ops mpc52xx_fec_netdev_ops = {
> +       .ndo_open               = mpc52xx_fec_open,
> +       .ndo_stop               = mpc52xx_fec_close,
> +       .ndo_start_xmit         = mpc52xx_fec_hard_start_xmit,
> +       .ndo_tx_timeout         = mpc52xx_fec_tx_timeout,
> +       .ndo_get_stats          = mpc52xx_fec_get_stats,
> +       .ndo_set_multicast_list = mpc52xx_fec_set_multicast_list,
> +       .ndo_validate_addr      = eth_validate_addr,
> +       .ndo_set_mac_address    = mpc52xx_fec_set_mac_address,
> +       .ndo_do_ioctl           = mpc52xx_fec_ioctl,
> +
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +       .ndo_poll_controller     = mpc52xx_fec_poll_controller,
> +#endif
> +};
> +
> 
>  static int __devinit
>  mpc52xx_fec_probe(struct of_device *op, const struct of_device_id *match)
> @@ -929,20 +945,7 @@ mpc52xx_fec_probe(struct of_device *op, const
> struct of_device_id *match)
>  		return -EBUSY;
> 
>  	/* Init ether ndev with what we have */
> -	ndev->open		= mpc52xx_fec_open;
> -	ndev->stop		= mpc52xx_fec_close;
> -	ndev->hard_start_xmit	= mpc52xx_fec_hard_start_xmit;
> -	ndev->do_ioctl		= mpc52xx_fec_ioctl;
> -	ndev->ethtool_ops	= &mpc52xx_fec_ethtool_ops;
> -	ndev->get_stats		= mpc52xx_fec_get_stats;
> -	ndev->set_mac_address	= mpc52xx_fec_set_mac_address;
> -	ndev->set_multicast_list = mpc52xx_fec_set_multicast_list;
> -	ndev->tx_timeout	= mpc52xx_fec_tx_timeout;
> -	ndev->watchdog_timeo	= FEC_WATCHDOG_TIMEOUT;
> -	ndev->base_addr		= mem.start;
> -#ifdef CONFIG_NET_POLL_CONTROLLER
> -	ndev->poll_controller = mpc52xx_fec_poll_controller;
> -#endif
> +	ndev->netdev_ops = &mpc52xx_fec_netdev_ops;
> 
>  	priv->t_irq = priv->r_irq = ndev->irq = NO_IRQ; /* IRQ are free for now */
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@ozlabs.org
> https://ozlabs.org/mailman/listinfo/linuxppc-dev
