From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: Keystone 2 boards boot failure
Date: Wed, 3 Feb 2016 18:31:00 +0200
Message-ID: <56B22B44.9050802@ti.com>
References: <56B0DE61.2000704@ti.com> <56B20A96.9040507@ti.com>
 <56B20CD1.5060003@ti.com> <1888105.8DsfvU3cAo@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Franklin S Cooper Jr." <fcooper@ti.com>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <w-kwok2@ti.com>, <davem@davemloft.net>,
	Santosh Shilimkar <ssantosh@kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:52375 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755592AbcBCQbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 11:31:13 -0500
In-Reply-To: <1888105.8DsfvU3cAo@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2016 06:20 PM, Arnd Bergmann wrote:
> On Wednesday 03 February 2016 16:21:05 Grygorii Strashko wrote:
>> On 02/03/2016 04:11 PM, Franklin S Cooper Jr. wrote:
>>> On 02/02/2016 07:19 PM, Franklin S Cooper Jr. wrote:
>>>>>
>>>> So only making this change on the latest master with no
>>>> other changes I see the boot problem again.
>>
>> yep. I can confirm that.
>>
>> Also, I'm today came up with the similar fix that you've proposed before in this thread.
>> So, Could we move forward this way?
>
> I still think it would be good to actually understand what the actual
> problem was.
>
>>  From 8280895f01b33edba303e7374431bef47630f26c Mon Sep 17 00:00:00 2001
>> From: Grygorii Strashko <grygorii.strashko@ti.com>
>> Date: Wed, 3 Feb 2016 15:11:40 +0200
>> Subject: [PATCH] net: ti: netcp: restore get/set_pad_info() functionality
>>
>> The commit 899077791403 ("netcp: try to reduce type confusion in descriptors")
>> introduces a regression in Kernel 4.5-rc1 as it breaks
>> get/set_pad_info() functionality.
>>
>> The TI NETCP driver uses pad0 and pad1 fields of knav_dma_desc to
>> store DMA/MEM buffer pointer and buffer size respectively. And in both
>> cases the pointer type size is 32 bit regardless of LAPE enabled or
>> not.
>> 			!LAPE	LPAE
>> sizeof(void*)		32bit	32bit
>> sizeof(dma_addr_t) 	32bit	32bit
>> sizeof(phys_addr_t) 	32bit	64bit
>>
>
> This looks wrong: I was getting the build warnings originally
> because of 64-bit dma_addr_t, and that should be the only way that
> this driver can operate, because in some configurations on keystone
> there is no memory below 4GB, and there is no dma-ranges property
> in the DT that shifts around the start of the DMA addresses.

see keystone.dtsi:
	soc {
		#address-cells = <1>;
		#size-cells = <1>;
		compatible = "ti,keystone","simple-bus";
		interrupt-parent = <&gic>;
		ranges = <0x0 0x0 0x0 0xc0000000>;
		dma-ranges = <0x80000000 0x8 0x00000000 0x80000000>;
		^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

config:

CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_PHYS_ADDR_T_64BIT=y

and

#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT <--- should not be defined for KS2
typedef u64 dma_addr_t;
#else
typedef u32 dma_addr_t;
#endif

Above is valid configuration for Keystone 2 with LPAE=y

>
> This doesn't all fit together yet, maybe you have a better idea
> of what is going on.
>
> I don't think we should ever have a platform that has dma_addr_t
> and phys_addr_t be different.

This is a valid case.

>
>> Unfortunately, above commit changed buffer's pointers save/restore
>> code (get/set_pad_info()) and added intermediate conversation to u64
>> which causes TI NETCP driver crash in RX/TX path due to "Unable to
>> handle kernel NULL pointer" exception.
>
> The conversion is not what made it crash, it must be a bug in the
> conversion ;-)
>
>> @@ -163,11 +153,10 @@ static void set_desc_info(u32 desc_info, u32 pkt_info,
>>   	desc->packet_info = cpu_to_le32(pkt_info);
>>   }
>>
>> -static void set_pad_info(u32 pad0, u32 pad1, u32 pad2, struct knav_dma_desc *desc)
>> +static void set_pad_info(u32 pad0, u32 pad1, struct knav_dma_desc *desc)
>>   {
>>   	desc->pad[0] = cpu_to_le32(pad0);
>>   	desc->pad[1] = cpu_to_le32(pad1);
>> -	desc->pad[2] = cpu_to_le32(pad1);
>>   }
>
> As in my earlier patch, the line you are removing here was clearly
> broken, but evidently that is not the only bug.
>
>>   static void set_org_pkt_info(dma_addr_t buff, u32 buff_len,
>> @@ -581,7 +570,6 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
>>   	dma_addr_t dma_desc, dma_buf;
>>   	unsigned int buf_len, dma_sz = sizeof(*ndesc);
>>   	void *buf_ptr;
>> -	u32 pad[2];
>>   	u32 tmp;
>>
>>   	get_words(&dma_desc, 1, &desc->next_desc);
>> @@ -593,14 +581,12 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
>>   			break;
>>   		}
>>   		get_pkt_info(&dma_buf, &tmp, &dma_desc, ndesc);
>> -		get_pad_ptr(&buf_ptr, ndesc);
>> +		get_pad_info((u32 *)&buf_ptr, &buf_len, ndesc);
>
> I'd prefer not to put code like this back, as this cannot possibly
> do the right thing on a 64-bit architecture.
>
>
>> @@ -1078,7 +1058,6 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
>>   		u32 page_offset = frag->page_offset;
>>   		u32 buf_len = skb_frag_size(frag);
>>   		dma_addr_t desc_dma;
>> -		u32 desc_dma_32;
>>   		u32 pkt_info;
>>
>>   		dma_addr = dma_map_page(dev, page, page_offset, buf_len,
>> @@ -1100,8 +1079,7 @@ netcp_tx_map_skb(struct sk_buff *skb, struct netcp_intf *netcp)
>>   			(netcp->tx_compl_qid & KNAV_DMA_DESC_RETQ_MASK) <<
>>   				KNAV_DMA_DESC_RETQ_SHIFT;
>>   		set_pkt_info(dma_addr, buf_len, 0, ndesc);
>> -		desc_dma_32 = (u32)desc_dma;
>> -		set_words(&desc_dma_32, 1, &pdesc->next_desc);
>> +		set_words(&desc_dma, 1, &pdesc->next_desc);
>>   		pkt_len += buf_len;
>>   		if (pdesc != desc)
>>   			knav_pool_desc_map(netcp->tx_pool, pdesc,
>
> This is clearly broken on big-endian kernels with 64-bit dma_addr_t, so even
> if we revert the rest I think this part has to stay.

Keystone 2 has 32-bit dma_addr_t

>
> I have another version for testing below. That removes the logic that
> splits and reassembles the 64-bit values, but leaves the other changes
> in place. Can you try this?

Sry, but we really don't need this logic for KS2 ;)


>
> diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
> index c61d66d38634..cda19f2401c1 100644
> --- a/drivers/net/ethernet/ti/netcp_core.c
> +++ b/drivers/net/ethernet/ti/netcp_core.c
> @@ -120,16 +120,14 @@ static void get_pkt_info(dma_addr_t *buff, u32 *buff_len, dma_addr_t *ndesc,
>   static void get_pad_info(u32 *pad0, u32 *pad1, u32 *pad2, struct knav_dma_desc *desc)
>   {
>   	*pad0 = le32_to_cpu(desc->pad[0]);
> -	*pad1 = le32_to_cpu(desc->pad[1]);
> -	*pad2 = le32_to_cpu(desc->pad[2]);
> +	*pad2 = le32_to_cpu(desc->pad[1]);
>   }
>
>   static void get_pad_ptr(void **padptr, struct knav_dma_desc *desc)
>   {
>   	u64 pad64;
>
> -	pad64 = le32_to_cpu(desc->pad[0]) +
> -		((u64)le32_to_cpu(desc->pad[1]) << 32);
> +	pad64 = le32_to_cpu(desc->pad[0]);
>   	*padptr = (void *)(uintptr_t)pad64;
>   }
>
> @@ -166,8 +164,7 @@ static void set_desc_info(u32 desc_info, u32 pkt_info,
>   static void set_pad_info(u32 pad0, u32 pad1, u32 pad2, struct knav_dma_desc *desc)
>   {
>   	desc->pad[0] = cpu_to_le32(pad0);
> -	desc->pad[1] = cpu_to_le32(pad1);
> -	desc->pad[2] = cpu_to_le32(pad1);
> +	desc->pad[1] = cpu_to_le32(pad2);
>   }
>
>   static void set_org_pkt_info(dma_addr_t buff, u32 buff_len,
> @@ -581,7 +578,7 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
>   	dma_addr_t dma_desc, dma_buf;
>   	unsigned int buf_len, dma_sz = sizeof(*ndesc);
>   	void *buf_ptr;
> -	u32 pad[2];
> +	u32 pad;
>   	u32 tmp;
>
>   	get_words(&dma_desc, 1, &desc->next_desc);
> @@ -599,8 +596,8 @@ static void netcp_free_rx_desc_chain(struct netcp_intf *netcp,
>   		knav_pool_desc_put(netcp->rx_pool, desc);
>   	}
>
> -	get_pad_info(&pad[0], &pad[1], &buf_len, desc);
> -	buf_ptr = (void *)(uintptr_t)(pad[0] + ((u64)pad[1] << 32));
> +	get_pad_info(&pad, NULL, &buf_len, desc);
> +	buf_ptr = (void *)(uintptr_t)(pad);
>
>   	if (buf_ptr)
>   		netcp_frag_free(buf_len <= PAGE_SIZE, buf_ptr);
> @@ -653,8 +650,8 @@ static int netcp_process_one_rx_packet(struct netcp_intf *netcp)
>   	}
>
>   	get_pkt_info(&dma_buff, &buf_len, &dma_desc, desc);
> -	get_pad_info(&pad[0], &pad[1], &org_buf_len, desc);
> -	org_buf_ptr = (void *)(uintptr_t)(pad[0] + ((u64)pad[1] << 32));
> +	get_pad_info(&pad[0], NULL, &org_buf_len, desc);
> +	org_buf_ptr = (void *)(uintptr_t)(pad[0]);
>
>   	if (unlikely(!org_buf_ptr)) {
>   		dev_err(netcp->ndev_dev, "NULL bufptr in desc\n");
> @@ -858,8 +855,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
>   		if (unlikely(dma_mapping_error(netcp->dev, dma)))
>   			goto fail;
>
> -		pad[0] = lower_32_bits((uintptr_t)bufptr);
> -		pad[1] = upper_32_bits((uintptr_t)bufptr);
> +		pad[0] = (uintptr_t)bufptr;
>
>   	} else {
>   		/* Allocate a secondary receive queue entry */
> @@ -870,8 +866,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
>   		}
>   		buf_len = PAGE_SIZE;
>   		dma = dma_map_page(netcp->dev, page, 0, buf_len, DMA_TO_DEVICE);
> -		pad[0] = lower_32_bits(dma);
> -		pad[1] = upper_32_bits(dma);
> +		pad[0] = (u32)(dma);
>   		pad[2] = 0;
>   	}
>
> @@ -882,7 +877,7 @@ static int netcp_allocate_rx_buf(struct netcp_intf *netcp, int fdq)
>   	pkt_info |= (netcp->rx_queue_id & KNAV_DMA_DESC_RETQ_MASK) <<
>   		    KNAV_DMA_DESC_RETQ_SHIFT;
>   	set_org_pkt_info(dma, buf_len, hwdesc);
> -	set_pad_info(pad[0], pad[1], pad[2], hwdesc);
> +	set_pad_info(pad[0], 0, pad[2], hwdesc);
>   	set_desc_info(desc_info, pkt_info, hwdesc);
>
>   	/* Push to FDQs */
> @@ -1194,10 +1189,8 @@ static int netcp_tx_submit_skb(struct netcp_intf *netcp,
>   	}
>
>   	set_words(&tmp, 1, &desc->packet_info);
> -	tmp = lower_32_bits((uintptr_t)&skb);
> +	tmp = (uintptr_t)&skb;
>   	set_words(&tmp, 1, &desc->pad[0]);
> -	tmp = upper_32_bits((uintptr_t)&skb);
> -	set_words(&tmp, 1, &desc->pad[1]);
>
>   	if (tx_pipe->flags & SWITCH_TO_PORT_IN_TAGINFO) {
>   		tmp = tx_pipe->switch_to_port;
>


-- 
regards,
-grygorii
