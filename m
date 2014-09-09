From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 1/3] ipv6: Clear flush_id to make GRO work
Date: Tue, 9 Sep 2014 11:52:16 -0700
Message-ID: <CA+mtBx_Mm8VbnV8CdRdQySHahyr-YLpPiGHPeJvVt3FJqWXXkw@mail.gmail.com>
References: <1410286996-302-1-git-send-email-therbert@google.com>
	<1410286996-302-2-git-send-email-therbert@google.com>
	<1410287886.7106.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:55215 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751123AbaIISwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 14:52:16 -0400
Received: by mail-ig0-f177.google.com with SMTP id uq10so1719569igb.16
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 11:52:16 -0700 (PDT)
In-Reply-To: <1410287886.7106.20.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 9, 2014 at 11:38 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-09-09 at 11:23 -0700, Tom Herbert wrote:
>> In TCP gro we check flush_id which is derived from the IP identifier.
>> In IPv4 gro path the flush_id is set with the expectation that every
>> matched packet increments IP identifier. In IPv6, the flush_id is
>> never set and thus is uinitialized. What's worse is that in IPv6
>> over IPv4 encapsulation, the IP identifier is taken from the outer
>> header which is currently not incremented on every packet for Linux
>> stack, so GRO in this case never matches packets (identifier is
>> not increasing).
>>
>> This patch clears flush_id for every time for a matched packet in
>> IPv6 gro_receive. We need to do this each time to overwrite the
>> setting that would be done in IPv4 gro_receive per the outer
>> header in IPv6 over Ipv4 encapsulation.
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>>  net/ipv6/ip6_offload.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
>> index 5bcda33..929bbbcd 100644
>> --- a/net/ipv6/ip6_offload.c
>> +++ b/net/ipv6/ip6_offload.c
>> @@ -261,6 +261,9 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
>>               /* flush if Traffic Class fields are different */
>>               NAPI_GRO_CB(p)->flush |= !!(first_word & htonl(0x0FF00000));
>>               NAPI_GRO_CB(p)->flush |= flush;
>> +
>> +             /* Clear flush_id, there's really no concept of ID in IPv6. */
>> +             NAPI_GRO_CB(p)->flush_id = 0;
>>       }
>>
>>       NAPI_GRO_CB(skb)->flush |= flush;
>
> Yeah, I mentioned this problem months ago and apparently forgot to push
> the fix.
>
Unfortunately, probably not the last GRO issue. This whole thing is
really rather fragile and probably easy to break undetected...

> http://patchwork.ozlabs.org/patch/311212/
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
>
>
