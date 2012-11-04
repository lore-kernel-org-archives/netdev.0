From: Cyril Chemparathy <cyril@ti.com>
Subject: Re: [PATCH net-next 2/2] cpsw: fix leaking IO mappings
Date: Sun, 4 Nov 2012 14:23:58 +0100
Message-ID: <50966C6E.1000507@ti.com>
References: <cover.1351930782.git.richardcochran@gmail.com> <1c915a7d0301355342358db8f84560417609a61c.1351930782.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Vaibhav Hiremath <hvaibhav@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:50177 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752200Ab2KDNYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2012 08:24:08 -0500
In-Reply-To: <1c915a7d0301355342358db8f84560417609a61c.1351930782.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2012 09:25 AM, Richard Cochran wrote:
> The CPSW driver remaps two different IO regions, but fails to unmap them
> both. This patch fixes the issue by calling iounmap in the appropriate
> places.

Any thoughts on using devres helpers to keep the bail out path simpler?

> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> ---
>   drivers/net/ethernet/ti/cpsw.c |   17 ++++++++---------
>   1 files changed, 8 insertions(+), 9 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 6215246..7654a62 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1252,14 +1252,12 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
>   		ret = -ENOENT;
>   		goto clean_clk_ret;
>   	}
> -
>   	if (!request_mem_region(priv->cpsw_res->start,
>   				resource_size(priv->cpsw_res), ndev->name)) {
>   		dev_err(priv->dev, "failed request i/o region\n");
>   		ret = -ENXIO;
>   		goto clean_clk_ret;
>   	}
> -
>   	regs = ioremap(priv->cpsw_res->start, resource_size(priv->cpsw_res));
>   	if (!regs) {
>   		dev_err(priv->dev, "unable to map i/o region\n");
> @@ -1274,16 +1272,14 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
>   	if (!priv->cpsw_wr_res) {
>   		dev_err(priv->dev, "error getting i/o resource\n");
>   		ret = -ENOENT;
> -		goto clean_clk_ret;
> +		goto clean_iomap_ret;
>   	}
> -
>   	if (!request_mem_region(priv->cpsw_wr_res->start,
>   			resource_size(priv->cpsw_wr_res), ndev->name)) {
>   		dev_err(priv->dev, "failed request i/o region\n");
>   		ret = -ENXIO;
> -		goto clean_clk_ret;
> +		goto clean_iomap_ret;
>   	}
> -
>   	regs = ioremap(priv->cpsw_wr_res->start,
>   				resource_size(priv->cpsw_wr_res));
>   	if (!regs) {
> @@ -1326,7 +1322,7 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
>   	if (!priv->dma) {
>   		dev_err(priv->dev, "error initializing dma\n");
>   		ret = -ENOMEM;
> -		goto clean_iomap_ret;
> +		goto clean_wr_iomap_ret;
>   	}
>   
>   	priv->txch = cpdma_chan_create(priv->dma, tx_chan_num(0),
> @@ -1407,11 +1403,13 @@ clean_dma_ret:
>   	cpdma_chan_destroy(priv->txch);
>   	cpdma_chan_destroy(priv->rxch);
>   	cpdma_ctlr_destroy(priv->dma);
> -clean_iomap_ret:
> -	iounmap(priv->regs);
> +clean_wr_iomap_ret:
> +	iounmap(priv->wr_regs);
>   clean_cpsw_wr_iores_ret:
>   	release_mem_region(priv->cpsw_wr_res->start,
>   			   resource_size(priv->cpsw_wr_res));
> +clean_iomap_ret:
> +	iounmap(priv->regs);
>   clean_cpsw_iores_ret:
>   	release_mem_region(priv->cpsw_res->start,
>   			   resource_size(priv->cpsw_res));
> @@ -1442,6 +1440,7 @@ static int __devexit cpsw_remove(struct platform_device *pdev)
>   	iounmap(priv->regs);
>   	release_mem_region(priv->cpsw_res->start,
>   			   resource_size(priv->cpsw_res));
> +	iounmap(priv->wr_regs);
>   	release_mem_region(priv->cpsw_wr_res->start,
>   			   resource_size(priv->cpsw_wr_res));
>   	pm_runtime_disable(&pdev->dev);
