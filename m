From: PERIER Romain <romain.perier@gmail.com>
Subject: Re: [PATCH v3 3/3] ethernet: arc: Add support for specific SoC glue
 layer device tree bindings
Date: Tue, 26 Aug 2014 11:26:32 +0200
Message-ID: <CABgxDoLiCiDay7MGWnzStZ8N4Uhe5rVEzcPgbu4POJuGSeZrug@mail.gmail.com>
References: <1409045032-29604-1-git-send-email-romain.perier@gmail.com>
	<1409045032-29604-3-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko@sntech.de>,
	Tobias Klauser <tklauser@distanz.ch>,
	Beniamino Galvani <b.galvani@gmail.com>,
	"eric.dumazet" <eric.dumazet@gmail.com>,
	yongjun_wei@trendmicro.com.cn,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>
To: davem <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:36948 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932407AbaHZJ0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 05:26:33 -0400
Received: by mail-qc0-f174.google.com with SMTP id l6so15100535qcy.33
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 02:26:32 -0700 (PDT)
In-Reply-To: <1409045032-29604-3-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PS: I will add callback function for set_mac_speed from platform
driver and a priv data inline function (like netdev_priv for arc_emac)
into another seperated commit, I think.

Romain

2014-08-26 11:23 GMT+02:00 Romain Perier <romain.perier@gmail.com>:
> Some platforms have special bank registers which might be used to select
> the correct clock or the right mode for Media Indepent Interface controllers.
> Sometimes, it is also required to activate vcc regulators in the right order to supply
> the ethernet controller at the right time. This patch is an architecture refactoring
> of the arc-emac device driver. it adds a new software design which allows to add specific
> platform glue layer. Each platform has now its own module which performs custom initialization
> and remove for the target and then calls to the core driver.
>
> Signed-off-by: Romain Perier <romain.perier@gmail.com>
> ---
>  drivers/net/ethernet/arc/Kconfig     |  8 ++-
>  drivers/net/ethernet/arc/Makefile    |  3 +-
>  drivers/net/ethernet/arc/emac.h      |  4 ++
>  drivers/net/ethernet/arc/emac_arc.c  | 95 ++++++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/arc/emac_main.c | 80 +++++++++---------------------
>  5 files changed, 129 insertions(+), 61 deletions(-)
>  create mode 100644 drivers/net/ethernet/arc/emac_arc.c
>
> diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
> index 514c57f..e193826 100644
> --- a/drivers/net/ethernet/arc/Kconfig
> +++ b/drivers/net/ethernet/arc/Kconfig
> @@ -17,12 +17,16 @@ config NET_VENDOR_ARC
>
>  if NET_VENDOR_ARC
>
> -config ARC_EMAC
> -       tristate "ARC EMAC support"
> +config ARC_EMAC_CORE
> +       bool
>         select MII
>         select PHYLIB
>         depends on OF_IRQ
>         depends on OF_NET
> +
> +config ARC_EMAC
> +       tristate "ARC EMAC support"
> +       select ARC_EMAC_CORE
>         ---help---
>           On some legacy ARC (Synopsys) FPGA boards such as ARCAngel4/ML50x
>           non-standard on-chip ethernet device ARC EMAC 10/100 is used.
> diff --git a/drivers/net/ethernet/arc/Makefile b/drivers/net/ethernet/arc/Makefile
> index 00c8657..241bb80 100644
> --- a/drivers/net/ethernet/arc/Makefile
> +++ b/drivers/net/ethernet/arc/Makefile
> @@ -3,4 +3,5 @@
>  #
>
>  arc_emac-objs := emac_main.o emac_mdio.o
> -obj-$(CONFIG_ARC_EMAC) += arc_emac.o
> +obj-$(CONFIG_ARC_EMAC_CORE) += arc_emac.o
> +obj-$(CONFIG_ARC_EMAC) += emac_arc.o
> diff --git a/drivers/net/ethernet/arc/emac.h b/drivers/net/ethernet/arc/emac.h
> index 8011445..eb2ba67 100644
> --- a/drivers/net/ethernet/arc/emac.h
> +++ b/drivers/net/ethernet/arc/emac.h
> @@ -124,6 +124,8 @@ struct buffer_state {
>   */
>  struct arc_emac_priv {
>         /* Devices */
> +       const char *drv_name;
> +       const char *drv_version;
>         struct device *dev;
>         struct phy_device *phy_dev;
>         struct mii_bus *bus;
> @@ -206,5 +208,7 @@ static inline void arc_reg_clr(struct arc_emac_priv *priv, int reg, int mask)
>
>  int arc_mdio_probe(struct arc_emac_priv *priv);
>  int arc_mdio_remove(struct arc_emac_priv *priv);
> +int arc_emac_probe(struct net_device *ndev, int interface);
> +int arc_emac_remove(struct net_device *ndev);
>
>  #endif /* ARC_EMAC_H */
> diff --git a/drivers/net/ethernet/arc/emac_arc.c b/drivers/net/ethernet/arc/emac_arc.c
> new file mode 100644
> index 0000000..f9cb99b
> --- /dev/null
> +++ b/drivers/net/ethernet/arc/emac_arc.c
> @@ -0,0 +1,95 @@
> +/**
> + * emac_arc.c - ARC EMAC specific glue layer
> + *
> + * Copyright (C) 2014 Romain Perier
> + *
> + * Romain Perier  <romain.perier@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + */
> +
> +#include <linux/etherdevice.h>
> +#include <linux/module.h>
> +#include <linux/of_net.h>
> +#include <linux/platform_device.h>
> +
> +#include "emac.h"
> +
> +#define DRV_NAME    "emac_arc"
> +#define DRV_VERSION "1.0"
> +
> +static int emac_arc_probe(struct platform_device *pdev)
> +{
> +       struct device *dev = &pdev->dev;
> +       struct net_device *ndev;
> +       struct arc_emac_priv *priv;
> +       int interface, err;
> +
> +       if (!dev->of_node)
> +               return -ENODEV;
> +
> +       ndev = alloc_etherdev(sizeof(struct arc_emac_priv));
> +       if (!ndev)
> +               return -ENOMEM;
> +       platform_set_drvdata(pdev, ndev);
> +       SET_NETDEV_DEV(ndev, dev);
> +
> +       priv = netdev_priv(ndev);
> +       priv->drv_name = DRV_NAME;
> +       priv->drv_version = DRV_VERSION;
> +
> +       interface = of_get_phy_mode(dev->of_node);
> +       if (interface < 0)
> +               interface = PHY_INTERFACE_MODE_MII;
> +
> +       priv->clk = devm_clk_get(dev, "hclk");
> +       if (IS_ERR(priv->clk)) {
> +               dev_err(dev, "failed to retrieve host clock from device tree\n");
> +               err = -EINVAL;
> +               goto out_netdev;
> +       }
> +
> +       err = arc_emac_probe(ndev, interface);
> +out_netdev:
> +       if (err)
> +               free_netdev(ndev);
> +       return err;
> +}
> +
> +static int emac_arc_remove(struct platform_device *pdev)
> +{
> +       struct net_device *ndev = platform_get_drvdata(pdev);
> +       int err;
> +
> +       err = arc_emac_remove(ndev);
> +       free_netdev(ndev);
> +       return err;
> +}
> +
> +static const struct of_device_id emac_arc_dt_ids[] = {
> +       { .compatible = "snps,arc-emac" },
> +       { /* Sentinel */ }
> +};
> +
> +static struct platform_driver emac_arc_driver = {
> +       .probe = emac_arc_probe,
> +       .remove = emac_arc_remove,
> +       .driver = {
> +               .name = DRV_NAME,
> +               .of_match_table  = emac_arc_dt_ids,
> +       },
> +};
> +
> +module_platform_driver(emac_arc_driver);
> +
> +MODULE_AUTHOR("Romain Perier <romain.perier@gmail.com>");
> +MODULE_DESCRIPTION("ARC EMAC platform driver");
> +MODULE_LICENSE("GPL");
> diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
> index bbc3157..b35c69e 100644
> --- a/drivers/net/ethernet/arc/emac_main.c
> +++ b/drivers/net/ethernet/arc/emac_main.c
> @@ -26,8 +26,6 @@
>
>  #include "emac.h"
>
> -#define DRV_NAME       "arc_emac"
> -#define DRV_VERSION    "1.0"
>
>  /**
>   * arc_emac_adjust_link - Adjust the PHY link duplex.
> @@ -120,8 +118,10 @@ static int arc_emac_set_settings(struct net_device *ndev,
>  static void arc_emac_get_drvinfo(struct net_device *ndev,
>                                  struct ethtool_drvinfo *info)
>  {
> -       strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
> -       strlcpy(info->version, DRV_VERSION, sizeof(info->version));
> +       struct arc_emac_priv *priv = netdev_priv(ndev);
> +
> +       strlcpy(info->driver, priv->drv_name, sizeof(info->driver));
> +       strlcpy(info->version, priv->drv_version, sizeof(info->version));
>  }
>
>  static const struct ethtool_ops arc_emac_ethtool_ops = {
> @@ -671,19 +671,16 @@ static const struct net_device_ops arc_emac_netdev_ops = {
>  #endif
>  };
>
> -static int arc_emac_probe(struct platform_device *pdev)
> +int arc_emac_probe(struct net_device *ndev, int interface)
>  {
> -       struct device *dev = &pdev->dev;
> +       struct device *dev = ndev->dev.parent;
>         struct resource res_regs;
>         struct device_node *phy_node;
>         struct arc_emac_priv *priv;
> -       struct net_device *ndev;
>         const char *mac_addr;
>         unsigned int id, clock_frequency, irq;
>         int err;
>
> -       if (!dev->of_node)
> -               return -ENODEV;
>
>         /* Get PHY from device tree */
>         phy_node = of_parse_phandle(dev->of_node, "phy", 0);
> @@ -706,12 +703,6 @@ static int arc_emac_probe(struct platform_device *pdev)
>                 return -ENODEV;
>         }
>
> -       ndev = alloc_etherdev(sizeof(struct arc_emac_priv));
> -       if (!ndev)
> -               return -ENOMEM;
> -
> -       dev_set_drvdata(dev, ndev);
> -       SET_NETDEV_DEV(ndev, dev);
>
>         ndev->netdev_ops = &arc_emac_netdev_ops;
>         ndev->ethtool_ops = &arc_emac_ethtool_ops;
> @@ -724,28 +715,25 @@ static int arc_emac_probe(struct platform_device *pdev)
>
>         priv->regs = devm_ioremap_resource(dev, &res_regs);
>         if (IS_ERR(priv->regs)) {
> -               err = PTR_ERR(priv->regs);
> -               goto out_netdev;
> +               return PTR_ERR(priv->regs);
>         }
>         dev_dbg(dev, "Registers base address is 0x%p\n", priv->regs);
>
> -       priv->clk = of_clk_get(dev->of_node, 0);
> -       if (IS_ERR(priv->clk)) {
> -               /* Get CPU clock frequency from device tree */
> -               if (of_property_read_u32(dev->of_node, "clock-frequency",
> -                                       &clock_frequency)) {
> -                       dev_err(dev, "failed to retrieve <clock-frequency> from device tree\n");
> -                       err = -EINVAL;
> -                       goto out_netdev;
> -               }
> -       } else {
> +       if (priv->clk) {
>                 err = clk_prepare_enable(priv->clk);
>                 if (err) {
>                         dev_err(dev, "failed to enable clock\n");
> -                       goto out_clkget;
> +                       return err;
>                 }
>
>                 clock_frequency = clk_get_rate(priv->clk);
> +       } else {
> +               /* Get CPU clock frequency from device tree */
> +               if (of_property_read_u32(dev->of_node, "clock-frequency",
> +                                        &clock_frequency)) {
> +                       dev_err(dev, "failed to retrieve <clock-frequency> from device tree\n");
> +                       return -EINVAL;
> +               }
>         }
>
>         id = arc_reg_get(priv, R_ID);
> @@ -806,7 +794,7 @@ static int arc_emac_probe(struct platform_device *pdev)
>         }
>
>         priv->phy_dev = of_phy_connect(ndev, phy_node, arc_emac_adjust_link, 0,
> -                                      PHY_INTERFACE_MODE_MII);
> +                                      interface);
>         if (!priv->phy_dev) {
>                 dev_err(dev, "of_phy_connect() failed\n");
>                 err = -ENODEV;
> @@ -833,20 +821,15 @@ out_netif_api:
>  out_mdio:
>         arc_mdio_remove(priv);
>  out_clken:
> -       if (!IS_ERR(priv->clk))
> +       if (priv->clk)
>                 clk_disable_unprepare(priv->clk);
> -out_clkget:
> -       if (!IS_ERR(priv->clk))
> -               clk_put(priv->clk);
> -out_netdev:
> -       free_netdev(ndev);
>         return err;
>  }
> +EXPORT_SYMBOL_GPL(arc_emac_probe);
>
> -static int arc_emac_remove(struct platform_device *pdev)
> +int arc_emac_remove(struct net_device *ndev)
>  {
> -       struct device *dev = &pdev->dev;
> -       struct net_device *ndev = dev_get_drvdata(dev);
> +       struct device *dev = ndev->dev.parent;
>         struct arc_emac_priv *priv = netdev_priv(ndev);
>
>         phy_disconnect(priv->phy_dev);
> @@ -857,31 +840,12 @@ static int arc_emac_remove(struct platform_device *pdev)
>
>         if (!IS_ERR(priv->clk)) {
>                 clk_disable_unprepare(priv->clk);
> -               clk_put(priv->clk);
>         }
>
> -       free_netdev(ndev);
>
>         return 0;
>  }
> -
> -static const struct of_device_id arc_emac_dt_ids[] = {
> -       { .compatible = "snps,arc-emac" },
> -       { /* Sentinel */ }
> -};
> -MODULE_DEVICE_TABLE(of, arc_emac_dt_ids);
> -
> -static struct platform_driver arc_emac_driver = {
> -       .probe = arc_emac_probe,
> -       .remove = arc_emac_remove,
> -       .driver = {
> -               .name = DRV_NAME,
> -               .owner = THIS_MODULE,
> -               .of_match_table  = arc_emac_dt_ids,
> -               },
> -};
> -
> -module_platform_driver(arc_emac_driver);
> +EXPORT_SYMBOL_GPL(arc_emac_remove);
>
>  MODULE_AUTHOR("Alexey Brodkin <abrodkin@synopsys.com>");
>  MODULE_DESCRIPTION("ARC EMAC driver");
> --
> 1.9.1
>
