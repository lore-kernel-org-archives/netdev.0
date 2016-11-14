From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 2/2] ptr_ring_ll: pop/push multiple objects at once
Date: Tue, 15 Nov 2016 01:06:46 +0200
Message-ID: <20161115010140-mutt-send-email-mst@kernel.org>
References: <20161111043857.1547.70337.stgit@john-Precision-Tower-5810>
 <20161111044432.1547.65342.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161111044432.1547.65342.stgit@john-Precision-Tower-5810>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 10, 2016 at 08:44:32PM -0800, John Fastabend wrote:
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

This will naturally reduce the cache line bounce
costs, but so will a _many API for ptr-ring,
doing lock-add many-unlock.

the number of atomics also scales better with the lock:
one per push instead of one per queue.

Also, when can qdisc use a _many operation?


> ---
>  include/linux/ptr_ring_ll.h |   22 ++++++++++++++++------
>  include/linux/skb_array.h   |   11 +++++++++--
>  net/sched/sch_generic.c     |    2 +-
>  3 files changed, 26 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/ptr_ring_ll.h b/include/linux/ptr_ring_ll.h
> index bcb11f3..5dc25f7 100644
> --- a/include/linux/ptr_ring_ll.h
> +++ b/include/linux/ptr_ring_ll.h
> @@ -45,9 +45,10 @@ struct ptr_ring_ll {
>  /* Note: callers invoking this in a loop must use a compiler barrier,
>   * for example cpu_relax(). Callers must hold producer_lock.
>   */
> -static inline int __ptr_ring_ll_produce(struct ptr_ring_ll *r, void *ptr)
> +static inline int __ptr_ring_ll_produce_many(struct ptr_ring_ll *r,
> +					     void **ptr, int num)
>  {
> -	u32 ret, head, tail, next, slots, mask;
> +	u32 ret, head, tail, next, slots, mask, i;
>  
>  	do {
>  		head = READ_ONCE(r->prod_head);
> @@ -55,21 +56,30 @@ static inline int __ptr_ring_ll_produce(struct ptr_ring_ll *r, void *ptr)
>  		tail = READ_ONCE(r->cons_tail);
>  
>  		slots = mask + tail - head;
> -		if (slots < 1)
> +		if (slots < num)
> +			num = slots;
> +
> +		if (unlikely(!num))
>  			return -ENOMEM;
>  
> -		next = head + 1;
> +		next = head + num;
>  		ret = cmpxchg(&r->prod_head, head, next);
>  	} while (ret != head);
>  
> -	r->queue[head & mask] = ptr;
> +	for (i = 0; i < num; i++)
> +		r->queue[(head + i) & mask] = ptr[i];
>  	smp_wmb();
>  
>  	while (r->prod_tail != head)
>  		cpu_relax();
>  
>  	r->prod_tail = next;
> -	return 0;
> +	return num;
> +}
> +
> +static inline int __ptr_ring_ll_produce(struct ptr_ring_ll *r, void **ptr)
> +{
> +	return __ptr_ring_ll_produce_many(r, ptr, 1);
>  }
>  
>  static inline void *__ptr_ring_ll_consume(struct ptr_ring_ll *r)
> diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
> index 9b43dfd..de3c700 100644
> --- a/include/linux/skb_array.h
> +++ b/include/linux/skb_array.h
> @@ -48,9 +48,16 @@ static inline bool skb_array_full(struct skb_array *a)
>  	return ptr_ring_full(&a->ring);
>  }
>  
> -static inline int skb_array_ll_produce(struct skb_array_ll *a, struct sk_buff *skb)
> +static inline int skb_array_ll_produce_many(struct skb_array_ll *a,
> +					    struct sk_buff **skb, int num)
>  {
> -	return __ptr_ring_ll_produce(&a->ring, skb);
> +	return __ptr_ring_ll_produce_many(&a->ring, (void **)skb, num);
> +}
> +
> +static inline int skb_array_ll_produce(struct skb_array_ll *a,
> +				       struct sk_buff **skb)
> +{
> +	return __ptr_ring_ll_produce(&a->ring, (void **)skb);
>  }
>  
>  static inline int skb_array_produce(struct skb_array *a, struct sk_buff *skb)
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 4648ec8..58f2011 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -571,7 +571,7 @@ static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
>  	struct skb_array_ll *q = band2list(priv, band);
>  	int err;
>  
> -	err = skb_array_ll_produce(q, skb);
> +	err = skb_array_ll_produce(q, &skb);
>  
>  	if (unlikely(err)) {
>  		net_warn_ratelimited("drop a packet from fast enqueue\n");

I don't see a pop many operation here.

-- 
MST
