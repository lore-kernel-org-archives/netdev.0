From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 2/5] net: ethernet: cpsw: add optional third memory
 region for CONTROL module
Date: Fri, 23 Aug 2013 18:03:35 +0400
Message-ID: <52176BB7.3000405@cogentembedded.com>
References: <1377247417-27386-1-git-send-email-zonque@gmail.com> <1377247417-27386-3-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsekhar@ti.com, davem@davemloft.net,
	ujhelyi.m@gmail.com, mugunthanvnm@ti.com, vaibhav.bedia@ti.com,
	d-gerlach@ti.com, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, devicetree@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:38880 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754547Ab3HWODa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 10:03:30 -0400
Received: by mail-lb0-f177.google.com with SMTP id n6so499840lbi.36
        for <netdev@vger.kernel.org>; Fri, 23 Aug 2013 07:03:29 -0700 (PDT)
In-Reply-To: <1377247417-27386-3-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 23-08-2013 12:43, Daniel Mack wrote:

> At least the AM33xx SoC has a control module register to configure
> details such as the hardware ethernet interface mode.

> I'm not sure whether all SoCs which feature the cpsw block have such a
> register, so that third memory region is considered optional for now.

> Signed-off-by: Daniel Mack <zonque@gmail.com>
[...]

> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 1a91aac..bd0b664 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
[...]
> @@ -1999,6 +2000,21 @@ static int cpsw_probe(struct platform_device *pdev)
>   		goto clean_runtime_disable_ret;
>   	}
>
> +	/* If the control memory region is unspecified, continue without it.
> +	 * If it is specified, but we're unable to reserve it, bail.
> +	 */
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
> +	if (!res) {
> +		dev_err(priv->dev, "error getting control i/o resource\n");

    If the resource is optional, why use dev_err()?

> +		goto no_gmii_sel;
> +	}
> +	priv->gmii_sel_reg = devm_ioremap_resource(&pdev->dev, res);
> +	if (!priv->gmii_sel_reg) {

    devm_ioremap_resource() doesn't return NULL, it returns error, so you 
should check with IS_ERR() and propagate the error to the caller with PTR_ERR().

> +		dev_err(priv->dev, "unable to map control i/o region\n");

    devm_ioremap_resource() prints out the error messages itself, so you don't 
have to.

> +		goto clean_runtime_disable_ret;
> +	}
> +
> +no_gmii_sel:
>   	memset(&dma_params, 0, sizeof(dma_params));
>   	memset(&ale_params, 0, sizeof(ale_params));

WBR, Sergei
