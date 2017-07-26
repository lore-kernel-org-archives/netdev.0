From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 03/18] net: mvpp2: set the SMI PHY address when
 connecting to the PHY
Date: Wed, 26 Jul 2017 18:08:06 +0200
Message-ID: <20170726160806.GF12049@lunn.ch>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-4-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40947 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751653AbdGZQIQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 12:08:16 -0400
Content-Disposition: inline
In-Reply-To: <20170724134848.19330-4-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 03:48:33PM +0200, Antoine Tenart wrote:
> When connecting to the PHY, explicitly set the SMI PHY address in the
> controller registers to configure a given port to be connected to the
> selected PHY.
> 
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
> ---
>  drivers/net/ethernet/marvell/mvpp2.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
> index 1e592abc9067..6ffff929b22a 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -359,6 +359,8 @@
>  #define MVPP22_SMI_MISC_CFG_REG			0x1204
>  #define     MVPP22_SMI_POLLING_EN		BIT(10)
>  
> +#define MVPP22_SMI_PHY_ADDR(port)		(0x120c + (port) * 0x4)
> +
>  #define MVPP22_GMAC_BASE(port)		(0x7000 + (port) * 0x1000 + 0xe00)
>  
>  #define MVPP2_CAUSE_TXQ_SENT_DESC_ALL_MASK	0xff
> @@ -5939,7 +5941,9 @@ static void mvpp21_get_mac_address(struct mvpp2_port *port, unsigned char *addr)
>  
>  static int mvpp2_phy_connect(struct mvpp2_port *port)
>  {
> +	struct mvpp2 *priv = port->priv;
>  	struct phy_device *phy_dev;
> +	u32 phy_addr;
>  
>  	phy_dev = of_phy_connect(port->dev, port->phy_node, mvpp2_link_event, 0,
>  				 port->phy_interface);
> @@ -5954,6 +5958,16 @@ static int mvpp2_phy_connect(struct mvpp2_port *port)
>  	port->duplex  = 0;
>  	port->speed   = 0;
>  
> +	if (priv->hw_version != MVPP22)
> +		return 0;
> +
> +	/* Set the SMI PHY address */
> +	if (of_property_read_u32(port->phy_node, "reg", &phy_addr)) {
> +		netdev_err(port->dev, "cannot find the PHY address\n");
> +		return -EINVAL;
> +	}
> +
> +	writel(phy_addr, priv->iface_base + MVPP22_SMI_PHY_ADDR(port->gop_id));
>  	return 0;
>  }

Hi Antoine

You could use phy_dev->mdiodev->addr, rather than parse the DT.

Why does the MAC need to know this address? The phylib and PHY driver
should be the only thing accessing the PHY, otherwise you are asking
for trouble.

What if the PHY is hanging off some other mdio bus? I've got a
freescale board with dual ethernets and a Marvell switch on the
hardware MDIO bus and a PHY on a bit-banging MDIO bus.

	 Andrew
