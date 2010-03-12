From: Kevin Hilman <khilman@deeprootsystems.com>
Subject: Re: [PATCH 2/2] davinci: introduce EMAC PHY clock usage
Date: Fri, 12 Mar 2010 14:38:20 -0800
Message-ID: <87wrxh5foj.fsf@deeprootsystems.com>
References: <1268317491-3822-1-git-send-email-srk@ti.com>
	<1268317491-3822-2-git-send-email-srk@ti.com>
	<1268317491-3822-3-git-send-email-srk@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: Sriramakrishnan <srk@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:34882 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab0CLWiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 17:38:23 -0500
Received: by pwi1 with SMTP id 1so1048386pwi.19
        for <netdev@vger.kernel.org>; Fri, 12 Mar 2010 14:38:23 -0800 (PST)
In-Reply-To: <1268317491-3822-3-git-send-email-srk@ti.com> (Sriramakrishnan's message of "Thu\, 11 Mar 2010 19\:54\:51 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sriramakrishnan <srk@ti.com> writes:

> From: Sekhar Nori <nsekhar@ti.com>
>
> The patch "TI DaVinci EMAC: Add EMAC PHY clock handling" adds
> support for enabling and disabling the EMAC PHY clock.
>
> The PHY clock on all DaVinci boards is derived from a fixed
> on board clock. This patch adds the PHY clock definition to
> the clock tree for all the DaVinci boards using EMAC. Also,
> the existing input to EMAC module is differentiated from the
> PHY clock using the clock name "emac_clk".
>
> Without this patch ethernet fails to initialize since it cannot
> get the PHY clock and EMAC clock.
>
> Tested on EVM boards for DM365, DM6467, DM644x, DA830 and DA850.
>
> Signed-off-by: Sekhar Nori <nsekhar@ti.com>
> ---
> Though i have made changes for Neuros OSD2 and SFFSDR boards, i
> do not have the hardware to test. Appreciate if folks having this
> hardware ack the patch.
>
>  arch/arm/mach-davinci/board-da830-evm.c   |   19 +++++++++++++++++++
>  arch/arm/mach-davinci/board-da850-evm.c   |   21 +++++++++++++++++++++
>  arch/arm/mach-davinci/board-dm365-evm.c   |   18 ++++++++++++++++++
>  arch/arm/mach-davinci/board-dm644x-evm.c  |   18 ++++++++++++++++++
>  arch/arm/mach-davinci/board-dm646x-evm.c  |   15 +++++++++++++++
>  arch/arm/mach-davinci/board-neuros-osd2.c |   19 +++++++++++++++++++
>  arch/arm/mach-davinci/board-sffsdr.c      |   19 +++++++++++++++++++
>  arch/arm/mach-davinci/da830.c             |    2 +-
>  arch/arm/mach-davinci/da850.c             |    2 +-
>  arch/arm/mach-davinci/dm365.c             |    2 +-
>  arch/arm/mach-davinci/dm644x.c            |    2 +-
>  arch/arm/mach-davinci/dm646x.c            |    2 +-
>  12 files changed, 134 insertions(+), 5 deletions(-)
>
> diff --git a/arch/arm/mach-davinci/board-da830-evm.c b/arch/arm/mach-davinci/board-da830-evm.c
> index dc19870..54e8567 100644
> --- a/arch/arm/mach-davinci/board-da830-evm.c
> +++ b/arch/arm/mach-davinci/board-da830-evm.c
> @@ -20,9 +20,11 @@
>  #include <linux/i2c/at24.h>
>  #include <linux/mtd/mtd.h>
>  #include <linux/mtd/partitions.h>
> +#include <linux/clk.h>
>  
>  #include <asm/mach-types.h>
>  #include <asm/mach/arch.h>
> +#include <mach/clock.h>
>  
>  #include <mach/cp_intc.h>
>  #include <mach/mux.h>
> @@ -30,6 +32,8 @@
>  #include <mach/da8xx.h>
>  #include <mach/usb.h>
>  
> +#include "clock.h"
> +
>  #define DA830_EVM_PHY_MASK		0x0
>  #define DA830_EVM_MDIO_FREQUENCY	2200000	/* PHY bus frequency */
>  
> @@ -557,9 +561,24 @@ static __init void da830_evm_irq_init(void)
>  			soc_info->intc_irq_prios);
>  }
>  
> +#define EMAC_PHY_CLK_RATE	50000000
> +
> +static struct clk emac_phy = {
> +	.name	= "emac_phy",
> +	.rate	= EMAC_PHY_CLK_RATE,
> +};
> +
> +static struct clk_lookup emac_phy_clks[] = {
> +	CLK("davinci_emac.1", "phy_clk", &emac_phy),

Just make it "phy" instead of "phy_clk".  The con_id field is just
a handle to differentiate between multiple clocks per device.

The same for the emac_clk change.  I'd call that one "main" (or "emac"
if you prefer.)  Doing this change will require an update do PATCH 1/2
as well.

> +	CLK(NULL, NULL, NULL),
> +};
> +

I'm not crazy about the clock definitions in the board files.  I
assume you put it here instead of <soc>.c is because each clock
has a board specific rate.

Instead, what I'd rather see is the clock defined once for each
<soc>.c with a custom set_rate hook.  The default rate could
be a per-SoC default (25MHz looks common) and any board files
that don't use the default can use clk_set_rate() to change it.

This approach should simplfy things and minimize changes to board
files.

Kevin
