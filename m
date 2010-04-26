From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Mon, 26 Apr 2010 21:35:52 +0800
Message-ID: <n2g412e6f7f1004260635kcd0c6ed7y5a9fc85a461d94fc@mail.gmail.com>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	<1271583573.16881.4798.camel@edumazet-laptop> <1271590476.16881.4925.camel@edumazet-laptop>
	<1271764941.3735.94.camel@bigi> <1271769195.7895.4.camel@edumazet-laptop>
	<1271853570.4032.21.camel@bigi> <1271876480.7895.3106.camel@edumazet-laptop>
	<1271938343.4032.30.camel@bigi> <t2r412e6f7f1004241931ie9e70e3aka77b49557a7872e3@mail.gmail.com>
	<1272281709.8918.35.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f202.google.com ([209.85.223.202]:49039 "EHLO
	mail-iw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804Ab0DZNgN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 09:36:13 -0400
Received: by iwn40 with SMTP id 40so3203623iwn.1
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 06:36:12 -0700 (PDT)
In-Reply-To: <1272281709.8918.35.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 26, 2010 at 7:35 PM, jamal <hadi@cyberus.ca> wrote:
> On Sun, 2010-04-25 at 10:31 +0800, Changli Gao wrote:
>
>> I read the code again, and find that we don't use spin_lock_irqsave(=
),
>> and we use local_irq_save() and spin_lock() instead, so
>> _raw_spin_lock_irqsave() and _raw_spin_lock_irqrestore() should not =
be
>> related to backlog. the lock maybe sk_receive_queue.lock.
>
> Possible.
> I am wondering if there's a way we can precisely nail where that is
> happening? is lockstat any use?
> Fixing _raw_spin_lock_irqsave and friend is the lowest hanging fruit.
>

Maybe lockstat can help in this case.

> So looking at your patch now i see it is likely there was an improvem=
ent
> made for non-rps case (moving out of loop some irq_enable etc).
> i.e my results may not be crazy after adding your patch and seeing an
> improvement for non-rps case.
> However, whatever your patch did - it did not help the rps case case:
> call_function_single_interrupt() comes out higher in the profile,
> and # of IPIs seems to have gone up (although i did not measure this,=
 I
> can see the interrupts/second went up by almost 50-60%)

Did you apply the patch from Eric? It would reduce the number of
local_irq_disable() calls but increase the number of IPIs.

>
>> Jamal, did you use a single socket to serve all the clients?
>
> Socket per detected cpu.

Ignore it. I made a mistake here.

>
>> BTW: =C2=A0completion_queue and output_queue in softnet_data both ar=
e LIFO
>> queues. For completion_queue, FIFO is better, as the last used skb i=
s
>> more likely in cache, and should be used first. Since slab has alway=
s
>> cache the last used memory at the head, we'd better free the skb in
>> FIFO manner. For output_queue, FIFO is good for fairness among qdisc=
s.
>
> I think it will depend on how many of those skbs are sitting in the
> completion queue, cache warmth etc. LIFO is always safest, you have
> higher probability of finding a cached skb infront.
>

we call kfree_skb() to release skbs to slab allocator, then slab
allocator stores them in a LIFO queue. If completion queue is also a
LIFO queue, the latest unused skb will be in the front of the queue,
and will be released to slab allocator at first. At the next time, we
call alloc_skb(), the memory used by the skb in the end of the
completion queue will be returned instead of the hot one.

However, as Eric said, new drivers don't rely on completion queue, it
isn't a real problem, especially in your test case.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
