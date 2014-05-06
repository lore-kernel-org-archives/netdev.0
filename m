From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 2/2] net: systemport: pad packets to a minimum
 of 64 bytes
Date: Tue, 6 May 2014 09:32:54 -0700
Message-ID: <CAGVrzcadbNGUWaT=nFNkW67tJQf0Q56DXGvmhB2hhbD948Z6pg@mail.gmail.com>
References: <1399317652-20078-1-git-send-email-f.fainelli@gmail.com>
 <1399317652-20078-3-git-send-email-f.fainelli@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D0F70CFD2@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:63372 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbaEFQdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 12:33:35 -0400
Received: by mail-qg0-f50.google.com with SMTP id z60so4297468qgd.9
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 09:33:34 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F70CFD2@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-06 2:31 GMT-07:00 David Laight <David.Laight@aculab.com>:
> From: Florian Fainelli
>> The switch fabric which is used behind the Broadcom SYSTEMPORT Ethernet
>> controller will discard any incoming packet that is not 64 bytes or
>> more. Since the UniMAC hardware automatically pads up to the specified
>> length, we can simply ensure we instruct it to transmit >= 64 bytes
>> packets.
>
> That is a strange description...
> All ethernet packets are padded out to 64 bytes, but IIRC that includes the CRC.
> If the UniMAC hardware automatically pads, then why do you need to do anything
> in the driver?

I think this explanation is not very good, I should have written something like:

"UniMAC will transmit up to the specified number of bytes" or something similar.

> If the actual problem (hinted at) is that the hardware is padding with the
> 'random' bytes after the end of the frame, then that should be in the comment.
>
> ...
>> @@ -848,7 +849,19 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
>>               }
>>       }
>>
>> -     mapping = dma_map_single(kdev, skb->data, skb->len, DMA_TO_DEVICE);
>> +     /* The Ethernet switch we are interfaced with needs packets to be at
>> +      * least 64 bytes otherwise they will be discarded when they enter
>> +      * the switch port logic. The UniMAC hardware automatically pads if
>> +      * instructed to do so.
>> +      */
>> +     if (skb_padto(skb, 64)) {
>> +             ret = NETDEV_TX_OK;
>
> Isn't that a silent tx discard, and possibly a skb/memory leak?

skb_padto() returns !=0 if it failed to pad and also frees the SKB
(see the comment in include/linux/skbuff.h).

>
>> +             goto out;
>> +     }
>> +
>> +     skb_len = skb->len < 64 ? 64 : skb->len;
>> +
>> +     mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
>>       if (dma_mapping_error(kdev, mapping)) {
>>               netif_err(priv, tx_err, dev, "DMA map failed at %p (len=%d)\n",
>>                               skb->data, skb->len);
>> @@ -860,14 +873,14 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
>>       cb = &ring->cbs[ring->curr_desc];
>>       cb->skb = skb;
>>       dma_unmap_addr_set(cb, dma_addr, mapping);
>> -     dma_unmap_len_set(cb, dma_len, skb->len);
>> +     dma_unmap_len_set(cb, dma_len, skb_len);
>>
>>       /* Fetch a descriptor entry from our pool */
>>       desc = ring->desc_cpu;
>>
>>       desc->addr_lo = lower_32_bits(mapping);
>>       len_status = upper_32_bits(mapping) & DESC_ADDR_HI_MASK;
>> -     len_status |= (skb->len << DESC_LEN_SHIFT);
>> +     len_status |= (skb_len << DESC_LEN_SHIFT);
>>       len_status |= (DESC_SOP | DESC_EOP | TX_STATUS_APP_CRC) <<
>>                       DESC_STATUS_SHIFT;
>>       if (skb->ip_summed == CHECKSUM_PARTIAL)
>> --
>
>         David
>
>
>



-- 
Florian
