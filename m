From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH V4 2/4] CS89x0 : add CS89x0 platform device to the
 iMX21ADS board
Date: Mon, 23 Jan 2012 10:34:20 +0100
Message-ID: <20120123093420.GL5446@pengutronix.de>
References: <1326996830-13548-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel@pengutronix.de, u.kleine-koenig@pengutronix.de,
	davem@davemloft.net, cavokz@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46226 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab2AWJeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 04:34:36 -0500
Content-Disposition: inline
In-Reply-To: <1326996830-13548-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2012 at 07:13:50PM +0100, Jaccon Bastiaansen wrote:
> Add CS89x0 networking support to the iMX21ADS board by using the
> platform driver support in the CS89x0 driver.
> 
> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
> ---
>  arch/arm/configs/imx_v4_v5_defconfig |    2 ++
>  arch/arm/mach-imx/mach-mx21ads.c     |   31 ++++++++++++++++++++++++++++---
>  2 files changed, 30 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/arm/configs/imx_v4_v5_defconfig b/arch/arm/configs/imx_v4_v5_defconfig
> index 11a4192..fc0106f 100644
> --- a/arch/arm/configs/imx_v4_v5_defconfig
> +++ b/arch/arm/configs/imx_v4_v5_defconfig
> @@ -81,6 +81,8 @@ CONFIG_NET_ETHERNET=y
>  CONFIG_SMC91X=y
>  CONFIG_DM9000=y
>  CONFIG_SMC911X=y
> +CONFIG_CS89x0=y
> +CONFIG_CS89x0_PLATFORM=y
>  # CONFIG_NETDEV_1000 is not set
>  # CONFIG_NETDEV_10000 is not set
>  # CONFIG_INPUT_MOUSEDEV is not set
> diff --git a/arch/arm/mach-imx/mach-mx21ads.c b/arch/arm/mach-imx/mach-mx21ads.c
> index 25f8402..4fd37fc 100644
> --- a/arch/arm/mach-imx/mach-mx21ads.c
> +++ b/arch/arm/mach-imx/mach-mx21ads.c
> @@ -37,8 +37,8 @@
>  #define MX21ADS_REG_ADDR(offset)    (void __force __iomem *) \
>  		(MX21ADS_MMIO_BASE_ADDR + (offset))
>  
> +#define MX21ADS_CS8900A_MMIO_SIZE   0x200000
>  #define MX21ADS_CS8900A_IRQ         IRQ_GPIOE(11)
> -#define MX21ADS_CS8900A_IOBASE_REG  MX21ADS_REG_ADDR(0x000000)
>  #define MX21ADS_ST16C255_IOBASE_REG MX21ADS_REG_ADDR(0x200000)
>  #define MX21ADS_VERSION_REG         MX21ADS_REG_ADDR(0x400000)
>  #define MX21ADS_IO_REG              MX21ADS_REG_ADDR(0x800000)
> @@ -159,6 +159,26 @@ static struct platform_device mx21ads_nor_mtd_device = {
>  	.resource = &mx21ads_flash_resource,
>  };
>  
> +static const struct resource mx21ads_cs8900_resources[] __initconst = {
> +	{
> +		.start = MX21_CS1_BASE_ADDR,
> +		.end = MX21_CS1_BASE_ADDR +  MX21ADS_CS8900A_MMIO_SIZE - 1,
> +		.flags = IORESOURCE_MEM,
> +	},
> +	{
> +		.start = MX21ADS_CS8900A_IRQ,
> +		.end = MX21ADS_CS8900A_IRQ,
> +		.flags = IORESOURCE_IRQ,
> +	}
> +};
> +
> +static const struct platform_device_info mx21ads_cs8900_devinfo __initconst = {
> +	.name = "cs89x0",
> +	.id = 0,
> +	.res = mx21ads_cs8900_resources,
> +	.num_res = ARRAY_SIZE(mx21ads_cs8900_resources),
> +};
> +
>  static const struct imxuart_platform_data uart_pdata_rts __initconst = {
>  	.flags = IMXUART_HAVE_RTSCTS,
>  };
> @@ -254,14 +274,17 @@ mx21ads_nand_board_info __initconst = {
>  static struct map_desc mx21ads_io_desc[] __initdata = {
>  	/*
>  	 * Memory-mapped I/O on MX21ADS Base board:
> -	 *   - CS8900A Ethernet controller
>  	 *   - ST16C2552CJ UART
>  	 *   - CPU and Base board version
>  	 *   - Base board I/O register
> +	 *
> +	 * Note that the CS8900 uses the first MX21ADS_CS8900A_MMIO_SIZE
> +	 * bytes of the CS1 memory range.
>  	 */
>  	{
>  		.virtual = MX21ADS_MMIO_BASE_ADDR,
> -		.pfn = __phys_to_pfn(MX21_CS1_BASE_ADDR),
> +		.pfn = __phys_to_pfn(MX21_CS1_BASE_ADDR +
> +					MX21ADS_CS8900A_MMIO_SIZE),

Since you now use ioremap the cs89x0 driver this mapping is not used
for the cs89x0 anymore, so it's strange to have references to it
here.
You still need the mapping though, but only for MX21ADS_IO_REG.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
