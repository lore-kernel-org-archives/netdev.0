From: Eric Nelson <eric@nelint.com>
Subject: Re: [PATCH 3/3] net: fec: align IP header in hardware
Date: Fri, 30 Sep 2016 07:16:12 -0700
Message-ID: <638d2aa0-eb4a-dd4b-e516-d7ad89eca627@nelint.com>
References: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <1474728139-9335-1-git-send-email-eric@nelint.com>
 <1474728139-9335-4-git-send-email-eric@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0109865@AcuExch.aculab.com>
 <4d199f32-092c-1c0a-7a01-6d0d317ef676@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010A73F@AcuExch.aculab.com>
 <5cf173c4-84e0-f309-f356-35b114cc166e@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010E25C@AcuExch.aculab.com>
 <af74a33e-a164-bd2f-4c63-24a128d1ffb5@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010FE38@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "fugang.duan@nxp.com" <fugang.duan@nxp.com>,
        "otavio@ossystems.com.br" <otavio@ossystems.com.br>,
        "edumazet@google.com" <edumazet@google.com>,
        "troy.kisky@boundarydevices.com" <troy.kisky@boundarydevices.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>
To: David Laight <David.Laight@ACULAB.COM>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36590 "EHLO
        mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932968AbcI3OQP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 10:16:15 -0400
Received: by mail-pa0-f45.google.com with SMTP id qn7so39002551pac.3
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 07:16:14 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB010FE38@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On 09/30/2016 06:49 AM, David Laight wrote:
> From: Eric Nelson
>> Sent: 30 September 2016 14:27
>> Thanks for the feedback David,
>>
>> On 09/29/2016 04:07 AM, David Laight wrote:
>>> From: Eric Nelson
>>>> Sent: 28 September 2016 18:15
>>>> On 09/28/2016 09:42 AM, David Laight wrote:
>>>>> From: Eric Nelson
>>>>>> Sent: 26 September 2016 19:40
>>>>>> Hi David,
>>>>>>
>>>>>> On 09/26/2016 02:26 AM, David Laight wrote:
>>>>>>> From: Eric Nelson
>>>>>>>> Sent: 24 September 2016 15:42
>>>>>>>> The FEC receive accelerator (RACC) supports shifting the data payload of
>>>>>>>> received packets by 16-bits, which aligns the payload (IP header) on a
>>>>>>>> 4-byte boundary, which is, if not required, at least strongly suggested
>>>>>>>> by the Linux networking layer.
>>>>>>> ...
>>>>>>>> +		/* align IP header */
>>>>>>>> +		val |= FEC_RACC_SHIFT16;
>>>>>>>
>>>>>>> I can't help feeling that there needs to be corresponding
>>>>>>> changes to increase the buffer size by 2 (maybe for large mtu)
>>>>>>> and to discard two bytes from the frame length.
>>>>>>>
>>>>>>
>>>>>> In the normal case, the fec driver over-allocates all receive packets to
>>>>>> be of size FEC_ENET_RX_FRSIZE (2048) minus the value of rx_align,
>>>>>> which is either 0x0f (ARM) or 0x03 (PPC).
>>>>>>
>>>>>> If the frame length is less than rx_copybreak (typically 256), then
>>>>>> the frame length from the receive buffer descriptor is used to
>>>>>> control the allocation size for a copied buffer, and this will include
>>>>>> the two bytes of padding if RACC_SHIFT16 is set.
>>>>>>
>>>>>>> If probably ought to be predicated on NET_IP_ALIGN as well.
>>>>>>>
>>>>>> Can you elaborate?
>>>>>
>>>>> From reading this it seems that the effect of FEC_RACC_SHIFT16 is to
>>>>> add two bytes of 'junk' to the start of every receive frame.
>>>>>
>>>>
>>>> That's right. Two bytes of junk between the MAC header and the
>>>> IP header.
>>>>
>>>>> In the 'copybreak' case the new skb would need to be 2 bytes shorter
>>>>> than the length reported by the hardware, and the data copied from
>>>>> 2 bytes into the dma buffer.
>>>>>
>>>>
>>>> As it stands, the skb allocated by the copybreak routine will include
>>>> the two bytes of padding, and the call to skb_pull_inline will ignore
>>>> them.
>>>
>>> Ok, I didn't see that call being added by this patch.
>>>
>>>>> The extra 2 bytes also mean the that maximum mtu that can be received
>>>>> into a buffer is two bytes less.
>>>>>
>>>>
>>>> Right, but I think the max is already high enough that this isn't a
>>>> problem.
>>>>
>>>>> If someone sets the mtu to (say) 9k for jumbo frames this might matter.
>>>>> Even with fixed 2048 byte buffers it reduces the maximum value the mtu
>>>>> can be set to by 2.
>>>>>
>>>>
>>>> As far as I can tell, the fec driver doesn't support jumbo frames, and
>>>> the max frame length is currently hard-coded at PKT_MAXBUF_SIZE (1522).
>>>>
>>>> This is well within the 2048-byte allocation, even with optional headers
>>>> for VLAN etc.
>>>
>>> Hmm...
>>>
>>> That (probably) means all the skb the driver allocates are actually 4k.
>>> It would be much better to reduce the size so that the entire skb
>>> (with packet buffer) is less than 2k.
>>>
>>
>> That seems worthwhile, but un-related to this patch.
> 
> Indeed.
> 
>> It appears to me that the received packets could be allocated as
>>
>> PKT_MAXBUF_SIZE+fep->rx_align+NET_IP_ALIGN
>>
>> (+2 if FEC_RACC_SHIFT16 is used)
> 
> No.
> The packet buffers need to be allocated NET_IP_ALIGN + PKT_MAXBUF_SIZE
> byte long and (I assume) aligned on a fep->rx_align byte boundary.
> 

I think we're saying the same thing here, with the exception of the
+2 for FEC_RACC_SHIFT16.

> If NET_IP_ALIGN is set (to 2) then FEC_RACC_SHIFT16 must also me set
> so that the ethernet frame itself is 4n+2 aligned.
> 

This patch does this, but not with the beginning of the skb.

It also does this when NET_IP_ALIGN is zero though, and I believe this
is the right thing, so the IP header is aligned in a sensible way.

The driver can't handle a DMA to (4n+2) on any architecture.

>>>>> Now if NET_IP_ALIGN is zero then it is fine for the rx frame to start
>>>>> on a 4n boundary, and the skb are likely to be allocated that way.
>>>>> In this case you don't want to extra two bytes of 'junk'.
>>>>>
>>>> NET_IP_ALIGN is defaulting to 2 by the conditional in skbuff.h
>>>
>>> Even though it is always currently set is isn't really ideal to have
>>> a driver that breaks if it isn't set.
>>> This could easily happen at some point in the future if the ethernet
>>> logic is put with a different cpu.
>>>
>>
>> After multiple reads, I'm confused about the meaning of NET_IP_ALIGN
>> and how it should be used.
>>
>> From Documentation/unaligned-memory-access.txt, I take it that this
>> should be configured on a per-architecture basis, and it seems to be
>> set to zero on both PPC and x86.
>>
>> I wonder if this is proper though. It seems that its' use might depend
>> on the I/O subsystem(s) in use as much as the architecture.
> ...
> 
> If the cpu cannot do misaligned memory cycles then NET_IP_ALIGN must be 2
> and all receive frames must be aligned like that.
> 

On ARM, the CPU can't handle misaligned memory cycles without
taking an alignment fault and NET_IP_ALIGN is set to 2.

On PPC, NET_IP_ALIGN is set to zero.

I could use some help from NXP about whether the driver is used on
PPC, but I don't think it can DMA to 4n+2 addresses on any architecture
and the purpose of this patch is to align the frame on a (4n+2)
address.

> If the cpu can do misaligned memory cycles then the alignment of receive
> ethernet frames doesn't matter that much.
> NET_IP_ALIGN is likely to be set to zero because the cost of the cpu
> doing misaligned transfers it likely to be a lot less than that of
> un-optimised dma accesses to misaligned memory [1] [2].
> 

On ARM, we have CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
but I find it hard to believe that taking alignment faults is more
efficient than adding two bytes to the start of the frame.

> If NET_IP_ALIGN is zero then I believe that ethernet drivers are
> allowed to build skb that have the frame on a 4n+2 alignment.
> This is probably sensible if the hardware can write the two bytes.
> (DM might correct me there.)
> 

Again, I don't think the FEC can do this, even if PPC does allow
DMA to 4n+2 addresses for other functions.

> 	David
> 
> [1] The original sparc sbus 'DMA' part did multiple 16bit transfers instead
>   of a burst of 32bit transfers. This meant the buffer had to be misaligned
>   and a software copy done to align the frames. Fixed in the DMA+ part.
> 
> [2] PCIe writes are likely to be much faster if they contain entire cache
>   lines of data.
> 
