From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH v2] ethernet: arc: Add support for specific SoC glue
 layer device tree bindings
Date: Wed, 20 Aug 2014 09:50:50 +0200
Message-ID: <20140820075050.GA3614@distanz.ch>
References: <1408286882-10186-1-git-send-email-romain.perier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, heiko@sntech.de, b.galvani@gmail.com,
	eric.dumazet@gmail.com, yongjun_wei@trendmicro.com.cn,
	f.fainelli@gmail.com, netdev@vger.kernel.org
To: Romain Perier <romain.perier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:46636 "EHLO sym2.noone.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822AbaHTHux (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Aug 2014 03:50:53 -0400
Content-Disposition: inline
In-Reply-To: <1408286882-10186-1-git-send-email-romain.perier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014-08-17 at 16:48:02 +0200, Romain Perier <romain.perier@gmail.com> wrote:
> Some platforms have special bank registers which might be used to select
> the correct clock or the right mode for Media Indepent Interface controllers.
> Sometimes, it is also required to activate vcc regulators in the right order to supply
> the ethernet controller at the right time. This patch is a refactoring of the arc-emac
> device driver, it adds a new software architecture design which allows to add specific
> platform glue layer. Each platform has now its own module which performs custom initialization
> and remove for the target and then calls to the core driver.
> 
> Signed-off-by: Romain Perier <romain.perier@gmail.com>
> ---
>  drivers/net/ethernet/arc/Kconfig     |  13 ++--
>  drivers/net/ethernet/arc/Makefile    |   3 +-
>  drivers/net/ethernet/arc/emac.h      |  21 ++++-
>  drivers/net/ethernet/arc/emac_arc.c  |  77 +++++++++++++++++++
>  drivers/net/ethernet/arc/emac_main.c | 145 +++++++++++++++--------------------
>  drivers/net/ethernet/arc/emac_mdio.c |  11 ++-
>  6 files changed, 170 insertions(+), 100 deletions(-)
>  create mode 100644 drivers/net/ethernet/arc/emac_arc.c
[...]
> diff --git a/drivers/net/ethernet/arc/emac_arc.c b/drivers/net/ethernet/arc/emac_arc.c
> new file mode 100644
> index 0000000..be10943
> --- /dev/null
> +++ b/drivers/net/ethernet/arc/emac_arc.c
> @@ -0,0 +1,77 @@
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
> +#include "emac.h"

Private headers should come after global ones.

> +#include <linux/of_net.h>
> +#include <linux/platform_device.h>
> +#include <linux/module.h>
> +#include <linux/clk.h>
> +
> +#define DRV_NAME "emac_arc"
> +#define DRV_VERSION "1.0"
> +
> +static int emac_arc_probe(struct platform_device *pdev)
> +{
> +	struct arc_emac_platform_data *plat_data = NULL;
> +	struct device *dev = &pdev->dev;
> +
> +	plat_data = devm_kzalloc(dev, sizeof(*plat_data), GFP_KERNEL);
> +	if (!plat_data)
> +		return -ENOMEM;
> +	plat_data->name = DRV_NAME;
> +	plat_data->version = DRV_VERSION;
> +
> +	plat_data->interface = of_get_phy_mode(dev->of_node);
> +	if (plat_data->interface < 0)
> +		plat_data->interface = PHY_INTERFACE_MODE_MII;
> +
> +	plat_data->clk = devm_clk_get(dev, "hclk");
> +        if (IS_ERR(plat_data->clk)) {

Indentation looks strange here.

> +		dev_err(dev, "failed to retrieve host clock from device tree\n");
> +		return PTR_ERR_OR_ZERO(plat_data->clk);

You test for IS_ERR(plat_data->clk) above, so PTR_ERR() should be
sufficient here.

> +	}
> +
> +	return arc_emac_probe(dev, plat_data);
> +}
> +
> +static int emac_arc_remove(struct platform_device *pdev)
> +{
> +	struct net_device *ndev = dev_get_drvdata(&pdev->dev);
> +
> +	return arc_emac_remove(ndev);
> +}
> +
> +static const struct of_device_id emac_arc_dt_ids[] = {
> +	{ .compatible = "snps,arc-emac" },
> +	{ /* Sentinel */ }
> +};
> +
> +static struct platform_driver emac_arc_driver = {
> +	.probe = emac_arc_probe,
> +	.remove = emac_arc_remove,
> +	.driver = {
> +		.name = DRV_NAME,
> +		.of_match_table  = emac_arc_dt_ids,
> +	},
> +};
> +
> +module_platform_driver(emac_arc_driver);
> +
> +MODULE_AUTHOR("Romain Perier <romain.perier@gmail.com>");
> +MODULE_DESCRIPTION("ARC EMAC platform driver");
> +MODULE_LICENSE("GPL");

You already have these in emac_main.c (with different author), though
they are built together into the same module. Better merge them and only
specifiy them once.
