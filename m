From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH v5 1/4] stmmac: create of compatible mdio bus for stmacc
 driver
Date: Fri, 11 Dec 2015 10:13:07 +0100
Message-ID: <566A93A3.9010004@st.com>
References: <1449650381-82074-1-git-send-email-preid@electromag.com.au> <1449650381-82074-2-git-send-email-preid@electromag.com.au> <5669B372.5070207@st.com> <566A2A94.9090000@electromag.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Phil Reid <preid@electromag.com.au>, <robh+dt@kernel.org>,
	<pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<davem@davemloft.net>, <vbridger@opensource.altera.com>,
	<devicetree@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:50656 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754063AbbLKJOM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 04:14:12 -0500
In-Reply-To: <566A2A94.9090000@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Phil

On 12/11/2015 2:44 AM, Phil Reid wrote:
> G'day Giuseppe,
>
> On 11/12/2015 1:16 AM, Giuseppe CAVALLARO wrote:
>> Hi
>>
>> also pls fix this typo
>>
>> stmmac: create of compatible mdio bus for stmacc driver
>>                                           ^^^^^^^^
>>                                            stmmac
> Will do.
>>
>> On 12/9/2015 9:39 AM, Phil Reid wrote:
>>> The DSA driver needs to be passed a reference to an mdio bus. Typically
>>> the mac is configured to use a fixed link but the mdio bus still needs
>>> to be registered so that it con configure the switch.
>>> This patch follows the same process as the altera tse ethernet driver
>>> for
>>> creation of the mdio bus.
>>>
>>> Acked-by: Rob Herring <robh@kernel.org>
>>> Signed-off-by: Phil Reid <preid@electromag.com.au>
>>> ---
>>>   Documentation/devicetree/bindings/net/stmmac.txt   |  8 ++++++
>>>   drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  | 31
>>> +++++++++++++++-------
>>>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  2 +-
>>>   3 files changed, 31 insertions(+), 10 deletions(-)
>>>
>>> diff --git a/Documentation/devicetree/bindings/net/stmmac.txt
>>> b/Documentation/devicetree/bindings/net/stmmac.txt
>>> index f34fc3c..fd5ddf8 100644
>>> --- a/Documentation/devicetree/bindings/net/stmmac.txt
>>> +++ b/Documentation/devicetree/bindings/net/stmmac.txt
>>> @@ -47,6 +47,7 @@ Optional properties:
>>>   - snps,burst_len: The AXI burst lenth value of the AXI BUS MODE
>>> register.
>>>   - tx-fifo-depth: See ethernet.txt file in the same directory
>>>   - rx-fifo-depth: See ethernet.txt file in the same directory
>>> +- mdio: with compatible = "snps,dwmac-mdio", create and register
>>> mdio bus.
>>>
>>>   Examples:
>>>
>>> @@ -65,4 +66,11 @@ Examples:
>>>           tx-fifo-depth = <16384>;
>>>           clocks = <&clock>;
>>>           clock-names = "stmmaceth";
>>> +        mdio0 {
>>> +            #address-cells = <1>;
>>> +            #size-cells = <0>;
>>> +            compatible = "snps,dwmac-mdio";
>>> +            phy1: ethernet-phy@0 {
>>> +            };
>>> +        };
>>>       };
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>>> index bba670c..bb6f75c 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>>> @@ -29,7 +29,7 @@
>>>   #include <linux/slab.h>
>>>   #include <linux/of.h>
>>>   #include <linux/of_gpio.h>
>>> -
>>> +#include <linux/of_mdio.h>
>>>   #include <asm/io.h>
>>>
>>>   #include "stmmac.h"
>>> @@ -200,10 +200,29 @@ int stmmac_mdio_register(struct net_device *ndev)
>>>       struct stmmac_priv *priv = netdev_priv(ndev);
>>>       struct stmmac_mdio_bus_data *mdio_bus_data =
>>> priv->plat->mdio_bus_data;
>>>       int addr, found;
>>> +    struct device_node *mdio_node = NULL;
>>> +    struct device_node *child_node = NULL;
>>>
>>>       if (!mdio_bus_data)
>>>           return 0;
>>>
>>> +    if (IS_ENABLED(CONFIG_OF)) {
>>> +        for_each_child_of_node(priv->device->of_node, child_node) {
>>> +            if (of_device_is_compatible(child_node,
>>> +                            "snps,dwmac-mdio")) {
>>> +                mdio_node = child_node;
>>> +                break;
>>> +            }
>>> +        }
>>> +
>>> +        if (mdio_node) {
>>> +            netdev_dbg(ndev, "FOUND MDIO subnode\n");
>>> +        } else {
>>> +            netdev_err(ndev, "NO MDIO subnode\n");
>>> +            return 0;
>>> +        }
>>> +    }
>>> +
>>>       new_bus = mdiobus_alloc();
>>>       if (new_bus == NULL)
>>>           return -ENOMEM;
>>> @@ -231,7 +250,8 @@ int stmmac_mdio_register(struct net_device *ndev)
>>>       new_bus->irq = irqlist;
>>>       new_bus->phy_mask = mdio_bus_data->phy_mask;
>>>       new_bus->parent = priv->device;
>>> -    err = mdiobus_register(new_bus);
>>> +
>>> +    err = of_mdiobus_register(new_bus, mdio_node);
>>>       if (err != 0) {
>>>           pr_err("%s: Cannot register as MDIO bus\n", new_bus->name);
>>>           goto bus_register_fail;
>>> @@ -284,13 +304,6 @@ int stmmac_mdio_register(struct net_device *ndev)
>>>           }
>>>       }
>>>
>>> -    if (!found) {
>>> -        pr_warn("%s: No PHY found\n", ndev->name);
>>> -        mdiobus_unregister(new_bus);
>>> -        mdiobus_free(new_bus);
>>> -        return -ENODEV;
>>> -    }
>>
>> hmm,  this could be necessary on some platforms that wants to
>> get the phy addr at runtime and in case of failure then
>> removes the registered bus.
>>
> Could make this conditional on (!found && !mdio_node).
> Therefore if dt node exists it will be created regardless, otherwise
> unregister if nothing found.
> Thoughts?
>
>>> -
>>>       priv->mii = new_bus;
>>>
>>>       return 0;
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> index d02691b..6863420 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> @@ -146,7 +146,7 @@ stmmac_probe_config_dt(struct platform_device
>>> *pdev, const char **mac)
>>>       if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_addr)
>>> == 0)
>>>           dev_warn(&pdev->dev, "snps,phy-addr property is
>>> deprecated\n");
>>> ec
>>> -    if (plat->phy_node || plat->phy_bus_name)
>>
> I think that would be dependent on the device tree.
> However this may also work:
> if ((plat->phy_node && !of_phy_is_fixed_link(np)) || plat->phy_bus_name)

that's ok for me

>
>> can this breaks some conf case?
>>
>>> +    if (plat->phy_bus_name)
>>>           plat->mdio_bus_data = NULL;
>>>       else
>>>           plat->mdio_bus_data =
>>>
>
> Alternatively the solution would be to introduce some non standard
> device tree node
> to force the creation of the mdio bus.

no, I guess the easier way is what you proposed.

Peppe

>
>
