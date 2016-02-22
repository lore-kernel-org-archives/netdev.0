From: Alexandre Torgue <alexandre.torgue@gmail.com>
Subject: Re: [PATCH 1/4] net: ethernet: dwmac: add Ethernet glue logic for
 stm32 chip
Date: Mon, 22 Feb 2016 15:50:46 +0100
Message-ID: <CAJgp7zwOVEq=hnxfUt7eHZWSFUAwuK6MCVHdH591=xReRUsW8Q@mail.gmail.com>
References: <1454511275-9791-1-git-send-email-alexandre.torgue@gmail.com>
	<1454511275-9791-2-git-send-email-alexandre.torgue@gmail.com>
	<CAGhQ9VypZ5J0pQmrf1Mk-mNsv=XTXu7fhoLt_r2LHJ_Lsyj0yA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joachim Eastwood <manabian@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGhQ9VypZ5J0pQmrf1Mk-mNsv=XTXu7fhoLt_r2LHJ_Lsyj0yA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-02-13 14:48 GMT+01:00 Joachim  Eastwood <manabian@gmail.com>:
> On 3 February 2016 at 15:54, Alexandre TORGUE
> <alexandre.torgue@gmail.com> wrote:
>> stm324xx family chips support Synopsys MAC 3.510 IP.
>> This patch adds settings for logical glue logic:
>> -clocks
>> -mode selection MII or RMII.
>>
>> Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
>> index cec147d..a94dd15 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
>> +++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
>> @@ -114,6 +114,18 @@ config DWMAC_SUNXI
>>           This selects Allwinner SoC glue layer support for the
>>           stmmac device driver. This driver is used for A20/A31
>>           GMAC ethernet controller.
>> +
>> +config DWMAC_STM32
>> +       tristate "STM32 DWMAC support"
>> +       default ARCH_STM32
>> +       depends on OF
>> +       select MFD_SYSCON
>> +       ---help---
>> +         Support for ethernet controller on STM32 SOCs.
>> +
>> +         This selects STM32 SoC glue layer support for the stmmac
>> +         device driver. This driver is used on for the STM32 series
>> +         SOCs GMAC ethernet controller.
>>  endif
>>
>>  config STMMAC_PCI
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
>> index b390161..9fb2061 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/Makefile
>> +++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
>> @@ -14,6 +14,7 @@ obj-$(CONFIG_DWMAC_SOCFPGA)   += dwmac-socfpga.o
>>  obj-$(CONFIG_DWMAC_STI)                += dwmac-sti.o
>>  obj-$(CONFIG_DWMAC_SUNXI)      += dwmac-sunxi.o
>>  obj-$(CONFIG_DWMAC_GENERIC)    += dwmac-generic.o
>> +obj-$(CONFIG_DWMAC_STM32)      += dwmac-stm32.o
>
> Keep these sorted. There also a comment in the Makefile that states
> that the generic should always be last.

ok
>
>
>>  stmmac-platform-objs:= stmmac_platform.o
>>
>>  obj-$(CONFIG_STMMAC_PCI) += stmmac-pci.o
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
>> new file mode 100644
>> index 0000000..56ccc20
>> --- /dev/null
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
>> @@ -0,0 +1,177 @@
>> +/*
>> + * dwmac-stm32.c - DWMAC Specific Glue layer for STM32 MCU
>> + *
>> + * Copyright (C) Alexandre Torgue 2015
>> + * Author:  Alexandre Torgue <alexandre.torgue@gmail.com>
>> + * License terms:  GNU General Public License (GPL), version 2
>> + *
>> + */
>> +
>> +#include <linux/kernel.h>
>> +#include <linux/slab.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/stmmac.h>
>> +#include <linux/phy.h>
>> +#include <linux/mfd/syscon.h>
>> +#include <linux/module.h>
>> +#include <linux/regmap.h>
>> +#include <linux/clk.h>
>> +#include <linux/of.h>
>> +#include <linux/of_device.h>
>> +#include <linux/of_net.h>
>
> Consider sorting the includes.

ok
>
>> +
>> +#include "stmmac_platform.h"
>> +
>> +#define MII_PHY_SEL_MASK       BIT(23)
>> +
>> +struct stm32_dwmac {
>> +       int interface;          /* MII interface */
>> +       struct clk *clk_tx;
>> +       struct clk *clk_rx;
>> +       u32 mode_reg;           /* MAC glue-logic mode register */
>> +       struct device *dev;
>
> dev doesn't seem to be used anywhere.

ok
>
>> +       struct regmap *regmap;
>> +       u32 speed;
>> +};
>> +
>> +static int stm32_dwmac_init(struct platform_device *pdev, void *priv)
>> +{
>> +       struct stm32_dwmac *dwmac = priv;
>> +       struct regmap *regmap = dwmac->regmap;
>> +       int ret, iface = dwmac->interface;
>> +       u32 reg = dwmac->mode_reg;
>> +       u32 val;
>> +
>> +       if (dwmac->clk_tx)
>> +               ret = clk_prepare_enable(dwmac->clk_tx);
>
> The clk API handles a NULL clk so you don't really need to check for it.

I agree
>
>
>> +               if (ret)
>> +                       goto out;
>> +
>> +       if (dwmac->clk_rx)
>> +               ret = clk_prepare_enable(dwmac->clk_rx);
>
> Same here.
I agree
>
>
>> +               if (ret)
>> +                       goto out_disable_clk_tx;
>> +
>> +       val = (iface == PHY_INTERFACE_MODE_MII) ? 0 : 1;
>> +       ret = regmap_update_bits(regmap, reg, MII_PHY_SEL_MASK, val);
>> +       if (ret)
>> +               goto out_disable_clk_tx_rx;
>> +
>> +       return 0;
>> +
>> +out_disable_clk_tx_rx:
>> +       clk_disable_unprepare(dwmac->clk_rx);
>> +out_disable_clk_tx:
>> +       clk_disable_unprepare(dwmac->clk_tx);
>> +out:
>> +       return ret;
>> +}
>> +
>> +static void stm32_dwmac_exit(struct platform_device *pdev, void *priv)
>> +{
>> +       struct stm32_dwmac *dwmac = priv;
>> +
>> +       if (dwmac->clk_tx)
>> +               clk_disable_unprepare(dwmac->clk_tx);
>> +       if (dwmac->clk_rx)
>> +               clk_disable_unprepare(dwmac->clk_rx);
>
> Same here.
I agree
>
>
>> +}
>> +
>> +static int stm32_dwmac_parse_data(struct stm32_dwmac *dwmac,
>> +                                 struct platform_device *pdev)
>> +{
>> +       struct device *dev = &pdev->dev;
>> +       struct device_node *np = dev->of_node;
>> +       struct regmap *regmap;
>> +       int err;
>> +
>> +       if (!np)
>> +               return -EINVAL;
>
> Can this ever happen?
> This is a DT only driver, right?
You're right. It is only DT.
>
>> +
>> +       /*  Get TX/RX clocks */
>> +       dwmac->clk_tx = devm_clk_get(dev, "tx-clk");
>> +       if (IS_ERR(dwmac->clk_tx)) {
>> +               dev_warn(dev, "No tx clock provided...\n");
>> +               dwmac->clk_tx = NULL;
>> +       }
>> +       dwmac->clk_rx = devm_clk_get(dev, "rx-clk");
>> +       if (IS_ERR(dwmac->clk_rx)) {
>> +               dev_warn(dev, "No rx clock provided...\n");
>> +               dwmac->clk_rx = NULL;
>> +       }
>> +
>> +       /* Get mode register */
>> +       regmap = syscon_regmap_lookup_by_phandle(np, "st,syscon");
>> +       if (IS_ERR(regmap))
>> +               return PTR_ERR(regmap);
>> +
>> +       err = of_property_read_u32_index(np, "st,syscon", 1, &dwmac->mode_reg);
>> +       if (err) {
>> +               dev_err(dev, "Can't get sysconfig mode offset (%d)\n", err);
>> +               return err;
>> +       }
>> +
>> +       dwmac->dev = dev;
>> +       dwmac->interface = of_get_phy_mode(np);
>> +       dwmac->regmap = regmap;
>> +
>> +       return 0;
>> +}
>> +
>> +static int stm32_dwmac_probe(struct platform_device *pdev)
>> +{
>> +       struct plat_stmmacenet_data *plat_dat;
>> +       struct stmmac_resources stmmac_res;
>> +       struct stm32_dwmac *dwmac;
>> +       int ret;
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
>> +       ret = stm32_dwmac_parse_data(dwmac, pdev);
>> +       if (ret) {
>> +               dev_err(&pdev->dev, "Unable to parse OF data\n");
>> +               return ret;
>> +       }
>> +
>> +       plat_dat->bsp_priv = dwmac;
>> +       plat_dat->init = stm32_dwmac_init;
>> +       plat_dat->exit = stm32_dwmac_exit;
>
> Instead of using these callbacks could you rather implement the PM
> callbacks directly in this driver?
> I don't think it should add much code and it will make it look more
> like standard driver. This will also give you some more control and
> flexibility in your code.

I prefer to keep the code as it is. Glue layer is directly linked to
stmmac driver and I don't want to brake the link between the glue and
the stmmac driver.

>
>> +
>> +       ret = stm32_dwmac_init(pdev, plat_dat->bsp_priv);
>> +       if (ret)
>> +               return ret;
>> +
>> +       return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
>> +}
>> +
>> +static const struct of_device_id stm32_dwmac_match[] = {
>> +       { .compatible = "st,stm32-dwmac"},
>> +       { }
>> +};
>> +MODULE_DEVICE_TABLE(of, stm32_dwmac_match);
>> +
>> +static struct platform_driver stm32_dwmac_driver = {
>> +       .probe  = stm32_dwmac_probe,
>> +       .remove = stmmac_pltfr_remove,
>
> Could you implement the .remove callback in your driver instead of
> using stmmac_pltfr_remove?
> Same reasons as above.

As explain above, I prefere to keep the code as it is in order to not
remove glue layer before the stmmac driver.

>
>
>> +       .driver = {
>> +               .name           = "stm32-dwmac",
>> +               .pm             = &stmmac_pltfr_pm_ops,
>> +               .of_match_table = stm32_dwmac_match,
>> +       },
>> +};
>> +module_platform_driver(stm32_dwmac_driver);
>> +
>> +MODULE_AUTHOR("Alexandre Torgue <alexandre.torgue@gmail.com>");
>> +MODULE_DESCRIPTION("STMicroelectronics MCU DWMAC Specific Glue layer");
>> +MODULE_LICENSE("GPL");
>
> Since you state:
>> + * License terms:  GNU General Public License (GPL), version 2
>
> You might want to switch use: MODULE_LICENSE("GPL v2");
>
I agree.
>
> regards,
> Joachim Eastwood

Thanks Joachim for the review and remarks. Main will be corrected in
next patch version.

regards
Alexandre Torgue
