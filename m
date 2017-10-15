From: Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH net-next v2 2/2] net: ethernet: socionext: add AVE
 ethernet driver
Date: Mon, 16 Oct 2017 00:08:21 +0900
Message-ID: <CAK7LNAR0Dy0aUjQKw7YxSbXZkpjn=1B7_knkSed6=EDVzL6v9w@mail.gmail.com>
References: <1507854928-4357-1-git-send-email-hayashi.kunihiko@socionext.com> <1507854928-4357-3-git-send-email-hayashi.kunihiko@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Masami Hiramatsu <masami.hiramatsu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507854928-4357-3-git-send-email-hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2017-10-13 9:35 GMT+09:00 Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>:
> +static int ave_probe(struct platform_device *pdev)
> +{
> +       struct device *dev = &pdev->dev;
> +       struct device_node *np = dev->of_node;
> +       u32 ave_id;
> +       struct ave_private *priv;
> +       const struct ave_soc_data *data;
> +       phy_interface_t phy_mode;
> +       struct net_device *ndev;
> +       struct resource *res;
> +       void __iomem *base;
> +       int irq, ret = 0;
> +       char buf[ETHTOOL_FWVERS_LEN];
> +       const void *mac_addr;
> +
> +       data = of_device_get_match_data(dev);
> +       if (WARN_ON(!data))
> +               return -EINVAL;
> +
> +       phy_mode = of_get_phy_mode(np);
> +       if (phy_mode < 0) {
> +               dev_err(dev, "phy-mode not found\n");
> +               return -EINVAL;
> +       }
> +       if ((!phy_interface_mode_is_rgmii(phy_mode)) &&
> +           phy_mode != PHY_INTERFACE_MODE_RMII &&
> +           phy_mode != PHY_INTERFACE_MODE_MII) {
> +               dev_err(dev, "phy-mode is invalid\n");
> +               return -EINVAL;
> +       }
> +
> +       irq = platform_get_irq(pdev, 0);
> +       if (irq < 0) {
> +               dev_err(dev, "IRQ not found\n");
> +               return irq;
> +       }
> +
> +       res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +       base = devm_ioremap_resource(dev, res);
> +       if (IS_ERR(base))
> +               return PTR_ERR(base);
> +
> +       /* alloc netdevice */
> +       ndev = alloc_etherdev(sizeof(struct ave_private));
> +       if (!ndev) {
> +               dev_err(dev, "can't allocate ethernet device\n");
> +               return -ENOMEM;
> +       }
> +
> +       ndev->netdev_ops = &ave_netdev_ops;
> +       ndev->ethtool_ops = &ave_ethtool_ops;
> +       SET_NETDEV_DEV(ndev, dev);
> +
> +       /* support hardware checksum */
> +       ndev->features    |= (NETIF_F_IP_CSUM | NETIF_F_RXCSUM);
> +       ndev->hw_features |= (NETIF_F_IP_CSUM | NETIF_F_RXCSUM);
> +
> +       ndev->max_mtu = AVE_MAX_ETHFRAME - (ETH_HLEN + ETH_FCS_LEN);
> +
> +       /* get mac address */
> +       mac_addr = of_get_mac_address(np);
> +       if (mac_addr)
> +               ether_addr_copy(ndev->dev_addr, mac_addr);
> +
> +       /* if the mac address is invalid, use random mac address */
> +       if (!is_valid_ether_addr(ndev->dev_addr)) {
> +               eth_hw_addr_random(ndev);
> +               dev_warn(dev, "Using random MAC address: %pM\n",
> +                        ndev->dev_addr);
> +       }
> +
> +       priv = netdev_priv(ndev);
> +       priv->base = base;
> +       priv->irq = irq;
> +       priv->ndev = ndev;
> +       priv->msg_enable = netif_msg_init(-1, AVE_DEFAULT_MSG_ENABLE);
> +       priv->phy_mode = phy_mode;
> +       priv->data = data;
> +
> +       if (IS_DESC_64BIT(priv)) {
> +               priv->desc_size = AVE_DESC_SIZE_64;
> +               priv->tx.daddr  = AVE_TXDM_64;
> +               priv->rx.daddr  = AVE_RXDM_64;
> +       } else {
> +               priv->desc_size = AVE_DESC_SIZE_32;
> +               priv->tx.daddr  = AVE_TXDM_32;
> +               priv->rx.daddr  = AVE_RXDM_32;
> +       }
> +       priv->tx.ndesc = AVE_NR_TXDESC;
> +       priv->rx.ndesc = AVE_NR_RXDESC;
> +
> +       u64_stats_init(&priv->stats_rx.syncp);
> +       u64_stats_init(&priv->stats_tx.syncp);
> +
> +       /* get clock */

Please remove this super-obvious comment.


> +       priv->clk = clk_get(dev, NULL);

Missing clk_put() in the failure path.

Why don't you use devm?



> +       if (IS_ERR(priv->clk))
> +               priv->clk = NULL;

So, clk is optional, but
you need to check EPROBE_DEFER.




> +       /* get reset */

Remove.


> +       priv->rst = reset_control_get(dev, NULL);
> +       if (IS_ERR(priv->rst))
> +               priv->rst = NULL;


reset_control_get() is deprecated.  Do not use it in a new driver.

Again, missing reset_control_put().   devm?


The reset seems optional (again, ignoring EPROBE_DEFER)
but you did not use reset_control_get_optional, why?

>From your code, this reset is used as shared.


priv->rst = devm_reset_control_get_optional_shared(dev, NULL);
if (IS_ERR(priv->rst))
          return PTR_ERR(priv->rst);








-- 
Best Regards
Masahiro Yamada
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
