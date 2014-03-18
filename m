From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V5 2/8] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Tue, 18 Mar 2014 11:59:15 -0700
Message-ID: <CAGVrzcYgONroZULGKhiigPT8yqLDufbzgR4+q7_tdNEqgWDKkA@mail.gmail.com>
References: <002801cf42d6$a27317c0$e7594740$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, linux-samsung-soc@vger.kernel.org,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"siva.kallam" <siva.kallam@samsung.com>,
	"ks.giri" <ks.giri@samsung.com>,
	"ilho215.lee" <ilho215.lee@samsung.com>,
	"vipul.pandya" <vipul.pandya@samsung.com>
To: Byungho An <bh74.an@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:42816 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757611AbaCRS76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 14:59:58 -0400
In-Reply-To: <002801cf42d6$a27317c0$e7594740$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-18 11:19 GMT-07:00 Byungho An <bh74.an@samsung.com>:
> From: Siva Reddy <siva.kallam@samsung.com>
>
> This patch adds support for Samsung 10Gb ethernet driver(sxgbe).
>
> - sxgbe core initialization
> - Tx and Rx support
> - MDIO support
> - ISRs for Tx and Rx
> - ifconfig support to driver

Too many files to review at once, the diffstat was around 5000+ lines!
You should split this into logical parts, or just submit the basic
bits for now and add the features later.

[snip]

> +       ret = register_netdev(ndev);
> +       if (ret) {
> +               pr_err("%s: ERROR %i registering the device\n", __func__, ret);
> +               goto error_netdev_register;
> +       }
> +
> +       priv->sxgbe_clk = clk_get(priv->device, SXGBE_RESOURCE_NAME);
> +       if (IS_ERR(priv->sxgbe_clk)) {
> +               netdev_warn(ndev, "%s: warning: cannot get CSR clock\n",
> +                           __func__);
> +               goto error_clk_get;
> +       }

This is racy, after register_netdev() is called, the network stack is
free to use the interface, which means that as much as possible needs
to be initialized before you call it, including clocks, and MDIO.

> +
> +       /* If a specific clk_csr value is passed from the platform
> +        * this means that the CSR Clock Range selection cannot be
> +        * changed at run-time and it is fixed. Viceversa the driver'll try to
> +        * set the MDC clock dynamically according to the csr actual
> +        * clock input.
> +        */
> +       if (!priv->plat->clk_csr)
> +               sxgbe_clk_csr_set(priv);
> +       else
> +               priv->clk_csr = priv->plat->clk_csr;
> +
> +       /* MDIO bus Registration */
> +       ret = sxgbe_mdio_register(ndev);
> +       if (ret < 0) {
> +               netdev_dbg(ndev, "%s: MDIO bus (id: %d) registration failed\n",
> +                          __func__, priv->plat->bus_id);
> +               goto error_mdio_register;
> +       }

Don't do this, register your MDIO bus before calling register_netdev().

> +
> +       sxgbe_check_ether_addr(priv);
> +
> +       return priv;
> +
> +error_mdio_register:
> +       clk_put(priv->sxgbe_clk);
> +error_clk_get:
> +       unregister_netdev(ndev);
> +error_netdev_register:
> +       netif_napi_del(&priv->napi);
> +error_free_netdev:
> +       free_netdev(ndev);
> +
> +       return NULL;
> +}
> +
> +/**
> + * sxgbe_dvr_remove
> + * @ndev: net device pointer
> + * Description: this function resets the TX/RX processes, disables the MAC RX/TX
> + * changes the link status, releases the DMA descriptor rings.
> + */
> +int sxgbe_dvr_remove(struct net_device *ndev)
> +{
> +       struct sxgbe_priv_data *priv = netdev_priv(ndev);
> +
> +       netdev_info(ndev, "%s: removing driver\n", __func__);
> +
> +       priv->hw->dma->stop_rx(priv->ioaddr, SXGBE_RX_QUEUES);
> +       priv->hw->dma->stop_tx(priv->ioaddr, SXGBE_TX_QUEUES);
> +
> +       priv->hw->mac->enable_tx(priv->ioaddr, false);
> +       priv->hw->mac->enable_rx(priv->ioaddr, false);
> +
> +       netif_napi_del(&priv->napi);
> +
> +       sxgbe_mdio_unregister(ndev);
> +
> +       netif_carrier_off(ndev);

This is not required, both the PHY library and the network stack will
do that for you.

[snip]

> +       /* register with kernel subsystem */
> +       err = mdiobus_register(mdio_bus);
> +       if (err != 0) {
> +               netdev_err(ndev, "mdiobus register failed\n");
> +               goto mdiobus_err;
> +       }
> +
> +       for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
> +               struct phy_device *phy = mdio_bus->phy_map[phy_addr];
> +               if (phy) {
> +                       char irq_num[4];
> +                       char *irq_str;
> +                       /* If an IRQ was provided to be assigned after
> +                        * the bus probe, do it here.
> +                        */
> +                       if ((mdio_data->irqs == NULL) &&
> +                           (mdio_data->probed_phy_irq > 0)) {
> +                               irqlist[phy_addr] = mdio_data->probed_phy_irq;
> +                               phy->irq = mdio_data->probed_phy_irq;
> +                       }
> +
> +                       /* If we're  going to bind the MAC to this PHY bus,
> +                        * and no PHY number was provided to the MAC,
> +                        * use the one probed here.
> +                        */
> +                       if (priv->plat->phy_addr == -1)
> +                               priv->plat->phy_addr = phy_addr;
> +
> +                       act = (priv->plat->phy_addr == phy_addr);
> +                       switch (phy->irq) {
> +                       case PHY_POLL:
> +                               irq_str = "POLL";
> +                               break;
> +                       case PHY_IGNORE_INTERRUPT:
> +                               irq_str = "IGNORE";
> +                               break;
> +                       default:
> +                               sprintf(irq_num, "%d", phy->irq);
> +                               irq_str = irq_num;
> +                               break;
> +                       }
> +                       netdev_info(ndev, "PHY ID %08x at %d IRQ %s (%s)%s\n",
> +                                   phy->phy_id, phy_addr, irq_str,
> +                                   dev_name(&phy->dev), act ? " active" : "");
> +                       phy_found = 1;
> +               }

This is clunky, and you are duplicating what of_mdiobus_register()
will do for you, but since you are not using the standard Ethernet PHY
device tree node, you could not use that code. So please use the
standard Ethernet PHY device tree node such that you can remove that
code and leverage it instead.
-- 
Florian
