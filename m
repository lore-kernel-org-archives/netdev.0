From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/4] net: ethernet: cpsw: add optional third memory region
 for CONTROL module
Date: Thu, 22 Aug 2013 22:12:46 +0400
Message-ID: <5216549E.1010305@cogentembedded.com>
References: <1377171448-27924-1-git-send-email-zonque@gmail.com> <1377171448-27924-3-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ujhelyi.m@gmail.com,
	mugunthanvnm@ti.com, vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1377171448-27924-3-git-send-email-zonque@gmail.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 08/22/2013 03:37 PM, Daniel Mack wrote:

> At least the AM33xx SoC has a control module register to configure
> details such as the hardware ethernet interface mode.

> I'm not sure whether all SoCs which feature the cpsw block have such a
> register, so that third memory region is considered optional for now.

> Signed-off-by: Daniel Mack <zonque@gmail.com>
> ---
>   Documentation/devicetree/bindings/net/cpsw.txt |  5 ++++-
>   drivers/net/ethernet/ti/cpsw.c                 | 22 ++++++++++++++++++++++
>   2 files changed, 26 insertions(+), 1 deletion(-)

> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
> index 05d660e..4e5ca54 100644
> --- a/Documentation/devicetree/bindings/net/cpsw.txt
> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
[...]
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 63feaae..4855d8e 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
[...]
> @@ -2012,6 +2013,27 @@ static int cpsw_probe(struct platform_device *pdev)
>   		goto clean_runtime_disable_ret;
>   	}
>
> +	/* If the control memory region is unspecified, continue without it.
> +	 * If it is specified, but we're unable to reserve it, bail. */

    According to Documentation/CodingStyle, the networking code's preferred 
style of multi-line comments is this:

/* Bla
  * bla
  */

> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
> +	if (!res) {
> +		dev_err(priv->dev, "error getting control i/o resource\n");
> +		goto no_gmii_sel;
> +	}
> +	if (!devm_request_mem_region(&pdev->dev, res->start, resource_size(res),
> +				     ndev->name)) {

    Not dev_name(&pdev->dev)?

> +		dev_err(priv->dev, "failed request control i/o region\n");
> +		ret = -ENXIO;

    Rather -EBUSY.

> +		goto clean_runtime_disable_ret;
> +	}
> +	priv->gmii_sel_reg = devm_ioremap(&pdev->dev, res->start,
> +					  resource_size(res));
> +	if (!priv->gmii_sel_reg) {
> +		dev_err(priv->dev, "unable to map control i/o region\n");
> +		goto clean_runtime_disable_ret;
> +	}

    Why not use devm_ioremap_resource() instead of the above sequence?

> +
> +no_gmii_sel:

WBR, Sergei

