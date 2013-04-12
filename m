From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 01/11] ixgbe: Support using build_skb in the case
 that jumbo frames are disabled
Date: Fri, 12 Apr 2013 06:10:04 -0700
Message-ID: <1365772204.4459.10.camel@edumazet-glaptop>
References: <1365765866-15741-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1365765866-15741-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:52036 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152Ab3DLNKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 09:10:07 -0400
Received: by mail-pd0-f180.google.com with SMTP id q11so1410544pdj.39
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 06:10:06 -0700 (PDT)
In-Reply-To: <1365765866-15741-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-12 at 04:24 -0700, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change makes it so that we can enable the use of build_skb for cases
> where jumbo frames are disabled.  The advantage to this is that we do not have
> to perform a memcpy to populate the header and as a result we see a
> significant performance improvement.
> 

> +	unsigned int size = le16_to_cpu(rx_desc->wb.upper.length);
>  #if (PAGE_SIZE < 8192)
> -	/* if we are only owner of page we can reuse it */
> -	if (unlikely(page_count(page) != 1))
> -		return false;
> +	unsigned int truesize = ixgbe_rx_bufsz(rx_ring);
> +#else
> +	unsigned int truesize = SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) +
> +				SKB_DATA_ALIGN(NET_SKB_PAD +
> +					       NET_IP_ALIGN +
> +					       size);
> +#endif
>  
> -	/* flip page offset to other buffer */
> -	rx_buffer->page_offset ^= truesize;
> +	/* If we spanned a buffer we have a huge mess so test for it */
> +	BUG_ON(unlikely(!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP)));
>  
> -	/*
> -	 * since we are the only owner of the page and we need to
> -	 * increment it, just set the value to 2 in order to avoid
> -	 * an unecessary locked operation
> -	 */
> -	atomic_set(&page->_count, 2);
> -#else
> -	/* move offset up to the next cache line */
> -	rx_buffer->page_offset += truesize;
> +	/* Guarantee this function can be used by verifying buffer sizes */
> +	BUILD_BUG_ON(SKB_WITH_OVERHEAD(IXGBE_RXBUFFER_2K) < (NET_SKB_PAD +
> +							     NET_IP_ALIGN +
> +							     VLAN_HLEN +
> +							     ETH_FRAME_LEN +
> +							     ETH_FCS_LEN));
>  
> -	if (rx_buffer->page_offset > last_offset)
> -		return false;
> +	rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
> +	page = rx_buffer->page;
> +	prefetchw(page);
>  
> -	/* bump ref count on page before it is given to the stack */
> -	get_page(page);
> +	page_addr = page_address(page) + rx_buffer->page_offset;
> +
> +	/* prefetch first cache line of first page */
> +	prefetch(page_addr + NET_SKB_PAD + NET_IP_ALIGN);
> +#if L1_CACHE_BYTES < 128
> +	prefetch(page_addr + L1_CACHE_BYTES + NET_SKB_PAD + NET_IP_ALIGN);
>  #endif
>  
> -	return true;
> +	/* build an skb to go around the page buffer */
> +	skb = build_skb(page_addr, truesize);


Strange. I feel you overestimate the final skb->truesize

The name 'truesize' is a bit misleading here, as its the size of
skb->head. A better name would have been frag_size, and you should not
include in it the struct skb_shared_info overhead because build_skb()
does it :

skb->truesize will be set to SKB_TRUESIZE(frag_size)

#define SKB_TRUESIZE(X) ((X) +                                          \
                         SKB_DATA_ALIGN(sizeof(struct sk_buff)) +       \
                         SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
