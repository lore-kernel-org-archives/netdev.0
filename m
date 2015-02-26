From: Alexandre Courbot <gnurou@gmail.com>
Subject: Re: [PATCH v5 4/4] mdio-mux-gpio: use new gpiod_get_array and
 gpiod_put_array functions
Date: Thu, 26 Feb 2015 18:54:53 +0900
Message-ID: <CAAVeFuLnHQpsduHRsEkSC31+HDiApNoB3DNDQLzZxng=OVx6eg@mail.gmail.com>
References: <1521782.cXqN30N6pA@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Rojhalat Ibrahim <imr@rtschenk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:40833 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbbBZJzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 04:55:14 -0500
In-Reply-To: <1521782.cXqN30N6pA@pcimr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 12, 2015 at 1:28 AM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:
> Use the new gpiod_get_array and gpiod_put_array functions for obtaining and
> disposing of GPIO descriptors.
>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> ---
> Change log:
>   v5: no change
>   v4: use shorter names for members of struct gpio_descs
>   v3: no change
>   v2: use the new interface
>
>  drivers/net/phy/mdio-mux-gpio.c | 60 ++++++++++++-----------------------------
>  1 file changed, 17 insertions(+), 43 deletions(-)
>
> diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
> index 320eb15..c49ad09 100644
> --- a/drivers/net/phy/mdio-mux-gpio.c
> +++ b/drivers/net/phy/mdio-mux-gpio.c
> @@ -12,33 +12,30 @@
>  #include <linux/module.h>
>  #include <linux/phy.h>
>  #include <linux/mdio-mux.h>
> -#include <linux/of_gpio.h>
> +#include <linux/gpio/consumer.h>
>
>  #define DRV_VERSION "1.1"
>  #define DRV_DESCRIPTION "GPIO controlled MDIO bus multiplexer driver"
>
> -#define MDIO_MUX_GPIO_MAX_BITS 8
> -
>  struct mdio_mux_gpio_state {
> -       struct gpio_desc *gpio[MDIO_MUX_GPIO_MAX_BITS];
> -       unsigned int num_gpios;
> +       struct gpio_descs *gpios;
>         void *mux_handle;
>  };
>
>  static int mdio_mux_gpio_switch_fn(int current_child, int desired_child,
>                                    void *data)
>  {
> -       int values[MDIO_MUX_GPIO_MAX_BITS];
> -       unsigned int n;
>         struct mdio_mux_gpio_state *s = data;
> +       int values[s->gpios->ndescs];
> +       unsigned int n;
>
>         if (current_child == desired_child)
>                 return 0;
>
> -       for (n = 0; n < s->num_gpios; n++) {
> +       for (n = 0; n < s->gpios->ndescs; n++)
>                 values[n] = (desired_child >> n) & 1;
> -       }
> -       gpiod_set_array_cansleep(s->num_gpios, s->gpio, values);
> +
> +       gpiod_set_array_cansleep(s->gpios->ndescs, s->gpios->desc, values);

One suggestion for a possible further improvement: it would be great
if the gpiod_set/get_array() functions would work on a struct
gpio_descs so users don't have to pass both the number of GPIOs and
the array.

I don't know whether it would be desirable to keep alternative
functions that preserve the current form, for users who want to set
multiple GPIOs but cannot use gpiod_get_array(). struct gpiod_descs is
easy to build, so maybe we don't need them?
