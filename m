From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net-next] net: bcmgenet: enable driver to work without
 a device tree
Date: Mon, 01 Dec 2014 15:23:38 -0800
Message-ID: <547CF87A.3010605@gmail.com>
References: <20141201220828.942A7220726@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Kevin Cernekee <cernekee@gmail.com>
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:43024 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932690AbaLAXXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2014 18:23:45 -0500
Received: by mail-pd0-f175.google.com with SMTP id y10so11893040pdj.20
        for <netdev@vger.kernel.org>; Mon, 01 Dec 2014 15:23:45 -0800 (PST)
In-Reply-To: <20141201220828.942A7220726@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/14 14:08, Petri Gynther wrote:
> Broadcom 7xxx MIPS-based STB platforms do not use device trees.
> Modify bcmgenet driver so that it can be used on those platforms.

Well, that statement is technically not true anymore thanks to Kevin's
recent efforts, but this is not exactly what we have been
advertising/supporting so far.

Looks mostly good to me, some minor nits below:

> 
> Signed-off-by: Petri Gynther <pgynther@google.com>
> ---
[snip]
> +	if (dn) {
> +		of_id = of_match_node(bcmgenet_match, dn);
> +		if (!of_id)
> +			return -EINVAL;
> +	} else {
> +		of_id = NULL;
> +	}

You could probably get way with this else condition by assigning of_id
to NULL by default.

[snip]

> +		if (pd->phy_addr >= 0 && pd->phy_addr < PHY_MAX_ADDR) {
> +			phydev = mdio->phy_map[pd->phy_addr];
> +		} else {
> +			phydev = NULL;
> +			for (i = 0; i < PHY_MAX_ADDR; i++) {
> +				if (mdio->phy_map[i]) {
> +					phydev = mdio->phy_map[i];
> +					break;
> +				}
> +			}

phy_find_first() might provide a shorter version of this.

> +		}
> +
> +		if (!phydev) {
> +			dev_err(kdev, "failed to register PHY device\n");
> +			mdiobus_unregister(mdio);
> +			return -ENODEV;
> +		}
> +	} else {
> +		/*
> +		 * MoCA port or no MDIO access.
> +		 * Use 1000/FD fixed PHY to represent the link layer.
> +		 */
> +		struct fixed_phy_status fphy_status = {
> +			.link = 1,
> +			.duplex = DUPLEX_FULL,
> +			.speed = SPEED_1000,
> +			.pause = 0,
> +			.asym_pause = 0,
> +		};
> +
> +		phydev = fixed_phy_register(PHY_POLL, &fphy_status, NULL);
> +		if (!phydev || IS_ERR(phydev)) {
> +			dev_err(kdev, "failed to register fixed PHY device\n");
> +			return -ENODEV;
> +		}

This is typically done by platform code (not necessarily for good
reasons though) but I cannot seen any problems with doing this here as well.

[snip]

> diff --git a/include/linux/platform_data/bcmgenet.h b/include/linux/platform_data/bcmgenet.h
> new file mode 100644
> index 0000000..3660133
> --- /dev/null
> +++ b/include/linux/platform_data/bcmgenet.h
> @@ -0,0 +1,18 @@
> +#ifndef __LINUX_PLATFORM_DATA_BCMGENET_H__
> +#define __LINUX_PLATFORM_DATA_BCMGENET_H__
> +
> +#include <linux/compiler.h>

That include does not look necessary, you might want linux/types.h for
"u8" though.

> +#include <linux/if_ether.h>
> +
> +struct bcmgenet_platform_data {
> +	void __iomem *base_reg;
> +	int           irq0;
> +	int           irq1;

These 3 members are unused and should be communicated to the driver as
resources, not side parameters, can you get rid of them?

> +	bool          mdio_enabled;
> +	int           phy_type;

This is essentially phy_interface_t, so let's use that type directly here.

> +	int           phy_addr;
> +	u8            macaddr[ETH_ALEN];
> +	int           genet_version;

That is also an enum, if that helps, you could move it from
drivers/net/ethernet/broadcom/bcmgenet.h there as well.
--
Florian
