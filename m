From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 1/4] phylib: Add device reset GPIO support
Date: Fri, 20 Oct 2017 13:56:04 +0300
Message-ID: <e7154cd6-1c6b-5a77-cc5f-2b46047e656b@cogentembedded.com>
References: <1508487261-18524-1-git-send-email-geert+renesas@glider.be>
 <1508487261-18524-2-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Nicolas Ferre <nicolas.ferre@microchip.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508487261-18524-2-git-send-email-geert+renesas@glider.be>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 10/20/2017 11:14 AM, Geert Uytterhoeven wrote:

> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> The PHY devices sometimes do have their reset signal (maybe even power
> supply?) tied to some GPIO and sometimes it also does happen that a boot
> loader does not leave it deasserted. So far this issue has been attacked
> from (as I believe) a wrong angle: by teaching the MAC driver to manipulate
> the GPIO in question; that solution, when applied to the device trees, led
> to adding the PHY reset GPIO properties to the MAC device node, with one
> exception: Cadence MACB driver which could handle the "reset-gpios" prop
> in a PHY device subnode. I believe that the correct approach is to teach
> the 'phylib' to get the MDIO device reset GPIO from the device tree node
> corresponding to this device -- which this patch is doing...
> 
> Note that I had to modify the AT803x PHY driver as it would stop working
> otherwise -- it made use of the reset GPIO for its own purposes...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Acked-by: Rob Herring <robh@kernel.org>
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>
> [geert: Propagate actual errors from fwnode_get_named_gpiod()]
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
[...]
> diff --git a/drivers/net/phy/mdio_device.c b/drivers/net/phy/mdio_device.c
> index e24f28924af8953d..6926db11ae888174 100644
> --- a/drivers/net/phy/mdio_device.c
> +++ b/drivers/net/phy/mdio_device.c
[...]
> @@ -128,9 +136,16 @@ static int mdio_probe(struct device *dev)
>   	struct mdio_driver *mdiodrv = to_mdio_driver(drv);
>   	int err = 0;
>   
> -	if (mdiodrv->probe)
> +	if (mdiodrv->probe) {
> +		/* Deassert the reset signal */
> +		mdio_device_reset(mdiodev, 0);
> +
>   		err = mdiodrv->probe(mdiodev);

    If the probe() method performs some register setup...

> +		/* Assert the reset signal */
> +		mdio_device_reset(mdiodev, 1);

    ... this reset would kill that setup. Hence we shouldn't drive the reset 
signal at least when the probe() method succeeds.

> +	}
> +
>   	return err;
>   }
>   
[...]
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 67f25ac29025c539..e694b0ecf780d096 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
[...]
> @@ -1811,9 +1826,16 @@ static int phy_probe(struct device *dev)
>   	/* Set the state to READY by default */
>   	phydev->state = PHY_READY;
>   
> -	if (phydev->drv->probe)
> +	if (phydev->drv->probe) {
> +		/* Deassert the reset signal */
> +		phy_device_reset(phydev, 0);
> +
>   		err = phydev->drv->probe(phydev);

    If the probe() method performs some register setup (as does the LXT PHY 
driver!)...

> +		/* Assert the reset signal */
> +		phy_device_reset(phydev, 1);

    ... this reset would kill that setup. Hence we shouldn't drive the reset 
signal at least when the probe() method succeeds.

> +	}
> +
>   	mutex_unlock(&phydev->lock);
>   
>   	return err;
[...]

MBR, Sergei
