From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 3/3] at91_can: add driver for Atmel's CAN controller on
	AT91SAM9263
Date: Wed, 16 Sep 2009 12:07:48 +0200
Message-ID: <4AB0B8F4.50301@grandegger.com>
References: <1253094405-3216-1-git-send-email-mkl@pengutronix.de>	<1253094405-3216-2-git-send-email-mkl@pengutronix.de>	<1253094405-3216-3-git-send-email-mkl@pengutronix.de>
	<1253094405-3216-4-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1253094405-3216-4-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Marc Kleine-Budde wrote:
> This patch add the driver for the SoC CAN controller in Atmel's AT91SAM9263.
> 
> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>

I already reviewed at91_can.c on the Socket-CAN ML and it's almost OK
from the Socket-CAN point of view. I just realized two minor issues:

> ---
>  drivers/net/can/Kconfig    |    6 +
>  drivers/net/can/Makefile   |    1 +
>  drivers/net/can/at91_can.c | 1177 ++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 1184 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/at91_can.c
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 0900743..b6d2af1 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -82,6 +82,12 @@ config CAN_KVASER_PCI
>  	  This driver is for the the PCIcanx and PCIcan cards (1, 2 or
>  	  4 channel) from Kvaser (http://www.kvaser.com).
>  
> +config CAN_AT91
> +	tristate "Atmel AT91 onchip CAN controller"
> +	depends on CAN && ARCH_AT91SAM9263

It should depend on CAN_DEV because it used the CAN device driver interface.

> +	---help---
> +	  This is a driver for the SoC CAN controller in Atmel's AT91SAM9263.
> +
>  config CAN_DEBUG_DEVICES
>  	bool "CAN devices debugging messages"
>  	depends on CAN
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 523a941..3a54a12 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -8,5 +8,6 @@ obj-$(CONFIG_CAN_DEV)		+= can-dev.o
>  can-dev-y			:= dev.o
>  
>  obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
> +obj-$(CONFIG_CAN_AT91)		+= at91_can.o
>  
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
> new file mode 100644
> index 0000000..cd1e8cb
> --- /dev/null
> +++ b/drivers/net/can/at91_can.c
> @@ -0,0 +1,1177 @@
> +/*
> + * at91_can.c - CAN network driver for AT91 SoC CAN controller
> + *
> + * (C) 2007 by Hans J. Koch <hjk-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> + * (C) 2008, 2009 by Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> + *
> + * This software may be distributed under the terms of the GNU General
> + * Public License ("GPL") version 2 as distributed in the 'COPYING'
> + * file from the main directory of the linux kernel source.
> + *
> + * Send feedback to <socketcan-users-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>

This driver uses platform data. Could you please add some description on
how they should be used, e.g. like for the MCP251x:

 * Your platform definition file should specify something like:
 *
 * static struct mcp251x_platform_data mcp251x_info = {
 *         .oscillator_frequency = 8000000,
 *         .board_specific_setup = &mcp251x_setup,
 *         .model = CAN_MCP251X_MCP2510,
 *         .power_enable = mcp251x_power_enable,
 *         .transceiver_enable = NULL,
 * };
 *
 * static struct spi_board_info spi_board_info[] = {
 *         {
 *                 .modalias      = "mcp251x",
 *                 .platform_data = &mcp251x_info,
 *                 .irq           = IRQ_EINT13,
 *                 .max_speed_hz  = 2*1000*1000,
 *                 .chip_select   = 2,
 *         },
 * };
 *
 * Please see mcp251x.h for a description of the fields in
 * struct mcp251x_platform_data.

I find that really useful.

Wolfgang.
