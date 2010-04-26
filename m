From: jamal <hadi@cyberus.ca>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Mon, 26 Apr 2010 07:35:09 -0400
Message-ID: <1272281709.8918.35.camel@bigi>
References: <t2p65634d661004141031xf80f62e7sb64362ea1ce10a1f@mail.gmail.com>
	 <1271489739.16881.4586.camel@edumazet-laptop>
	 <1271525519.3929.3.camel@bigi>
	 <1271583573.16881.4798.camel@edumazet-laptop>
	 <1271590476.16881.4925.camel@edumazet-laptop>
	 <1271764941.3735.94.camel@bigi> <1271769195.7895.4.camel@edumazet-laptop>
	 <1271853570.4032.21.camel@bigi>
	 <1271876480.7895.3106.camel@edumazet-laptop>
	 <1271938343.4032.30.camel@bigi>
	 <t2r412e6f7f1004241931ie9e70e3aka77b49557a7872e3@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, robert@herjulf.net, andi@firstfloor.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35924 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751052Ab0DZLfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 07:35:16 -0400
Received: by vws17 with SMTP id 17so1301036vws.19
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 04:35:15 -0700 (PDT)
In-Reply-To: <t2r412e6f7f1004241931ie9e70e3aka77b49557a7872e3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-04-25 at 10:31 +0800, Changli Gao wrote:

> I read the code again, and find that we don't use spin_lock_irqsave(),
> and we use local_irq_save() and spin_lock() instead, so
> _raw_spin_lock_irqsave() and _raw_spin_lock_irqrestore() should not be
> related to backlog. the lock maybe sk_receive_queue.lock.

Possible.
I am wondering if there's a way we can precisely nail where that is
happening? is lockstat any use? 
Fixing _raw_spin_lock_irqsave and friend is the lowest hanging fruit.

So looking at your patch now i see it is likely there was an improvement
made for non-rps case (moving out of loop some irq_enable etc).
i.e my results may not be crazy after adding your patch and seeing an
improvement for non-rps case.
However, whatever your patch did - it did not help the rps case case:
call_function_single_interrupt() comes out higher in the profile,
and # of IPIs seems to have gone up (although i did not measure this, I
can see the interrupts/second went up by almost 50-60%)

> Jamal, did you use a single socket to serve all the clients?

Socket per detected cpu.

> BTW:  completion_queue and output_queue in softnet_data both are LIFO
> queues. For completion_queue, FIFO is better, as the last used skb is
> more likely in cache, and should be used first. Since slab has always
> cache the last used memory at the head, we'd better free the skb in
> FIFO manner. For output_queue, FIFO is good for fairness among qdiscs.

I think it will depend on how many of those skbs are sitting in the
completion queue, cache warmth etc. LIFO is always safest, you have
higher probability of finding a cached skb infront.

cheers,
jamal

