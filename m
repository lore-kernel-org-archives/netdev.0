From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net/macb: add support for resetting PHY using GPIO
Date: Wed, 9 Dec 2015 19:18:27 +0100
Message-ID: <20151209181827.GS13328@lunn.ch>
References: <1449683383-5022-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	devicetree@vger.kernel.org
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449683383-5022-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 09, 2015 at 06:49:43PM +0100, Gregory CLEMENT wrote:
> With device tree it is no more possible to reset the PHY at board
> level. Furthermore, doing in the driver allow to power down the PHY when
> the network interface is no more used.
> 
> The patch introduces a new optional property "phy-reset-gpio" inspired
> from the one use for the FEC.
> 
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
> ---
>  Documentation/devicetree/bindings/net/macb.txt |  3 +++
>  drivers/net/ethernet/cadence/macb.c            | 26 ++++++++++++++++++++++++++
>  drivers/net/ethernet/cadence/macb.h            |  1 +
>  3 files changed, 30 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
> index b5d7976..546d34d 100644
> --- a/Documentation/devicetree/bindings/net/macb.txt
> +++ b/Documentation/devicetree/bindings/net/macb.txt
> @@ -19,6 +19,9 @@ Required properties:
>  	Optional elements: 'tx_clk'
>  - clocks: Phandles to input clocks.
>  
> +Optional properties:
> +- phy-reset-gpio : Should specify the gpio for phy reset

Hi Gregory

It is convention to use the plural here. So it should be phy-reset-gpios.

> +
>  Examples:
>  
>  	macb0: ethernet@fffc4000 {
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 88c1e1a..e630c56 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -30,6 +30,7 @@
>  #include <linux/of_device.h>
>  #include <linux/of_mdio.h>
>  #include <linux/of_net.h>
> +#include <linux/of_gpio.h>
>  
>  #include "macb.h"
>  
> @@ -2733,6 +2734,28 @@ static int at91ether_init(struct platform_device *pdev)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_OF
> +static void macb_reset_phy(struct macb *bp, struct device_node *np, int state)
> +{
> +	if (!np)
> +		return;
> +
> +	bp->reset_gpio = of_get_named_gpio(np, "phy-reset-gpio", 0);
> +
> +	if (gpio_is_valid(bp->reset_gpio))
> +		gpio_direction_output(bp->reset_gpio, state);

This does not handle the flags part of the GPIO descriptor in device
tree. i.e. ACTIVE_LOW or ACTIVE_HIGH. I think the FEC driver has the
same issue, and is not the best driver to copy. Using the gpiod API
will solve this issue.

     Andrew
