From: "Franklin S Cooper Jr." <fcooper@ti.com>
Subject: Re: Keystone 2 boards boot failure
Date: Wed, 3 Feb 2016 09:37:21 -0600
Message-ID: <56B21EB1.1010207@ti.com>
References: <56B0DE61.2000704@ti.com> <7911064.Pij4S9Q1yj@wuerfel>
 <56B134D6.101@ti.com> <10700980.gTvMTB9pzv@wuerfel> <56B15591.7080409@ti.com>
 <56B20A96.9040507@ti.com> <56B20CD1.5060003@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <m-karicheri2@ti.com>, <netdev@vger.kernel.org>, <w-kwok2@ti.com>,
	<davem@davemloft.net>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:47810 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752634AbcBCPh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 10:37:29 -0500
In-Reply-To: <56B20CD1.5060003@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/03/2016 08:21 AM, Grygorii Strashko wrote:
> Hi Arnd,
>
> On 02/03/2016 04:11 PM, Franklin S Cooper Jr. wrote:
>> On 02/02/2016 07:19 PM, Franklin S Cooper Jr. wrote:
>>> On 02/02/2016 05:26 PM, Arnd Bergmann wrote:
>>>> On Tuesday 02 February 2016 16:59:34 Franklin Cooper wrote:
>>>>> On 02/02/2016 03:26 PM, Arnd Bergmann wrote:
>>>>>> On Tuesday 02 February 2016 15:01:33 Franklin S Cooper Jr. wrote:
>>>>>>> Yes. Here is a boot log on the latest master with the below
>>>>>>> three patches reverted.
>>>>>>> http://pastebin.com/W7RWSHpE (Working)
>>>>>>>
>>>>>>> I reverted these three patches. The two latest patches seem
>>>>>>> to be trying to correct/expand upon the last patch on this list.
>>>>>>>
>>>>>>> commit 958d104e3d40eef5148c402887138f6594ff7e1e
>>>>>>> netcp: fix regression in receive processing
>>>>>>>
>>>>>>> commit 9dd2d6c5c9755b160fe0111bcdad9491676feea8
>>>>>>> netcp: add more __le32 annotations
>>>>>>>
>>>>>>> commit 899077791403ff7a2d8cfaa87bd1a82d729463e2
>>>>>>> netcp: try to reduce type confusion in descriptors
>>>>>>>
>>>>>> The middle patch should have no effect on generated code, so I'm ignoring
>>>>>> that for now.
>>>>>>
>>>>>> The next thing to rule out is an endianess bug. I assume you
>>>>>> are running this on with a little-endian kernel, correct? If
>>>>>> you are running big-endian, the base assumption that the driver needs
>>>>>> to swap the data was flawed and that portion needs to be done.
>>>>>>
>>>>>> If you are running little-endian 32-bit, please try the partial
>>>>>> revert below, which just undoes the attempt to make it work with
>>>>>> 64-bit kernels.
>>>>> Keystone 2 devices are little-endian 32-bit devices.
>>>> I meant the kernel you are running on it, not the hardware.
>>>> You should always be able to run both a big-endian kernel and
>>>> a littl-endian kernel on any ARMv7 machine, and a couple of
>>>> platforms use 64-bit physical addresses even on 32-bit machines
>>>> (with the normal 32-bit instruction set).
>>> I'm not sure if Keystone 2 devices support this or if we
>>> have support for this. I'll have to double check.
>>>> I wasn't completely sure if there are already keystone-derived
>>>> products with 64-bit CPU cores, but I guess the driver would
>>>> fail really badly on those (with or without the patch).
>>>>
>>>>> This partial revert fixes the boot problem for me.
>>>> Ok.
>>>>
>>>>
>>>> I tried to create a smaller version and stumbled over
>>>> a typo, maybe that's the whole problem. Can you try this one:
>>>>
>>>> diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
>>>> index c61d66d38634..8490804416dd 100644
>>>> --- a/drivers/net/ethernet/ti/netcp_core.c
>>>> +++ b/drivers/net/ethernet/ti/netcp_core.c
>>>> @@ -167,7 +167,7 @@ static void set_pad_info(u32 pad0, u32 pad1, u32 pad2, struct knav_dma_desc *des
>>>>   {
>>>>   	desc->pad[0] = cpu_to_le32(pad0);
>>>>   	desc->pad[1] = cpu_to_le32(pad1);
>>>> -	desc->pad[2] = cpu_to_le32(pad1);
>>>> +	desc->pad[2] = cpu_to_le32(pad2);
>>>>   }
>>>>   
>>>>   static void set_org_pkt_info(dma_addr_t buff, u32 buff_len,
>>>>
>>>>
>>> So only making this change on the latest master with no
>>> other changes I see the boot problem again.
> yep. I can confirm that.
>
> Also, I'm today came up with the similar fix that you've proposed before in this thread.
> So, Could we move forward this way?
>
>
> From 8280895f01b33edba303e7374431bef47630f26c Mon Sep 17 00:00:00 2001
> From: Grygorii Strashko <grygorii.strashko@ti.com>
> Date: Wed, 3 Feb 2016 15:11:40 +0200
> Subject: [PATCH] net: ti: netcp: restore get/set_pad_info() functionality
>
> The commit 899077791403 ("netcp: try to reduce type confusion in descriptors")
> introduces a regression in Kernel 4.5-rc1 as it breaks
> get/set_pad_info() functionality.
>
> The TI NETCP driver uses pad0 and pad1 fields of knav_dma_desc to
> store DMA/MEM buffer pointer and buffer size respectively. And in both
> cases the pointer type size is 32 bit regardless of LAPE enabled or
> not.
> 			!LAPE	LPAE
> sizeof(void*)		32bit	32bit
> sizeof(dma_addr_t) 	32bit	32bit
> sizeof(phys_addr_t) 	32bit	64bit
>
> Unfortunately, above commit changed buffer's pointers save/restore
> code (get/set_pad_info()) and added intermediate conversation to u64
> which causes TI NETCP driver crash in RX/TX path due to "Unable to
> handle kernel NULL pointer" exception.
>
> Hence, fix it by partially reverting above commit and restoring
> get/set_pad_info() functionality as it was before.
>
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
>  drivers/net/ethernet/ti/netcp_core.c | 63 +++++++++++-------------------------
>  1 file changed, 19 insertions(+), 44 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
> index c61d66d..c8eafc6 100644
> --- a/drivers/net/ethernet/ti/netcp_core.c
> +++ b/drivers/net/ethernet/ti/netcp_core.c
> @@ -117,20 +117,10 @@ static void get_pkt_info(dma_addr_t *buff, u32 *buff_len, dma_addr_t *ndesc,
>  	*ndesc = le32_to_cpu(desc->next_desc);
>  }
>  
> -static void get_pad_info(u32 *pad0, u32 *pad1, u32 *pad2, struct knav_dma_desc *desc)
> +static void get_pad_info(u32 *pad0, u32 *pad1, struct knav_dma_desc *desc)
>  {
>  	*pad0 = le32_to_cpu(desc->pad[0]);
>  	*pad1 = le32_to_cpu(desc->pad[1]);
> -	*pad2 = le32_to_cpu(desc->pad[2]);
> -}
> -
> -static void get_pad_ptr(void **padptr, struct knav_dma_desc *desc)
> -{
> -	u64 pad64;
> -
> -	pad64 = le32_to_cpu(desc->pad[0]) +
> -		((u64)le32_to_cpu(desc->pad[1]) << 32);
> -	*padptr = (void *)(uintptr_t)pad64;
>  }
>  
>  static void get_org_pkt_info(dma_addr_t *buff, u32 *buff_len,
> @@ -163,11 +153,10 @@ static void set_desc_info(u32 desc_info, u32 pkt_info,
>  	desc->packet_info = cpu_to_le32(pkt_info);
>  }
>  
> -static void set_pad_info(u32 pad0, u32 pad1, u32 pad2, struct knav_dma_desc *desc)
> +static void set_pad_info(u32 pad0, u32 pad1, struct knav_dma_desc *desc)
>  {
>  	desc->pad[0] = cpu_to_le32(pad0);
>  	desc->pad[1] = cpu_to_le32(pad1);
> -	desc->pad[2] = cpu_to_le32(pad1);
>  }
>  
>  static void set_org_pkt_info(dma_addr_t buff, u32 buff_len,
> @@ -581,7 +570,6 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
>  	dma_addr_t dma_desc, dma_buf;
>  	unsigned int buf_len, dma_sz = sizeof(*ndesc);
>  	void *buf_ptr;
> -	u32 pad[2];
>  	u32 tmp;
>  
>  	get_words(&dma_desc, 1, &desc->next_desc);
> @@ -593,14 +581,12 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
>  			break;
>  		}
>  		get_pkt_info(&dma_buf, &tmp, &dma_desc, ndesc);
> -		get_pad_ptr(&buf_ptr, ndesc);
> +		get_pad_info((u32 *)&buf_ptr, &buf_len, ndesc);
>  		dma_unmap_page(netcp->dev, dma_buf, PAGE_SIZE, DMA_FROM_DEVICE);
>  		__free_page(buf_ptr);
>  		knav_pool_desc_put(netcp->rx_pool, desc);
>  	}
> -
> -	get_pad_info(&pad[0], &pad[1], &buf_len, desc);
> -	buf_ptr = (void *)(uintptr_t)(pad[0] + ((u64)pad[1] << 32));
> +	get_pad_info((u32 *)&buf_ptr, &buf_len, desc);
>  
>  	if (buf_ptr)
>  		netcp_frag_free(buf_len <= PAGE_SIZE, buf_ptr);
> @@ -639,8 +625,8 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
>  	dma_addr_t dma_desc, dma_buff;
>  	struct netcp_packet p_info;
>  	struct sk_buff *skb;
> -	u32 pad[2];
>  	void *org_buf_ptr;
> +	u32 tmp;
>  
>  	dma_desc = knav_queue_pop(netcp->rx_queue, &dma_sz);
>  	if (!dma_desc)
> @@ -653,8 +639,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
>  	}
>  
>  	get_pkt_info(&dma_buff, &buf_len, &dma_desc, desc);
> -	get_pad_info(&pad[0], &pad[1], &org_buf_len, desc);
> -	org_buf_ptr = (void *)(uintptr_t)(pad[0] + ((u64)pad[1] << 32));
> +	get_pad_info((u32 *)&org_buf_ptr, &org_buf_len, desc);
>  
>  	if (unlikely(!org_buf_ptr)) {
>  		dev_err(netcp->ndev_dev, "NULL bufptr in desc\n");
> @@ -679,7 +664,6 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
>  	/* Fill in the page fragment list */
>  	while (dma_desc) {
>  		struct page *page;
> -		void *ptr;
>  
>  		ndesc = knav_pool_desc_unmap(netcp->rx_pool, dma_desc, dma_sz);
>  		if (unlikely(!ndesc)) {
> @@ -688,8 +672,7 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
>  		}
>  
>  		get_pkt_info(&dma_buff, &buf_len, &dma_desc, ndesc);
> -		get_pad_ptr(&ptr, ndesc);
> -		page = ptr;
> +		get_pad_info((u32 *)&page, &tmp, ndesc);
>  
>  		if (likely(dma_buff && buf_len && page)) {
>  			dma_unmap_page(netcp->dev, dma_buff, PAGE_SIZE,
> @@ -767,6 +750,7 @@ static void netcp_free_rx_buf(struct netcp_intf *netcp, int fdq)
>  	unsigned int buf_len, dma_sz;
>  	dma_addr_t dma;
>  	void *buf_ptr;
> +	u32 tmp;
>  
>  	/* Allocate descriptor */
>  	while ((dma = knav_queue_pop(netcp->rx_fdq[fdq], &dma_sz))) {
> @@ -777,7 +761,7 @@ static void netcp_free_rx_buf(struct netcp_intf *netcp, int fdq)
>  		}
>  
>  		get_org_pkt_info(&dma, &buf_len, desc);
> -		get_pad_ptr(&buf_ptr, desc);
> +		get_pad_info((u32 *)&buf_ptr, &tmp, desc);
>  
>  		if (unlikely(!dma)) {
>  			dev_err(netcp->ndev_dev, "NULL orig_buff in desc\n");
> @@ -829,7 +813,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
>  	struct page *page;
>  	dma_addr_t dma;
>  	void *bufptr;
> -	u32 pad[3];
> +	u32 pad[2];
>  
>  	/* Allocate descriptor */
>  	hwdesc = knav_pool_desc_get(netcp->rx_pool);
> @@ -846,7 +830,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
>  				SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
>  
>  		bufptr = netdev_alloc_frag(primary_buf_len);
> -		pad[2] = primary_buf_len;
> +		pad[1] = primary_buf_len;
>  
>  		if (unlikely(!bufptr)) {
>  			dev_warn_ratelimited(netcp->ndev_dev,
> @@ -858,9 +842,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
>  		if (unlikely(dma_mapping_error(netcp->dev, dma)))
>  			goto fail;
>  
> -		pad[0] = lower_32_bits((uintptr_t)bufptr);
> -		pad[1] = upper_32_bits((uintptr_t)bufptr);
> -
> +		pad[0] = (u32)bufptr;
>  	} else {
>  		/* Allocate a secondary receive queue entry */
>  		page = alloc_page(GFP_ATOMIC | GFP_DMA | __GFP_COLD);
> @@ -870,9 +852,8 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
>  		}
>  		buf_len = PAGE_SIZE;
>  		dma = dma_map_page(netcp->dev, page, 0, buf_len, DMA_TO_DEVICE);
> -		pad[0] = lower_32_bits(dma);
> -		pad[1] = upper_32_bits(dma);
> -		pad[2] = 0;
> +		pad[0] = (u32)page;
> +		pad[1] = 0;
>  	}
>  
>  	desc_info =  KNAV_DMA_DESC_PS_INFO_IN_DESC;
> @@ -882,7 +863,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
>  	pkt_info |= (netcp->rx_queue_id & KNAV_DMA_DESC_RETQ_MASK) <<
>  		    KNAV_DMA_DESC_RETQ_SHIFT;
>  	set_org_pkt_info(dma, buf_len, hwdesc);
> -	set_pad_info(pad[0], pad[1], pad[2], hwdesc);
> +	set_pad_info(pad[0], pad[1], hwdesc);
>  	set_desc_info(desc_info, pkt_info, hwdesc);
>  
>  	/* Push to FDQs */
> @@ -971,11 +952,11 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
>  					  unsigned int budget)
>  {
>  	struct knav_dma_desc *desc;
> -	void *ptr;
>  	struct sk_buff *skb;
>  	unsigned int dma_sz;
>  	dma_addr_t dma;
>  	int pkts = 0;
> +	u32 tmp;
>  
>  	while (budget--) {
>  		dma = knav_queue_pop(netcp->tx_compl_q, &dma_sz);
> @@ -988,8 +969,7 @@ static int netcp_process_tx_compl_packets(struct netcp_intf *netcp,
>  			continue;
>  		}
>  
> -		get_pad_ptr(&ptr, desc);
> -		skb = ptr;
> +		get_pad_info((u32 *)&skb, &tmp, desc);
>  		netcp_free_tx_desc_chain(netcp, desc, dma_sz);
>  		if (!skb) {
>  			dev_err(netcp->ndev_dev, "No skb in Tx desc\n");
> @@ -1078,7 +1058,6 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
>  		u32 page_offset = frag->page_offset;
>  		u32 buf_len = skb_frag_size(frag);
>  		dma_addr_t desc_dma;
> -		u32 desc_dma_32;
>  		u32 pkt_info;
>  
>  		dma_addr = dma_map_page(dev, page, page_offset, buf_len,
> @@ -1100,8 +1079,7 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
>  			(netcp->tx_compl_qid & KNAV_DMA_DESC_RETQ_MASK) <<
>  				KNAV_DMA_DESC_RETQ_SHIFT;
>  		set_pkt_info(dma_addr, buf_len, 0, ndesc);
> -		desc_dma_32 = (u32)desc_dma;
> -		set_words(&desc_dma_32, 1, &pdesc->next_desc);
> +		set_words(&desc_dma, 1, &pdesc->next_desc);
>  		pkt_len += buf_len;
>  		if (pdesc != desc)
>  			knav_pool_desc_map(netcp->tx_pool, pdesc,
> @@ -1194,10 +1172,7 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
>  	}
>  
>  	set_words(&tmp, 1, &desc->packet_info);
> -	tmp = lower_32_bits((uintptr_t)&skb);
> -	set_words(&tmp, 1, &desc->pad[0]);
> -	tmp = upper_32_bits((uintptr_t)&skb);
> -	set_words(&tmp, 1, &desc->pad[1]);
> +	set_words((u32 *)&skb, 1, &desc->pad[0]);
>  
>  	if (tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO) {
>  		tmp = tx_pipe->switch_to_port;

This worked for me.
