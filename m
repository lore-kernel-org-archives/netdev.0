From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Fri, 13 May 2016 00:35:50 +0300
Message-ID: <f1fae99f-2464-8a42-deb8-c27cccf8df12@cogentembedded.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, linux-kernel@vger.kernel.org,
	Linus Walleij <linus.walleij@linaro.org>
To: =?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160512184233.GJ30822@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/12/2016 09:42 PM, Uwe Kleine-K=F6nig wrote:

> [we already talked about this patch in #armlinux, I'm now just
> forwarding my comments on the list. Background was that I sent an eas=
ier
> and less complete patch with the same idea. See
> http://patchwork.ozlabs.org/patch/621418/]
>
> [added Linus Walleij to Cc, there is a question for you/him below]
>
> On Fri, Apr 29, 2016 at 01:12:54AM +0300, Sergei Shtylyov wrote:
>> --- net-next.orig/Documentation/devicetree/bindings/net/phy.txt
>> +++ net-next/Documentation/devicetree/bindings/net/phy.txt
>> @@ -35,6 +35,8 @@ Optional Properties:
>>  - broken-turn-around: If set, indicates the PHY device does not cor=
rectly
>>    release the turn around line low at the end of a MDIO transaction=
=2E
>>
>> +- reset-gpios: The GPIO phandle and specifier for the PHY reset sig=
nal.
>> +
>>  Example:
>>
>>  ethernet-phy@0 {
>
> This is great.
>
>> Index: net-next/drivers/net/phy/at803x.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- net-next.orig/drivers/net/phy/at803x.c
>> +++ net-next/drivers/net/phy/at803x.c
>> @@ -65,7 +65,6 @@ MODULE_LICENSE("GPL");
>> [...]
>
> My patch breaks this driver. I wasn't aware of it.

    I tried to be as careful as I could but still it looks that I didn'=
t=20
succeed at that too...

[...]
>> Index: net-next/drivers/net/phy/mdio_device.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- net-next.orig/drivers/net/phy/mdio_device.c
>> +++ net-next/drivers/net/phy/mdio_device.c
[...]
>> @@ -117,9 +126,16 @@ static int mdio_probe(struct device *dev
>>  	struct mdio_driver *mdiodrv =3D to_mdio_driver(drv);
>>  	int err =3D 0;
>>
>> -	if (mdiodrv->probe)
>> +	if (mdiodrv->probe) {
>> +		/* Deassert the reset signal */
>> +		mdio_device_reset(mdiodev, 0);
>> +
>>  		err =3D mdiodrv->probe(mdiodev);
>>
>> +		/* Assert the reset signal */
>> +		mdio_device_reset(mdiodev, 1);
>
> I wonder if it's safe to do this in general. What if ->probe does
> something with the phy that is lost by resetting but that is relied o=
n
> later?

    Well, I thought that config_init() method is designed for that but =
indeed=20
the LXT driver writes to BMCR in its probe() method and hence is broken=
=2E Thank=20
you for noticing...

[...]
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
>>
>> +	gpiod =3D fwnode_get_named_gpiod(&child->fwnode, "reset-gpios");
>> +	/* Deassert the reset signal */
>> +	if (!IS_ERR(gpiod))
>> +		gpiod_direction_output(gpiod, 0);
>
> This is wrong I think. You must only ignore -ENODEV, all other error

    At least -ENOSYS should also be ignored (it's returned when gpiolib=
 is not=20
configured), right? When does -ENODEV gets returned (it's not easy to f=
ollow)?

> codes should be passed to the caller.

    The caller doesn't care anyway...

> (I see that's not trivial because
> of_mdiobus_register_phy returns void.)

    I've made this function *void* in net-next.

> In my patch I used devm_gpiod_get_array which has the nice property t=
hat
> I can already pass GPIOD_OUT_LOW in flags. Also this binds the lifeti=
me
> of the gpio to the device which is nice and IMHO the right direction =
for
> the phylib (i.e. better embracing of the device model).
>
> This cannot be used here easily however because there is no struct
> device yet and this is only created after the phy id is determined.

    Your last patch [1] didn't make use of the managed device API (devm=
)=20
either, I didn't quite get to the bottom of that...

> The
> phy id is either read from the device tree or must be read from the p=
hy
> which might fail if reset is not deasserted.

> Principally there is no reason however that the phy_id must be known
> before the struct device is created however.

    It's just that the code is cleaner that way...

[1] http://paste.debian.net/683630/

> Best regards
> Uwe

MBR, Sergei
