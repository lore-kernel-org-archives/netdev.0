From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: sh: add support for ax88796 and 93cx6 to highlander boards
Date: Mon, 10 Sep 2007 16:15:28 +0900
Message-ID: <20070910071528.GB13672@linux-sh.org>
References: <20070910063626.2300.75144.sendpatchset@clockwork.opensource.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, ben-linux@fluff.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ocgnet.org ([64.20.243.3]:34590 "EHLO smtp.ocgnet.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754561AbXIJHPi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Sep 2007 03:15:38 -0400
Content-Disposition: inline
In-Reply-To: <20070910063626.2300.75144.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 10, 2007 at 03:36:26PM +0900, Magnus Damm wrote:
> --- 0004/arch/sh/boards/renesas/r7780rp/setup.c
> +++ work/arch/sh/boards/renesas/r7780rp/setup.c	2007-09-06 15:35:49.000000000 +0900
> @@ -21,6 +21,7 @@
>  #include <asm/clock.h>
>  #include <asm/heartbeat.h>
>  #include <asm/io.h>
> +#include <net/ax88796.h>
>  
>  static struct resource r8a66597_usb_host_resources[] = {
>  	[0] = {
> @@ -136,11 +137,50 @@ static struct platform_device heartbeat_
>  	.resource	= heartbeat_resources,
>  };
>  
> +static struct ax_plat_data ax88796_platdata = {
> +	.flags          = AXFLG_HAS_93CX6,
> +	.wordlength     = 2,
> +	.dcr_val        = 0x1,
> +	.rcr_val        = 0x40,
> +};
> +
> +static struct resource ax88796_resources[] = {
> +	{
> +#ifdef CONFIG_SH_R7780RP
> +		.start  = 0xa5800400,
> +		.end    = 0xa5800400 + (0x20 * 0x2) - 1,
> +#else
> +		.start  = 0xa4100400,
> +		.end    = 0xa4100400 + (0x20 * 0x2) - 1,
> +#endif
> +		.flags  = IORESOURCE_MEM,
> +	},
> +	{
> +		.start  = IRQ_AX88796,
> +		.end    = IRQ_AX88796,
> +		.flags  = IORESOURCE_IRQ,
> +	},
> +};
> +
> +static struct platform_device ax88796_device = {
> +	.name           = "ax88796",
> +	.id             = 0,
> +
> +	.dev    = {
> +		.platform_data = &ax88796_platdata,
> +	},
> +
> +	.num_resources  = ARRAY_SIZE(ax88796_resources),
> +	.resource       = ax88796_resources,
> +};
> +
> +
>  static struct platform_device *r7780rp_devices[] __initdata = {
>  	&r8a66597_usb_host_device,
>  	&m66592_usb_peripheral_device,
>  	&cf_ide_device,
>  	&heartbeat_device,
> +	&ax88796_device,
>  };
>  
>  static int __init r7780rp_devices_setup(void)

These bits I'll merge separately once the other patches have been
applied.

> --- 0001/drivers/net/Kconfig
> +++ work/drivers/net/Kconfig	2007-09-06 15:35:41.000000000 +0900
> @@ -218,13 +218,20 @@ source "drivers/net/arm/Kconfig"
>  
>  config AX88796
>  	tristate "ASIX AX88796 NE2000 clone support"
> -	depends on ARM || MIPS
> +	depends on ARM || MIPS || SUPERH
>  	select CRC32
>  	select MII
>  	help
>  	  AX88796 driver, using platform bus to provide
>  	  chip detection and resources
>  
> +config AX88796_93CX6
> +	bool "ASIX AX88796 external 93CX6 eeprom support"
> +	depends on AX88796
> +	select EEPROM_93CX6
> +	help
> +	  Select this if your platform comes with an external 93CX6 eeprom.
> +
>  config MACE
>  	tristate "MACE (Power Mac ethernet) support"
>  	depends on PPC_PMAC && PPC32

There are two different changes here, these should probably be split up
and applied independently of each other, given that there's no real
dependency between them.
