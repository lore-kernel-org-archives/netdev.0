From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH v3 2/6] net: rfkill: gpio: convert to descriptor-based
 GPIO interface
Date: Wed, 11 Dec 2013 13:00:18 +0100
Message-ID: <CACRpkdb03X_Z7amX-vAVX8KboeCo3ia6oqv8KW79WY=nZXV7wQ@mail.gmail.com>
References: <1385460350-17543-1-git-send-email-mika.westerberg@linux.intel.com>
	<1385460350-17543-3-git-send-email-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Chris Ball <cjb@laptop.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Rhyland Klein <rklein@nvidia.com>,
	Adrian Hunter <adrian.hunter@intel.com>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Mathias Nyman <mathias.nyman@linux.intel.com>,
	Rob Landley <rob@landley.net>,
	Heikki Krogerus <heikki.krogerus@linux.intel.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Thierry Reding <thierry.reding@gmail.com>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Mika Westerberg <mika.westerberg@linux.intel.com>,
	linux-netdev@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <1385460350-17543-3-git-send-email-mika.westerberg@linux.intel.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 26, 2013 at 11:05 AM, Mika Westerberg
<mika.westerberg@linux.intel.com> wrote:

> From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
>
> Convert to the safer gpiod_* family of API functions.
>
> Signed-off-by: Heikki Krogerus <heikki.krogerus@linux.intel.com>
> Signed-off-by: Mika Westerberg <mika.westerberg@linux.intel.com>
> Tested-by: Stephen Warren <swarren@nvidia.com>
> ---
>  net/rfkill/rfkill-gpio.c | 77 +++++++++++++++++++++---------------------------
>  1 file changed, 34 insertions(+), 43 deletions(-)
>
> diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
> index 5620d3c07479..bd2a5b90400c 100644
> --- a/net/rfkill/rfkill-gpio.c
> +++ b/net/rfkill/rfkill-gpio.c
> @@ -25,15 +25,15 @@
>  #include <linux/clk.h>
>  #include <linux/slab.h>
>  #include <linux/acpi.h>
> -#include <linux/acpi_gpio.h>
> +#include <linux/gpio/consumer.h>
>
>  #include <linux/rfkill-gpio.h>
>
>  struct rfkill_gpio_data {
>         const char              *name;
>         enum rfkill_type        type;
> -       int                     reset_gpio;
> -       int                     shutdown_gpio;
> +       struct gpio_desc        *reset_gpio;
> +       struct gpio_desc        *shutdown_gpio;
>
>         struct rfkill           *rfkill_dev;
>         char                    *reset_name;
> @@ -48,19 +48,15 @@ static int rfkill_gpio_set_power(void *data, bool blocked)
>         struct rfkill_gpio_data *rfkill = data;
>
>         if (blocked) {
> -               if (gpio_is_valid(rfkill->shutdown_gpio))
> -                       gpio_set_value(rfkill->shutdown_gpio, 0);
> -               if (gpio_is_valid(rfkill->reset_gpio))
> -                       gpio_set_value(rfkill->reset_gpio, 0);
> +               gpiod_set_value(rfkill->shutdown_gpio, 0);
> +               gpiod_set_value(rfkill->reset_gpio, 0);
>                 if (!IS_ERR(rfkill->clk) && rfkill->clk_enabled)
>                         clk_disable(rfkill->clk);
>         } else {
>                 if (!IS_ERR(rfkill->clk) && !rfkill->clk_enabled)
>                         clk_enable(rfkill->clk);
> -               if (gpio_is_valid(rfkill->reset_gpio))
> -                       gpio_set_value(rfkill->reset_gpio, 1);
> -               if (gpio_is_valid(rfkill->shutdown_gpio))
> -                       gpio_set_value(rfkill->shutdown_gpio, 1);
> +               gpiod_set_value(rfkill->reset_gpio, 1);
> +               gpiod_set_value(rfkill->shutdown_gpio, 1);
>         }
>
>         rfkill->clk_enabled = blocked;
> @@ -83,8 +79,6 @@ static int rfkill_gpio_acpi_probe(struct device *dev,
>
>         rfkill->name = dev_name(dev);
>         rfkill->type = (unsigned)id->driver_data;
> -       rfkill->reset_gpio = acpi_get_gpio_by_index(dev, 0, NULL);
> -       rfkill->shutdown_gpio = acpi_get_gpio_by_index(dev, 1, NULL);
>
>         return 0;
>  }
> @@ -94,8 +88,9 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
>         struct rfkill_gpio_platform_data *pdata = pdev->dev.platform_data;
>         struct rfkill_gpio_data *rfkill;
>         const char *clk_name = NULL;
> -       int ret = 0;
> -       int len = 0;
> +       struct gpio_desc *gpio;
> +       int ret;
> +       int len;
>
>         rfkill = devm_kzalloc(&pdev->dev, sizeof(*rfkill), GFP_KERNEL);
>         if (!rfkill)
> @@ -109,28 +104,10 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
>                 clk_name = pdata->power_clk_name;
>                 rfkill->name = pdata->name;
>                 rfkill->type = pdata->type;
> -               rfkill->reset_gpio = pdata->reset_gpio;
> -               rfkill->shutdown_gpio = pdata->shutdown_gpio;
>         } else {
>                 return -ENODEV;
>         }
>
> -       /* make sure at-least one of the GPIO is defined and that
> -        * a name is specified for this instance */
> -       if ((!gpio_is_valid(rfkill->reset_gpio) &&
> -            !gpio_is_valid(rfkill->shutdown_gpio)) || !rfkill->name) {
> -               pr_warn("%s: invalid platform data\n", __func__);
> -               return -EINVAL;
> -       }
> -
> -       if (pdata && pdata->gpio_runtime_setup) {
> -               ret = pdata->gpio_runtime_setup(pdev);
> -               if (ret) {
> -                       pr_warn("%s: can't set up gpio\n", __func__);
> -                       return ret;
> -               }
> -       }
> -
>         len = strlen(rfkill->name);
>         rfkill->reset_name = devm_kzalloc(&pdev->dev, len + 7, GFP_KERNEL);
>         if (!rfkill->reset_name)
> @@ -145,20 +122,34 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
>
>         rfkill->clk = devm_clk_get(&pdev->dev, clk_name);
>
> -       if (gpio_is_valid(rfkill->reset_gpio)) {
> -               ret = devm_gpio_request_one(&pdev->dev, rfkill->reset_gpio,
> -                                           0, rfkill->reset_name);
> -               if (ret) {
> -                       pr_warn("%s: failed to get reset gpio.\n", __func__);
> +       gpio = devm_gpiod_get_index(&pdev->dev, rfkill->reset_name, 0);
> +       if (!IS_ERR(gpio)) {
> +               ret = gpiod_direction_output(gpio, 0);
> +               if (ret)
>                         return ret;
> -               }
> +               rfkill->reset_gpio = gpio;
> +       }
> +
> +       gpio = devm_gpiod_get_index(&pdev->dev, rfkill->shutdown_name, 1);
> +       if (!IS_ERR(gpio)) {
> +               ret = gpiod_direction_output(gpio, 0);
> +               if (ret)
> +                       return ret;
> +               rfkill->shutdown_gpio = gpio;
>         }
>
> -       if (gpio_is_valid(rfkill->shutdown_gpio)) {
> -               ret = devm_gpio_request_one(&pdev->dev, rfkill->shutdown_gpio,
> -                                           0, rfkill->shutdown_name);
> +       /* Make sure at-least one of the GPIO is defined and that
> +        * a name is specified for this instance
> +        */
> +       if ((!rfkill->reset_gpio && !rfkill->shutdown_gpio) || !rfkill->name) {
> +               dev_err(&pdev->dev, "invalid platform data\n");
> +               return -EINVAL;
> +       }
> +
> +       if (pdata && pdata->gpio_runtime_setup) {
> +               ret = pdata->gpio_runtime_setup(pdev);
>                 if (ret) {
> -                       pr_warn("%s: failed to get shutdown gpio.\n", __func__);
> +                       dev_err(&pdev->dev, "can't set up gpio\n");
>                         return ret;
>                 }
>         }

DavidM: can I have an ACK from you to apply this patch through the GPIO
tree?

Yours,
Linus Walleij
