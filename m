From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 01/12] lib: array based lock free queue
Date: Wed, 13 Jan 2016 20:28:07 +0100
Message-ID: <20160113202807.2fe90c1a@redhat.com>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
	<20151230175103.26257.75334.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, davem@davemloft.net,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33515 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753543AbcAMT2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2016 14:28:14 -0500
In-Reply-To: <20151230175103.26257.75334.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 30 Dec 2015 09:51:03 -0800 John Fastabend <john.fastabend@gmail.com> wrote:

> Initial implementation of an array based lock free queue. This works
> is originally done by Jesper Dangaard Brouer and I've grabbed it made
> only minor tweaks at the moment and plan to use it with the 'tc'
> subsystem although it is general enough to be used elsewhere.

First thanks for using my work. P.s. Hannes also deserves some credit
developing this queue.  And Alex Duyck helped review it (and found some
bugs ;-))

A question about the qdisc usage context: It is guaranteed that qdisc
enqueue and dequeue always runs either 1) in softirq context or 2) with
softirq/BH disabled?

This is important because (as noted in a comment), alf_queue is:

 Not preemption safe. Multiple CPUs can enqueue elements, but the
 same CPU is not allowed to be preempted and access the same
 queue. Due to how the tail is updated, this can result in a soft
 lock-up


> Certainly this implementation can be furthered optimized and improved
> but it is a good base implementation.

Agreed. E.g. the helpers you choose for enqueue/dequeue (store/load)
might not be the best, they look optimal (loop unroll etc) but the
extra icache usage cancel out the performance gain. At least in my
qmempool testing.
 But lets not get into these details now, as you say it is a good base
implementation. 


> diff --git a/include/linux/alf_queue.h b/include/linux/alf_queue.h
> new file mode 100644
> index 0000000..dac304e
> --- /dev/null
> +++ b/include/linux/alf_queue.h
> @@ -0,0 +1,368 @@
[...]
> +
> +/* Main Multi-Producer ENQUEUE
> + *
[...]
> + *
> + * Not preemption safe. Multiple CPUs can enqueue elements, but the
> + * same CPU is not allowed to be preempted and access the same
> + * queue. Due to how the tail is updated, this can result in a soft
> + * lock-up. (Same goes for alf_mc_dequeue).
> + */
> +static inline int
> +alf_mp_enqueue(const u32 n;
> +	       struct alf_queue *q, void *ptr[n], const u32 n)
> +{
> +	u32 p_head, p_next, c_tail, space;
> +
> +	/* Reserve part of the array for enqueue STORE/WRITE */
> +	do {
> +		p_head = ACCESS_ONCE(q->producer.head);
> +		c_tail = ACCESS_ONCE(q->consumer.tail);/* as smp_load_aquire */
> +
> +		space = q->size + c_tail - p_head;
> +		if (n > space)
> +			return 0;
> +
> +		p_next = p_head + n;
> +	}
> +	while (unlikely(cmpxchg(&q->producer.head, p_head, p_next) != p_head));
> +
> +	/* The memory barrier of smp_load_acquire(&q->consumer.tail)
> +	 * is satisfied by cmpxchg implicit full memory barrier
> +	 */
> +
> +	/* STORE the elems into the queue array */
> +	__helper_alf_enqueue_store(p_head, q, ptr, n);
> +	smp_wmb(); /* Write-Memory-Barrier matching dequeue LOADs */
> +
> +	/* Wait for other concurrent preceding enqueues not yet done,
> +	 * this part make us none-wait-free and could be problematic
> +	 * in case of congestion with many CPUs
> +	 */
> +	while (unlikely(ACCESS_ONCE(q->producer.tail) != p_head))
> +		cpu_relax();
> +	/* Mark this enq done and avail for consumption */
> +	ACCESS_ONCE(q->producer.tail) = p_next;
> +
> +	return n;
> +}

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
