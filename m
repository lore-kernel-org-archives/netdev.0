From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH] net: davinci_emac: Move call of devm_request_irq to
 emac_dev_open
Date: Tue, 04 Mar 2014 15:32:01 +0100
Message-ID: <55F0BA9CA946E1901FB5D1A3@[172.22.2.41]>
References: <5dd177ee-f4e8-47b0-aeb8-d2fa64d3725b@mary.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	Jon Ringle <jon@ringle.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:44392 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757442AbaCDOcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 09:32:05 -0500
In-Reply-To: <5dd177ee-f4e8-47b0-aeb8-d2fa64d3725b@mary.at.omicron.at>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Uh, wrong subject, this should of course read

net: davinci_emac: Move call of devm_request_irq to davinci_emac_probe()

--On March 04, 2014 15:07 +0100 Christian Riesch 
<christian.riesch@omicron.at> wrote:

> In commit 6892b41d9701283085b655c6086fb57a5d63fa47
>
> Author: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> Date:   Tue Jun 25 21:24:51 2013 +0530
> net: davinci: emac: Convert to devm_* api
>
> the call of request_irq is replaced by devm_request_irq and the call
> of free_irq is removed. But since interrupts are requested in
> emac_dev_open, doing ifconfig up/down on the board requests the
> interrupts again each time, causing devm_request_irq to fail.
>
> This patch moves the interrupt requests to emac_dev_open and thus
> fixes this regression.

And of course: "This patch moves the interrupt requests to 
davinci_emac_probe() and thus
fixes this regression.

I will fix that in the next version of the patch.

Christian

>
> Reported-by: Jon Ringle <jon@ringle.org>
> Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
> Cc: Lad, Prabhakar <prabhakar.csengg@gmail.com>
> Cc: <stable@vger.kernel.org>
> ---
>
> Hi,
> This is an attempt to fix the bug discussed in
> https://lkml.org/lkml/2014/3/4/218
>
> Since I am not really familiar with interrupts I am not sure if this is
> the right way to do it. I am looking forward to your comments.
>
> Christian
>
>  drivers/net/ethernet/ti/davinci_emac.c |   32
> ++++++++++++++++----------------  1 file changed, 16 insertions(+), 16
> deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_emac.c
> b/drivers/net/ethernet/ti/davinci_emac.c index cd9b164..97c6036 100644
> --- a/drivers/net/ethernet/ti/davinci_emac.c
> +++ b/drivers/net/ethernet/ti/davinci_emac.c
> @@ -1531,10 +1531,8 @@ static int emac_dev_open(struct net_device *ndev)
>  {
>  	struct device *emac_dev = &ndev->dev;
>  	u32 cnt;
> -	struct resource *res;
>  	int ret;
>  	int i = 0;
> -	int k = 0;
>  	struct emac_priv *priv = netdev_priv(ndev);
>
>  	pm_runtime_get(&priv->pdev->dev);
> @@ -1563,16 +1561,6 @@ static int emac_dev_open(struct net_device *ndev)
>  			break;
>  	}
>
> -	/* Request IRQ */
> -
> -	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
> -		for (i = res->start; i <= res->end; i++) {
> -			if (devm_request_irq(&priv->pdev->dev, i, emac_irq,
> -					     0, ndev->name, ndev))
> -				goto rollback;
> -		}
> -		k++;
> -	}
>
>  	/* Start/Enable EMAC hardware */
>  	emac_hw_enable(priv);
> @@ -1639,10 +1627,6 @@ static int emac_dev_open(struct net_device *ndev)
>
>  	return 0;
>
> -rollback:
> -
> -	dev_err(emac_dev, "DaVinci EMAC: devm_request_irq() failed");
> -	ret = -EBUSY;
>  err:
>  	pm_runtime_put(&priv->pdev->dev);
>  	return ret;
> @@ -1839,6 +1823,8 @@ static int davinci_emac_probe(struct
> platform_device *pdev)  	struct clk *emac_clk;
>  	unsigned long emac_bus_frequency;
>
> +	int k = 0;
> +	int i = 0;
>
>  	/* obtain emac clock from kernel */
>  	emac_clk = devm_clk_get(&pdev->dev, NULL);
> @@ -1968,11 +1954,25 @@ static int davinci_emac_probe(struct
> platform_device *pdev)  			   (void *)priv->emac_base_phys, ndev->irq);
>  	}
>
> +	/* Request IRQ */
> +	while ((res = platform_get_resource(priv->pdev, IORESOURCE_IRQ, k))) {
> +		for (i = res->start; i <= res->end; i++) {
> +			if (devm_request_irq(&priv->pdev->dev, i, emac_irq,
> +					     0, ndev->name, ndev))
> +				goto no_irq;
> +		}
> +		k++;
> +	}
> +
>  	pm_runtime_enable(&pdev->dev);
>  	pm_runtime_resume(&pdev->dev);
>
>  	return 0;
>
> +no_irq:
> +	dev_err(emac_dev, "DaVinci EMAC: devm_request_irq() failed");
> +	rc = -EBUSY;
> +
>  no_cpdma_chan:
>  	if (priv->txchan)
>  		cpdma_chan_destroy(priv->txchan);
> --
> 1.7.9.5
>
> _______________________________________________
> Davinci-linux-open-source mailing list
> Davinci-linux-open-source@linux.davincidsp.com
> http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source
