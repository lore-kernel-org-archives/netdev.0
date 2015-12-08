From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3 1/4] stmmac: create of compatible mdio bus for stmacc driver
Date: Tue, 08 Dec 2015 10:35:05 +0100
Message-ID: <2819989.unjINxCo2S@wuerfel>
References: <1449551582-6599-1-git-send-email-preid@electromag.com.au> <1449551582-6599-2-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, davem@davemloft.net,
	vbridger@opensource.altera.com, devicetree@vger.kernel.org,
	netdev@vger.kernel.org
To: Phil Reid <preid@electromag.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:58013 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756079AbbLHJfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 04:35:46 -0500
In-Reply-To: <1449551582-6599-2-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 08 December 2015 13:12:59 Phil Reid wrote:

> @@ -201,6 +201,25 @@ int stmmac_mdio_register(struct net_device *ndev)
>  	struct stmmac_mdio_bus_data *mdio_bus_data = priv->plat->mdio_bus_data;
>  	int addr, found;
>  
> +#ifdef CONFIG_OF
> +	struct device_node *mdio_node = NULL;
> +	struct device_node *child_node = NULL;
> +
> +	for_each_child_of_node(priv->device->of_node, child_node) {
> +		if (of_device_is_compatible(child_node, "snps,dwmac-mdio")) {
> +			mdio_node = child_node;
> +			break;
> +		}
> +	}

Can you use "if (IS_ENABLED(CONFIG_OF))" here instead of a preprocessor "#if"?

> @@ -231,7 +250,11 @@ int stmmac_mdio_register(struct net_device *ndev)
>  	new_bus->irq = irqlist;
>  	new_bus->phy_mask = mdio_bus_data->phy_mask;
>  	new_bus->parent = priv->device;
> +#ifdef CONFIG_OF
> +	err = of_mdiobus_register(new_bus, mdio_node);
> +#else
>  	err = mdiobus_register(new_bus);
> +#endif

This looks like it should be done in the header file. Can you make
a separate patch that changes the header file declaring of_mdiobus_register
to make it a static inline function calling mdiobus_register() if CONFIG_OF
is disabled?

	Arnd
