From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH] ARM: Add SMSC911X support to Overo platform (V2)
Date: Fri, 20 Feb 2009 12:43:21 -0800
Message-ID: <20090220204320.GC7414@atomide.com>
References: <5e088bd90902012227o6e82ca64gbbe0bbc63ca03a69@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-omap <linux-omap@vger.kernel.org>, netdev@vger.kernel.org
To: Steve Sakoman <sakoman@gmail.com>
Return-path: <linux-omap-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5e088bd90902012227o6e82ca64gbbe0bbc63ca03a69@mail.gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Steve Sakoman <sakoman@gmail.com> [090201 22:28]:
> Gumstix will soon be shipping a variant of their Summit board that
> includes an SMSC LAN9221 ethernet interface.  This patch provides
> support via the smsc911x driver when enabled in kernel config.
> 
> The Overo defconfig is not updated since the LAN9221 is an option
> not present on all systems.

Adding this to omap3-upstream and pushing to linux-omap.

Tony

> Signed-off-by: Steve Sakoman <steve@sakoman.com>
> ---
>  arch/arm/mach-omap2/board-overo.c             |   62 +++++++++++++++++++++++++
>  arch/arm/plat-omap/include/mach/board-overo.h |    3 +
>  2 files changed, 65 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/arm/mach-omap2/board-overo.c
> b/arch/arm/mach-omap2/board-overo.c
> index 9995ac2..032a2c9 100644
> --- a/arch/arm/mach-omap2/board-overo.c
> +++ b/arch/arm/mach-omap2/board-overo.c
> @@ -55,6 +55,67 @@
>  #define GPMC_CS0_BASE  0x60
>  #define GPMC_CS_SIZE   0x30
> 
> +#if defined(CONFIG_SMSC911X) || defined(CONFIG_SMSC911X_MODULE)
> +
> +#include <linux/smsc911x.h>
> +
> +static struct resource overo_smsc911x_resources[] = {
> +	{
> +		.name	= "smsc911x-memory",
> +		.flags	= IORESOURCE_MEM,
> +	},
> +	{
> +		.flags	= IORESOURCE_IRQ | IORESOURCE_IRQ_LOWLEVEL,
> +	},
> +};
> +
> +static struct smsc911x_platform_config overo_smsc911x_config = {
> +	.irq_polarity	= SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
> +	.irq_type	= SMSC911X_IRQ_TYPE_OPEN_DRAIN,
> +	.flags		= SMSC911X_USE_32BIT ,
> +	.phy_interface	= PHY_INTERFACE_MODE_MII,
> +};
> +
> +static struct platform_device overo_smsc911x_device = {
> +	.name		= "smsc911x",
> +	.id		= -1,
> +	.num_resources	= ARRAY_SIZE(overo_smsc911x_resources),
> +	.resource	= &overo_smsc911x_resources,
> +	.dev		= {
> +		.platform_data = &overo_smsc911x_config,
> +	},
> +};
> +
> +static inline void __init overo_init_smsc911x(void)
> +{
> +	unsigned long cs_mem_base;
> +
> +	if (gpmc_cs_request(OVERO_SMSC911X_CS, SZ_16M, &cs_mem_base) < 0) {
> +		printk(KERN_ERR "Failed request for GPMC mem for smsc911x\n");
> +		return;
> +	}
> +
> +	overo_smsc911x_resources[0].start = cs_mem_base + 0x0;
> +	overo_smsc911x_resources[0].end   = cs_mem_base + 0xff;
> +
> +	if ((gpio_request(OVERO_SMSC911X_GPIO, "SMSC911X IRQ") == 0) &&
> +	    (gpio_direction_input(OVERO_SMSC911X_GPIO) == 0)) {
> +		gpio_export(OVERO_SMSC911X_GPIO, 0);
> +	} else {
> +		printk(KERN_ERR "could not obtain gpio for SMSC911X IRQ\n");
> +		return;
> +	}
> +
> +	overo_smsc911x_resources[1].start = OMAP_GPIO_IRQ(OVERO_SMSC911X_GPIO);
> +	overo_smsc911x_resources[1].end	  = 0;
> +
> +	platform_device_register(&overo_smsc911x_device);
> +}
> +
> +#else
> +static inline void __init overo_init_smsc911x(void) { return; }
> +#endif
> +
>  static struct mtd_partition overo_nand_partitions[] = {
>  	{
>  		.name           = "xloader",
> @@ -234,6 +295,7 @@ static void __init overo_init(void)
>  	usb_musb_init();
>  	usb_ehci_init();
>  	overo_flash_init();
> +	overo_init_smsc911x();
> 
>  	if ((gpio_request(OVERO_GPIO_W2W_NRESET,
>  			  "OVERO_GPIO_W2W_NRESET") == 0) &&
> diff --git a/arch/arm/plat-omap/include/mach/board-overo.h
> b/arch/arm/plat-omap/include/mach/board-overo.h
> index 7ecae66..8635171 100644
> --- a/arch/arm/plat-omap/include/mach/board-overo.h
> +++ b/arch/arm/plat-omap/include/mach/board-overo.h
> @@ -22,5 +22,8 @@
>  #define OVERO_GPIO_USBH_CPEN	168
>  #define OVERO_GPIO_USBH_NRESET	183
> 
> +#define OVERO_SMSC911X_CS	5
> +#define OVERO_SMSC911X_GPIO	176
> +
>  #endif /* ____ASM_ARCH_OVERO_H */
> 
> -- 
> 1.5.6.3
> --
> To unsubscribe from this list: send the line "unsubscribe linux-omap" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
