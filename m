From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC net-next] of: mdio: Honor hints from MDIO bus drivers
Date: Tue, 11 Apr 2017 15:18:36 -0700
Message-ID: <8ef102a4-22e5-def8-b50e-04f84b5849d7@gmail.com>
References: <20170410214258.9409-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, Andrew Lunn <andrew@lunn.ch>,
        Rob Herring <robh+dt@kernel.org>,
        Frank Rowand <frowand.list@gmail.com>,
        "open list:OPEN FIRMWARE AND FLATTENED DEVICE TREE"
        <devicetree@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170410214258.9409-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/10/2017 02:42 PM, Florian Fainelli wrote:
> A MDIO bus driver can set phy_mask to indicate which PHYs should be
> probed and which should not. Right now, of_mdiobus_register() always
> sets mdio->phy_mask to ~0 which means: don't probe anything yourself,
> and let the Device Tree scanning do it based on the availability of
> child nodes.
> 
> When MDIO buses are stacked together (on purpose, as is done by DSA), we
> run into possible double probing which is, at best unnecessary, and at
> worse, can cause problems if that's not expected (e.g: during probe
> deferral).
> 
> Fix this by remember the original mdio->phy_mask, and make sure that if
> it was set to all 0xF, we set it to zero internally in order not to
> influence how the child PHY/MDIO device registration is going to behave.
> When the original mdio->phy_mask is set to something non-zero, we honor
> this value and utilize it as a hint to register only the child nodes
> that we have both found, and indicated to be necessary.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Sending this as RFC because a quick look at the current tree makes
> me think we are fine, but I would appreciate some review/feedback
> before this gets merged.

To give some more background and rational for this change.

On a platform where we have a parent MDIO bus, backed by the
mdio-bcm-unimac.c driver, we also register a slave MII bus (through
net/dsa/dsa2.c) which is parented to this UniMAC MDIO bus through an
assignment of of_node. This slave MII bus is created in order to
intercept reads/writes to problematic addresses (e.g: that clashes with
another piece of hardware).

This means that the slave DSA MII bus inherits all child nodes from the
originating master MII bus. This also means that when the slave MII bus
is probed via of_mdiobus_register(), we probe the same devices twice:
once through the master, another time through the slave.

With this change, we avoid double probing, because when creating the
slave MDIO bus, we carefully set phy_mask to intentionally restrict the
child PHY/MDIO device's creation to the relevant devices.

> 
> Thank you!
> 
>  drivers/of/of_mdio.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 0b2979816dbf..6bfbf00623cb 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -209,6 +209,7 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  {
>  	struct device_node *child;
>  	bool scanphys = false;
> +	u32 orig_phy_mask;
>  	int addr, rc;
>  
>  	/* Do not continue if the node is disabled */
> @@ -217,8 +218,15 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  
>  	/* Mask out all PHYs from auto probing.  Instead the PHYs listed in
>  	 * the device tree are populated after the bus has been registered */
> +	orig_phy_mask = mdio->phy_mask;
>  	mdio->phy_mask = ~0;
>  
> +	/* If the original phy_mask was all 0xf, we make it zero here in order
> +	 * to get child Device Tree nodes to be probed successfully
> +	 */
> +	if (orig_phy_mask == mdio->phy_mask)
> +		orig_phy_mask = 0;
> +
>  	mdio->dev.of_node = np;
>  
>  	/* Register the MDIO bus */
> @@ -234,6 +242,10 @@ int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  			continue;
>  		}
>  
> +		/* Honor hints from the mdio bus */
> +		if (orig_phy_mask & BIT(addr))
> +			continue;
> +
>  		if (of_mdiobus_child_is_phy(child))
>  			of_mdiobus_register_phy(mdio, child, addr);
>  		else
> 


-- 
Florian
