From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 02/15] drivers, net, ethernet: convert
 mtk_eth.dma_refcnt from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 16:08:47 +0800
Message-ID: <1508486927.29850.12.camel@mtkswgap22>
References: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
 <1508484229-19706-3-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
 zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ganeshgr-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
 ajk-iz34hMvxm2Hmj42eshorlhS11BummzK+@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org, matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-ppp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-mediatek-bounces+glpam-linux-mediatek=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1508484229-19706-3-git-send-email-elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

On Fri, 2017-10-20 at 10:23 +0300, Elena Reshetova wrote:
> atomic_t variables are currently used to implement reference
> counters with the following properties:
>  - counter is initialized to 1 using atomic_set()
>  - a resource is freed upon counter reaching zero
>  - once counter reaches zero, its further
>    increments aren't allowed
>  - counter schema uses basic atomic operations
>    (set, inc, inc_not_zero, dec_and_test, etc.)
> 
> Such atomic variables should be converted to a newly provided
> refcount_t type and API that prevents accidental counter overflows
> and underflows. This is important since overflows and underflows
> can lead to use-after-free situation and be exploitable.
> 
> The variable mtk_eth.dma_refcnt is used as pure reference counter.
> Convert it to refcount_t and fix up the operations.
> 
> Suggested-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Reviewed-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Reviewed-by: Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 8 +++++---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.h | 4 +++-
>  2 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 5e81a72..54adfd9 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -1817,7 +1817,7 @@ static int mtk_open(struct net_device *dev)
>  	struct mtk_eth *eth = mac->hw;
>  
>  	/* we run 2 netdevs on the same dma ring so we only bring it up once */
> -	if (!atomic_read(&eth->dma_refcnt)) {
> +	if (!refcount_read(&eth->dma_refcnt)) {
>  		int err = mtk_start_dma(eth);
>  
>  		if (err)
> @@ -1827,8 +1827,10 @@ static int mtk_open(struct net_device *dev)
>  		napi_enable(&eth->rx_napi);
>  		mtk_tx_irq_enable(eth, MTK_TX_DONE_INT);
>  		mtk_rx_irq_enable(eth, MTK_RX_DONE_INT);
> +		refcount_set(&eth->dma_refcnt, 1);

the existing driver seems to have a missing initial atomic_set for the
eth->dma_refcnt. 

>  	}
> -	atomic_inc(&eth->dma_refcnt);
> +	else
> +		refcount_inc(&eth->dma_refcnt);
>  

how about add the initial refcount_set into probe handler, and keep
logic else unchanged ? 

>  	phy_start(dev->phydev);
>  	netif_start_queue(dev);
> @@ -1868,7 +1870,7 @@ static int mtk_stop(struct net_device *dev)
>  	phy_stop(dev->phydev);
>  
>  	/* only shutdown DMA if this is the last user */
> -	if (!atomic_dec_and_test(&eth->dma_refcnt))
> +	if (!refcount_dec_and_test(&eth->dma_refcnt))
>  		return 0;
>  
>  	mtk_tx_irq_disable(eth, MTK_TX_DONE_INT);
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.h b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> index 3d3c24a..a3af466 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.h
> @@ -15,6 +15,8 @@
>  #ifndef MTK_ETH_H
>  #define MTK_ETH_H
>  
> +#include <linux/refcount.h>
> +
>  #define MTK_QDMA_PAGE_SIZE	2048
>  #define	MTK_MAX_RX_LENGTH	1536
>  #define MTK_TX_DMA_BUF_LEN	0x3fff
> @@ -632,7 +634,7 @@ struct mtk_eth {
>  	struct regmap			*pctl;
>  	u32				chip_id;
>  	bool				hwlro;
> -	atomic_t			dma_refcnt;
> +	refcount_t			dma_refcnt;
>  	struct mtk_tx_ring		tx_ring;
>  	struct mtk_rx_ring		rx_ring[MTK_MAX_RX_RING_NUM];
>  	struct mtk_rx_ring		rx_ring_qdma;
