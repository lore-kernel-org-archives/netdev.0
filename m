From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/5] net: skb_gro_checksum_* functions
Date: Fri, 27 Jun 2014 17:47:57 -0700
Message-ID: <CA+mtBx8JpQTgy1afxWGPq3o8kkiN2X_hjCuoF4icBTjz1YujUQ@mail.gmail.com>
References: <alpine.DEB.2.02.1406201630550.12976@tomh.mtv.corp.google.com>
	<1403327349.16682.11.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:48075 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbaF1Ar6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 20:47:58 -0400
Received: by mail-ig0-f171.google.com with SMTP id h18so2577627igc.10
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 17:47:57 -0700 (PDT)
In-Reply-To: <1403327349.16682.11.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +     /* Save result in checksum complete */
>> +     skb->csum = skb_checksum(skb, 0, skb_gro_offset(skb), wsum);
>> +     skb->ip_summed = CHECKSUM_COMPLETE;
>> +     skb->csum_complete_sw = 1;
>> +     NAPI_GRO_CB(skb)->csum = wsum;
>
> Why is this affectation (NAPI_GRO_CB(skb)->csum = wsum) needed ?
>
This saves the csum so that it is available to a later encapsulated
protocol with a checksum.

> And why CHECKSUM_UNNECESSARY isn't used instead ?
>
A few reasons: 1) this won't work for GRE checksum, the checksum for
an encapsulated TCP packet would be assumed to be correct by current
checks 2) If there is UDP encapsulation the checksum would be
recomputed in this path 3) If the checksum is not correct, we can't
set unnecessary but can still set complete-- in this scenario the
packet will revert to normal path and we wouldn't want to compute full
checksum again there (might be possible DOS otherwise).

I think it will be possible to do correct conversions to
CHECKSUM_UNNECESSARY if we clarify precisely which protocols
CHECKSUM_UNNECESSARY applies to, and precisely what skb->encapsulation
applies to (in particular if this can be used with GRE in same way as
UDP). I intended to do this later, but maybe to keep GRO path
understandable this should be done first.

> This is a bit confusing, as tcp_gro_complete() will later set
> CHECKSUM_PARTIAL
>
This is okay since TCP is considered to be a terminal protocol and it
is assuming that all possible checksums have been verified. It might
be a better idea to use CHECKSUM_UNNECESSARY for consistency (maybe
eliminate use of CHECKSUM_PARTIAL in rx path).

Tom

> You might add comments, because this is so confusing, and I'd like to
> understand and maintain gro layer.
>
>> +
>> +     return sum;
>> +}
>> +EXPORT_SYMBOL(__skb_gro_checksum_complete);
>> +
>>  /*
>>   * net_rps_action_and_irq_enable sends any pending IPI's for rps.
>>   * Note: called with local irq disabled, but exits with local irq enabled.
>> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
>> index 546d2d4..fb8e6ba 100644
>> --- a/net/ipv4/udp_offload.c
>> +++ b/net/ipv4/udp_offload.c
>> @@ -176,6 +176,8 @@ static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *s
>>                       goto out;
>>       }
>>
>> +     NAPI_GRO_CB(skb)->encapsulation = 1;
>> +
>>       rcu_read_lock();
>>       uo_priv = rcu_dereference(udp_offload_base);
>>       for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
>
>
