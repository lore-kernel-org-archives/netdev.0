From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH 5/5] net: rfkill: gpio: add ACPI support
Date: Wed, 16 Oct 2013 22:55:01 +0200
Message-ID: <2878506.7lf24R85t6@vostro.rjw.lan>
References: <1381920823-15403-1-git-send-email-heikki.krogerus@linux.intel.com> <1381920823-15403-6-git-send-email-heikki.krogerus@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Rhyland Klein <rklein@nvidia.com>, linux-acpi@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Mika Westerberg <mika.westerberg@linux.intel.com>
To: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from v094114.home.net.pl ([79.96.170.134]:54777 "HELO
	v094114.home.net.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S934413Ab3JPUnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 16:43:11 -0400
In-Reply-To: <1381920823-15403-6-git-send-email-heikki.krogerus@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, October 16, 2013 01:53:43 PM Heikki Krogerus wrote:
> Including ACPI ID for Broadcom GPS receiver BCM4752.
> 
> Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
> ---
>  net/rfkill/rfkill-gpio.c | 31 ++++++++++++++++++++++++++++++-
>  1 file changed, 30 insertions(+), 1 deletion(-)
> 
> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
> index 2dd78c6..5620d3c 100644
> --- a/net/rfkill/rfkill-gpio.c
> +++ b/net/rfkill/rfkill-gpio.c
> @@ -24,6 +24,8 @@
>  #include <linux/platform_device.h>
>  #include <linux/clk.h>
>  #include <linux/slab.h>
> +#include <linux/acpi.h>
> +#include <linux/acpi_gpio.h>
>  
>  #include <linux/rfkill-gpio.h>
>  
> @@ -70,6 +72,23 @@ static const struct rfkill_ops rfkill_gpio_ops = {
>  	.set_block = rfkill_gpio_set_power,
>  };
>  
> +static int rfkill_gpio_acpi_probe(struct device *dev,
> +				  struct rfkill_gpio_data *rfkill)
> +{
> +	const struct acpi_device_id *id;
> +
> +	id = acpi_match_device(dev->driver->acpi_match_table, dev);
> +	if (!id)
> +		return -ENODEV;
> +
> +	rfkill->name = dev_name(dev);
> +	rfkill->type = (unsigned)id->driver_data;
> +	rfkill->reset_gpio = acpi_get_gpio_by_index(dev, 0, NULL);
> +	rfkill->shutdown_gpio = acpi_get_gpio_by_index(dev, 1, NULL);
> +
> +	return 0;
> +}
> +
>  static int rfkill_gpio_probe(struct platform_device *pdev)
>  {
>  	struct rfkill_gpio_platform_data *pdata = pdev->dev.platform_data;
> @@ -82,7 +101,11 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
>  	if (!rfkill)
>  		return -ENOMEM;
>  
> -	if (pdata) {
> +	if (ACPI_HANDLE(&pdev->dev)) {
> +		ret = rfkill_gpio_acpi_probe(&pdev->dev, rfkill);
> +		if (ret)
> +			return ret;
> +	} else if (pdata) {
>  		clk_name = pdata->power_clk_name;
>  		rfkill->name = pdata->name;
>  		rfkill->type = pdata->type;
> @@ -170,12 +193,18 @@ static int rfkill_gpio_remove(struct platform_device *pdev)
>  	return 0;
>  }
>  
> +static const struct acpi_device_id rfkill_acpi_match[] = {
> +	{ "BCM4752", RFKILL_TYPE_GPS },
> +	{ },
> +};
> +
>  static struct platform_driver rfkill_gpio_driver = {
>  	.probe = rfkill_gpio_probe,
>  	.remove = rfkill_gpio_remove,
>  	.driver = {
>  		.name = "rfkill_gpio",
>  		.owner = THIS_MODULE,
> +		.acpi_match_table = ACPI_PTR(rfkill_acpi_match),
>  	},
>  };

Looks good to me.

Has Mika seen this?

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
