From: Jesper Dangaard Brouer <netdev@brouer.com>
Subject: Re: [RFC PATCH 1/2] net: use cmpxchg instead of spinlock in ptr
 rings
Date: Mon, 14 Nov 2016 12:09:58 +0100
Message-ID: <20161114120958.5f22e50a@brouer.com>
References: <20161111043857.1547.70337.stgit@john-Precision-Tower-5810>
        <20161111044408.1547.92737.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:36794 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934338AbcKNLKC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 06:10:02 -0500
Received: by mail-lf0-f65.google.com with SMTP id o20so6686957lfg.3
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 03:10:01 -0800 (PST)
In-Reply-To: <20161111044408.1547.92737.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 10 Nov 2016 20:44:08 -0800 John Fastabend <john.fastabend@gmail.com> wrote:

> ---
>  include/linux/ptr_ring_ll.h |  136 +++++++++++++++++++++++++++++++++++++++++++
>  include/linux/skb_array.h   |   25 ++++++++
>  2 files changed, 161 insertions(+)
>  create mode 100644 include/linux/ptr_ring_ll.h
> 
> diff --git a/include/linux/ptr_ring_ll.h b/include/linux/ptr_ring_ll.h
> new file mode 100644
> index 0000000..bcb11f3
> --- /dev/null
> +++ b/include/linux/ptr_ring_ll.h
> @@ -0,0 +1,136 @@
> +/*
> + *	Definitions for the 'struct ptr_ring_ll' datastructure.
> + *
> + *	Author:
> + *		John Fastabend <john.r.fastabend@intel.com>
[...]
> + *
> + *	This is a limited-size FIFO maintaining pointers in FIFO order, with
> + *	one CPU producing entries and another consuming entries from a FIFO.
> + *	extended from ptr_ring_ll to use cmpxchg over spin lock.

It sounds like this is Single Producer Single Consumer (SPSC)
implementation, but your implementation actually is Multi Producer
Multi Consumer (MPMC) capable.

The implementation looks a lot like my alf_queue[1] implementation:
 [1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/include/linux/alf_queue.h

If the primary use-case is one CPU producing and another consuming,
then the normal ptr_ring (skb_array) will actually be faster!

The reason is ptr_ring avoids bouncing a cache-line between the CPUs on
every ring access.  This is achieved by having the checks for full
(__ptr_ring_full) and empty (__ptr_ring_empty) use the contents of the
array (NULL value).

I actually implemented two micro-benchmarks to measure the difference
between skb_array[2] and alf_queue[3]:
 [2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/skb_array_parallel01.c
 [3] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/alf_queue_parallel01.c


> + */
> +
> +#ifndef _LINUX_PTR_RING_LL_H
> +#define _LINUX_PTR_RING_LL_H 1
> +
[...]
> +
> +struct ptr_ring_ll {
> +	u32 prod_size;
> +	u32 prod_mask;
> +	u32 prod_head;
> +	u32 prod_tail;
> +	u32 cons_size;
> +	u32 cons_mask;
> +	u32 cons_head;
> +	u32 cons_tail;
> +
> +	void **queue;
> +};

Your implementation doesn't even split the consumer and producer into
different cachelines (which in practice doesn't help much due to how
the empty/full checks are performed).

> +
> +/* Note: callers invoking this in a loop must use a compiler barrier,
> + * for example cpu_relax(). Callers must hold producer_lock.
> + */
> +static inline int __ptr_ring_ll_produce(struct ptr_ring_ll *r, void *ptr)
> +{
> +	u32 ret, head, tail, next, slots, mask;
> +
> +	do {
> +		head = READ_ONCE(r->prod_head);
> +		mask = READ_ONCE(r->prod_mask);
> +		tail = READ_ONCE(r->cons_tail);

Problem occur here, as the producer need to access/read the consumers
tail, to determine if the queue is not already full (slots avail).
Thus, the next "consumer-CPU" will see the cacheline in wrong state
(Modified/Invalid or Shared).

> +
> +		slots = mask + tail - head;
> +		if (slots < 1)
> +			return -ENOMEM;
> +
> +		next = head + 1;
> +		ret = cmpxchg(&r->prod_head, head, next);
> +	} while (ret != head);
> +
> +	r->queue[head & mask] = ptr;
> +	smp_wmb();
> +
> +	while (r->prod_tail != head)
> +		cpu_relax();
> +
> +	r->prod_tail = next;
> +	return 0;
> +}
> +
> +static inline void *__ptr_ring_ll_consume(struct ptr_ring_ll *r)
> +{
> +	u32 ret, head, tail, next, slots, mask;
> +	void *ptr;
> +
> +	do {
> +		head = READ_ONCE(r->cons_head);
> +		mask = READ_ONCE(r->cons_mask);
> +		tail = READ_ONCE(r->prod_tail);

Like wise the consumer is reading the producer tail (for the empty check).

> +
> +		slots = tail - head;
> +		if (slots < 1)
> +			return ERR_PTR(-ENOMEM);
> +
> +		next = head + 1;
> +		ret = cmpxchg(&r->cons_head, head, next);
> +	} while (ret != head);
> +
> +	ptr = r->queue[head & mask];
> +	smp_rmb();
> +
> +	while (r->cons_tail != head)
> +		cpu_relax();
> +
> +	r->cons_tail = next;
> +	return ptr;
> +}
> +
> +static inline void **__ptr_ring_ll_init_queue_alloc(int size, gfp_t gfp)
> +{
> +	return kzalloc(ALIGN(size * sizeof(void *), SMP_CACHE_BYTES), gfp);
> +}
> +
> +static inline int ptr_ring_ll_init(struct ptr_ring_ll *r, int size, gfp_t gfp)
> +{
> +	r->queue = __ptr_ring_init_queue_alloc(size, gfp);
> +	if (!r->queue)
> +		return -ENOMEM;
> +
> +	r->prod_size = r->cons_size = size;
> +	r->prod_mask = r->cons_mask = size - 1;

Shouldn't we have some check like is_power_of_2(size), as this code
looks like it depend on this.

> +	r->prod_tail = r->prod_head = 0;
> +	r->cons_tail = r->prod_tail = 0;
> +
> +	return 0;
> +}
> +
[...]
> +#endif /* _LINUX_PTR_RING_LL_H  */
> diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
> index f4dfade..9b43dfd 100644
> --- a/include/linux/skb_array.h
> +++ b/include/linux/skb_array.h
[...]
>  
> +static inline int skb_array_ll_produce(struct skb_array_ll *a, struct sk_buff *skb)
> +{
> +	return __ptr_ring_ll_produce(&a->ring, skb);
> +}
> +
[...]
>  
> +static inline struct sk_buff *skb_array_ll_consume(struct skb_array_ll *a)
> +{
> +	return __ptr_ring_ll_consume(&a->ring);
> +}
> +

Note in the Multi Producer Multi Consumer (MPMC) use-case this type of
queue can be faster than normal ptr_ring.  And in patch2 you implement
bulking, which is where the real benefit shows (in the MPMC case) for
this kind of queue.

What I would really like to see is a lock-free (locked cmpxchg) queue
implementation, what like ptr_ring use the array as empty/full check,
and still (somehow) support bulking.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
