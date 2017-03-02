From: Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 7/7] net: stmmac: dwc-qos: Add Tegra186 support
Date: Thu, 2 Mar 2017 16:44:29 +0000
Message-ID: <a2d39373-4e94-c139-1890-8dc76dfb81bf@synopsys.com>
References: <20170223172438.14770-1-thierry.reding@gmail.com>
 <20170223172438.14770-8-thierry.reding@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre Torgue <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Joao Pinto <Joao.Pinto-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>,
        "Alexandre Courbot" <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Jon Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170223172438.14770-8-thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Às 5:24 PM de 2/23/2017, Thierry Reding escreveu:
> From: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> 
> The NVIDIA Tegra186 SoC contains an instance of the Synopsys DWC
> ethernet QOS IP core. The binding that it uses is slightly different
> from existing ones because of the integration (clocks, resets, ...).
> 
> Signed-off-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> ---
>  .../ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c    | 252 +++++++++++++++++++++
>  1 file changed, 252 insertions(+)
> 
> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
> index 5071d3c15adc..54dfbdc48f6d 100644
> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-dwc-qos-eth.c
> @@ -14,6 +14,7 @@
>  #include <linux/clk.h>
>  #include <linux/clk-provider.h>
>  #include <linux/device.h>
> +#include <linux/gpio/consumer.h>
>  #include <linux/ethtool.h>
>  #include <linux/io.h>
>  #include <linux/ioport.h>
> @@ -22,10 +23,24 @@
>  #include <linux/of_net.h>
>  #include <linux/mfd/syscon.h>
>  #include <linux/platform_device.h>
> +#include <linux/reset.h>
>  #include <linux/stmmac.h>
>  
>  #include "stmmac_platform.h"
>  
> +struct tegra_eqos {
> +	struct device *dev;
> +	void __iomem *regs;
> +
> +	struct reset_control *rst;
> +	struct clk *clk_master;
> +	struct clk *clk_slave;
> +	struct clk *clk_tx;
> +	struct clk *clk_rx;
> +
> +	struct gpio_desc *reset;
> +};
> +
>  static int dwc_eth_dwmac_config_dt(struct platform_device *pdev,
>  				   struct plat_stmmacenet_data *plat_dat)
>  {
> @@ -148,6 +163,237 @@ static int dwc_qos_remove(struct platform_device *pdev)
>  	return 0;
>  }
>  
> +#define SDMEMCOMPPADCTRL 0x8800
> +#define  SDMEMCOMPPADCTRL_PAD_E_INPUT_OR_E_PWRD BIT(31)
> +
> +#define AUTO_CAL_CONFIG 0x8804
> +#define  AUTO_CAL_CONFIG_START BIT(31)
> +#define  AUTO_CAL_CONFIG_ENABLE BIT(29)
> +
> +#define AUTO_CAL_STATUS 0x880c
> +#define  AUTO_CAL_STATUS_ACTIVE BIT(31)
> +
> +static void tegra_eqos_fix_speed(void *priv, unsigned int speed)
> +{
> +	struct tegra_eqos *eqos = priv;
> +	unsigned long rate = 125000000;
> +	bool needs_calibration = false;
> +	unsigned int i;
> +	u32 value;
> +
> +	switch (speed) {
> +	case SPEED_1000:
> +		needs_calibration = true;
> +		rate = 125000000;
> +		break;
> +
> +	case SPEED_100:
> +		needs_calibration = true;
> +		rate = 25000000;
> +		break;
> +
> +	case SPEED_10:
> +		rate = 2500000;
> +		break;
> +
> +	default:
> +		dev_err(eqos->dev, "invalid speed %u\n", speed);
> +		break;
> +	}
> +
> +	if (needs_calibration) {
> +		/* calibrate */
> +		value = readl(eqos->regs + SDMEMCOMPPADCTRL);
> +		value |= SDMEMCOMPPADCTRL_PAD_E_INPUT_OR_E_PWRD;
> +		writel(value, eqos->regs + SDMEMCOMPPADCTRL);
> +
> +		udelay(1);
> +
> +		value = readl(eqos->regs + AUTO_CAL_CONFIG);
> +		value |= AUTO_CAL_CONFIG_START | AUTO_CAL_CONFIG_ENABLE;
> +		writel(value, eqos->regs + AUTO_CAL_CONFIG);
> +
> +		for (i = 0; i <= 10; i++) {
> +			value = readl(eqos->regs + AUTO_CAL_STATUS);
> +			if (value & AUTO_CAL_STATUS_ACTIVE)
> +				break;
> +
> +			udelay(1);
> +		}
> +
> +		if ((value & AUTO_CAL_STATUS_ACTIVE) == 0) {
> +			dev_err(eqos->dev, "calibration did not start\n");
> +			goto failed;
> +		}
> +
> +		for (i = 0; i <= 10; i++) {
> +			value = readl(eqos->regs + AUTO_CAL_STATUS);
> +			if ((value & AUTO_CAL_STATUS_ACTIVE) == 0)
> +				break;
> +
> +			udelay(20);
> +		}
> +
> +		if (value & AUTO_CAL_STATUS_ACTIVE) {
> +			dev_err(eqos->dev, "calibration didn't finish\n");
> +			goto failed;
> +		}
> +
> +	failed:
> +		value = readl(eqos->regs + SDMEMCOMPPADCTRL);
> +		value &= ~SDMEMCOMPPADCTRL_PAD_E_INPUT_OR_E_PWRD;
> +		writel(value, eqos->regs + SDMEMCOMPPADCTRL);
> +	} else {
> +		value = readl(eqos->regs + AUTO_CAL_CONFIG);
> +		value &= ~AUTO_CAL_CONFIG_ENABLE;
> +		writel(value, eqos->regs + AUTO_CAL_CONFIG);
> +	}
> +
> +	clk_set_rate(eqos->clk_tx, rate);
> +}
> +
> +static int tegra_eqos_init(struct platform_device *pdev, void *priv)
> +{
> +	struct tegra_eqos *eqos = priv;
> +	unsigned long rate;
> +	u32 value;
> +
> +	rate = clk_get_rate(eqos->clk_slave);
> +
> +	value = readl(eqos->regs + 0xdc);
> +	value = (rate / 1000000) - 1;
> +	writel(value, eqos->regs + 0xdc);
> +
> +	return 0;
> +}
> +
> +static void *tegra_eqos_probe(struct platform_device *pdev,
> +			      struct plat_stmmacenet_data *data,
> +			      struct stmmac_resources *res)
> +{
> +	struct tegra_eqos *eqos;
> +	int err;
> +
> +	eqos = devm_kzalloc(&pdev->dev, sizeof(*eqos), GFP_KERNEL);
> +	if (!eqos) {
> +		err = -ENOMEM;
> +		goto error;
> +	}
> +
> +	eqos->dev = &pdev->dev;
> +	eqos->regs = res->addr;
> +
> +	eqos->clk_master = devm_clk_get(&pdev->dev, "master_bus");
> +	if (IS_ERR(eqos->clk_master)) {
> +		err = PTR_ERR(eqos->clk_master);
> +		goto error;
> +	}
> +
> +	err = clk_prepare_enable(eqos->clk_master);
> +	if (err < 0)
> +		goto error;
> +
> +	eqos->clk_slave = devm_clk_get(&pdev->dev, "slave_bus");
> +	if (IS_ERR(eqos->clk_slave)) {
> +		err = PTR_ERR(eqos->clk_slave);
> +		goto disable_master;
> +	}
> +
> +	data->stmmac_clk = eqos->clk_slave;
> +
> +	err = clk_prepare_enable(eqos->clk_slave);
> +	if (err < 0)
> +		goto disable_master;
> +
> +	eqos->clk_rx = devm_clk_get(&pdev->dev, "rx");
> +	if (IS_ERR(eqos->clk_rx)) {
> +		err = PTR_ERR(eqos->clk_rx);
> +		goto disable_slave;
> +	}
> +
> +	err = clk_prepare_enable(eqos->clk_rx);
> +	if (err < 0)
> +		goto disable_slave;
> +
> +	eqos->clk_tx = devm_clk_get(&pdev->dev, "tx");
> +	if (IS_ERR(eqos->clk_tx)) {
> +		err = PTR_ERR(eqos->clk_tx);
> +		goto disable_rx;
> +	}
> +
> +	err = clk_prepare_enable(eqos->clk_tx);
> +	if (err < 0)
> +		goto disable_rx;
> +
> +	eqos->reset = devm_gpiod_get(&pdev->dev, "phy-reset", GPIOD_OUT_HIGH);
> +	if (IS_ERR(eqos->reset)) {
> +		err = PTR_ERR(eqos->reset);
> +		goto disable_tx;
> +	}
> +
> +	usleep_range(2000, 4000);
> +	gpiod_set_value(eqos->reset, 0);
> +
> +	eqos->rst = devm_reset_control_get(&pdev->dev, "eqos");
> +	if (IS_ERR(eqos->rst)) {
> +		err = PTR_ERR(eqos->rst);
> +		goto reset_phy;
> +	}
> +
> +	err = reset_control_assert(eqos->rst);
> +	if (err < 0)
> +		goto reset_phy;
> +
> +	usleep_range(2000, 4000);
> +
> +	err = reset_control_deassert(eqos->rst);
> +	if (err < 0)
> +		goto reset_phy;
> +
> +	usleep_range(2000, 4000);
> +
> +	data->fix_mac_speed = tegra_eqos_fix_speed;
> +	data->init = tegra_eqos_init;
> +	data->bsp_priv = eqos;
> +
> +	err = tegra_eqos_init(pdev, eqos);
> +	if (err < 0)
> +		goto reset;
> +
> +out:
> +	return eqos;
> +
> +reset:
> +	reset_control_assert(eqos->rst);
> +reset_phy:
> +	gpiod_set_value(eqos->reset, 1);
> +disable_tx:
> +	clk_disable_unprepare(eqos->clk_tx);
> +disable_rx:
> +	clk_disable_unprepare(eqos->clk_rx);
> +disable_slave:
> +	clk_disable_unprepare(eqos->clk_slave);
> +disable_master:
> +	clk_disable_unprepare(eqos->clk_master);
> +error:
> +	eqos = ERR_PTR(err);
> +	goto out;
> +}
> +
> +static int tegra_eqos_remove(struct platform_device *pdev)
> +{
> +	struct tegra_eqos *eqos = get_stmmac_bsp_priv(&pdev->dev);
> +
> +	reset_control_assert(eqos->rst);
> +	gpiod_set_value(eqos->reset, 1);
> +	clk_disable_unprepare(eqos->clk_tx);
> +	clk_disable_unprepare(eqos->clk_rx);
> +	clk_disable_unprepare(eqos->clk_slave);
> +	clk_disable_unprepare(eqos->clk_master);
> +
> +	return 0;
> +}
> +
>  struct dwc_eth_dwmac_data {
>  	void *(*probe)(struct platform_device *pdev,
>  		       struct plat_stmmacenet_data *data,
> @@ -160,6 +406,11 @@ static const struct dwc_eth_dwmac_data dwc_qos_data = {
>  	.remove = dwc_qos_remove,
>  };
>  
> +static const struct dwc_eth_dwmac_data tegra_eqos_data = {
> +	.probe = tegra_eqos_probe,
> +	.remove = tegra_eqos_remove,
> +};
> +
>  static int dwc_eth_dwmac_probe(struct platform_device *pdev)
>  {
>  	const struct dwc_eth_dwmac_data *data;
> @@ -245,6 +496,7 @@ static int dwc_eth_dwmac_remove(struct platform_device *pdev)
>  
>  static const struct of_device_id dwc_eth_dwmac_match[] = {
>  	{ .compatible = "snps,dwc-qos-ethernet-4.10", .data = &dwc_qos_data },
> +	{ .compatible = "nvidia,tegra186-eqos", .data = &tegra_eqos_data},
>  	{ }
>  };
>  MODULE_DEVICE_TABLE(of, dwc_eth_dwmac_match);
> 

Please check comments from Mikko Perttunen. Overall is ok.

Thanks.
