From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 4/4] [powerpc] Add flexcan device support for p1010rdb.
Date: Tue, 09 Aug 2011 15:00:12 +0200
Message-ID: <4E412F5C.7030802@grandegger.com>
References: <1312892907-20419-1-git-send-email-holt@sgi.com>
	<1312892907-20419-5-git-send-email-holt@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1312892907-20419-5-git-send-email-holt-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Robin,

On 08/09/2011 02:28 PM, Robin Holt wrote:
> I added a simple clock source for the p1010rdb so the flexcan driver
> could determine a clock frequency.  The p1010 can device only has an
> oscillator of system bus frequency divided by 2.
> 
> Signed-off-by: Robin Holt <holt-sJ/iWh9BUns@public.gmane.org>
> To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
> To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
> To: U Bhaskar-B22300 <B22300-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
> Cc: PPC list <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
> ---
>  arch/powerpc/platforms/85xx/Kconfig    |    2 +
>  arch/powerpc/platforms/85xx/Makefile   |    2 +
>  arch/powerpc/platforms/85xx/clock.c    |   42 ++++++++++++++++++++++++++++++++
>  arch/powerpc/platforms/85xx/p1010rdb.c |    8 ++++++
>  4 files changed, 54 insertions(+), 0 deletions(-)
>  create mode 100644 arch/powerpc/platforms/85xx/clock.c
> 
> diff --git a/arch/powerpc/platforms/85xx/Kconfig b/arch/powerpc/platforms/85xx/Kconfig
> index 498534c..c4304ae 100644
> --- a/arch/powerpc/platforms/85xx/Kconfig
> +++ b/arch/powerpc/platforms/85xx/Kconfig
> @@ -70,6 +70,8 @@ config MPC85xx_RDB
>  config P1010_RDB
>  	bool "Freescale P1010RDB"
>  	select DEFAULT_UIMAGE
> +	select HAVE_CAN_FLEXCAN if NET && CAN
> +	select PPC_CLOCK if CAN_FLEXCAN
>  	help
>  	  This option enables support for the MPC85xx RDB (P1010 RDB) board
>  
> diff --git a/arch/powerpc/platforms/85xx/Makefile b/arch/powerpc/platforms/85xx/Makefile
> index a971b32..cc7f381 100644
> --- a/arch/powerpc/platforms/85xx/Makefile
> +++ b/arch/powerpc/platforms/85xx/Makefile
> @@ -3,6 +3,8 @@
>  #
>  obj-$(CONFIG_SMP) += smp.o
>  
> +obj-$(CONFIG_PPC_CLOCK)   += clock.o
> +
>  obj-$(CONFIG_MPC8540_ADS) += mpc85xx_ads.o
>  obj-$(CONFIG_MPC8560_ADS) += mpc85xx_ads.o
>  obj-$(CONFIG_MPC85xx_CDS) += mpc85xx_cds.o
> diff --git a/arch/powerpc/platforms/85xx/clock.c b/arch/powerpc/platforms/85xx/clock.c
> new file mode 100644
> index 0000000..a6fd2c8
> --- /dev/null
> +++ b/arch/powerpc/platforms/85xx/clock.c
> @@ -0,0 +1,42 @@
> +
> +#include <linux/device.h>
> +#include <linux/err.h>
> +
> +#include <asm/clk_interface.h>
> +
> +#include <sysdev/fsl_soc.h>
> +
> +/*
> + * p1010 needs to provide a clock source for the flexcan driver. The
> + * oscillator for the p1010 processor is only ever the system clock / 2.
> + */
> +
> +static struct clk *mpc85xx_clk_get(struct device *dev, const char *id)
> +{
> +	if (!dev)
> +		return ERR_PTR(-ENOENT);
> +

Ah, I think you removed too much code here. I obviously did not
understand what the device node check is good for, sorry. The clock is
only implemented for the Flexcan and therefore we should add a check here:

	if (!dev->of_node ||
	    !of_device_is_compatible(dev->of_node, "fsl,flexcan"))
		return ERR_PTR(-ENOENT);

Something like that should work. For the next version you can then add
my "Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org" to all patches.

Wolfgang.
