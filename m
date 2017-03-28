From: Andrey Konovalov <andreyknvl@google.com>
Subject: Re: [PATCH 3/5] net/packet: fix overflow in check for tp_frame_nr
Date: Tue, 28 Mar 2017 19:19:27 +0200
Message-ID: <CAAeHK+yRZ-oM5ynNgpBSR+s0TFfN6K4M_+5uX9m__xP+syZWAw@mail.gmail.com>
References: <CAEfhGizS=cwEka=ouphw2S6yL-n4OzZ8msX=FOBO_UjnSAB+cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:32850 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752469AbdC1RTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 13:19:53 -0400
Received: by mail-pg0-f50.google.com with SMTP id n5so70947216pgh.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 10:19:42 -0700 (PDT)
In-Reply-To: <CAEfhGizS=cwEka=ouphw2S6yL-n4OzZ8msX=FOBO_UjnSAB+cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 5:54 PM, Craig Gallek <kraigatgoog@gmail.com> wrote:
> On Tue, Mar 28, 2017 at 10:00 AM, Andrey Konovalov
> <andreyknvl@google.com> wrote:
>> When calculating rb->frames_per_block * req->tp_block_nr the result
>> can overflow.
>>
>> Add a check that tp_block_size * tp_block_nr <= UINT_MAX.
>>
>> Since frames_per_block <= tp_block_size, the expression would
>> never overflow.
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>> ---
>>  net/packet/af_packet.c | 3 +++
>>  1 file changed, 3 insertions(+)
>>
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index 506348abdf2f..c5c43fff8c01 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -4197,6 +4197,9 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
>>                         goto out;
>>                 if (unlikely(req->tp_frame_size == 0))
>>                         goto out;
>> +               if (unlikely((u64)req->tp_block_size * req->tp_block_nr >
>> +                                       UINT_MAX))
>> +                       goto out;
> So this may be pedantic, but really the only guarantee that you have
> for the 'unsigned int' type of these fields is that they are _at
> least_ 16 bits.  There is no guarantee on the upper bound size, so
> casting to a u64 will be problematic on a compiler that happens to use
> 64 bits for 'unsigned int'.  I'm not aware of any that use greater
> than 32 bits right now and using one that does may very well break
> other things in the kernel, but here we are...  Perhaps a alternative
> fix would be to do the multiplication into an 'unsigned int' type and
> ensure that the result is larger than each of the original two values?

I don't mind changing the check, but I've never encountered such compilers.

Would this alternative work? It doesn't seem obvious.

Other alternatives that I see for this check are:

1. req->tp_block_size > UINT_MAX / req->tp_block_nr

2. (req->tp_block_size * req->tp_block_nr) / req->tp_block_nr !=
req->tp_block_size

I'm not sure which one is better.

>
> The real issue is that explicit size types should have been used in
> this userspace structure.
