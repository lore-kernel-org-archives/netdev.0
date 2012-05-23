From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Wed, 23 May 2012 09:04:21 -0700
Message-ID: <4FBD0A85.4040407@intel.com>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>  <1337093776.8512.1089.camel@edumazet-glaptop>  <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>  <1337099641.8512.1102.camel@edumazet-glaptop>  <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>  <1337101280.8512.1108.camel@edumazet-glaptop>  <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>  <1337272654.3403.20.camel@edumazet-glaptop>  <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>  <1337678759.3361.147.camel@edumazet-glaptop>  <1337679045.3361.154.camel@edumazet-glaptop>  <1337699379.1698.30.camel@kjm-desktop.uk.level5networks.com>  <1337703170.3361.217.camel@edumazet-glaptop>  <1337704382.1698.53.camel@kjm-desktop.uk.level5networks.com>  <1337705135.3361.226.camel@eduma
 zet-glaptop>  <1337720076.3361.667.camel@edumazet-glaptop>  <1337766246.3361.2447.camel@edumazet-glaptop> <1337774978.3361.2744.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Kieran Mansley <kmansley@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65039 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965054Ab2EWQEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2012 12:04:22 -0400
In-Reply-To: <1337774978.3361.2744.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2012 05:09 AM, Eric Dumazet wrote:
> On Wed, 2012-05-23 at 11:44 +0200, Eric Dumazet wrote:
>
>> I believe that as soon as ixgbe can use build_skb() and avoid the 1024
>> bytes overhead per skb, it should go away.
>
> Here is the patch for ixgbe, for reference.
I'm confused as to what this is trying to accomplish.

Currently the way the ixgbe driver works is that we allocate the
skb->head using netdev_alloc_skb, which after your recent changes should
be using a head frag.  If the buffer is less than 256 bytes we have
pushed the entire buffer into the head frag, and if it is more we only
pull everything up to the end of the TCP header.  In either case if we
are merging TCP flows we should be able to drop one page or the other
along with the sk_buff giving us a total truesize addition after merge
of ~1K for less than 256 bytes or 2K for a full sized frame.

I'll try to take a look at this today as it is in our interest to have
TCP performing as well as possible on ixgbe.

Thanks,

Alex


 
>
> My machine is now able to receive a netperf TCP_STREAM full speed
> (10Gb), even with GRO/LRO off. (TCPRcvCoalesce counter increasing very
> fast too)
>
> Its not an official patch yet, because :
>
> 1) I need to properly align DMA buffers to reserve NET_SKB_PAD bytes
> (not all workloads are like TCP, and some headroom is needed for
> tunnels)
>
> 2) Must cope with MTU > 1500 cases
>
> 3) Should not be done if NET_IP_ALIGN is not null (I dont know if ixgbe
> hardware can do the DMA to non aligned area on receive)
>
> This patch saves 1024 bytes per incoming skb. (skb->head directly mapped
> to the frag containing the frame, instead of a separate memory area)
>
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   82 ++++++++--------
>  1 file changed, 46 insertions(+), 36 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index bf20457..d05693a 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -1511,39 +1511,41 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
>  		return true;
>  	}
>  
> -	/*
> -	 * it is valid to use page_address instead of kmap since we are
> -	 * working with pages allocated out of the lomem pool per
> -	 * alloc_page(GFP_ATOMIC)
> -	 */
> -	va = skb_frag_address(frag);
> +	if (!skb_headlen(skb)) {
> +		/*
> +		 * it is valid to use page_address instead of kmap since we are
> +		 * working with pages allocated out of the lowmem pool per
> +		 * alloc_page(GFP_ATOMIC)
> +		 */
> +		va = skb_frag_address(frag);
>  
> -	/*
> -	 * we need the header to contain the greater of either ETH_HLEN or
> -	 * 60 bytes if the skb->len is less than 60 for skb_pad.
> -	 */
> -	pull_len = skb_frag_size(frag);
> -	if (pull_len > 256)
> -		pull_len = ixgbe_get_headlen(va, pull_len);
> +		/*
> +		 * we need the header to contain the greater of either ETH_HLEN or
> +		 * 60 bytes if the skb->len is less than 60 for skb_pad.
> +		 */
> +		pull_len = skb_frag_size(frag);
> +		if (pull_len > 256)
> +			pull_len = ixgbe_get_headlen(va, pull_len);
>  
> -	/* align pull length to size of long to optimize memcpy performance */
> -	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
> +		/* align pull length to size of long to optimize memcpy performance */
> +		skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
>  
> -	/* update all of the pointers */
> -	skb_frag_size_sub(frag, pull_len);
> -	frag->page_offset += pull_len;
> -	skb->data_len -= pull_len;
> -	skb->tail += pull_len;
> +		/* update all of the pointers */
> +		skb_frag_size_sub(frag, pull_len);
> +		frag->page_offset += pull_len;
> +		skb->data_len -= pull_len;
> +		skb->tail += pull_len;
>  
> -	/*
> -	 * if we sucked the frag empty then we should free it,
> -	 * if there are other frags here something is screwed up in hardware
> -	 */
> -	if (skb_frag_size(frag) == 0) {
> -		BUG_ON(skb_shinfo(skb)->nr_frags != 1);
> -		skb_shinfo(skb)->nr_frags = 0;
> -		__skb_frag_unref(frag);
> -		skb->truesize -= ixgbe_rx_bufsz(rx_ring);
> +		/*
> +		 * if we sucked the frag empty then we should free it,
> +		 * if there are other frags here something is screwed up in hardware
> +		 */
> +		if (skb_frag_size(frag) == 0) {
> +			BUG_ON(skb_shinfo(skb)->nr_frags != 1);
> +			skb_shinfo(skb)->nr_frags = 0;
> +			__skb_frag_unref(frag);
> +			skb->truesize -= ixgbe_rx_bufsz(rx_ring);
> +		}
>  	}
>  
>  	/* if skb_pad returns an error the skb was freed */
> @@ -1662,6 +1664,8 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>  		struct sk_buff *skb;
>  		struct page *page;
>  		u16 ntc;
> +		unsigned int len;
> +		bool addfrag = true;
>  
>  		/* return some buffers to hardware, one at a time is too slow */
>  		if (cleaned_count >= IXGBE_RX_BUFFER_WRITE) {
> @@ -1687,7 +1691,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>  		prefetchw(page);
>  
>  		skb = rx_buffer->skb;
> -
> +		len = le16_to_cpu(rx_desc->wb.upper.length);
>  		if (likely(!skb)) {
>  			void *page_addr = page_address(page) +
>  					  rx_buffer->page_offset;
> @@ -1698,9 +1702,14 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>  			prefetch(page_addr + L1_CACHE_BYTES);
>  #endif
>  
> -			/* allocate a skb to store the frags */
> -			skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
> -							IXGBE_RX_HDR_SIZE);
> +			/* allocate a skb to store the frag */
> +			if (len <= 256) {
> +				skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
> +								256);
> +			} else {
> +				skb = build_skb(page_addr, ixgbe_rx_bufsz(rx_ring));
> +				addfrag = false;
> +			}
>  			if (unlikely(!skb)) {
>  				rx_ring->rx_stats.alloc_rx_buff_failed++;
>  				break;
> @@ -1729,9 +1738,10 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
>  						      DMA_FROM_DEVICE);
>  		}
>  
> -		/* pull page into skb */
> -		ixgbe_add_rx_frag(rx_ring, rx_buffer, skb,
> -				  le16_to_cpu(rx_desc->wb.upper.length));
> +		if (addfrag)
> +			ixgbe_add_rx_frag(rx_ring, rx_buffer, skb, len);
> +		else
> +			__skb_put(skb, len);
>  
>  		if (ixgbe_can_reuse_page(rx_buffer)) {
>  			/* hand second half of page back to the ring */
>
>
