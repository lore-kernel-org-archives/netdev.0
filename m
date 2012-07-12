From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 2/2] net: Update alloc frag to reduce get/put page usage
 and recycle pages
Date: Thu, 12 Jul 2012 08:33:49 -0700
Message-ID: <4FFEEE5D.7020305@intel.com>
References: <20120712001804.26542.2889.stgit@gitlad.jf.intel.com>  <20120712001810.26542.61967.stgit@gitlad.jf.intel.com>  <1342052967.3265.8210.camel@edumazet-glaptop>  <4FFE303F.8070902@gmail.com> <1342069601.3265.8218.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43591 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932560Ab2GLPdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 11:33:51 -0400
In-Reply-To: <1342069601.3265.8218.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2012 10:06 PM, Eric Dumazet wrote:
> On Wed, 2012-07-11 at 19:02 -0700, Alexander Duyck wrote:
>
>> The gain will be minimal if any with the 1500 byte allocations, however 
>> there shouldn't be a performance degradation.
>>
>> I was thinking more of the ixgbe case where we are working with only 256 
>> byte allocations and can recycle pages in the case of GRO or TCP.  For 
>> ixgbe the advantages are significant since we drop a number of the 
>> get_page calls and get the advantage of the page recycling.  So for 
>> example with GRO enabled we should only have to allocate 1 page for 
>> headers every 16 buffers, and the 6 slots we use in that page have a 
>> good likelihood of being warm in the cache since we just keep looping on 
>> the same page.
>>
> Its not possible to get 16 buffers per 4096 bytes page.
Actually I was talking about buffers from the device, not buffers from
the page.  However, it is possible to get 16 head_frag buffers from the
same 4K page if we consider recycling.  In the case of GRO we will end
up with the first buffer keeping the head_frag, and all of the remaining
head_frags will be freed before we call netdev_alloc_frag again.  So
what will end up happening is that each GRO assembled frame from ixgbe
would start with a recycled page used for the previously freed
head_frags, the page will be dropped from netdev_alloc_frag after we run
out of space, a new page will be allocated for use as head_frags, and
finally those head_frags will be freed and recycled until we hit the end
of the GRO frame and start over.  So if you count them all then we end
up using the page up to 16 times, maybe even more depending on how the
page offset reset aligns with the start of the GRO frame.

> sizeof(struct skb_shared_info)=0x140 320
>
> Add 192 bytes (NET_SKB_PAD + 128)
>
> Thats a minimum of 512 bytes (but ixgbe uses more) per skb.
>
> In practice for ixgbe, its :
>
> #define IXGBE_RXBUFFER_512   512    /* Used for packet split */
> #define IXGBE_RX_HDR_SIZE IXGBE_RXBUFFER_512 
>
> skb = netdev_alloc_skb_ip_align(rx_ring->netdev, IXGBE_RX_HDR_SIZE)
>
> So 4 buffers per PAGE
>
> Maybe you plan to use IXGBE_RXBUFFER_256 or IXGBE_RXBUFFER_128 ?
I have a patch that is in testing in Jeff Kirsher's tree that uses
IXGBE_RXBUFFER_256.  With your recent changes it didn't make sense to
use 512 when we would only copy 256 bytes into the head.  With the size
set to 256 we will get 6 buffers per page without any recycling.

Thanks,

Alex
