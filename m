From: Niklas =?iso-8859-1?Q?S=F6derlund?=
        <niklas.soderlund@ragnatech.se>
Subject: Re: [PATCH] sh_eth: add wake-on-lan support via magic packet
Date: Mon, 12 Dec 2016 16:49:55 +0100
Message-ID: <20161212154955.GA17342@bigcity.dyn.berto.se>
References: <20161207162843.4731-1-niklas.soderlund+renesas@ragnatech.se>
 <59a1f246-9062-20e1-3f85-a1c5f6fcfc29@cogentembedded.com>
 <20161208145635.GH21834@bigcity.dyn.berto.se>
 <b0bc6386-45ba-2205-6cd4-dce9a1529124@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b0bc6386-45ba-2205-6cd4-dce9a1529124@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

Thanks for your feedback.

On 2016-12-11 00:25:41 +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 12/08/2016 05:56 PM, Niklas Söderlund wrote:
> 
> > >   You only enable the WOL support fo the R-Car gen2 chips but never say that
> > > explicitly, neither in the subject nor here.
> > > 
> > > > Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> > > > ---
> > > >  drivers/net/ethernet/renesas/sh_eth.c | 120 +++++++++++++++++++++++++++++++---
> > > >  drivers/net/ethernet/renesas/sh_eth.h |   4 ++
> > > >  2 files changed, 116 insertions(+), 8 deletions(-)
> > > 
> > > > diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> > > > index 05b0dc5..3974046 100644
> > > > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > > > +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
> > > > @@ -1657,6 +1658,10 @@ static irqreturn_t sh_eth_interrupt(int irq, void *netdev)
> > > >  		goto out;
> > > > 
> > > >  	if (!likely(mdp->irq_enabled)) {
> > > 
> > >    Oops, I guess unlikely(!mdp->irq_enabled) was meant here...
> > 
> > I can correct this in a separate patch if you wish.
> 
>    I'll look into this myself, I think.

OK.

> 
> > > +		/* Handle MagicPacket interrupt */
> > > +		if (sh_eth_read(ndev, ECSR) & ECSR_MPD)
> 
>    What if it wasn't enabled ATM?

Sorry I don't understand this comment.

> 
> [...]
> > > > @@ -3111,6 +3150,10 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
> > > >  	if (ret)
> > > >  		goto out_napi_del;
> > > > 
> > > > +	mdp->wol_enabled = false;
> > > 
> > >    No need, the '*mdp' was kzalloc'ed.
> > 
> > OK, i prefer to explicitly set for easier reading of the code. But if
> > you wish I will remove this in v2.
> 
>    Yes, remove it please.

Will remove for v2.

> 
> > > > @@ -3150,15 +3193,71 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
> > > > 
> > > >  #ifdef CONFIG_PM
> > > >  #ifdef CONFIG_PM_SLEEP
> > > > +static int sh_eth_wol_setup(struct net_device *ndev)
> > > > +{
> > > > +	struct sh_eth_private *mdp = netdev_priv(ndev);
> > > > +
> > > > +	/* Only allow ECI interrupts */
> > > > +	mdp->irq_enabled = false;
> > > 
> > >    Why 'false' if you enable IRQs below?
> > 
> > I mask all interrupts except MagicPacket (ECSIPR_MPDIP) interrupts form
> > the ECI (DMAC_M_ECI) and by setting irq_enabled to false the interrupt
> > handler will only ack any residue interrupt.
> 
>    I don't see where it ack's anything, it just clears EESIPR and returns in
> this case.

You are right, I must have misread when looking at this.

> 
> > This is how it's done in
> > other parts of the driver when disabling interrupts.
> 
>    Not in all parts of the driver that disable EESIPR interrupts... I must
> confess that I never liked that 'mdp->irq_enabled' flag and still suspect we
> can get things done without it... I need to look at this code again, sigh...
> 
> > This is also why I only check for MagicPacket interrupts if irq_enabled
> > is false.
> 
>   I would have preferred that this was done with the other EMAC interrupts,
> in sh_eth_error().

I removed the check for Magic Packet in sh_eth_interrupt() and running 
without setting mdp->irq_enabled = false. sh_eth_error() will then clear 
any ECI interrupt so no need to add Magic Packet detection to it since 
all that is needed on Magic Packet is to clear the interrupt which 
already is done. This works and I can do multiple suspend/resume cycles, 
will be in v2 thanks for the suggestion.

> 
> > > > +	synchronize_irq(ndev->irq);
> > > > +	napi_disable(&mdp->napi);
> > > > +	sh_eth_write(ndev, DMAC_M_ECI, EESIPR);
> > > > +
> > > > +	/* Enable ECI MagicPacket interrupt */
> > > > +	sh_eth_write(ndev, ECSIPR_MPDIP, ECSIPR);
> 
>    I'd prefer if it was always enabled via 'ecsipr_value'.

Will do so in v2.

> 
> > > > +
> > > > +	/* Enable MagicPacket */
> > > > +	sh_eth_modify(ndev, ECMR, 0, ECMR_PMDE);
> > > > +
> > > > +	/* Increased clock usage so device won't be suspended */
> > > > +	clk_enable(mdp->clk);
> > > 
> > >    Hum, intermixiggn runtime PM with clock API doesn't look good...
> > 
> > I agree it looks weird but I need a way to increment the usage count for
> > the clock otherwise the PM code will disable the module clock and WoL
> > will not work.
> 
>    How will it do it if you don't call sh_eth_close() in this case?
> 
> > Note that this call will not enable the clock just
> > increase the usage count so it won't be disabled when the PM code
> > decrease it after the sh_eth suspend function is run.
> 
>    You mean that the PM code calls RPM or clk API on its own? That's strange...

Yes it calls clk API.

> 
> > If you know of a different way of ensuring that the clock is not turned
> > off I be happy to look at it. I did some investigation into this and
> > calling clk_enable() directly is for example what happens in the
> > enable_irq_wake() call path to ensure the clock for the irq_chip is not
> > turned off if it is a wakeup source, se for example
> > gpio_rcar_irq_set_wake() in drivers/gpio/gpio-rcar.c.
> 
>    Thanks, will look into it...
> 
> [...]
> 
> MBR, Sergei
> 

-- 
Regards,
Niklas Söderlund
