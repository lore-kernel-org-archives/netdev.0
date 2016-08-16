From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCHv3] net: ethernet: macb: Add support for rx_clk
Date: Tue, 16 Aug 2016 09:33:49 -0700
Message-ID: <d658e2d7-e550-b4f0-4aa1-ec7e95269724@atmel.com>
References: <1471322690-35923-1-git-send-email-shubhrajyoti.datta@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <soren.brinkmann@xilinx.com>, <shubhrajyoti.datta@gmail.com>,
	<michal.simek@xilinx.com>
To: Shubhrajyoti Datta <shubhrajyoti.datta@xilinx.com>,
	<netdev@vger.kernel.org>, <devicetree@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:35526 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292AbcHPQeV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 12:34:21 -0400
In-Reply-To: <1471322690-35923-1-git-send-email-shubhrajyoti.datta@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/08/2016 à 21:44, Shubhrajyoti Datta a écrit :
> Some of the platforms like zynqmp ultrascale+ has a
> separate clock gate for the rx clock. Add an optional
> rx_clk so that the clock can be enabled.
> 
> Signed-off-by: Shubhrajyoti Datta <shubhrajyoti.datta@xilinx.com>

Fine with me:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>


> ---
> v2:
> fix warnng
> v3
> Add that rx applies to zcu mpsoc
> 
>  Documentation/devicetree/bindings/net/macb.txt |  1 +
>  drivers/net/ethernet/cadence/macb.c            | 31 +++++++++++++++++++++-----
>  drivers/net/ethernet/cadence/macb.h            |  4 +++-
>  3 files changed, 30 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
> index b5a42df..1506e94 100644
> --- a/Documentation/devicetree/bindings/net/macb.txt
> +++ b/Documentation/devicetree/bindings/net/macb.txt
> @@ -21,6 +21,7 @@ Required properties:
>  - clock-names: Tuple listing input clock names.
>  	Required elements: 'pclk', 'hclk'
>  	Optional elements: 'tx_clk'
> +	Optional elements: 'rx_clk' applies to cdns,zynqmp-gem
>  - clocks: Phandles to input clocks.
>  
>  Optional properties for PHY child node:
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 89c0cfa..278c6e3 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2303,7 +2303,8 @@ static void macb_probe_queues(void __iomem *mem,
>  }
>  
>  static int macb_clk_init(struct platform_device *pdev, struct clk **pclk,
> -			 struct clk **hclk, struct clk **tx_clk)
> +			 struct clk **hclk, struct clk **tx_clk,
> +			 struct clk **rx_clk)
>  {
>  	int err;
>  
> @@ -2325,6 +2326,10 @@ static int macb_clk_init(struct platform_device *pdev, struct clk **pclk,
>  	if (IS_ERR(*tx_clk))
>  		*tx_clk = NULL;
>  
> +	*rx_clk = devm_clk_get(&pdev->dev, "rx_clk");
> +	if (IS_ERR(*rx_clk))
> +		*rx_clk = NULL;
> +
>  	err = clk_prepare_enable(*pclk);
>  	if (err) {
>  		dev_err(&pdev->dev, "failed to enable pclk (%u)\n", err);
> @@ -2343,8 +2348,17 @@ static int macb_clk_init(struct platform_device *pdev, struct clk **pclk,
>  		goto err_disable_hclk;
>  	}
>  
> +	err = clk_prepare_enable(*rx_clk);
> +	if (err) {
> +		dev_err(&pdev->dev, "failed to enable rx_clk (%u)\n", err);
> +		goto err_disable_txclk;
> +	}
> +
>  	return 0;
>  
> +err_disable_txclk:
> +	clk_disable_unprepare(*tx_clk);
> +
>  err_disable_hclk:
>  	clk_disable_unprepare(*hclk);
>  
> @@ -2728,12 +2742,14 @@ static const struct net_device_ops at91ether_netdev_ops = {
>  };
>  
>  static int at91ether_clk_init(struct platform_device *pdev, struct clk **pclk,
> -			      struct clk **hclk, struct clk **tx_clk)
> +			      struct clk **hclk, struct clk **tx_clk,
> +			      struct clk **rx_clk)
>  {
>  	int err;
>  
>  	*hclk = NULL;
>  	*tx_clk = NULL;
> +	*rx_clk = NULL;
>  
>  	*pclk = devm_clk_get(&pdev->dev, "ether_clk");
>  	if (IS_ERR(*pclk))
> @@ -2857,13 +2873,13 @@ MODULE_DEVICE_TABLE(of, macb_dt_ids);
>  static int macb_probe(struct platform_device *pdev)
>  {
>  	int (*clk_init)(struct platform_device *, struct clk **,
> -			struct clk **, struct clk **)
> +			struct clk **, struct clk **,  struct clk **)
>  					      = macb_clk_init;
>  	int (*init)(struct platform_device *) = macb_init;
>  	struct device_node *np = pdev->dev.of_node;
>  	struct device_node *phy_node;
>  	const struct macb_config *macb_config = NULL;
> -	struct clk *pclk, *hclk = NULL, *tx_clk = NULL;
> +	struct clk *pclk, *hclk = NULL, *tx_clk = NULL, *rx_clk = NULL;
>  	unsigned int queue_mask, num_queues;
>  	struct macb_platform_data *pdata;
>  	bool native_io;
> @@ -2891,7 +2907,7 @@ static int macb_probe(struct platform_device *pdev)
>  		}
>  	}
>  
> -	err = clk_init(pdev, &pclk, &hclk, &tx_clk);
> +	err = clk_init(pdev, &pclk, &hclk, &tx_clk, &rx_clk);
>  	if (err)
>  		return err;
>  
> @@ -2927,6 +2943,7 @@ static int macb_probe(struct platform_device *pdev)
>  	bp->pclk = pclk;
>  	bp->hclk = hclk;
>  	bp->tx_clk = tx_clk;
> +	bp->rx_clk = rx_clk;
>  	if (macb_config)
>  		bp->jumbo_max_len = macb_config->jumbo_max_len;
>  
> @@ -3020,6 +3037,7 @@ err_disable_clocks:
>  	clk_disable_unprepare(tx_clk);
>  	clk_disable_unprepare(hclk);
>  	clk_disable_unprepare(pclk);
> +	clk_disable_unprepare(rx_clk);
>  
>  	return err;
>  }
> @@ -3046,6 +3064,7 @@ static int macb_remove(struct platform_device *pdev)
>  		clk_disable_unprepare(bp->tx_clk);
>  		clk_disable_unprepare(bp->hclk);
>  		clk_disable_unprepare(bp->pclk);
> +		clk_disable_unprepare(bp->rx_clk);
>  		free_netdev(dev);
>  	}
>  
> @@ -3069,6 +3088,7 @@ static int __maybe_unused macb_suspend(struct device *dev)
>  		clk_disable_unprepare(bp->tx_clk);
>  		clk_disable_unprepare(bp->hclk);
>  		clk_disable_unprepare(bp->pclk);
> +		clk_disable_unprepare(bp->rx_clk);
>  	}
>  
>  	return 0;
> @@ -3088,6 +3108,7 @@ static int __maybe_unused macb_resume(struct device *dev)
>  		clk_prepare_enable(bp->pclk);
>  		clk_prepare_enable(bp->hclk);
>  		clk_prepare_enable(bp->tx_clk);
> +		clk_prepare_enable(bp->rx_clk);
>  	}
>  
>  	netif_device_attach(netdev);
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index 36893d8..10485b6 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -763,7 +763,8 @@ struct macb_config {
>  	u32			caps;
>  	unsigned int		dma_burst_length;
>  	int	(*clk_init)(struct platform_device *pdev, struct clk **pclk,
> -			    struct clk **hclk, struct clk **tx_clk);
> +			    struct clk **hclk, struct clk **tx_clk,
> +			    struct clk **rx_clk);
>  	int	(*init)(struct platform_device *pdev);
>  	int	jumbo_max_len;
>  };
> @@ -809,6 +810,7 @@ struct macb {
>  	struct clk		*pclk;
>  	struct clk		*hclk;
>  	struct clk		*tx_clk;
> +	struct clk		*rx_clk;
>  	struct net_device	*dev;
>  	struct napi_struct	napi;
>  	struct net_device_stats	stats;
> 


-- 
Nicolas Ferre
