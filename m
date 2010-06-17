From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] CAN: Add Flexcan CAN controller driver
Date: Thu, 17 Jun 2010 21:12:11 +0200
Message-ID: <4C1A738B.5050600@grandegger.com>
References: <1276784480-32340-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1276784480-32340-1-git-send-email-mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

On 06/17/2010 04:21 PM, Marc Kleine-Budde wrote:
> From: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> 
> This core is found on some Freescale SoCs and also some Coldfire
> SoCs. Support for Coldfire is missing though at the moment as
> they have an older revision of the core which does not have RX FIFO
> support.
> 
> Signed-off-by: Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> Signed-off-by: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
> ---
>  drivers/net/can/Kconfig              |    6 +
>  drivers/net/can/Makefile             |    1 +
>  drivers/net/can/flexcan.c            | 1010 ++++++++++++++++++++++++++++++++++
>  include/linux/can/platform/flexcan.h |   20 +
>  4 files changed, 1037 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/flexcan.c
>  create mode 100644 include/linux/can/platform/flexcan.h
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 05b7517..3d932a4 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -63,6 +63,12 @@ config CAN_BFIN
>  	  To compile this driver as a module, choose M here: the
>  	  module will be called bfin_can.
>  
> +config CAN_FLEXCAN
> +	tristate "Support for Freescale FLEXCAN based chips"
> +	depends on CAN_DEV
> +	---help---
> +	  Say Y here if you want to support for Freescale FlexCAN.
> +
>  source "drivers/net/can/mscan/Kconfig"
>  
>  source "drivers/net/can/sja1000/Kconfig"
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 7a702f2..5bf3621 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -15,5 +15,6 @@ obj-$(CONFIG_CAN_AT91)		+= at91_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
>  obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
>  obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
> +obj-$(CONFIG_CAN_FLEXCAN)	+= flexcan.o
>  
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> new file mode 100644
> index 0000000..f341989
> --- /dev/null
> +++ b/drivers/net/can/flexcan.c
> @@ -0,0 +1,1010 @@
> +/*
> + * flexcan.c - FLEXCAN CAN controller driver
> + *
> + * Copyright (c) 2005-2006 Varma Electronics Oy
> + * Copyright (c) 2009 Sascha Hauer, Pengutronix
> + * Copyright (c) 2010 Marc Kleine-Budde, Pengutronix
> + *
> + * Based on code originally by Andrey Volkov <avolkov-ppI4tVfbJvJWk0Htik3J/w@public.gmane.org>
> + *
> + * LICENCE:
> + *  This program is free software; you can redistribute it and/or modify
> + *  it under the terms of the GNU General Public License as published by
> + *  the Free Software Foundation; either version 2 of the License, or
> + *  (at your option) any later version.
> + *
> + *  This program is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + *  GNU General Public License for more details.
> + *
> + *  You should have received a copy of the GNU General Public License
> + *  along with this program; if not, write to the Free Software
> + *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + *
> + */
...
> +MODULE_AUTHOR("Sascha Hauer <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, "
> +	      "Marc Kleine-Budde <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>");
> +MODULE_LICENSE("GPL v2");

This does not match to the license text above.

Wolfgang.
