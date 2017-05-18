From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Thu, 18 May 2017 11:25:46 -0700
Message-ID: <f0ed61c3-062b-cec6-fe19-7412231e8ef1@gmail.com>
References: <1495112345-24795-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        Andrew Lunn <andrew@lunn.ch>, Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1495112345-24795-1-git-send-email-geert+renesas@glider.be>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/18/2017 05:59 AM, Geert Uytterhoeven wrote:
> If an Ethernet PHY is initialized before the interrupt controller it is
> connected to, a message like the following is printed:
> 
>     irq: no irq domain found for /interrupt-controller@e61c0000 !
> 
> However, the actual error is ignored, leading to a non-functional (-1)
> PHY interrupt later:
> 
>     Micrel KSZ8041RNLI ee700000.ethernet-ffffffff:01: attached PHY driver [Micrel KSZ8041RNLI] (mii_bus:phy_addr=ee700000.ethernet-ffffffff:01, irq=-1)
> 
> Depending on whether the PHY driver will fall back to polling, Ethernet
> may or may not work.
> 
> To fix this:
>   1. Switch of_mdiobus_register_phy() from irq_of_parse_and_map() to
>      of_irq_get().
>      Unlike the former, the latter returns -EPROBE_DEFER if the
>      interrupt controller is not yet available, so this condition can be
>      detected.
>      Other errors are handled the same as before, i.e. use the passed
>      mdio->irq[addr] as interrupt.
>   2. Propagate and handle errors from of_mdiobus_register_phy() and
>      of_mdiobus_register_device().

This most certainly works fine in the simple case where you have one PHY
hanging off the MDIO bus, now what happens if you have several?

Presumably, the first PHY that returns EPROBE_DEFER will make the entire
bus registration return EPROB_DEFER as well, and so on, and so forth,
but I am not sure if we will be properly unwinding the successful
registration of PHYs that either don't have an interrupt, or did not
return EPROBE_DEFER.

It should be possible to mimic this behavior by using the fixed PHY, and
possibly the dsa_loop.c driver which would create 4 ports, expecting 4
fixed PHYs to be present.

> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> ---
> Seen on r8a7791/koelsch when using the new CPG/MSSR clock driver.
> I assume it always happened on RZ/G1 in mainline.
> ---
>  drivers/of/of_mdio.c | 39 +++++++++++++++++++++++++++------------
>  1 file changed, 27 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 7e4c80f9b6cda0d3..f9ac2893f56184be 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -44,7 +44,7 @@ static int of_get_phy_id(struct device_node *device, u32 *phy_id)
>  	return -EINVAL;
>  }
>  
> -static void of_mdiobus_register_phy(struct mii_bus *mdio,
> +static int of_mdiobus_register_phy(struct mii_bus *mdio,
>  				    struct device_node *child, u32 addr)
>  {
>  	struct phy_device *phy;
> @@ -60,9 +60,13 @@ static void of_mdiobus_register_phy(struct mii_bus *mdio,
>  	else
>  		phy = get_phy_device(mdio, addr, is_c45);
>  	if (IS_ERR(phy))
> -		return;
> +		return PTR_ERR(phy);
>  
> -	rc = irq_of_parse_and_map(child, 0);
> +	rc = of_irq_get(child, 0);
> +	if (rc == -EPROBE_DEFER) {
> +		phy_device_free(phy);
> +		return rc;
> +	}
>  	if (rc > 0) {
>  		phy->irq = rc;
>  		mdio->irq[addr] = rc;
> @@ -84,22 +88,23 @@ static void of_mdiobus_register_phy(struct mii_bus *mdio,
>  	if (rc) {
>  		phy_device_free(phy);
>  		of_node_put(child);
> -		return;
> +		return rc;
>  	}
>  
>  	dev_dbg(&mdio->dev, "registered phy %s at address %i\n",
>  		child->name, addr);
> +	return 0;
>  }
>  
> -static void of_mdiobus_register_device(struct mii_bus *mdio,
> -				       struct device_node *child, u32 addr)
> +static int of_mdiobus_register_device(struct mii_bus *mdio,
> +				      struct device_node *child, u32 addr)
>  {
>  	struct mdio_device *mdiodev;
>  	int rc;
>  
>  	mdiodev = mdio_device_create(mdio, addr);
>  	if (IS_ERR(mdiodev))
> -		return;
> +		return PTR_ERR(mdiodev);
>  
>  	/* Associate the OF node with the device structure so it
>  	 * can be looked up later.
> @@ -112,11 +117,12 @@ static void of_mdiobus_register_device(struct mii_bus *mdio,
>  	if (rc) {
>  		mdio_device_free(mdiodev);
>  		of_node_put(child);
> -		return;
> +		return rc;
>  	}
>  
>  	dev_dbg(&mdio->dev, "registered mdio device %s at address %i\n",
>  		child->name, addr);
> +	return 0;
>  }
>  
>  int of_mdio_parse_addr(struct device *dev, const struct device_node *np)
> @@ -242,9 +248,11 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  		}
>  
>  		if (of_mdiobus_child_is_phy(child))
> -			of_mdiobus_register_phy(mdio, child, addr);
> +			rc = of_mdiobus_register_phy(mdio, child, addr);
>  		else
> -			of_mdiobus_register_device(mdio, child, addr);
> +			rc = of_mdiobus_register_device(mdio, child, addr);
> +		if (rc)
> +			goto unregister;
>  	}
>  
>  	if (!scanphys)
> @@ -265,12 +273,19 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  			dev_info(&mdio->dev, "scan phy %s at address %i\n",
>  				 child->name, addr);
>  
> -			if (of_mdiobus_child_is_phy(child))
> -				of_mdiobus_register_phy(mdio, child, addr);
> +			if (of_mdiobus_child_is_phy(child)) {
> +				rc = of_mdiobus_register_phy(mdio, child, addr);
> +				if (rc)
> +					goto unregister;
> +			}
>  		}
>  	}
>  
>  	return 0;
> +
> +unregister:
> +	mdiobus_unregister(mdio);
> +	return rc;
>  }
>  EXPORT_SYMBOL(of_mdiobus_register);
>  
> 


-- 
Florian
