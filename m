From: Tom Herbert <tom@herbertland.com>
Subject: Re: Setting skb->csum in shared skb with csum-complete
Date: Thu, 19 Jan 2017 19:50:30 -0800
Message-ID: <CALx6S36AF8rz75LYRx7kzHx57Eazc9vi_QvJGwqQCR4GjCPOfQ@mail.gmail.com>
References: <CALx6S34ZfFzPOmzfLoverXQ215AvasYejyJUv8wtWAVRumi-eg@mail.gmail.com>
 <1484877634.16328.71.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:33382 "EHLO
        mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750747AbdATDub (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 22:50:31 -0500
Received: by mail-yw0-f169.google.com with SMTP id u68so26895209ywg.0
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 19:50:31 -0800 (PST)
In-Reply-To: <1484877634.16328.71.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 19, 2017 at 6:00 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2017-01-19 at 17:29 -0800, Tom Herbert wrote:
>> Hi Herbert,
>>
>> I am looking at "net: Fix skb csum races when peeking". The context is
>> that I'm seeing checksum faults after backporting mlx5 from driver.
>> The handling of the checksum faults in interesting in itself. One side
>> effect is that we end up recalculating and doing the dump twice when
>> GRO is enabled. Another is that we validate checksum complete in a
>> shared skbuf with a knowingly bad skb->csum value.
>>
>> In the checksum fault case we recalculate the checksum and find it was
>> actually correct in the packet. If the skb is not shared then we set
>> the skb->csum to the correct value and also set skb->csum_complete_sw
>> and skb->csum_valid. But if skb is shared we don't do any of that.
>> This is kind of odd since __skb_checksum_complete_head then returns
>> zero for an skb with checksum_complete where the checksum complete
>> value is not correct. I'm not sure what the consequences of doing that
>> are (I don't think it's related to issues I'm seeing) but this doesn't
>> seem like a good thing. Maybe we should set skb->csum in this case
>> since we know it's already wrong and the fact that skbuf is shared
>> can't make it more wrong...
>
> Why GRO can not change skb fields ?
>
Sure, I just noted this fact. We don't typically expect the device to
be giving us miscomputed checksum complete values ;-)

> skb can not be shared at GRO layer, so really this should be done there
> if you want to avoid a double checksumming later.
>
> You added all these skb fields, you know better than us ;)
>
>
>
