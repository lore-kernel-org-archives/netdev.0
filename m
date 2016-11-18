From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support for GEM
Date: Fri, 18 Nov 2016 10:10:15 +0100
Message-ID: <a315b554-8b44-ac82-a104-e382940750bb@atmel.com>
References: <BN3PR07MB2516B2EBCF0AE7079971DBF6C9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVECJ-ZYjGg-3CbWD2Ka8yKzOokUxS8ZHHOJXa2Z6anuTr7Q@mail.gmail.com>
 <e6773b4e-a633-4754-893d-fd2351d07459@atmel.com>
 <BN3PR07MB2516EBCDD8822FC5F8A9095FC9B10@BN3PR07MB2516.namprd07.prod.outlook.com>
 <CAFcVEC+RqUMQF39oe2EuCoisX6dCwRQ3G81zFMqoOHU3HpfPHQ@mail.gmail.com>
 <BN3PR07MB25166D8301C60C4A35402AB1C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rafal Ozieblo <rafalo@cadence.com>,
        Harini Katakam <harinikatakamlinux@gmail.com>,
        Andrei Pistirica <Andrei.Pistirica@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:37084 "EHLO
        eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752430AbcKRJK5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 04:10:57 -0500
In-Reply-To: <BN3PR07MB25166D8301C60C4A35402AB1C9B00@BN3PR07MB2516.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/11/2016 à 09:59, Rafal Ozieblo a écrit :
> Hello,
> 
>> From: Harini Katakam [mailto:harinikatakamlinux@gmail.com]
>> Sent: 18 listopada 2016 05:30
>> To: Rafal Ozieblo
>> Cc: Nicolas Ferre; harini.katakam@xilinx.com; netdev@vger.kernel.org; linux-kernel@vger.kernel.org
>> Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support for GEM
>>
>> Hi Rafal,
>>
>> On Thu, Nov 17, 2016 at 7:05 PM, Rafal Ozieblo <rafalo@cadence.com> wrote:
>>> -----Original Message-----
>>> From: Nicolas Ferre [mailto:nicolas.ferre@atmel.com]
>>> Sent: 17 listopada 2016 14:29
>>> To: Harini Katakam; Rafal Ozieblo
>>> Cc: harini.katakam@xilinx.com; netdev@vger.kernel.org;
>>> linux-kernel@vger.kernel.org
>>> Subject: Re: [RFC PATCH 2/2] net: macb: Add 64 bit addressing support
>>> for GEM
>>>
>>>> Le 17/11/2016 à 13:21, Harini Katakam a écrit :
>>>>> Hi Rafal,
>>>>>
>>>>> On Thu, Nov 17, 2016 at 5:20 PM, Rafal Ozieblo <rafalo@cadence.com> wrote:
>>>>>> Hello,
>>>>>> I think, there could a bug in your patch.
>>>>>>
>>>>>>> +
>>>>>>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>>>>>>> +             dmacfg |= GEM_BIT(ADDR64); #endif
>>>>>>
>>>>>> You enable 64 bit addressing (64b dma bus width) always when appropriate architecture config option is enabled.
>>>>>> But there are some legacy controllers which do not support that feature. According Cadence hardware team:
>>>>>> "64 bit addressing was added in July 2013. Earlier version do not have it.
>>>>>> This feature was enhanced in release August 2014 to have separate upper address values for transmit and receive."
>>>>>>
>>>>>>> /* Bitfields in NSR */
>>>>>>> @@ -474,6 +479,10 @@
>>>>>>>  struct macb_dma_desc {
>>>>>>  >      u32     addr;
>>>>>>>       u32     ctrl;
>>>>>>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>>>>>>> +     u32     addrh;
>>>>>>> +     u32     resvd;
>>>>>>> +#endif
>>>>>>>  };
>>>>>>
>>>>>> It will not work for legacy hardware. Old descriptor is 2 words wide, the new one is 4 words wide.
>>>>>> If you enable CONFIG_ARCH_DMA_ADDR_T_64BIT but hardware doesn't
>>>>>> support it at all, you will miss every second descriptor.
>>>>>>
>>>>>
>>>>> True, this feature is not available in all of Cadence IP versions.
>>>>> In fact, the IP version Zynq does not support this. But the one in ZynqMP does.
>>>>> So, we enable kernel config for 64 bit DMA addressing for this SoC
>>>>> and hence the driver picks it up. My assumption was that if the
>>>>> legacy IP does not support
>>>>> 64 bit addressing, then this DMA option wouldn't be enabled.
>>>>>
>>>>> There is a design config register in Cadence IP which is being read
>>>>> to check for 64 bit address support - DMA mask is set based on that.
>>>>> But the addition of two descriptor words cannot be based on this runtime check.
>>>>> For this reason, all the static changes were placed under this check.
>>>>
>>>> We have quite a bunch of options in this driver to determinate what is the real capacity of the underlying hardware.
>>>> If HW configuration registers are not appropriate, and it seems they are not, I would advice to simply use the DT compatibility string.
>>>>
>>>> Best regards,
>>>> --
>>>> Nicolas Ferre
>>>
>>> HW configuration registers are appropriate. The issue is that this code doesn’t use the capability bit to switch between different dma descriptors (2 words vs. 4 words).
>>> DMA descriptor size is chosen based on kernel configuration, not based on hardware capabilities.
>>
>> HW configuration register does give appropriate information.
>> But addition of two address words in the macb descriptor structure is a static change.
>>
>> +static inline void macb_set_addr(struct macb_dma_desc *desc, dma_addr_t
>> +addr) {
>> +       desc->addr = (u32)addr;
>> +#ifdef CONFIG_ARCH_DMA_ADDR_T_64BIT
>> +       desc->addrh = (u32)(addr >> 32); #endif
>> +
>>
>> Even if the #ifdef condition here is changed to HW config check, addr and addrh are different.
>> And "addrh" entry has to be present for 64 bit desc case to be handled separately.
>> Can you please tell me how you propose change in DMA descriptor structure from
>> 4 to 2 or 2 to 4 words *after* reading the DCFG register?
> 
> It is very complex problem. I wrote to you because I faced the same issue. I'm working on PTP implementation for macb. When PTP is enabled there are additional two words in buffer descriptor.

Moreover, we can use PTP without the 64bits descriptor support (early
GEM revisions).

BTW, note that there is an initiative ongoing with Andrei to support
PTP/1588 on these devices with patches already send: please synchronize
with him.
https://marc.info/?l=linux-netdev&m=147282092309112&w=3
or
https://patchwork.kernel.org/patch/9310989/
and
https://patchwork.kernel.org/patch/9310991/

Regards,

> But hardware might not be compatible with PTP. Therefore I have to change DMA descriptor between 2 and 4 words after reading DCFG register (the same as you between 32b and 64b).
> When we consider both PTP and 64 bits, we end up with 4 different descriptors!
> 
> 1. 32b and without PTP support:
> 
> struct macb_dma_desc {
> 	u32	addr;
> 	u32	ctrl;
> }
> 
> 2. 64b and without PTP support:
> 
> struct macb_dma_desc {
> 	u32	addr;
> 	u32	ctrl;
> 	u32 	addrh;
> 	u32  	resvd;
> }
> 
> 3. 32 and PTP support:
> 
> struct macb_dma_desc {
> 	u32	addr;
> 	u32	ctrl;
> 	u32	dma_desc_ts_1;
> 	u32	dma_desc_ts_2;
> };
> 
> 4. 64b and PTP support:
> 
> struct macb_dma_desc {
> 	u32 	addr;
> 	u32 	ctrl;
> 	u32 	addrh;
> 	u32  	resvd;
> 	u32 	dma_desc_ts_1;
> 	u32	dma_desc_ts_2;
> };
> 
>> Can you please tell me how you propose change in DMA descriptor structure from
>> 4 to 2 or 2 to 4 words *after* reading the DCFG register?
> 
> I have some ideas but I don’t know whether it is possible to upstream it later on.
> IMHO, we need to use the same mechanism in both our cases.
> 
> My very first idea to start discussion:
> (Below is kind of pseudo code only to show my idea. All defines like 64B or PTP are omitted for simplicity)
> 
> 1. Prepare appropriate structures:
> 
> struct macb_dma_desc {
> 	u32	addr;
> 	u32	ctrl;
> }
> 
> struct macb_dma_desc_64 {
> 	u32 addrh;
> 	u32 resvd;
> }
> 
> struct macb_dma_desc_ptp {
> 	u32 dma_desc_ts_1;
> 	u32	dma_desc_ts_2;
> }
> 
> 2. Add hardware support information to macb:
> 
> enum macb_hw_cap {
> 	HW_CAP_NONE,
> 	HW_CAP_64B,
> 	HW_CAP_PTP,
> 	HW_CAP_64B_PTP,
> };
> 
> struct macb {
> // (...)
> 	macb_hw_cap hw_cap;
> 
> }
> 
> 3. Set bp->hw_cap on macb_probe()
> 
> 4. Additional function might be helpful:
> 
> static unsigned char macb_dma_desc_get_mul(struct macb *bp)
> {
> 	switch (bp->hw_cap) {
> 		case HW_CAP_NONE:
> 			return 1;
> 		case HW_CAP_64B:
> 		case HW_CAP_PTP:
> 			return 2;
> 		case HW_CAP_64B_PTP:
> 			return 3;
> 	}
> }
> 
> 5. Change sizeof struct to function:
> (sizeof(struct macb_dma_desc) change to macb_dma_desc_get_size(bp). It will return sizeof(struct macb_dma_desc) * macb_dma_desc_get_mul(bp).
> There is a hidden assumption that all three structures have the same size.
> 
> 6. macb_rx_desc() and macb_tx_desc() will still return struct macb_dma_desc * but descriptor index will be counted in different way, ex.
> 
> static struct macb_dma_desc *macb_rx_desc(struct macb *bp, unsigned int index)
> {
> 	index *= macb_dma_desc_get_mul(bp);
> 	return &bp->rx_ring[macb_rx_ring_wrap(bp, index)];
> }
> 
> 7. Two additional functions to dereference PTP and 64b information:
> 
> static struct macb_dma_desc_64 *macb_64b_desc(struct macb *bp, struct macb_dma_desc *desc)
> {
> 	switch (bp->hw_cap) {
> 		case HW_CAP_64B:
> 		case HW_CAP_64B_PTP:
> 			return (struct macb_dma_desc_64 *)(desc + 1);  // ugly casting
> 		default:
> 			return NULL;
> 	}
> }
> 
> static struct macb_dma_desc_ptp *macb_ptp_desc(struct macb *bp, struct macb_dma_desc *desc)
> {
> 	switch (bp->hw_cap) {
> 		case HW_CAP_PTP:
> 			return (struct macb_dma_desc_ptp *)(desc + 1);
> 		case HW_CAP_64B_PTP:
> 			return (struct macb_dma_desc_ptp *)(desc + 2);
> 		default:
> 			return NULL;
> 	}
> }
> 
> Whenever you want to reach fields in appropriate descriptor, above function should be used.
> 
> This is only my very first idea. Of course, we can leave it as it is and say, that old hardware is not support either when PTP enabled or 64b enabled.
> 


-- 
Nicolas Ferre
