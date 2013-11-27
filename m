From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 1/8] net: smc91x: Fix device tree based configuration
 so it's usable
Date: Wed, 27 Nov 2013 10:36:30 -0800
Message-ID: <20131127183629.GZ26766@atomide.com>
References: <1384396537-3486-1-git-send-email-tony@atomide.com>
 <1384396537-3486-2-git-send-email-tony@atomide.com>
 <20131114110324.GC16396@e106331-lin.cambridge.arm.com>
 <20131114160813.GC10317@atomide.com>
 <20131116151640.GJ10317@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131116151640.GJ10317@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Tony Lindgren <tony@atomide.com> [131116 07:17]:
>
> Here's what I was thinking with the reg-io-width-mask. Anybody
> have comments on using reg-io-width vs reg-io-width-mask?
...

> --- a/drivers/net/ethernet/smsc/smc91x.c
> +++ b/drivers/net/ethernet/smsc/smc91x.c
> @@ -2222,11 +2234,31 @@ static int smc_drv_probe(struct platform_device *pdev)
>  	 */
>  
>  	lp = netdev_priv(ndev);
> +	lp->cfg.flags = 0;
>  
>  	if (pd) {
>  		memcpy(&lp->cfg, pd, sizeof(lp->cfg));
>  		lp->io_shift = SMC91X_IO_SHIFT(lp->cfg.flags);
> -	} else {
> +	}
> +
> +#if IS_BUILTIN(CONFIG_OF)
> +	match = of_match_device(of_match_ptr(smc91x_match), &pdev->dev);
> +	if (match) {
> +		u32 val;
> +
> +		of_property_read_u32(np, "reg-io-width", &val);
> +		if (val == 0)
> +			lp->cfg.flags |= SMC91X_USE_16BIT;
> +		if (val & 1)
> +			lp->cfg.flags |= SMC91X_USE_8BIT;
> +		if (val & 2)
> +			lp->cfg.flags |= SMC91X_USE_16BIT;
> +		if (val & 4)
> +			lp->cfg.flags |= SMC91X_USE_32BIT;
> +	}
> +#endif
> +
> +	if (!pd && !match) {
>  		lp->cfg.flags |= (SMC_CAN_USE_8BIT)  ? SMC91X_USE_8BIT  : 0;
>  		lp->cfg.flags |= (SMC_CAN_USE_16BIT) ? SMC91X_USE_16BIT : 0;
>  		lp->cfg.flags |= (SMC_CAN_USE_32BIT) ? SMC91X_USE_32BIT : 0;

Looks this patch is missing the check for the return value for
of_property_read_u32(), will repost this patch separately as the
others in this series are out of the way now.

Regards,

Tony
