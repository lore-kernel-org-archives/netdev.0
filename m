From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: stmmac: Use the right logging function in
 stmmac_mdio_register
Date: Thu, 10 Aug 2017 15:56:53 +0200
Message-ID: <20170810135653.GB24790@lunn.ch>
References: <20170810073826.24362-1-romain.perier@collabora.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Romain Perier <romain.perier@collabora.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170810073826.24362-1-romain.perier@collabora.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 10, 2017 at 09:38:26AM +0200, Romain Perier wrote:
> Currently, the function stmmac_mdio_register() is only used by
> stmmac_dvr_probe() from stmmac_main.c, in order to register the MDIO bus
> and probe information about the PHY. As this function is called before
> calling register_netdev(), all messages logged from stmmac_mdio_register
> are prefixed by "(unnamed net_device)". The goal of netdev_info or
> netdev_err is to dump useful infos about a net_device, when this data
> structure is partially initialized, there is no point for using these
> functions.
> 
> This commit fixes the issue by replacing all netdev_*() by the
> corresponding dev_*() function for logging. The last netdev_info is
> replaced by phy_attached_info(), as a valid phydev can be used at this
> point.
> 
> Signed-off-by: Romain Perier <romain.perier@collabora.com>
> ---
> 
> Changes in v2:
> - Replaced dev_info() by phy_attached_print()
> - Simplified message because informations were redudant
> - Updated commit message
> 
>  drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> index db157a47000c..e0fbf8657103 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
> @@ -204,6 +204,7 @@ int stmmac_mdio_register(struct net_device *ndev)
>  	struct stmmac_priv *priv = netdev_priv(ndev);
>  	struct stmmac_mdio_bus_data *mdio_bus_data = priv->plat->mdio_bus_data;
>  	struct device_node *mdio_node = priv->plat->mdio_node;
> +	struct device *dev = ndev->dev.parent;
>  	int addr, found;
>  
>  	if (!mdio_bus_data)
> @@ -237,7 +238,7 @@ int stmmac_mdio_register(struct net_device *ndev)
>  	else
>  		err = mdiobus_register(new_bus);
>  	if (err != 0) {
> -		netdev_err(ndev, "Cannot register the MDIO bus\n");
> +		dev_err(dev, "Cannot register the MDIO bus\n");
>  		goto bus_register_fail;
>  	}
>  
> @@ -285,14 +286,14 @@ int stmmac_mdio_register(struct net_device *ndev)
>  			irq_str = irq_num;
>  			break;
>  		}
> -		netdev_info(ndev, "PHY ID %08x at %d IRQ %s (%s)%s\n",
> -			    phydev->phy_id, addr, irq_str, phydev_name(phydev),
> -			    act ? " active" : "");
> +		phy_attached_print(phydev, "PHY ID %08x IRQ %s %s\n",
> +				   phydev->phy_id, irq_str,
> +				   act ? " active" : "");

I don't want to go round and round with this patch, with feature creep. 

But there are only two drivers which use phy_attached_print() to print
more than the standard printed by phy_attached_info().
phy_attached_info() will give you the driver name, so do you need the
ID? phy_attached_info() prints the irq as a number, rather than a nice
string.

act is just odd. The loop is effectively phy_find_first(). The act
means it has found a phy, but not the phy indicated in the platform
data, but it is going to use it anyway!

So i will give:

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

but if you think phy_attached_info() is acceptable, that would be
great.

    Andrew
