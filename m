From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 1/2] net: use cmpxchg instead of spinlock in ptr rings
Date: Tue, 15 Nov 2016 20:37:20 -0800
Message-ID: <582BE280.7030306@gmail.com>
References: <20161115143258.2c46fc9a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36617 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932375AbcKPEhf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 23:37:35 -0500
Received: by mail-pg0-f65.google.com with SMTP id x23so13562113pgx.3
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 20:37:35 -0800 (PST)
In-Reply-To: <20161115143258.2c46fc9a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-15 05:32 AM, Jesper Dangaard Brouer wrote:
> 
> (looks like my message didn't reach the netdev list, due to me sending
> from the wrong email, forwarded message again):
> 
> On Thu, 10 Nov 2016 20:44:08 -0800 John Fastabend <john.fastabend@gmail.com> wrote:
> 
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
> [...]
>> + *
>> + *	This is a limited-size FIFO maintaining pointers in FIFO order, with
>> + *	one CPU producing entries and another consuming entries from a FIFO.
>> + *	extended from ptr_ring_ll to use cmpxchg over spin lock.  
> 
> It sounds like this is Single Producer Single Consumer (SPSC)
> implementation, but your implementation actually is Multi Producer
> Multi Consumer (MPMC) capable.

Correct qdisc requires a MPMC to handle all the OOO cases.

> 
> The implementation looks a lot like my alf_queue[1] implementation:
>  [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/include/linux/alf_queue.h
> 

Sure, I was using that implementation originally.

> If the primary use-case is one CPU producing and another consuming,
> then the normal ptr_ring (skb_array) will actually be faster!
> 
> The reason is ptr_ring avoids bouncing a cache-line between the CPUs on
> every ring access.  This is achieved by having the checks for full
> (__ptr_ring_full) and empty (__ptr_ring_empty) use the contents of the
> array (NULL value).
> 
> I actually implemented two micro-benchmarks to measure the difference
> between skb_array[2] and alf_queue[3]:
>  [2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/skb_array_parallel01.c
>  [3] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/alf_queue_parallel01.c
> 

But :) this doesn't jive with my experiments where this implementation
was actually giving better numbers with pktgen over pfifo_fast even in
the SPSC case. I'll rerun metrics later this week its possible there was
some other issue causing the difference I guess.

As I noted in Michael's email though really I need to fix a bug in my
qdisc code and submit it before I worry too much about this
optimization.

> 
>> + */
>> +
>> +#ifndef _LINUX_PTR_RING_LL_H
>> +#define _LINUX_PTR_RING_LL_H 1
>> +  
> [...]
>> +
>> +struct ptr_ring_ll {
>> +	u32 prod_size;
>> +	u32 prod_mask;
>> +	u32 prod_head;
>> +	u32 prod_tail;
>> +	u32 cons_size;
>> +	u32 cons_mask;
>> +	u32 cons_head;
>> +	u32 cons_tail;
>> +
>> +	void **queue;
>> +};  
> 
> Your implementation doesn't even split the consumer and producer into
> different cachelines (which in practice doesn't help much due to how
> the empty/full checks are performed).

Its was just a implementation to get the qdisc patches off the ground. I
expected to follow up with patches to optimize the implementation.


[...]

>> +static inline int ptr_ring_ll_init(struct ptr_ring_ll *r, int size, gfp_t gfp)
>> +{
>> +	r->queue = __ptr_ring_init_queue_alloc(size, gfp);
>> +	if (!r->queue)
>> +		return -ENOMEM;
>> +
>> +	r->prod_size = r->cons_size = size;
>> +	r->prod_mask = r->cons_mask = size - 1;  
> 
> Shouldn't we have some check like is_power_of_2(size), as this code
> looks like it depend on this.
> 

Sure it is required. I was just ensuring callers do it correctly.

>> +	r->prod_tail = r->prod_head = 0;
>> +	r->cons_tail = r->prod_tail = 0;
>> +
>> +	return 0;
>> +}
>> +  

[...]

>>  
>> +static inline struct sk_buff *skb_array_ll_consume(struct skb_array_ll *a)
>> +{
>> +	return __ptr_ring_ll_consume(&a->ring);
>> +}
>> +  
> 
> Note in the Multi Producer Multi Consumer (MPMC) use-case this type of
> queue can be faster than normal ptr_ring.  And in patch2 you implement
> bulking, which is where the real benefit shows (in the MPMC case) for
> this kind of queue.
> 
> What I would really like to see is a lock-free (locked cmpxchg) queue
> implementation, what like ptr_ring use the array as empty/full check,
> and still (somehow) support bulking.
> 

OK perhaps worth experimenting with after if I can _finally_ get the
qdisc series in.

.John
