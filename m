From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v2 2/2] NFC: Add ACPI support for NXP PN544
Date: Thu, 12 Feb 2015 09:14:59 +0100
Message-ID: <20150212081459.GA28954@pengutronix.de>
References: <1422270817-10950-1-git-send-email-robert.dolca@intel.com>
 <1422270817-10950-3-git-send-email-robert.dolca@intel.com>
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
In-Reply-To: <1422270817-10950-3-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, Jan 26, 2015 at 01:13:37PM +0200, Robert Dolca wrote:
> +	/* Get EN GPIO from ACPI */
> +	gpiod_en =3D devm_gpiod_get_index(dev, PN544_GPIO_NAME_EN, 1);
Actually devm_gpiod_get_index takes 4 arguments. In your case you shoul=
d
also pass GPIOD_OUT_LOW, then you can skip the gpiod_direction_output
part below.

> +	if (IS_ERR(gpiod_en)) {
> +		nfc_err(dev,
> +			"Unable to get EN GPIO\n");
> +		return -ENODEV;
> +	}
> +
> +	phy->gpio_en  =3D desc_to_gpio(gpiod_en);
Why don't you save a reference to the gpiod instead? Mixing usage of ra=
w
and gpiod might result in surprising results. For example

	gpiod_direction_output(gpiod_en, 0);

might actually have the same result as

	gpio_direction_output(gpio_en, 1);

if the matching gpio is marked as active low.

> +
> +	/* Configuration EN GPIO */
> +	ret =3D gpiod_direction_output(gpiod_en, 0);
> +	if (ret) {
> +		nfc_err(dev, "Fail EN pin direction\n");
> +		return ret;
> +	}
> +
> +	/* Get FW GPIO from ACPI */
> +	gpiod_fw =3D devm_gpiod_get_index(dev, PN544_GPIO_NAME_FW, 2);
> +	if (IS_ERR(gpiod_fw)) {
> +		nfc_err(dev,
> +			"Unable to get FW GPIO\n");
> +		return -ENODEV;
> +	}
> +
> +	phy->gpio_fw  =3D desc_to_gpio(gpiod_fw);
> +
> +	/* Configuration FW GPIO */
> +	ret =3D gpiod_direction_output(gpiod_fw, 0);
> +	if (ret) {
> +		nfc_err(dev, "Fail FW pin direction\n");
> +		return ret;
> +	}
The same comments apply here.

> +
> +	/* Get IRQ GPIO */
> +	gpiod_irq =3D devm_gpiod_get_index(dev, PN544_GPIO_NAME_IRQ, 0);
> +	if (IS_ERR(gpiod_irq)) {
> +		nfc_err(dev,
> +			"Unable to get IRQ GPIO\n");
> +		return -ENODEV;
> +	}
> +
> +	phy->gpio_irq =3D desc_to_gpio(gpiod_irq);
> +
> +	/* Configure IRQ GPIO */
> +	ret =3D gpiod_direction_input(gpiod_irq);
> +	if (ret) {
> +		nfc_err(dev, "Fail IRQ pin direction\n");
> +		return ret;
> +	}
> +
> +	/* Map the pin to an IRQ */
> +	ret =3D gpiod_to_irq(gpiod_irq);
> +	if (ret < 0) {
> +		nfc_err(dev, "Fail pin IRQ mapping\n");
> +		return ret;
> +	}
and here.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
