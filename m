From: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Subject: Re: [RFC PATCH] net: stmmac: Add OXNAS Glue Driver
Date: Fri, 21 Oct 2016 10:28:23 +0200
Message-ID: <872a84c9-6ec3-695b-0c37-c58719e0a034@baylibre.com>
References: <20161020155406.27172-1-narmstrong@baylibre.com>
 <CAGhQ9VxJ-gQTX1xjMOJ4spiL_RnhryyQ0=gUEQCHm3sHecTVuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "peppe.cavallaro" <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-oxnas-Xt5XgHjqiBU06sgRBLv0+0B+6BGkLq7r@public.gmane.org,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Joachim Eastwood <manabian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGhQ9VxJ-gQTX1xjMOJ4spiL_RnhryyQ0=gUEQCHm3sHecTVuA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/20/2016 06:26 PM, Joachim Eastwood wrote:
> Hi Neil,
> 
> On 20 October 2016 at 17:54, Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org> wrote:
>> Add Synopsys Designware MAC Glue layer for the Oxford Semiconductor OX820.
>>
>> Signed-off-by: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
>> ---
>>  .../devicetree/bindings/net/oxnas-dwmac.txt        |  44 ++++++
>>  drivers/net/ethernet/stmicro/stmmac/Kconfig        |  11 ++
>>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   1 +
>>  drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c  | 173 +++++++++++++++++++++
>>  4 files changed, 229 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/oxnas-dwmac.txt
>>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c
> <snip>
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
>> +       plat_dat->bsp_priv = dwmac;
>> +       plat_dat->init = oxnas_dwmac_init;
>> +       plat_dat->exit = oxnas_dwmac_exit;
> 
> Please do not use the init/exit callbacks. Implement proper driver
> callbacks instead. I.e: PM resume/suspend and driver remove.
> 
> Shouldn't you call oxnas_dwmac_init() from probe as well?
> As it is now it will only be called during PM resume and that can't be right.
> 
> 
>> +
>> +       return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
> 
> If stmmac_dvr_probe() fails you should disable your clocks.
> 
> 
> regards,
> Joachim Eastwood
> 

Hi Joachim,

Thanks for the hints, stm32 glue does that and I will sync on it.

Neil
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
