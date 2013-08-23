From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v4 1/5] net: ethernet: cpsw: switch to devres allocations
Date: Fri, 23 Aug 2013 22:10:54 +0400
Message-ID: <5217A5AE.6090704@cogentembedded.com>
References: <1377267365-24057-1-git-send-email-zonque@gmail.com> <1377267365-24057-2-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcousson@baylibre.com, nsekhar@ti.com,
	davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1377267365-24057-2-git-send-email-zonque@gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/23/2013 06:16 PM, Daniel Mack wrote:

> This patch cleans up the allocation and error unwind paths, which
> allows us to carry less information in struct cpsw_priv and reduce the
> amount of jump labels in the probe functions.

> Signed-off-by: Daniel Mack <zonque@gmail.com>
> ---
>   drivers/net/ethernet/ti/cpsw.c | 147 +++++++++++++----------------------------
>   1 file changed, 45 insertions(+), 102 deletions(-)

> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 79974e3..849af52 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
[...]
> @@ -1977,55 +1963,41 @@ static int cpsw_probe(struct platform_device *pdev)
>   	priv->slaves[0].ndev = ndev;
>   	priv->emac_port = 0;
>
> -	priv->clk = clk_get(&pdev->dev, "fck");
> +	priv->clk = devm_clk_get(&pdev->dev, "fck");
>   	if (IS_ERR(priv->clk)) {
> -		dev_err(&pdev->dev, "fck is not found\n");
> +		dev_err(priv->dev, "fck is not found\n");
>   		ret = -ENODEV;
> -		goto clean_slave_ret;
> +		goto clean_runtime_disable_ret;
>   	}
>   	priv->coal_intvl = 0;
>   	priv->bus_freq_mhz = clk_get_rate(priv->clk) / 1000000;
>
> -	priv->cpsw_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> -	if (!priv->cpsw_res) {
> +	ss_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> +	if (!ss_res) {

    You don't need to check the result of platform_get_resource() if you call
devm_ioremap_resource() right afterwards -- it will check resource ptr for 
NULL the first thing. :-)

>   		dev_err(priv->dev, "error getting i/o resource\n");
>   		ret = -ENOENT;
> -		goto clean_clk_ret;
> +		goto clean_runtime_disable_ret;
>   	}
> -	if (!request_mem_region(priv->cpsw_res->start,
> -				resource_size(priv->cpsw_res), ndev->name)) {
> -		dev_err(priv->dev, "failed request i/o region\n");
> -		ret = -ENXIO;
> -		goto clean_clk_ret;
> -	}
> -	ss_regs = ioremap(priv->cpsw_res->start, resource_size(priv->cpsw_res));
> -	if (!ss_regs) {
> +	ss_regs = devm_ioremap_resource(&pdev->dev, ss_res);
> +	if (IS_ERR(ss_regs)) {
>   		dev_err(priv->dev, "unable to map i/o region\n");

    Don't need the error message anymore -- devm_ioremap_resource() will print 
it. And you missed:

		ret = PTR_ERR(ss_regs);

> -		goto clean_cpsw_iores_ret;
> +		goto clean_runtime_disable_ret;
>   	}
>   	priv->regs = ss_regs;
>   	priv->version = __raw_readl(&priv->regs->id_ver);
>   	priv->host_port = HOST_PORT_NUM;
>
> -	priv->cpsw_wr_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> -	if (!priv->cpsw_wr_res) {
> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
> +	if (!res) {

    Same comment about resource check here...

>   		dev_err(priv->dev, "error getting i/o resource\n");
>   		ret = -ENOENT;
> -		goto clean_iomap_ret;
> -	}
> -	if (!request_mem_region(priv->cpsw_wr_res->start,
> -			resource_size(priv->cpsw_wr_res), ndev->name)) {
> -		dev_err(priv->dev, "failed request i/o region\n");
> -		ret = -ENXIO;
> -		goto clean_iomap_ret;
> +		goto clean_runtime_disable_ret;
>   	}
> -	wr_regs = ioremap(priv->cpsw_wr_res->start,
> -				resource_size(priv->cpsw_wr_res));
> -	if (!wr_regs) {
> +	priv->wr_regs = devm_ioremap_resource(&pdev->dev, res);
> +	if (IS_ERR(priv->wr_regs)) {
>   		dev_err(priv->dev, "unable to map i/o region\n");

    And same comments about the unneeded error message and missing 'ret' 
assignment here...

> -		goto clean_cpsw_wr_iores_ret;
> +		goto clean_runtime_disable_ret;
>   	}
> -	priv->wr_regs = wr_regs;
>
>   	memset(&dma_params, 0, sizeof(dma_params));
>   	memset(&ale_params, 0, sizeof(ale_params));
[...]

WBR, Sergei

