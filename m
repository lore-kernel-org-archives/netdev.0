From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Fri, 13 May 2016 09:06:20 +0200
Message-ID: <20160513070620.GB28415@pengutronix.de>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de>
 <f1fae99f-2464-8a42-deb8-c27cccf8df12@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, linux-kernel@vger.kernel.org,
	Linus Walleij <linus.walleij@linaro.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f1fae99f-2464-8a42-deb8-c27cccf8df12@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Sergei,

On Fri, May 13, 2016 at 12:35:50AM +0300, Sergei Shtylyov wrote:
> On 05/12/2016 09:42 PM, Uwe Kleine-K=F6nig wrote:
> >>Index: net-next/drivers/net/phy/mdio_device.c
> >>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >>--- net-next.orig/drivers/net/phy/mdio_device.c
> >>+++ net-next/drivers/net/phy/mdio_device.c
> [...]
> >>@@ -117,9 +126,16 @@ static int mdio_probe(struct device *dev
> >> 	struct mdio_driver *mdiodrv =3D to_mdio_driver(drv);
> >> 	int err =3D 0;
> >>
> >>-	if (mdiodrv->probe)
> >>+	if (mdiodrv->probe) {
> >>+		/* Deassert the reset signal */
> >>+		mdio_device_reset(mdiodev, 0);
> >>+
> >> 		err =3D mdiodrv->probe(mdiodev);
> >>
> >>+		/* Assert the reset signal */
> >>+		mdio_device_reset(mdiodev, 1);
> >
> >I wonder if it's safe to do this in general. What if ->probe does
> >something with the phy that is lost by resetting but that is relied =
on
> >later?
>=20
>    Well, I thought that config_init() method is designed for that but=
 indeed
> the LXT driver writes to BMCR in its probe() method and hence is brok=
en.
> Thank you for noticing...
>=20
> [...]
> >>Index: net-next/drivers/of/of_mdio.c
> >>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >>--- net-next.orig/drivers/of/of_mdio.c
> >>+++ net-next/drivers/of/of_mdio.c
> >>@@ -44,6 +44,7 @@ static int of_get_phy_id(struct device_n
> >> static void of_mdiobus_register_phy(struct mii_bus *mdio,
> >> 				    struct device_node *child, u32 addr)
> >> {
> >>+	struct gpio_desc *gpiod;
> >> 	struct phy_device *phy;
> >> 	bool is_c45;
> >> 	int rc;
> >>@@ -52,10 +53,17 @@ static void of_mdiobus_register_phy(stru
> >> 	is_c45 =3D of_device_is_compatible(child,
> >> 					 "ethernet-phy-ieee802.3-c45");
> >>
> >>+	gpiod =3D fwnode_get_named_gpiod(&child->fwnode, "reset-gpios");
> >>+	/* Deassert the reset signal */
> >>+	if (!IS_ERR(gpiod))
> >>+		gpiod_direction_output(gpiod, 0);
> >
> >This is wrong I think. You must only ignore -ENODEV, all other error
>=20
>    At least -ENOSYS should also be ignored (it's returned when gpioli=
b is
> not configured), right?

No, that's a common misconception. If GPIOLIB is off you cannot
determine if dt specified a reset gpio. So you have the choice between:

 a) ignore -ENOSYS and so don't handle the reset line in the cases wher=
e
    it's necessary probably yielding an "Error: phy not found" message.
 b) fail to probe even if a reset handling isn't necessary, yielding
    "Error: failed to get hold of reset gpio".

I say b) is the better one. It's easier to debug because the error
message is better, GPIOLIB is enabled in most cases anyhow (still maybe
select it?) and it's ensured that we're operating in the limits of the
hardware specs (maybe a phy returns a random value when a register is
read while reset is applied?).

> When does -ENODEV gets returned (it's not easy to follow)?

I don't know for sure for fwnode_get_named_gpiod, but the gpiod_get*()
family returns -ENODEV if the node doesn't have a reset-gpio property.

> >codes should be passed to the caller.
>=20
>    The caller doesn't care anyway...
>=20
> >(I see that's not trivial because
> >of_mdiobus_register_phy returns void.)
>=20
>    I've made this function *void* in net-next.

I'd say this is a step in the wrong direction. For example this makes i=
t
impossible to handle the case where the phy should be probed, the gpio
driver isn't available yet, though. Normally you'd want to return
-EPROBE_DEFER in this case and retry probing later.

> >In my patch I used devm_gpiod_get_array which has the nice property =
that
> >I can already pass GPIOD_OUT_LOW in flags. Also this binds the lifet=
ime
> >of the gpio to the device which is nice and IMHO the right direction=
 for
> >the phylib (i.e. better embracing of the device model).
> >
> >This cannot be used here easily however because there is no struct
> >device yet and this is only created after the phy id is determined.
>=20
>    Your last patch [1] didn't make use of the managed device API (dev=
m)
> either, I didn't quite get to the bottom of that...

Right, devm didn't work. My patch was a prototype for a way that allowe=
d
to bind the lifetime of the gpio to the device. This might be longer
than the call to mdiobus_unregister. See the problems that i2c handles
because it doesn't handle lifetimes correctly in drivers/i2c/i2c-core.c
at the end of i2c_del_adapter.

> >The phy id is either read from the device tree or must be read from
> >the phy which might fail if reset is not deasserted.
>=20
> >Principally there is no reason however that the phy_id must be known
> >before the struct device is created however.
>=20
>    It's just that the code is cleaner that way...

I don't agree, I don't see that

	determine_phyid()
	allocate_device()

is better than

	allocate_device()
	determine_phyid()

=2E The former is maybe easier because that's the status quo and it
doesn't need patching. But IMHO the result is on a similar level of
cleanliness.

Best regards
Uwe

> [1] http://paste.debian.net/683630/

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
