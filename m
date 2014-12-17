From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] dm9000: Add regulator and reset support to dm9000
Date: Wed, 17 Dec 2014 07:19:39 +0100
Message-ID: <20141217061939.GJ30369@pengutronix.de>
References: <1418747624-2682-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	paul.burton@imgtec.com
To: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:35645 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbaLQGTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 01:19:46 -0500
Content-Disposition: inline
In-Reply-To: <1418747624-2682-1-git-send-email-Zubair.Kakakhel@imgtec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Zubair,

Several comments inline.

On Tue, Dec 16, 2014 at 04:33:44PM +0000, Zubair Lutfullah Kakakhel wrote:
> In boards, the dm9000 chip's power and reset can be controlled by gpio.
> 
> It makes sense to add them to the dm9000 driver and let dt be used to
> enable power and reset the phy.
> 
> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
> Signed-off-by: Paul Burton <paul.burton@imgtec.com>
> ---
>  .../devicetree/bindings/net/davicom-dm9000.txt     |  4 +++
>  drivers/net/ethernet/davicom/dm9000.c              | 33 ++++++++++++++++++++++
>  2 files changed, 37 insertions(+)
> 
> diff --git a/Documentation/devicetree/bindings/net/davicom-dm9000.txt b/Documentation/devicetree/bindings/net/davicom-dm9000.txt
> index 28767ed..dba19a2 100644
> --- a/Documentation/devicetree/bindings/net/davicom-dm9000.txt
> +++ b/Documentation/devicetree/bindings/net/davicom-dm9000.txt
> @@ -11,6 +11,8 @@ Required properties:
>  Optional properties:
>  - davicom,no-eeprom : Configuration EEPROM is not available
>  - davicom,ext-phy : Use external PHY
> +- reset-gpio : phandle of gpio that will be used to reset chip during probe
> +- vcc-supply : phandle of regulator that will be used to enable power to chip
>  
>  Example:
>  
> @@ -21,4 +23,6 @@ Example:
>  		interrupts = <7 4>;
>  		local-mac-address = [00 00 de ad be ef];
>  		davicom,no-eeprom;
> +		reset-gpio = <&gpf 12 GPIO_ACTIVE_LOW>;
> +		vcc-supply = <&eth0_power>;
>  	};
> diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
> index ef0bb58..7333b8d 100644
> --- a/drivers/net/ethernet/davicom/dm9000.c
> +++ b/drivers/net/ethernet/davicom/dm9000.c
> @@ -36,6 +36,9 @@
>  #include <linux/platform_device.h>
>  #include <linux/irq.h>
>  #include <linux/slab.h>
> +#include <linux/regulator/consumer.h>
> +#include <linux/gpio.h>
> +#include <linux/of_gpio.h>
>  
>  #include <asm/delay.h>
>  #include <asm/irq.h>
> @@ -1426,11 +1429,41 @@ dm9000_probe(struct platform_device *pdev)
>  	struct dm9000_plat_data *pdata = dev_get_platdata(&pdev->dev);
>  	struct board_info *db;	/* Point a board information structure */
>  	struct net_device *ndev;
> +	struct device *dev = &pdev->dev;
>  	const unsigned char *mac_src;
>  	int ret = 0;
>  	int iosize;
>  	int i;
>  	u32 id_val;
> +	int reset_gpio;
> +	enum of_gpio_flags flags;
> +	struct regulator *power;
> +
> +	power = devm_regulator_get(dev, "vcc");
> +	if (IS_ERR(power)) {
> +		dev_dbg(dev, "no regulator provided\n");

You have to check for errors here. The return value can be -EPROBE_DEFER
in which case you have to return -EPROBE_DEFER from the driver and try
again later.

> +	} else if (!regulator_is_enabled(power)) {

You must enable the regulator unconditionally to increase the reference
counter. When this regulator is turned on because another consumer
enabled it then this other consumer can turn it off and the dm9000 stops
working.

> +		ret = regulator_enable(power);
> +		dev_dgb(dev, "regulator enabled\n");
> +	}
> +
> +	reset_gpio = of_get_named_gpio_flags(dev->of_node, "reset-gpio", 0,
> +					     &flags);

Should be reset-gpios (plural). For some reason this is the established
binding.

> +	if (gpio_is_valid(reset_gpio)) {
> +		ret = devm_gpio_request_one(dev, reset_gpio, flags,
> +					    "dm9000_reset");
> +		if (ret) {
> +			dev_err(dev, "failed to request reset gpio %d: %d\n",
> +				reset_gpio, ret);

I think this is fatal. When A gpio is not registered for this device
then this is fine, but when it's registered and you can't get it then
it's fatal.

> +		} else {
> +			gpio_direction_output(reset_gpio, 0);
> +			/* According to manual PWRST# Low Period Min 1ms */
> +			msleep(2);
> +			gpio_direction_output(reset_gpio, 1);

No need to set the direction again. gpio_set_value should be suffice
here.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
