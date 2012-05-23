From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Wed, 23 May 2012 15:03:06 -0700
Message-ID: <4FBD5E9A.80005@intel.com>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>  <1337101280.8512.1108.camel@edumazet-glaptop>  <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>  <1337272654.3403.20.camel@edumazet-glaptop>  <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>  <1337678759.3361.147.camel@edumazet-glaptop>  <1337679045.3361.154.camel@edumazet-glaptop>  <1337699379.1698.30.camel@kjm-desktop.uk.level5networks.com>  <1337703170.3361.217.camel@edumazet-glaptop>  <1337704382.1698.53.camel@kjm-desktop.uk.level5networks.com>  <1337705135.3361.226.camel@edumazet-glaptop>  <1337720076.3361.667.camel@edumazet-glaptop>  <1337766246.3361.2447.camel@edumazet-glaptop>  <1337774978.3361.2744.camel@edumazet-glaptop> <4FBD0A85.4040407@intel.com>  <1337789530.3361.2992.camel@edumaz
 et-glaptop>  <1337791189.3361.3029.camel@edumazet-glaptop> <4FBD1A0C.4070606@intel.com>  <4FBD546A.1030504@intel.com> <1337809034.3361.3487.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Kieran Mansley <kmansley@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:62135 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752044Ab2EWWDY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2012 18:03:24 -0400
In-Reply-To: <1337809034.3361.3487.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2012 02:37 PM, Eric Dumazet wrote:
> On Wed, 2012-05-23 at 14:19 -0700, Alexander Duyck wrote:
>> On 05/23/2012 10:10 AM, Alexander Duyck wrote:
>>> On 05/23/2012 09:39 AM, Eric Dumazet wrote:
>>>> On Wed, 2012-05-23 at 18:12 +0200, Eric Dumazet wrote:
>>>>
>>>>> With current driver, a MTU=1500 frame uses :
>>>>>
>>>>> sk_buff (256 bytes)
>>>>> skb->head : 1024 bytes  (or more exaclty now : 512 + 384)
>>>> By the way, NET_SKB_PAD adds 64 bytes so its 64 + 512 + 384 = 960
>>> Actually pahole seems to be indicating to me the size of skb_shared_info
>>> is 320, unless something has changed in the last few days.
>>>
>>> When I get a chance I will try to remember to reduce the ixgbe header
>>> size to 256 which should also help.  The only reason it is set to 512
>>> was to deal with the fact that the old alloc_skb code wasn't aligning
>>> the shared info with the end of whatever size was allocated and so the
>>> 512 was an approximation to make better use of the 1K slab allocation
>>> back when we still were using hardware packet split.  That should help
>>> to improve the page utilization for the headers since that would
>>> increase the uses of a page from 4 to 6 for the skb head frag, and it
>>> would drop truesize by another 256 bytes.
>>>
>>> Thanks,
>>>
>>> Alex
>> Here is the patch for review.  I have submitted the official patch to Jeff 
>> so that it can go through his tree for testing, validation, and submission 
>> once Dave's tree opens back up.
>>
>> ---
>>
>> The recent changes to netdev_alloc_skb actually make it so that the size of
>> the buffer now actually has a more direct input on the truesize.  So in
>> order to make best use of the piece of a page we are allocated I am
>> reducing the IXGBE_RX_HDR_SIZE to 256 so that our truesize will be reduced
>> by 256 bytes as well.
>>
>> This should result in performance improvements since the number of uses per
>> page should increase from 4 to 6 in the case of a 4K page.  In addition we
>> should see socket performance improvements due to the truesize dropping
>> to less than 1K for buffers less than 256 bytes.
>>
>> Not-Yet-Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>
>>  drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   15 ++++++++-------
>>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 ++--
>>  2 files changed, 10 insertions(+), 9 deletions(-)
>>
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>> index 402dd66..468e4ab 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
>> @@ -77,17 +77,18 @@
>>  #define IXGBE_MAX_FCPAUSE		 0xFFFF
>>  
>>  /* Supported Rx Buffer Sizes */
>> -#define IXGBE_RXBUFFER_512   512    /* Used for packet split */
>> +#define IXGBE_RXBUFFER_256    256  /* Used for skb receive header */
>>  #define IXGBE_MAX_RXBUFFER  16384  /* largest size for a single descriptor */
>>  
>>  /*
>> - * NOTE: netdev_alloc_skb reserves up to 64 bytes, NET_IP_ALIGN mans we
>> - * reserve 2 more, and skb_shared_info adds an additional 384 bytes more,
>> - * this adds up to 512 bytes of extra data meaning the smallest allocation
>> - * we could have is 1K.
>> - * i.e. RXBUFFER_512 --> size-1024 slab
>> + * NOTE: netdev_alloc_skb reserves up to 64 bytes, NET_IP_ALIGN means we
>> + * reserve 64 more, and skb_shared_info adds an additional 320 bytes more,
>> + * this adds up to 448 bytes of extra data.
>> + *
>> + * Since netdev_alloc_skb now allocates a page fragment we can use a value
>> + * of 256 and the resultant skb will have a truesize of 960 or less.
>>   */
>> -#define IXGBE_RX_HDR_SIZE IXGBE_RXBUFFER_512
>> +#define IXGBE_RX_HDR_SIZE IXGBE_RXBUFFER_256
>>  
>>  #define MAXIMUM_ETHERNET_VLAN_SIZE (ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
>>  
>> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> index 7f92e40..f92b31a 100644
>> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
>> @@ -1520,8 +1520,8 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
>>  	 * 60 bytes if the skb->len is less than 60 for skb_pad.
>>  	 */
>>  	pull_len = skb_frag_size(frag);
>> -	if (pull_len > 256)
>> -		pull_len = ixgbe_get_headlen(va, pull_len);
>> +	if (pull_len > IXGBE_RX_HDR_SIZE)
>> +		pull_len = ixgbe_get_headlen(va, IXGBE_RX_HDR_SIZE);
>>  
>>  	/* align pull length to size of long to optimize memcpy performance */
>>  	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
>>
>
> By the way you should reword the comment about NET_IP_ALIGN
>
> On x86 NET_IP_ALIGN is 0, so we dont 'reserve 64 bytes more'
On x86 yes, on other platforms that don't clear the value it will add 2
more bytes, and after cache alignment it will likely add another 64.  I
am really just stating the worst case scenario here.  This is why I end
the comment with "960 or less".

> -> 896 bytes
.. or 832 bytes if you really tweak settings and get the sk_buff down to
192 bytes.  :-)

> Also, are you sure :
>
> srrctl |= (IXGBE_RX_HDR_SIZE << IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT) &  
> 	IXGBE_SRRCTL_BSIZEHDR_MASK; 
>
>
> is still needed in ixgbe_configure_srrctl() , since it uses
> IXGBE_SRRCTL_DESCTYPE_ADV_ONEBUF (non packet split)
That bit is needed for RSC.  Basically we have to specify the maximum
size of a header, even if we are not using packet split.  The value has
to be at least 128 or more.  Since we are using the value of
IXGBE_RX_HDR_SIZE to limit how much header we pull anyway I figure it is
probably a good idea just to leave this here.

Thanks,

Alex
