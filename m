From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: ixgbe: normalize frag_list usage
Date: Mon, 4 Oct 2010 08:37:46 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755F950A136@orsmsx508.amr.corp.intel.com>
References: <20101003.235400.229759758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:65080 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751473Ab0JDPiH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 11:38:07 -0400
In-Reply-To: <20101003.235400.229759758.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RSC isn't actually supported in virtual functions or even when SR-IOV mode is enabled.  Any left over bits are just cruft from when the vf driver was ported from the pf driver.

I'll have a look at it.

- Gerg

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
> Behalf Of David Miller
> Sent: Sunday, October 03, 2010 11:54 PM
> To: Kirsher, Jeffrey T
> Cc: Brandeburg, Jesse; Allan, Bruce W; netdev@vger.kernel.org
> Subject: ixgbe: normalize frag_list usage
> 
> 
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
> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index c35e13c..43987a4 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -1130,36 +1130,6 @@ static inline u32 ixgbe_get_rsc_count(union
> ixgbe_adv_rx_desc *rx_desc)
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
> @@ -1216,10 +1186,13 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector
> *q_vector,
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
> @@ -1279,9 +1252,12 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector
> *q_vector,
>  		}
> 
>  		if (staterr & IXGBE_RXD_STAT_EOP) {
> -			if (skb->prev)
> -				skb = ixgbe_transform_rsc_queue(skb,
> -
> 	&(rx_ring->rsc_count));
> +			if (rx_ring->rsc_skb) {
> +				skb = rx_ring->rsc_skb;
> +				rx_ring->rsc_skb = NULL;
> +
> +				skb->prev = NULL;
> +			}
>  			if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
>  				if (IXGBE_RSC_CB(skb)->delay_unmap) {
>  					dma_unmap_single(&pdev->dev,
> @@ -1307,8 +1283,22 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector
> *q_vector,
>  				next_buffer->skb = skb;
>  				next_buffer->dma = 0;
>  			} else {
> -				skb->next = next_buffer->skb;
> -				skb->next->prev = skb;
> +				struct sk_buff *head = rx_ring->rsc_skb;
> +				struct sk_buff *next = next_buffer->skb;
> +
> +				if (!skb_shinfo(head)->frag_list) {
> +					skb_shinfo(head)->frag_list =
> next;
> +				} else {
> +					head->prev->next = next;
> +				}
> +
> +				/* ->prev tracks the last skb in the
> frag_list */
> +				head->prev = next;
> +				rx_ring->rsc_count++;
> +
> +				head->len += next->len;
> +				head->data_len += next->len;
> +				head->truesize += next->len;
>  			}
>  			rx_ring->non_eop_descs++;
>  			goto next_desc;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
