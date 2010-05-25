From: Tobias Klauser <klto@zhaw.ch>
Subject: Re: [Nios2-dev] [PATCH] ethoc: fix null dereference in ethoc_probe
Date: Tue, 25 May 2010 08:16:43 +0200
Message-ID: <4BFB6B4B.3020107@zhaw.ch>
References: <20100522155455.GE22515@bicker> <1274669042-1901-1-git-send-email-thomas@wytron.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thierry.reding@avionic-design.de,
	linux-kernel@vger.kernel.org, Dan Carpenter <error27@gmail.com>
To: nios2-dev@sopc.et.ntust.edu.tw
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1274669042-1901-1-git-send-email-thomas@wytron.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/24/2010 04:44 AM, Thomas Chou wrote:
> Dan reported the patch 0baa080c75c: "ethoc: use system memory
> as buffer" introduced a potential null dereference.
> 
>   1060  free:
>   1061          if (priv->dma_alloc)
>                     ^^^^^^^^^^^^^^^
> 	priv can be null here.
> 
> He also suggested that the error handling is not complete.
> 
> This patch fixes the null priv issue and improves resources
> releasing in ethoc_probe() and ethoc_remove().
> 
> Reported-by: Dan Carpenter <error27@gmail.com>
> Signed-off-by: Thomas Chou <thomas@wytron.com.tw>
> ---
>  drivers/net/ethoc.c |   34 ++++++++++++++++++++++++++++++----
>  1 files changed, 30 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
> index a8d9250..fddd5f5 100644
> --- a/drivers/net/ethoc.c
> +++ b/drivers/net/ethoc.c
> @@ -174,6 +174,7 @@ MODULE_PARM_DESC(buffer_size, "DMA buffer allocation size");
>   * @iobase:	pointer to I/O memory region
>   * @membase:	pointer to buffer memory region
>   * @dma_alloc:	dma allocated buffer size
> + * @io_region_size:	I/O memory region size
>   * @num_tx:	number of send buffers
>   * @cur_tx:	last send buffer written
>   * @dty_tx:	last buffer actually sent
> @@ -193,6 +194,7 @@ struct ethoc {
>  	void __iomem *iobase;
>  	void __iomem *membase;
>  	int dma_alloc;
> +	resource_size_t io_region_size;
>  
>  	unsigned int num_tx;
>  	unsigned int cur_tx;
> @@ -944,6 +946,7 @@ static int ethoc_probe(struct platform_device *pdev)
>  	priv = netdev_priv(netdev);
>  	priv->netdev = netdev;
>  	priv->dma_alloc = 0;
> +	priv->io_region_size = mmio->end - mmio->start + 1;

Better use the resource_size inline here.

>  	priv->iobase = devm_ioremap_nocache(&pdev->dev, netdev->base_addr,
>  			resource_size(mmio));
                        ^^^
Then you could use the io_region_size here to avoid calculating the size
again.

> @@ -1049,20 +1052,34 @@ static int ethoc_probe(struct platform_device *pdev)
>  	ret = register_netdev(netdev);
>  	if (ret < 0) {
>  		dev_err(&netdev->dev, "failed to register interface\n");
> -		goto error;
> +		goto error2;
>  	}
>  
>  	goto out;
>  
> +error2:
> +	netif_napi_del(&priv->napi);
>  error:
>  	mdiobus_unregister(priv->mdio);
>  free_mdio:
>  	kfree(priv->mdio->irq);
>  	mdiobus_free(priv->mdio);
>  free:
> -	if (priv->dma_alloc)
> -		dma_free_coherent(NULL, priv->dma_alloc, priv->membase,
> -			netdev->mem_start);
> +	if (priv) {
> +		if (priv->dma_alloc)
> +			dma_free_coherent(NULL, priv->dma_alloc, priv->membase,
> +					  netdev->mem_start);
> +		else if (priv->membase)
> +			devm_iounmap(&pdev->dev, priv->membase);
> +		if (priv->iobase)
> +			devm_iounmap(&pdev->dev, priv->iobase);
> +	}
> +	if (mem)
> +		devm_release_mem_region(&pdev->dev, mem->start,
> +					mem->end - mem->start + 1);

resource_size again

> +	if (mmio)
> +		devm_release_mem_region(&pdev->dev, mmio->start,
> +					mmio->end - mmio->start + 1);

ditto

>  	free_netdev(netdev);
>  out:
>  	return ret;
> @@ -1080,6 +1097,7 @@ static int ethoc_remove(struct platform_device *pdev)
>  	platform_set_drvdata(pdev, NULL);
>  
>  	if (netdev) {
> +		netif_napi_del(&priv->napi);
>  		phy_disconnect(priv->phy);
>  		priv->phy = NULL;
>  
> @@ -1091,6 +1109,14 @@ static int ethoc_remove(struct platform_device *pdev)
>  		if (priv->dma_alloc)
>  			dma_free_coherent(NULL, priv->dma_alloc, priv->membase,
>  				netdev->mem_start);
> +		else {
> +			devm_iounmap(&pdev->dev, priv->membase);
> +			devm_release_mem_region(&pdev->dev, netdev->mem_start,
> +				netdev->mem_end - netdev->mem_start + 1);
> +		}
> +		devm_iounmap(&pdev->dev, priv->iobase);
> +		devm_release_mem_region(&pdev->dev, netdev->base_addr,
> +			priv->io_region_size);
>  		unregister_netdev(netdev);
>  		free_netdev(netdev);
>  	}
