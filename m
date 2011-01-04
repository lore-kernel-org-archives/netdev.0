From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH v2 05/10] net/fec: add dual fec support for mx28
Date: Tue, 4 Jan 2011 11:59:16 +0200
Message-ID: <20110104095916.GE2987@jasper.tkos.co.il>
References: <1294133056-21195-1-git-send-email-shawn.guo@freescale.com>
	<1294133056-21195-6-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: gerg@snapgear.com, B32542@freescale.com, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, u.kleine-koenig@pengutronix.de,
	w.sang@pengutronix.de, r64343@freescale.com, eric@eukrea.com,
	bryan.wu@canonical.com, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, lw@karo-electronics.de
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1294133056-21195-6-git-send-email-shawn.guo@freescale.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Shawn,

On Tue, Jan 04, 2011 at 05:24:11PM +0800, Shawn Guo wrote:
> This patch is to add mx28 dual fec support. Here are some key notes
> for mx28 fec controller.
> 
>  - mx28 fec design made an assumption that it runs on a
>    big-endian system, which is incorrect. As the result, the
>    driver has to swap every frame going to and coming from
>    the controller.
>  - external phys can only be configured by fec0, which means
>    fec1 can not work independently and both phys need to be
>    configured by mii_bus attached on fec0.
>  - mx28 fec reset will get mac address registers reset too.
>  - MII/RMII mode and 10M/100M speed are configured differently
>    from i.mx/mxs fec controller.
>  - ETHER_EN bit must be set to get interrupt work.
> 
> Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
> ---
> Changes for v2:
>  - Use module parameter fec.macaddr over new kernel command line
>    fec_mac to pass mac address

Since you introduce this new kernel command line parameter in patch #3 of this 
series, why not just make it right in the first place? This should make both 
patches smaller and easier for review.

>  - Update comment in fec_get_mac() to stop using confusing word
>    "default"
>  - Fix copyright breakage in fec.h

Ditto.

>  drivers/net/Kconfig |    7 ++-
>  drivers/net/fec.c   |  139 ++++++++++++++++++++++++++++++++++++++++----------
>  drivers/net/fec.h   |    5 +-
>  include/linux/fec.h |    3 +-
>  4 files changed, 120 insertions(+), 34 deletions(-)

[snip]

> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index f147508..b2b3e37 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -17,6 +17,8 @@
>   *
>   * Bug fixes and cleanup by Philippe De Muyter (phdm@macqel.be)
>   * Copyright (c) 2004-2006 Macq Electronique SA.
> + *
> + * Copyright (C) 2010 Freescale Semiconductor, Inc.
>   */
>  
>  #include <linux/module.h>
> @@ -45,21 +47,34 @@
>  
>  #include <asm/cacheflush.h>
>  
> -#ifndef CONFIG_ARCH_MXC
> +#if !defined(CONFIG_ARCH_MXC) && !defined(CONFIG_SOC_IMX28)
>  #include <asm/coldfire.h>
>  #include <asm/mcfsim.h>
>  #endif
>  
>  #include "fec.h"
>  
> -#ifdef CONFIG_ARCH_MXC
> -#include <mach/hardware.h>

Since you now remove mach/hardware.h for ARCH_MXC, does this build for all 
i.MX variants?

> +#ifdef CONFIG_SOC_IMX28
> +/*
> + * mx28 does not have MIIGSK registers
> + */
> +#undef FEC_MIIGSK_ENR
> +#include <mach/mxs.h>
> +#else
> +#define cpu_is_mx28()	(0)
> +#endif

This breaks kernels for multiple archs (e.g. i.MX28 and i.MX25). Please use 
run-time detection of CPU type, and do the MII/RMII etc. configuration 
accordingly.

> +
> +#if defined(CONFIG_ARCH_MXC) || defined(CONFIG_SOC_IMX28)
>  #define FEC_ALIGNMENT	0xf
>  #else
>  #define FEC_ALIGNMENT	0x3
>  #endif

[snip]

baruch

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
