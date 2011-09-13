From: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 2/3] netdev/of/phy: Add MDIO bus multiplexer support.
Date: Tue, 13 Sep 2011 18:07:09 -0500
Message-ID: <129FAAB3-C9AD-43F6-A8CB-96548A47C4DC@kernel.crashing.org>
References: <1314820906-14004-1-git-send-email-david.daney@cavium.com>
	<1314820906-14004-3-git-send-email-david.daney@cavium.com>
Mime-Version: 1.0 (Apple Message framework v1244.3)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1314820906-14004-3-git-send-email-david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org


> diff --git a/Documentation/devicetree/bindings/net/mdio-mux.txt b/Documentation/devicetree/bindings/net/mdio-mux.txt
> new file mode 100644
> index 0000000..a908312
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/mdio-mux.txt
> @@ -0,0 +1,132 @@
> +Common MDIO bus multiplexer/switch properties.
> +
> +An MDIO bus multiplexer/switch will have several child busses that are
> +numbered uniquely in a device dependent manner.  The nodes for an MDIO
> +bus multiplexer/switch will have one child node for each child bus.
> +
> +Required properties:
> +- parent-bus : phandle to the parent MDIO bus.

Should probably be mdio-parent-bus

> +
> +Optional properties:
> +- Other properties specific to the multiplexer/switch hardware.
> +
> +Required properties for child nodes:
> +- #address-cells = <1>;
> +- #size-cells = <0>;
> +- cell-index : The sub-bus number.

What does sub-bus number mean?

> +
> +
> +Example :

[snip]

> diff --git a/drivers/net/phy/mdio-mux.c b/drivers/net/phy/mdio-mux.c
> new file mode 100644
> index 0000000..f9c5826
> --- /dev/null
> +++ b/drivers/net/phy/mdio-mux.c
> @@ -0,0 +1,182 @@
> +/*
> + * This file is subject to the terms and conditions of the GNU General Public
> + * License.  See the file "COPYING" in the main directory of this archive
> + * for more details.
> + *
> + * Copyright (C) 2011 Cavium Networks
> + */
> +
> +#include <linux/platform_device.h>
> +#include <linux/of_mdio.h>
> +#include <linux/module.h>
> +#include <linux/init.h>
> +#include <linux/gfp.h>
> +#include <linux/phy.h>
> +#include <linux/mdio-mux.h>
> +
> +#define DRV_VERSION "1.0"
> +#define DRV_DESCRIPTION "MDIO bus multiplexer driver"
> +
> +struct mdio_mux_parent_bus {
> +	struct mii_bus *mii_bus;
> +	int current_child;
> +	int parent_id;
> +	void *switch_data;
> +	int (*switch_fn)(int current_child, int desired_child, void *data);
> +};
> +
> +struct mdio_mux_child_bus {
> +	struct mii_bus *mii_bus;
> +	struct mdio_mux_parent_bus *parent;
> +	int bus_number;
> +	int phy_irq[PHY_MAX_ADDR];
> +};
> +
> +/*
> + * The parent bus' lock is used to order access to the switch_fn.
> + */
> +static int mdio_mux_read(struct mii_bus *bus, int phy_id, int regnum)
> +{
> +	struct mdio_mux_child_bus *cb = bus->priv;
> +	struct mdio_mux_parent_bus *pb = cb->parent;
> +	int r;
> +
> +	mutex_lock(&pb->mii_bus->mdio_lock);
> +	r = pb->switch_fn(pb->current_child, cb->bus_number, pb->switch_data);
> +	if (r)
> +		goto out;
> +
> +	pb->current_child = cb->bus_number;
> +
> +	r = pb->mii_bus->read(pb->mii_bus, phy_id, regnum);
> +out:
> +	mutex_unlock(&pb->mii_bus->mdio_lock);
> +
> +	return r;
> +}
> +
> +/*
> + * The parent bus' lock is used to order access to the switch_fn.
> + */
> +static int mdio_mux_write(struct mii_bus *bus, int phy_id,
> +			  int regnum, u16 val)
> +{
> +	struct mdio_mux_child_bus *cb = bus->priv;
> +	struct mdio_mux_parent_bus *pb = cb->parent;
> +
> +	int r;
> +
> +	mutex_lock(&pb->mii_bus->mdio_lock);
> +	r = pb->switch_fn(pb->current_child, cb->bus_number, pb->switch_data);
> +	if (r)
> +		goto out;
> +
> +	pb->current_child = cb->bus_number;
> +
> +	r = pb->mii_bus->write(pb->mii_bus, phy_id, regnum, val);
> +out:
> +	mutex_unlock(&pb->mii_bus->mdio_lock);
> +
> +	return r;
> +}
> +
> +static int parent_count;
> +
> +int mdio_mux_probe(struct platform_device *pdev,
> +		   int (*switch_fn)(int cur, int desired, void *data),
> +		   void *data)
> +{
> +	struct device_node *parent_bus_node;
> +	struct device_node *child_bus_node;
> +	int r, n, ret_val;
> +	struct mii_bus *parent_bus;
> +	struct mdio_mux_parent_bus *pb;
> +	struct mdio_mux_child_bus *cb;
> +
> +	if (!pdev->dev.of_node)
> +		return -ENODEV;
> +
> +	parent_bus_node = of_parse_phandle(pdev->dev.of_node, "parent-bus", 0);
> +
> +	if (!parent_bus_node)
> +		return -ENODEV;
> +
> +	parent_bus = of_mdio_find_bus(parent_bus_node);


So what happens if the parent bus probe happens after the mux probe?

> +
> +	pb = devm_kzalloc(&pdev->dev, sizeof(*pb), GFP_KERNEL);
> +	if (pb == NULL) {
> +		ret_val = -ENOMEM;
> +		goto err_parent_bus;
> +	}
> +
> +	pb->switch_data = data;
> +	pb->switch_fn = switch_fn;
> +	pb->current_child = -1;
> +	pb->parent_id = parent_count++;
> +	pb->mii_bus = parent_bus;
> +
> +	n = 0;
> +	for_each_child_of_node(pdev->dev.of_node, child_bus_node) {
> +		u32 v;
> +
> +		r = of_property_read_u32(child_bus_node, "cell-index", &v);
> +		if (r == 0) {
> +			cb = devm_kzalloc(&pdev->dev, sizeof(*cb), GFP_KERNEL);
> +			if (cb == NULL)
> +				break;
> +			cb->bus_number = v;
> +			cb->parent = pb;
> +			cb->mii_bus = mdiobus_alloc();
> +			cb->mii_bus->priv = cb;
> +
> +			cb->mii_bus->irq = cb->phy_irq;
> +			cb->mii_bus->name = "mdio_mux";
> +			snprintf(cb->mii_bus->id, MII_BUS_ID_SIZE, "%x.%x",
> +				 pb->parent_id, v);
> +			cb->mii_bus->parent = &pdev->dev;
> +			cb->mii_bus->read = mdio_mux_read;
> +			cb->mii_bus->write = mdio_mux_write;
> +			r = of_mdiobus_register(cb->mii_bus, child_bus_node);
> +			if (r) {
> +				of_node_put(child_bus_node);
> +				devm_kfree(&pdev->dev, cb);
> +			} else {
> +				n++;
> +			}
> +
> +		} else {
> +			of_node_put(child_bus_node);
> +		}
> +	}
> +	if (n) {
> +		dev_info(&pdev->dev, "Version " DRV_VERSION "\n");
> +		return 0;
> +	}
> +	ret_val = -ENOMEM;
> +	devm_kfree(&pdev->dev, pb);
> +err_parent_bus:
> +	of_node_put(parent_bus_node);
> +	return ret_val;
> +}
> +EXPORT_SYMBOL(mdio_mux_probe);
> +
> +static int __devexit mdio_mux_remove(struct platform_device *pdev)
> +{
> +	return 0;
> +}
> +
> +static int __init mdio_mux_mod_init(void)
> +{
> +	return 0;
> +}
> +module_init(mdio_mux_mod_init);
> +
> +static void __exit mdio_mux_mod_exit(void)
> +{
> +}
> +module_exit(mdio_mux_mod_exit);
> +
> +MODULE_DESCRIPTION(DRV_DESCRIPTION);
> +MODULE_VERSION(DRV_VERSION);
> +MODULE_AUTHOR("David Daney");
> +MODULE_LICENSE("GPL");
