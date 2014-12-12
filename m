From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH net v2] net: smc91x: Fix build without gpiolib
Date: Fri, 12 Dec 2014 08:11:00 -0800
Message-ID: <20141212161100.GH2950@atomide.com>
References: <1418400429-6680-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:18161 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030528AbaLLQOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 11:14:11 -0500
Content-Disposition: inline
In-Reply-To: <1418400429-6680-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Tobias Klauser <tklauser@distanz.ch> [141212 08:09]:
> If GPIOLIB=n the following build errors occur:
> 
> drivers/net/ethernet/smsc/smc91x.c: In function 'try_toggle_control_gpio':
> drivers/net/ethernet/smsc/smc91x.c:2204:2: error: implicit declaration of function 'devm_gpiod_get_index' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/smsc/smc91x.c:2204:7: warning: assignment makes pointer from integer without a cast [enabled by default]
> drivers/net/ethernet/smsc/smc91x.c:2213:2: error: implicit declaration of function 'gpiod_direction_output' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/smsc/smc91x.c:2216:3: error: implicit declaration of function 'devm_gpiod_put' [-Werror=implicit-function-declaration]
> drivers/net/ethernet/smsc/smc91x.c:2222:2: error: implicit declaration of function 'gpiod_set_value_cansleep' [-Werror=implicit-function-declaration]
> 
> Since the toggling of the GPIOs is an optional feature, define
> try_toggle_control_gpio only if GPIOLIB is enabled.

Oops sorry about that, I guess my systems have it all selected so
randconfig builds did not expose it.

Would it make sense to add the missing gpio stub into
include/linux/gpio/consumer.h instead?

Regards,

Tony
 
> Fixes: 7d2911c4381 ("net: smc91x: Fix gpios for device tree based booting")
> Cc: Tony Lindgren <tony@atomide.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---
>  drivers/net/ethernet/smsc/smc91x.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
> index 6cc3cf6..050bcb6 100644
> --- a/drivers/net/ethernet/smsc/smc91x.c
> +++ b/drivers/net/ethernet/smsc/smc91x.c
> @@ -2193,6 +2193,7 @@ MODULE_DEVICE_TABLE(of, smc91x_match);
>  /**
>   * of_try_set_control_gpio - configure a gpio if it exists
>   */
> +#ifdef CONFIG_GPIOLIB
>  static int try_toggle_control_gpio(struct device *dev,
>  				   struct gpio_desc **desc,
>  				   const char *name, int index,
> @@ -2224,7 +2225,16 @@ static int try_toggle_control_gpio(struct device *dev,
>  
>  	return 0;
>  }
> -#endif
> +#else
> +static int try_toggle_control_gpio(struct device *dev,
> +				   struct gpio_desc **desc,
> +				   const char *name, int index,
> +				   int value, unsigned int nsdelay)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_GPIOLIB */
> +#endif /* CONFIG_OF */
>  
>  /*
>   * smc_init(void)
> -- 
> 2.2.0
> 
> 
