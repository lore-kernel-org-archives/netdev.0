From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net] be2net: add dma_mapping_error() check for
 dma_map_page()
Date: Wed, 15 Jan 2014 07:36:32 +0000
Message-ID: <89af1a0a-785c-4dfd-93c5-b1be112d5f60@CMEXHTCAS1.ad.emulex.com>
References: <1389724139-27111-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <Ajit.Khaparde@Emulex.Com>
To: Ivan Vecera <ivecera@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:46413 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbaAOHgp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:36:45 -0500
In-Reply-To: <1389724139-27111-1-git-send-email-ivecera@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Ivan Vecera [mailto:ivecera@redhat.com]
> 
> The driver does not check value returned by dma_map_page. The patch
> fixes this as well as one additional bug. The prev_page_info is
> dereferenced after 'for' loop but if the 1st be_alloc_pages fails its
> value is NULL.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c | 13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c
> b/drivers/net/ethernet/emulex/benet/be_main.c
> index bf40fda..f2811b5 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -1776,6 +1776,7 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
>  	struct be_rx_page_info *page_info = NULL, *prev_page_info = NULL;
>  	struct be_queue_info *rxq = &rxo->q;
>  	struct page *pagep = NULL;
> +	struct device *dev = &adapter->pdev->dev;
>  	struct be_eth_rx_d *rxd;
>  	u64 page_dmaaddr = 0, frag_dmaaddr;
>  	u32 posted, page_offset = 0;
> @@ -1788,9 +1789,15 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
>  				rx_stats(rxo)->rx_post_fail++;
>  				break;
>  			}
> -			page_dmaaddr = dma_map_page(&adapter->pdev->dev, pagep,
> -						    0, adapter->big_page_size,
> +			page_dmaaddr = dma_map_page(dev, pagep, 0,
> +						    adapter->big_page_size,
>  						    DMA_FROM_DEVICE);
> +			if (dma_mapping_error(dev, page_dmaaddr)) {
> +				put_page(pagep);
> +				pagep = NULL;
> +				rx_stats(rxo)->rx_post_fail++;
> +				break;
> +			}
>  			page_info->page_offset = 0;
>  		} else {
>  			get_page(pagep);
> @@ -1816,7 +1823,7 @@ static void be_post_rx_frags(struct be_rx_obj *rxo, gfp_t gfp)
>  		queue_head_inc(rxq);
>  		page_info = &rxo->page_info_tbl[rxq->head];
>  	}
> -	if (pagep)
> +	if (pagep && prev_page_info)
>  		prev_page_info->last_page_user = true;

Ivan, if the 1st be_alloc_pages() fails, won't "pagep" be NULL aswell.
In that case, "prev_page_info" will not be dereferenced.

> 
>  	if (posted) {
> --
> 1.8.3.2
