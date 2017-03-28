From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH 4/5] net/packet: fix overflow in check for tp_reserve
Date: Tue, 28 Mar 2017 11:21:05 -0400
Message-ID: <CAF=yD-+1q+mP+vLDWsQan4ffnHSUqKn_aEjWJtad2Gd9eVXUDg@mail.gmail.com>
References: <cover.1490709552.git.andreyknvl@google.com> <0f3f9342c09be4d97a820cf9abeb9dabed8eb69f.1490709552.git.andreyknvl@google.com>
 <CAF=yD-JJVYj0szu2=Pod2MtK6kYpoU=agwnNnn4yQegk6t4u7Q@mail.gmail.com> <CAAeHK+yX=3TTX+fYZCi5vPqa9=Fi2hyfybcbJo_iEFM4CLvWrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>,
        Network Development <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:36319 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751941AbdC1PV5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 11:21:57 -0400
Received: by mail-qk0-f194.google.com with SMTP id r142so9096096qke.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 08:21:51 -0700 (PDT)
In-Reply-To: <CAAeHK+yX=3TTX+fYZCi5vPqa9=Fi2hyfybcbJo_iEFM4CLvWrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 11:11 AM, Andrey Konovalov
<andreyknvl@google.com> wrote:
> On Tue, Mar 28, 2017 at 5:00 PM, Willem de Bruijn
> <willemdebruijn.kernel@gmail.com> wrote:
>> On Tue, Mar 28, 2017 at 10:00 AM, Andrey Konovalov
>> <andreyknvl@google.com> wrote:
>>> When calculating po->tp_hdrlen + po->tp_reserve the result can overflow.
>>>
>>> Fix by checking that tp_reserve <= INT_MAX on assign.
>>>
>>> This also takes cared of an overflow when calculating
>>>  macoff = TPACKET_ALIGN(po->tp_hdrlen) + 16 + po->tp_reserve
>>>  snaplen = skb->len
>>>  macoff + snaplen
>>> since macoff ~ INT_MAX and snaplen < SKB_MAX_ALLOC.
>>
>> This refers to the overflow of macoff + snaplen?
>>
>> Note that macoff is unsigned short, so will truncate any overflow from
>> tp_reserve.
>
> Yes, you're right.
> Should I make macoff unsigned int to fix this?

This is an unrelated issue. On first read, it seems quite harmless as
a process can
cause data to be placed at an offset that causes it to be overwritten
by the tpacket_hdr
later. Worth looking into more closely separately.

>>
>>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>>> ---
>>>  net/packet/af_packet.c | 7 ++++---
>>>  1 file changed, 4 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>>> index c5c43fff8c01..28b49749d1af 100644
>>> --- a/net/packet/af_packet.c
>>> +++ b/net/packet/af_packet.c
>>> @@ -3665,6 +3665,8 @@ packet_setsockopt(struct socket *sock, int level, int optname, char __user *optv
>>>                         return -EBUSY;
>>>                 if (copy_from_user(&val, optval, sizeof(val)))
>>>                         return -EFAULT;
>>> +               if (val > INT_MAX)
>>> +                       return -EINVAL;
>>
>> This change on its own is sufficient to avoid the overflow. For net
>> and backports to stable, this minimal patch is preferable.
>
> I will put it into a separate patch then.

Thanks.

>
>>
>>>                 po->tp_reserve = val;
>>>                 return 0;
>>>         }
>>> @@ -4200,6 +4202,8 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
>>>                 if (unlikely((u64)req->tp_block_size * req->tp_block_nr >
>>>                                         UINT_MAX))
>>>                         goto out;
>>> +               if (unlikely(po->tp_reserve >= req->tp_frame_size))
>>> +                       goto out;
>>>
>>>                 if (unlikely(!PAGE_ALIGNED(req->tp_block_size)))
>>>                         goto out;
>>> @@ -4207,9 +4211,6 @@ static int packet_set_ring(struct sock *sk, union tpacket_req_u *req_u,
>>>                     req->tp_block_size <=
>>>                           BLK_PLUS_PRIV((u64)req_u->req3.tp_sizeof_priv))
>>>                         goto out;
>>> -               if (unlikely(req->tp_frame_size < po->tp_hdrlen +
>>> -                                       po->tp_reserve))
>>> -                       goto out;
>>
>> Is there a reason that the test is moved up? It is probably not
>> correct to remove tp_hdrlen from the test.
>
> Just to group together all checks of tp_frame_size and tp_block_size.

That makes sense, but indeed more for net-next. I would then send a single patch
that includes the other new block and frame tests.

> I'm not sure there's any difference between checking against
> po->tp_hdrlen + po->tp_reserve and just po->tp_reserve.
> I guess the correct check should be against
> TPACKET_ALIGN(po->tp_hdrlen) + 16 + po->tp_reserve.
>
> Should I use this value?

Yes, for net-next this seems like a good tightening of the test.
