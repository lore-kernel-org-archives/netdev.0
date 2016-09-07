From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH net-next v5 1/2] net: ethernet: mediatek: enhance RX path
 by reducing the frequency of the memory barrier used
Date: Wed, 7 Sep 2016 08:35:32 +0200
Message-ID: <a12e7967-992a-c0d4-01f0-b1699bd5808b@phrozen.org>
References: <1472896767-18352-1-git-send-email-sean.wang@mediatek.com>
 <1472896767-18352-2-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, keyhaede@gmail.com,
        objelf@gmail.com
To: sean.wang@mediatek.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:57736 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752040AbcIGGfj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 02:35:39 -0400
In-Reply-To: <1472896767-18352-2-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/09/2016 11:59, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
> 
> The patch makes move wmb() to outside the loop that could help
> RX path handling more faster although that RX descriptors aren't
> freed for DMA to use as soon as possible, but based on my experiment
> and the result shows it still can reach about 943Mbpis without
> performance drop that is tested based on the setup with one port
> using Giga PHY and 256 RX descriptors for DMA to move.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>

gave it a quick spin on my hardware and it works well even when using
more than 1 gmac.

Acked-by: John Crispin <john@phrozen.org>

> ---
>  drivers/net/ethernet/mediatek/mtk_eth_soc.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> index 431b851..a1bdb53 100644
> --- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> +++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
> @@ -890,13 +890,14 @@ release_desc:
>  		rxd->rxd2 = RX_DMA_PLEN0(ring->buf_size);
>  
>  		ring->calc_idx = idx;
> -		/* make sure that all changes to the dma ring are flushed before
> -		 * we continue
> -		 */
> -		wmb();
> -		mtk_w32(eth, ring->calc_idx, MTK_PRX_CRX_IDX0);
> +
>  		done++;
>  	}
> +	/* make sure that all changes to the dma ring are flushed before
> +	 * we continue
> +	 */
> +	wmb();
> +	mtk_w32(eth, ring->calc_idx, MTK_PRX_CRX_IDX0);
>  
>  	if (done < budget)
>  		mtk_w32(eth, MTK_RX_DONE_INT, MTK_PDMA_INT_STATUS);
> 
