From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH] net: stmmac: Add OXNAS Glue Driver
Date: Fri, 21 Oct 2016 16:43:14 +0200
Message-ID: <c817b14d-bb00-715d-50ca-21dfed60a567@baylibre.com>
References: <20161021084445.24989-1-narmstrong@baylibre.com>
 <CAGhQ9Vxe8fe8kfF_WY40xdh6YX9TuxQ3-Dd6pBG=AHpLtrHnMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "peppe.cavallaro" <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, netdev <netdev@vger.kernel.org>,
        linux-oxnas@lists.tuxfamily.org,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        devicetree <devicetree@vger.kernel.org>
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGhQ9Vxe8fe8kfF_WY40xdh6YX9TuxQ3-Dd6pBG=AHpLtrHnMA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/21/2016 12:20 PM, Joachim Eastwood wrote:
> Hi Neil,
> 
> On 21 October 2016 at 10:44, Neil Armstrong <narmstrong@baylibre.com> wrote:
>> Add Synopsys Designware MAC Glue layer for the Oxford Semiconductor OX820.
>>
>> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
>> ---
>>  .../devicetree/bindings/net/oxnas-dwmac.txt        |  44 +++++
>>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |  11 ++
>>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>>  drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c  | 219 +++++++++++++++++++++
>>  4 files changed, 275 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/oxnas-dwmac.txt
>>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
>>
>> Changes since RFC at https://patchwork.kernel.org/patch/9387257 :
>>  - Drop init/exit callbacks
>>  - Implement proper remove and PM callback
>>  - Call init from probe
>>  - Disable/Unprepare clock if stmmac probe fails
> 
> <snip>
> 
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
>> @@ -0,0 +1,219 @@
>> +/*
>> + * Oxford Semiconductor OXNAS DWMAC glue layer
>> + *
>> + * Copyright (C) 2016 Neil Armstrong <narmstrong@baylibre.com>
>> + * Copyright (C) 2014 Daniel Golle <daniel@makrotopia.org>
>> + * Copyright (C) 2013 Ma Haijun <mahaijuns@gmail.com>
>> + * Copyright (C) 2012 John Crispin <blogic@openwrt.org>
>> + *
>> + * This program is free software; you can redistribute it and/or modify
>> + * it under the terms of the GNU General Public License version 2 as
>> + * published by the Free Software Foundation.
>> + *
>> + * You should have received a copy of the GNU General Public License
>> + * along with this program. If not, see <http://www.gnu.org/licenses/>.
>> + */
>> +
>> +#include <linux/device.h>
>> +#include <linux/io.h>
>> +#include <linux/module.h>
>> +#include <linux/of.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/regmap.h>
>> +#include <linux/mfd/syscon.h>
>> +#include <linux/stmmac.h>
>> +
>> +#include "stmmac_platform.h"
>> +
>> +/* System Control regmap offsets */
>> +#define OXNAS_DWMAC_CTRL_REGOFFSET     0x78
>> +#define OXNAS_DWMAC_DELAY_REGOFFSET    0x100
>> +
>> +/* Control Register */
>> +#define DWMAC_CKEN_RX_IN        14
>> +#define DWMAC_CKEN_RXN_OUT      13
>> +#define DWMAC_CKEN_RX_OUT       12
>> +#define DWMAC_CKEN_TX_IN        10
>> +#define DWMAC_CKEN_TXN_OUT      9
>> +#define DWMAC_CKEN_TX_OUT       8
>> +#define DWMAC_RX_SOURCE         7
>> +#define DWMAC_TX_SOURCE         6
>> +#define DWMAC_LOW_TX_SOURCE     4
>> +#define DWMAC_AUTO_TX_SOURCE    3
>> +#define DWMAC_RGMII             2
>> +#define DWMAC_SIMPLE_MUX        1
>> +#define DWMAC_CKEN_GTX          0
>> +
>> +/* Delay register */
>> +#define DWMAC_TX_VARDELAY_SHIFT                0
>> +#define DWMAC_TXN_VARDELAY_SHIFT       8
>> +#define DWMAC_RX_VARDELAY_SHIFT                16
>> +#define DWMAC_RXN_VARDELAY_SHIFT       24
>> +#define DWMAC_TX_VARDELAY(d)           ((d) << DWMAC_TX_VARDELAY_SHIFT)
>> +#define DWMAC_TXN_VARDELAY(d)          ((d) << DWMAC_TXN_VARDELAY_SHIFT)
>> +#define DWMAC_RX_VARDELAY(d)           ((d) << DWMAC_RX_VARDELAY_SHIFT)
>> +#define DWMAC_RXN_VARDELAY(d)          ((d) << DWMAC_RXN_VARDELAY_SHIFT)
>> +
>> +struct oxnas_dwmac {
>> +       struct device   *dev;
>> +       struct clk      *clk;
>> +       struct regmap   *regmap;
>> +};
>> +
>> +static int oxnas_dwmac_init(struct oxnas_dwmac *dwmac)
>> +{
>> +       unsigned int value;
>> +       int ret;
>> +
>> +       /* Reset HW here before changing the glue configuration */
>> +       ret = device_reset(dwmac->dev);
>> +       if (ret)
>> +               return ret;
>> +
>> +       clk_prepare_enable(dwmac->clk);
> 
> You might want to check the return value from clk_prepare_enable() as well.
> 
>> +
>> +       ret = regmap_read(dwmac->regmap, OXNAS_DWMAC_CTRL_REGOFFSET, &value);
>> +       if (ret < 0)
>> +               return ret;
>> +
>> +       /* Enable GMII_GTXCLK to follow GMII_REFCLK, required for gigabit PHY */
>> +       value |= BIT(DWMAC_CKEN_GTX);
>> +       /* Use simple mux for 25/125 Mhz clock switching */
>> +       value |= BIT(DWMAC_SIMPLE_MUX);
>> +       /* set auto switch tx clock source */
>> +       value |= BIT(DWMAC_AUTO_TX_SOURCE);
>> +       /* enable tx & rx vardelay */
>> +       value |= BIT(DWMAC_CKEN_TX_OUT);
>> +       value |= BIT(DWMAC_CKEN_TXN_OUT);
>> +       value |= BIT(DWMAC_CKEN_TX_IN);
>> +       value |= BIT(DWMAC_CKEN_RX_OUT);
>> +       value |= BIT(DWMAC_CKEN_RXN_OUT);
>> +       value |= BIT(DWMAC_CKEN_RX_IN);
>> +       regmap_write(dwmac->regmap, OXNAS_DWMAC_CTRL_REGOFFSET, value);
>> +
>> +       /* set tx & rx vardelay */
>> +       value = DWMAC_TX_VARDELAY(4);
>> +       value |= DWMAC_TXN_VARDELAY(2);
>> +       value |= DWMAC_RX_VARDELAY(10);
>> +       value |= DWMAC_RXN_VARDELAY(8);
>> +       regmap_write(dwmac->regmap, OXNAS_DWMAC_DELAY_REGOFFSET, value);
>> +
>> +       return 0;
>> +}
>> +
>> +static int oxnas_dwmac_probe(struct platform_device *pdev)
>> +{
>> +       struct plat_stmmacenet_data *plat_dat;
>> +       struct stmmac_resources stmmac_res;
>> +       struct device_node *sysctrl;
>> +       struct oxnas_dwmac *dwmac;
>> +       int ret;
>> +
>> +       sysctrl = of_parse_phandle(pdev->dev.of_node, "oxsemi,sys-ctrl", 0);
>> +       if (!sysctrl) {
>> +               dev_err(&pdev->dev, "failed to get sys-ctrl node\n");
>> +               return -EINVAL;
>> +       }
>> +
>> +       ret = stmmac_get_platform_resources(pdev, &stmmac_res);
>> +       if (ret)
>> +               return ret;
>> +
>> +       plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
>> +       if (IS_ERR(plat_dat))
>> +               return PTR_ERR(plat_dat);
>> +
>> +       dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
>> +       if (!dwmac)
>> +               return -ENOMEM;
>> +
>> +       dwmac->dev = &pdev->dev;
>> +       plat_dat->bsp_priv = dwmac;
>> +
>> +       dwmac->regmap = syscon_node_to_regmap(sysctrl);
>> +       if (IS_ERR(dwmac->regmap)) {
>> +               dev_err(&pdev->dev, "failed to have sysctrl regmap\n");
>> +               return PTR_ERR(dwmac->regmap);
>> +       }
>> +
>> +       dwmac->clk = devm_clk_get(&pdev->dev, "gmac");
>> +       if (IS_ERR(dwmac->clk))
>> +               return PTR_ERR(dwmac->clk);
>> +
>> +       ret = oxnas_dwmac_init(dwmac);
>> +       if (ret)
>> +               return ret;
>> +
>> +       ret = stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
>> +       if (ret)
>> +               clk_disable_unprepare(dwmac->clk);
>> +
>> +       return ret;
>> +}
>> +
>> +static int oxnas_dwmac_remove(struct platform_device *pdev)
>> +{
>> +       struct net_device *ndev = platform_get_drvdata(pdev);
>> +       struct stmmac_priv *priv = netdev_priv(ndev);
>> +       struct oxnas_dwmac *dwmac = priv->plat->bsp_priv;
> 
> Instead of this long dance of variables use the get_stmmac_bsp_priv()-helper.
> 
> You can take a look at dwmac-meson8b.c for reference.
> 
> 
>> +       int ret = stmmac_dvr_remove(&pdev->dev);
>> +
>> +       clk_disable_unprepare(dwmac->clk);
>> +
>> +       return ret;
>> +}
>> +
>> +#ifdef CONFIG_PM_SLEEP
>> +static int oxnas_dwmac_suspend(struct device *dev)
>> +{
>> +       struct net_device *ndev = dev_get_drvdata(dev);
>> +       struct stmmac_priv *priv = netdev_priv(ndev);
>> +       struct oxnas_dwmac *dwmac = priv->plat->bsp_priv;
> 
> get_stmmac_bsp_priv()
> 
> 
>> +       int ret;
>> +
>> +       ret = stmmac_suspend(dev);
>> +       clk_disable_unprepare(dwmac->clk);
>> +
>> +       return ret;
>> +}
>> +
>> +static int oxnas_dwmac_resume(struct device *dev)
>> +{
>> +       struct net_device *ndev = dev_get_drvdata(dev);
>> +       struct stmmac_priv *priv = netdev_priv(ndev);
>> +       struct oxnas_dwmac *dwmac = priv->plat->bsp_priv;
> 
> get_stmmac_bsp_priv()
> 
> 
>> +       int ret;
>> +
>> +       ret = oxnas_dwmac_init(dwmac);
>> +       if (ret)
>> +               return ret;
>> +
>> +       ret = stmmac_resume(dev);
>> +
>> +       return ret;
>> +}
>> +#endif /* CONFIG_PM_SLEEP */
> 
> With these changes:
> Acked-by: Joachim Eastwood <manabian@gmail.com>
> 
> 
> best regards,
> Joachim Eastwood
> 

Thanks,
Will do this for v2

Neil
