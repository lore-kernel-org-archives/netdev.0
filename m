From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv3 3/4] of: provide a binding for fixed link PHYs
Date: Tue, 4 Mar 2014 12:58:41 -0800
Message-ID: <CAGVrzcbHwxtgUfC4+u_3wszcmEYpz8Y7gu13xJy6TbT6fgR1sg@mail.gmail.com>
References: <1393930704-24374-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1393930704-24374-4-git-send-email-thomas.petazzoni@free-electrons.com>
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
	Christian Gmeiner <christian.gmeiner@gmail.com>,
	Grant Likely <grant.likely@linaro.org>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:63130 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757052AbaCDU73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 15:59:29 -0500
In-Reply-To: <1393930704-24374-4-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas,

2014-03-04 2:58 GMT-08:00 Thomas Petazzoni
<thomas.petazzoni@free-electrons.com>:
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

I have a better understanding of why Grant objected last time, and I
just found yet another argument which should hopefully be in favor of
this new binding.

One of the problems mentioned earlier about the 'fixed-link' 5-digit
property is that it is inflexible. It turns out that it seems to
capture everything we need, as nobody needed to extend it with a 6th
type for instance. This new binding allows for more flexibility and is
more human readable, which is a net bonus, though not a compelling
reason (yet).

Another problem with that "old" 'fixed-link' property is that we are
not properly capturing and representing Ethernet switches/PHYs whose
data-path are isolated from the control path. For instance such
devices will traditionally expose their control path as a
MMIO/GPIO/I2C/SPI interface. Using the 5-digit 'fixed-link' property
we are not representing this, on one side the Ethernet MAC is just
told to hardcode the link parameters with some parameters, and on
other side, any MMIO/GPIO/I2C/SPI device is not equipped with the
correct properties to express the fact that is also has a data-path
connected to an Ethernet MAC.

What I like about this new binding is that we could place the
'fixed-link' related properties in e.g: a SPI slave node, and have the
Ethernet MAC be pointed at it by a phandle to tell it: look this is
your PHY, it might not be one you could address on a MDIO bus, so I
have been providing additional properties to help you with the link
configuration.

One thing that needs to be addressed in this patch is how to deal with
the existing 5-digit fixed-link, something that sounds fairly easy and
which would not require changing the callers of of_phy_connect_fixed()
is to do the following:

- of_phy_is_fixed_link() needs to look for *all* required compatible
properties of the new binding to give an accurate verdict on the
nature of the PHY (to avoid false positives as mentioned in PATCH 4),
and it also needs to look for the 5-digit fixed-link property and
ensure the property is 5-digits long if existing

- of_phy_register_fixed_link() needs to also parse the old 5-digit
fixed-link property, most likely just copy-pasting what
arch/powerpc/sysdev/fsl_soc.c::of_add_fixed_phys does with the
property endian-swapping (as this code is for PowerPC)

Then we can deal with how to make that semi-automatic for the new
binding users to make it smoother to use a regular or "fixed PHY"
device.

>
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
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
> +
> +Example:
> +
> +ethernet@0 {
> +       ...
> +       phy = <&phy0>;
> +       phy0: phy@0 {
> +             fixed-link;
> +             speed = <1000>;
> +             full-duplex;
> +       };
> +       ...
> +};
> +
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index 875b7b6..c645fb8 100644
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
> @@ -274,3 +275,26 @@ struct phy_device *of_phy_attach(struct net_device *dev,
>         return phy_attach_direct(dev, phy, flags, iface) ? NULL : phy;
>  }
>  EXPORT_SYMBOL(of_phy_attach);
> +
> +#if defined(CONFIG_FIXED_PHY)
> +bool of_phy_is_fixed_link(struct device_node *np)
> +{
> +       return of_property_read_bool(np, "fixed-link");
> +}
> +EXPORT_SYMBOL(of_phy_is_fixed_link);
> +
> +int of_phy_register_fixed_link(struct device_node *np)
> +{
> +       struct fixed_phy_status status = {};
> +
> +       status.link = 1;
> +       status.duplex = of_property_read_bool(np, "full-duplex");
> +       if (of_property_read_u32(np, "speed", &status.speed))
> +               return -EINVAL;
> +       status.pause = of_property_read_bool(np, "pause");
> +       status.asym_pause = of_property_read_bool(np, "asym-pause");
> +
> +       return fixed_phy_register(PHY_POLL, &status, np);
> +}
> +EXPORT_SYMBOL(of_phy_register_fixed_link);
> +#endif
> diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
> index 6fe8464..77a6e32 100644
> --- a/include/linux/of_mdio.h
> +++ b/include/linux/of_mdio.h
> @@ -67,4 +67,19 @@ static inline struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np)
>  }
>  #endif /* CONFIG_OF */
>
> +#if defined(CONFIG_OF) && defined(CONFIG_FIXED_PHY)
> +extern int of_phy_register_fixed_link(struct device_node *np);
> +extern bool of_phy_is_fixed_link(struct device_node *np);
> +#else
> +static inline int of_phy_register_fixed_link(struct device_node *np)
> +{
> +       return -ENOSYS;
> +}
> +static inline bool of_phy_is_fixed_link(struct device_node *np)
> +{
> +       return false;
> +}
> +#endif
> +
> +
>  #endif /* __LINUX_OF_MDIO_H */
> --
> 1.8.3.2



-- 
Florian
