From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH v2 1/4] net: ethernet: dwmac: add Ethernet glue logic for
 stm32 chip
Date: Tue, 23 Feb 2016 23:16:38 +0100
Message-ID: <CAGhQ9Vz8uUeyhEutTPh3Zb3C=T3F2xC7kgHorZyWcz6HW+ySmw@mail.gmail.com>
References: <1456240244-10275-1-git-send-email-alexandre.torgue@gmail.com>
	<1456240244-10275-2-git-send-email-alexandre.torgue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexandre TORGUE <alexandre.torgue@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456240244-10275-2-git-send-email-alexandre.torgue@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alexandre,

On 23 February 2016 at 16:10, Alexandre TORGUE
<alexandre.torgue@gmail.com> wrote:
> stm324xx family chips support Synopsys MAC 3.510 IP.
> This patch adds settings for logical glue logic:
> -clocks
> -mode selection MII or RMII.
>
> Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>
>
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> index cec147d..f63bdcf 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
> +++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
> @@ -114,6 +114,18 @@ config DWMAC_SUNXI
>           This selects Allwinner SoC glue layer support for the
>           stmmac device driver. This driver is used for A20/A31
>           GMAC ethernet controller.
> +
> +config DWMAC_STM32
> +       tristate "STM32 DWMAC support"
> +       default ARCH_STM32
> +       depends on OF && HAS_IOMEM
> +       select MFD_SYSCON
> +       ---help---
> +         Support for ethernet controller on STM32 SOCs.
> +
> +         This selects STM32 SoC glue layer support for the stmmac
> +         device driver. This driver is used on for the STM32 series
> +         SOCs GMAC ethernet controller.
>  endif
>
>  config STMMAC_PCI
> diff --git a/drivers/net/ethernet/stmicro/stmmac/Makefile b/drivers/net/ethernet/stmicro/stmmac/Makefile
> index b390161..559086d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/Makefile
> +++ b/drivers/net/ethernet/stmicro/stmmac/Makefile
> @@ -13,6 +13,7 @@ obj-$(CONFIG_DWMAC_ROCKCHIP)  += dwmac-rk.o
>  obj-$(CONFIG_DWMAC_SOCFPGA)    += dwmac-socfpga.o
>  obj-$(CONFIG_DWMAC_STI)                += dwmac-sti.o
>  obj-$(CONFIG_DWMAC_SUNXI)      += dwmac-sunxi.o
> +obj-$(CONFIG_DWMAC_STM32)      += dwmac-stm32.o

Put them in alphabetic order. Same goes for the KConfig entry.


>  obj-$(CONFIG_DWMAC_GENERIC)    += dwmac-generic.o
>  stmmac-platform-objs:= stmmac_platform.o
...
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-stm32.c
> +struct stm32_dwmac {
> +       int interface;          /* MII interface */
> +       struct clk *clk_tx;
> +       struct clk *clk_rx;
> +       u32 mode_reg;           /* MAC glue-logic mode register */
> +       struct regmap *regmap;
> +       u32 speed;
> +};
> +
> +static int stm32_dwmac_init(void *priv)

If you used 'struct stm32_dwmac *' instead of 'void *' you could skip
the local variable assignment.

Even better; you could pass 'struct plat_stmmacenet_data *' and use
it's 'interface' member to set the phy mode. Then you could drop the
interface member in your priv data struct and remove of_get_phy_mode()
in stm32_dwmac_parse_data().


> +{
> +       struct stm32_dwmac *dwmac = priv;
> +       struct regmap *regmap = dwmac->regmap;
> +       int ret, iface = dwmac->interface;
> +       u32 reg = dwmac->mode_reg;
> +       u32 val;
> +
> +       ret = clk_prepare_enable(dwmac->clk_tx);
> +       if (ret)
> +               goto out;
> +
> +       ret = clk_prepare_enable(dwmac->clk_rx);
> +       if (ret)
> +               goto out_disable_clk_tx;
> +
> +       val = (iface == PHY_INTERFACE_MODE_MII) ? 0 : 1;
> +       ret = regmap_update_bits(regmap, reg, MII_PHY_SEL_MASK, val);
> +       if (ret)
> +               goto out_disable_clk_tx_rx;
> +
> +       return 0;
> +
> +out_disable_clk_tx_rx:
> +       clk_disable_unprepare(dwmac->clk_rx);
> +out_disable_clk_tx:
> +       clk_disable_unprepare(dwmac->clk_tx);
> +out:
> +       return ret;
> +}
> +
> +static void stm32_dwmac_exit(void *priv)
> +{
> +       struct stm32_dwmac *dwmac = priv;

Again; instead of 'void *' use 'struct stm32_dwmac *' to avoid the
local assignment.


> +
> +       clk_disable_unprepare(dwmac->clk_tx);
> +       clk_disable_unprepare(dwmac->clk_rx);
> +}

To be honest I really don't see the point in having a function with
just two other function calls in it. Consider dropping the function
altogether and place the clk_disable_unprepare() calls where it's
called from. If you still want to keep it, please put a more
descriptive name on it.


> +static int stm32_dwmac_parse_data(struct stm32_dwmac *dwmac,
> +                                 struct platform_device *pdev)

Since you are only interested in *dev and not *pdev you could pass a
'struct dev *' instead.

> +{
> +       struct device *dev = &pdev->dev;
> +       struct device_node *np = dev->of_node;
> +       struct regmap *regmap;
> +       int err;
> +
> +       /*  Get TX/RX clocks */
> +       dwmac->clk_tx = devm_clk_get(dev, "tx-clk");
> +       if (IS_ERR(dwmac->clk_tx)) {
> +               dev_warn(dev, "No tx clock provided...\n");
> +               dwmac->clk_tx = NULL;
> +       }
> +       dwmac->clk_rx = devm_clk_get(dev, "rx-clk");
> +       if (IS_ERR(dwmac->clk_rx)) {
> +               dev_warn(dev, "No rx clock provided...\n");
> +               dwmac->clk_rx = NULL;
> +       }
> +
> +       /* Get mode register */
> +       regmap = syscon_regmap_lookup_by_phandle(np, "st,syscon");
> +       if (IS_ERR(regmap))
> +               return PTR_ERR(regmap);
> +
> +       err = of_property_read_u32_index(np, "st,syscon", 1, &dwmac->mode_reg);
> +       if (err) {
> +               dev_err(dev, "Can't get sysconfig mode offset (%d)\n", err);
> +               return err;
> +       }
> +
> +       dwmac->interface = of_get_phy_mode(np);
> +       dwmac->regmap = regmap;

Why the temporary local regmap variable?

Assigning dwmac->regmap with syscon_regmap_lookup_by_phandle() should
not exceed 80 chars if that is what you are worried about.


> +       return 0;
> +}
> +
> +static int stm32_dwmac_probe(struct platform_device *pdev)
> +{
> +       struct plat_stmmacenet_data *plat_dat;
> +       struct stmmac_resources stmmac_res;
> +       struct stm32_dwmac *dwmac;
> +       int ret;
> +
> +       ret = stmmac_get_platform_resources(pdev, &stmmac_res);
> +       if (ret)
> +               return ret;
> +
> +       plat_dat = stmmac_probe_config_dt(pdev, &stmmac_res.mac);
> +       if (IS_ERR(plat_dat))
> +               return PTR_ERR(plat_dat);
> +
> +       dwmac = devm_kzalloc(&pdev->dev, sizeof(*dwmac), GFP_KERNEL);
> +       if (!dwmac)
> +               return -ENOMEM;
> +
> +       ret = stm32_dwmac_parse_data(dwmac, pdev);
> +       if (ret) {
> +               dev_err(&pdev->dev, "Unable to parse OF data\n");
> +               return ret;
> +       }
> +
> +       plat_dat->bsp_priv = dwmac;
> +
> +       ret = stm32_dwmac_init(plat_dat->bsp_priv);
> +       if (ret)
> +               return ret;
> +
> +       return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);

Note that stmmac_dvr_probe() can fail and if so you should disable
your tx/rx clks before you return.

Consider putting the clk_prepare_enable() directly here and use goto
labels for the clean up like most other drivers do in probe.

Also if you put regmap_update_bits() for phy mode above the
clk_prepare_enable() calls you remove one of the gotos.
I assume you don't need to enable tx/rx clock before you write to syscon.


> +static int stm32_dwmac_remove(struct platform_device *pdev)
> +{
> +       struct net_device *ndev = platform_get_drvdata(pdev);
> +       struct stmmac_priv *priv = netdev_priv(ndev);
> +       int ret = stmmac_dvr_remove(ndev);
> +
> +       stm32_dwmac_exit(priv->plat->bsp_priv);
> +
> +       return ret;
> +}
> +
> +#ifdef CONFIG_PM_SLEEP
> +static int stm32_dwmac_suspend(struct device *dev)
> +{
> +       struct net_device *ndev = dev_get_drvdata(dev);
> +       struct stmmac_priv *priv = netdev_priv(ndev);
> +       int ret;
> +
> +       ret = stmmac_suspend(ndev);
> +       stm32_dwmac_exit(priv->plat->bsp_priv);
> +
> +       return ret;
> +}
> +
> +static int stm32_dwmac_resume(struct device *dev)
> +{
> +       struct net_device *ndev = dev_get_drvdata(dev);
> +       struct stmmac_priv *priv = netdev_priv(ndev);
> +       int ret;
> +
> +       ret = stm32_dwmac_init(priv->plat->bsp_priv);
> +       if (ret)
> +               goto out_regmap;
> +
> +       ret = stmmac_resume(ndev);
> +
> +out_regmap:
> +       return ret;

Why the goto?

This could be written:
    ret = stm32_dwmac_init(priv->plat->bsp_priv);
    if (ret)
       return ret;

    return stmmac_resume(ndev);


regards,
Joachim Eastwood
