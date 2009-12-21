From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 4/4] mx25: add support for FEC on i.MX25 PDK
Date: Mon, 21 Dec 2009 12:08:07 +0100
Message-ID: <20091221110807.GE15126@pengutronix.de>
References: <cover.1260785451.git.baruch@tkos.co.il> <4eb5a5232acc6028648f94a1fdfd60b52b64149c.1260785451.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sascha Hauer <kernel@pengutronix.de>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44843 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436AbZLULIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 06:08:45 -0500
Content-Disposition: inline
In-Reply-To: <4eb5a5232acc6028648f94a1fdfd60b52b64149c.1260785451.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 14, 2009 at 12:19:42PM +0200, Baruch Siach wrote:
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> ---
>  arch/arm/mach-mx25/clock.c            |    2 +
>  arch/arm/mach-mx25/devices.c          |   19 +++++++++++++++
>  arch/arm/mach-mx25/devices.h          |    1 +
>  arch/arm/mach-mx25/mx25pdk.c          |   40 ++++++++++++++++++++++++++++++++-
>  arch/arm/plat-mxc/include/mach/mx25.h |    4 +++

Can you please split this into two patches, one for the i.MX25 and one
for the board support?

Sascha

>  5 files changed, 65 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/arm/mach-mx25/clock.c b/arch/arm/mach-mx25/clock.c
> index dbbbcc6..ea8c3da 100644
> --- a/arch/arm/mach-mx25/clock.c
> +++ b/arch/arm/mach-mx25/clock.c
> @@ -173,6 +173,7 @@ DEFINE_CLOCK(pwm4_clk,	 0, CCM_CGCR2,  2, get_rate_ipg, NULL);
>  DEFINE_CLOCK(kpp_clk,	 0, CCM_CGCR1, 28, get_rate_ipg, NULL);
>  DEFINE_CLOCK(tsc_clk,	 0, CCM_CGCR2, 13, get_rate_ipg, NULL);
>  DEFINE_CLOCK(i2c_clk,	 0, CCM_CGCR0,  6, get_rate_i2c, NULL);
> +DEFINE_CLOCK(fec_clk,	 0, CCM_CGCR0, 23, get_rate_ipg, NULL);
>  
>  #define _REGISTER_CLOCK(d, n, c)	\
>  	{				\
> @@ -204,6 +205,7 @@ static struct clk_lookup lookups[] = {
>  	_REGISTER_CLOCK("imx-i2c.0", NULL, i2c_clk)
>  	_REGISTER_CLOCK("imx-i2c.1", NULL, i2c_clk)
>  	_REGISTER_CLOCK("imx-i2c.2", NULL, i2c_clk)
> +	_REGISTER_CLOCK("fec.0", NULL, fec_clk)
>  };
>  
>  int __init mx25_clocks_init(unsigned long fref)
> diff --git a/arch/arm/mach-mx25/devices.c b/arch/arm/mach-mx25/devices.c
> index 63511de..9fdeea1 100644
> --- a/arch/arm/mach-mx25/devices.c
> +++ b/arch/arm/mach-mx25/devices.c
> @@ -419,3 +419,22 @@ int __init mxc_register_gpios(void)
>  	return mxc_gpio_init(imx_gpio_ports, ARRAY_SIZE(imx_gpio_ports));
>  }
>  
> +static struct resource mx25_fec_resources[] = {
> +	{
> +		.start	= MX25_FEC_BASE_ADDR,
> +		.end	= MX25_FEC_BASE_ADDR + 0xfff,
> +		.flags	= IORESOURCE_MEM,
> +	},
> +	{
> +		.start	= MX25_INT_FEC,
> +		.end	= MX25_INT_FEC,
> +		.flags	= IORESOURCE_IRQ,
> +	},
> +};
> +
> +struct platform_device mx25_fec_device = {
> +	.name	= "fec",
> +	.id	= 0,
> +	.num_resources	= ARRAY_SIZE(mx25_fec_resources),
> +	.resource	= mx25_fec_resources,
> +};
> diff --git a/arch/arm/mach-mx25/devices.h b/arch/arm/mach-mx25/devices.h
> index fe6bf88..fe5420f 100644
> --- a/arch/arm/mach-mx25/devices.h
> +++ b/arch/arm/mach-mx25/devices.h
> @@ -17,3 +17,4 @@ extern struct platform_device mxc_keypad_device;
>  extern struct platform_device mxc_i2c_device0;
>  extern struct platform_device mxc_i2c_device1;
>  extern struct platform_device mxc_i2c_device2;
> +extern struct platform_device mx25_fec_device;
> diff --git a/arch/arm/mach-mx25/mx25pdk.c b/arch/arm/mach-mx25/mx25pdk.c
> index d23ae57..011d6c3 100644
> --- a/arch/arm/mach-mx25/mx25pdk.c
> +++ b/arch/arm/mach-mx25/mx25pdk.c
> @@ -18,6 +18,7 @@
>  
>  #include <linux/types.h>
>  #include <linux/init.h>
> +#include <linux/delay.h>
>  #include <linux/clk.h>
>  #include <linux/irq.h>
>  #include <linux/gpio.h>
> @@ -35,16 +36,53 @@
>  #include <mach/mx25.h>
>  #include <mach/mxc_nand.h>
>  #include "devices.h"
> -#include <mach/iomux-v3.h>
> +#include <mach/iomux.h>
>  
>  static struct imxuart_platform_data uart_pdata = {
>  	.flags = IMXUART_HAVE_RTSCTS,
>  };
>  
> +static struct pad_desc mx25pdk_pads[] = {
> +	MX25_PAD_FEC_MDC__FEC_MDC,
> +	MX25_PAD_FEC_MDIO__FEC_MDIO,
> +	MX25_PAD_FEC_TDATA0__FEC_TDATA0,
> +	MX25_PAD_FEC_TDATA1__FEC_TDATA1,
> +	MX25_PAD_FEC_TX_EN__FEC_TX_EN,
> +	MX25_PAD_FEC_RDATA0__FEC_RDATA0,
> +	MX25_PAD_FEC_RDATA1__FEC_RDATA1,
> +	MX25_PAD_FEC_RX_DV__FEC_RX_DV,
> +	MX25_PAD_FEC_TX_CLK__FEC_TX_CLK,
> +	MX25_PAD_A17__GPIO_2_3, /* FEC_EN, GPIO 35 */
> +	MX25_PAD_D12__GPIO_4_8, /* FEC_RESET_B, GPIO 104 */
> +};
> +
> +#define FEC_ENABLE_GPIO		35
> +#define FEC_RESET_B_GPIO	104
> +
> +static void __init mx25pdk_fec_reset(void)
> +{
> +	gpio_request(FEC_ENABLE_GPIO, "FEC PHY enable");
> +	gpio_request(FEC_RESET_B_GPIO, "FEC PHY reset");
> +
> +	gpio_direction_output(FEC_ENABLE_GPIO, 0);  /* drop PHY power */
> +	gpio_direction_output(FEC_RESET_B_GPIO, 0); /* assert reset */
> +	udelay(2);
> +
> +	/* turn on PHY power and lift reset */
> +	gpio_set_value(FEC_ENABLE_GPIO, 1);
> +	gpio_set_value(FEC_RESET_B_GPIO, 1);
> +}
> +
>  static void __init mx25pdk_init(void)
>  {
> +	mxc_iomux_v3_setup_multiple_pads(mx25pdk_pads,
> +			ARRAY_SIZE(mx25pdk_pads));
> +
>  	mxc_register_device(&mxc_uart_device0, &uart_pdata);
>  	mxc_register_device(&mxc_usbh2, NULL);
> +
> +	mx25pdk_fec_reset();
> +	mxc_register_device(&mx25_fec_device, NULL);
>  }
>  
>  static void __init mx25pdk_timer_init(void)
> diff --git a/arch/arm/plat-mxc/include/mach/mx25.h b/arch/arm/plat-mxc/include/mach/mx25.h
> index ec64bd9..106f651 100644
> --- a/arch/arm/plat-mxc/include/mach/mx25.h
> +++ b/arch/arm/plat-mxc/include/mach/mx25.h
> @@ -41,4 +41,8 @@
>  #define UART1_BASE_ADDR			0x43f90000
>  #define UART2_BASE_ADDR			0x43f94000
>  
> +#define MX25_FEC_BASE_ADDR		0x50038000
> +
> +#define MX25_INT_FEC	57
> +
>  #endif /* __MACH_MX25_H__ */
> -- 
> 1.6.5
> 
> 

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
