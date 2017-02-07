From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 2/3] net: phy: dp83867: Add lane swapping support in
 the DP83867 TI's PHY driver
Date: Tue, 7 Feb 2017 14:03:15 +0100
Message-ID: <20170207130315.GC31560@lunn.ch>
References: <1486444824-12733-1-git-send-email-lukma@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Karicheri Muralidharan <m-karicheri2@ti.com>,
        linux-kernel@vger.kernel.org, Eric Engestrom <eric@engestrom.ch>,
        netdev@vger.kernel.org, Kishon Vijay Abraham I <kishon@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: Lukasz Majewski <lukma@denx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1486444824-12733-1-git-send-email-lukma@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 07, 2017 at 06:20:23AM +0100, Lukasz Majewski wrote:
> This patch adds support for enabling or disabling the lane swapping (called
> "port mirroring" in PHY's CFG4 register) feature of the DP83867 TI's PHY
> device.
> 
> One use case is when bootstrap configuration enables this feature (because
> of e.g. LED_0 wrong wiring) so then one needs to disable it in software
> (at u-boot/Linux).
> 
> Signed-off-by: Lukasz Majewski <lukma@denx.de>

So it is documented, in a separate patch, which is out of order.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew


> ---
> Changes for v3:
> - Add "line swapping" to the patch description
> - Add DP83867_PORT_MIRROING_KEEP enum for better code readability
> 
> Changes for v2:
> - use "net-phy-lane-swap" and "net-phy-lane-no-swap" generic PHY properties.
>   instead of TI specific one
> ---
>  drivers/net/phy/dp83867.c | 38 ++++++++++++++++++++++++++++++++++++++
>  1 file changed, 38 insertions(+)
> 
> diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
> index ca1b462..be6fa24 100644
> --- a/drivers/net/phy/dp83867.c
> +++ b/drivers/net/phy/dp83867.c
> @@ -32,6 +32,7 @@
>  #define DP83867_CFG3		0x1e
>  
>  /* Extended Registers */
> +#define DP83867_CFG4            0x0031
>  #define DP83867_RGMIICTL	0x0032
>  #define DP83867_RGMIIDCTL	0x0086
>  #define DP83867_IO_MUX_CFG	0x0170
> @@ -70,11 +71,21 @@
>  #define DP83867_IO_MUX_CFG_IO_IMPEDANCE_MAX	0x0
>  #define DP83867_IO_MUX_CFG_IO_IMPEDANCE_MIN	0x1f
>  
> +/* CFG4 bits */
> +#define DP83867_CFG4_PORT_MIRROR_EN              BIT(0)
> +
> +enum {
> +	DP83867_PORT_MIRROING_KEEP,
> +	DP83867_PORT_MIRROING_EN,
> +	DP83867_PORT_MIRROING_DIS,
> +};
> +
>  struct dp83867_private {
>  	int rx_id_delay;
>  	int tx_id_delay;
>  	int fifo_depth;
>  	int io_impedance;
> +	int port_mirroring;
>  };
>  
>  static int dp83867_ack_interrupt(struct phy_device *phydev)
> @@ -111,6 +122,24 @@ static int dp83867_config_intr(struct phy_device *phydev)
>  	return phy_write(phydev, MII_DP83867_MICR, micr_status);
>  }
>  
> +static int dp83867_config_port_mirroring(struct phy_device *phydev)
> +{
> +	struct dp83867_private *dp83867 =
> +		(struct dp83867_private *)phydev->priv;
> +	u16 val;
> +
> +	val = phy_read_mmd_indirect(phydev, DP83867_CFG4, DP83867_DEVADDR);
> +
> +	if (dp83867->port_mirroring == DP83867_PORT_MIRROING_EN)
> +		val |= DP83867_CFG4_PORT_MIRROR_EN;
> +	else
> +		val &= ~DP83867_CFG4_PORT_MIRROR_EN;
> +
> +	phy_write_mmd_indirect(phydev, DP83867_CFG4, DP83867_DEVADDR, val);
> +
> +	return 0;
> +}
> +
>  #ifdef CONFIG_OF_MDIO
>  static int dp83867_of_init(struct phy_device *phydev)
>  {
> @@ -144,6 +173,12 @@ static int dp83867_of_init(struct phy_device *phydev)
>  	     phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID))
>  		return ret;
>  
> +	if (of_property_read_bool(of_node, "enet-phy-lane-swap"))
> +		dp83867->port_mirroring = DP83867_PORT_MIRROING_EN;
> +
> +	if (of_property_read_bool(of_node, "enet-phy-lane-no-swap"))
> +		dp83867->port_mirroring = DP83867_PORT_MIRROING_DIS;
> +
>  	return of_property_read_u32(of_node, "ti,fifo-depth",
>  				   &dp83867->fifo_depth);
>  }
> @@ -228,6 +263,9 @@ static int dp83867_config_init(struct phy_device *phydev)
>  		phy_write(phydev, DP83867_CFG3, val);
>  	}
>  
> +	if (dp83867->port_mirroring != DP83867_PORT_MIRROING_KEEP)
> +		dp83867_config_port_mirroring(phydev);
> +
>  	return 0;
>  }
>  
> -- 
> 2.1.4
> 
