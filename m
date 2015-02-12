From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v2 2/2] NFC: Add ACPI support for NXP PN544
Date: Thu, 12 Feb 2015 20:26:16 +0100
Message-ID: <20150212192616.GH10842@pengutronix.de>
References: <1422270817-10950-1-git-send-email-robert.dolca@intel.com>
 <1422270817-10950-3-git-send-email-robert.dolca@intel.com>
 <20150212081459.GA28954@pengutronix.de>
 <20150212174843.GA4007@rdolca-desk.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-nfc@ml01.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Berg Johannes <johannes.berg@intel.com>,
	Clement Perrochaud <clement.perrochaud@nxp.com>
To: Robert Dolca <robert.dolca@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150212174843.GA4007@rdolca-desk.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Robert,

On Thu, Feb 12, 2015 at 07:48:43PM +0200, Robert Dolca wrote:
> On Thu, Feb 12, 2015 at 09:14:59AM +0100, Uwe Kleine-K=F6nig wrote:
> > On Mon, Jan 26, 2015 at 01:13:37PM +0200, Robert Dolca wrote:
> > > +	/* Get EN GPIO from ACPI */
> > > +	gpiod_en =3D devm_gpiod_get_index(dev, PN544_GPIO_NAME_EN, 1);
> > Actually devm_gpiod_get_index takes 4 arguments. In your case you s=
hould
> > also pass GPIOD_OUT_LOW, then you can skip the gpiod_direction_outp=
ut
> > part below.
> >=20
> > > +	if (IS_ERR(gpiod_en)) {
> > > +		nfc_err(dev,
> > > +			"Unable to get EN GPIO\n");
> > > +		return -ENODEV;
> > > +	}
> > > +
> > > +	phy->gpio_en  =3D desc_to_gpio(gpiod_en);
> > Why don't you save a reference to the gpiod instead? Mixing usage o=
f raw
> > and gpiod might result in surprising results. For example
> >=20
> > 	gpiod_direction_output(gpiod_en, 0);
> >=20
> > might actually have the same result as
> >=20
> > 	gpio_direction_output(gpio_en, 1);
> >=20
> > if the matching gpio is marked as active low.
> >=20
> > > +
> > > +	/* Configuration EN GPIO */
> > > +	ret =3D gpiod_direction_output(gpiod_en, 0);
> > > +	if (ret) {
> > > +		nfc_err(dev, "Fail EN pin direction\n");
> > > +		return ret;
> > > +	}
> > > +
> > > +	/* Get FW GPIO from ACPI */
> > > +	gpiod_fw =3D devm_gpiod_get_index(dev, PN544_GPIO_NAME_FW, 2);
> > > +	if (IS_ERR(gpiod_fw)) {
> > > +		nfc_err(dev,
> > > +			"Unable to get FW GPIO\n");
> > > +		return -ENODEV;
> > > +	}
> > > +
> > > +	phy->gpio_fw  =3D desc_to_gpio(gpiod_fw);
> > > +
> > > +	/* Configuration FW GPIO */
> > > +	ret =3D gpiod_direction_output(gpiod_fw, 0);
> > > +	if (ret) {
> > > +		nfc_err(dev, "Fail FW pin direction\n");
> > > +		return ret;
> > > +	}
> > The same comments apply here.
> >=20
> > > +
> > > +	/* Get IRQ GPIO */
> > > +	gpiod_irq =3D devm_gpiod_get_index(dev, PN544_GPIO_NAME_IRQ, 0)=
;
> > > +	if (IS_ERR(gpiod_irq)) {
> > > +		nfc_err(dev,
> > > +			"Unable to get IRQ GPIO\n");
> > > +		return -ENODEV;
> > > +	}
> > > +
> > > +	phy->gpio_irq =3D desc_to_gpio(gpiod_irq);
> > > +
> > > +	/* Configure IRQ GPIO */
> > > +	ret =3D gpiod_direction_input(gpiod_irq);
> > > +	if (ret) {
> > > +		nfc_err(dev, "Fail IRQ pin direction\n");
> > > +		return ret;
> > > +	}
> > > +
> > > +	/* Map the pin to an IRQ */
> > > +	ret =3D gpiod_to_irq(gpiod_irq);
> > > +	if (ret < 0) {
> > > +		nfc_err(dev, "Fail pin IRQ mapping\n");
> > > +		return ret;
> > > +	}
> > and here.
=20
> Also as far as I know the device tree implementation will not give yo=
u the
> gpiod data structure. It gives you only the gpio index.
What is "the device tree implementation"? If devm_gpiod_get_index gets
the information which gpio to use from a device tree that doesn't chang=
e
the return type, you still get a struct gpio_desc pointer. And it can
very well return a descriptor with GPIO_ACTIVE_LOW set, see the
implementation of of_find_gpio.
=20
> Keeping both gpiod and gpio depending on the enumeration method is un=
scallable
> so I didn't choose that.
And if the descriptor has GPIO_ACTIVE_LOW set, you should better not
ignore it. The best thing to do here AFAIUI is to first convert the
driver to gpiod and then add your ACPI support in an additional patch.

And then please (this was the main motivation for my reply) your the
4-parameter version of devm_gpiod_get_index.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
