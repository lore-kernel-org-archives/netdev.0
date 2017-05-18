From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] of_mdio: Fix broken PHY IRQ in case of probe deferral
Date: Thu, 18 May 2017 18:09:43 +0200
Message-ID: <20170518160943.GC707@lunn.ch>
References: <1495112345-24795-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1495112345-24795-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 18, 2017 at 02:59:05PM +0200, Geert Uytterhoeven wrote:
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

Maybe this should be consistent. All other places there is an error,
you return it. Here however, you only return the error if it is
EPROBE_DEFER.

	Andrew


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
