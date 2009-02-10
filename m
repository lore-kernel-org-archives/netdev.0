From: Tony Lindgren <tony@atomide.com>
Subject: Re: Remaining bits for basic support of LDP
Date: Tue, 10 Feb 2009 13:02:02 -0800
Message-ID: <20090210210159.GK14200@atomide.com>
References: <20090202213953.GB16069@n2100.arm.linux.org.uk> <20090202.134530.63616213.davem@davemloft.net> <20090202222909.GC16069@n2100.arm.linux.org.uk> <20090210114855.GA9746@n2100.arm.linux.org.uk> <20090210115615.GA9869@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090210115615.GA9869@n2100.arm.linux.org.uk>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Russell King - ARM Linux <linux@arm.linux.org.uk> [090210 03:56]:
> On Tue, Feb 10, 2009 at 11:48:55AM +0000, Russell King - ARM Linux wrote:
> > On Mon, Feb 02, 2009 at 10:29:09PM +0000, Russell King - ARM Linux wrote:
> > > On Mon, Feb 02, 2009 at 01:45:30PM -0800, David Miller wrote:
> > > > From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> > > > Date: Mon, 2 Feb 2009 21:39:53 +0000
> > > > 
> > > > > The patch to fix these issues would seem to be relatively small (12
> > > > > lines in the smc911x and one line change in board-ldp.c) - is it
> > > > > something we want done for -rc4 or do we scrap the ethernet support 
> > > > > on the LDP until the SMSC driver has been merged ?
> > > > > 
> > > > > Obviously, having working ethernet would be helpful, and since it was
> > > > > half heartedly merged when the initial OMAP3 stuff went upstream we
> > > > > should do something with it one way or another.
> > > > 
> > > > Well, the SMSC driver is there already in the tree.
> > > >
> > > > The only thing not currently being scheduled to hit
> > > > 2.6.29-rcX are the recent changes to support platform
> > > > specified interrupt flags and all of that stuff.
> > > > 
> > > > If you want, we can look into pushing that work into
> > > > 2.6.29-rcX
> > > 
> > > Hmm.  Since we should assume that the other smc911x using platforms work
> > > as-is, merging Steve's first four and the LDP patch seems to be a sane
> > > idea.  We can queue the remainder for when bugs are reported or the
> > > next merge window, whichever comes earlier.
> > 
> > So, what's happening on this?
> 
> For the record, this is what the patch for fixing smc911x to work on
> the LDP looks like.  It's been tested on the LDP and works.  It has
> a minimal impact, so this is probably a better patch to merge for
> 2.6.29 rather than the smsc911x conversion patches which are more
> invasive.

Yeah, the smsc updates for omap might take a while longer to get going.
So here's my ack for this smc911x patch:

Acked-by: Tony Lindgren <tony@atomide.com>

For the smsc changes, I don't have an LDP to test with. But I'll try
to get another board to work with smsc now that I have some MMC voltage
weirdness out of the way and have a proper root on MMC :) That is after
I have musb working on it so I can scp the module over g_ether..

Regards,

Tony

> diff --git a/arch/arm/mach-omap2/board-ldp.c b/arch/arm/mach-omap2/board-ldp.c
> index 61f7c36..d544965 100644
> --- a/arch/arm/mach-omap2/board-ldp.c
> +++ b/arch/arm/mach-omap2/board-ldp.c
> @@ -81,7 +87,7 @@ static inline void __init ldp_init_smc911x(void)
>  	}
>  
>  	ldp_smc911x_resources[0].start = cs_mem_base + 0x0;
> -	ldp_smc911x_resources[0].end   = cs_mem_base + 0xf;
> +	ldp_smc911x_resources[0].end   = cs_mem_base + 0xff;
>  	udelay(100);
>  
>  	eth_gpio = LDP_SMC911X_GPIO;
> diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
> index 870b4c3..a45952e 100644
> --- a/drivers/net/smc911x.h
> +++ b/drivers/net/smc911x.h
> @@ -42,6 +42,16 @@
>    #define SMC_USE_16BIT		0
>    #define SMC_USE_32BIT		1
>    #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
> +#elif defined(CONFIG_ARCH_OMAP34XX)
> +  #define SMC_USE_16BIT		0
> +  #define SMC_USE_32BIT		1
> +  #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
> +  #define SMC_MEM_RESERVED	1
> +#elif defined(CONFIG_ARCH_OMAP24XX)
> +  #define SMC_USE_16BIT		0
> +  #define SMC_USE_32BIT		1
> +  #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
> +  #define SMC_MEM_RESERVED	1
>  #else
>  /*
>   * Default configuration
> @@ -675,6 +685,7 @@ smc_pxa_dma_outsl(struct smc911x_local *lp, u_long physaddr,
>  #define CHIP_9116	0x0116
>  #define CHIP_9117	0x0117
>  #define CHIP_9118	0x0118
> +#define CHIP_9211	0x9211
>  #define CHIP_9215	0x115A
>  #define CHIP_9217	0x117A
>  #define CHIP_9218	0x118A
> @@ -689,6 +700,7 @@ static const struct chip_id chip_ids[] =  {
>  	{ CHIP_9116, "LAN9116" },
>  	{ CHIP_9117, "LAN9117" },
>  	{ CHIP_9118, "LAN9118" },
> +	{ CHIP_9211, "LAN9211" },
>  	{ CHIP_9215, "LAN9215" },
>  	{ CHIP_9217, "LAN9217" },
>  	{ CHIP_9218, "LAN9218" },
> 
