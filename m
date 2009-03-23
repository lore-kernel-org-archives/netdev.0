From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 15/77] irda: convert smsc driver to net_device_ops
Date: Mon, 23 Mar 2009 12:36:03 +0100
Message-ID: <20090323113603.GL8199@sortiz.org>
References: <20090321053527.316395697@vyatta.com> <20090321053713.682844996@vyatta.com>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:52589 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755937AbZCWLdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 07:33:50 -0400
Content-Disposition: inline
In-Reply-To: <20090321053713.682844996@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2009 at 10:35:42PM -0700, Stephen Hemminger wrote:
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Samuel Ortiz <samuel@sortiz.org>

> 
> 
> ---
>  drivers/net/irda/smsc-ircc2.c |   33 +++++++++++++++++++++------------
>  1 file changed, 21 insertions(+), 12 deletions(-)
> 
> --- a/drivers/net/irda/smsc-ircc2.c	2009-03-20 12:00:24.525964199 -0700
> +++ b/drivers/net/irda/smsc-ircc2.c	2009-03-20 12:04:46.972777223 -0700
> @@ -486,6 +486,26 @@ static int __init smsc_ircc_init(void)
>  	return ret;
>  }
>  
> +static int smsc_ircc_net_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct smsc_ircc_cb *self = netdev_priv(dev);
> +
> +	if (self->io.speed > 115200)
> +		return 	smsc_ircc_hard_xmit_fir(skb, dev);
> +	else
> +		return 	smsc_ircc_hard_xmit_sir(skb, dev);
> +}
> +
> +static const struct net_device_ops smsc_ircc_netdev_ops = {
> +	.ndo_open       = smsc_ircc_net_open,
> +	.ndo_stop       = smsc_ircc_net_close,
> +	.ndo_do_ioctl   = smsc_ircc_net_ioctl,
> +	.ndo_start_xmit = smsc_ircc_net_xmit,
> +#if SMSC_IRCC2_C_NET_TIMEOUT
> +	.ndo_tx_timeout	= smsc_ircc_timeout,
> +#endif
> +};
> +
>  /*
>   * Function smsc_ircc_open (firbase, sirbase, dma, irq)
>   *
> @@ -519,14 +539,10 @@ static int __init smsc_ircc_open(unsigne
>  		goto err_out1;
>  	}
>  
> -	dev->hard_start_xmit = smsc_ircc_hard_xmit_sir;
>  #if SMSC_IRCC2_C_NET_TIMEOUT
> -	dev->tx_timeout	     = smsc_ircc_timeout;
>  	dev->watchdog_timeo  = HZ * 2;  /* Allow enough time for speed change */
>  #endif
> -	dev->open            = smsc_ircc_net_open;
> -	dev->stop            = smsc_ircc_net_close;
> -	dev->do_ioctl        = smsc_ircc_net_ioctl;
> +	dev->netdev_ops = &smsc_ircc_netdev_ops;
>  
>  	self = netdev_priv(dev);
>  	self->netdev = dev;
> @@ -995,9 +1011,6 @@ static void smsc_ircc_fir_start(struct s
>  
>  	/* Reset everything */
>  
> -	/* Install FIR transmit handler */
> -	dev->hard_start_xmit = smsc_ircc_hard_xmit_fir;
> -
>  	/* Clear FIFO */
>  	outb(inb(fir_base + IRCC_LCR_A) | IRCC_LCR_A_FIFO_RESET, fir_base + IRCC_LCR_A);
>  
> @@ -1894,7 +1907,6 @@ static void smsc_ircc_sir_start(struct s
>  	IRDA_ASSERT(self != NULL, return;);
>  	dev = self->netdev;
>  	IRDA_ASSERT(dev != NULL, return;);
> -	dev->hard_start_xmit = &smsc_ircc_hard_xmit_sir;
>  
>  	fir_base = self->io.fir_base;
>  	sir_base = self->io.sir_base;
> 
> -- 

-- 
Intel Open Source Technology Centre
http://oss.intel.com/
