From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v4 2/2] net: systemport: pad packets to a minimum
 of 64 bytes
Date: Tue, 13 May 2014 17:18:51 -0700
Message-ID: <CAGVrzcadcBzoLL9sxnuZ-rszpO-h4BircuWxNr4a7oFHbKxtXA@mail.gmail.com>
References: <1399666599-19398-1-git-send-email-f.fainelli@gmail.com>
 <1399666599-19398-3-git-send-email-f.fainelli@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D0F7116C2@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:62468 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbaENATg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 20:19:36 -0400
Received: by mail-qc0-f175.google.com with SMTP id w7so1584485qcr.6
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 17:19:36 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F7116C2@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-12 5:45 GMT-07:00 David Laight <David.Laight@aculab.com>:
> From: Florian Fainelli
>> The switch fabric which is used behind the Broadcom SYSTEMPORT Ethernet
>> controller will discard any incoming packet that is not 64 bytes or
>> more. Since the UniMAC hardware transmits up to the specified size, just
>> make sure that we properly pad the end of the packet with zeroes using
>> skb_padto() and set a minimum packet length of 64 bytes.
>
> Surely the above should just be:
>     "Pad transmit packets to the minimum length (64 bytes)."
> All ethernet packets should be padded to 64 bytes (including the CRC).

Sure, I can definitively simplify the commit message.

>
> ...
>> @@ -848,10 +849,22 @@ static netdev_tx_t bcm_sysport_xmit(struct sk_buff *skb,
>>               }
>>       }
>>
>> -     mapping = dma_map_single(kdev, skb->data, skb->len, DMA_TO_DEVICE);
>> +     /* The Ethernet switch we are interfaced with needs packets to be at
>> +      * least 64 bytes otherwise they will be discarded when they enter
>> +      * the switch port logic. The UniMAC hardware transmits up to the
>> +      * specified length.
>> +      */
>> +     if (skb_padto(skb, 64)) {
>
> Shouldn't that be 60?

It should, absolutely, and that is ETH_ZLEN. Thanks!

> I presume there is an appropriate constant defined for it as well.
>
>> +             ret = NETDEV_TX_OK;
>> +             goto out;
>> +     }
>> +
>> +     skb_len = skb->len < 64 ? 64 : skb->len;
>> +
>> +     mapping = dma_map_single(kdev, skb->data, skb_len, DMA_TO_DEVICE);
>>       if (dma_mapping_error(kdev, mapping)) {
>>               netif_err(priv, tx_err, dev, "DMA map failed at %p (len=%d)\n",
>> -                             skb->data, skb->len);
>> +                             skb->data, skb_len);
>>               ret = NETDEV_TX_OK;
>>               goto out;
>>       }
> ...
>
>         david
>
>



-- 
Florian
