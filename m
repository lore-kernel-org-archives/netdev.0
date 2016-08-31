From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH 2/3 v2] net: smsc911x: request and deassert optional RESET
 GPIO
Date: Wed, 31 Aug 2016 10:08:48 -0500
Message-ID: <722bf13c-ebce-2a33-a5b7-c654c515ac3c@arm.com>
References: <1472043582-7653-1-git-send-email-linus.walleij@linaro.org>
 <1472043582-7653-2-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Guenter Roeck <linux@roeck-us.net>,
        Kamlakant Patel <kamlakant.patel@broadcom.com>,
        Pavel Fedin <p.fedin@samsung.com>
To: Linus Walleij <linus.walleij@linaro.org>, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:35134 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935178AbcHaPIu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 11:08:50 -0400
In-Reply-To: <1472043582-7653-2-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Linus,

On 08/24/2016 07:59 AM, Linus Walleij wrote:
> On some systems (such as the Qualcomm APQ8060 Dragonboard) the
> RESET signal of the SMSC911x is not pulled up by a resistor but
> connected to a GPIO line, so that the operating system must
> explicitly deassert RESET before use.
>
> Support this in the SMSC911x driver so this ethernet connector
> can be used on such targets.

Hmm, at least in our hardware case AFAIK (juno/lan9118) the hardware 
reset line on the lan9118 is active low, but the chip itself is 
documented as having internal pullups so that it may be left unconnected.

Which microchip/smsc chip are we talking about? because it seems that 
you probably want the GPIO pin to be in any state (hi-Z, or just high) 
besides the one you selected here.

Beyond that, is it not possible for the firmware to get the reset pin in 
the correct configuration, so that linux doesn't have to mess with it?



>
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> ---
> ChangeLog v1->v2:
> - Use devm_gpiod_request_optiona() and request the line with
>   GPIOD_OUT_LOW so it is deasserted immediately if active.
> ---
>  drivers/net/ethernet/smsc/smsc911x.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index ca3134540d2d..8ab8d4b9614b 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -62,6 +62,7 @@
>  #include <linux/acpi.h>
>  #include <linux/pm_runtime.h>
>  #include <linux/property.h>
> +#include <linux/gpio/consumer.h>
>
>  #include "smsc911x.h"
>
> @@ -147,6 +148,9 @@ struct smsc911x_data {
>  	/* regulators */
>  	struct regulator_bulk_data supplies[SMSC911X_NUM_SUPPLIES];
>
> +	/* Reset GPIO */
> +	struct gpio_desc *reset_gpiod;
> +
>  	/* clock */
>  	struct clk *clk;
>  };
> @@ -438,6 +442,11 @@ static int smsc911x_request_resources(struct platform_device *pdev)
>  		netdev_err(ndev, "couldn't get regulators %d\n",
>  				ret);
>
> +	/* Request optional RESET GPIO */
> +	pdata->reset_gpiod = devm_gpiod_get_optional(&pdev->dev,
> +						     "reset",
> +						     GPIOD_OUT_LOW);
> +
>  	/* Request clock */
>  	pdata->clk = clk_get(&pdev->dev, NULL);
>  	if (IS_ERR(pdata->clk))
>
