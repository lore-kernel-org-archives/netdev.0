From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] m68k/atari: EtherNEC - rewrite to use mainstream ne.c
Date: Wed, 7 Mar 2012 11:09:23 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1203071053360.3196@ayla.of.borg>
References: <1327085843-6980-1-git-send-email-geert@linux-m68k.org> <4F4B2BB6.900@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: Michael Schmitz <schmitzmic@googlemail.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <4F4B2BB6.900@gmail.com>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 27 Feb 2012, Michael Schmitz wrote:
> after much prodding from Geert, and a bit of bouncing ideas back and forth,
> I've rewritten the Atari EtherNEC ethercard driver to use work with only
> minimal patches to ne.c (instead of duplicating ne.c as atari_ethernec.c).
> 
> The EtherNEC adapter is a solution to use a RTL8019 ISA card on the cartridge
> (ROM) port of m68k Atari computers. The cartridge port does not support
> generating interrupts. To service card interrupts, the 8390 interrupt handler
> is called periodically from a dedicated hardware timer which needs to be
> shared with other users (the SMC91C111 EtherNAT driver, and a dummy handler
> dedicated to preventing interference from the interrupt watchdog if the card
> is idle).
> 
> netdev subscribers please focus on the patch to ne.c at the top. Changes to
> ne.c are twofold: to select 8-bit mode for the driver, and to ensure the
> interrupt can be shared with aforementioned other users if the driver is used
> on Atari.
> 
> This patch applies on top of Geert's current linux-m68k. It won't cleanly
> apply on top of, or work if built from Linus' tree, as it relies on further
> patches relating to bus access quirks that are pending in Geert's tree.
> 
> The old EtherNEC driver is retained as-is, to be removed from Geert's tree
> after this code has been accepted. It can still be built by selecting the
> CONFIG_ATARI_ETHERNEC_OLD option.
> 
> Comments to linux-m68k or me, please - I'm not subscribed to netdev.
> 
> Cheers,
> 
>   Michael
> 
> 
> diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
> index f92ea2a..28b8781 100644
> --- a/drivers/net/ethernet/8390/ne.c
> +++ b/drivers/net/ethernet/8390/ne.c
> @@ -55,6 +55,9 @@ static const char version2[] =
> 
>  #include <asm/system.h>
>  #include <asm/io.h>
> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
> +#include <asm/atariints.h>
> +#endif
> 
>  #include "8390.h"
> 
> @@ -165,7 +168,8 @@ bad_clone_list[] __initdata = {
>  #if defined(CONFIG_PLAT_MAPPI)
>  #  define DCR_VAL 0x4b
>  #elif defined(CONFIG_PLAT_OAKS32R)  || \
> -   defined(CONFIG_MACH_TX49XX)
> +   defined(CONFIG_MACH_TX49XX) || \
> +   IS_ENABLED(CONFIG_ATARI_ETHERNEC)
>  #  define DCR_VAL 0x48        /* 8-bit mode */
>  #else
>  #  define DCR_VAL 0x49
> @@ -492,7 +496,16 @@ static int __init ne_probe1(struct net_device *dev,
> unsigned long ioaddr)
> 
>      /* Snarf the interrupt now.  There's no point in waiting since we cannot
>         share and the board will usually be enabled. */
> -    ret = request_irq(dev->irq, eip_interrupt, 0, name, dev);
> +#if IS_ENABLED(CONFIG_ATARI_ETHERNEC)
> +    if (MACH_IS_ATARI) {
> +        /* Atari EtherNEC emulates the card interrupt via a timer -
> +           this needs to be shared with the smc91C111 driver and with
> +           a dummy handler to catch unhandled interrupts ! */
> +        ret = request_irq(dev->irq, eip_interrupt, IRQF_SHARED, name, dev);
> +    } else
> +#endif
> +        ret = request_irq(dev->irq, eip_interrupt, 0, name, dev);
> +
>      if (ret) {
>          printk (" unable to get IRQ %d (errno=%d).\n", dev->irq, ret);
>          goto err_out;

Netdev people: are these changes to ne.c acceptable?

If yes, I'll split everything and queue it up (the ne.c part through netdev,
the rest through m68k).
If not, do you have a better solution[*]?
Are there other network drivers using/requiring a similar approach?

Thanks!

[*] I can imagine an alternative, which could be generalized for other
    platforms:
      - Leave the irq at zero to indicate polling.
      - In the driver, do

	if (!dev->irq) {
		ret = -E...;
#ifdef CONFIG_ATARI
		if (MACH_IS_ATARI) {
			ret = atari_request_poll(eip_interrupt, name, dev);
		}
#endif
	} else {
		ret = request_irq(dev->irq, ...);
		...
	}

	and a similar thing for free_irq().

This has the advantage that atari_request_poll() can decide to register the
timer interrupt only when EtherNEC or EtherNAT are active.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
