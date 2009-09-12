From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Account for VLAN tag in tx_le_req
Date: Fri, 11 Sep 2009 21:42:18 -0700
Message-ID: <20090911214218.0cac5253@nehalam>
References: <4AAB12C9.3070707@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36278 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751036AbZILEmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Sep 2009 00:42:36 -0400
In-Reply-To: <4AAB12C9.3070707@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 12 Sep 2009 12:17:29 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> With VLAN enabled, tx_le_req would return on less list elements than required,
>  leading to a potential wrap around of the transmit ring buffer.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>
> ---
>  drivers/net/sky2.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 00bc65a..018aa58 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -66,7 +66,7 @@
>  
>  /* This is the worst case number of transmit list elements for a single skb:
>     VLAN + TSO + CKSUM + Data + skb_frags * DMA */
> -#define MAX_SKB_TX_LE	(4 + (sizeof(dma_addr_t)/sizeof(u32))*MAX_SKB_FRAGS)
> +#define MAX_SKB_TX_LE	(5 + (sizeof(dma_addr_t)/sizeof(u32))*MAX_SKB_FRAGS)
>  #define TX_MIN_PENDING		(MAX_SKB_TX_LE+1)
>  #define TX_MAX_PENDING		4096
>  #define TX_DEF_PENDING		127
> @@ -1576,6 +1576,11 @@ static unsigned tx_le_req(const struct sk_buff *skb)
>  	if (skb->ip_summed == CHECKSUM_PARTIAL)
>  		++count;
>  
> +#ifdef SKY2_VLAN_TAG_USED
> +	if (vlan_tx_tag_present(skb))
> +		++count;
> +#endif
> +
>  	return count;
>  }
>  

The vlan tag can be nested with either ADDR64 or GSO element.
The correct test would be to do something like:

    	if (skb_is_gso(skb))
		++count;
        else if (sizeof(dma_addr_t) == sizeof(u32) && 
                 vlan_tx_tag_present(skb))
                ++count;

And the MAX_SKB_TX_LE value is fine. 

-- 
