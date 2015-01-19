From: Eugene Krasnikov <k.eugene.e@gmail.com>
Subject: Re: [PATCH 2/2] net wireless wcn36xx adapt wcnss platform to select
 module by DT
Date: Mon, 19 Jan 2015 08:34:43 +0000
Message-ID: <CAFSJ42YW5RNpeWA-VDjUT9Ct0MSCxaLNY8XQHUdo9NKzLbCjMg@mail.gmail.com>
References: <20150118051222.32019.32719.stgit@114-36-241-182.dynamic.hinet.net>
	<20150118051650.32019.49483.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	wcn36xx <wcn36xx@lists.infradead.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f44.google.com ([209.85.192.44]:60322 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbbASIeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 03:34:44 -0500
In-Reply-To: <20150118051650.32019.49483.stgit@114-36-241-182.dynamic.hinet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So how do we insmod wcn36xx_msm with a parameter specifying what type
of hardware do we use?

2015-01-18 5:16 GMT+00:00 Andy Green <andy.green@linaro.org>:
> Simplify the resource handling and use DT to indicate which chip type
> we are dealing with
>
> Signed-off-by: Andy Green <andy.green@linaro.org>
> ---
>  drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c |  101 ++++++++++++------------
>  1 file changed, 52 insertions(+), 49 deletions(-)
>
> diff --git a/drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c b/drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c
> index f6f6c83..c9250e0 100644
> --- a/drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c
> +++ b/drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c
> @@ -42,7 +42,10 @@ struct wcn36xx_msm {
>         struct completion       smd_compl;
>         smd_channel_t           *smd_ch;
>         struct pinctrl *pinctrl;
> -} wmsm;
> +       enum wcn36xx_chip_type chip_type;
> +};
> +
> +static struct wcn36xx_msm wmsm;
>
>  static int wcn36xx_msm_smsm_change_state(u32 clear_mask, u32 set_mask)
>  {
> @@ -217,14 +220,47 @@ int wcn36xx_msm_powerup(const struct subsys_desc *desc)
>         return 0;
>  }
>
> +static const struct of_device_id wcn36xx_msm_match_table[] = {
> +       { .compatible = "qcom,wcn3660", .data = (void *)WCN36XX_CHIP_3660 },
> +       { .compatible = "qcom,wcn3680", .data = (void *)WCN36XX_CHIP_3680 },
> +       { .compatible = "qcom,wcn3620", .data = (void *)WCN36XX_CHIP_3620 },
> +       { }
> +};
> +
> +static int wcn36xx_msm_get_chip_type(void)
> +{
> +       return wmsm.chip_type;
> +}
> +
> +static struct wcn36xx_msm wmsm = {
> +       .ctrl_ops = {
> +               .open = wcn36xx_msm_smd_open,
> +               .close = wcn36xx_msm_smd_close,
> +               .tx = wcn36xx_msm_smd_send_and_wait,
> +               .get_hw_mac = wcn36xx_msm_get_hw_mac,
> +               .smsm_change_state = wcn36xx_msm_smsm_change_state,
> +               .get_chip_type = wcn36xx_msm_get_chip_type,
> +       },
> +};
> +
>  static int wcn36xx_msm_probe(struct platform_device *pdev)
>  {
>         int ret;
> -       struct resource *wcnss_memory;
> -       struct resource *tx_irq;
> -       struct resource *rx_irq;
> +       const struct of_device_id *of_id;
> +       struct resource *r;
>         struct resource res[3];
>         struct pinctrl_state *ps;
> +       static const char const *rnames[] = {
> +               "wcnss_mmio", "wcnss_wlantx_irq", "wcnss_wlanrx_irq" };
> +       static const int rtype[] = {
> +               IORESOURCE_MEM, IORESOURCE_IRQ, IORESOURCE_IRQ };
> +       int n;
> +
> +       of_id = of_match_node(wcn36xx_msm_match_table, pdev->dev.of_node);
> +       if (!of_id)
> +               return -EINVAL;
> +
> +       wmsm.chip_type = (enum wcn36xx_chip_type)of_id->data;
>
>         wmsm.pinctrl = devm_pinctrl_get(&pdev->dev);
>         if (IS_ERR_OR_NULL(wmsm.pinctrl))
> @@ -240,52 +276,23 @@ static int wcn36xx_msm_probe(struct platform_device *pdev)
>
>         if (IS_ERR_OR_NULL(pil))
>                 pil = subsystem_get("wcnss");
> -               if (IS_ERR_OR_NULL(pil))
> -                       return PTR_ERR(pil);
> +       if (IS_ERR_OR_NULL(pil))
> +               return PTR_ERR(pil);
>
>         wmsm.core = platform_device_alloc("wcn36xx", -1);
>
> -       //dev_err(&pdev->dev, "%s starting\n", __func__);
> -
> -       memset(res, 0x00, sizeof(res));
> -       wmsm.ctrl_ops.open = wcn36xx_msm_smd_open;
> -       wmsm.ctrl_ops.close = wcn36xx_msm_smd_close;
> -       wmsm.ctrl_ops.tx = wcn36xx_msm_smd_send_and_wait;
> -       wmsm.ctrl_ops.get_hw_mac = wcn36xx_msm_get_hw_mac;
> -       wmsm.ctrl_ops.smsm_change_state = wcn36xx_msm_smsm_change_state;
> -       wcnss_memory =
> -               platform_get_resource_byname(pdev,
> -                                             IORESOURCE_MEM,
> -                                             "wcnss_mmio");
> -       if (wcnss_memory == NULL) {
> -               dev_err(&wmsm.core->dev,
> -                       "Failed to get wcnss wlan memory map.\n");
> -               ret = -ENOMEM;
> -               return ret;
> -       }
> -       memcpy(&res[0], wcnss_memory, sizeof(*wcnss_memory));
> -
> -       tx_irq = platform_get_resource_byname(pdev,
> -                                             IORESOURCE_IRQ,
> -                                             "wcnss_wlantx_irq");
> -       if (tx_irq == NULL) {
> -               dev_err(&wmsm.core->dev, "Failed to get wcnss tx_irq");
> -               ret = -ENOMEM;
> -               return ret;
> -       }
> -       memcpy(&res[1], tx_irq, sizeof(*tx_irq));
> -
> -       rx_irq = platform_get_resource_byname(pdev,
> -                                             IORESOURCE_IRQ,
> -                                             "wcnss_wlanrx_irq");
> -       if (rx_irq == NULL) {
> -               dev_err(&wmsm.core->dev, "Failed to get wcnss rx_irq");
> -               ret = -ENOMEM;
> -               return ret;
> +       for (n = 0; n < ARRAY_SIZE(rnames); n++) {
> +               r = platform_get_resource_byname(pdev, rtype[n], rnames[n]);
> +               if (!r) {
> +                       dev_err(&wmsm.core->dev,
> +                               "Missing resource %s'\n", rnames[n]);
> +                       ret = -ENOMEM;
> +                       return ret;
> +               }
> +               res[n] = *r;
>         }
> -       memcpy(&res[2], rx_irq, sizeof(*rx_irq));
>
> -       platform_device_add_resources(wmsm.core, res, ARRAY_SIZE(res));
> +       platform_device_add_resources(wmsm.core, res, n);
>
>         ret = platform_device_add_data(wmsm.core, &wmsm.ctrl_ops,
>                                        sizeof(wmsm.ctrl_ops));
> @@ -319,10 +326,6 @@ static int wcn36xx_msm_remove(struct platform_device *pdev)
>         return 0;
>  }
>
> -static const struct of_device_id wcn36xx_msm_match_table[] = {
> -       { .compatible = "qcom,wcn36xx" },
> -       { }
> -};
>  MODULE_DEVICE_TABLE(of, wcn36xx_msm_match_table);
>
>  static struct platform_driver wcn36xx_msm_driver = {
>



-- 
Best regards,
Eugene
