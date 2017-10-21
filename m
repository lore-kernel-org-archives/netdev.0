From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 1/4] phylib: Add device reset GPIO support
Date: Sat, 21 Oct 2017 13:03:14 +0300
Message-ID: <44bc181e-6fd2-4868-3c8d-64e66d9c8d6b@cogentembedded.com>
References: <1508487261-18524-1-git-send-email-geert+renesas@glider.be>
 <1508487261-18524-2-git-send-email-geert+renesas@glider.be>
 <2dacbfaf-ce5e-f113-9ae8-641441d99bbc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Ferre <nicolas.ferre@microchip.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <2dacbfaf-ce5e-f113-9ae8-641441d99bbc@gmail.com>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 10/20/2017 9:11 PM, Florian Fainelli wrote:

>> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> The PHY devices sometimes do have their reset signal (maybe even power
>> supply?) tied to some GPIO and sometimes it also does happen that a boot
>> loader does not leave it deasserted. So far this issue has been attacked
>> from (as I believe) a wrong angle: by teaching the MAC driver to manipulate
>> the GPIO in question; that solution, when applied to the device trees, led
>> to adding the PHY reset GPIO properties to the MAC device node, with one
>> exception: Cadence MACB driver which could handle the "reset-gpios" prop
>> in a PHY device subnode. I believe that the correct approach is to teach
>> the 'phylib' to get the MDIO device reset GPIO from the device tree node
>> corresponding to this device -- which this patch is doing...
>>
>> Note that I had to modify the AT803x PHY driver as it would stop working
>> otherwise -- it made use of the reset GPIO for its own purposes...
>>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>> Acked-by: Rob Herring <robh@kernel.org>
>> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> This is a new patch as far as PHYLIB is concerned, so not quite accurate

    No, it is not new. No changes in logic since v2.

> anymore. Thanks for picking that up, this looks good, with a few minor
> things here and there.

>> [geert: Propagate actual errors from fwnode_get_named_gpiod()]
>> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
[...]
>> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
>> index 5f93e6add56394f2..15b4560aeb5de759 100644
>> --- a/drivers/net/phy/at803x.c
>> +++ b/drivers/net/phy/at803x.c
> 
> You most certainly want to make the conversion of the at803x.c driver as
> a separate patch, there is no reason why it should be folded within the

    No, it can't be a separate patch, otherwise I would have posted it 
separately. We cannot request the same GPIO 2 times.

> patch teaching PHYLIB about PHY reset through GPIOs. More on that below.
> 
[...]
>> @@ -254,22 +253,11 @@ static int at803x_probe(struct phy_device *phydev)
>>   {
>>   	struct device *dev = &phydev->mdio.dev;
>>   	struct at803x_priv *priv;
>> -	struct gpio_desc *gpiod_reset;
>>   
>>   	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
>>   	if (!priv)
>>   		return -ENOMEM;
>>   
>> -	if (phydev->drv->phy_id != ATH8030_PHY_ID)
>> -		goto does_not_require_reset_workaround;
> 
> We have lost that bit now, see below.

    Hm... I'm still seeing this in net-next.

>> -
>> -	gpiod_reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_LOW);
>> -	if (IS_ERR(gpiod_reset))
>> -		return PTR_ERR(gpiod_reset);
>> -
>> -	priv->gpiod_reset = gpiod_reset;
>> -
>> -does_not_require_reset_workaround:
>>   	phydev->priv = priv;
>>   
>>   	return 0;
>> @@ -343,14 +331,14 @@ static void at803x_link_change_notify(struct phy_device *phydev)
>>   	 * cannot recover from by software.
>>   	 */
>>   	if (phydev->state == PHY_NOLINK) {
>> -		if (priv->gpiod_reset && !priv->phy_reset) {
>> +		if (phydev->mdio.reset && !priv->phy_reset) {
> 
> and phydev->drv->phy_id == ATH8030_PHY_ID, the workaround is not
> applicable to all PHY devices.

    You are clearly looking at an outdated tree -- this check was removed,
This method is populated only for 8030 instead.

[...]
>> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
>> index 98258583abb0b405..3d044119c032d176 100644
>> --- a/drivers/of/of_mdio.c
>> +++ b/drivers/of/of_mdio.c
[...]
>> @@ -55,10 +56,22 @@ static int of_mdiobus_register_phy(struct mii_bus *mdio,
>>   	is_c45 = of_device_is_compatible(child,
>>   					 "ethernet-phy-ieee802.3-c45");
>>   
>> +	/* Deassert the optional reset signal */
>> +	gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios", 0,
>> +				       GPIOD_OUT_LOW, "PHY reset");
>> +	if (PTR_ERR(gpiod) == -ENOENT)
>> +		gpiod = NULL;
>> +	else if (IS_ERR(gpiod))
>> +		return PTR_ERR(gpiod);
>> +
>>   	if (!is_c45 && !of_get_phy_id(child, &phy_id))
>>   		phy = phy_device_create(mdio, addr, phy_id, 0, NULL);
>>   	else
>>   		phy = get_phy_device(mdio, addr, is_c45);
>> +
>> +	/* Assert the reset signal again */
>> +	gpiod_set_value(gpiod, 1);
> 
> You have a phy_device reference now, so why not call phy_device_reset()
> directly here?

    Symmetry, perhaps? (There was a gpiod_set_value(gpiod, 0) call above it...

[...]
>> @@ -112,6 +127,14 @@ static int of_mdiobus_register_device(struct mii_bus *mdio,
>>   	of_node_get(child);
>>   	mdiodev->dev.of_node = child;
>>   
>> +	gpiod = fwnode_get_named_gpiod(&child->fwnode, "reset-gpios", 0,
>> +				       GPIOD_ASIS, "PHY reset");
>> +	if (PTR_ERR(gpiod) == -ENOENT)
>> +		gpiod = NULL;
>> +	else if (IS_ERR(gpiod))
>> +		return PTR_ERR(gpiod);
>> +	mdiodev->reset = gpiod;
> 
> There is some obvious and non desireable duplication of code between
> "pure" mdio_device and phy_device paths here, can you factor this such
> that there is a common function storing gpiod into a mdio_device's reset
> member in both cases?
> 
> Also, there is some asymetry being exposed here, the GPIO descriptor is
> acquired from OF specific code, but is released in the generic MDIO
> device layer, can we find a way to make that symmetrical?

    Finally move of_mdio.c into drivers/net/phy/? ;-)

MBR, Sergei
