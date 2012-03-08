From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH v6] lpc32xx: Added ethernet driver
Date: Thu, 08 Mar 2012 10:27:58 +0100
Message-ID: <4F587B9E.4000708@openwrt.org>
References: <1331151693-21726-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	alexander.h.duyck@intel.com, eilong@broadcom.com,
	ian.campbell@citrix.com, netdev@vger.kernel.org,
	w.sang@pengutronix.de, linux-kernel@vger.kernel.org,
	kevin.wells@nxp.com, linux-arm-kernel@lists.infradead.org,
	arnd@arndb.de, baruch@tkos.co.il, joe@perches.com,
	bhutchings@solarflare.com
To: Roland Stigge <stigge@antcom.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331151693-21726-1-git-send-email-stigge@antcom.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Roland,

Le 03/07/12 21:21, Roland Stigge a =C3=A9crit :
> This patch adds an ethernet driver for the LPC32xx ARM SoC.
>
> Signed-off-by: Roland Stigge<stigge@antcom.de>

I have a couple of phylib-related comments addressed inline.

>
> ---
>
> Applies to v3.3-rc6
>
> Changes since v5:
>   * Indentation and whitespace fixes
>   * Use __le32 for descriptors
>   * Use bool for boolean function parameters
>   * Removed unnecessary (u32) cast
>   * Added comment regarding future device tree introduction
>
>   Thanks to David Miller, Arnd Bergmann and Joe Perches for
>   reviewing the last version!
>
>   drivers/net/ethernet/Kconfig       |    1
>   drivers/net/ethernet/Makefile      |    1
>   drivers/net/ethernet/nxp/Kconfig   |    8
>   drivers/net/ethernet/nxp/Makefile  |    1
>   drivers/net/ethernet/nxp/lpc_eth.c | 1616 +++++++++++++++++++++++++=
++++++++++++
>   5 files changed, 1627 insertions(+)
>
> --- linux-2.6.orig/drivers/net/ethernet/Kconfig
> +++ linux-2.6/drivers/net/ethernet/Kconfig

> +
> +static int lpc_mii_probe(struct net_device *ndev)
> +{
> +	struct netdata_local *pldat =3D netdev_priv(ndev);
> +	struct phy_device *phydev =3D NULL;
> +	int phy_addr;
> +
> +	/* find the first phy */
> +	for (phy_addr =3D 0; phy_addr<  PHY_MAX_ADDR; phy_addr++) {
> +		if (pldat->mii_bus->phy_map[phy_addr]) {
> +			phydev =3D pldat->mii_bus->phy_map[phy_addr];
> +			break;
> +		}
> +	}

Please use phy_find_first() instead of open-coding this.

> +
> +	if (!phydev) {
> +		netdev_err(ndev, "no PHY found\n");
> +		return -ENODEV;
> +	}
> +
> +	/* Attach to the PHY */
> +	if (lpc_phy_interface_mode() =3D=3D PHY_INTERFACE_MODE_MII)
> +		netdev_info(ndev, "using MII interface\n");
> +	else
> +		netdev_info(ndev, "using RMII interface\n");
> +	phydev =3D phy_connect(ndev, dev_name(&phydev->dev),
> +		&lpc_handle_link_change, 0, lpc_phy_interface_mode());
> +
> +	if (IS_ERR(phydev)) {
> +		netdev_err(ndev, "Could not attach to PHY\n");
> +		return PTR_ERR(phydev);
> +	}
> +
> +	/* mask with MAC supported features */
> +	phydev->supported&=3D PHY_BASIC_FEATURES;
> +
> +	phydev->advertising =3D phydev->supported;
> +
> +	pldat->link =3D 0;
> +	pldat->speed =3D 0;
> +	pldat->duplex =3D -1;
> +	pldat->phy_dev =3D phydev;
> +
> +	return 0;
> +}
> +
> +static int lpc_mii_init(struct netdata_local *pldat)
> +{
> +	int err =3D -ENXIO, i;
> +
> +	pldat->mii_bus =3D mdiobus_alloc();
> +	if (!pldat->mii_bus) {
> +		err =3D -ENOMEM;
> +		goto err_out;
> +	}
> +
> +	/* Setup MII mode */
> +	if (lpc_phy_interface_mode() =3D=3D PHY_INTERFACE_MODE_MII)
> +		writel(LPC_COMMAND_PASSRUNTFRAME,
> +		       LPC_ENET_COMMAND(pldat->net_base));
> +	else {
> +		writel((LPC_COMMAND_PASSRUNTFRAME | LPC_COMMAND_RMII),
> +		       LPC_ENET_COMMAND(pldat->net_base));
> +		writel(LPC_SUPP_RESET_RMII, LPC_ENET_SUPP(pldat->net_base));
> +	}
> +
> +	pldat->mii_bus->name =3D "lpc_mii_bus";
> +	pldat->mii_bus->read =3D&lpc_mdio_read;
> +	pldat->mii_bus->write =3D&lpc_mdio_write;
> +	pldat->mii_bus->reset =3D&lpc_mdio_reset;
> +	snprintf(pldat->mii_bus->id, MII_BUS_ID_SIZE, "%x", pldat->pdev->id=
);

No, makes this bus name unique in the system:
snprnitf(pldat->mii_bus->id, MII_BUS_ID_SIZE, "%s-%x",
	pldat->pdev->name, pldat->pdev->id);

> +	pldat->mii_bus->priv =3D pldat;
> +	pldat->mii_bus->parent =3D&pldat->pdev->dev;
> +	pldat->mii_bus->phy_mask =3D 0xFFFFFFF0;

I would rather not hardcode the phy_mask here, just leave it to 0, and=20
let phy_find_first() find the PHY devices for you, or make this platfor=
m=20
configurable.

> +
> +	pldat->mii_bus->irq =3D kmalloc(sizeof(int) * PHY_MAX_ADDR, GFP_KER=
NEL);
> +	if (!pldat->mii_bus->irq) {
> +		err =3D -ENOMEM;
> +		goto err_out_1;
> +	}
> +
> +	for (i =3D 0; i<  PHY_MAX_ADDR; i++)
> +		pldat->mii_bus->irq[i] =3D PHY_POLL;
> +
> +	platform_set_drvdata(pldat->pdev, pldat->mii_bus);
> +
> +	if (mdiobus_register(pldat->mii_bus))
> +		goto err_out_free_mdio_irq;
> +
> +	if (lpc_mii_probe(pldat->ndev) !=3D 0)
> +		goto err_out_unregister_bus;
> +
> +	return 0;
> +
> +err_out_unregister_bus:
> +	mdiobus_unregister(pldat->mii_bus);
> +err_out_free_mdio_irq:
> +	kfree(pldat->mii_bus->irq);
> +err_out_1:
> +	mdiobus_free(pldat->mii_bus);
> +err_out:
> +	return err;
> +}
> +

[snip]

> +
> +static int lpc_eth_open(struct net_device *ndev)
> +{
> +	struct netdata_local *pldat =3D netdev_priv(ndev);
> +
> +	/* if the phy is not yet registered, retry later*/
> +	if (!pldat->phy_dev)
> +		return -EAGAIN;

You have already probed the mii bus in the driver's probe function, how=
=20
can you end up here without a phy being attached here?

[snip]

> +	if (lpc_mii_init(pldat) !=3D 0)
> +		goto err_out_unregister_netdev;
> +
> +	netdev_info(ndev, "LPC mac at 0x%08x irq %d\n",
> +	       res->start, ndev->irq);
> +
> +	phydev =3D pldat->phy_dev;
> +	netdev_info(ndev,
> +		"attached PHY driver [%s] (mii_bus:phy_addr=3D%s, irq=3D%d)\n",
> +		phydev->drv->name, dev_name(&phydev->dev), phydev->irq);

Most drivers put this informational message in their mii probing=20
function, please move it here as well.

> +
> +	device_init_wakeup(&pdev->dev, 1);
> +	device_set_wakeup_enable(&pdev->dev, 0);
> +
> +	return 0;
> +
> +err_out_unregister_netdev:
> +	platform_set_drvdata(pdev, NULL);
> +	unregister_netdev(ndev);
> +err_out_dma_unmap:
> +	if (!use_iram_for_net() ||
> +	    pldat->dma_buff_size>  lpc32xx_return_iram_size())
> +		dma_free_coherent(&pldat->pdev->dev, pldat->dma_buff_size,
> +				  pldat->dma_buff_base_v,
> +				  pldat->dma_buff_base_p);
> +err_out_free_irq:
> +	free_irq(ndev->irq, ndev);
> +err_out_iounmap:
> +	iounmap(pldat->net_base);
> +err_out_disable_clocks:
> +	clk_disable(pldat->clk);
> +	clk_put(pldat->clk);
> +err_out_free_dev:
> +	free_netdev(ndev);
> +err_exit:
> +	pr_err("%s: not found (%d).\n", MODNAME, ret);
> +	return ret;
> +}
> +
> +static int lpc_eth_drv_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev =3D platform_get_drvdata(pdev);
> +	struct netdata_local *pldat =3D netdev_priv(ndev);
> +
> +	unregister_netdev(ndev);
> +	platform_set_drvdata(pdev, NULL);
> +
> +	if (!use_iram_for_net() ||
> +	    pldat->dma_buff_size>  lpc32xx_return_iram_size())
> +		dma_free_coherent(&pldat->pdev->dev, pldat->dma_buff_size,
> +				  pldat->dma_buff_base_v,
> +				  pldat->dma_buff_base_p);
> +	free_irq(ndev->irq, ndev);
> +	iounmap(pldat->net_base);
> +	clk_disable(pldat->clk);
> +	clk_put(pldat->clk);
> +	free_netdev(ndev);

You are not freeing the mii bus in the driver's remove path.
--
=46lorian
