From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Sat, 14 May 2016 00:49:04 +0300
Message-ID: <f27f4c4c-f4b0-dfb3-ec20-c8584c637288@cogentembedded.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de>
 <f1fae99f-2464-8a42-deb8-c27cccf8df12@cogentembedded.com>
 <20160513070620.GB28415@pengutronix.de>
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
In-Reply-To: <20160513070620.GB28415@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/13/2016 10:06 AM, Uwe Kleine-K=F6nig wrote:

[...]
>>>> Index: net-next/drivers/of/of_mdio.c
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>> --- net-next.orig/drivers/of/of_mdio.c
>>>> +++ net-next/drivers/of/of_mdio.c
>>>> @@ -44,6 +44,7 @@ static int of_get_phy_id(struct device_n
>>>> static void of_mdiobus_register_phy(struct mii_bus *mdio,
>>>> 				    struct device_node *child, u32 addr)
>>>> {
>>>> +	struct gpio_desc *gpiod;
>>>> 	struct phy_device *phy;
>>>> 	bool is_c45;
>>>> 	int rc;
>>>> @@ -52,10 +53,17 @@ static void of_mdiobus_register_phy(stru
>>>> 	is_c45 =3D of_device_is_compatible(child,
>>>> 					 "ethernet-phy-ieee802.3-c45");
>>>>
>>>> +	gpiod =3D fwnode_get_named_gpiod(&child->fwnode, "reset-gpios");
>>>> +	/* Deassert the reset signal */
>>>> +	if (!IS_ERR(gpiod))
>>>> +		gpiod_direction_output(gpiod, 0);
>>>
>>> This is wrong I think. You must only ignore -ENODEV, all other erro=
r
>>
>>    At least -ENOSYS should also be ignored (it's returned when gpiol=
ib is
>> not configured), right?
>
> No, that's a common misconception. If GPIOLIB is off you cannot
> determine if dt specified a reset gpio. So you have the choice betwee=
n:
>
>  a) ignore -ENOSYS and so don't handle the reset line in the cases wh=
ere
>     it's necessary probably yielding an "Error: phy not found" messag=
e.
>  b) fail to probe even if a reset handling isn't necessary, yielding
>     "Error: failed to get hold of reset gpio".
>
> I say b) is the better one. It's easier to debug because the error
> message is better, GPIOLIB is enabled in most cases anyhow (still may=
be
> select it?) and it's ensured that we're operating in the limits of th=
e
> hardware specs (maybe a phy returns a random value when a register is
> read while reset is applied?).

    It returns all ones in my case.

>> When does -ENODEV gets returned (it's not easy to follow)?
>
> I don't know for sure for fwnode_get_named_gpiod, but the gpiod_get*(=
)
> family returns -ENODEV if the node doesn't have a reset-gpio property=
=2E

    Are you sure it's not -ENOENT?

>>> codes should be passed to the caller.
>>
>>    The caller doesn't care anyway...
>>
>>> (I see that's not trivial because
>>> of_mdiobus_register_phy returns void.)
>>
>>    I've made this function *void* in net-next.
>
> I'd say this is a step in the wrong direction. For example this makes=
 it
> impossible to handle the case where the phy should be probed, the gpi=
o
> driver isn't available yet, though. Normally you'd want to return
> -EPROBE_DEFER in this case and retry probing later.

    Well, of_mdiobus_register() is not an easy function to add the chec=
ks=20
whiuch were never there (and undo the done stuff on failure). I'll see =
what I=20
can do but no promises...

>>> In my patch I used devm_gpiod_get_array which has the nice property=
 that
>>> I can already pass GPIOD_OUT_LOW in flags. Also this binds the life=
time
>>> of the gpio to the device which is nice and IMHO the right directio=
n for
>>> the phylib (i.e. better embracing of the device model).
>>>
>>> This cannot be used here easily however because there is no struct
>>> device yet and this is only created after the phy id is determined.
>>
>>    Your last patch [1] didn't make use of the managed device API (de=
vm)
>> either, I didn't quite get to the bottom of that...
>
> Right, devm didn't work. My patch was a prototype for a way that allo=
wed
> to bind the lifetime of the gpio to the device. This might be longer
> than the call to mdiobus_unregister.

    Ah, that was the reason... Well, then you hardly achieved anything =
with=20
rehashing the code...

> See the problems that i2c handles
> because it doesn't handle lifetimes correctly in drivers/i2c/i2c-core=
=2Ec
> at the end of i2c_del_adapter.
>
>>> The phy id is either read from the device tree or must be read from
>>> the phy which might fail if reset is not deasserted.
>>
>>> Principally there is no reason however that the phy_id must be know=
n
>>> before the struct device is created however.
>>
>>    It's just that the code is cleaner that way...
>
> I don't agree, I don't see that
>
> 	determine_phyid()
> 	allocate_device()
>
> is better than
>
> 	allocate_device()
> 	determine_phyid()

    This is an oversimplified view. Actually, it is:

	error =3D determine_phyid()
	if (error)
		return
	allocate_device()

versus

	allocate_device()
	error =3D determine_phyid()
	if (error)
		free_device()

> . The former is maybe easier because that's the status quo and it
> doesn't need patching. But IMHO the result is on a similar level of
> cleanliness.

    I disagree. And I don't see why it's necessary at all. Just to use =
another=20
gpiolib API?

> Best regards
> Uwe

MBR, Sergei
