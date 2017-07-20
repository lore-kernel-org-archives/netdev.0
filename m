From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: Push the request_irq function to
 the end of probe
Date: Thu, 20 Jul 2017 11:08:09 -0500
Message-ID: <5259f0e7-cc5d-35c9-8f09-94cf7b40f653@ti.com>
References: <1500550192-6550-1-git-send-email-j-keerthy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-omap@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <johan@kernel.org>,
        <ivan.khoronzhuk@linaro.org>, <t-kristo@ti.com>, <nsekhar@ti.com>
To: Keerthy <j-keerthy@ti.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1500550192-6550-1-git-send-email-j-keerthy@ti.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/20/2017 06:29 AM, Keerthy wrote:
> Push the request_irq function to the end of probe so as
> to ensure all the required fields are populated in the event
> of an ISR getting executed right after requesting the irq.
> 
> Currently while loading the crash kernel a crash was seen as
> soon as devm_request_threaded_irq was called. This was due to
> n->poll being NULL which is called as part of net_rx_action
> function.
> 

In general patch looks good to me, but it's really unexpected to
receive IRQs while CPSW is probing ;(

So, case you have is:
- loading the crash kernel with CPSW driver enabled
- HW is in unpredictable state (CPDMA queues can be filled with
descriptors which ca point on memory this kernel instance do
not own).

In my opinion, CPSW driver should not be the part of crash kernel by default and
if networking functionality is required then it should be loaded as module.
And to make things work right It might be required to add in probe
call 
 soft_reset("cpsw", &cpsw->regs->soft_reset);
right after
 pm_runtime_get_sync(&pdev->dev)

Could you confirm that it will fix issue without your patch, pls?

> Suggested-by: Sekhar Nori <nsekhar@ti.com>
> Signed-off-by: Keerthy <j-keerthy@ti.com>
> ---
>   drivers/net/ethernet/ti/cpsw.c | 49 +++++++++++++++++++++---------------------
>   1 file changed, 25 insertions(+), 24 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 37fc165..94892d5 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -3085,6 +3085,31 @@ static int cpsw_probe(struct platform_device *pdev)
>   			cpsw->quirk_irq = true;
>   	}
>   
> +	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
> +
> +	ndev->netdev_ops = &cpsw_netdev_ops;
> +	ndev->ethtool_ops = &cpsw_ethtool_ops;
> +	netif_napi_add(ndev, &cpsw->napi_rx, cpsw_rx_poll, CPSW_POLL_WEIGHT);
> +	netif_tx_napi_add(ndev, &cpsw->napi_tx, cpsw_tx_poll, CPSW_POLL_WEIGHT);
> +	cpsw_split_res(ndev);
> +
> +	/* register the network device */
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +	ret = register_netdev(ndev);
> +	if (ret) {
> +		dev_err(priv->dev, "error registering net device\n");
> +		ret = -ENODEV;
> +		goto clean_ale_ret;
> +	}
> +
> +	if (cpsw->data.dual_emac) {
> +		ret = cpsw_probe_dual_emac(priv);
> +		if (ret) {
> +			cpsw_err(priv, probe, "error probe slave 2 emac interface\n");
> +			goto clean_unregister_netdev_ret;
> +		}
> +	}
> +
>   	/* Grab RX and TX IRQs. Note that we also have RX_THRESHOLD and
>   	 * MISC IRQs which are always kept disabled with this driver so
>   	 * we will not request them.
> @@ -3123,33 +3148,9 @@ static int cpsw_probe(struct platform_device *pdev)
>   		goto clean_ale_ret;
>   	}
>   
> -	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
> -
> -	ndev->netdev_ops = &cpsw_netdev_ops;
> -	ndev->ethtool_ops = &cpsw_ethtool_ops;
> -	netif_napi_add(ndev, &cpsw->napi_rx, cpsw_rx_poll, CPSW_POLL_WEIGHT);
> -	netif_tx_napi_add(ndev, &cpsw->napi_tx, cpsw_tx_poll, CPSW_POLL_WEIGHT);
> -	cpsw_split_res(ndev);
> -
> -	/* register the network device */
> -	SET_NETDEV_DEV(ndev, &pdev->dev);
> -	ret = register_netdev(ndev);
> -	if (ret) {
> -		dev_err(priv->dev, "error registering net device\n");
> -		ret = -ENODEV;
> -		goto clean_ale_ret;
> -	}
> -
>   	cpsw_notice(priv, probe,
>   		    "initialized device (regs %pa, irq %d, pool size %d)\n",
>   		    &ss_res->start, ndev->irq, dma_params.descs_pool_size);
> -	if (cpsw->data.dual_emac) {
> -		ret = cpsw_probe_dual_emac(priv);
> -		if (ret) {
> -			cpsw_err(priv, probe, "error probe slave 2 emac interface\n");
> -			goto clean_unregister_netdev_ret;
> -		}
> -	}
>   
>   	pm_runtime_put(&pdev->dev);
>   
> 

-- 
regards,
-grygorii
