From: Alexandre Courbot <gnurou@gmail.com>
Subject: Re: [PATCH] mdio-mux-gpio: Use GPIO descriptor interface and new
 gpiod_set_array function
Date: Tue, 25 Nov 2014 12:39:13 +0900
Message-ID: <CAAVeFuKTmQi3vK5vALbT=hseRm9mn=-cb-7hiHwg7Zbczmz_WA@mail.gmail.com>
References: <6441674.xrJo8HXDvD@pcimr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Daney <david.daney@cavium.com>,
	"linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Alexandre Courbot <acourbot@nvidia.com>
To: Rojhalat Ibrahim <imr@rtschenk.de>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <6441674.xrJo8HXDvD@pcimr>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 20, 2014 at 9:24 PM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:
> Convert mdio-mux-gpio to the GPIO descriptor interface and use the new
> gpiod_set_array function to set all output signals simultaneously.
>
> Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> --
> This patch depends on the gpiod_set_array function, which is available in
> the linux-gpio devel tree.
>
>  drivers/net/phy/mdio-mux-gpio.c |   35 +++++++++++++++--------------------
>  1 file changed, 15 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
> index 0966951..3fdea96 100644
> --- a/drivers/net/phy/mdio-mux-gpio.c
> +++ b/drivers/net/phy/mdio-mux-gpio.c
> @@ -14,13 +14,13 @@
>  #include <linux/mdio-mux.h>
>  #include <linux/of_gpio.h>
>
> -#define DRV_VERSION "1.0"
> +#define DRV_VERSION "1.1"
>  #define DRV_DESCRIPTION "GPIO controlled MDIO bus multiplexer driver"
>
>  #define MDIO_MUX_GPIO_MAX_BITS 8
>
>  struct mdio_mux_gpio_state {
> -       int gpio[MDIO_MUX_GPIO_MAX_BITS];
> +       struct gpio_desc *gpio[MDIO_MUX_GPIO_MAX_BITS];
>         unsigned int num_gpios;
>         void *mux_handle;
>  };
> @@ -28,29 +28,23 @@ struct mdio_mux_gpio_state {
>  static int mdio_mux_gpio_switch_fn(int current_child, int desired_child,
>                                    void *data)
>  {
> -       int change;
> +       int values[MDIO_MUX_GPIO_MAX_BITS];
>         unsigned int n;
>         struct mdio_mux_gpio_state *s = data;
>
>         if (current_child == desired_child)
>                 return 0;
>
> -       change = current_child == -1 ? -1 : current_child ^ desired_child;
> -
>         for (n = 0; n < s->num_gpios; n++) {
> -               if (change & 1)
> -                       gpio_set_value_cansleep(s->gpio[n],
> -                                               (desired_child & 1) != 0);
> -               change >>= 1;
> -               desired_child >>= 1;
> +               values[n] = (desired_child >> n) & 1;
>         }
> +       gpiod_set_array_cansleep(s->num_gpios, s->gpio, values);
>
>         return 0;
>  }
>
>  static int mdio_mux_gpio_probe(struct platform_device *pdev)
>  {
> -       enum of_gpio_flags f;
>         struct mdio_mux_gpio_state *s;
>         int num_gpios;
>         unsigned int n;
> @@ -70,20 +64,17 @@ static int mdio_mux_gpio_probe(struct platform_device *pdev)
>         s->num_gpios = num_gpios;
>
>         for (n = 0; n < num_gpios; ) {
> -               int gpio = of_get_gpio_flags(pdev->dev.of_node, n, &f);
> -               if (gpio < 0) {
> -                       r = (gpio == -ENODEV) ? -EPROBE_DEFER : gpio;
> +               struct gpio_desc *gpio = gpiod_get_index(&pdev->dev,
> +                                                        "mdio-mux-gpio", n);

Doesn't this change introduce some incompatibility against the current
DT bindings? of_get_gpio_flags() looks for a "gpios" property, while
your call to gpiod_get_index() will look for "mdio-mux-gpio-gpios". It
should probably be changed to gpiod_get_index(&pdev->dev, NULL, n).

... or even be changed to gpiod_get_index(&pdev->dev, NULL, n,
GPIOD_OUT_LOW) as the calls to gpiod_get() functions are being updated
to take an initial state (both variants are currently usable but the
former one will disappear in the future). This will also allow you to
get rid of your call to gpiod_direction_output().

Side-note: it would be nice to have a gpiod_get_array() call that does
exactly what this loop does, and returns an array of gpios directly
usable by gpiod_set_array*(). And a matching gpiod_put_array() of
course.
