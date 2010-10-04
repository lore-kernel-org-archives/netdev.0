From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: ixgbe: normalize frag_list usage
Date: Mon, 04 Oct 2010 11:04:18 -0700
Message-ID: <4CAA1722.7070405@intel.com>
References: <20101003.235400.229759758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48233 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756324Ab0JDSEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 14:04:21 -0400
In-Reply-To: <20101003.235400.229759758.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
> 
> Basically I want to get the whole tree to consistently use
> the convention that the frag list is built as packets arrive
> by using "skb->prev" of the head skb to track the tail member
> of the frag list.
> 
> This will allow me to do something like:
> 
> struct sk_buff {
>        union {
> 		struct {
> 			struct sk_buff *next;
> 			struct sk_buff *prev;
> 		};
> 		struct {
> 			struct sk_buff *frag_next;
> 			struct sk_buff *frag_tail_tracker;
> 		};
> 	}
>  ...
> }
> 
> And have all frag_list code use these members consistently.
> 
> While doing this patch I noticed that there are some left-over bits in
> the IXGBEVF driver that builds these IXGBE style (before my patch)
> skb->prev RSC chains.
> 
> But nothing other than the RX ring shutdown code processes them, so
> likely if they are created they will leak or cause some other kind of
> problem.
> 
> Please take a look, thanks.
> 
> diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
> index 5cebc37..434c9fa 100644
> --- a/drivers/net/ixgbe/ixgbe.h
> +++ b/drivers/net/ixgbe/ixgbe.h
> @@ -181,6 +181,7 @@ struct ixgbe_ring {
>  	struct ixgbe_queue_stats stats;
>  	unsigned long reinit_state;
>  	int numa_node;
> +	struct sk_buff *rsc_skb;	/* RSC packet being built */
>  	u64 rsc_count;			/* stat for coalesced packets */
>  	u64 rsc_flush;			/* stats for flushed packets */
>  	u32 restart_queue;		/* track tx queue restarts */

This will not work for RSC due to the fact that it assumes only one RSC 
context is active per ring and that is not the case.  There can be 
multiple RSC combined flows interlaced on the ring.

It occurs to me that RSC needs the inverse of what you need for frag 
list handling.  You state that you need the next and tail pointers, 
while RSC really needs the prev and head pointers.  One possible 
solution for all this would be to just reverse the logic a bit.

What you are setting up right now is essentially a head based layout 
based on the idea that th head it the component you will have access to. 
   RSC on the other hand is a tail based layout.  If we were to overload 
skb->next so that it pointed at head from tail in ixgbe then we could 
make RSC function, and probably even improve the performance a bit by 
getting rid of the extra RSC transform at the end of creating RSC packets.

Below I have made suggestions based on a tail based approach if we 
overloaded the next pointer on the tail packet to point to the head.

> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index c35e13c..43987a4 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -1130,36 +1130,6 @@ static inline u32 ixgbe_get_rsc_count(union ixgbe_adv_rx_desc *rx_desc)
>  		IXGBE_RXDADV_RSCCNT_SHIFT;
>  }
>  
> -/**
> - * ixgbe_transform_rsc_queue - change rsc queue into a full packet
> - * @skb: pointer to the last skb in the rsc queue
> - * @count: pointer to number of packets coalesced in this context
> - *
> - * This function changes a queue full of hw rsc buffers into a completed
> - * packet.  It uses the ->prev pointers to find the first packet and then
> - * turns it into the frag list owner.
> - **/
> -static inline struct sk_buff *ixgbe_transform_rsc_queue(struct sk_buff *skb,
> -							u64 *count)
> -{
> -	unsigned int frag_list_size = 0;
> -
> -	while (skb->prev) {
> -		struct sk_buff *prev = skb->prev;
> -		frag_list_size += skb->len;
> -		skb->prev = NULL;
> -		skb = prev;
> -		*count += 1;
> -	}
> -
> -	skb_shinfo(skb)->frag_list = skb->next;
> -	skb->next = NULL;
> -	skb->len += frag_list_size;
> -	skb->data_len += frag_list_size;
> -	skb->truesize += frag_list_size;
> -	return skb;
> -}
> -
>  struct ixgbe_rsc_cb {
>  	dma_addr_t dma;
>  	bool delay_unmap;

So this could probably go since we wouldn't need it for the new approach.

> @@ -1216,10 +1186,13 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>  		prefetch(skb->data);
>  		rx_buffer_info->skb = NULL;
>  
> +		if (!(staterr & IXGBE_RXD_STAT_EOP)) {
> +			rx_ring->rsc_skb = skb;
> +			rx_ring->rsc_count++;
> +		}
>  		if (rx_buffer_info->dma) {
>  			if ((adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
> -			    (!(staterr & IXGBE_RXD_STAT_EOP)) &&
> -				 (!(skb->prev))) {
> +			    rx_ring->rsc_skb == skb) {
>  				/*
>  				 * When HWRSC is enabled, delay unmapping
>  				 * of the first packet. It carries the

This bit of code is based on the flawed assumption that RSC doesn't have 
other packets interlaced with is not true.

> @@ -1279,9 +1252,12 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>  		}
>  
>  		if (staterr & IXGBE_RXD_STAT_EOP) {
> -			if (skb->prev)
> -				skb = ixgbe_transform_rsc_queue(skb,
> -								&(rx_ring->rsc_count));
> +			if (rx_ring->rsc_skb) {
> +				skb = rx_ring->rsc_skb;
> +				rx_ring->rsc_skb = NULL;
> +
> +				skb->prev = NULL;
> +			}
>  			if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
>  				if (IXGBE_RSC_CB(skb)->delay_unmap) {
>  					dma_unmap_single(&pdev->dev,

So this bit of code could be changed to something like:
			if (skb->next) {
				skb = skb->next;
				skb->frag_tail_tracker->next == NULL;
			}

> @@ -1307,8 +1283,22 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>  				next_buffer->skb = skb;
>  				next_buffer->dma = 0;
>  			} else {
> -				skb->next = next_buffer->skb;
> -				skb->next->prev = skb;
> +				struct sk_buff *head = rx_ring->rsc_skb;
> +				struct sk_buff *next = next_buffer->skb;
> +
> +				if (!skb_shinfo(head)->frag_list) {
> +					skb_shinfo(head)->frag_list = next;
> +				} else {
> +					head->prev->next = next;
> +				}
> +
> +				/* ->prev tracks the last skb in the frag_list */
> +				head->prev = next;
> +				rx_ring->rsc_count++;
> +		
> +				head->len += next->len;
> +				head->data_len += next->len;
> +				head->truesize += next->len;
>  			}
>  			rx_ring->non_eop_descs++;
>  			goto next_desc;

This piece is a bit trickier, the len/data_len/truesize addition needs 
to be done on all packets and it looks like it was only done on the 
non-EOP packets which may be an issue.  My guess would be that it would 
probably work if we added something along of the lines of the following 
before the EOP check:
		if (skb->next) {
			skb->next->len += skb->len;
			skb->next->data_len += skb->data_len;
			skb->next->truesize += skb->truesize;
			rx_ring->rsc_count++;
		}

My thoughts for the rest of the code for the non-EOP case would be 
something more along the lines of:
		if (skb->next) {
			next_buffer->skb->next = skb->next;
			skb->next->frag_tail_tracker = next_buffer->skb;
			skb->next = next_buffer->skb;
		}

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

