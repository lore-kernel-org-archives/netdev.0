From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: Keystone 2 boards boot failure
Date: Thu, 4 Feb 2016 18:25:08 +0200
Message-ID: <56B37B64.1000606@ti.com>
References: <56B0DE61.2000704@ti.com> <56B20A96.9040507@ti.com>
 <56B20CD1.5060003@ti.com> <1888105.8DsfvU3cAo@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "Franklin S Cooper Jr." <fcooper@ti.com>, <m-karicheri2@ti.com>,
	<netdev@vger.kernel.org>, <w-kwok2@ti.com>, <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:50002 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934041AbcBDQZS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 11:25:18 -0500
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

[...]

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
> 
> I have another version for testing below. That removes the logic that
> splits and reassembles the 64-bit values, but leaves the other changes
> in place. Can you try this?
> 

Nop. It crashes kernel
   50.244448] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   50.266219] Unable to handle kernel NULL pointer dereference at virtual address 00000001
[   50.274287] pgd = c0003000
[   50.277007] [00000001] *pgd=80000800004003, *pmd=00000000
[   50.282412] Internal error: Oops: a07 [#1] PREEMPT SMP ARM
[   50.287881] Modules linked in:
[   50.290938] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W       4.5.0-rc2-00179-gad2f022-dirty #30
[   50.300214] Hardware name: Keystone
[   50.303693] task: c07476c0 ti: c0742000 task.ti: c0742000
[   50.309082] PC is at _test_and_set_bit+0x4/0x4c
[   50.313607] LR is at __netif_schedule+0x1c/0x60
[   50.318127] pc : [<c028415c>]    lr : [<c04294f0>]    psr: 20000113
[   50.318127] sp : c0743d68  ip : 00000001  fp : c0743d7c
[   50.329568] r10: c0743e00  r9 : c0744100  r8 : ffff9e75
[   50.334775] r7 : 00000000  r6 : 00000040  r5 : de495b00  r4 : 6d3cdb51
[   50.341282] r3 : 00000001  r2 : c07476c0  r1 : 6d3cdba9  r0 : 00000000
[   50.347790] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
[   50.355077] Control: 30c5387d  Table: 1878abc0  DAC: fffffffd
[   50.360803] Process swapper/0 (pid: 0, stack limit = 0xc0742210)
[   50.366790] Stack: (0xc0743d68 to 0xc0744000)
[   50.371137] 3d60:                   d9a16a00 de495b00 c0743d94 c0743d80 c04295a0 c04294e0
[   50.379291] 3d80: de7a9cc0 de495b00 c0743dbc c0743d98 c037396c c0429570 c0061d34 00000010
[   50.387445] 3da0: de7a9d80 de7a9d80 00000040 0000012c c0743ddc c0743dc0 c0375f58 c0373848
[   50.395599] 3dc0: de7a9d80 c0375f3c 00000040 0000012c c0743e3c c0743de0 c042a0cc c0375f48
[   50.403752] 3de0: c0743e9c c06635f8 c0744b1c c0744b1c c0773c46 1e46b000 c0741000 debac000
[   50.411907] 3e00: c0743e00 c0743e00 c0743e08 c0743e08 de408000 00000000 c074408c c0742000
[   50.420061] 3e20: 00000101 00000003 40000003 c0744080 c0743e9c c0743e40 c0026670 c0429ed8
[   50.428215] 3e40: d8722360 c0744808 00200000 c0744100 ffff9e74 c054088c 0000000a c07779c0
[   50.436369] 3e60: c073d2c8 c0744080 c0743e40 c0742000 c0744808 c073dddc 0000004e 00000000
[   50.444522] 3e80: 00000000 de408000 c0773aa4 c07444fc c0743eb4 c0743ea0 c0026a38 c0026548
[   50.452675] 3ea0: c073dddc 0000004e c0743edc c0743eb8 c0061d34 c00269c4 c0744808 e080400c
[   50.460828] 3ec0: c0743f08 e0804000 e0805000 c0773aa4 c0743f04 c0743ee0 c0009438 c0061cd8
[   50.468981] 3ee0: c0010314 60000013 ffffffff c0743f3c c0773aa4 c0773aa4 c0743f64 c0743f08
[   50.477136] 3f00: c0013a80 c0009404 00000000 deba8348 000070c8 c001f880 c0742000 c07444b0
[   50.485289] 3f20: c073d324 c0743f78 c0773aa4 c0773aa4 c07444fc c0743f64 c0743f68 c0743f58
[   50.493442] 3f40: c0010310 c0010314 60000013 ffffffff c006d624 c006a15c c0743f74 c0743f68
[   50.501595] 3f60: c00598c0 c00102e0 c0743f8c c0743f78 c00599dc c00598a4 00000002 00000000
[   50.509749] 3f80: c0743fa4 c0743f90 c0538468 c00598d8 c0777050 00000000 c0743ff4 c0743fa8
[   50.517902] 3fa0: c06fad60 c05383e4 ffffffff ffffffff 00000000 c06fa6d8 ffffffff 00000000
[   50.526056] 3fc0: 00000000 c0731a30 00000000 c0777294 c0744484 c0731a2c c0748878 80007000
[   50.534210] 3fe0: 412fc0f4 00000000 00000000 c0743ff8 80008090 c06fa964 00000000 00000000
[   50.542357] Backtrace: 
[   50.544816] [<c04294d4>] (__netif_schedule) from [<c04295a0>] (netif_wake_subqueue+0x3c/0x44)
[   50.553312]  r5:de495b00 r4:d9a16a00
[   50.556909] [<c0429564>] (netif_wake_subqueue) from [<c037396c>] (netcp_process_tx_compl_packets+0x130/0x134)
[   50.566789]  r5:de495b00 r4:de7a9cc0
[   50.570381] [<c037383c>] (netcp_process_tx_compl_packets) from [<c0375f58>] (netcp_tx_poll+0x1c/0x4c)
[   50.579570]  r7:0000012c r6:00000040 r5:de7a9d80 r4:de7a9d80
[   50.585258] [<c0375f3c>] (netcp_tx_poll) from [<c042a0cc>] (net_rx_action+0x200/0x2f8)
[   50.593148]  r7:0000012c r6:00000040 r5:c0375f3c r4:de7a9d80
[   50.598833] [<c0429ecc>] (net_rx_action) from [<c0026670>] (__do_softirq+0x134/0x258)
[   50.606637]  r10:c0744080 r9:40000003 r8:00000003 r7:00000101 r6:c0742000 r5:c074408c
[   50.614486]  r4:00000000
[   50.617023] [<c002653c>] (__do_softirq) from [<c0026a38>] (irq_exit+0x80/0xb8)
[   50.624221]  r10:c07444fc r9:c0773aa4 r8:de408000 r7:00000000 r6:00000000 r5:0000004e
[   50.632069]  r4:c073dddc
[   50.634608] [<c00269b8>] (irq_exit) from [<c0061d34>] (__handle_domain_irq+0x68/0xbc)
[   50.642410]  r5:0000004e r4:c073dddc
[   50.645996] [<c0061ccc>] (__handle_domain_irq) from [<c0009438>] (gic_handle_irq+0x40/0x78)
[   50.654318]  r9:c0773aa4 r8:e0805000 r7:e0804000 r6:c0743f08 r5:e080400c r4:c0744808
[   50.662087] [<c00093f8>] (gic_handle_irq) from [<c0013a80>] (__irq_svc+0x40/0x74)
[   50.669547] Exception stack(0xc0743f08 to 0xc0743f50)
[   50.674586] 3f00:                   00000000 deba8348 000070c8 c001f880 c0742000 c07444b0
[   50.682740] 3f20: c073d324 c0743f78 c0773aa4 c0773aa4 c07444fc c0743f64 c0743f68 c0743f58
[   50.690892] 3f40: c0010310 c0010314 60000013 ffffffff
[   50.695925]  r9:c0773aa4 r8:c0773aa4 r7:c0743f3c r6:ffffffff r5:60000013 r4:c0010314
[   50.703701] [<c00102d4>] (arch_cpu_idle) from [<c00598c0>] (default_idle_call+0x28/0x34)
[   50.711773] [<c0059898>] (default_idle_call) from [<c00599dc>] (cpu_startup_entry+0x110/0x180)
[   50.720366] [<c00598cc>] (cpu_startup_entry) from [<c0538468>] (rest_init+0x90/0x94)
[   50.728083]  r7:00000000 r4:00000002
[   50.731675] [<c05383d8>] (rest_init) from [<c06fad60>] (start_kernel+0x408/0x414)
[   50.739131]  r5:00000000 r4:c0777050
[   50.742716] [<c06fa958>] (start_kernel) from [<80008090>] (0x80008090)
[   50.749227] Code: e3500000 13a00001 e12fff1e e211c003 (15cc1000) 
[   50.755356] ---[ end trace ff02c0c474692a7b ]---



> 	Arnd
> 
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
