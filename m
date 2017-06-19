From: Nicolas Ferre <nicolas.ferre@microchip.com>
Subject: Re: [PATCH] net: macb: add fixed-link node support
Date: Mon, 19 Jun 2017 12:54:10 +0200
Message-ID: <f9b2d4f7-3751-af45-c347-5f996586b15e@microchip.com>
References: <20170616085536.20442-1-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <kernel@pengutronix.de>
To: Michael Grzeschik <m.grzeschik@pengutronix.de>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:9614 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753650AbdFSKxk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 06:53:40 -0400
In-Reply-To: <20170616085536.20442-1-m.grzeschik@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/06/2017 à 10:55, Michael Grzeschik a écrit :
> In case the MACB is directly connected to a
> non-mdio PHY/device, it should be possible to provide
> a fixed link configuration in the DT.
> 
> Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
> ---
>  drivers/net/ethernet/cadence/macb.c | 21 +++++++++++++++++++++
>  drivers/net/ethernet/cadence/macb.h |  2 +-
>  2 files changed, 22 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 91f7492623d3f..91e36efe1d5fb 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -425,6 +425,16 @@ static int macb_mii_probe(struct net_device *dev)
>  	int phy_irq;
>  	int ret;
>  
> +	if (bp->phy_node) {
> +		phydev = of_phy_connect(dev, bp->phy_node,
> +					&macb_handle_link_change, 0,
> +					bp->phy_interface);
> +		if (!phydev)
> +			return -ENODEV;
> +
> +		return 0;

I understand that we can avoid the part with phy_connect_direct() of the
remaining of this function, but what about the way to amend the phy
features with the possibilities of the MAC
(phydev->supported/advertising). The bp fields initialization seem
redundant and handled elsewhere anyway.

> +	}
> +
>  	phydev = phy_find_first(bp->mii_bus);
>  	if (!phydev) {
>  		netdev_err(dev, "no PHY found\n");
> @@ -498,6 +508,17 @@ static int macb_mii_init(struct macb *bp)
>  	dev_set_drvdata(&bp->dev->dev, bp->mii_bus);
>  
>  	np = bp->pdev->dev.of_node;
> +	if (of_phy_is_fixed_link(np)) {

For now, we are not sure that the np is != NULL.
The PCI support for this driver does use the pdata.
(Cf: 83a77e9ec415 (net: macb: Added PCI wrapper for Platform Driver.)
).


> +		if (of_phy_register_fixed_link(np) < 0) {
> +			dev_err(&bp->pdev->dev,
> +				"broken fixed-link specification\n");
> +			goto err_out_unregister_bus;
> +		}
> +		bp->phy_node = of_node_get(np);
> +
> +		np = NULL;
> +	}
> +
>  	if (np) {

Even if the case np == NULL is catch somewhere in
of_phy_register_fixed_link(), why not put the  code here?

>  		/* try dt phy registration */
>  		err = of_mdiobus_register(bp->mii_bus, np);
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index ec037b0fa2a4d..7efc726e0a113 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -928,7 +928,7 @@ struct macb {
>  	dma_addr_t		rx_buffers_dma;
>  
>  	struct macb_or_gem_ops	macbgem_ops;
> -

Nit: no need to remove the empty line.

> +	struct device_node	*phy_node;
>  	struct mii_bus		*mii_bus;
>  	int 			link;
>  	int 			speed;
> 

Thanks for your patch.

Best regards,
-- 
Nicolas Ferre
