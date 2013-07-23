From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 1/3] of: provide a binding for the 'fixed-link'
 property
Date: Tue, 23 Jul 2013 12:22:59 +0100
Message-ID: <20130723112259.GE4833@e106331-lin.cambridge.arm.com>
References: <1373902450-11857-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1373902450-11857-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Likely <grant.likely@secretlab.ca>,
	"rob.herring@calxeda.com" <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:39742 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756174Ab3GWLX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 07:23:56 -0400
Content-Disposition: inline
In-Reply-To: <1373902450-11857-2-git-send-email-thomas.petazzoni@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

On Mon, Jul 15, 2013 at 04:34:08PM +0100, Thomas Petazzoni wrote:
> Some Ethernet MACs have a "fixed link", and are not connected to a
> normal MDIO-managed PHY device. For those situations, a Device Tree
> binding allows to describe a "fixed link", as a "fixed-link" property
> of the Ethernet device Device Tree node.
> 
> This patch adds:
> 
>  * A documentation for the Device Tree property "fixed-link".
> 
>  * A of_phy_register_fixed_link() OF helper, which provided an OF node
>    that contains a "fixed-link" property, registers the corresponding
>    fixed PHY.
> 
>  * Removes the warning on the of_phy_connect_fixed_link() that says
>    new drivers should not use it, since Grant Likely indicated that
>    this "fixed-link" property is indeed the way to go.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  .../devicetree/bindings/net/fixed-link.txt         | 26 ++++++++++++++++
>  drivers/of/of_mdio.c                               | 36 +++++++++++++++++++---
>  include/linux/of_mdio.h                            | 10 ++++++
>  3 files changed, 68 insertions(+), 4 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/fixed-link.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
> new file mode 100644
> index 0000000..25a009a
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/fixed-link.txt
> @@ -0,0 +1,26 @@
> +Fixed link Device Tree binding
> +------------------------------
> +
> +Some Ethernet MACs have a "fixed link", and are not connected to a
> +normal MDIO-managed PHY device. For those situations, a Device Tree
> +binding allows to describe a "fixed link".

Are partictular MACs fixed link, or can some either be either fixed link
or wired to an MDIO-managed PHY? i.e. can we assume a given MAC is
fixed-link from its compatible string?

> +
> +Such a fixed link situation is described within an Ethernet device
> +Device Tree node using a 'fixed-link' property, composed of 5
> +elements:

I'm not sure grouping these values together is the best way of handling
this. It's rather opaque, and inflexible for future extension.

> +
> + 1. A fake PHY ID, which must be unique accross all fixed-link PHYs in
> +    the system.

Is there any reason this couldn't be allocated dynamically within the
kernel as needed? I don't see why an arbitrary unique value should be a
dt binding requirement; it seems like a leak of Linux implementation
details.

> + 2. The duplex (1 for full-duplex, 0 for half-duplex)

Will this change for a given MAC?

Could we not have a boolean property for each of these, and require one
to be present?

Possibly fixed-link-full-duplex / fix-link-half-duplex?

> + 3. The speed (10, 100, 1000)

fixed-link-speed?

> + 4. The pause setting (1 for enabled, 0 for disabled)
> + 5. The asym pause setting (1 for enabled, 0 for disabled)

Boolean properties for both of these?

Thanks,
Mark.

> +
> +Example:
> +
> +ethernet@0 {
> +	...
> +	fixed-link = <1 1 1000 0 0>;
> +	...
> +};
> +
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index d5a57a9..66d5591 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -14,6 +14,7 @@
>  #include <linux/netdevice.h>
>  #include <linux/err.h>
>  #include <linux/phy.h>
> +#include <linux/phy_fixed.h>
>  #include <linux/of.h>
>  #include <linux/of_irq.h>
>  #include <linux/of_mdio.h>
> @@ -215,10 +216,6 @@ EXPORT_SYMBOL(of_phy_connect);
>   * @dev: pointer to net_device claiming the phy
>   * @hndlr: Link state callback for the network device
>   * @iface: PHY data interface type
> - *
> - * This function is a temporary stop-gap and will be removed soon.  It is
> - * only to support the fs_enet, ucc_geth and gianfar Ethernet drivers.  Do
> - * not call this function from new drivers.
>   */
>  struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
>  					     void (*hndlr)(struct net_device *),
> @@ -247,3 +244,34 @@ struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
>  	return IS_ERR(phy) ? NULL : phy;
>  }
>  EXPORT_SYMBOL(of_phy_connect_fixed_link);
> +
> +#if defined(CONFIG_FIXED_PHY)
> +/**
> + * of_phy_register_fixed_link - Parse fixed-link property and register a dummy phy
> + * @np: pointer to the OF device node that contains the "fixed-link"
> + * property for which a dummy phy should be registered.
> + */
> +#define FIXED_LINK_PROPERTIES_COUNT 5
> +int of_phy_register_fixed_link(struct device_node *np)
> +{
> +	struct fixed_phy_status status = {};
> +	u32 fixed_link_props[FIXED_LINK_PROPERTIES_COUNT];
> +	int ret;
> +
> +	ret = of_property_read_u32_array(np, "fixed-link",
> +					 fixed_link_props,
> +					 FIXED_LINK_PROPERTIES_COUNT);
> +	if (ret < 0)
> +		return ret;
> +
> +	status.link       = 1;
> +	status.duplex     = fixed_link_props[1];
> +	status.speed      = fixed_link_props[2];
> +	status.pause      = fixed_link_props[3];
> +	status.asym_pause = fixed_link_props[4];
> +
> +	return fixed_phy_add(PHY_POLL, fixed_link_props[0],
> +			     &status);
> +}
> +EXPORT_SYMBOL(of_phy_register_fixed_link);
> +#endif
> diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
> index 8163107..bf6efea 100644
> --- a/include/linux/of_mdio.h
> +++ b/include/linux/of_mdio.h
> @@ -57,4 +57,14 @@ static inline struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
>  }
>  #endif /* CONFIG_OF */
>  
> +#if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
> +extern int of_phy_register_fixed_link(struct device_node *np);
> +#else
> +static inline int of_phy_register_fixed_link(struct device_node *np)
> +{
> +	return -ENOSYS;
> +}
> +#endif
> +
> +
>  #endif /* __LINUX_OF_MDIO_H */
> -- 
> 1.8.1.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
