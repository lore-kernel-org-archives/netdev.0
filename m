From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] phy: add support for a reset-gpio specification
Date: Thu, 12 May 2016 18:14:11 +0200
Message-ID: <20160512161411.GI30822@pengutronix.de>
References: <1463047233-18091-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <57348A2A.8070806@ti.com>
 <57348D05.905@ti.com>
 <57349058.6040708@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nishanth Menon <nm@ti.com>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>, kernel@pengutronix.de,
	"Andrew F . Davis" <afd@ti.com>, Sekhar Nori <nsekhar@ti.com>,
	Suman Anna <s-anna@ti.com>
To: Roger Quadros <rogerq@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:47108 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932278AbcELQOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2016 12:14:15 -0400
Content-Disposition: inline
In-Reply-To: <57349058.6040708@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, May 12, 2016 at 05:16:56PM +0300, Roger Quadros wrote:
> On 12/05/16 17:02, Roger Quadros wrote:
> > On 12/05/16 16:50, Nishanth Menon wrote:
> >> On 05/12/2016 05:00 AM, Uwe Kleine-K=F6nig wrote:
> >>> The framework only asserts (for now) that the reset gpio is not a=
ctive.
> >>>
> >>> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de=
>
> >>> ---
> >>>  Documentation/devicetree/bindings/net/phy.txt | 3 +++
> >>>  drivers/net/phy/phy_device.c                  | 8 ++++++++
> >>>  2 files changed, 11 insertions(+)
> >>>
> >>> diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Docu=
mentation/devicetree/bindings/net/phy.txt
> >>> index bc1c3c8bf8fa..c00a9a894547 100644
> >>> --- a/Documentation/devicetree/bindings/net/phy.txt
> >>> +++ b/Documentation/devicetree/bindings/net/phy.txt
> >>> @@ -35,6 +35,8 @@ Optional Properties:
> >>>  - broken-turn-around: If set, indicates the PHY device does not =
correctly
> >>>    release the turn around line low at the end of a MDIO transact=
ion.
> >>> =20
> >>> +- reset-gpios: Reference to a GPIO used to reset the phy.
> >>> +
> >>>  Example:
> >>> =20
> >>>  ethernet-phy@0 {
> >>> @@ -42,4 +44,5 @@ ethernet-phy@0 {
> >>>  	interrupt-parent =3D <40000>;
> >>>  	interrupts =3D <35 1>;
> >>>  	reg =3D <0>;
> >>> +	reset-gpios =3D <&gpio1 17 GPIO_ACTIVE_LOW>;
> >>>  };
> >>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_d=
evice.c
> >>> index e551f3a89cfd..7d666ab47271 100644
> >>> --- a/drivers/net/phy/phy_device.c
> >>> +++ b/drivers/net/phy/phy_device.c
> >>> @@ -34,6 +34,7 @@
> >>>  #include <linux/io.h>
> >>>  #include <linux/uaccess.h>
> >>>  #include <linux/of.h>
> >>> +#include <linux/gpio/consumer.h>
> >>> =20
> >>>  #include <asm/irq.h>
> >>> =20
> >>> @@ -1569,9 +1570,16 @@ static int phy_probe(struct device *dev)
> >>>  	struct device_driver *drv =3D phydev->mdio.dev.driver;
> >>>  	struct phy_driver *phydrv =3D to_phy_driver(drv);
> >>>  	int err =3D 0;
> >>> +	struct gpio_descs *reset_gpios;
> >>> =20
> >>>  	phydev->drv =3D phydrv;
> >>> =20
> >>> +	/* take phy out of reset */
> >>> +	reset_gpios =3D devm_gpiod_get_array_optional(dev, "reset",
> >>> +						    GPIOD_OUT_LOW);
> >>> +	if (IS_ERR(reset_gpios))
> >>> +		return PTR_ERR(reset_gpios);
> >>> +
> >>>  	/* Disable the interrupt if the PHY doesn't support it
> >>>  	 * but the interrupt is still a valid one
> >>>  	 */
> >>>
> >>
> >> This looks like the right approach to me at least: I see that TI E=
VMs
> >> will also benefit with this approach.
> >>
> >=20
> > Agreed. Although on some of our boards we actually need a RESET pul=
se
> > to get the PHY in a sane state. I can send a patch on top for that.
> >=20
>=20
> I think I replied too early. Will phy_probe() be called at all if the
> PHY is not detected on the MDIO bus?
> If not then this approach is not sufficient for some of the TI boards=
=2E
> e.g. am57xx-idk.
> I think the reset needs to be done at MDIO bus level before it enumer=
ates
> the PHYs so that we know the PHY is in an enumerable state.
I have this in the device tree:

&davinci_mdio {
        pinctrl-names =3D "default", "sleep";
        pinctrl-0 =3D <&davinci_mdio_default>;
        pinctrl-1 =3D <&davinci_mdio_sleep>;
        status =3D "okay";

        phy0: ethernet-phy@0 {
                compatible =3D "ethernet-phy-id2000.a212", "ethernet-ph=
y-ieee802.3-c22";
                reg =3D <0>;

                interrupt-parent =3D <&gpio2>;
                interrupts =3D <2 8>;

                pinctrl-names =3D "default";
                pinctrl-0 =3D <&phy0_pins>;

                reset-gpios =3D <&gpio2 9 GPIO_ACTIVE_LOW>;
        };

        phy1: ethernet-phy@2 {
                compatible =3D "ethernet-phy-id2000.a212", "ethernet-ph=
y-ieee802.3-c22";
                reg =3D <2>;

                interrupt-parent =3D <&gpio0>;
                interrupts =3D <2 8>;

                pinctrl-names =3D "default";
                pinctrl-0 =3D <&phy1_pins>;

                reset-gpios =3D <&gpio2 11 GPIO_ACTIVE_LOW>;
        };
};

With the phy id values specified in the compatible the mdio bus is only
accessed when the reset pin was handled.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
