From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 1/2] net: use cmpxchg instead of spinlock in ptr rings
Date: Tue, 15 Nov 2016 20:30:09 -0800
Message-ID: <582BE0D1.3020007@gmail.com>
References: <20161111043857.1547.70337.stgit@john-Precision-Tower-5810>
 <20161111044408.1547.92737.stgit@john-Precision-Tower-5810>
 <20161115002552-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161115002552-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16-11-14 03:01 PM, Michael S. Tsirkin wrote:
> On Thu, Nov 10, 2016 at 08:44:08PM -0800, John Fastabend wrote:
>>
>> ---
>>  include/linux/ptr_ring_ll.h |  136 +++++++++++++++++++++++++++++++++++++++++++
>>  include/linux/skb_array.h   |   25 ++++++++
>>  2 files changed, 161 insertions(+)
>>  create mode 100644 include/linux/ptr_ring_ll.h
>>
>> diff --git a/include/linux/ptr_ring_ll.h b/include/linux/ptr_ring_ll.h
>> new file mode 100644
>> index 0000000..bcb11f3
>> --- /dev/null
>> +++ b/include/linux/ptr_ring_ll.h
>> @@ -0,0 +1,136 @@
>> +/*
>> + *	Definitions for the 'struct ptr_ring_ll' datastructure.
>> + *
>> + *	Author:
>> + *		John Fastabend <john.r.fastabend@intel.com>
>> + *
>> + *	Copyright (C) 2016 Intel Corp.
>> + *
>> + *	This program is free software; you can redistribute it and/or modify it
>> + *	under the terms of the GNU General Public License as published by the
>> + *	Free Software Foundation; either version 2 of the License, or (at your
>> + *	option) any later version.
>> + *
>> + *	This is a limited-size FIFO maintaining pointers in FIFO order, with
>> + *	one CPU producing entries and another consuming entries from a FIFO.
>> + *	extended from ptr_ring_ll to use cmpxchg over spin lock.
> 
> So when is each one (ptr-ring/ptr-ring-ll) a win? _ll suffix seems to
> imply this gives a better latency, OTOH for a ping/pong I suspect
> ptr-ring would be better as it avoids index cache line bounces.

My observation under qdisc testing with pktgen is that I get better pps
numbers with this code vs ptr_ring using spinlock. I actually wrote
this implementation before the skb_array code was around though and
haven't done a thorough analysis of the two yet only pktgen benchmarks.

In my pktgen benchmarks I test 1:1 producer/consumer and many to one
producer/consumer tests. I'll post some numbers later this week.

[...]

>> + */
>> +static inline int __ptr_ring_ll_produce(struct ptr_ring_ll *r, void *ptr)
>> +{
>> +	u32 ret, head, tail, next, slots, mask;
>> +
>> +	do {
>> +		head = READ_ONCE(r->prod_head);
>> +		mask = READ_ONCE(r->prod_mask);
>> +		tail = READ_ONCE(r->cons_tail);
>> +
>> +		slots = mask + tail - head;
>> +		if (slots < 1)
>> +			return -ENOMEM;
>> +
>> +		next = head + 1;
>> +		ret = cmpxchg(&r->prod_head, head, next);
>> +	} while (ret != head);
> 
> 
> So why is this preferable to a lock?
> 
> I suspect it's nothing else than the qspinlock fairness
> and polling code complexity. It's all not very useful if you
> 1. are just doing a couple of instructions under the lock
> and
> 2. use a finite FIFO which is unfair anyway
> 
> 
> How about this hack (lifted from virt_spin_lock):
> 
> static inline void quick_spin_lock(struct qspinlock *lock)
> {
>         do {
>                 while (atomic_read(&lock->val) != 0)
>                         cpu_relax();
>         } while (atomic_cmpxchg(&lock->val, 0, _Q_LOCKED_VAL) != 0);
> }
> 
> Or maybe we should even drop the atomic_read in the middle -
> worth profiling and comparing:
> 
> static inline void quick_spin_lock(struct qspinlock *lock)
> {
>         while (atomic_cmpxchg(&lock->val, 0, _Q_LOCKED_VAL) != 0)
> 		cpu_relax();
> }
> 
> 
> Then, use quick_spin_lock instead of spin_lock everywhere in
> ptr_ring - will that make it more efficient?
> 

I think this could be the case. I'll give it a test later this week I
am working on the xdp bits for virtio at the moment. To be honest though
for my qdisc patchset first I need to resolve a bug and then probably in
the first set just use the existing skb_array implementation. Its fun
to micro-optimize this stuff but really any implementation will show
improvement over existing code.

Thanks,
John
