From: Kumar Gala <galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH 2/3] netdev/of/phy: Add MDIO bus multiplexer support.
Date: Wed, 14 Sep 2011 15:42:21 -0500
Message-ID: <678076BE-4CF8-4AC9-BE9B-9AF1A17B7AF8@kernel.crashing.org>
References: <1314820906-14004-1-git-send-email-david.daney@cavium.com>
	<1314820906-14004-3-git-send-email-david.daney@cavium.com>
	<129FAAB3-C9AD-43F6-A8CB-96548A47C4DC@kernel.crashing.org>
	<4E6FE5F9.2060604@cavium.com>
Mime-Version: 1.0 (Apple Message framework v1244.3)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <4E6FE5F9.2060604-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
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


On Sep 13, 2011, at 6:23 PM, David Daney wrote:

> On 09/13/2011 04:07 PM, Kumar Gala wrote:
>> 
>>> diff --git a/Documentation/devicetree/bindings/net/mdio-mux.txt b/Documentation/devicetree/bindings/net/mdio-mux.txt
>>> new file mode 100644
>>> index 0000000..a908312
>>> --- /dev/null
>>> +++ b/Documentation/devicetree/bindings/net/mdio-mux.txt
>>> @@ -0,0 +1,132 @@
>>> +Common MDIO bus multiplexer/switch properties.
>>> +
>>> +An MDIO bus multiplexer/switch will have several child busses that are
>>> +numbered uniquely in a device dependent manner.  The nodes for an MDIO
>>> +bus multiplexer/switch will have one child node for each child bus.
>>> +
>>> +Required properties:
>>> +- parent-bus : phandle to the parent MDIO bus.
>> 
>> Should probably be mdio-parent-bus
> 
> Why?  We know it is MDIO.
> 
> Serial bus multiplexing is not a concept limited to MDIO.  We would want to use "parent-bus" for some I2C multiplexers as well.

>From many years of dealing with device trees.  We typically don't name things overlay generically unless they will be used over and over again as a common idiom (like reg, interrupt, etc.).

We don't really use 'bus' generically today.

> 
>> 
>>> +
>>> +Optional properties:
>>> +- Other properties specific to the multiplexer/switch hardware.
>>> +
>>> +Required properties for child nodes:
>>> +- #address-cells =<1>;
>>> +- #size-cells =<0>;
>>> +- cell-index : The sub-bus number.
>> 
>> What does sub-bus number mean?
> 
> There are N child buses (or sub-buses) coming out of the multiplexer. The cell-index is used as a handle or identifier for each of these.
> 
> The concrete example in Patch 3/3 is a multiplexer with four child buses.  The happen to have cell-indexes of 0, 1, 2 and 3.
> 
> In the GPIO case of patch 3/3, these directly correspond the the state of the two GPIO pins controlling the multiplexer.  The driver then uses the cell-index property to determine the state of the GPIO to connect any given child.
> 
> It is possible that the documentation part of the patch could be made more clear about this.
> 
>> 
>>> +
>>> +
>>> +Example :
>> 
> [...]
>>> +
>>> +int mdio_mux_probe(struct platform_device *pdev,
>>> +		   int (*switch_fn)(int cur, int desired, void *data),
>>> +		   void *data)
>>> +{
>>> +	struct device_node *parent_bus_node;
>>> +	struct device_node *child_bus_node;
>>> +	int r, n, ret_val;
>>> +	struct mii_bus *parent_bus;
>>> +	struct mdio_mux_parent_bus *pb;
>>> +	struct mdio_mux_child_bus *cb;
>>> +
>>> +	if (!pdev->dev.of_node)
>>> +		return -ENODEV;
>>> +
>>> +	parent_bus_node = of_parse_phandle(pdev->dev.of_node, "parent-bus", 0);
>>> +
>>> +	if (!parent_bus_node)
>>> +		return -ENODEV;
>>> +
>>> +	parent_bus = of_mdio_find_bus(parent_bus_node);
>> 
>> 
>> So what happens if the parent bus probe happens after the mux probe?
>> 
> 
> The whole house of cards collapses.
> 
> Grant Likely has a patch to deal with this by retrying the probing,  but as far as I know, it has not been merged yet.

- k
