From: Marc Dietrich <marvin24@gmx.de>
Subject: Re: [PATCH 1/4] net: rfkill: gpio: remove unused and obsolete platform parameters
Date: Fri, 21 Feb 2014 14:55:14 +0100
Message-ID: <1723302.jKkc8NDNRI@fb07-iapwap2>
References: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com> <1392900697-27577-2-git-send-email-heikki.krogerus@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7Bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Chen-Yu Tsai <wens@csie.org>,
	Rhyland Klein <rklein@nvidia.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392900697-27577-2-git-send-email-heikki.krogerus@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Heikki,

Am Donnerstag, 20. Februar 2014, 14:51:34 schrieb Heikki Krogerus:
> After upgrading to descriptor based gpios, the gpio numbers
> are not used anymore. The power_clk_name and the platform
> specific setup and close hooks are not used by anybody, and
> we should not encourage use of such things, so removing them.

arch/arm/mach-tegra/board-paz00.c is still using platform data. Is there some 
prerequisite patch I'm missing (3.14-rc3) or how can this file be converted? 
We are waiting for DT support to arrive so we can finally remove this file.

Marc

> 
> Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
> ---
>  include/linux/rfkill-gpio.h | 10 ----------
>  net/rfkill/rfkill-gpio.c    | 15 +--------------
>  2 files changed, 1 insertion(+), 24 deletions(-)
> 
> diff --git a/include/linux/rfkill-gpio.h b/include/linux/rfkill-gpio.h
> index 4d09f6e..20bcb55 100644
> --- a/include/linux/rfkill-gpio.h
> +++ b/include/linux/rfkill-gpio.h
> @@ -27,21 +27,11 @@
>   * struct rfkill_gpio_platform_data - platform data for rfkill gpio device.
> * for unused gpio's, the expected value is -1.
>   * @name:		name for the gpio rf kill instance
> - * @reset_gpio:		GPIO which is used for reseting rfkill switch
> - * @shutdown_gpio:	GPIO which is used for shutdown of rfkill switch
> - * @power_clk_name:	[optional] name of clk to turn off while blocked
> - * @gpio_runtime_close:	clean up platform specific gpio configuration
> - * @gpio_runtime_setup:	set up platform specific gpio configuration
>   */
> 
>  struct rfkill_gpio_platform_data {
>  	char			*name;
> -	int			reset_gpio;
> -	int			shutdown_gpio;
> -	const char		*power_clk_name;
>  	enum rfkill_type	type;
> -	void	(*gpio_runtime_close)(struct platform_device *);
> -	int	(*gpio_runtime_setup)(struct platform_device *);
>  };
> 
>  #endif /* __RFKILL_GPIO_H */
> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
> index bd2a5b9..0adda44 100644
> --- a/net/rfkill/rfkill-gpio.c
> +++ b/net/rfkill/rfkill-gpio.c
> @@ -87,7 +87,6 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
> {
>  	struct rfkill_gpio_platform_data *pdata = pdev->dev.platform_data;
>  	struct rfkill_gpio_data *rfkill;
> -	const char *clk_name = NULL;
>  	struct gpio_desc *gpio;
>  	int ret;
>  	int len;
> @@ -101,7 +100,6 @@ static int rfkill_gpio_probe(struct platform_device
> *pdev) if (ret)
>  			return ret;
>  	} else if (pdata) {
> -		clk_name = pdata->power_clk_name;
>  		rfkill->name = pdata->name;
>  		rfkill->type = pdata->type;
>  	} else {
> @@ -120,7 +118,7 @@ static int rfkill_gpio_probe(struct platform_device
> *pdev) snprintf(rfkill->reset_name, len + 6 , "%s_reset", rfkill->name);
> snprintf(rfkill->shutdown_name, len + 9, "%s_shutdown", rfkill->name);
> 
> -	rfkill->clk = devm_clk_get(&pdev->dev, clk_name);
> +	rfkill->clk = devm_clk_get(&pdev->dev, NULL);
> 
>  	gpio = devm_gpiod_get_index(&pdev->dev, rfkill->reset_name, 0);
>  	if (!IS_ERR(gpio)) {
> @@ -146,14 +144,6 @@ static int rfkill_gpio_probe(struct platform_device
> *pdev) return -EINVAL;
>  	}
> 
> -	if (pdata && pdata->gpio_runtime_setup) {
> -		ret = pdata->gpio_runtime_setup(pdev);
> -		if (ret) {
> -			dev_err(&pdev->dev, "can't set up gpio\n");
> -			return ret;
> -		}
> -	}
> -
>  	rfkill->rfkill_dev = rfkill_alloc(rfkill->name, &pdev->dev,
>  					  rfkill->type, &rfkill_gpio_ops,
>  					  rfkill);
> @@ -174,10 +164,7 @@ static int rfkill_gpio_probe(struct platform_device
> *pdev) static int rfkill_gpio_remove(struct platform_device *pdev)
>  {
>  	struct rfkill_gpio_data *rfkill = platform_get_drvdata(pdev);
> -	struct rfkill_gpio_platform_data *pdata = pdev->dev.platform_data;
> 
> -	if (pdata && pdata->gpio_runtime_close)
> -		pdata->gpio_runtime_close(pdev);
>  	rfkill_unregister(rfkill->rfkill_dev);
>  	rfkill_destroy(rfkill->rfkill_dev);
