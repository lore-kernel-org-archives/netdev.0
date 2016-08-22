From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [PATCH] gianfar: fix size of fragmented frames
Date: Mon, 22 Aug 2016 15:41:46 +0200
Message-ID: <2e03d037-7517-667a-bfca-0a2c798243bc@neratec.com>
References: <1471598156-16875-1-git-send-email-zefir.kurtisi@neratec.com>
 <AM5PR0401MB25613B657270085A3EE4324F96160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
 <f3ec9590-766b-ac5f-d793-ebc134366d09@neratec.com>
 <AM5PR0401MB2561233A47F3A64710D2293096160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
 <AM5PR0401MB25619ACF2F6D5B380E478AD396160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev list <netdev@vger.kernel.org>
To: Claudiu Manoil <claudiu.manoil@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:56749 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753151AbcHVNlt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 09:41:49 -0400
In-Reply-To: <AM5PR0401MB25619ACF2F6D5B380E478AD396160@AM5PR0401MB2561.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Claudiu,


On 08/19/2016 11:12 PM, Claudiu Manoil wrote:
> Hi Zefir,
> 
> [sorry if the message indentation is wrong ... webmail]
> 
> 
> From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
> Sent: Friday, August 19, 2016 8:11 PM
> To: Claudiu Manoil
> Subject: Re: [PATCH] gianfar: fix size of fragmented frames
>     
> Hi Claudiu,
> 
> On 08/19/2016 06:46 PM, Claudiu Manoil wrote:
>>> -----Original Message-----
>>> From: Zefir Kurtisi [mailto:zefir.kurtisi@neratec.com]
>>> Sent: Friday, August 19, 2016 12:16 PM
>>> To: netdev@vger.kernel.org
>>> Cc: claudiu.manoil@freescale.com
>>> Subject: [PATCH] gianfar: fix size of fragmented frames
>>>
>>> The eTSEC RxBD 'Data Length' field is context depening:
>>> for the last fragment it contains the full frame size,
>>> while fragments contain the fragment size, which equals
>>> the value written to register MRBLR.
>>>
>>
>> According to RM the last fragment has the whole packet length indeed,
>> and this should apply to fragmented frames too:
>>
>> " Data length, written by the eTSEC.
>> Data length is the number of octets written by the eTSEC into this BD's data buffer if L is cleared
>> (the value is equal to MRBLR), or, if L is set, the length of the frame including CRC, FCB (if
>> RCTRL[PRSDEP > 00), preamble (if MACCFG2[PreAmRxEn]=1), time stamp (if RCTRL[TS] = 1)
>> and any padding (RCTRL[PAL]). "
>>
>>> This differentiation is missing in the gianfar driver,
>>> which causes data corruption as soon as the hardware
>>> starts to fragment receiving frames. As a result, the
>>> size of fragmented frames is increased by
>>> (nr_frags - 1) * MRBLR
>>>
>>> We first noticed this issue working with DSA, where a
>>> 1540 octet frame is fragmented by the hardware and
>>> reconstructed by the driver as 3076 octet frame.
>>>
>>> This patch fixes the problem by adjusting the size of
>>> the last fragment.
>>>
>>> Signed-off-by: Zefir Kurtisi <zefir.kurtisi@neratec.com>
>>> ---
>>> drivers/net/ethernet/freescale/gianfar.c | 19 +++++++++++++------
>>> 1 file changed, 13 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/freescale/gianfar.c
>>> b/drivers/net/ethernet/freescale/gianfar.c
>>> index d20935d..4187280 100644
>>> --- a/drivers/net/ethernet/freescale/gianfar.c
>>> +++ b/drivers/net/ethernet/freescale/gianfar.c
>>> @@ -2922,17 +2922,24 @@ static bool gfar_add_rx_frag(struct gfar_rx_buff *rxb,
>>> u32 lstatus,
>>> {
>>>        unsigned int size = lstatus & BD_LENGTH_MASK;
>>>        struct page *page = rxb->page;
>>> +    bool last = !!(lstatus & BD_LFLAG(RXBD_LAST));
>>>
>>>        /* Remove the FCS from the packet length */
>>> -    if (likely(lstatus & BD_LFLAG(RXBD_LAST)))
>>> +    if (last)
>>>                size -= ETH_FCS_LEN;
>>>
>>> -    if (likely(first))
>>> +    if (likely(first)) {
>>>                skb_put(skb, size);
>>> -    else
>>> -            skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
>>> -                            rxb->page_offset + RXBUF_ALIGNMENT,
>>> -                            size, GFAR_RXB_TRUESIZE);
>>> +    } else {
>>> +            /* the last fragments' length contains the full frame length */
>>> +            if (last)
>>> +                    size -= skb->len;
>>
>> While I agree with your finding, I don't think this works for packets having more
>> than 2 buffers (head + 1 fragment).
>> How's this supposed to work for a skb with 2 fragments, for instance?
>> I think this needs more thoughtful consideration.
>>
> In fact, this works and I tested it by setting GFAR_RXB_SIZE to 256. Receiving a
> 1000 byte frame then results in 4 fragments, 3*256 plus the last one sized 1000.
> The driver then combines 256+256+256+232 (=1000-768) back to a 1000 bytes frame.
> 
> I don't see why it should not, because skb->len is exactly the size of the
> fragments added before the last one, so subtracting them from the total frame size
> should give the size of the last fragment, no?
> 
> [Claudiu]
> Thanks for the details. I didn't have much time to look into it (I still don't), and you can
> never be too careful with this kind of changes. But I agree with your assessment.
> I'm surprised this didn't come out earlier, like a warning from the stack, since the
> truesize can be easily exceeded in this case.
> 
In fact, I was observing warnings sending max-sized pings to the device:
# ping -c 1 -s 1472 <IP> => $ br0: dropped over-mtu packet: 3036 > 1500

That way, you won't get ICMP requests responded when the eTSEC is fragmenting (or
scatter-gathering) frames.

>>> +
>>> +            if (size > 0 && size <= GFAR_RXB_SIZE)
>>
>> Why do you need this check?
>> The h/w ensures that the buffers won't exceed GFAR_RXB_SIZE
>> (which is MRBL), size 0 is also not possible.
>>
> Do you question the first part? In cases where the last fragment consists of only
> the FCS, adding a zero size fragment would falsify skb->truesize.
> 
> The second expression is fail-safe only - it should never happen given the
> hardware specs - but if it did, not checking for a sane frame size might cause
> serious trouble (not sure what skb_add_rx_frag() does with an insanely high size
> value). If you prefer, I will leave it out in v2 of the patch.
> 
> [Claudiu]
> Nice catch with the size > 0 part too.  The second part is debatable indeed, it may case
> confusion implying that size may exceed that limit, which is false, since the point of RX
> S/G is that a buffer doesn't exceed GFAR_RXB_SIZE.  So I'd drop the second check.
> Other than that,
> Acked-by: <claudiu.manoil@nxp.com>
> 
> Thanks,
> Claudiu    
> 
Thank you for the review, patch v2 is on its way.
