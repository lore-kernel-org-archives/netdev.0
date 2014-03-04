From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv3 2/4] net: phy: extend fixed driver with fixed_phy_register()
Date: Tue, 4 Mar 2014 10:44:38 -0800
Message-ID: <CAGVrzca7m0hwL-Wgv2eqO9_khpJP3ioZjbRNX7dOged-bq_C9Q@mail.gmail.com>
References: <1393930704-24374-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1393930704-24374-3-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:34169 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304AbaCDSpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 13:45:18 -0500
In-Reply-To: <1393930704-24374-3-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-04 2:58 GMT-08:00 Thomas Petazzoni
<thomas.petazzoni@free-electrons.com>:
> The existing fixed_phy_add() function has several drawbacks that
> prevents it from being used as is for OF-based declaration of fixed
> PHYs:
>
>  * The address of the PHY on the fake bus needs to be passed, while a
>    dynamic allocation is desired.
>
>  * Since the phy_device instantiation is post-poned until the next
>    mdiobus scan, there is no way to associate the fixed PHY with its
>    OF node, which later prevents of_phy_connect() from finding this
>    fixed PHY from a given OF node.
>
> To solve this, this commit introduces fixed_phy_register(), which will
> allocate an available PHY address, add the PHY using fixed_phy_add()
> and instantiate the phy_device structure associated with the provided
> OF node.

Besides the !CONFIG_FIXED_PHY hiccup (see below), this looks good to me:

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

>
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  drivers/net/phy/fixed.c   | 61 +++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/phy_fixed.h | 11 +++++++++
>  2 files changed, 72 insertions(+)
>
> diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
> index 0f02403..82095cc 100644
> --- a/drivers/net/phy/fixed.c
> +++ b/drivers/net/phy/fixed.c
> @@ -21,6 +21,7 @@
>  #include <linux/phy_fixed.h>
>  #include <linux/err.h>
>  #include <linux/slab.h>
> +#include <linux/of.h>
>
>  #define MII_REGS_NUM 29
>
> @@ -203,6 +204,66 @@ err_regs:
>  }
>  EXPORT_SYMBOL_GPL(fixed_phy_add);
>
> +void fixed_phy_del(int phy_addr)
> +{
> +       struct fixed_mdio_bus *fmb = &platform_fmb;
> +       struct fixed_phy *fp, *tmp;
> +
> +       list_for_each_entry_safe(fp, tmp, &fmb->phys, node) {
> +               if (fp->addr == phy_addr) {
> +                       list_del(&fp->node);
> +                       kfree(fp);
> +                       return;
> +               }
> +       }
> +}
> +EXPORT_SYMBOL_GPL(fixed_phy_del);
> +
> +static int phy_fixed_addr;
> +static DEFINE_SPINLOCK(phy_fixed_addr_lock);
> +
> +int fixed_phy_register(unsigned int irq,
> +                      struct fixed_phy_status *status,
> +                      struct device_node *np)
> +{
> +       struct fixed_mdio_bus *fmb = &platform_fmb;
> +       struct phy_device *phy;
> +       int phy_addr;
> +       int ret;
> +
> +       /* Get the next available PHY address, up to PHY_MAX_ADDR */
> +       spin_lock(&phy_fixed_addr_lock);
> +       if (phy_fixed_addr == PHY_MAX_ADDR) {
> +               spin_unlock(&phy_fixed_addr_lock);
> +               return -ENOSPC;
> +       }
> +       phy_addr = phy_fixed_addr++;
> +       spin_unlock(&phy_fixed_addr_lock);
> +
> +       ret = fixed_phy_add(PHY_POLL, phy_addr, status);
> +       if (ret < 0)
> +               return ret;
> +
> +       phy = get_phy_device(fmb->mii_bus, phy_addr, false);
> +       if (!phy || IS_ERR(phy)) {
> +               fixed_phy_del(phy_addr);
> +               return -EINVAL;
> +       }
> +
> +       of_node_get(np);
> +       phy->dev.of_node = np;
> +
> +       ret = phy_device_register(phy);
> +       if (ret) {
> +               phy_device_free(phy);
> +               of_node_put(np);
> +               fixed_phy_del(phy_addr);
> +               return ret;
> +       }
> +
> +       return 0;
> +}
> +
>  static int __init fixed_mdio_bus_init(void)
>  {
>         struct fixed_mdio_bus *fmb = &platform_fmb;
> diff --git a/include/linux/phy_fixed.h b/include/linux/phy_fixed.h
> index 509d8f5..902e8a1 100644
> --- a/include/linux/phy_fixed.h
> +++ b/include/linux/phy_fixed.h
> @@ -9,15 +9,26 @@ struct fixed_phy_status {
>         int asym_pause;
>  };
>
> +struct device_node;
> +
>  #ifdef CONFIG_FIXED_PHY
>  extern int fixed_phy_add(unsigned int irq, int phy_id,
>                          struct fixed_phy_status *status);
> +extern int fixed_phy_register(unsigned int irq,
> +                             struct fixed_phy_status *status,
> +                             struct device_node *np);
>  #else
>  static inline int fixed_phy_add(unsigned int irq, int phy_id,
>                                 struct fixed_phy_status *status)
>  {
>         return -ENODEV;
>  }
> +extern int fixed_phy_register(unsigned int irq,
> +                             struct fixed_phy_status *status,
> +                             struct device_node *np)
> +{
> +       return -ENODEV;
> +}

s/extern/static/ otherwise I doubt this builds correctly.
-- 
Florian
