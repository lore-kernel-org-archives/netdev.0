From: Steve Sakoman <sakoman@gmail.com>
Subject: Re: [RFC] ARM: Add SMSC911X support to Overo platform
Date: Fri, 30 Jan 2009 12:43:49 -0800
Message-ID: <5e088bd90901301243s31bfea9bra34328b00574e2fc@mail.gmail.com>
References: <5e088bd90901301228l3a0ab25m35a7341ac972e9de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-omap <linux-omap@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:14171 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753558AbZA3Uny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 15:43:54 -0500
In-Reply-To: <5e088bd90901301228l3a0ab25m35a7341ac972e9de@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 12:28 PM, Steve Sakoman <sakoman@gmail.com> wrote:
> Gumstix will soon be shipping a variant of their Summit board that
> includes an SMSC9221 ethernet interface.  This patch is intended to
> provide support via the smsc911x driver when enabled in defconfig.
> The final submission of course will also include an updated defconfig.
>
> Signed-off-by: Steve Sakoman <steve@sakoman.com>
> ---
> diff --git a/arch/arm/mach-omap2/board-overo.c
> b/arch/arm/mach-omap2/board-overo.c
> index 9995ac2..97d95a4 100644
> --- a/arch/arm/mach-omap2/board-overo.c
> +++ b/arch/arm/mach-omap2/board-overo.c
> @@ -55,6 +55,63 @@
>  #define GPMC_CS0_BASE  0x60
>  #define GPMC_CS_SIZE   0x30
>
> +#if defined(CONFIG_SMSC911X) || defined(CONFIG_SMSC911X_MODULE)
> +
> +#include <linux/smsc911x.h>
> +
> +static struct resource overo_smsc911x_resources[] = {
> +       {
> +               .name   = "smsc911x-memory",
> +               .flags  = IORESOURCE_MEM,
> +       },
> +       {
> +               .flags  = IORESOURCE_IRQ | IORESOURCE_IRQ_LOWLEVEL,
> +       },
> +};
> +
> +static struct smsc911x_platform_config overo_smsc911x_config = {
> +       .irq_polarity   = SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
> +       .irq_type       = SMSC911X_IRQ_TYPE_OPEN_DRAIN,
> +       .flags          = SMSC911X_USE_32BIT ,
> +       .phy_interface  = PHY_INTERFACE_MODE_MII,
> +};
> +
> +static struct platform_device overo_smsc911x_device = {
> +       .name           = "smsc911x",
> +       .id             = -1,
> +       .num_resources  = ARRAY_SIZE(overo_smsc911x_resources),
> +       .resource       = &overo_smsc911x_resources,
> +       .dev            = {
> +               .platform_data = &overo_smsc911x_config,
> +       },
> +};
> +
> +static inline void __init overo_init_smsc911x(void)
> +{
> +       unsigned long cs_mem_base;
> +
> +       if (gpmc_cs_request(OVERO_SMSC911X_CS, SZ_16M, &cs_mem_base) < 0) {
> +               printk(KERN_ERR "Failed request for GPMC mem for smsc911x\n");
> +               return;
> +       }
> +
> +       overo_smsc911x_resources[0].start = cs_mem_base + 0x0;
> +       overo_smsc911x_resources[0].end   = cs_mem_base + 0xff;
> +
> +       if ((gpio_request(OVERO_SMSC911X_GPIO, "SMSC911X IRQ") == 0) &&
> +           (gpio_direction_input(OVERO_SMSC911X_GPIO) == 0)) {
> +               gpio_export(OVERO_SMSC911X_GPIO, 0);
> +       } else {
> +               printk(KERN_ERR "could not obtain gpio for SMSC911X IRQ\n");
> +               return;
> +       }
> +
> +       overo_smsc911x_resources[1].start = OMAP_GPIO_IRQ(OVERO_SMSC911X_GPIO),
> +       overo_smsc911x_resources[1].end   = OMAP_GPIO_IRQ(OVERO_SMSC911X_GPIO),

Just to see if anyone was paying attention, I pasted the version with
the stupid typos :-)

The two lines above were meant to end with semicolons rather than commas!

> +}
> +
> +#endif
> +
>  static struct mtd_partition overo_nand_partitions[] = {
>        {
>                .name           = "xloader",
> @@ -187,6 +244,9 @@ static void __init overo_init_irq(void)
>        omap2_init_common_hw(mt46h32m32lf6_sdrc_params);
>        omap_init_irq();
>        omap_gpio_init();
> +#if defined(CONFIG_SMSC911X) || defined(CONFIG_SMSC911X_MODULE)
> +       overo_init_smsc911x();
> +#endif
>  }
>
>  static struct platform_device overo_lcd_device = {
> @@ -204,6 +264,9 @@ static struct omap_board_config_kernel
> overo_config[] __initdata = {
>  };
>
>  static struct platform_device *overo_devices[] __initdata = {
> +#if defined(CONFIG_SMSC911X) || defined(CONFIG_SMSC911X_MODULE)
> +       &overo_smsc911x_device,
> +#endif
>        &overo_lcd_device,
>  };
>
> diff --git a/arch/arm/plat-omap/include/mach/board-overo.h
> b/arch/arm/plat-omap/include/mach/board-overo.h
> index 7ecae66..8635171 100644
> --- a/arch/arm/plat-omap/include/mach/board-overo.h
> +++ b/arch/arm/plat-omap/include/mach/board-overo.h
> @@ -22,5 +22,8 @@
>  #define OVERO_GPIO_USBH_CPEN   168
>  #define OVERO_GPIO_USBH_NRESET 183
>
> +#define OVERO_SMSC911X_CS      5
> +#define OVERO_SMSC911X_GPIO    176
> +
>  #endif /* ____ASM_ARCH_OVERO_H */
>
