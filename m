From: "Niklas =?iso-8859-1?Q?S=F6derlund?=" <niklas.soderlund@ragnatech.se>
Subject: Re: [PATCH] sh_eth: add wake-on-lan support via magic packet
Date: Thu, 8 Dec 2016 15:56:35 +0100
Message-ID: <20161208145635.GH21834@bigcity.dyn.berto.se>
References: <20161207162843.4731-1-niklas.soderlund+renesas@ragnatech.se>
 <59a1f246-9062-20e1-3f85-a1c5f6fcfc29@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <59a1f246-9062-20e1-3f85-a1c5f6fcfc29@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

Thanks for your feedback.

On 2016-12-08 15:28:48 +0300, Sergei Shtylyov wrote:
> Hello!
> 
>    Good to see that somebody cares still about this driver, one more task
> off my back. :-)
> 
> On 12/07/2016 07:28 PM, Niklas Söderlund wrote:
> 
>   You only enable the WOL support fo the R-Car gen2 chips but never say that
> explicitly, neither in the subject nor here.
> 
> > Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> > ---
> >  drivers/net/ethernet/renesas/sh_eth.c | 120 +++++++++++++++++++++++++++++++---
> >  drivers/net/ethernet/renesas/sh_eth.h |   4 ++
> >  2 files changed, 116 insertions(+), 8 deletions(-)
> 
> > diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> > index 05b0dc5..3974046 100644
> > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > +++ b/drivers/net/ethernet/renesas/sh_eth.c
> > @@ -624,7 +624,7 @@ static struct sh_eth_cpu_data r8a779x_data = {
> > 
> >  	.register_type	= SH_ETH_REG_FAST_RCAR,
> > 
> > -	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD,
> > +	.ecsr_value	= ECSR_PSRTO | ECSR_LCHNG | ECSR_ICD | ECSR_MPD,
> >  	.ecsipr_value	= ECSIPR_PSRTOIP | ECSIPR_LCHNGIP | ECSIPR_ICDIP,
> >  	.eesipr_value	= 0x01ff009f,
> > 
> > @@ -641,6 +641,7 @@ static struct sh_eth_cpu_data r8a779x_data = {
> >  	.tpauser	= 1,
> >  	.hw_swap	= 1,
> >  	.rmiimode	= 1,
> > +	.magic		= 1,
> >  };
> >  #endif /* CONFIG_OF */
> 
>    So I suggest that you add the general WOL support code in the 1st patch
> and enable the new feature per SoC family in the follow up patches.

Ok I will split this up in v2.

> 
> > @@ -1657,6 +1658,10 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
> >  		goto out;
> > 
> >  	if (!likely(mdp->irq_enabled)) {
> 
>    Oops, I guess unlikely(!mdp->irq_enabled) was meant here...

I can correct this in a separate patch if you wish.

> 
> > +		/* Handle MagicPacket interrupt */
> > +		if (sh_eth_read(ndev, ECSR) & ECSR_MPD)
> 
>    Why do it here?

See bellow.

> 
> > +			sh_eth_modify(ndev, ECSR, 0, ECSR_MPD);
> > +
> >  		sh_eth_write(ndev, 0, EESIPR);
> >  		goto out;
> >  	}
> [...]
> > @@ -3017,6 +3051,11 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
> >  		goto out_release;
> >  	}
> > 
> > +	/* Get clock, if not found that's OK but Wake-On-Lan is unavailable */
> > +	mdp->clk = devm_clk_get(&pdev->dev, NULL);
> 
>    Luckily, we have <linux/clk.h> #include'd...
> 
> > +	if (IS_ERR(mdp->clk))
> > +		mdp->clk = NULL;
> > +
> >  	ndev->base_addr = res->start;
> > 
> >  	spin_lock_init(&mdp->lock);
> > @@ -3111,6 +3150,10 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
> >  	if (ret)
> >  		goto out_napi_del;
> > 
> > +	mdp->wol_enabled = false;
> 
>    No need, the '*mdp' was kzalloc'ed.

OK, i prefer to explicitly set for easier reading of the code. But if 
you wish I will remove this in v2.

> 
> > +	if (mdp->cd->magic && mdp->clk)
> > +		device_set_wakeup_capable(&pdev->dev, 1);
> > +
> >  	/* print device information */
> >  	netdev_info(ndev, "Base address at 0x%x, %pM, IRQ %d.\n",
> >  		    (u32)ndev->base_addr, ndev->dev_addr, ndev->irq);
> > @@ -3150,15 +3193,71 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
> > 
> >  #ifdef CONFIG_PM
> >  #ifdef CONFIG_PM_SLEEP
> > +static int sh_eth_wol_setup(struct net_device *ndev)
> > +{
> > +	struct sh_eth_private *mdp = netdev_priv(ndev);
> > +
> > +	/* Only allow ECI interrupts */
> > +	mdp->irq_enabled = false;
> 
>    Why 'false' if you enable IRQs below?

I mask all interrupts except MagicPacket (ECSIPR_MPDIP) interrupts form 
the ECI (DMAC_M_ECI) and by setting irq_enabled to false the interrupt 
handler will only ack any residue interrupt. This is how it's done in 
other parts of the driver when disabling interrupts.

This is also why I only check for MagicPacket interrupts if irq_enabled 
is false.

> 
> > +	synchronize_irq(ndev->irq);
> > +	napi_disable(&mdp->napi);
> > +	sh_eth_write(ndev, DMAC_M_ECI, EESIPR);
> > +
> > +	/* Enable ECI MagicPacket interrupt */
> > +	sh_eth_write(ndev, ECSIPR_MPDIP, ECSIPR);
> > +
> > +	/* Enable MagicPacket */
> > +	sh_eth_modify(ndev, ECMR, 0, ECMR_PMDE);
> > +
> > +	/* Increased clock usage so device won't be suspended */
> > +	clk_enable(mdp->clk);
> 
>    Hum, intermixiggn runtime PM with clock API doesn't look good...

I agree it looks weird but I need a way to increment the usage count for 
the clock otherwise the PM code will disable the module clock and WoL 
will not work. Note that this call will not enable the clock just 
increase the usage count so it won't be disabled when the PM code 
decrease it after the sh_eth suspend function is run.

If you know of a different way of ensuring that the clock is not turned 
off I be happy to look at it. I did some investigation into this and 
calling clk_enable() directly is for example what happens in the 
enable_irq_wake() call path to ensure the clock for the irq_chip is not 
turned off if it is a wakeup source, se for example 
gpio_rcar_irq_set_wake() in drivers/gpio/gpio-rcar.c.

> 
> > +
> > +	return enable_irq_wake(ndev->irq);
> > +}
> > +
> > +static int sh_eth_wol_restore(struct net_device *ndev)
> > +{
> > +	struct sh_eth_private *mdp = netdev_priv(ndev);
> > +	int ret;
> > +
> > +	napi_enable(&mdp->napi);
> > +
> > +	/* Disable MagicPacket */
> > +	sh_eth_modify(ndev, ECMR, ECMR_PMDE, 0);
> > +
> > +	/* The device need to be reset to restore MagicPacket logic
> > +	 * for next wakeup. If we close and open the device it will
> > +	 * both be reset and all registers restored. This is what
> > +	 * happens during suspend and resume without WoL enabled.
> > +	 */
> > +	ret = sh_eth_close(ndev);
> > +	if (ret < 0)
> > +		return ret;
> > +	ret = sh_eth_open(ndev);
> > +	if (ret < 0)
> > +		return ret;
> > +
> > +	/* Restore clock usage count */
> > +	clk_disable(mdp->clk);
> 
>    Hm... and RPM will think the clock is still enabled?
> Why disable the clock here anyway if we're resuming?

This call is needed to decrease the usage count for the clock we 
increased with clk_enable() in the suspend path.

> 
> > +
> > +	return disable_irq_wake(ndev->irq);
> > +}
> > +
> [...]
> > @@ -3166,14 +3265,19 @@ static int sh_eth_suspend(struct device *dev)
> >  static int sh_eth_resume(struct device *dev)
> >  {
> >  	struct net_device *ndev = dev_get_drvdata(dev);
> > +	struct sh_eth_private *mdp = netdev_priv(ndev);
> >  	int ret = 0;
> > 
> > -	if (netif_running(ndev)) {
> > +	if (!netif_running(ndev))
> > +		return 0;
> > +
> > +	if (mdp->wol_enabled)
> > +		ret = sh_eth_wol_restore(ndev);
> > +	else
> >  		ret = sh_eth_open(ndev);
> > -		if (ret < 0)
> > -			return ret;
> > +
> > +	if (!ret)
> 
>    Please keep the original error return logic, so that you can return 0 at
> the end...

Will fix for v2.

> 
> >  		netif_device_attach(ndev);
> > -	}
> > 
> >  	return ret;
> >  }
> > diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
> > index d050f37..26c6620 100644
> > --- a/drivers/net/ethernet/renesas/sh_eth.h
> > +++ b/drivers/net/ethernet/renesas/sh_eth.h
> > @@ -493,6 +493,7 @@ struct sh_eth_cpu_data {
> >  	unsigned shift_rd0:1;	/* shift Rx descriptor word 0 right by 16 */
> >  	unsigned rmiimode:1;	/* EtherC has RMIIMODE register */
> >  	unsigned rtrate:1;	/* EtherC has RTRATE register */
> > +	unsigned magic:1;	/* EtherC have PMDE in ECMR and MPDIP in ECSIPR */
> 
>    OK, e.g. RZ/A1 doesn't have these bits...
> 
> [...]
> 
> MBR, Sergei
> 

-- 
Regards,
Niklas Söderlund
