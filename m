From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH 3/5] net/packet: fix overflow in check for tp_frame_nr
Date: Wed, 29 Mar 2017 09:43:49 -0400
Message-ID: <CAEfhGiwOk2NEUDqxfr37T0t718x20r+o4xRS0GFH3vHdQboCbg@mail.gmail.com>
References: <CAEfhGizS=cwEka=ouphw2S6yL-n4OzZ8msX=FOBO_UjnSAB+cw@mail.gmail.com>
 <CAAeHK+yRZ-oM5ynNgpBSR+s0TFfN6K4M_+5uX9m__xP+syZWAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        netdev <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36585 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753680AbdC2Nnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 09:43:53 -0400
Received: by mail-qk0-f194.google.com with SMTP id r142so2056584qke.3
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 06:43:52 -0700 (PDT)
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com. [209.85.220.171])
        by smtp.gmail.com with ESMTPSA id u5sm4924476qkd.46.2017.03.29.06.43.50
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 06:43:50 -0700 (PDT)
Received: by mail-qk0-f171.google.com with SMTP id r142so12946906qke.2
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 06:43:50 -0700 (PDT)
In-Reply-To: <CAAeHK+yRZ-oM5ynNgpBSR+s0TFfN6K4M_+5uX9m__xP+syZWAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 1:19 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Tue, Mar 28, 2017 at 5:54 PM, Craig Gallek <kraigatgoog@gmail.com> wrote:
>> On Tue, Mar 28, 2017 at 10:00 AM, Andrey Konovalov
>> <andreyknvl@google.com> wrote:
>>> When calculating rb->frames_per_block * req->tp_block_nr the result
>>> can overflow.
>>>
>>> Add a check that tp_block_size * tp_block_nr <= UINT_MAX.
>>>
>>> Since frames_per_block <= tp_block_size, the expression would
>>> never overflow.
>>>
>>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>>> ---
>>>  net/packet/af_packet.c | 3 +++
>>>  1 file changed, 3 insertions(+)
>>>
>>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>>> index 506348abdf2f..c5c43fff8c01 100644
>>> --- a/net/packet/af_packet.c
>>> +++ b/net/packet/af_packet.c
>>> @@ -4197,6 +4197,9 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
>>>                         goto out;
>>>                 if (unlikely(req->tp_frame_size == 0))
>>>                         goto out;
>>> +               if (unlikely((u64)req->tp_block_size * req->tp_block_nr >
>>> +                                       UINT_MAX))
>>> +                       goto out;
>> So this may be pedantic, but really the only guarantee that you have
>> for the 'unsigned int' type of these fields is that they are _at
>> least_ 16 bits.  There is no guarantee on the upper bound size, so
>> casting to a u64 will be problematic on a compiler that happens to use
>> 64 bits for 'unsigned int'.  I'm not aware of any that use greater
>> than 32 bits right now and using one that does may very well break
>> other things in the kernel, but here we are...  Perhaps a alternative
>> fix would be to do the multiplication into an 'unsigned int' type and
>> ensure that the result is larger than each of the original two values?
>
> I don't mind changing the check, but I've never encountered such compilers.
>
> Would this alternative work? It doesn't seem obvious.
>
> Other alternatives that I see for this check are:
>
> 1. req->tp_block_size > UINT_MAX / req->tp_block_nr
>
> 2. (req->tp_block_size * req->tp_block_nr) / req->tp_block_nr !=
> req->tp_block_size
>
> I'm not sure which one is better.
I'm by no means the style expert here, but I would go with whichever
makes the intention of the check (preventing overflow) most obvious.
Maybe #1 in your example?  I'm also not sure what the acceptable
assumptions about the size of 'int' are in the kernel code.  I'm sure
there's a thread out there with Linus expressing a strong feeling one
way or another, but I haven't found it yet ;)

>
>>
>> The real issue is that explicit size types should have been used in
>> this userspace structure.
