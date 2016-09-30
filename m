From: Eric Nelson <eric@nelint.com>
Subject: Re: [PATCH 3/3] net: fec: align IP header in hardware
Date: Fri, 30 Sep 2016 06:27:06 -0700
Message-ID: <af74a33e-a164-bd2f-4c63-24a128d1ffb5@nelint.com>
References: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <1474728139-9335-1-git-send-email-eric@nelint.com>
 <1474728139-9335-4-git-send-email-eric@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0109865@AcuExch.aculab.com>
 <4d199f32-092c-1c0a-7a01-6d0d317ef676@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010A73F@AcuExch.aculab.com>
 <5cf173c4-84e0-f309-f356-35b114cc166e@nelint.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010E25C@AcuExch.aculab.com>
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
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34639 "EHLO
        mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932748AbcI3N1K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 09:27:10 -0400
Received: by mail-pa0-f41.google.com with SMTP id dw4so24975230pac.1
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 06:27:09 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB010E25C@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the feedback David,

On 09/29/2016 04:07 AM, David Laight wrote:
> From: Eric Nelson
>> Sent: 28 September 2016 18:15
>> On 09/28/2016 09:42 AM, David Laight wrote:
>>> From: Eric Nelson
>>>> Sent: 26 September 2016 19:40
>>>> Hi David,
>>>>
>>>> On 09/26/2016 02:26 AM, David Laight wrote:
>>>>> From: Eric Nelson
>>>>>> Sent: 24 September 2016 15:42
>>>>>> The FEC receive accelerator (RACC) supports shifting the data payload of
>>>>>> received packets by 16-bits, which aligns the payload (IP header) on a
>>>>>> 4-byte boundary, which is, if not required, at least strongly suggested
>>>>>> by the Linux networking layer.
>>>>> ...
>>>>>> +		/* align IP header */
>>>>>> +		val |= FEC_RACC_SHIFT16;
>>>>>
>>>>> I can't help feeling that there needs to be corresponding
>>>>> changes to increase the buffer size by 2 (maybe for large mtu)
>>>>> and to discard two bytes from the frame length.
>>>>>
>>>>
>>>> In the normal case, the fec driver over-allocates all receive packets to
>>>> be of size FEC_ENET_RX_FRSIZE (2048) minus the value of rx_align,
>>>> which is either 0x0f (ARM) or 0x03 (PPC).
>>>>
>>>> If the frame length is less than rx_copybreak (typically 256), then
>>>> the frame length from the receive buffer descriptor is used to
>>>> control the allocation size for a copied buffer, and this will include
>>>> the two bytes of padding if RACC_SHIFT16 is set.
>>>>
>>>>> If probably ought to be predicated on NET_IP_ALIGN as well.
>>>>>
>>>> Can you elaborate?
>>>
>>> From reading this it seems that the effect of FEC_RACC_SHIFT16 is to
>>> add two bytes of 'junk' to the start of every receive frame.
>>>
>>
>> That's right. Two bytes of junk between the MAC header and the
>> IP header.
>>
>>> In the 'copybreak' case the new skb would need to be 2 bytes shorter
>>> than the length reported by the hardware, and the data copied from
>>> 2 bytes into the dma buffer.
>>>
>>
>> As it stands, the skb allocated by the copybreak routine will include
>> the two bytes of padding, and the call to skb_pull_inline will ignore
>> them.
> 
> Ok, I didn't see that call being added by this patch.
> 
>>> The extra 2 bytes also mean the that maximum mtu that can be received
>>> into a buffer is two bytes less.
>>>
>>
>> Right, but I think the max is already high enough that this isn't a
>> problem.
>>
>>> If someone sets the mtu to (say) 9k for jumbo frames this might matter.
>>> Even with fixed 2048 byte buffers it reduces the maximum value the mtu
>>> can be set to by 2.
>>>
>>
>> As far as I can tell, the fec driver doesn't support jumbo frames, and
>> the max frame length is currently hard-coded at PKT_MAXBUF_SIZE (1522).
>>
>> This is well within the 2048-byte allocation, even with optional headers
>> for VLAN etc.
> 
> Hmm...
>
> That (probably) means all the skb the driver allocates are actually 4k.
> It would be much better to reduce the size so that the entire skb
> (with packet buffer) is less than 2k.
>

That seems worthwhile, but un-related to this patch.

It appears to me that the received packets could be allocated as

PKT_MAXBUF_SIZE+fep->rx_align+NET_IP_ALIGN

(+2 if FEC_RACC_SHIFT16 is used)

>>> Now if NET_IP_ALIGN is zero then it is fine for the rx frame to start
>>> on a 4n boundary, and the skb are likely to be allocated that way.
>>> In this case you don't want to extra two bytes of 'junk'.
>>>
>> NET_IP_ALIGN is defaulting to 2 by the conditional in skbuff.h
> 
> Even though it is always currently set is isn't really ideal to have
> a driver that breaks if it isn't set.
> This could easily happen at some point in the future if the ethernet
> logic is put with a different cpu.
> 

After multiple reads, I'm confused about the meaning of NET_IP_ALIGN
and how it should be used.

>From Documentation/unaligned-memory-access.txt, I take it that this
should be configured on a per-architecture basis, and it seems to be
set to zero on both PPC and x86.

I wonder if this is proper though. It seems that its' use might depend
on the I/O subsystem(s) in use as much as the architecture.

For example, it might be desirable to have a different value for a PCIe
interface than for an integrated MAC like the FEC.

Looking at the example of the 3c59x driver, I see a pattern of an
allocation that adds NET_IP_ALIGN followed by an skb->reserve()
of NET_IP_ALIGN before determining the target address to end
up with allocation with 4n+2 alignment.

This seems somewhat equivalent to this patch, except that we're
using the allocated address as the target and using skb_pull_inline
afterwards.

Andy, is the FEC used on any PPC SOCs?

If so, then this patch may cause a DMA of 2 extra bytes per frame
unecessarily although the driver doesn't special-case the allocation
to align the IP header, so this is still probably preferred.

>>> OTOH if NET_IP_ALIGN is 2 then you need to 'fiddle' things so that
>>> the data is dma'd to offset -2 in the skb and then ensure that the
>>> end of frame is set correctly.
>>>
>>
>> That's what the RACC SHIFT16 bit does.
> 
> No, that causes the ethernet controller to add 2 bytes to the frame.
> You then need to change the dma target address to match.
>

Or use skb_pull_inline to ignore the two bytes.

> Otherwise if a new version of the silicon stops ignoring the low
> address with the frame will be misaligned in the buffer.
> 

I'm not sure I understand this.

> The receive frame length will also (probably) be 2 larger than the
> actual frame - so you need to set the end point correctly as well.
> IP will probably ignore the 2 bytes of pad I think you are generating.
> 

The received frame length **is** 2 bytes longer, but these are
eaten by skb_pull_inline().

>> The FEC hardware isn't capable of DMA'ing to an un-aligned address.
>> On ARM, it requires 64-bit alignment, but suggests 128-bit alignment.
>>
>> On other (PPC?) architectures, it requires 32-bit alignment. This is
>> handled by the rx_align field.
> 
> That isn't entirely relevant.
>
> If the kernel is being built with NET_IP_ALIGN set to 0 you should
> align the destination mac address on a 4n boundary
> (Or rather the skb are likely to be allocated that way).

They're not currently allocated that way. The routine
fec_enet_alloc_rxq_buffers
forces the allocations to 32 or 128-bit alignment through the
routine fec_enet_new_rxbdp().

> If it causes misaligned memory reads later on that is a different problem.

That's the problem this patch is designed to address. Without this
patch, the IP header is always mis-aligned.

> The MAC driver has aligned the frames as it was told to.
> 
> 	David
> 
> 

Regards,


Eric
