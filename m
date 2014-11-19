From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [net-next 07/15] ixgbevf: Change receive model to use double
 buffered page based receives
Date: Wed, 19 Nov 2014 23:06:53 +0000
Message-ID: <87618083B2453E4A8714035B62D67992501A10B7@FMSMSX105.amr.corp.intel.com>
References: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1416370256-16834-8-git-send-email-jeffrey.t.kirsher@intel.com>
 <546CE067.9010903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: Alexander Duyck <alexander.h.duyck@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:19724 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754658AbaKSXGz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 18:06:55 -0500
In-Reply-To: <546CE067.9010903@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Alexander Duyck [mailto:alexander.h.duyck@redhat.com]
>Sent: Wednesday, November 19, 2014 10:25 AM
>To: Kirsher, Jeffrey T; davem@davemloft.net
>Cc: Tantilov, Emil S; netdev@vger.kernel.org;
>nhorman@redhat.com; sassmann@redhat.com; jogreene@redhat.com
>Subject: Re: [net-next 07/15] ixgbevf: Change receive model to use double buffered page based receives
>
>There were a few things in this patch that should be addressed.
>
>Comments inline below.
>
>- Alex
>
>On 11/18/2014 08:10 PM, Jeff Kirsher wrote:
>> From: Emil Tantilov <emil.s.tantilov@intel.com>
>>
>> This patch changes the basic receive path for ixgbevf so that instead of
>> receiving the data into an skb it is received into a double buffered page.
>> The main change is that the receives will be done in pages only and then
>> pull the header out of the page and copy it into the sk_buff data.
>>
>> This has the advantages of reduced cache misses and improved performance on
>> IOMMU enabled systems.
>>
>> CC: Alexander Duyck <alexander.h.duyck@redhat.com>
>> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
>> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>   drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  24 +-
>>   drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 452 +++++++++++++++-------
>>   2 files changed, 331 insertions(+), 145 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>> index 72a354b..2362001 100644
>> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
>> @@ -58,8 +58,9 @@ struct ixgbevf_tx_buffer {
>>   };
>>
>>   struct ixgbevf_rx_buffer {
>> -	struct sk_buff *skb;
>>   	dma_addr_t dma;
>> +	struct page *page;
>> +	unsigned int page_offset;
>>   };
>>
>>   struct ixgbevf_stats {
>> @@ -91,9 +92,10 @@ struct ixgbevf_ring {
>>   	void *desc;			/* descriptor ring memory */
>>   	dma_addr_t dma;			/* phys. address of
>descriptor ring */
>>   	unsigned int size;		/* length in bytes */
>> -	unsigned int count;		/* amount of descriptors */
>> -	unsigned int next_to_use;
>> -	unsigned int next_to_clean;
>> +	u16 count;			/* amount of descriptors */
>> +	u16 next_to_use;
>> +	u16 next_to_clean;
>> +	u16 next_to_alloc;
>>
>>   	union {
>>   		struct ixgbevf_tx_buffer *tx_buffer_info;
>> @@ -109,12 +111,11 @@ struct ixgbevf_ring {
>>
>>   	u64 hw_csum_rx_error;
>>   	u8 __iomem *tail;
>> +	struct sk_buff *skb;
>>
>>   	u16 reg_idx; /* holds the special value that gets the hardware register
>>   		      * offset associated with this ring, which is different
>>   		      * for DCB and RSS modes */
>> -
>> -	u16 rx_buf_len;
>>   	int queue_index; /* needed for multiqueue queue management */
>>   };
>>
>> @@ -133,12 +134,10 @@ struct ixgbevf_ring {
>>
>>   /* Supported Rx Buffer Sizes */
>>   #define IXGBEVF_RXBUFFER_256   256    /* Used for packet split */
>> -#define IXGBEVF_RXBUFFER_2K    2048
>> -#define IXGBEVF_RXBUFFER_4K    4096
>> -#define IXGBEVF_RXBUFFER_8K    8192
>> -#define IXGBEVF_RXBUFFER_10K   10240
>> +#define IXGBEVF_RXBUFFER_2048	2048
>>
>>   #define IXGBEVF_RX_HDR_SIZE IXGBEVF_RXBUFFER_256
>> +#define IXGBEVF_RX_BUFSZ	IXGBEVF_RXBUFFER_2048
>>
>>   #define MAXIMUM_ETHERNET_VLAN_SIZE (VLAN_ETH_FRAME_LEN + ETH_FCS_LEN)
>>
>> @@ -430,11 +429,6 @@ enum ixbgevf_state_t {
>>   	__IXGBEVF_WORK_INIT,
>>   };
>>
>> -struct ixgbevf_cb {
>> -	struct sk_buff *prev;
>> -};
>> -#define IXGBE_CB(skb) ((struct ixgbevf_cb *)(skb)->cb)
>> -
>>   enum ixgbevf_boards {
>>   	board_82599_vf,
>>   	board_X540_vf,
>> diff --git
>a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> index 20bebd2..2ca7c96 100644
>> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>> @@ -422,8 +422,7 @@ static void
>ixgbevf_process_skb_fields(struct ixgbevf_ring *rx_ring,
>>    * that this is in fact a non-EOP buffer.
>>    **/
>>   static bool ixgbevf_is_non_eop(struct ixgbevf_ring *rx_ring,
>> -			       union ixgbe_adv_rx_desc *rx_desc,
>> -			       struct sk_buff *skb)
>> +			       union ixgbe_adv_rx_desc *rx_desc)
>>   {
>>   	u32 ntc = rx_ring->next_to_clean + 1;
>>
>> @@ -439,37 +438,40 @@ static bool
>ixgbevf_is_non_eop(struct ixgbevf_ring *rx_ring,
>>   	return true;
>>   }
>>
>> -static bool ixgbevf_alloc_mapped_skb(struct ixgbevf_ring *rx_ring,
>> -				     struct ixgbevf_rx_buffer *bi)
>> +static bool ixgbevf_alloc_mapped_page(struct ixgbevf_ring *rx_ring,
>> +				      struct ixgbevf_rx_buffer *bi)
>>   {
>> -	struct sk_buff *skb = bi->skb;
>> +	struct page *page = bi->page;
>>   	dma_addr_t dma = bi->dma;
>>
>> -	if (unlikely(skb))
>> +	/* since we are recycling buffers we should seldom need to alloc */
>> +	if (likely(page))
>>   		return true;
>>
>> -	skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
>> -					rx_ring->rx_buf_len);
>> -	if (unlikely(!skb)) {
>> -		rx_ring->rx_stats.alloc_rx_buff_failed++;
>> +	/* alloc new page for storage */
>> +	page = dev_alloc_page();
>> +	if (unlikely(!page)) {
>> +		rx_ring->rx_stats.alloc_rx_page_failed++;
>>   		return false;
>>   	}
>>
>> -	dma = dma_map_single(rx_ring->dev, skb->data,
>> -			     rx_ring->rx_buf_len, DMA_FROM_DEVICE);
>> +	/* map page for use */
>> +	dma = dma_map_page(rx_ring->dev, page, 0,
>> +			   PAGE_SIZE, DMA_FROM_DEVICE);
>>
>>   	/* if mapping failed free memory back to system since
>>   	 * there isn't much point in holding memory we can't use
>>   	 */
>>   	if (dma_mapping_error(rx_ring->dev, dma)) {
>> -		dev_kfree_skb_any(skb);
>> +		__free_page(page);
>>
>>   		rx_ring->rx_stats.alloc_rx_buff_failed++;
>>   		return false;
>>   	}
>>
>> -	bi->skb = skb;
>>   	bi->dma = dma;
>> +	bi->page = page;
>> +	bi->page_offset = 0;
>>
>>   	return true;
>>   }
>> @@ -495,13 +497,13 @@ static void
>ixgbevf_alloc_rx_buffers(struct ixgbevf_ring *rx_ring,
>>   	i -= rx_ring->count;
>>
>>   	do {
>> -		if (!ixgbevf_alloc_mapped_skb(rx_ring, bi))
>> +		if (!ixgbevf_alloc_mapped_page(rx_ring, bi))
>>   			break;
>>
>>   		/* Refresh the desc even if pkt_addr didn't change
>>   		 * because each write-back erases this info.
>>   		 */
>> -		rx_desc->read.pkt_addr = cpu_to_le64(bi->dma);
>> +		rx_desc->read.pkt_addr = cpu_to_le64(bi->dma + bi->page_offset);
>>
>>   		rx_desc++;
>>   		bi++;
>> @@ -524,6 +526,9 @@ static void
>ixgbevf_alloc_rx_buffers(struct ixgbevf_ring *rx_ring,
>>   		/* record the next descriptor to use */
>>   		rx_ring->next_to_use = i;
>>
>> +		/* update next to alloc since we have filled the ring */
>> +		rx_ring->next_to_alloc = i;
>> +
>>   		/* Force memory writes to complete before letting h/w
>>   		 * know there are new descriptors to fetch.  (Only
>>   		 * applicable for weak-ordered memory model archs,
>> @@ -534,6 +539,257 @@ static void
>ixgbevf_alloc_rx_buffers(struct ixgbevf_ring *rx_ring,
>>   	}
>>   }
>>
>> +/* ixgbevf_pull_tail - ixgbevf specific version of skb_pull_tail
>> + * @rx_ring: Rx descriptor ring packet is being transacted on
>> + * @skb: pointer to current skb being adjusted 
>> + *
>> + * This function is an ixgbevf specific version of __pskb_pull_tail.  The
>> + * main difference between this version and the original function is that
>> + * this function can make several assumptions about the state of things
>> + * that allow for significant optimizations versus the standard function.
>> + * As a result we can do things like drop a frag and maintain an accurate
>> + * truesize for the skb.
>> + */
>> +static void ixgbevf_pull_tail(struct ixgbevf_ring *rx_ring,
>> +			      struct sk_buff *skb)
>> +{
>> +	struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
>> +	unsigned char *va;
>> +	unsigned int pull_len;
>> +
>> +	/* it is valid to use page_address instead of kmap since we are
>> +	 * working with pages allocated out of the lomem pool per
>> +	 * alloc_page(GFP_ATOMIC)
>> +	 */
>> +	va = skb_frag_address(frag);
>> +
>> +	/* we need the header to contain the greater of either ETH_HLEN or
>> +	 * 60 bytes if the skb->len is less than 60 for skb_pad.
>> +	 */
>> +	pull_len = eth_get_headlen(va, IXGBEVF_RX_HDR_SIZE);
>> +
>> +	/* align pull length to size of long to optimize memcpy performance */
>> +	skb_copy_to_linear_data(skb, va, ALIGN(pull_len, sizeof(long)));
>> +
>> +	/* update all of the pointers */
>> +	skb_frag_size_sub(frag, pull_len);
>> +	frag->page_offset += pull_len;
>> +	skb->data_len -= pull_len;
>> +	skb->tail += pull_len;
>> +}
>
>I really think we should look at making this into a generic function.
>Maybe I will submit something later today to get a common function
>placed in the code.  Maybe something like eth_pull_tail.

Sounds good.

>
>> +/* ixgbevf_cleanup_headers - Correct corrupted or empty headers
>> + * @rx_ring: Rx descriptor ring packet is being transacted on
>> + * @rx_desc: pointer to the EOP Rx descriptor
>> + * @skb: pointer to current skb being fixed
>> + *
>> + * Check for corrupted packet headers caused by senders on the local L2
>> + * embedded NIC switch not setting up their Tx Descriptors right.  These
>> + * should be very rare.
>> + *
>> + * Also address the case where we are pulling data in on pages only
>> + * and as such no data is present in the skb header.
>> + *
>> + * In addition if skb is not at least 60 bytes we need to pad it so that
>> + * it is large enough to qualify as a valid Ethernet frame.
>> + *
>> + * Returns true if an error was encountered and skb was freed.
>> + */
>> +static bool ixgbevf_cleanup_headers(struct ixgbevf_ring *rx_ring,
>> +				    union ixgbe_adv_rx_desc *rx_desc,
>> +				    struct sk_buff *skb)
>> +{
>> +	/* verify that the packet does not have any known errors */
>> +	if (unlikely(ixgbevf_test_staterr(rx_desc,
>> +
>IXGBE_RXDADV_ERR_FRAME_ERR_MASK))) {
>> +		struct net_device *netdev = rx_ring->netdev;
>> +
>> +		if (!(netdev->features & NETIF_F_RXALL)) {
>> +			dev_kfree_skb_any(skb);
>> +			return true;
>> +		}
>> +	}
>> +
>> +	/* place header in linear portion of buffer */
>> +	if (skb_is_nonlinear(skb))
>> +		ixgbevf_pull_tail(rx_ring, skb);
>> +
>> +	/* if skb_pad returns an error the skb was freed */
>> +	if (unlikely(skb->len < 60)) {
>> +		int pad_len = 60 - skb->len;
>> +
>> +		if (skb_pad(skb, pad_len))
>> +			return true;
>> +		__skb_put(skb, pad_len);
>> +	}
>> +
>> +	return false;
>> +}
>
>The same goes for the padding bit here.  Maybe something like eth_skb_pad.

OK

>> +/* ixgbevf_reuse_rx_page - page flip buffer and store it back on the ring
>> + * @rx_ring: Rx descriptor ring to store buffers on
>> + * @old_buff: donor buffer to have page reused
>> + *
>> + * Synchronizes page for reuse by the adapter
>> + */
>> +static void ixgbevf_reuse_rx_page(struct ixgbevf_ring *rx_ring,
>> +				  struct ixgbevf_rx_buffer *old_buff)
>> +{
>> +	struct ixgbevf_rx_buffer *new_buff;
>> +	u16 nta = rx_ring->next_to_alloc;
>> +
>> +	new_buff = &rx_ring->rx_buffer_info[nta];
>> +
>> +	/* update, and store next to alloc */
>> +	nta++;
>> +	rx_ring->next_to_alloc = (nta < rx_ring->count) ? nta : 0;
>> +
>> +	/* transfer page from old buffer to new buffer */
>> +	new_buff->page = old_buff->page;
>> +	new_buff->dma = old_buff->dma;
>> +	new_buff->page_offset = old_buff->page_offset;
>> +
>> +	/* sync the buffer for use by the device */
>> +	dma_sync_single_range_for_device(rx_ring->dev, new_buff->dma,
>> +					 new_buff->page_offset,
>> +					 IXGBEVF_RX_BUFSZ,
>> +					 DMA_FROM_DEVICE);
>> +}
>> +
>> +/* ixgbevf_add_rx_frag - Add contents of Rx buffer to sk_buff
>> + * @rx_ring: Rx descriptor ring to transact packets on
>> + * @rx_buffer: buffer containing page to add
>> + * @rx_desc: descriptor containing length of buffer written by hardware
>> + * @skb: sk_buff to place the data into
>> + *
>> + * This function will add the data contained in rx_buffer->page to the skb.
>> + * This is done either through a direct copy if the data in the buffer is
>> + * less than the skb header size, otherwise it will just attach the page as
>> + * a frag to the skb.
>> + *
>> + * The function will then update the page offset if necessary and return
>> + * true if the buffer can be reused by the adapter.
>> + */
>> +static bool ixgbevf_add_rx_frag(struct ixgbevf_ring *rx_ring,
>> +				struct ixgbevf_rx_buffer *rx_buffer,
>> +				union ixgbe_adv_rx_desc *rx_desc,
>> +				struct sk_buff *skb)
>> +{
>> +	struct page *page = rx_buffer->page;
>> +	unsigned int size = le16_to_cpu(rx_desc-
>>wb.upper.length);
>> +#if (PAGE_SIZE < 8192)
>> +	unsigned int truesize = IXGBEVF_RX_BUFSZ;
>> +#else
>> +	unsigned int truesize = ALIGN(size, L1_CACHE_BYTES);
>> +#endif
>> +
>> +	if ((size <= IXGBEVF_RX_HDR_SIZE) && !skb_is_nonlinear(skb)) {
>> +		unsigned char *va = page_address(page) + rx_buffer->page_offset;
>> +
>> +		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
>> +
>> +		/* we can reuse buffer as-is, just make sure it is local */
>> +		if (likely(page_to_nid(page) == numa_node_id()))
>> +			return true;
>> +
>> +		/* this page cannot be reused so discard it */
>> +		put_page(page);
>> +		return false;
>> +	}
>> +
>> +	skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
>> +			rx_buffer->page_offset, size, truesize);
>> +
>> +	/* avoid re-using remote pages */
>> +	if (unlikely(page_to_nid(page) != numa_node_id()))
>> +		return false;
>> +
>
>This is missing the pfmemalloc fix that is already in igb,
>and that I submitted for ixgbe and fm10k.

Just because of timing. I can redo the patch with the pfmemalloc check added.

>
>> +#if (PAGE_SIZE < 8192)
>> +	/* if we are only owner of page we can reuse it */
>> +	if (unlikely(page_count(page) != 1))
>> +		return false;
>> +
>> +	/* flip page offset to other buffer */
>> +	rx_buffer->page_offset ^= IXGBEVF_RX_BUFSZ;
>> +
>> +	/* since we are the only owner of the page and we need to
>> +	 * increment it.
>> +	 */
>> +	atomic_inc(&page->_count);
>> +#else
>> +	/* move offset up to the next cache line */
>> +	rx_buffer->page_offset += truesize;
>> +
>> +	if (rx_buffer->page_offset > (PAGE_SIZE - IXGBEVF_RX_BUFSZ))
>> +		return false;
>> +
>> +	/* bump ref count on page before it is given to the stack */
>> +	get_page(page);
>> +#endif
>> +
>> +	return true;
>> +}
>
>The get_page and atomic_inc calls can be pulled out and
>placed after if #if/else logic.  The preference is to use atomic_inc since
>you are using an order 0 page and don't need to check for PageTail().

I can do that,

>> +static struct sk_buff *ixgbevf_fetch_rx_buffer(struct ixgbevf_ring *rx_ring,
>> +					       union ixgbe_adv_rx_desc *rx_desc,
>> +					       struct sk_buff *skb)
>> +{
>> +	struct ixgbevf_rx_buffer *rx_buffer;
>> +	struct page *page;
>> +
>> +	rx_buffer = &rx_ring->rx_buffer_info[rx_ring->next_to_clean];
>> +	page = rx_buffer->page;
>> +	prefetchw(page);
>> +
>> +	if (likely(!skb)) {
>> +		void *page_addr = page_address(page) +
>> +				  rx_buffer->page_offset;
>> +
>> +		/* prefetch first cache line of first page */
>> +		prefetch(page_addr);
>> +#if L1_CACHE_BYTES < 128
>> +		prefetch(page_addr + L1_CACHE_BYTES);
>> +#endif
>> +
>> +		/* allocate a skb to store the frags */
>> +		skb = netdev_alloc_skb_ip_align(rx_ring->netdev,
>> +						IXGBEVF_RX_HDR_SIZE);
>> +		if (unlikely(!skb)) {
>> +			rx_ring->rx_stats.alloc_rx_buff_failed++;
>> +			return NULL;
>> +		}
>> +
>> +		/* we will be copying header into skb->data in
>> +		 * pskb_may_pull so it is in our interest to prefetch
>> +		 * it now to avoid a possible cache miss
>> +		 */
>> +		prefetchw(skb->data);
>> +	}
>> +
>> +	/* we are reusing so sync this buffer for CPU use */
>> +	dma_sync_single_range_for_cpu(rx_ring->dev,
>> +				      rx_buffer->dma,
>> +				      rx_buffer->page_offset,
>> +				      IXGBEVF_RX_BUFSZ,
>> +				      DMA_FROM_DEVICE);
>> +
>> +	/* pull page into skb */
>> +	if (ixgbevf_add_rx_frag(rx_ring, rx_buffer, rx_desc, skb)) {
>> +		/* hand second half of page back to the ring */
>> +		ixgbevf_reuse_rx_page(rx_ring, rx_buffer);
>> +	} else {
>> +		/* we are not reusing the buffer so unmap it */
>> +		dma_unmap_page(rx_ring->dev, rx_buffer->dma,
>> +			       PAGE_SIZE, DMA_FROM_DEVICE);
>> +	}
>> +
>> +	/* clear contents of buffer_info */
>> +	rx_buffer->dma = 0;
>> +	rx_buffer->page = NULL;
>> +
>> +	return skb;
>> +}
>> +
>>   static inline void ixgbevf_irq_enable_queues(struct ixgbevf_adapter *adapter,
>>   					     u32 qmask)
>>   {
>
><snip>
>
>> @@ -3320,21 +3522,11 @@ static int ixgbevf_set_mac(struct net_device *netdev, void *p)
>>   static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
>>   {
>>   	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
>> +	struct ixgbe_hw *hw = &adapter->hw;
>>   	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
>> -	int max_possible_frame = MAXIMUM_ETHERNET_VLAN_SIZE;
>> -
>> -	switch (adapter->hw.api_version) {
>> -	case ixgbe_mbox_api_11:
>> -		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
>> -		break;
>> -	default:
>> -		if (adapter->hw.mac.type == ixgbe_mac_X540_vf)
>> -			max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
>> -		break;
>> -	}
>>
>>   	/* MTU < 68 is an error and causes problems on some kernels */
>> -	if ((new_mtu < 68) || (max_frame > max_possible_frame))
>> +	if ((new_mtu < 68) || (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
>>   		return -EINVAL;
>>
>>   	hw_dbg(&adapter->hw, "changing MTU from %d to %d\n",
>
>This is wrong. You are still limited by the PF so if it is a version
>1.0 mailbox on an 82599 you cannot enable jumbo frames.  Yes you can
>support it but the PF won't let you do it.
>
>> @@ -3342,8 +3534,8 @@ static int ixgbevf_change_mtu(struct
>net_device *netdev, int new_mtu)
>>   	/* must set new MTU before calling down or up */
>>   	netdev->mtu = new_mtu;
>>
>> -	if (netif_running(netdev))
>> -		ixgbevf_reinit_locked(adapter);
>> +	/* notify the PF of our intent to use this size of frame */
>> +	ixgbevf_rlpml_set_vf(hw, max_frame);
>>
>>   	return 0;
>>   }
>>
>
>This is the reason why the change is wrong.  If the mailbox api is
>version 1.0 you cannot support jumbo frames so ixgbevf_rlmpl_set_vf will
>return an error via the mailbox indicating that the message >is not
>supported.

I'll have to see how this change was introduced, but I can drop it for now since it's not directly related to this change anyway.

Thanks,
Emil
