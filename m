From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net: fec: ptp: avoid register access when ipg clock is
 disabled
Date: Mon, 21 Jul 2014 06:03:01 +0200
Message-ID: <20140721040301.GA4035@localhost.localdomain>
References: <1405910155-29760-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shawn.guo@linaro.org, b20596@freescale.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:51726 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbaGUEDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 00:03:21 -0400
Received: by mail-wi0-f173.google.com with SMTP id f8so3407131wiw.12
        for <netdev@vger.kernel.org>; Sun, 20 Jul 2014 21:03:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1405910155-29760-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 21, 2014 at 10:35:55AM +0800, Fugang Duan wrote:

> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index e0efb21..c4944e1 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -997,7 +997,7 @@ fec_restart(struct net_device *ndev)
>  	writel(ecntl, fep->hwp + FEC_ECNTRL);
>  	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
>  
> -	if (fep->bufdesc_ex)
> +	if (fep->bufdesc_ex && (fep->hwts_tx_en || fep->hwts_rx_en))
>  		fec_ptp_start_cyclecounter(ndev);
>  
>  	/* Enable interrupts we wish to service */
> @@ -1026,6 +1026,9 @@ fec_stop(struct net_device *ndev)
>  	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
>  	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
>  
> +	if (fep->bufdesc_ex && (fep->hwts_tx_en || fep->hwts_rx_en))
> +		fec_ptp_stop(ndev);

So if user space turns time stamping off, then you keep running the
timer. That is wrong, isn't it?

>  	/* We have to keep ENET enabled to have MII interrupt stay working */
>  	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
>  		writel(2, fep->hwp + FEC_ECNTRL);
> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
> index 82386b2..b2e9eb4 100644
> --- a/drivers/net/ethernet/freescale/fec_ptp.c
> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
> @@ -128,6 +128,9 @@ void fec_ptp_start_cyclecounter(struct net_device *ndev)
>  	timecounter_init(&fep->tc, &fep->cc, ktime_to_ns(ktime_get_real()));
>  
>  	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
> +
> +	if (!timer_pending(&fep->time_keep))
> +		add_timer(&fep->time_keep);

Why not use a work queue for this?

Thanks,
Richard

>  }
>  
>  /**
> @@ -390,7 +393,6 @@ void fec_ptp_init(struct platform_device *pdev)
>  	fep->time_keep.data = (unsigned long)fep;
>  	fep->time_keep.function = fec_time_keep;
>  	fep->time_keep.expires = jiffies + HZ;
> -	add_timer(&fep->time_keep);
>  
>  	fep->ptp_clock = ptp_clock_register(&fep->ptp_caps, &pdev->dev);
>  	if (IS_ERR(fep->ptp_clock)) {
> @@ -398,3 +400,20 @@ void fec_ptp_init(struct platform_device *pdev)
>  		pr_err("ptp_clock_register failed\n");
>  	}
>  }
> +
> +/*
> + * Cleanup routine for 1588 module.
> + * When FEC is stopped this routing is called
> + */
> +void fec_ptp_stop(struct net_device *ndev)
> +{
> +	struct fec_enet_private *priv = netdev_priv(ndev);
> +
> +	writel(0, priv->hwp + FEC_ATIME_CTRL);
> +	writel(FEC_T_CTRL_RESTART, priv->hwp + FEC_ATIME_CTRL);
> +
> +	priv->hwts_tx_en = 0;
> +	priv->hwts_rx_en = 0;
> +
> +	del_timer_sync(&priv->time_keep);
> +}
> -- 
> 1.7.8
> 
