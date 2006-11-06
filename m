From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH/RFC] add netpoll support for gianfar
Date: Mon, 6 Nov 2006 15:26:33 -0600
Message-ID: <D22C8326-01E3-428C-B1EE-F87B1232BDB4@freescale.com>
References: <20061106141958.00002c6c.vwool@ru.mvista.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:10948 "EHLO
	az33egw01.freescale.net") by vger.kernel.org with ESMTP
	id S1753813AbWKFV1T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Nov 2006 16:27:19 -0500
In-Reply-To: <20061106141958.00002c6c.vwool@ru.mvista.com>
To: Vitaly Wool <vwool@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Nov 6, 2006, at 05:19, Vitaly Wool wrote:

> The patch inlined below adds NET_POLL_CONTROLLER support for  
> gianfar network driver.
>
>  drivers/net/gianfar.c |   34 ++++++++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
>
> Signed-off-by: Vitaly Wool <vwool@ru.mvista.com>
>
> Index: powerpc/drivers/net/gianfar.c
> ===================================================================
> --- powerpc.orig/drivers/net/gianfar.c
> +++ powerpc/drivers/net/gianfar.c
> @@ -133,6 +133,9 @@ static void gfar_set_hash_for_addr(struc
>  #ifdef CONFIG_GFAR_NAPI
>  static int gfar_poll(struct net_device *dev, int *budget);
>  #endif
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void gfar_netpoll(struct net_device *dev);
> +#endif
>  int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit);
>  static int gfar_process_frame(struct net_device *dev, struct  
> sk_buff *skb, int length);
>  static void gfar_vlan_rx_register(struct net_device *netdev,
> @@ -260,6 +263,9 @@ static int gfar_probe(struct platform_de
>  	dev->poll = gfar_poll;
>  	dev->weight = GFAR_DEV_WEIGHT;
>  #endif
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	dev->poll_controller = gfar_netpoll;
> +#endif
>  	dev->stop = gfar_close;
>  	dev->get_stats = gfar_get_stats;
>  	dev->change_mtu = gfar_change_mtu;
> @@ -1536,6 +1542,34 @@ static int gfar_poll(struct net_device *
>  }
>  #endif
>
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +/*
> + * Polling 'interrupt' - used by things like netconsole to send skbs
> + * without having to re-enable interrupts. It's not called while
> + * the interrupt routine is executing.
> + */
> +static void gfar_netpoll(struct net_device *dev)
> +{
> +	struct gfar_private *priv = netdev_priv(dev);
> +
> +	/* If the device has multiple interrupts, run tx/rx */
> +	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
> +		disable_irq(priv->interruptTransmit);
> +		disable_irq(priv->interruptReceive);
> +		disable_irq(priv->interruptError);
> +		gfar_transmit(priv->interruptTransmit, dev, NULL);
> +		gfar_receive(priv->interruptReceive, dev, NULL);


You are passing extra arguments, here


> +		enable_irq(priv->interruptError);
> +		enable_irq(priv->interruptReceive);
> +		enable_irq(priv->interruptTransmit);
> +	} else {
> +		disable_irq(priv->interruptTransmit);
> +		gfar_interrupt(priv->interruptTransmit, dev, NULL);


and here (pt_regs got eliminated).

Also, a few more comments:

1) Do we need the disable/enable irq stuff?  It seems like we should  
be able to either just *mask* the interrupts at the controller, or  
rely on the locks to disable the interrupts.

2) If we are calling gfar_transmit and gfar_receive, shouldn't we  
call gfar_error?

3) I think it should be possible to just call gfar_interrupt() in  
every situation, but I'm not very familiar with net poll's  
requirements (You can add that into your evaluation of #1, too).

Andy


