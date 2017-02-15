From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH net-next 10/13] net: ethernet: aquantia: Checking for
 success dma_map_single.
Date: Wed, 15 Feb 2017 22:23:24 +0100
Message-ID: <60f99adb-f29f-1527-0a0a-406c39c99d0f@gmx.de>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
 <6ad9fef330a2c9b59139621efbb7c77e746d9f25.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>
To: Pavel Belous <Pavel.Belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:64771 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752204AbdBOVXg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 16:23:36 -0500
In-Reply-To: <6ad9fef330a2c9b59139621efbb7c77e746d9f25.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.02.2017 21:01, Pavel Belous wrote:
> From: Pavel Belous <pavel.belous@aquantia.com>
>
> Dma mapping can fail. We should check the result.
>
> Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
> ---
>  drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> index daed4c1..7000b9f 100644
> --- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> +++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
> @@ -476,11 +476,15 @@ static unsigned int aq_nic_map_skb_frag(struct aq_nic_s *self,
>  	unsigned int ret = 0U;
>  	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
>  	unsigned int frag_count = 0U;
> +	struct device *dev = aq_nic_get_dev(self);
>
>  	dx->flags = 0U;
>  	dx->len = skb_headlen(skb);
> -	dx->pa = dma_map_single(aq_nic_get_dev(self), skb->data, dx->len,
> -				DMA_TO_DEVICE);
> +	dx->pa = dma_map_single(dev, skb->data, dx->len, DMA_TO_DEVICE);
> +
> +	if (unlikely(dma_mapping_error(dev, dx->pa)))
> +		goto err_exit;
> +
>  	dx->len_pkt = skb->len;
>  	dx->is_sop = 1U;
>  	dx->is_mapped = 1U;
> @@ -502,8 +506,10 @@ static unsigned int aq_nic_map_skb_frag(struct aq_nic_s *self,
>
>  		frag_len = skb_frag_size(frag);
>
> -		frag_pa = skb_frag_dma_map(aq_nic_get_dev(self), frag, 0,
> +		frag_pa = skb_frag_dma_map(dev, frag, 0,
>  					   frag_len, DMA_TO_DEVICE);
> +		if (unlikely(dma_mapping_error(dev, frag_pa)))
> +			goto err_exit;


In case of this error you have to undo all mappings that you have
done so far (i.e the complete frag list and the head buffer).


>  		while (frag_len > AQ_CFG_TX_FRAME_MAX) {
>  			++dx;
> @@ -529,6 +535,7 @@ static unsigned int aq_nic_map_skb_frag(struct aq_nic_s *self,
>  	dx->is_eop = 1U;
>  	dx->skb = skb;
>
> +err_exit:
>  	return ret;
>  }
>
>

Regards,
Lino
