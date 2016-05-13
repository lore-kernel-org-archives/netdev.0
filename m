From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Fri, 13 May 2016 12:07:39 +0300
Message-ID: <5735995B.8030802@ti.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <grant.likely@linaro.org>, <robh+dt@kernel.org>,
	<devicetree@vger.kernel.org>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <frowand.list@gmail.com>,
	<pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<linux-kernel@vger.kernel.org>,
	Linus Walleij <linus.walleij@linaro.org>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:56310 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089AbcEMJIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 05:08:13 -0400
In-Reply-To: <20160512184233.GJ30822@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On 12/05/16 21:42, Uwe Kleine-K=F6nig wrote:
> Hello Sergei,
>=20
> [we already talked about this patch in #armlinux, I'm now just
> forwarding my comments on the list. Background was that I sent an eas=
ier
> and less complete patch with the same idea. See
> http://patchwork.ozlabs.org/patch/621418/]
>=20
> [added Linus Walleij to Cc, there is a question for you/him below]
>=20
> On Fri, Apr 29, 2016 at 01:12:54AM +0300, Sergei Shtylyov wrote:
>> --- net-next.orig/Documentation/devicetree/bindings/net/phy.txt
>> +++ net-next/Documentation/devicetree/bindings/net/phy.txt
>> @@ -35,6 +35,8 @@ Optional Properties:
>>  - broken-turn-around: If set, indicates the PHY device does not cor=
rectly
>>    release the turn around line low at the end of a MDIO transaction=
=2E
>> =20
>> +- reset-gpios: The GPIO phandle and specifier for the PHY reset sig=
nal.
>> +
>>  Example:
>> =20
>>  ethernet-phy@0 {
>=20
> This is great.
>=20
>> Index: net-next/drivers/net/phy/at803x.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- net-next.orig/drivers/net/phy/at803x.c
>> +++ net-next/drivers/net/phy/at803x.c
>> @@ -65,7 +65,6 @@ MODULE_LICENSE("GPL");
>> [...]
>=20
> My patch breaks this driver. I wasn't aware of it.
>=20
>> [...]
>> Index: net-next/drivers/net/phy/mdio_device.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- net-next.orig/drivers/net/phy/mdio_device.c
>> +++ net-next/drivers/net/phy/mdio_device.c
>> [...]
>> @@ -103,6 +105,13 @@ void mdio_device_remove(struct mdio_devi
>>  }
>>  EXPORT_SYMBOL(mdio_device_remove);
>> =20
>> +void mdio_device_reset(struct mdio_device *mdiodev, int value)
>> +{
>> +	if (mdiodev->reset)
>> +		gpiod_set_value(mdiodev->reset, value);
>=20
> Before v4.6-rc1~108^2~91 it was not necessary to check for the first
> parameter being non-NULL before calling gpiod_set_value. Linus, did y=
ou
> change this on purpose?
>=20
>> +}
>> +EXPORT_SYMBOL(mdio_device_reset);
>> +
>>  /**
>>   * mdio_probe - probe an MDIO device
>>   * @dev: device to probe
>> @@ -117,9 +126,16 @@ static int mdio_probe(struct device *dev
>>  	struct mdio_driver *mdiodrv =3D to_mdio_driver(drv);
>>  	int err =3D 0;
>> =20
>> -	if (mdiodrv->probe)
>> +	if (mdiodrv->probe) {
>> +		/* Deassert the reset signal */
>> +		mdio_device_reset(mdiodev, 0);
>> +
>>  		err =3D mdiodrv->probe(mdiodev);
>> =20
>> +		/* Assert the reset signal */
>> +		mdio_device_reset(mdiodev, 1);
>=20
> I wonder if it's safe to do this in general. What if ->probe does
> something with the phy that is lost by resetting but that is relied o=
n
> later?

mdio_probe is called for non PHY devices only, right?

I'm a bit lost as to why we're de-asserting reset at multiple places. i=
=2Ee.
mdio_probe(), phy_device_register(), phy_init_hw(), phy_probe(), of_mdi=
obus_register_phy().

Isn't it simpler to just de-assert it once at the topmost level?
i.e. of_mdiobus_register_device() f and of_mdiobus_register_phy()?

Also, how about issuing a reset pulse instead of just de-asserting it.
This would tackle the case where PHY is in invalid state with reset alr=
eady
de-asserted.

Another issue is that on some boards we have one reset line tied to
multiple PHYs. How do we prevent multiple resets being taking place whe=
n each of
the PHYs are registered? Do we just specify the reset line only for one=
 PHY in
the DT or can we have the reset gpio in the mdio_bus node for such case=
?

cheers,
-roger

>=20
>> +	}
>> +
>>  	return err;
>>  }
>> [...]
>> Index: net-next/drivers/of/of_mdio.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- net-next.orig/drivers/of/of_mdio.c
>> +++ net-next/drivers/of/of_mdio.c
>> @@ -44,6 +44,7 @@ static int of_get_phy_id(struct device_n
>>  static void of_mdiobus_register_phy(struct mii_bus *mdio,
>>  				    struct device_node *child, u32 addr)
>>  {
>> +	struct gpio_desc *gpiod;
>>  	struct phy_device *phy;
>>  	bool is_c45;
>>  	int rc;
>> @@ -52,10 +53,17 @@ static void of_mdiobus_register_phy(stru
>>  	is_c45 =3D of_device_is_compatible(child,
>>  					 "ethernet-phy-ieee802.3-c45");
>> =20
>> +	gpiod =3D fwnode_get_named_gpiod(&child->fwnode, "reset-gpios");
>> +	/* Deassert the reset signal */
>> +	if (!IS_ERR(gpiod))
>> +		gpiod_direction_output(gpiod, 0);
>=20
> This is wrong I think. You must only ignore -ENODEV, all other error
> codes should be passed to the caller. (I see that's not trivial becau=
se
> of_mdiobus_register_phy returns void.)
>=20
> In my patch I used devm_gpiod_get_array which has the nice property t=
hat
> I can already pass GPIOD_OUT_LOW in flags. Also this binds the lifeti=
me
> of the gpio to the device which is nice and IMHO the right direction =
for
> the phylib (i.e. better embracing of the device model).
>=20
> This cannot be used here easily however because there is no struct
> device yet and this is only created after the phy id is determined. T=
he
> phy id is either read from the device tree or must be read from the p=
hy
> which might fail if reset is not deasserted.
>=20
> Principally there is no reason however that the phy_id must be known
> before the struct device is created however.
>=20
> Best regards
> Uwe
>=20
