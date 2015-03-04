From: Rojhalat Ibrahim <imr@rtschenk.de>
Subject: Re: [PATCH v5 4/4] mdio-mux-gpio: use new gpiod_get_array and gpiod_put_array functions
Date: Wed, 04 Mar 2015 15:33:56 +0100
Message-ID: <7922544.OK5CjAi0mG@pcimr>
References: <1521782.cXqN30N6pA@pcimr> <1842407.4EyTjGZBVF@pcimr> <CAAVeFuLt0Oy9QK+BJ5zAb-CugKi0n4ruy6=+CWQwgS9J0=dfrQ@mail.gmail.com>
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
In-Reply-To: <CAAVeFuLt0Oy9QK+BJ5zAb-CugKi0n4ruy6=+CWQwgS9J0=dfrQ@mail.gmail.com>
Sender: linux-gpio-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 04 March 2015 22:22:24 Alexandre Courbot wrote:
> On Tue, Mar 3, 2015 at 6:45 PM, Rojhalat Ibrahim <imr@rtschenk.de> wrote:
> > On Thursday 26 February 2015 18:54:53 Alexandre Courbot wrote:

> >> One suggestion for a possible further improvement: it would be great
> >> if the gpiod_set/get_array() functions would work on a struct
> >> gpio_descs so users don't have to pass both the number of GPIOs and
> >> the array.
> >>
> >> I don't know whether it would be desirable to keep alternative
> >> functions that preserve the current form, for users who want to set
> >> multiple GPIOs but cannot use gpiod_get_array(). struct gpiod_descs is
> >> easy to build, so maybe we don't need them?
> >>
> >
> > I thought about that, but didn't want to change the interface in this
> > patch series.
> >
> > Furthermore there is this use case (my use case):
> >
> > I acquire a descriptor array for multiple data outputs and (among others) a
> > single descriptor for a clock output. Afterwards I want to set the data bits
> > and simultaneously clear the clock bit (using gpiod_set_array) before setting
> > only the clock output (using gpiod_set_value).
> >
> > Therefore I need an array containing the data bits and the clock bit which
> > is easy to build.
> >
> > I could also create a struct gpiod_descs but it would be more complicated
> > since I would have to allocate a new struct before populating it with the
> > descriptors and also free the allocated memory afterwards. It's not really
> > a big deal but more complicated than before.
> >
> > But this might not be a very common use case.
> >
> > If we can assume that for the common use case the group of descriptors that
> > can be acquired using gpiod_get_array() is the same group that should be
> > set using gpiod_set_array(), it might make sense to change the interface.
> 
> Ah, thanks for sharing your use-case. I wish I had heard it earlier as
> it seems we should make things more flexible than they currently are.
> 
> If I followed you correctly, you need to call gpiod_get_array() to
> obtain the data lines, and gpiod_get() for the clock line. Then you
> need to allocate a new array of gpio_desc * and copy all the
> descriptors there before calling gpiod_set_array(). So simply put, the
> struct gpio_descs you obtained is just useless to you.
> 
> It seems like we have been doing things wrong. Maybe gpiod_get_array()
> should simply take a pointer to a gpio_desc * array that it would
> fill, as you originally proposed?
> 
> So now, the question is: do we need struct gpiod_descs at all? It can
> help reducing the number of arguments passed to functions, but also
> makes the whole API more rigid. Use it with gpiod_get_array(), and you
> end up with unneeded copies and memory allocations. Pass it to
> gpiod_set_array() and you cannot do things like setting only part of
> the GPIOs you requested.
> 
> Argh, and looking closer there is some possible confusion between
> gpiod_set_array() and gpiod_get_array(). One might expect the latter
> to return the *values* of the GPIOs, considering the name of the
> former, while it actually is the array counterpart of gpiod_get(). To
> be consistent with the single descriptor API, I suppose we should
> rename gpiod_set_array() to gpiod_set_array_value(). But that's a
> separate issue.
> 
> For now, since you are the main user of the array API, what is your
> opinion about gpiod_descs? Do you think it is worth making the API
> less flexible just to not have to carry an array lengh separately?
> Should we just get rid of it?

I don't think it's that bad.

As I said before my use case might be very different from the common use case.

Furthermore the alternative API, that fills a pre-allocated array, wouldn't
make things easier. I would still have an array of data lines and a separate
descriptor for the clock. For setting them all together I would still have to
create an array containing the data and the clock descriptors. Creating this
array is not a big deal because it can be a static global array or an on stack
array in the context of a function. So no calls to kalloc / kfree are needed.

And the interface as proposed in this series is very convenient for obtaining
all the GPIOs belonging to a group with a single function call and without
having to know the number of GPIOs within the group beforehand.

So if we want to support different use cases, I think it's quite good as it is.
People who want to set a group of GPIOs as obtained by gpiod_get_array() can
do so with a single call to gpiod_set_array(), the only overhead being that
they have to specify the two elements of struct gpiod_descs explicitly.
Likewise people who want to set a group of GPIOs obtained with a combination
of calls to gpiod_get_array() and gpiod_get() can do so too. They just have
to create that group first.

On the other hand if gpiod_set_array() would require a struct gpiod_descs as
argument the creation of a group for the second use case would become more
complicated as you would have to allocate a struct instead of an array, etc.

So let's just keep it the way it is and get this series merged.

About the confusing function names: I would be happy to submit a patch
renaming gpiod_set_array() to gpiod_set_array_value(), once this has been
merged. I'm a little concerned about the length of some function names though.
Isn't gpiod_set_raw_array_value_cansleep() a bit long?


