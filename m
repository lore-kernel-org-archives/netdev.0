From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 4/9] mlx4: get rid of frag_prefix_size
Date: Thu, 9 Feb 2017 14:28:15 +0200
Message-ID: <008c9016-6781-374a-ab78-79c3a9af0f06@gmail.com>
References: <20170207030240.31357-1-edumazet@google.com>
 <20170207030240.31357-5-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35085 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751543AbdBIM5c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 07:57:32 -0500
Received: by mail-wr0-f196.google.com with SMTP id o16so11872071wra.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 04:57:32 -0800 (PST)
In-Reply-To: <20170207030240.31357-5-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 07/02/2017 5:02 AM, Eric Dumazet wrote:
> Using per frag storage for frag_prefix_size is really silly.
>
> mlx4_en_complete_rx_desc() has all needed info already.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 27 ++++++++++++---------------
>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  3 +--
>   2 files changed, 13 insertions(+), 17 deletions(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index f868cb330039f5730ab8f59eca451c3d5272..c6c64ac1e25931fc172beb5c718ec3a799f6 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -585,15 +585,14 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
>   				    int length)
>   {
>   	struct skb_frag_struct *skb_frags_rx = skb_shinfo(skb)->frags;
> -	struct mlx4_en_frag_info *frag_info;
> -	int nr;
> +	struct mlx4_en_frag_info *frag_info = priv->frag_info;
> +	int nr, frag_size;
>   	dma_addr_t dma;
>   
>   	/* Collect used fragments while replacing them in the HW descriptors */
> -	for (nr = 0; nr < priv->num_frags; nr++) {
> -		frag_info = &priv->frag_info[nr];
> -		if (length <= frag_info->frag_prefix_size)
> -			break;
> +	for (nr = 0;;) {
> +		frag_size = min_t(int, length, frag_info->frag_size);
> +
>   		if (unlikely(!frags[nr].page))
>   			goto fail;
>   
> @@ -603,15 +602,16 @@ static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
>   
>   		__skb_fill_page_desc(skb, nr, frags[nr].page,
>   				     frags[nr].page_offset,
> -				     frag_info->frag_size);
> +				     frag_size);
Same for dma_sync_single (two lines above).
>   
>   		skb->truesize += frag_info->frag_stride;
>   		frags[nr].page = NULL;
> +		nr++;
> +		length -= frag_size;
> +		if (!length)
> +			break;
> +		frag_info++;
>   	}
> -	/* Adjust size of last fragment to match actual length */
> -	if (nr > 0)
> -		skb_frag_size_set(&skb_frags_rx[nr - 1],
> -			length - priv->frag_info[nr - 1].frag_prefix_size);
>   	return nr;
>   
>   fail:
> @@ -1194,7 +1194,6 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
>   	if (priv->tx_ring_num[TX_XDP]) {
>   		priv->rx_page_order = 0;
>   		priv->frag_info[0].frag_size = eff_mtu;
> -		priv->frag_info[0].frag_prefix_size = 0;
>   		/* This will gain efficient xdp frame recycling at the
>   		 * expense of more costly truesize accounting
>   		 */
> @@ -1209,7 +1208,6 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
>   			priv->frag_info[i].frag_size =
>   				(eff_mtu > buf_size + frag_sizes[i]) ?
>   					frag_sizes[i] : eff_mtu - buf_size;
> -			priv->frag_info[i].frag_prefix_size = buf_size;
>   			priv->frag_info[i].frag_stride =
>   				ALIGN(priv->frag_info[i].frag_size,
>   				      SMP_CACHE_BYTES);
> @@ -1229,10 +1227,9 @@ void mlx4_en_calc_rx_buf(struct net_device *dev)
>   	       eff_mtu, priv->num_frags);
>   	for (i = 0; i < priv->num_frags; i++) {
>   		en_err(priv,
> -		       "  frag:%d - size:%d prefix:%d stride:%d\n",
> +		       "  frag:%d - size:%d stride:%d\n",
>   		       i,
>   		       priv->frag_info[i].frag_size,
> -		       priv->frag_info[i].frag_prefix_size,
>   		       priv->frag_info[i].frag_stride);
>   	}
>   }
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> index 11898550f87c077f6687903790d329e4aa1e..fe8ed4e85e9645679cc37d0d30284b523689 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> @@ -472,9 +472,8 @@ struct mlx4_en_mc_list {
>   
>   struct mlx4_en_frag_info {
>   	u16 frag_size;
> -	u16 frag_prefix_size;
> -	u32 frag_stride;
>   	u16 rx_headroom;
> +	u32 frag_stride;
>   };
>   
>   #ifdef CONFIG_MLX4_EN_DCB
