From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Subject: Re: [PATCH v2 net] net: qualcomm: rmnet: Fix a double free
Date: Sat, 09 Sep 2017 12:59:04 -0600
Message-ID: <2c40c295a607d3d6b9029e48cc130e69@codeaurora.org>
References: <20170909085803.zgfqhp23yt4ol3ka@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170909085803.zgfqhp23yt4ol3ka@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2017-09-09 02:58, Dan Carpenter wrote:
> There is a typo here so we accidentally free "skb" instead of "skbn".
> It leads to a double free and a leak.  After discussing with Subash,
> it's better to just move the check before the allocation and avoid the
> need to free.
> 
> Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial
> implementation")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: Fix the leak as well.  Thanks Subash!
> 
> diff --git a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
> b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
> index 557c9bf1a469..86b8c758f94e 100644
> --- a/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
> +++ b/drivers/net/ethernet/qualcomm/rmnet/rmnet_map_data.c
> @@ -84,6 +84,10 @@ struct sk_buff *rmnet_map_deaggregate(struct sk_buff 
> *skb)
>  	if (((int)skb->len - (int)packet_len) < 0)
>  		return NULL;
> 
> +	/* Some hardware can send us empty frames. Catch them */
> +	if (ntohs(maph->pkt_len) == 0)
> +		return NULL;
> +
>  	skbn = alloc_skb(packet_len + RMNET_MAP_DEAGGR_SPACING, GFP_ATOMIC);
>  	if (!skbn)
>  		return NULL;
> @@ -94,11 +98,5 @@ struct sk_buff *rmnet_map_deaggregate(struct sk_buff 
> *skb)
>  	memcpy(skbn->data, skb->data, packet_len);
>  	skb_pull(skb, packet_len);
> 
> -	/* Some hardware can send us empty frames. Catch them */
> -	if (ntohs(maph->pkt_len) == 0) {
> -		kfree_skb(skb);
> -		return NULL;
> -	}
> -
>  	return skbn;
>  }

Acked-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>


-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a 
Linux Foundation Collaborative Project
