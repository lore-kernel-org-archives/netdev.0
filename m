From: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
Subject: Re: [RFC PATCHv2 3/4] of: provide a binding for fixed link PHYs
Date: Tue, 17 Sep 2013 23:29:23 -0500
Message-ID: <20130918042923.5D845C42CF7@trevor.secretlab.ca>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com> <1378480701-12908-4-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Lior Amsalem <alior-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Christian Gmeiner <christian.gmeiner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ezequiel Garcia <ezequiel.garcia-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1378480701-12908-4-git-send-email-thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri,  6 Sep 2013 17:18:20 +0200, Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:
> Some Ethernet MACs have a "fixed link", and are not connected to a
> normal MDIO-managed PHY device. For those situations, a Device Tree
> binding allows to describe a "fixed link" using a special PHY node.
> 
> This patch adds:
> 
>  * A documentation for the fixed PHY Device Tree binding.
> 
>  * An of_phy_is_fixed_link() function that an Ethernet driver can call
>    on its PHY phandle to find out whether it's a fixed link PHY or
>    not. It should typically be used to know if
>    of_phy_register_fixed_link() should be called.
> 
>  * An of_phy_register_fixed_link() function that instantiates the
>    fixed PHY into the PHY subsystem, so that when the driver calls
>    of_phy_connect(), the PHY device associated to the OF node will be
>    found.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>

Hi Thomas,

The implemenation in this series looks like it is in good shape, so I'll
restrict my comments to be binding...

> ---
>  .../devicetree/bindings/net/fixed-link.txt         | 34 ++++++++++++++++++++++
>  drivers/of/of_mdio.c                               | 24 +++++++++++++++
>  include/linux/of_mdio.h                            | 15 ++++++++++
>  3 files changed, 73 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/fixed-link.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/fixed-link.txt b/Documentation/devicetree/bindings/net/fixed-link.txt
> new file mode 100644
> index 0000000..9f2a1a50
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/fixed-link.txt
> @@ -0,0 +1,34 @@
> +Fixed link Device Tree binding
> +------------------------------
> +
> +Some Ethernet MACs have a "fixed link", and are not connected to a
> +normal MDIO-managed PHY device. For those situations, a Device Tree
> +binding allows to describe a "fixed link".
> +
> +Such a fixed link situation is described by creating a PHY node as a
> +sub-node of an Ethernet device, with the following properties:
> +
> +* 'fixed-link' (boolean, mandatory), to indicate that this PHY is a
> +  fixed link PHY.
> +* 'speed' (integer, mandatory), to indicate the link speed. Accepted
> +  values are 10, 100 and 1000
> +* 'full-duplex' (boolean, optional), to indicate that full duplex is
> +  used. When absent, half duplex is assumed.
> +* 'pause' (boolean, optional), to indicate that pause should be
> +  enabled.
> +* 'asym-pause' (boolean, optional), to indicate that asym_pause should
> +  be enabled.

I understand what you're trying to do here, but it causes a troublesome
leakage of implementation detail into the binding, making the whole
thing look very odd. This binding tries to make a fixed link look
exactly like a real PHY even to the point of including a phandle to the
phy. But having a phandle to a node which is *always* a direct child of
the MAC node is redundant and a rather looney. Yes, doing it that way
makes it easy for of_phy_find_device() to be transparent for fixed link,
but that should *not* drive bindings, especially when that makes the
binding really rather weird.

Second, this new binding doesn't provide anything over and above the
existing fixed-link binding. It may not be pretty, but it is
estabilshed.

That said, I do agree that the current Linux implementation is not good
because it cannot handle a fixed-link property transparently. That's a
deficiency in the Linux implementation and it should be fixed.
of_phy_connect() currently requires the phy phandle to be passed in.
Part of the reason it was done this way is that some drivers connect to
multiple 'phys'. A soulition could be to make the phy handle optional.
If it is empty then go looking for either a phy-device or fixed-link
property. Otherwise use the provided node.

g.

> +
> +Example:
> +
> +ethernet@0 {
> +	...
> +	phy = <&phy0>;
> +	phy0: phy@0 {
> +	      fixed-link;
> +	      speed = <1000>;
> +	      full-duplex;
> +	};
> +	...
> +};
> +
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index d5a57a9..0507f8f 100644
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
> @@ -247,3 +248,26 @@ struct phy_device *of_phy_connect_fixed_link(struct net_device *dev,
>  	return IS_ERR(phy) ? NULL : phy;
>  }
>  EXPORT_SYMBOL(of_phy_connect_fixed_link);
> +
> +#if defined(CONFIG_FIXED_PHY)
> +bool of_phy_is_fixed_link(struct device_node *np)
> +{
> +	return of_property_read_bool(np, "fixed-link");
> +}
> +EXPORT_SYMBOL(of_phy_is_fixed_link);
> +
> +int of_phy_register_fixed_link(struct device_node *np)
> +{
> +	struct fixed_phy_status status = {};
> +
> +	status.link = 1;
> +	status.duplex = of_property_read_bool(np, "full-duplex");
> +	if (of_property_read_u32(np, "speed", &status.speed))
> +		return -EINVAL;
> +	status.pause = of_property_read_bool(np, "pause");
> +	status.asym_pause = of_property_read_bool(np, "asym-pause");
> +
> +	return fixed_phy_register(PHY_POLL, &status, np);
> +}
> +EXPORT_SYMBOL(of_phy_register_fixed_link);
> +#endif
> diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
> index 8163107..2f535ee 100644
> --- a/include/linux/of_mdio.h
> +++ b/include/linux/of_mdio.h
> @@ -57,4 +57,19 @@ static inline struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
>  }
>  #endif /* CONFIG_OF */
>  
> +#if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
> +extern int of_phy_register_fixed_link(struct device_node *np);
> +extern bool of_phy_is_fixed_link(struct device_node *np);
> +#else
> +static inline int of_phy_register_fixed_link(struct device_node *np)
> +{
> +	return -ENOSYS;
> +}
> +static inline bool of_phy_is_fixed_link(struct device_node *np)
> +{
> +	return false;
> +}
> +#endif
> +
> +
>  #endif /* __LINUX_OF_MDIO_H */
> -- 
> 1.8.1.2
> 
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
