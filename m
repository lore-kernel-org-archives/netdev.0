From: Alexandre Courbot <gnurou@gmail.com>
Subject: Re: [PATCH 2/2] mdio-mux-gpio: use new gpiod_get_array and
 gpiod_put_array functions
Date: Wed, 14 Jan 2015 14:11:27 +0900
Message-ID: <CAAVeFuLqV7CvR2-SNWsrQuBzctQx1wiMtWwjw=cPbp5GRnMdcw@mail.gmail.com>
References: <13407316.QPemVgjPDO@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Rojhalat Ibrahim <imr@rtschenk.de>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <13407316.QPemVgjPDO@pcimr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 10, 2015 at 12:19 AM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:
> Use the new gpiod_get_array and gpiod_put_array functions for obtaining and
> disposing of GPIO descriptors.
>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> ---
> This patch depends on my previous patch "gpiolib: add gpiod_get_array and
> gpiod_put_array functions".
>
>  drivers/net/phy/mdio-mux-gpio.c |   28 ++++++++--------------------
>  1 file changed, 8 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
> index 1eaf81e..35c37da 100644
> --- a/drivers/net/phy/mdio-mux-gpio.c
> +++ b/drivers/net/phy/mdio-mux-gpio.c
> @@ -47,7 +47,6 @@ static int mdio_mux_gpio_probe(struct platform_device *pdev)
>  {
>         struct mdio_mux_gpio_state *s;
>         int num_gpios;
> -       unsigned int n;
>         int r;
>
>         if (!pdev->dev.of_node)
> @@ -63,16 +62,10 @@ static int mdio_mux_gpio_probe(struct platform_device *pdev)
>
>         s->num_gpios = num_gpios;
>
> -       for (n = 0; n < num_gpios; ) {
> -               struct gpio_desc *gpio = gpiod_get_index(&pdev->dev, NULL, n,
> -                                                        GPIOD_OUT_LOW);
> -               if (IS_ERR(gpio)) {
> -                       r = PTR_ERR(gpio);
> -                       goto err;
> -               }
> -               s->gpio[n] = gpio;
> -               n++;
> -       }
> +       r = gpiod_get_array(&pdev->dev, NULL, s->gpio, num_gpios,
> +                           GPIOD_OUT_LOW);
> +       if (r != num_gpios)
> +               return r;
>
>         r = mdio_mux_init(&pdev->dev,
>                           mdio_mux_gpio_switch_fn, &s->mux_handle, s);
> @@ -80,22 +73,17 @@ static int mdio_mux_gpio_probe(struct platform_device *pdev)
>         if (r == 0) {
>                 pdev->dev.platform_data = s;
>                 return 0;
> +       } else {
> +               gpiod_put_array(s->gpio, num_gpios);
> +               return r;
>         }

Suggestion: handle the errors in the if condition, and let normal
execution be visible at the first level of indentation of the
function. I.e:

    if (r != 0) {
        gpiod_put_array(s->gpio, num_gpios);
        return r;
    }

    pdev->dev.platform_data = s;
    return 0;

This is how previous errors are handled in this function and is
generally a good thing to do as it makes the function's logic easier
to follow.
