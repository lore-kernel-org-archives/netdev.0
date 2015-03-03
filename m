From: Rojhalat Ibrahim <imr@rtschenk.de>
Subject: Re: [PATCH v5 4/4] mdio-mux-gpio: use new gpiod_get_array and gpiod_put_array functions
Date: Tue, 03 Mar 2015 10:45:10 +0100
Message-ID: <1842407.4EyTjGZBVF@pcimr>
References: <1521782.cXqN30N6pA@pcimr> <CAAVeFuLnHQpsduHRsEkSC31+HDiApNoB3DNDQLzZxng=OVx6eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "linux-gpio@vger.kernel.org" <linux-gpio@vger.kernel.org>,
	Alexandre Courbot <acourbot@nvidia.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Alexandre Courbot <gnurou@gmail.com>
Return-path: <linux-gpio-owner@vger.kernel.org>
In-Reply-To: <CAAVeFuLnHQpsduHRsEkSC31+HDiApNoB3DNDQLzZxng=OVx6eg@mail.gmail.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 26 February 2015 18:54:53 Alexandre Courbot wrote:
> On Thu, Feb 12, 2015 at 1:28 AM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:
> > Use the new gpiod_get_array and gpiod_put_array functions for obtaining and
> > disposing of GPIO descriptors.
> >
> > Cc: David Miller <davem@davemloft.net>
> > Signed-off-by: Rojhalat Ibrahim <imr@rtschenk.de>
> > ---
> > Change log:
> >   v5: no change
> >   v4: use shorter names for members of struct gpio_descs
> >   v3: no change
> >   v2: use the new interface
> >
> >  drivers/net/phy/mdio-mux-gpio.c | 60 ++++++++++++-----------------------------
> >  1 file changed, 17 insertions(+), 43 deletions(-)
> >
> > diff --git a/drivers/net/phy/mdio-mux-gpio.c b/drivers/net/phy/mdio-mux-gpio.c
> > index 320eb15..c49ad09 100644
> > --- a/drivers/net/phy/mdio-mux-gpio.c
> > +++ b/drivers/net/phy/mdio-mux-gpio.c
> > @@ -12,33 +12,30 @@
> >  #include <linux/module.h>
> >  #include <linux/phy.h>
> >  #include <linux/mdio-mux.h>
> > -#include <linux/of_gpio.h>
> > +#include <linux/gpio/consumer.h>
> >
> >  #define DRV_VERSION "1.1"
> >  #define DRV_DESCRIPTION "GPIO controlled MDIO bus multiplexer driver"
> >
> > -#define MDIO_MUX_GPIO_MAX_BITS 8
> > -
> >  struct mdio_mux_gpio_state {
> > -       struct gpio_desc *gpio[MDIO_MUX_GPIO_MAX_BITS];
> > -       unsigned int num_gpios;
> > +       struct gpio_descs *gpios;
> >         void *mux_handle;
> >  };
> >
> >  static int mdio_mux_gpio_switch_fn(int current_child, int desired_child,
> >                                    void *data)
> >  {
> > -       int values[MDIO_MUX_GPIO_MAX_BITS];
> > -       unsigned int n;
> >         struct mdio_mux_gpio_state *s = data;
> > +       int values[s->gpios->ndescs];
> > +       unsigned int n;
> >
> >         if (current_child == desired_child)
> >                 return 0;
> >
> > -       for (n = 0; n < s->num_gpios; n++) {
> > +       for (n = 0; n < s->gpios->ndescs; n++)
> >                 values[n] = (desired_child >> n) & 1;
> > -       }
> > -       gpiod_set_array_cansleep(s->num_gpios, s->gpio, values);
> > +
> > +       gpiod_set_array_cansleep(s->gpios->ndescs, s->gpios->desc, values);
> 
> One suggestion for a possible further improvement: it would be great
> if the gpiod_set/get_array() functions would work on a struct
> gpio_descs so users don't have to pass both the number of GPIOs and
> the array.
> 
> I don't know whether it would be desirable to keep alternative
> functions that preserve the current form, for users who want to set
> multiple GPIOs but cannot use gpiod_get_array(). struct gpiod_descs is
> easy to build, so maybe we don't need them?
> 

I thought about that, but didn't want to change the interface in this
patch series.

Furthermore there is this use case (my use case):

I acquire a descriptor array for multiple data outputs and (among others) a
single descriptor for a clock output. Afterwards I want to set the data bits
and simultaneously clear the clock bit (using gpiod_set_array) before setting
only the clock output (using gpiod_set_value).

Therefore I need an array containing the data bits and the clock bit which
is easy to build.

I could also create a struct gpiod_descs but it would be more complicated
since I would have to allocate a new struct before populating it with the
descriptors and also free the allocated memory afterwards. It's not really
a big deal but more complicated than before.

But this might not be a very common use case.

If we can assume that for the common use case the group of descriptors that
can be acquired using gpiod_get_array() is the same group that should be
set using gpiod_set_array(), it might make sense to change the interface.

   Rojhalat

