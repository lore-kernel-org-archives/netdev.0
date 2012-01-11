From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH V2 2/4] CS89x0 : add CS89x0 platform device to the
 iMX21ADS board
Date: Wed, 11 Jan 2012 09:12:31 +0100
Message-ID: <20120111081231.GK14252@pengutronix.de>
References: <1326237255-23630-1-git-send-email-jaccon.bastiaansen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: s.hauer@pengutronix.de, kernel@pengutronix.de, davem@davemloft.net,
	cavokz@gmail.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46509 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754906Ab2AKIMg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 03:12:36 -0500
Content-Disposition: inline
In-Reply-To: <1326237255-23630-1-git-send-email-jaccon.bastiaansen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Jan 11, 2012 at 12:14:15AM +0100, Jaccon Bastiaansen wrote:
> Add CS89x0 networking support to the iMX21ADS board by using the
> platform driver support in the CS89x0 driver.
>=20
> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
> ---
>  arch/arm/configs/imx_v4_v5_defconfig |    2 ++
>  arch/arm/mach-imx/mach-mx21ads.c     |   25 ++++++++++++++++++++++--=
-
>  2 files changed, 24 insertions(+), 3 deletions(-)
>=20
> diff --git a/arch/arm/configs/imx_v4_v5_defconfig b/arch/arm/configs/=
imx_v4_v5_defconfig
> index 11a4192..fc0106f 100644
> --- a/arch/arm/configs/imx_v4_v5_defconfig
> +++ b/arch/arm/configs/imx_v4_v5_defconfig
> @@ -81,6 +81,8 @@ CONFIG_NET_ETHERNET=3Dy
>  CONFIG_SMC91X=3Dy
>  CONFIG_DM9000=3Dy
>  CONFIG_SMC911X=3Dy
> +CONFIG_CS89x0=3Dy
> +CONFIG_CS89x0_PLATFORM=3Dy
>  # CONFIG_NETDEV_1000 is not set
>  # CONFIG_NETDEV_10000 is not set
>  # CONFIG_INPUT_MOUSEDEV is not set
> diff --git a/arch/arm/mach-imx/mach-mx21ads.c b/arch/arm/mach-imx/mac=
h-mx21ads.c
> index 25f8402..faefdf8 100644
> --- a/arch/arm/mach-imx/mach-mx21ads.c
> +++ b/arch/arm/mach-imx/mach-mx21ads.c
> @@ -38,7 +38,6 @@
>  		(MX21ADS_MMIO_BASE_ADDR + (offset))
> =20
>  #define MX21ADS_CS8900A_IRQ         IRQ_GPIOE(11)
> -#define MX21ADS_CS8900A_IOBASE_REG  MX21ADS_REG_ADDR(0x000000)
>  #define MX21ADS_ST16C255_IOBASE_REG MX21ADS_REG_ADDR(0x200000)
>  #define MX21ADS_VERSION_REG         MX21ADS_REG_ADDR(0x400000)
>  #define MX21ADS_IO_REG              MX21ADS_REG_ADDR(0x800000)
> @@ -159,6 +158,26 @@ static struct platform_device mx21ads_nor_mtd_de=
vice =3D {
>  	.resource =3D &mx21ads_flash_resource,
>  };
> =20
> +static struct resource mx21ads_cs8900_resources[] =3D {
> +	{
> +		.start =3D MX21_CS1_BASE_ADDR,
> +		.end =3D MX21_CS1_BASE_ADDR + 0x200000 - 1,
> +		.flags =3D IORESOURCE_MEM,
> +	},
> +	{
> +		.start =3D MX21ADS_CS8900A_IRQ,
> +		.end =3D MX21ADS_CS8900A_IRQ,
> +		.flags =3D IORESOURCE_IRQ,
> +	}
> +};
> +
> +static struct platform_device mx21ads_cs8900_device =3D {
> +	.name =3D "cs89x0",
> +	.id =3D 0,
> +	.num_resources =3D ARRAY_SIZE(mx21ads_cs8900_resources),
> +	.resource =3D mx21ads_cs8900_resources
> +};
> +
Nowadays we prefer dynamic initialisation over static structs. (A struc=
t
platform_device takes 300 and a few bytes IIRC and just occupies memory
if you boot a machine different from mx21ads.) So the right incantation
is:

	static const struct resource mx21ads_cs8900_resources[] __initconst =3D=
 {
		...
	};

	static const struct platform_device_info mx21ads_cs8900_devinfo __init=
const =3D {
		.name =3D "cs89x0",
		.id =3D 0;
		.res =3D mx21ads_cs8900_resources,
		.num_res =3D ARRAY_SIZE(mx21ads_cs8900_resources),
	};

	platform_device_register_full(&mx21ads_cs8900_devinfo);

>  static const struct imxuart_platform_data uart_pdata_rts __initconst=
 =3D {
>  	.flags =3D IMXUART_HAVE_RTSCTS,
>  };
> @@ -254,14 +273,13 @@ mx21ads_nand_board_info __initconst =3D {
>  static struct map_desc mx21ads_io_desc[] __initdata =3D {
>  	/*
>  	 * Memory-mapped I/O on MX21ADS Base board:
> -	 *   - CS8900A Ethernet controller
>  	 *   - ST16C2552CJ UART
>  	 *   - CPU and Base board version
>  	 *   - Base board I/O register
>  	 */
>  	{
>  		.virtual =3D MX21ADS_MMIO_BASE_ADDR,
> -		.pfn =3D __phys_to_pfn(MX21_CS1_BASE_ADDR),
> +		.pfn =3D __phys_to_pfn(MX21_CS1_BASE_ADDR + 0x200000),
>  		.length =3D MX21ADS_MMIO_SIZE,
>  		.type =3D MT_DEVICE,
>  	},
Maybe add a comment here why an offset is used here and maybe use a
nice #define for it instead of a bare number.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
