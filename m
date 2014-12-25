From: Roger <roger.chen@rock-chips.com>
Subject: Re: [PATCH v2 1/6] GMAC: add driver for Rockchip RK3288 SoCs integrated
 GMAC
Date: Thu, 25 Dec 2014 08:46:08 +0800
Message-ID: <549B5E50.2000501@rock-chips.com>
References: <1417056591-3570-1-git-send-email-roger.chen@rock-chips.com> <1417056728-3642-1-git-send-email-roger.chen@rock-chips.com> <1591535.72TyRu5yfQ@diego> <547EC24E.6050905@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	kever.yang@rock-chips.com, eddie.cai@rock-chips.com
To: =?windows-1252?Q?Heiko_St=FCbner?= <heiko@sntech.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from regular1.263xmail.com ([211.150.99.134]:57991 "EHLO
	regular1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbaLYAqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 19:46:20 -0500
In-Reply-To: <547EC24E.6050905@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi! Heiko

Any suggestion?

On 2014/12/3 15:57, Roger wrote:
> Hi! Heiko
>
> about regulator, power gpio,  reset gpio and irq gpio
> please refer to my comment inline, tks.
>
> On 2014/12/2 7:44, Heiko St=FCbner wrote:
>> Hi Roger,
>>
>> the comments inline are a rough first review. I hope to get a cleare=
r=20
>> picture
>> for the stuff I'm not sure about in v3 once the big issues are fixed=
=2E
>>
>>
>> Am Donnerstag, 27. November 2014, 10:52:08 schrieb Roger Chen:
>>> This driver is based on stmmac driver.
>>>
>>> modification based on Giuseppe CAVALLARO's suggestion:
>>> 1. use BIT()
>>>
>>>     > +/*RK3288_GRF_SOC_CON3*/
>>>     > +#define GMAC_TXCLK_DLY_ENABLE   ((0x4000 << 16) | (0x4000))
>>>     > +#define GMAC_TXCLK_DLY_DISABLE  ((0x4000 << 16) | (0x0000))
>>>
>>>     ...
>>>
>>>     why do not use BIT and BIT_MASK where possible?
>>>
>>>     =3D=3D=3D>after modification:
>>>
>>>     #define GRF_BIT(nr)     (BIT(nr) | BIT(nr+16))
>>>     #define GRF_CLR_BIT(nr) (BIT(nr+16))
>>>     #define GMAC_TXCLK_DLY_ENABLE   GRF_BIT(14)
>>>     #define GMAC_TXCLK_DLY_DISABLE  GRF_CLR_BIT(14)
>>>     ...
>>> 2.
>>>
>>>     > +    regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
>>>     > +             GMAC_PHY_INTF_SEL_RGMII);
>>>     > +    regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
>>>     > +             GMAC_RMII_MODE_CLR);
>>>
>>>     maybe you could perform just one write unless there is some HW
>>>     constraint.
>>>
>>>     =3D=3D=3D>after modification:
>>>
>>>     regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
>>>              GMAC_PHY_INTF_SEL_RGMII | GMAC_RMII_MODE_CLR);
>>>
>>> 3. use macros
>>>
>>>     > +    regmap_write(bsp_priv->grf, RK3288_GRF_GPIO3D_E,=20
>>> 0xFFFFFFFF);
>>>     > +    regmap_write(bsp_priv->grf, RK3288_GRF_GPIO4B_E,
>>>     > +             0x3<<2<<16 | 0x3<<2);
>>>
>>>     pls use macros, these shift sequence is really help to decode
>>>
>>>     =3D=3D=3D>after modification:
>>>
>>>     regmap_write(bsp_priv->grf, RK3288_GRF_GPIO4A_E, GPIO4A_12MA);
>>>     regmap_write(bsp_priv->grf, RK3288_GRF_GPIO4B_E, GPIO4B_2_12MA)=
;
>>>
>>> 4. remove grf fail check in rk_gmac_setup()
>>>
>>>     > +    if (IS_ERR(bsp_priv->grf))
>>>     > +        dev_err(&pdev->dev, "Missing rockchip,grf property\n=
");
>>>
>>>     I wonder if you can fail on here and save all the check in
>>>     set_rgmii_speed etc.
>>>     Maybe this can be considered a mandatory property for the=20
>>> glue-logic.
>>>
>>> 5. remove .tx_coe=3D1
>>>
>>>     > +const struct stmmac_of_data rk_gmac_data =3D {
>>>     > +    .has_gmac =3D 1,
>>>     > +    .tx_coe =3D 1,
>>>
>>>     FYI, on new gmac there is the HW capability register to dinamic=
ally
>>>     provide you if coe is supported.
>>>
>>>     IMO you should add the OF "compatible" string and in case of ma=
c
>>>     newer than the 3.50a you can remove coe.
>> changelogs like these, should be compact and also not be in the=20
>> commit message
>> itself, but in the "comment"-section below the "---" and before the=20
>> diffstat.
>>
>>
>>> Signed-off-by: Roger Chen <roger.chen@rock-chips.com>
>>> ---
>> changelog here ... the commonly used pattern is something like
>>
>> changes since v2:
>> - ...
>> - ...
>>
>> changes since v1:
>> - ...
>>
>>> drivers/net/ethernet/stmicro/stmmac/Makefile       |    2 +-
>>>   drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c     |  636
>>> ++++++++++++++++++++=20
>>> .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |
>>>   3 +
>>>   .../net/ethernet/stmicro/stmmac/stmmac_platform.h  |    1 +
>>>   4 files changed, 641 insertions(+), 1 deletion(-)
>>>   create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>>>
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile
>>> b/drivers/net/ethernet/stmicro/stmmac/Makefile index ac4d562..73c27=
15
>>> 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/Makefile
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
>>> @@ -6,7 +6,7 @@ stmmac-objs:=3D stmmac_main.o stmmac_ethtool.o=20
>>> stmmac_mdio.o
>>> ring_mode.o    \
>>>
>>>   obj-$(CONFIG_STMMAC_PLATFORM) +=3D stmmac-platform.o
>>>   stmmac-platform-objs:=3D stmmac_platform.o dwmac-meson.o=20
>>> dwmac-sunxi.o    \
>>> -               dwmac-sti.o dwmac-socfpga.o
>>> +               dwmac-sti.o dwmac-socfpga.o dwmac-rk.o
>>>
>>>   obj-$(CONFIG_STMMAC_PCI) +=3D stmmac-pci.o
>>>   stmmac-pci-objs:=3D stmmac_pci.o
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>>> b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c new file mode 1006=
44
>>> index 0000000..870563f
>>> --- /dev/null
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>>> @@ -0,0 +1,636 @@
>>> +/**
>>> + * dwmac-rk.c - Rockchip RK3288 DWMAC specific glue layer
>>> + *
>>> + * Copyright (C) 2014 Chen-Zhi (Roger Chen)
>>> + *
>>> + * Chen-Zhi (Roger Chen)  <roger.chen@rock-chips.com>
>>> + *
>>> + * This program is free software; you can redistribute it and/or=20
>>> modify
>>> + * it under the terms of the GNU General Public License as=20
>>> published by
>>> + * the Free Software Foundation; either version 2 of the License, =
or
>>> + * (at your option) any later version.
>>> + *
>>> + * This program is distributed in the hope that it will be useful,
>>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>>> + * GNU General Public License for more details.
>>> + */
>>> +
>>> +#include <linux/stmmac.h>
>>> +#include <linux/bitops.h>
>>> +#include <linux/clk.h>
>>> +#include <linux/phy.h>
>>> +#include <linux/of_net.h>
>>> +#include <linux/gpio.h>
>>> +#include <linux/of_gpio.h>
>>> +#include <linux/of_device.h>
>>> +#include <linux/regulator/consumer.h>
>>> +#include <linux/delay.h>
>>> +#include <linux/mfd/syscon.h>
>>> +#include <linux/regmap.h>
>>> +
>>> +struct rk_priv_data {
>>> +    struct platform_device *pdev;
>>> +    int phy_iface;
>>> +    bool power_ctrl_by_pmu;
>>> +    char pmu_regulator[32];
>>> +    int pmu_enable_level;
>>> +
>>> +    int power_io;
>>> +    int power_io_level;
>>> +    int reset_io;
>>> +    int reset_io_level;
>>> +    int phyirq_io;
>>> +    int phyirq_io_level;
>>> +
>>> +    bool clk_enabled;
>>> +    bool clock_input;
>>> +
>>> +    struct clk *clk_mac;
>>> +    struct clk *clk_mac_pll;
>>> +    struct clk *gmac_clkin;
>>> +    struct clk *mac_clk_rx;
>>> +    struct clk *mac_clk_tx;
>>> +    struct clk *clk_mac_ref;
>>> +    struct clk *clk_mac_refout;
>>> +    struct clk *aclk_mac;
>>> +    struct clk *pclk_mac;
>>> +
>>> +    int tx_delay;
>>> +    int rx_delay;
>>> +
>>> +    struct regmap *grf;
>>> +};
>>> +
>>> +#define RK3288_GRF_SOC_CON1 0x0248
>>> +#define RK3288_GRF_SOC_CON3 0x0250
>>> +#define RK3288_GRF_GPIO3D_E 0x01ec
>>> +#define RK3288_GRF_GPIO4A_E 0x01f0
>>> +#define RK3288_GRF_GPIO4B_E 0x01f4
>> here you're using a space instead of a tab, please select one patter=
n=20
>> either
>> tabs or space but do not mix them.
>>
>>
>>> +#define GPIO3D_2MA    0xFFFF0000
>>> +#define GPIO3D_4MA    0xFFFF5555
>>> +#define GPIO3D_8MA    0xFFFFAAAA
>>> +#define GPIO3D_12MA    0xFFFFFFFF
>>> +
>>> +#define GPIO4A_2MA    0xFFFF0000
>>> +#define GPIO4A_4MA    0xFFFF5555
>>> +#define GPIO4A_8MA    0xFFFFAAAA
>>> +#define GPIO4A_12MA    0xFFFFFFFF
>> see comment about pin settings below
>>
>>
>>> +
>>> +#define GRF_BIT(nr)    (BIT(nr) | BIT(nr+16))
>>> +#define GRF_CLR_BIT(nr)    (BIT(nr+16))
>>> +
>>> +#define GPIO4B_2_2MA    (GRF_CLR_BIT(2) | GRF_CLR_BIT(3))
>>> +#define GPIO4B_2_4MA    (GRF_BIT(2) | GRF_CLR_BIT(3))
>>> +#define GPIO4B_2_8MA    (GRF_CLR_BIT(2) | GRF_BIT(3))
>>> +#define GPIO4B_2_12MA    (GRF_BIT(2) | GRF_BIT(3))
>>> +
>>> +/*RK3288_GRF_SOC_CON1*/
>>> +#define GMAC_PHY_INTF_SEL_RGMII    (GRF_BIT(6) | GRF_CLR_BIT(7) |
>>> GRF_CLR_BIT(8))
>>> +#define GMAC_PHY_INTF_SEL_RMII  (GRF_CLR_BIT(6) |
>>> GRF_CLR_BIT(7) | GRF_BIT(8))
>>> +#define GMAC_FLOW_CTRL          GRF_BIT(9)
>>> +#define GMAC_FLOW_CTRL_CLR      GRF_CLR_BIT(9)
>>> +#define GMAC_SPEED_10M          GRF_CLR_BIT(10)
>>> +#define GMAC_SPEED_100M         GRF_BIT(10)
>>> +#define GMAC_RMII_CLK_25M       GRF_BIT(11)
>>> +#define GMAC_RMII_CLK_2_5M      GRF_CLR_BIT(11)
>>> +#define GMAC_CLK_125M           (GRF_CLR_BIT(12) | GRF_CLR_BIT(13)=
)
>>> +#define GMAC_CLK_25M            (GRF_BIT(12) | GRF_BIT(13))
>>> +#define GMAC_CLK_2_5M           (GRF_CLR_BIT(12) | GRF_BIT(13))
>>> +#define GMAC_RMII_MODE          GRF_BIT(14)
>>> +#define GMAC_RMII_MODE_CLR      GRF_CLR_BIT(14)
>>> +
>>> +/*RK3288_GRF_SOC_CON3*/
>>> +#define GMAC_TXCLK_DLY_ENABLE   GRF_BIT(14)
>>> +#define GMAC_TXCLK_DLY_DISABLE  GRF_CLR_BIT(14)
>>> +#define GMAC_RXCLK_DLY_ENABLE   GRF_BIT(15)
>>> +#define GMAC_RXCLK_DLY_DISABLE  GRF_CLR_BIT(15)
>>> +#define GMAC_CLK_RX_DL_CFG(val) ((0x7F<<7<<16) | (val<<7))
>>> +#define GMAC_CLK_TX_DL_CFG(val) ((0x7F<<16) | (val))
>> again mixed tabs and spaces as delimiters.
>>
>> Also the _CFG macros are not well abstracted. You could take a look=20
>> at the
>> HIWORD_UPDATE macro in drivers/clk/rockchip/clk.h:
>>
>> #define GMAC_CLK_DL_MASK    0x7f
>> #define GMAC_CLK_RX_DL_CFG(val)  HIWORD_UPDATE(val, GMAC_CLK_DL_MASK=
, 7)
>> #define GMAC_CLK_TX_DL_CFG(val)  HIWORD_UPDATE(val, GMAC_CLK_DL_MASK=
, 0)
>>
>>
>>> +
>>> +static void set_to_rgmii(struct rk_priv_data *bsp_priv,
>>> +             int tx_delay, int rx_delay)
>>> +{
>>> +    if (IS_ERR(bsp_priv->grf)) {
>>> +        pr_err("%s: Missing rockchip,grf property\n", __func__);
>>> +        return;
>>> +    }
>>> +
>>> +    regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
>>> +             GMAC_PHY_INTF_SEL_RGMII | GMAC_RMII_MODE_CLR);
>>> +    regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON3,
>>> +             GMAC_RXCLK_DLY_ENABLE | GMAC_TXCLK_DLY_ENABLE |
>>> +             GMAC_CLK_RX_DL_CFG(rx_delay) |
>>> +             GMAC_CLK_TX_DL_CFG(tx_delay));
>>> +    regmap_write(bsp_priv->grf, RK3288_GRF_GPIO3D_E, GPIO3D_12MA);
>>> +    regmap_write(bsp_priv->grf, RK3288_GRF_GPIO4A_E, GPIO4A_12MA);
>>> +    regmap_write(bsp_priv->grf, RK3288_GRF_GPIO4B_E, GPIO4B_2_12MA=
);
>> please don't write to parts controlled by other drivers - here the d=
rive
>> strength settings of pins is controlled by the pinctrl driver.=20
>> Instead you can
>> just set the drive-strength in the pinctrl settings.
>>
>>
>>> +
>>> +    pr_debug("%s: tx delay=3D0x%x; rx delay=3D0x%x;\n",
>>> +         __func__, tx_delay, rx_delay);
>>> +}
>>> +
>>> +static void set_to_rmii(struct rk_priv_data *bsp_priv)
>>> +{
>>> +    if (IS_ERR(bsp_priv->grf)) {
>>> +        pr_err("%s: Missing rockchip,grf property\n", __func__);
>> you have a device-reference in rk_priv_data, so you could use dev_er=
r=20
>> here.
>> Same for all other pr_err/pr_debug/pr_* calls in this file.
>>
>>
>>> +        return;
>>> +    }
>>> +
>>> +    regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
>>> +             GMAC_PHY_INTF_SEL_RMII);
>>> +    regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
>>> +             GMAC_RMII_MODE);
>> these two could be combined?
>>
>>
>>> +}
>>> +
>>> +static void set_rgmii_speed(struct rk_priv_data *bsp_priv, int spe=
ed)
>>> +{
>>> +    if (IS_ERR(bsp_priv->grf)) {
>>> +        pr_err("%s: Missing rockchip,grf property\n", __func__);
>>> +        return;
>>> +    }
>>> +
>>> +    if (speed =3D=3D 10)
>>> +        regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,=20
>>> GMAC_CLK_2_5M);
>>> +    else if (speed =3D=3D 100)
>>> +        regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,=20
>>> GMAC_CLK_25M);
>>> +    else if (speed =3D=3D 1000)
>>> +        regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,=20
>>> GMAC_CLK_125M);
>>> +    else
>>> +        pr_err("unknown speed value for RGMII! speed=3D%d", speed)=
;
>>> +}
>>> +
>>> +static void set_rmii_speed(struct rk_priv_data *bsp_priv, int spee=
d)
>>> +{
>>> +    if (IS_ERR(bsp_priv->grf)) {
>>> +        pr_err("%s: Missing rockchip,grf property\n", __func__);
>>> +        return;
>>> +    }
>>> +
>>> +    if (speed =3D=3D 10) {
>>> +        regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
>>> +                 GMAC_RMII_CLK_2_5M);
>>> +        regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
>>> +                 GMAC_SPEED_10M);
>> combine into one write?
>>
>>
>>> +    } else if (speed =3D=3D 100) {
>>> +        regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
>>> +                 GMAC_RMII_CLK_25M);
>>> +        regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
>>> +                 GMAC_SPEED_100M);
>> combine into one write?
>>
>>
>>> +    } else {
>>> +        pr_err("unknown speed value for RMII! speed=3D%d", speed);
>>> +    }
>>> +}
>>> +
>>> +#define MAC_CLK_RX    "mac_clk_rx"
>>> +#define MAC_CLK_TX    "mac_clk_tx"
>>> +#define CLK_MAC_REF    "clk_mac_ref"
>>> +#define CLK_MAC_REF_OUT    "clk_mac_refout"
>>> +#define CLK_MAC_PLL    "clk_mac_pll"
>>> +#define ACLK_MAC    "aclk_mac"
>>> +#define PCLK_MAC    "pclk_mac"
>>> +#define MAC_CLKIN    "ext_gmac"
>>> +#define CLK_MAC        "stmmaceth"
>> why the need to extra constants for the clock names and not use the=20
>> real names
>> directly like most other drivers do?
>>
>>
>>> +
>>> +static int gmac_clk_init(struct rk_priv_data *bsp_priv)
>>> +{
>>> +    struct device *dev =3D &bsp_priv->pdev->dev;
>>> +
>>> +    bsp_priv->clk_enabled =3D false;
>>> +
>>> +    bsp_priv->mac_clk_rx =3D clk_get(dev, MAC_CLK_RX);
>>> +    if (IS_ERR(bsp_priv->mac_clk_rx))
>>> +        pr_warn("%s: warning: cannot get clock %s\n",
>>> +            __func__, MAC_CLK_RX);
>>> +
>>> +    bsp_priv->mac_clk_tx =3D clk_get(dev, MAC_CLK_TX);
>>> +    if (IS_ERR(bsp_priv->mac_clk_tx))
>>> +        pr_warn("%s: warning: cannot get clock %s\n",
>>> +            __func__, MAC_CLK_TX);
>>> +
>>> +    bsp_priv->clk_mac_ref =3D clk_get(dev, CLK_MAC_REF);
>>> +    if (IS_ERR(bsp_priv->clk_mac_ref))
>>> +        pr_warn("%s: warning: cannot get clock %s\n",
>>> +            __func__, CLK_MAC_REF);
>>> +
>>> +    bsp_priv->clk_mac_refout =3D clk_get(dev, CLK_MAC_REF_OUT);
>>> +    if (IS_ERR(bsp_priv->clk_mac_refout))
>>> +        pr_warn("%s: warning:cannot get clock %s\n",
>>> +            __func__, CLK_MAC_REF_OUT);
>>> +
>>> +    bsp_priv->aclk_mac =3D clk_get(dev, ACLK_MAC);
>>> +    if (IS_ERR(bsp_priv->aclk_mac))
>>> +        pr_warn("%s: warning: cannot get clock %s\n",
>>> +            __func__, ACLK_MAC);
>>> +
>>> +    bsp_priv->pclk_mac =3D clk_get(dev, PCLK_MAC);
>>> +    if (IS_ERR(bsp_priv->pclk_mac))
>>> +        pr_warn("%s: warning: cannot get clock %s\n",
>>> +            __func__, PCLK_MAC);
>>> +
>>> +    bsp_priv->clk_mac_pll =3D clk_get(dev, CLK_MAC_PLL);
>>> +    if (IS_ERR(bsp_priv->clk_mac_pll))
>>> +        pr_warn("%s: warning: cannot get clock %s\n",
>>> +            __func__, CLK_MAC_PLL);
>>> +
>>> +    bsp_priv->gmac_clkin =3D clk_get(dev, MAC_CLKIN);
>>> +    if (IS_ERR(bsp_priv->gmac_clkin))
>>> +        pr_warn("%s: warning: cannot get clock %s\n",
>>> +            __func__, MAC_CLKIN);
>>> +
>>> +    bsp_priv->clk_mac =3D clk_get(dev, CLK_MAC);
>>> +    if (IS_ERR(bsp_priv->clk_mac))
>>> +        pr_warn("%s: warning: cannot get clock %s\n",
>>> +            __func__, CLK_MAC);
>> there is not clk_put in the _remove case ... maybe you could simply =
use
>> devm_clk_get here so that all clocks are put on device removal.
>>
>> Also you're warning on every missing clock. Below it looks like you=20
>> need a
>> different set of them for rgmii and rmii, so maybe you should simply=
=20
>> error out
>> when core clocks for the selected phy-mode are missing.
>>
>>
>>> +
>>> +    if (bsp_priv->clock_input) {
>>> +        pr_info("%s: clock input from PHY\n", __func__);
>>> +    } else {
>>> +        if (bsp_priv->phy_iface =3D=3D PHY_INTERFACE_MODE_RMII)
>>> +            clk_set_rate(bsp_priv->clk_mac_pll, 50000000);
>>> +
>>> +        clk_set_parent(bsp_priv->clk_mac, bsp_priv->clk_mac_pll);
>> why the explicit reparenting. The common clock-framework is=20
>> intelligent enough
>> to select the best suitable parent.
>>
>> In general I'm thinking the clock-handling inside this driver should=
 be
>> simplyfied, as the common-clock framework can handle most cases=20
>> itself. I.e. if
>> a 125MHz external clock is present and so on. But haven't looked to=20
>> deep yet.
>>
>>
>>
>>> +    }
>>> +
>>> +    return 0;
>>> +}
>>> +
>>> +static int gmac_clk_enable(struct rk_priv_data *bsp_priv, bool ena=
ble)
>>> +{
>>> +    int phy_iface =3D phy_iface =3D bsp_priv->phy_iface;
>>> +
>>> +    if (enable) {
>>> +        if (!bsp_priv->clk_enabled) {
>>> +            if (phy_iface =3D=3D PHY_INTERFACE_MODE_RMII) {
>>> +                if (!IS_ERR(bsp_priv->mac_clk_rx))
>>> +                    clk_prepare_enable(
>>> +                        bsp_priv->mac_clk_rx);
>>> +
>>> +                if (!IS_ERR(bsp_priv->clk_mac_ref))
>>> +                    clk_prepare_enable(
>>> +                        bsp_priv->clk_mac_ref);
>>> +
>>> +                if (!IS_ERR(bsp_priv->clk_mac_refout))
>>> +                    clk_prepare_enable(
>>> +                        bsp_priv->clk_mac_refout);
>>> +            }
>>> +
>>> +            if (!IS_ERR(bsp_priv->aclk_mac))
>>> +                clk_prepare_enable(bsp_priv->aclk_mac);
>>> +
>>> +            if (!IS_ERR(bsp_priv->pclk_mac))
>>> +                clk_prepare_enable(bsp_priv->pclk_mac);
>>> +
>>> +            if (!IS_ERR(bsp_priv->mac_clk_tx))
>>> +                clk_prepare_enable(bsp_priv->mac_clk_tx);
>>> +
>>> +            /**
>>> +             * if (!IS_ERR(bsp_priv->clk_mac))
>>> +             *    clk_prepare_enable(bsp_priv->clk_mac);
>>> +             */
>>> +            mdelay(5);
>>> +            bsp_priv->clk_enabled =3D true;
>>> +        }
>>> +    } else {
>>> +        if (bsp_priv->clk_enabled) {
>>> +            if (phy_iface =3D=3D PHY_INTERFACE_MODE_RMII) {
>>> +                if (!IS_ERR(bsp_priv->mac_clk_rx))
>>> +                    clk_disable_unprepare(
>>> +                        bsp_priv->mac_clk_rx);
>>> +
>>> +                if (!IS_ERR(bsp_priv->clk_mac_ref))
>>> +                    clk_disable_unprepare(
>>> +                        bsp_priv->clk_mac_ref);
>>> +
>>> +                if (!IS_ERR(bsp_priv->clk_mac_refout))
>>> +                    clk_disable_unprepare(
>>> +                        bsp_priv->clk_mac_refout);
>>> +            }
>>> +
>>> +            if (!IS_ERR(bsp_priv->aclk_mac))
>>> +                clk_disable_unprepare(bsp_priv->aclk_mac);
>>> +
>>> +            if (!IS_ERR(bsp_priv->pclk_mac))
>>> +                clk_disable_unprepare(bsp_priv->pclk_mac);
>>> +
>>> +            if (!IS_ERR(bsp_priv->mac_clk_tx))
>>> + clk_disable_unprepare(bsp_priv->mac_clk_tx);
>>> +            /**
>>> +             * if (!IS_ERR(bsp_priv->clk_mac))
>>> +             * clk_disable_unprepare(bsp_priv->clk_mac);
>>> +             */
>>> +            bsp_priv->clk_enabled =3D false;
>>> +        }
>>> +    }
>>> +
>>> +    return 0;
>>> +}
>>> +
>>> +static int power_on_by_pmu(struct rk_priv_data *bsp_priv, bool ena=
ble)
>>> +{
>>> +    struct regulator *ldo;
>>> +    char *ldostr =3D bsp_priv->pmu_regulator;
>>> +    int ret;
>>> +
>>> +    if (!ldostr) {
>>> +        pr_err("%s: no ldo found\n", __func__);
>>> +        return -1;
>>> +    }
>>> +
>>> +    ldo =3D regulator_get(NULL, ldostr);
>>> +    if (!ldo) {
>>> +        pr_err("\n%s get ldo %s failed\n", __func__, ldostr);
>>> +    } else {
>>> +        if (enable) {
>>> +            if (!regulator_is_enabled(ldo)) {
>>> +                regulator_set_voltage(ldo, 3300000, 3300000);
>>> +                ret =3D regulator_enable(ldo);
>>> +                if (ret !=3D 0)
>>> +                    pr_err("%s: fail to enable %s\n",
>>> +                           __func__, ldostr);
>>> +                else
>>> +                    pr_info("turn on ldo done.\n");
>>> +            } else {
>>> +                pr_warn("%s is enabled before enable", ldostr);
>>> +            }
>>> +        } else {
>>> +            if (regulator_is_enabled(ldo)) {
>>> +                ret =3D regulator_disable(ldo);
>>> +                if (ret !=3D 0)
>>> +                    pr_err("%s: fail to disable %s\n",
>>> +                           __func__, ldostr);
>>> +                else
>>> +                    pr_info("turn off ldo done.\n");
>>> +            } else {
>>> +                pr_warn("%s is disabled before disable",
>>> +                    ldostr);
>>> +            }
>>> +        }
>>> +        regulator_put(ldo);
>>> +    }
>>> +
>>> +    return 0;
>>> +}
>>> +
>>> +static int power_on_by_gpio(struct rk_priv_data *bsp_priv, bool=20
>>> enable)
>>> +{
>>> +    if (enable) {
>>> +        /*power on*/
>>> +        if (gpio_is_valid(bsp_priv->power_io))
>>> +            gpio_direction_output(bsp_priv->power_io,
>>> +                          bsp_priv->power_io_level);
>>> +    } else {
>>> +        /*power off*/
>>> +        if (gpio_is_valid(bsp_priv->power_io))
>>> +            gpio_direction_output(bsp_priv->power_io,
>>> +                          !bsp_priv->power_io_level);
>>> +    }
>>> +
>>> +    return 0;
>>> +}
>>> +
>>> +static int phy_power_on(struct rk_priv_data *bsp_priv, bool enable=
)
>>> +{
>>> +    int ret =3D -1;
>>> +
>>> +    pr_info("Ethernet PHY power %s\n", enable =3D=3D 1 ? "on" : "o=
ff");
>>> +
>>> +    if (bsp_priv->power_ctrl_by_pmu)
>>> +        ret =3D power_on_by_pmu(bsp_priv, enable);
>>> +    else
>>> +        ret =3D  power_on_by_gpio(bsp_priv, enable);
>> this looks wrong. This should always be a regulator. Even a regulato=
r=20
>> + switch
>> controlled by a gpio can still be modelled as regulator, so that you=
=20
>> don't
>> need this switch and assorted special handling - so just use the=20
>> regulator API
>>
> In some case, it would be a switching circuit to control the power fo=
r=20
> PHY.
> All I need to do is to control a GPIO to make switch on/off. So...
>>> +
>>> +    if (enable) {
>>> +        /*reset*/
>>> +        if (gpio_is_valid(bsp_priv->reset_io)) {
>>> +            gpio_direction_output(bsp_priv->reset_io,
>>> +                          bsp_priv->reset_io_level);
>>> +            mdelay(5);
>>> +            gpio_direction_output(bsp_priv->reset_io,
>>> +                          !bsp_priv->reset_io_level);
>>> +        }
>>> +        mdelay(30);
>>> +
>>> +    } else {
>>> +        /*pull down reset*/
>>> +        if (gpio_is_valid(bsp_priv->reset_io)) {
>>> +            gpio_direction_output(bsp_priv->reset_io,
>>> +                          bsp_priv->reset_io_level);
>>> +        }
>>> +    }
>> I'm not sure yet if it would be better to use the reset framework fo=
r=20
>> this.
>> While it says it is also meant for reset-gpios, there does not seem =
a=20
>> driver
>> for this to exist yet.
>>
> What should I do?
>>
>>> +
>>> +    return ret;
>>> +}
>>> +
>>> +#define GPIO_PHY_POWER    "gmac_phy_power"
>>> +#define GPIO_PHY_RESET    "gmac_phy_reset"
>>> +#define GPIO_PHY_IRQ    "gmac_phy_irq"
>> again I don't understand why these constants are necessary
>>
>>> +
>>> +static void *rk_gmac_setup(struct platform_device *pdev)
>>> +{
>>> +    struct rk_priv_data *bsp_priv;
>>> +    struct device *dev =3D &pdev->dev;
>>> +    enum of_gpio_flags flags;
>>> +    int ret;
>>> +    const char *strings =3D NULL;
>>> +    int value;
>>> +    int irq;
>>> +
>>> +    bsp_priv =3D devm_kzalloc(dev, sizeof(*bsp_priv), GFP_KERNEL);
>>> +    if (!bsp_priv)
>>> +        return ERR_PTR(-ENOMEM);
>>> +
>>> +    bsp_priv->phy_iface =3D of_get_phy_mode(dev->of_node);
>>> +
>>> +    ret =3D of_property_read_string(dev->of_node, "pmu_regulator",=
=20
>>> &strings);
>>> +    if (ret) {
>>> +        pr_err("%s: Can not read property: pmu_regulator.\n",=20
>>> __func__);
>>> +        bsp_priv->power_ctrl_by_pmu =3D false;
>>> +    } else {
>>> +        pr_info("%s: ethernet phy power controlled by pmu(%s).\n",
>>> +            __func__, strings);
>>> +        bsp_priv->power_ctrl_by_pmu =3D true;
>>> +        strcpy(bsp_priv->pmu_regulator, strings);
>>> +    }
>> There is a generic regulator-dt-binding for regulator-consumers=20
>> available
>> which you should of course use.
>>
> The same explanation as above
>>> +
>>> +    ret =3D of_property_read_u32(dev->of_node, "pmu_enable_level",=
=20
>>> &value);
>>> +    if (ret) {
>>> +        pr_err("%s: Can not read property: pmu_enable_level.\n",
>>> +               __func__);
>>> +        bsp_priv->power_ctrl_by_pmu =3D false;
>>> +    } else {
>>> +        pr_info("%s: PHY power controlled by pmu(level =3D %s).\n"=
,
>>> +            __func__, (value =3D=3D 1) ? "HIGH" : "LOW");
>>> +        bsp_priv->power_ctrl_by_pmu =3D true;
>>> +        bsp_priv->pmu_enable_level =3D value;
>>> +    }
>> What is this used for? Enabling should of course be done via=20
>> regulator_enable
>> and disabling using regulator_disable.
>>
>>
>>> +
>>> +    ret =3D of_property_read_string(dev->of_node, "clock_in_out",=20
>>> &strings);
>>> +    if (ret) {
>>> +        pr_err("%s: Can not read property: clock_in_out.\n",=20
>>> __func__);
>>> +        bsp_priv->clock_input =3D true;
>>> +    } else {
>>> +        pr_info("%s: clock input or output? (%s).\n",
>>> +            __func__, strings);
>>> +        if (!strcmp(strings, "input"))
>>> +            bsp_priv->clock_input =3D true;
>>> +        else
>>> +            bsp_priv->clock_input =3D false;
>>> +    }
>>> +
>>> +    ret =3D of_property_read_u32(dev->of_node, "tx_delay", &value)=
;
>>> +    if (ret) {
>>> +        bsp_priv->tx_delay =3D 0x30;
>>> +        pr_err("%s: Can not read property: tx_delay.", __func__);
>>> +        pr_err("%s: set tx_delay to 0x%x\n",
>>> +               __func__, bsp_priv->tx_delay);
>>> +    } else {
>>> +        pr_info("%s: TX delay(0x%x).\n", __func__, value);
>>> +        bsp_priv->tx_delay =3D value;
>>> +    }
>>> +
>>> +    ret =3D of_property_read_u32(dev->of_node, "rx_delay", &value)=
;
>>> +    if (ret) {
>>> +        bsp_priv->rx_delay =3D 0x10;
>>> +        pr_err("%s: Can not read property: rx_delay.", __func__);
>>> +        pr_err("%s: set rx_delay to 0x%x\n",
>>> +               __func__, bsp_priv->rx_delay);
>>> +    } else {
>>> +        pr_info("%s: RX delay(0x%x).\n", __func__, value);
>>> +        bsp_priv->rx_delay =3D value;
>>> +    }
>>> +
>>> +    bsp_priv->grf =3D syscon_regmap_lookup_by_phandle(dev->of_node=
,
>>> +                            "rockchip,grf");
>>> +    bsp_priv->phyirq_io =3D
>>> +        of_get_named_gpio_flags(dev->of_node,
>>> +                    "phyirq-gpio", 0, &flags);
>>> +    bsp_priv->phyirq_io_level =3D (flags & OF_GPIO_ACTIVE_LOW) ? 0=
 : 1;
>>> +
>>> +    bsp_priv->reset_io =3D
>>> +        of_get_named_gpio_flags(dev->of_node,
>>> +                    "reset-gpio", 0, &flags);
>>> +    bsp_priv->reset_io_level =3D (flags & OF_GPIO_ACTIVE_LOW) ? 0 =
: 1;
>>> +
>>> +    bsp_priv->power_io =3D
>>> +        of_get_named_gpio_flags(dev->of_node, "power-gpio", 0,=20
>>> &flags);
>>> +    bsp_priv->power_io_level =3D (flags & OF_GPIO_ACTIVE_LOW) ? 0 =
: 1;
>>> +
>>> +    /*power*/
>>> +    if (!gpio_is_valid(bsp_priv->power_io)) {
>>> +        pr_err("%s: Failed to get GPIO %s.\n",
>>> +               __func__, "power-gpio");
>>> +    } else {
>>> +        ret =3D gpio_request(bsp_priv->power_io, GPIO_PHY_POWER);
>>> +        if (ret)
>>> +            pr_err("%s: ERROR: Failed to request GPIO %s.\n",
>>> +                   __func__, GPIO_PHY_POWER);
>>> +    }
>> When everything power-related is handled using the regulator api, yo=
u=20
>> don't
>> need this
> The same explanation as above
>>
>>> +
>>> +    if (!gpio_is_valid(bsp_priv->reset_io)) {
>>> +        pr_err("%s: ERROR: Get reset-gpio failed.\n", __func__);
>>> +    } else {
>>> +        ret =3D gpio_request(bsp_priv->reset_io, GPIO_PHY_RESET);
>>> +        if (ret)
>>> +            pr_err("%s: ERROR: Failed to request GPIO %s.\n",
>>> +                   __func__, GPIO_PHY_RESET);
>>> +    }
>>> +
>>> +    if (bsp_priv->phyirq_io > 0) {
>> This is more for my understanding: why does the mac driver need to=20
>> handle the
>> phy interrupt - but I might be overlooking something.
>>
> phy interrupt is not mandatory.  In most of the time,  in order to=20
> find something happen in PHY, for example,
> link is up or down,  we just use polling method to read the phy's=20
> register in a timer.
> Buf if phy interrupt is in use, when link is up or down,  phy=20
> interrupt pin will be assert to inform the CPU.
> I just implement the driver for phy interrupt gpio,  not enable it as=
=20
> default.
>
>>> +        struct plat_stmmacenet_data *plat_dat;
>>> +
>>> +        pr_info("PHY irq in use\n");
>>> +        ret =3D gpio_request(bsp_priv->phyirq_io, GPIO_PHY_IRQ);
>>> +        if (ret < 0) {
>>> +            pr_warn("%s: Failed to request GPIO %s\n",
>>> +                __func__, GPIO_PHY_IRQ);
>>> +            goto goon;
>>> +        }
>>> +
>>> +        ret =3D gpio_direction_input(bsp_priv->phyirq_io);
>>> +        if (ret < 0) {
>>> +            pr_err("%s, Failed to set input for GPIO %s\n",
>>> +                   __func__, GPIO_PHY_IRQ);
>>> +            gpio_free(bsp_priv->phyirq_io);
>>> +            goto goon;
>>> +        }
>>> +
>>> +        irq =3D gpio_to_irq(bsp_priv->phyirq_io);
>>> +        if (irq < 0) {
>>> +            ret =3D irq;
>>> +            pr_err("Failed to set irq for %s\n",
>>> +                   GPIO_PHY_IRQ);
>>> +            gpio_free(bsp_priv->phyirq_io);
>>> +            goto goon;
>>> +        }
>>> +
>>> +        plat_dat =3D dev_get_platdata(&pdev->dev);
>>> +        if (plat_dat)
>>> +            plat_dat->mdio_bus_data->probed_phy_irq =3D irq;
>>> +        else
>>> +            pr_err("%s: plat_data is NULL\n", __func__);
>>> +    }
>>> +
>>> +goon:
>>> +    /*rmii or rgmii*/
>>> +    if (bsp_priv->phy_iface =3D=3D PHY_INTERFACE_MODE_RGMII) {
>>> +        pr_info("%s: init for RGMII\n", __func__);
>>> +        set_to_rgmii(bsp_priv, bsp_priv->tx_delay,=20
>>> bsp_priv->rx_delay);
>>> +    } else if (bsp_priv->phy_iface =3D=3D PHY_INTERFACE_MODE_RMII)=
 {
>>> +        pr_info("%s: init for RMII\n", __func__);
>>> +        set_to_rmii(bsp_priv);
>>> +    } else {
>>> +        pr_err("%s: ERROR: NO interface defined!\n", __func__);
>>> +    }
>>> +
>>> +    bsp_priv->pdev =3D pdev;
>>> +
>>> +    gmac_clk_init(bsp_priv);
>>> +
>>> +    return bsp_priv;
>>> +}
>>> +
>>> +static int rk_gmac_init(struct platform_device *pdev, void *priv)
>>> +{
>>> +    struct rk_priv_data *bsp_priv =3D priv;
>>> +    int ret;
>>> +
>>> +    ret =3D phy_power_on(bsp_priv, true);
>>> +    if (ret)
>>> +        return ret;
>>> +
>>> +    ret =3D gmac_clk_enable(bsp_priv, true);
>>> +    if (ret)
>>> +        return ret;
>>> +
>>> +    return 0;
>>> +}
>>> +
>>> +static void rk_gmac_exit(struct platform_device *pdev, void *priv)
>>> +{
>>> +    struct rk_priv_data *gmac =3D priv;
>>> +
>>> +    phy_power_on(gmac, false);
>>> +    gmac_clk_enable(gmac, false);
>>> +}
>>> +
>>> +static void rk_fix_speed(void *priv, unsigned int speed)
>>> +{
>>> +    struct rk_priv_data *bsp_priv =3D priv;
>>> +
>>> +    if (bsp_priv->phy_iface =3D=3D PHY_INTERFACE_MODE_RGMII)
>>> +        set_rgmii_speed(bsp_priv, speed);
>>> +    else if (bsp_priv->phy_iface =3D=3D PHY_INTERFACE_MODE_RMII)
>>> +        set_rmii_speed(bsp_priv, speed);
>>> +    else
>>> +        pr_err("unsupported interface %d", bsp_priv->phy_iface);
>>> +}
>>> +
>>> +const struct stmmac_of_data rk_gmac_data =3D {
>>> +    .has_gmac =3D 1,
>>> +    .fix_mac_speed =3D rk_fix_speed,
>>> +    .setup =3D rk_gmac_setup,
>>> +    .init =3D rk_gmac_init,
>>> +    .exit =3D rk_gmac_exit,
>>> +};
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c index
>>> 15814b7..b4dee96 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>>> @@ -33,6 +33,7 @@
>>>
>>>   static const struct of_device_id stmmac_dt_ids[] =3D {
>>>       /* SoC specific glue layers should come before generic=20
>>> bindings */
>>> +    { .compatible =3D "rockchip,rk3288-gmac", .data =3D &rk_gmac_d=
ata},
>> please name that rk3288_gmac_data [of course the other occurences to=
o]
>> It makes it easier to see which soc it is meant for and it's also no=
t=20
>> save to
>> assume that the next one will use the same register + bit positions=20
>> in the
>> grf.
>>
>>
>>>       { .compatible =3D "amlogic,meson6-dwmac", .data =3D=20
>>> &meson6_dwmac_data},
>>>       { .compatible =3D "allwinner,sun7i-a20-gmac", .data =3D=20
>>> &sun7i_gmac_data},
>>>       { .compatible =3D "st,stih415-dwmac", .data =3D &stih4xx_dwma=
c_data},
>>> @@ -291,6 +292,8 @@ static int stmmac_pltfr_probe(struct=20
>>> platform_device
>>> *pdev) return  -ENOMEM;
>>>           }
>>>
>>> +        pdev->dev.platform_data =3D plat_dat;
>>> +
>>>           ret =3D stmmac_probe_config_dt(pdev, plat_dat, &mac);
>>>           if (ret) {
>>>               pr_err("%s: main dt probe failed", __func__);
>>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
>>> b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h index
>>> 25dd1f7..32a0516 100644
>>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
>>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.h
>>> @@ -24,5 +24,6 @@ extern const struct stmmac_of_data sun7i_gmac_dat=
a;
>>>   extern const struct stmmac_of_data stih4xx_dwmac_data;
>>>   extern const struct stmmac_of_data stid127_dwmac_data;
>>>   extern const struct stmmac_of_data socfpga_gmac_data;
>>> +extern const struct stmmac_of_data rk_gmac_data;
>>>
>>>   #endif /* __STMMAC_PLATFORM_H__ */
>>
>>
>
