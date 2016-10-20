From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [RFC PATCH] net: stmmac: Add OXNAS Glue Driver
Date: Thu, 20 Oct 2016 18:26:58 +0200
Message-ID: <CAGhQ9VxJ-gQTX1xjMOJ4spiL_RnhryyQ0=gUEQCHm3sHecTVuA@mail.gmail.com>
References: <20161020155406.27172-1-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "peppe.cavallaro" <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, devicetree <devicetree@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-oxnas@lists.tuxfamily.org,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161020155406.27172-1-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Neil,

On 20 October 2016 at 17:54, Neil Armstrong <narmstrong@baylibre.com> wrote:
> Add Synopsys Designware MAC Glue layer for the Oxford Semiconductor OX820.
>
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  .../devicetree/bindings/net/oxnas-dwmac.txt        |  44 ++++++
>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |  11 ++
>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>  drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c  | 173 +++++++++++++++++++++
>  4 files changed, 229 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/oxnas-dwmac.txt
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
<snip>
> +
> +static int oxnas_dwmac_probe(struct platform_device *pdev)
> +{
> +       struct plat_stmmacenet_data *plat_dat;
> +       struct stmmac_resources stmmac_res;
> +       struct device_node *sysctrl;
> +       struct oxnas_dwmac *dwmac;
> +       int ret;
> +
> +       sysctrl = of_parse_phandle(pdev->dev.of_node, "oxsemi,sys-ctrl", 0);
> +       if (!sysctrl) {
> +               dev_err(&pdev->dev, "failed to get sys-ctrl node\n");
> +               return -EINVAL;
> +       }
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
> +       dwmac->regmap = syscon_node_to_regmap(sysctrl);
> +       if (IS_ERR(dwmac->regmap)) {
> +               dev_err(&pdev->dev, "failed to have sysctrl regmap\n");
> +               return PTR_ERR(dwmac->regmap);
> +       }
> +
> +       dwmac->clk = devm_clk_get(&pdev->dev, "gmac");
> +       if (IS_ERR(dwmac->clk))
> +               return PTR_ERR(dwmac->clk);
> +
> +       plat_dat->bsp_priv = dwmac;
> +       plat_dat->init = oxnas_dwmac_init;
> +       plat_dat->exit = oxnas_dwmac_exit;

Please do not use the init/exit callbacks. Implement proper driver
callbacks instead. I.e: PM resume/suspend and driver remove.

Shouldn't you call oxnas_dwmac_init() from probe as well?
As it is now it will only be called during PM resume and that can't be right.


> +
> +       return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);

If stmmac_dvr_probe() fails you should disable your clocks.


regards,
Joachim Eastwood
