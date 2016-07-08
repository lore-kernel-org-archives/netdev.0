From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 2/3] net: smsc911x: request and deassert optional RESET
 GPIO
Date: Fri, 8 Jul 2016 06:52:55 -0700
Message-ID: <577FB037.4070901@roeck-us.net>
References: <1467968852-6175-1-git-send-email-linus.walleij@linaro.org>
 <1467968852-6175-2-git-send-email-linus.walleij@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeremy Linton <jeremy.linton@arm.com>,
	Kamlakant Patel <kamlakant.patel@broadcom.com>,
	Pavel Fedin <p.fedin@samsung.com>
To: Linus Walleij <linus.walleij@linaro.org>, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:33766 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932713AbcGHNxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 09:53:08 -0400
In-Reply-To: <1467968852-6175-2-git-send-email-linus.walleij@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/08/2016 02:07 AM, Linus Walleij wrote:
> On some systems (such as the Qualcomm APQ8060 Dragonboard) the
> RESET signal of the SMSC911x is not pulled up by a resistor but
> connected to a GPIO line, so that the operating system must
> explicitly deassert RESET before use.
>
> Support this in the SMSC911x driver so this ethernet connector
> can be used on such targets.
>
> Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
> ---
>   drivers/net/ethernet/smsc/smsc911x.c | 13 +++++++++++++
>   1 file changed, 13 insertions(+)
>
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index 8af25563f627..125d58ac22bd 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -62,6 +62,7 @@
>   #include <linux/acpi.h>
>   #include <linux/pm_runtime.h>
>   #include <linux/property.h>
> +#include <linux/gpio/consumer.h>
>
>   #include "smsc911x.h"
>
> @@ -149,6 +150,9 @@ struct smsc911x_data {
>   	/* regulators */
>   	struct regulator_bulk_data supplies[SMSC911X_NUM_SUPPLIES];
>
> +	/* Reset GPIO */
> +	struct gpio_desc *reset_gpiod;
> +
>   	/* clock */
>   	struct clk *clk;
>   };
> @@ -440,6 +444,15 @@ static int smsc911x_request_resources(struct platform_device *pdev)
>   		netdev_err(ndev, "couldn't get regulators %d\n",
>   				ret);
>
> +	/* Request optional RESET GPIO */
> +	pdata->reset_gpiod = devm_gpiod_get(&pdev->dev, "reset",
> +					    GPIOD_OUT_HIGH);
> +	/* Deassert the signal */
> +	if (!IS_ERR(pdata->reset_gpiod)) {

This could return -EPROBE_DEFER, which should probably not be ignored.

It might be better to use devm_gpiod_get_optional(). If you pass GPIOD_OUT_LOW
as parameter to that function, it should take the chip out of reset immediately.
See drivers/i2c/muxes/i2c-mux-pca954x.c for an example with a similar use case.

Guenter

> +		dev_info(&pdev->dev, "release reset\n");
> +		gpiod_set_value(pdata->reset_gpiod, 0);
> +	}
> +
>   	/* Request clock */
>   	pdata->clk = clk_get(&pdev->dev, NULL);
>   	if (IS_ERR(pdata->clk))
>
