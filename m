From: David Held <drheld@google.com>
Subject: Re: [PATCH net-next 1/2] udp: Simplify __udp*_lib_mcast_deliver.
Date: Tue, 15 Jul 2014 23:23:48 -0400
Message-ID: <CAGa1Tm6k0x88oE0pNEa2GBJg9+TVupmyTsuF=qj=UybFhmbv-Q@mail.gmail.com>
References: <1405377039-10082-1-git-send-email-drheld@google.com>
	<20140715.171431.1611412835087664432.davem@davemloft.net>
	<CAGa1Tm6hC5-JOidCHWHBHwni2mtpjUdqvQPByK7g9ZH2QHW=Jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Willem de Bruijn <willemb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:49854 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752988AbaGPDXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 23:23:49 -0400
Received: by mail-ig0-f179.google.com with SMTP id h18so407687igc.0
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 20:23:49 -0700 (PDT)
In-Reply-To: <CAGa1Tm6hC5-JOidCHWHBHwni2mtpjUdqvQPByK7g9ZH2QHW=Jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Will resubmit the patchset with that update.

On Tue, Jul 15, 2014 at 9:53 PM, David Held <drheld@google.com> wrote:
> On Tue, Jul 15, 2014 at 8:14 PM, David Miller <davem@davemloft.net> wrote:
>> From: David Held <drheld@google.com>
>> Date: Mon, 14 Jul 2014 18:30:38 -0400
>>
>>>       spin_lock(&hslot->lock);
>>> -     sk = sk_nulls_head(&hslot->head);
>>> -     dif = skb->dev->ifindex;
>>> -     sk = udp_v4_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
>>> -     while (sk) {
>>> -             stack[count++] = sk;
>>> -             sk = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
>>> -                                    daddr, uh->source, saddr, dif);
>>> -             if (unlikely(count == ARRAY_SIZE(stack))) {
>>> -                     if (!sk)
>>> -                             break;
>>> -                     flush_stack(stack, count, skb, ~0);
>>> -                     count = 0;
>>> +     sk_nulls_for_each(sk, node, &hslot->head) {
>>> +             if (__udp_is_mcast_sock(net, sk,
>>> +                                     uh->dest, daddr,
>>> +                                     uh->source, saddr,
>>> +                                     dif, hnum)) {
>>> +                     stack[count++] = sk;
>>> +                     if (unlikely(count == ARRAY_SIZE(stack))) {
>>> +                             flush_stack(stack, count, skb, ~0);
>>> +                             count = 0;
>>> +                     }
>>>               }
>>>       }
>>
>> I think you are changing the logic of the loop in the edge case.
>>
>> If we have exactly ARRAY_SIZE(stack) sockets to process, the old code
>> performs the flush_stack() outside of the hslot->lock, but with your
>> change we'll do it inside the lock.
>>
>> The tradeoff here is reducing hslot->lock hold times vs. avoiding
>> taking a hold on all the sockets in the stack[] array.
>>
>> I just wanted to point this out and make sure you are aware of and
>> are ok with this.
>
> The followup patch makes it so we always take a hold on the sockets
> anyway (it makes things simpler and only changes things for the too
> large array case), so might as well reduce the lock time for the
> exactly ARRAY_SIZE case.
>
> Should just be a matter of moving the stack addition below the ARRAY_SIZE check:
> +                       if (unlikely(count == ARRAY_SIZE(stack))) {
> +                               flush_stack(stack, count, skb, ~0);
> +                               count = 0;
> +                       }
> +                       stack[count++] = sk;
