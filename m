From: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Wed, 11 Oct 2017 22:55:25 +0100
Message-ID: <1e9c4f8b-2eb6-24cf-764f-b0a98aa0d044@kot-begemot.co.uk>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <CAF=yD-+SxQTHxiU5Yi2f8dm6X1s7SA6PdkbeJP-K_9ZuTMAaTA@mail.gmail.com>
 <f2fe3f46-2ef1-0029-1c44-3576ca19d34b@cambridgegreys.com>
 <844d6e0f-6ee7-74bc-b961-faa77b240303@cambridgegreys.com>
 <CAF=yD-+JaS8JwEC2TyUG=Ebaho-MM+gjumrbHYM-H0EK1Hu62Q@mail.gmail.com>
 <23ace6d6-afa7-9a3a-aa61-1245ee6c0498@kot-begemot.co.uk>
 <CAF=yD-+MCLAoP5=orUyG0tQjXykde++QrOdE7v44srR54yP32Q@mail.gmail.com>
 <d6c1cda2-f7df-9132-304d-075c62d4d83d@kot-begemot.co.uk>
 <CAF=yD-+gc5oQ=XT0+yw4Wt_h3rObETti3FvXm+V-nu=87zaMyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Anton Ivanov <anton.ivanov@cambridgegreys.com>,
        Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:36656 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750778AbdJKVzf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:55:35 -0400
In-Reply-To: <CAF=yD-+gc5oQ=XT0+yw4Wt_h3rObETti3FvXm+V-nu=87zaMyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]

> The test can be run both with and without ring:
>
>   psock_txring_vnet -l 8000 -s $src_ip -d $dst_ip -v
>   psock_txring_vnet -l 8000 -s $src_ip -d $dst_ip -v -N
>
> both with and without qdisc bypass ('-q').

Thanks, apologies, I was being inpatient. Started reading the source,
saw the tpacket bits and stopped there.

>
>>  - this goes via the tpacket_snd
>> which allocs via sock_alloc_send_skb. That results in a non-fragged skb
>> as it calls pskb after that with data_len = 0 asking for a contiguous one.
> but attached the ring slot as fragments in tpacket_fill_skb.
>
>> My stuff is using sendmmsg which ends up via packet_snd which allocs
>> via  sock_alloc_send_pskb which is invoked in a way which always creates
>> 2 segments - one for the linear section and one for the rest (and more
>> if needed). It is faster than tpacket by the way (several times).
>>
>> As a comparison tap and other virtual drivers use sock_alloc_send_pskb
>> with non-zero data length which results in multiple frags. The code in
>> packet_snd is in fact identical with tap (+/- some cosmetic differences).
>>
>> That is the difference between the tests and that is why your test works
>> and mine fails.
> All the above test cases work for me, including those that build skbs
> with fragments. Could you try those.

Tried it, works on all of the adapters and hosts where mine fails. I
will step by step hack-in the differences so it behaves same as mine
until I find the culprit.

This will be tomorrow though, it is late here.

The only obvious difference I can see at this point is that I am using
iovs and sending the vnet header as iov[0] and the data in pieces after
that while your code is doing a send() for the whole frame. This should
not make any difference though - it all ends up as an iov internally in
the kernel.

A.

>
