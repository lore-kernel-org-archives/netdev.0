From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Subject: Re: [RESEND PATCH net 07/10] net: ethernet: mediatek: fix issue of
 driver removal with interface is up
Date: Thu, 25 Aug 2016 15:35:34 +0200
Message-ID: <2203871f-d73d-3a39-928d-39862ba5e367@phrozen.org>
References: <1472121901-15629-1-git-send-email-sean.wang@mediatek.com>
 <1472121901-15629-8-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1472121901-15629-8-git-send-email-sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-mediatek/>
List-Post: <mailto:linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-mediatek>,
 <mailto:linux-mediatek-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-mediatek" <linux-mediatek-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org



On 25/08/2016 12:44, Sean Wang wrote:
> 1) mtk_stop() must be called to stop for freeing DMA resources
> acquired and restoring state changed by mtk_open() when module
> removal.
> 
> 2) group clock disabled related function into mtk_hw_deinit which
> could be reused with others functionality such as the whole ethernet
> reset that would be posted in the later series of patches.
> 

Hi Sean,

these are 2 unrelated changes so they really need to go into two
separate patches. i also think that change 1) would better fit into the
future series making use of that functionality.

	John

> Signed-off-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 22 ++++++++++++++++++----
>  1 file changed, 18 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 0a4c782..c573475 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -1478,6 +1478,16 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
>  	return 0;
>  }
>  
> +static int mtk_hw_deinit(struct mtk_eth *eth)
> +{
> +	clk_disable_unprepare(eth->clk_esw);
> +	clk_disable_unprepare(eth->clk_gp1);
> +	clk_disable_unprepare(eth->clk_gp2);
> +	clk_disable_unprepare(eth->clk_ethif);
> +
> +	return 0;
> +}
> +
>  static int __init mtk_init(struct net_device *dev)
>  {
>  	struct mtk_mac *mac = netdev_priv(dev);
> @@ -1919,11 +1929,15 @@ err_free_dev:
>  static int mtk_remove(struct platform_device *pdev)
>  {
>  	struct mtk_eth *eth = platform_get_drvdata(pdev);
> +	int i;
>  
> -	clk_disable_unprepare(eth->clk_ethif);
> -	clk_disable_unprepare(eth->clk_esw);
> -	clk_disable_unprepare(eth->clk_gp1);
> -	clk_disable_unprepare(eth->clk_gp2);
> +	/* stop all devices to make sure that dma is properly shut down */
> +	for (i = 0; i < MTK_MAC_COUNT; i++) {
> +		if (!eth->netdev[i])
> +			continue;
> +		mtk_stop(eth->netdev[i]);
> +	}
> +	mtk_hw_deinit(eth);
>  
>  	netif_napi_del(&eth->tx_napi);
>  	netif_napi_del(&eth->rx_napi);
> 
