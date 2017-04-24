From: Matthias Brugger <matthias.bgg@gmail.com>
Subject: Re: [PATCH net v2 1/3] net: hns: support deferred probe when can not
 obtain irq
Date: Mon, 24 Apr 2017 12:28:33 +0200
Message-ID: <f9ebfcdf-daa2-2722-1f12-fb34e24adc24@gmail.com>
References: <1492760684-117205-1-git-send-email-yankejian@huawei.com>
 <1492760684-117205-2-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, charles.chenxin@huawei.com,
        linuxarm@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [195.159.176.226] ([195.159.176.226]:51184 "EHLO
        blaine.gmane.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1166768AbdDXK2r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 06:28:47 -0400
Received: from list by blaine.gmane.org with local (Exim 4.84_2)
        (envelope-from <linux-netdev-2@m.gmane.org>)
        id 1d2bEV-00019N-KE
        for netdev@vger.kernel.org; Mon, 24 Apr 2017 12:28:39 +0200
In-Reply-To: <1492760684-117205-2-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/04/17 09:44, Yankejian wrote:
> From: lipeng <lipeng321@huawei.com>
>
> In the hip06 and hip07 SoCs, the interrupt lines from the
> DSAF controllers are connected to mbigen hw module.
> The mbigen module is probed with module_init, and, as such,
> is not guaranteed to probe before the HNS driver. So we need
> to support deferred probe.
>
> We check for probe deferral in the hw layer probe, so we not
> probe into the main layer and memories, etc., to later learn
> that we need to defer the probe.
>

Why? This looks like a hack.
 From what I see, we can handle EPROBE_DEFER easily inside hns_ppe_init 
checking the return value of hns_rcb_get_cfg. Like you do in 2/3 of this 
series.

Regards,
Matthias

> Signed-off-by: lipeng <lipeng321@huawei.com>
> Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 12 ++++++++++++
>  1 file changed, 12 insertions(+)
>
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> index 403ea9d..2da5b42 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> @@ -2971,6 +2971,18 @@ static int hns_dsaf_probe(struct platform_device *pdev)
>  	struct dsaf_device *dsaf_dev;
>  	int ret;
>
> +	/*
> +	 * Check if we should defer the probe before we probe the
> +	 * dsaf, as it's hard to defer later on.
> +	 */
> +	ret = platform_get_irq(pdev, 0);
> +	if (ret < 0) {
> +		if (ret != -EPROBE_DEFER)
> +			dev_err(&pdev->dev, "Cannot obtain irq\n");
> +
> +		return ret;
> +	}
> +
>  	dsaf_dev = hns_dsaf_alloc_dev(&pdev->dev, sizeof(struct dsaf_drv_priv));
>  	if (IS_ERR(dsaf_dev)) {
>  		ret = PTR_ERR(dsaf_dev);
>
