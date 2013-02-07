From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH] net: sh_eth: Add support of device tree probe
Date: Thu, 7 Feb 2013 09:18:36 +0900
Message-ID: <CABMQnV+ut0hPNeN_0ZZtOQGFOXh9ZEVo484VBsYPmBHHbqsD=A@mail.gmail.com>
References: <1360116019-8870-1-git-send-email-horms+renesas@verge.net.au> <CAOJe8K3FJwOjBdLO00X270x4AHL3aLT6FB+jQqOZhF=7EX38qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Magnus Damm <magnus.damm@gmail.com>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <CAOJe8K3FJwOjBdLO00X270x4AHL3aLT6FB+jQqOZhF=7EX38qA@mail.gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

HI,

On Wed, Feb 6, 2013 at 4:30 PM, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> On 2/6/13, Simon Horman <horms+renesas@verge.net.au> wrote:
>> From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>>
>> This adds support of device tree probe for Renesas sh-ether driver.
>>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>>
>> ---
>>  Documentation/devicetree/bindings/net/sh_ether.txt |   43 ++++++
>>  drivers/net/ethernet/renesas/sh_eth.c              |  156
>> +++++++++++++++++---
>>  2 files changed, 177 insertions(+), 22 deletions(-)
>>  create mode 100644 Documentation/devicetree/bindings/net/sh_ether.txt
>>
>> [Simon Horman]
>> I am re-posting this patch with devicetree-discuss@lists.ozlabs.org CCed
>> for review of the proposed device tree bindings.
>>
>> diff --git a/Documentation/devicetree/bindings/net/sh_ether.txt
>> b/Documentation/devicetree/bindings/net/sh_ether.txt
>> new file mode 100644
>> index 0000000..c11e45d
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/sh_ether.txt
>> @@ -0,0 +1,43 @@
>> +* Renesas Electronics SuperH EMAC
>> +
>> +This file provides information, what the device node
>> +for the sh_eth interface contains.
>> +
>> +Required properties:
>> +- compatible:                   "renesas,sh-eth";
>> +- interrupt-parent:             The phandle for the interrupt controller
>> that
>> +                                services interrupts for this device.
>> +- reg:                          Offset and length of the register set for
>> the
>> +                                device.
>> +- interrupts:                   Interrupt mapping for the sh_eth interrupt
>> +                                sources (vector id).
>> +- phy-mode:              String, operation mode of the PHY interface.
>> +- sh-eth,edmac-endian:          String, endian of sh_eth dmac.
>> +- sh-eth,register-type:         String, register type of sh_eth.
>> +                                Please select "gigabit", "fast-sh4" or
>> +                                "fast-sh3-sh2".
>> +                                Please select "little" or "big".
>> +- sh-eth,endian:                String, endian of sh_eth dmac.
>> +- sh-eth,phy-id:                PHY id.
>> +
>> +Optional properties:
>> +- local-mac-address : 6 bytes, mac address
>> +- sh-eth,no-ether-link:         set link control by software. When device
>> does
>> +                                not support ether-link, set.
>> +- sh-etn,ether-link-active-low: set link check method.
>> +                                When detection of link is treated as
>> active-low,
>> +                                set.
>> +- sh-etn,needs-init:            Initialization flag.
>> +                                When initialize device in probing device,
>> set.
>> +
>> +Example (armadillo800eva):
>> +     sh-eth@e9a00000 {
>> +             compatible = "renesas,sh-eth";
>> +             interrupt-parent = <&intca>;
>> +             reg = <0xe9a00000 0x800>, <0xe9a01800 0x800>;
>> +             interrupts = <0x500>;
>> +             phy-mode = "mii";
>> +             sh-eth,edmac-endian = "little";
>> +             sh-eth,register-type = "gigabit";
>> +             sh-eth,phy-id = <0>;
>> +     };
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>> b/drivers/net/ethernet/renesas/sh_eth.c
>> index 3d70586..1f64848 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
>> @@ -31,6 +31,12 @@
>>  #include <linux/platform_device.h>
>>  #include <linux/mdio-bitbang.h>
>>  #include <linux/netdevice.h>
>> +#include <linux/of.h>
>> +#include <linux/of_device.h>
>> +#include <linux/of_platform.h>
>> +#include <linux/of_address.h>
>> +#include <linux/of_irq.h>
>> +#include <linux/of_net.h>
>>  #include <linux/phy.h>
>>  #include <linux/cache.h>
>>  #include <linux/io.h>
>> @@ -2347,26 +2353,120 @@ static const struct net_device_ops
>> sh_eth_netdev_ops = {
>>       .ndo_change_mtu         = eth_change_mtu,
>>  };
>>
>> +#ifdef CONFIG_OF
>> +
>> +static int
>> +sh_eth_of_get_register_type(struct device_node *np)
>> +{
>> +     const char *of_str;
>> +     int ret = of_property_read_string(np, "sh-eth,register-type", &of_str);
>> +     if (ret)
>> +             return ret;
>> +
>> +     if (of_str && !strcmp(of_str, "gigabit"))
>> +             return SH_ETH_REG_GIGABIT;
>> +     else if (of_str && !strcmp(of_str, "fast-sh4"))
>> +             return SH_ETH_REG_FAST_SH4;
>> +     else if (of_str && !strcmp(of_str, "fast-sh3-sh2"))
>> +             return SH_ETH_REG_FAST_SH3_SH2;
>> +     else
>> +             return -EINVAL;
>> +}
>> +
>> +static struct sh_eth_plat_data *
>> +sh_eth_parse_dt(struct device *dev, struct net_device *ndev)
>> +{
>> +     int ret;
>> +     const char *of_str;
>> +     struct device_node *np = dev->of_node;
>> +     struct sh_eth_plat_data *pdata;
>> +
>> +     pdata = devm_kzalloc(dev, sizeof(struct sh_eth_plat_data),
>> +                                     GFP_KERNEL);
>> +     if (!pdata) {
>> +             dev_err(dev, "%s: failed to allocate config data\n", __func__);
>> +             return NULL;
>> +     }
>> +
>> +     pdata->phy_interface = of_get_phy_mode(np);
>> +
>> +     of_property_read_u32(np, "sh-eth,phy-id", &pdata->phy);
>> +
>> +     of_property_read_string(np, "sh-eth,edmac-endian", &of_str);
>> +     if (of_str && !strcmp(of_str, "little"))
>> +             pdata->edmac_endian = EDMAC_LITTLE_ENDIAN;
>> +     else if (of_str && !strcmp(of_str, "big"))
>> +             pdata->edmac_endian = EDMAC_BIG_ENDIAN;
>> +     else
>> +             goto error;
>> +
>> +     if (of_find_property(np, "sh-eth,no-ether-link", NULL))
>> +             pdata->no_ether_link = 1;
>> +     else
>> +             pdata->no_ether_link = 0;
>> +
>> +     if (of_find_property(np, "sh-eth,ether-link-active-low", NULL))
>> +             pdata->ether_link_active_low = 1;
>> +     else
>> +             pdata->ether_link_active_low = 0;
>> +
>> +     ret = sh_eth_of_get_register_type(np);
>> +     if (ret < 0)
>> +             goto error;
>> +     pdata->register_type = ret;
>> +
>> +     if (of_find_property(np, "sh-eth,needs-init", NULL))
>> +             pdata->needs_init = 1;
>> +     else
>> +             pdata->needs_init = 0;
>> +
>> +#ifdef CONFIG_OF_NET
>> +     if (!is_valid_ether_addr(ndev->dev_addr)) {
>> +             const char *macaddr = of_get_mac_address(np);
>> +             if (macaddr)
>> +                     memcpy(pdata->mac_addr, macaddr, ETH_ALEN);
>> +     }
>> +#endif
>> +
>> +     return pdata;
>> +
>> +error:
>> +     devm_kfree(dev, pdata);
>> +     return NULL;
>> +}
>> +#else
>> +static struct sh_eth_plat_data *
>> +sh_eth_parse_dt(struct device *dev, struct net_device *ndev)
>> +{
>> +     return NULL;
>> +}
>> +#endif
>> +
>>  static int sh_eth_drv_probe(struct platform_device *pdev)
>>  {
>> -     int ret, devno = 0;
>> +     int ret = 0, devno = 0;
>>       struct resource *res;
>>       struct net_device *ndev = NULL;
>>       struct sh_eth_private *mdp = NULL;
>>       struct sh_eth_plat_data *pd;
>> +     struct device_node *np = pdev->dev.of_node;
>> +
>> +     ndev = alloc_etherdev(sizeof(struct sh_eth_private));
>> +     if (!ndev) {
>> +             ret = -ENOMEM;
>> +             goto out;
>> +     }
>> +
>> +     /* Fill in the fields of the device structure with ethernet values. */
>> +     ether_setup(ndev);
>
> You don't need to call ether_setup() since it's already called by
> alloc_etherdev()
>

OK, I will fix this.

Thanks.
  Nobuhiro


-- 
Nobuhiro Iwamatsu
