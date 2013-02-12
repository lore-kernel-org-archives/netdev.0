From: Bhushan Bharat-R65777 <R65777@freescale.com>
Subject: RE: [PATCH v2] net: fec_mpc52xx: Read MAC address from device-tree
Date: Tue, 12 Feb 2013 10:56:05 +0000
Message-ID: <6A3DF150A5B70D4F9B66A25E3F7C888D065A0271@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1360660088-27464-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	Anatolij Gustschin <agust@denx.de>
To: Stefan Roese <sr@denx.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe003.messaging.microsoft.com ([213.199.154.141]:21355
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756820Ab3BLK4N convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2013 05:56:13 -0500
In-Reply-To: <1360660088-27464-1-git-send-email-sr@denx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Linuxppc-dev [mailto:linuxppc-dev-
> bounces+bharat.bhushan=freescale.com@lists.ozlabs.org] On Behalf Of Stefan Roese
> Sent: Tuesday, February 12, 2013 2:38 PM
> To: netdev@vger.kernel.org
> Cc: linuxppc-dev@ozlabs.org; Anatolij Gustschin
> Subject: [PATCH v2] net: fec_mpc52xx: Read MAC address from device-tree
> 
> Until now, the MPC5200 FEC ethernet driver relied upon the bootloader
> (U-Boot) to write the MAC address into the ethernet controller registers. The
> Linux driver should not rely on such a thing. So lets read the MAC address from
> the DT as it should be done here.
> 
> The following priority is now used to read the MAC address:
> 
> 1) First, try OF node MAC address, if not present or invalid, then:
> 
> 2) Read from MAC address registers, if invalid, then:

Why we read from MAC registers if Linux should not rely on bootloader?

-Bharat


> 
> 3) Log a warning message, and choose a random MAC address.
> 
> This fixes a problem with a MPC5200 board that uses the SPL U-Boot version
> without FEC initialization before Linux booting for boot speedup.
> 
> Additionally a status line is now be printed upon successful driver probing,
> also displaying this MAC address.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>
> Cc: Anatolij Gustschin <agust@denx.de>
> ---
> v2:
> - Remove module parameter mpc52xx_fec_mac_addr
> - Priority for MAC address probing now is DT, controller regs
>   If the resulting MAC address is invalid, a random address will
>   be generated and used with a warning message
> - Use "np" variable to simplify the code
> 
>  drivers/net/ethernet/freescale/fec_mpc52xx.c | 61 +++++++++++++++++-----------
>  1 file changed, 37 insertions(+), 24 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c
> b/drivers/net/ethernet/freescale/fec_mpc52xx.c
> index 817d081..8b725f4 100644
> --- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
> +++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
> @@ -76,10 +76,6 @@ static void mpc52xx_fec_stop(struct net_device *dev);  static
> void mpc52xx_fec_start(struct net_device *dev);  static void
> mpc52xx_fec_reset(struct net_device *dev);
> 
> -static u8 mpc52xx_fec_mac_addr[6];
> -module_param_array_named(mac, mpc52xx_fec_mac_addr, byte, NULL, 0); -
> MODULE_PARM_DESC(mac, "six hex digits, ie. 0x1,0x2,0xc0,0x01,0xba,0xbe");
> -
>  #define MPC52xx_MESSAGES_DEFAULT ( NETIF_MSG_DRV | NETIF_MSG_PROBE | \
>  		NETIF_MSG_LINK | NETIF_MSG_IFDOWN | NETIF_MSG_IFUP)
>  static int debug = -1;	/* the above default */
> @@ -110,15 +106,6 @@ static void mpc52xx_fec_set_paddr(struct net_device *dev,
> u8 *mac)
>  	out_be32(&fec->paddr2, (*(u16 *)(&mac[4]) << 16) | FEC_PADDR2_TYPE);  }
> 
> -static void mpc52xx_fec_get_paddr(struct net_device *dev, u8 *mac) -{
> -	struct mpc52xx_fec_priv *priv = netdev_priv(dev);
> -	struct mpc52xx_fec __iomem *fec = priv->fec;
> -
> -	*(u32 *)(&mac[0]) = in_be32(&fec->paddr1);
> -	*(u16 *)(&mac[4]) = in_be32(&fec->paddr2) >> 16;
> -}
> -
>  static int mpc52xx_fec_set_mac_address(struct net_device *dev, void *addr)  {
>  	struct sockaddr *sock = addr;
> @@ -853,6 +840,8 @@ static int mpc52xx_fec_probe(struct platform_device *op)
>  	struct resource mem;
>  	const u32 *prop;
>  	int prop_size;
> +	struct device_node *np = op->dev.of_node;
> +	const void *p;
> 
>  	phys_addr_t rx_fifo;
>  	phys_addr_t tx_fifo;
> @@ -866,7 +855,7 @@ static int mpc52xx_fec_probe(struct platform_device *op)
>  	priv->ndev = ndev;
> 
>  	/* Reserve FEC control zone */
> -	rv = of_address_to_resource(op->dev.of_node, 0, &mem);
> +	rv = of_address_to_resource(np, 0, &mem);
>  	if (rv) {
>  		printk(KERN_ERR DRIVER_NAME ": "
>  				"Error while parsing device node resource\n" ); @@ -
> 919,7 +908,7 @@ static int mpc52xx_fec_probe(struct platform_device *op)
> 
>  	/* Get the IRQ we need one by one */
>  		/* Control */
> -	ndev->irq = irq_of_parse_and_map(op->dev.of_node, 0);
> +	ndev->irq = irq_of_parse_and_map(np, 0);
> 
>  		/* RX */
>  	priv->r_irq = bcom_get_task_irq(priv->rx_dmatsk);
> @@ -927,11 +916,33 @@ static int mpc52xx_fec_probe(struct platform_device *op)
>  		/* TX */
>  	priv->t_irq = bcom_get_task_irq(priv->tx_dmatsk);
> 
> -	/* MAC address init */
> -	if (!is_zero_ether_addr(mpc52xx_fec_mac_addr))
> -		memcpy(ndev->dev_addr, mpc52xx_fec_mac_addr, 6);
> -	else
> -		mpc52xx_fec_get_paddr(ndev, ndev->dev_addr);
> +	/*
> +	 * MAC address init:
> +	 *
> +	 * First try to read MAC address from DT
> +	 */
> +	p = of_get_property(np, "local-mac-address", NULL);
> +	if (p != NULL) {
> +		memcpy(ndev->dev_addr, p, 6);
> +	} else {
> +		struct mpc52xx_fec __iomem *fec = priv->fec;
> +
> +		/*
> +		 * If the MAC addresse is not provided via DT then read
> +		 * it back from the controller regs
> +		 */
> +		*(u32 *)(&ndev->dev_addr[0]) = in_be32(&fec->paddr1);
> +		*(u16 *)(&ndev->dev_addr[4]) = in_be32(&fec->paddr2) >> 16;
> +	}
> +
> +	/*
> +	 * Check if the MAC address is valid, if not get a random one
> +	 */
> +	if (!is_valid_ether_addr(ndev->dev_addr)) {
> +		eth_hw_addr_random(ndev);
> +		dev_warn(&ndev->dev, "using random MAC address %pM\n",
> +			 ndev->dev_addr);
> +	}
> 
>  	priv->msg_enable = netif_msg_init(debug, MPC52xx_MESSAGES_DEFAULT);
> 
> @@ -942,20 +953,20 @@ static int mpc52xx_fec_probe(struct platform_device *op)
>  	/* Start with safe defaults for link connection */
>  	priv->speed = 100;
>  	priv->duplex = DUPLEX_HALF;
> -	priv->mdio_speed = ((mpc5xxx_get_bus_frequency(op->dev.of_node) >> 20) /
> 5) << 1;
> +	priv->mdio_speed = ((mpc5xxx_get_bus_frequency(np) >> 20) / 5) << 1;
> 
>  	/* The current speed preconfigures the speed of the MII link */
> -	prop = of_get_property(op->dev.of_node, "current-speed", &prop_size);
> +	prop = of_get_property(np, "current-speed", &prop_size);
>  	if (prop && (prop_size >= sizeof(u32) * 2)) {
>  		priv->speed = prop[0];
>  		priv->duplex = prop[1] ? DUPLEX_FULL : DUPLEX_HALF;
>  	}
> 
>  	/* If there is a phy handle, then get the PHY node */
> -	priv->phy_node = of_parse_phandle(op->dev.of_node, "phy-handle", 0);
> +	priv->phy_node = of_parse_phandle(np, "phy-handle", 0);
> 
>  	/* the 7-wire property means don't use MII mode */
> -	if (of_find_property(op->dev.of_node, "fsl,7-wire-mode", NULL)) {
> +	if (of_find_property(np, "fsl,7-wire-mode", NULL)) {
>  		priv->seven_wire_mode = 1;
>  		dev_info(&ndev->dev, "using 7-wire PHY mode\n");
>  	}
> @@ -970,6 +981,8 @@ static int mpc52xx_fec_probe(struct platform_device *op)
> 
>  	/* We're done ! */
>  	dev_set_drvdata(&op->dev, ndev);
> +	printk(KERN_INFO "%s: %s MAC %pM\n",
> +	       ndev->name, op->dev.of_node->full_name, ndev->dev_addr);
> 
>  	return 0;
> 
> --
> 1.8.1.3
> 
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
