From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: enable driver to work without
 a device tree
Date: Fri, 10 Oct 2014 11:59:44 -0700
Message-ID: <54382CA0.6040105@gmail.com>
References: <20141010183501.0189F1008A3@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:48304 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751962AbaJJS7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 14:59:54 -0400
Received: by mail-pd0-f175.google.com with SMTP id v10so2152447pde.34
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 11:59:53 -0700 (PDT)
In-Reply-To: <20141010183501.0189F1008A3@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/2014 11:35 AM, Petri Gynther wrote:
> Broadcom 7xxx MIPS-based STB platforms do not use device trees.
> Modify bcmgenet driver so that it can be used on those platforms.
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>
> ---

[snip]

> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> index dbf524e..5191e3f 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
> @@ -17,6 +17,17 @@
>  #include <linux/if_vlan.h>
>  #include <linux/phy.h>
>  
> +struct bcmgenet_platform_data {
> +	void __iomem	*base_reg;
> +	int		irq0;
> +	int		irq1;

Why would these members here? The platform device should provide those
as standard resources that the driver fetches using
platform_get_resource() and platform_get_irq().

> +	int		phy_type;
> +	int		phy_addr;
> +	int		phy_speed;
> +	u8		macaddr[ETH_ALEN];
> +	int		genet_version;
> +};

I would rather we put this in include/linux/platform_data/bcmgenet.h
where it belongs.

> +
>  /* total number of Buffer Descriptors, same for Rx/Tx */
>  #define TOTAL_DESC				256
>  
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> index 9ff799a..e5ff913 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> @@ -157,6 +157,21 @@ static void bcmgenet_mii_setup(struct net_device *dev)
>  	phy_print_status(phydev);
>  }
>  
> +static int bcmgenet_moca_fphy_update(struct net_device *dev,
> +				     struct fixed_phy_status *status)
> +{
> +	struct bcmgenet_priv *priv = netdev_priv(dev);
> +	struct phy_device *phydev = priv->phydev;
> +
> +	/*
> +	 * MoCA daemon updates phydev->autoneg to reflect the link status.
> +	 * Update MoCA fixed PHY status accordingly, so that the PHY state
> +	 * machine becomes aware of the real link status.
> +	 */
> +	status->link = phydev->autoneg;
> +	return 0;
> +}

I don't want to see that in the upstream driver, please enable the link
interrupts like I suggested before and do not use the autoneg field at
all, which should require no MoCA daemon modifications.

[snip]

>  
>  	priv->phydev = phydev;
> @@ -437,6 +464,104 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
>  	return 0;
>  }
>  
> +static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
> +{
> +	struct device *kdev = &priv->pdev->dev;
> +	struct bcmgenet_platform_data *pd = kdev->platform_data;
> +	struct mii_bus *mdio = priv->mii_bus;
> +	int phy_addr = pd->phy_addr;
> +	struct phy_device *phydev;
> +	int ret;
> +	int i;
> +
> +	/* Disable automatic MDIO bus scan */
> +	mdio->phy_mask = ~0;
> +
> +	/* Clear all the IRQ properties */
> +	if (mdio->irq)
> +		for (i = 0; i < PHY_MAX_ADDR; i++)
> +			mdio->irq[i] = PHY_POLL;
> +
> +	/* Register the MDIO bus */
> +	ret = mdiobus_register(mdio);
> +	if (ret) {
> +		dev_err(kdev, "failed to register MDIO bus\n");
> +		return ret;
> +	}
> +
> +	/*
> +	 * bcmgenet_platform_data needs to pass a valid PHY address for
> +	 * internal/external PHY or -1 for MoCA PHY.
> +	 */
> +	if (phy_addr >= 0 && phy_addr < PHY_MAX_ADDR) {

We do too much low-level PHY device handling, and since you already have
the phy_type provided via platform_data, we can use that hint to do the
following:

1) an internal or external PHY with MDIO accesses should leave the bus
auto-probing on with the specified PHY address in the mdio bus phy_mask

2) a MoCA PHY or an external PHY with MDIO accesses disabled should use
the fixed-0 MII bus instead.

This would look like this:

if (pd->phy_type != PHY_INTERFACE_MODE_MOCA || pd->mdio_enabled)
	mdio->phy_mask = ~(1 << pd->phy_addr);

	...
	mdiobus_register()

	priv->phydev = mdio->bus->phy_map[pd->phy_addr];

	phydev->phy_flags |= mask;

if (pd->phy_type == PHY_INTERFACE_MODE_MOCA || !pd->mdio_enabled)
	priv->phydev = fixed_phy_register(...);

and in both cases, later on you do connect to the PHY device

I can cook a patch to illustrate what I think this could look like since
I realize using pseudo-code to explain might not be the best thing.

> +		/*
> +		 * 10/100/1000 Ethernet port with external or internal PHY.
> +		 */
> +		phydev = get_phy_device(mdio, phy_addr, false);
> +		if (!phydev || IS_ERR(phydev)) {
> +			dev_err(kdev, "failed to create PHY device\n");
> +			mdiobus_unregister(mdio);
> +			return 1;
> +		}
> +
> +		phydev->irq = PHY_POLL;
> +
> +		ret = phy_device_register(phydev);
> +		if (ret) {
> +			dev_err(kdev, "failed to register PHY device\n");
> +			phy_device_free(phydev);
> +			mdiobus_unregister(mdio);
> +			return 1;
> +		}
> +
> +		priv->phydev = phydev;
> +		priv->phy_interface = pd->phy_type;
> +	} else {
> +		/*
> +		 * MoCA port with no MDIO-accessible PHY.
> +		 * We need to use 1000/HD fixed PHY to represent the link layer.
> +		 * MoCA daemon interacts with this PHY via ethtool.
> +		 */
> +		struct fixed_phy_status moca_fphy_status = {
> +			.link = 0,
> +			.duplex = 0,

This should be DUPLEX_FULL here, the link between GENET and the MoCA
Ethernet convergence layer is full-duplex by nature (despite we report
the PHY being half-duplex, which is a mistake in the downstream driver),
the MoCA medium on the coaxial cable is half-duplex though, but that is
handled by the MoCA HW.

NB: I had issues in the past using a half-duplex link with the MoCA
ethernet convergence layer, causing various types of packet loss because
we use a simplified signaling internally in the hardware.

> +			.speed = 1000,
> +			.pause = 0,
> +			.asym_pause = 0,
> +		};
> +
> +		phydev = fixed_phy_register(PHY_POLL, &moca_fphy_status, NULL);
> +		if (!phydev || IS_ERR(phydev)) {
> +			dev_err(kdev, "failed to register fixed PHY device\n");
> +			mdiobus_unregister(mdio);
> +			return 1;
> +		}
> +
> +		phydev->autoneg = AUTONEG_DISABLE;
> +
> +		ret = fixed_phy_set_link_update(phydev,
> +						bcmgenet_moca_fphy_update);
> +		if (ret) {
> +			dev_err(kdev, "failed to set fixed PHY link update\n");
> +		}

Should not we propagate this error to the caller?
--
Florian
