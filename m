From: Romain Perier <romain.perier@gmail.com>
Subject: Re: [PATCH 2/2] ethernet: arc: Add support for Rockchip SoC glue
 layer device tree bindings
Date: Sat, 09 Aug 2014 11:23:50 +0200
Message-ID: <53E5E8A6.7010302@gmail.com>
References: <1407500875-23851-1-git-send-email-romain.perier@gmail.com> <1407500875-23851-2-git-send-email-romain.perier@gmail.com> <6643752.VIXJ29g27a@diego>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, max.schwarz@online.de, b.galvani@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: =?windows-1252?Q?Heiko_St=FCbner?= <heiko@sntech.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:64161 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbaHIJWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2014 05:22:07 -0400
Received: by mail-wg0-f48.google.com with SMTP id x13so6582410wgg.7
        for <netdev@vger.kernel.org>; Sat, 09 Aug 2014 02:22:05 -0700 (PDT)
In-Reply-To: <6643752.VIXJ29g27a@diego>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Heiko,

Le 08/08/2014 18:25, Heiko St=FCbner a =E9crit :
> Hi Romain,
>
> this new emac-variant is missing a dt-bindings document.
> And additional to Varka's comments, more inline:
>
> Am Freitag, 8. August 2014, 12:27:55 schrieb Romain Perier:
>> This patch defines a platform glue layer for Rockchip SoCs which sup=
port
>> arc-emac driver. It ensures that regulator for the rmii is on before=
 trying
>> to connect to the ethernet controller. It applies right speed and mo=
de
>> changes to the grf when ethernet settings changes.
>>
>> Signed-off-by: Romain Perier <romain.perier@gmail.com>
>> ---
>>   arch/arm/boot/dts/rk3188-radxarock.dts   |   2 +
>>   arch/arm/boot/dts/rk3xxx.dtsi            |   3 +
>>   drivers/net/ethernet/arc/Kconfig         |   9 ++
>>   drivers/net/ethernet/arc/Makefile        |   1 +
>>   drivers/net/ethernet/arc/emac_rockchip.c | 191
>> +++++++++++++++++++++++++++++++ 5 files changed, 206 insertions(+)
>>   create mode 100644 drivers/net/ethernet/arc/emac_rockchip.c
>>
>> diff --git a/arch/arm/boot/dts/rk3188-radxarock.dts
>> b/arch/arm/boot/dts/rk3188-radxarock.dts index d149155..773a433 1006=
44
>> --- a/arch/arm/boot/dts/rk3188-radxarock.dts
>> +++ b/arch/arm/boot/dts/rk3188-radxarock.dts
>> @@ -110,12 +110,14 @@
>>
>>   &emac {
>>   	status =3D "okay";
>> +	compatible =3D "rockchip,rk3188-emac";
>>
>>   	pinctrl-names =3D "default";
>>   	pinctrl-0 =3D <&emac_xfer>, <&emac_mdio>, <&phy_int>;
>>
>>   	mac-address =3D [ c6 ef 91 8e 60 4b ];
>>   	phy =3D <&phy0>;
>> +	phy-supply =3D <&vcc_rmii>;
>>
>>   	phy0: ethernet-phy@0 {
>>   		reg =3D <0>;
>> diff --git a/arch/arm/boot/dts/rk3xxx.dtsi b/arch/arm/boot/dts/rk3xx=
x.dtsi
>> index 80ed3dc..66c8b85 100644
>> --- a/arch/arm/boot/dts/rk3xxx.dtsi
>> +++ b/arch/arm/boot/dts/rk3xxx.dtsi
>> @@ -101,8 +101,11 @@
>>   		#address-cells =3D <1>;
>>   		#size-cells =3D <0>;
>>
>> +		rockchip,grf =3D <&grf>;
>> +
>>   		clocks =3D <&cru HCLK_EMAC>;
>>   		max-speed =3D <100>;
>> +		phy-mode =3D "rmii";
>>
>>   		status =3D "disabled";
>>   	};
> please don't include dts changes in driver patches ... they should be
> individual patches, as they're normally going through a separate tree=
=2E

I will re-submit 4 commits, one for emac refactoring, one for dts=20
changes, one for dts documentation and another one for Rockchip platfor=
m=20
(in this order).

>
> Also in this case, you based your dts changes on my development-branc=
h and
> there is currently no emac support at all in the mainline trees, so y=
ou should
> add the complete nodes.

whoops :D . I thought that this node was already on mainline. Sorry ^^

>
>
>> diff --git a/drivers/net/ethernet/arc/Kconfig
>> b/drivers/net/ethernet/arc/Kconfig index d73d971..196e9e7 100644
>> --- a/drivers/net/ethernet/arc/Kconfig
>> +++ b/drivers/net/ethernet/arc/Kconfig
>> @@ -28,4 +28,13 @@ config ARC_EMAC
>>   	  non-standard on-chip ethernet device ARC EMAC 10/100 is used.
>>   	  Say Y here if you have such a board.  If unsure, say N.
>>
>> +config EMAC_ROCKCHIP
>> +       tristate "Rockchip EMAC support"
>> +       depends on MFD_SYSCON && ARCH_ROCKCHIP
>> +       ---help---
>> +         Support for Rockchip RK3066/RK3188 EMAC ethernet controlle=
rs.
>> +         This selects Rockchip SoC glue layer support for the
>> +         emac device driver. This driver is used for RK3066/RK3188
>> +         EMAC ethernet controller.
>> +
>>   endif # NET_VENDOR_ARC
>> diff --git a/drivers/net/ethernet/arc/Makefile
>> b/drivers/net/ethernet/arc/Makefile index b6f15b4..cf10cf3 100644
>> --- a/drivers/net/ethernet/arc/Makefile
>> +++ b/drivers/net/ethernet/arc/Makefile
>> @@ -4,3 +4,4 @@
>>
>>   obj-$(CONFIG_NET_VENDOR_ARC) +=3D emac_main.o emac_mdio.o
>>   obj-$(CONFIG_ARC_EMAC) +=3D emac_arc.o
>> +obj-$(CONFIG_EMAC_ROCKCHIP) +=3D emac_rockchip.o
>> diff --git a/drivers/net/ethernet/arc/emac_rockchip.c
>> b/drivers/net/ethernet/arc/emac_rockchip.c new file mode 100644
>> index 0000000..2ea724f
>> --- /dev/null
>> +++ b/drivers/net/ethernet/arc/emac_rockchip.c
>> @@ -0,0 +1,191 @@
>> +/**
>> + * emac-rockchip.c - Rockchip EMAC specific glue layer
>> + *
>> + * Copyright (C) 2014 Romain Perier
>> + *
>> + * Romain Perier  <romain.perier@gmail.com>
>> + *
>> + * This program is free software; you can redistribute it and/or mo=
dify
>> + * it under the terms of the GNU General Public License as publishe=
d by
>> + * the Free Software Foundation; either version 2 of the License, o=
r
>> + * (at your option) any later version.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>> + * GNU General Public License for more details.
>> + */
>> +
>> +#include "emac.h"
>> +#include <linux/of_net.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/regulator/consumer.h>
>> +#include <linux/mfd/syscon.h>
>> +#include <linux/regmap.h>
>> +#include <linux/module.h>
>> +#include <linux/clk.h>
>> +
>> +#define DRV_NAME        "rockchip_emac"
>> +#define DRV_VERSION     "1.0"
>> +
>> +#define GRF_MODE_MII   BIT(0)
>> +#define GRF_MODE_RMII  0x0
>> +#define GRF_SPEED_10M  0x0
>> +#define GRF_SPEED_100M BIT(1)
>> +
>> +struct rockchip_priv_data {
>> +	struct regmap *grf;
>> +	unsigned int grf_offset;
>> +	int interface;
>> +	struct regulator *regulator;
>> +};
>> +
>> +static const unsigned int rockchip_emac_soc_grf_offset[] =3D {
>> +	0x154, /* rk3066 */
>> +	0x0a4, /* rk3188 */
>> +};
>> +
>> +static const struct of_device_id rockchip_emac_dt_ids[] =3D {
>> +	{ .compatible =3D "rockchip,rk3066-emac", .data =3D (void
>> *)rockchip_emac_soc_grf_offset }, +	{ .compatible =3D "rockchip,rk31=
88-emac",
>> .data =3D (void *)rockchip_emac_soc_grf_offset + 1 }, +	{ /* Sentine=
l */ }
>> +};
>> +
>> +MODULE_DEVICE_TABLE(of, rockchip_emac_dt_ids);
>> +
>> +static int rockchip_grf_set_phy_speed(const struct rockchip_priv_da=
ta
>> *emac, unsigned int speed) +{
>> +	/* write-enable bits */
>> +	u32 data =3D BIT(17) | BIT(16);
>> +
>> +	switch(speed) {
>> +	case 10:
>> +		data |=3D GRF_SPEED_10M << 1;
>> +		break;
>> +	case 100:
>> +		data |=3D GRF_SPEED_100M << 1;
> I don't understand the "<< 1" here, the speed-bit in the register is =
already
> bit(1) as defined in the GRF_SPEED_100M at the top, so this code woul=
d move the
> bit to bit(2)
>
>
>> +		break;
>> +	default:
>> +		return -ENOTSUPP;
>> +	}
>> +
>> +	switch(emac->interface) {
>> +	case PHY_INTERFACE_MODE_RMII:
>> +		data |=3D GRF_MODE_RMII;
>> +		break;
>> +	case PHY_INTERFACE_MODE_MII:
>> +		data |=3D GRF_MODE_MII;
>> +		break;
>> +	default:
>> +		return -ENOTSUPP;
>> +	}
> setting the interface mode could be done only once in _probe, especia=
lly when
> you take into account the necessary clock settings described below.
>
>
>> +
>> +	return regmap_write(emac->grf, emac->grf_offset, data);
>> +}
>> +
>> +static void rockchip_set_mac_speed(void *priv, unsigned int speed)
>> +{
>> +	struct rockchip_priv_data *emac =3D priv;
>> +	int ret =3D 0;
>> +
>> +	ret =3D rockchip_grf_set_phy_speed(emac, speed);
>> +	if (ret) {
>> +		if (ret =3D=3D -ENOTSUPP)
>> +			pr_err("phy interface (%d) or speed (%u) not supported\n",
>> emac->interface, speed); +		return ret;
>> +	}
>> +}
>> +
>> +static int rockchip_emac_probe(struct platform_device *pdev)
>> +{
>> +	struct rockchip_priv_data *emac =3D NULL;
>> +	struct emac_platform_data *emac_plat_data =3D NULL;
>> +	struct device *dev =3D &pdev->dev;
>> +	const struct of_device_id *match =3D NULL;
>> +	int ret =3D 0;
>> +	u32 data =3D 0;
>> +
>> +	emac =3D dev_get_platdata(dev);
> Rockchip support is devicetree-only, so you could simply error out in=
 a
> theoretical non-dt case with:
>
> if (!pdev->of_node)
> 	return -ENODEV;
>
> Otherwise if you really want to get a previous defined platform-data =
struct,
> you should not overwrite it unconditionally below.
>
>
>> +
>> +	if (!emac) {
>> +		emac =3D devm_kzalloc(dev, sizeof(*emac), GFP_KERNEL);
>> +		if (!emac)
>> +			return -ENOMEM;
>> +	}
>> +
>> +	emac_plat_data =3D devm_kzalloc(dev, sizeof(*emac_plat_data), GFP_=
KERNEL);
>> +	if (!emac_plat_data)
>> +		return -ENOMEM;
>> +	emac_plat_data->name =3D DRV_NAME;
>> +	emac_plat_data->version =3D DRV_VERSION;
>> +	emac_plat_data->set_mac_speed =3D rockchip_set_mac_speed;
>> +	emac_plat_data->priv =3D emac;
>> +
>> +	emac->interface =3D of_get_phy_mode(dev->of_node);
>> +	emac_plat_data->interface =3D emac->interface;
>> +
>> +	emac->grf =3D syscon_regmap_lookup_by_phandle(dev->of_node, "rockc=
hip,grf");
>> +	if (IS_ERR(emac->grf)) {
>> +		dev_err(dev, "unable to find syscon grf (%ld)\n", PTR_ERR(emac->g=
rf));
>> +		return PTR_ERR_OR_ZERO(emac->grf);
>> +	}
>> +
>> +	match =3D of_match_node(rockchip_emac_dt_ids, dev->of_node);
>> +	emac->grf_offset =3D *(unsigned int *)match;
>> +
>> +	emac_plat_data->clk =3D of_clk_get(dev->of_node, 0);
>> +	if (IS_ERR(emac_plat_data->clk)) {
>> +		dev_err(dev, "failed to retrieve clock from device tree\n");
>> +		return PTR_ERR_OR_ZERO(emac_plat_data->clk);
>> +	}
> The clock handling needs a bit more work.
>
> For one, the rockchip emac needs two clocks (the hclk and the macref =
clock).
> Additionally the macref clk needs to be set to different values depen=
ding on
> the interface type.
>
> In RMII mode it should be set to 50MHz and I guess in MII mode to 25M=
Hz [0].
>
> And secondly, you could use devm_clk_get because mixing devm_ and non=
-devm_
> function doesn't work that well (and you're missing the clk_put here)
>
> So combined:
>
> emac_plat_data->clk =3D devm_clk_get(dev, "ahb_hclk");
> if (IS_ERR(...))
> 	...
>
> emac->refclk =3D devm_clk_get(dev, "macref");
> ...
>
> 	switch(emac->interface) {
> 	case PHY_INTERFACE_MODE_RMII:
> 		data =3D GRF_MODE_RMII;
> 		rate =3D 50000000;
> 		break;
> 	case PHY_INTERFACE_MODE_MII:
> 		data =3D GRF_MODE_MII;
> 		rate =3D 25000000;
> 		break;
> 	default:
> 		return -ENOTSUPP;
> 	}
>
> 	ret =3D regmap_write(emac->grf, emac->grf_offset, data);
> 	if (ret)
> 		foo
>
> 	ret =3D clk_set_rate(emac->refclk, rate);
> 	if (ret)
> 		foo
>
>
> Heiko

Thanks for details, I will improve this patch.

>
> [0]
> http://en.wikipedia.org/wiki/Media_Independent_Interface#Reduced_Medi=
a_Independent_Interface
>
>> +
>> +        /* Optional regulator for PHY */
>> +	emac->regulator =3D devm_regulator_get_optional(dev, "phy");
>> +	if (IS_ERR(emac->regulator)) {
>> +		if (PTR_ERR(emac->regulator) =3D=3D -EPROBE_DEFER)
>> +			return ERR_PTR(-EPROBE_DEFER);
>> +		dev_info(dev, "no regulator found\n");
>> +		emac->regulator =3D NULL;
>> +	}
>> +
>> +	if (emac->regulator) {
>> +		ret =3D regulator_enable(emac->regulator);
>> +		if (ret)
>> +			return ret;
>> +	}
>> +
>> +	ret =3D rockchip_grf_set_phy_speed(emac, 100);
>> +	if (ret) {
>> +		if (ret =3D=3D -ENOTSUPP)
>> +			dev_err(dev, "phy interface not supported (%d)\n", emac-
>> interface);
>> +		return ret;
>> +	}
>> +
>> +	return emac_drv_probe(dev, emac_plat_data);
>> +}
>> +
>> +static int rockchip_emac_remove(struct platform_device *pdev)
>> +{
>> +	struct rockchip_priv_data *emac =3D dev_get_platdata(&pdev->dev);
>> +	struct net_device *ndev =3D dev_get_drvdata(&pdev->dev);
>> +
>> +	if (emac->regulator)
>> +		regulator_disable(emac->regulator);
>> +	return emac_drv_remove(ndev);
>> +}
>> +
>> +static struct platform_driver rockchip_emac_driver =3D {
>> +	.probe =3D rockchip_emac_probe,
>> +	.remove =3D rockchip_emac_remove,
>> +	.driver =3D {
>> +		.name =3D DRV_NAME,
>> +		.owner =3D THIS_MODULE,
>> +		.of_match_table  =3D rockchip_emac_dt_ids,
>> +	},
>> +};
>> +
>> +module_platform_driver(rockchip_emac_driver);
>> +
>> +MODULE_AUTHOR("Romain Perier <romain.perier@gmail.com>");
>> +MODULE_DESCRIPTION("Rockchip EMAC driver");
>> +MODULE_LICENSE("GPL");

Thanks to all of you for your feedbacks (and sorry for some of my=20
mistakes this is my first kernel contribution)
Romain
