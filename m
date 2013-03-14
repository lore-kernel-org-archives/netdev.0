From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: RFC crap-patch [PATCH] net: Per CPU separate frag mem accounting
Date: Thu, 14 Mar 2013 08:25:55 +0100
Message-ID: <1363245955.14913.21.camel@localhost>
References: <20130308221647.5312.33631.stgit@dragon>
	 <20130308221744.5312.14924.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8582 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945Ab3CNH0B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Mar 2013 03:26:01 -0400
In-Reply-To: <20130308221744.5312.14924.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


His is NOT the patch I just mentioned in the other thread, of removing
the LRU list.  This patch does real per cpu mem acct, and LRU per CPU.

I get really good performance number with this patch, but I still think
this might not be the correct solution.

My current best results, which got applied recently, compared to this
patch:
 - Test-type:  Test-20G64K    Test-20G3F  20G64K+DoS   20G3F+DoS
 - Patch-06:   18486.7 Mbit/s  10723.20     3657.85     4560.64 Mbit/s
 - curr-best:  19041.0 Mbit/s  12105.20    10160.40    11179.30 Mbit/s

Thus, I have almost solved DoS effect Test-20G3F 12GBit/s -> 11Gbit/s
under DoS. The 64K+DoS case is not perfect yet, 19Gbit/s -> 11 Gbit/s.

--Jesper


On Fri, 2013-03-08 at 23:17 +0100, Jesper Dangaard Brouer wrote:
> ... testing if the percpu_counter does not scale in DoS situations
> ---
> 
>  include/net/inet_frag.h                 |   99 ++++++++++++++++++-------------
>  net/ipv4/inet_fragment.c                |   61 +++++++++++++++----
>  net/ipv4/ip_fragment.c                  |    3 +
>  net/ipv6/netfilter/nf_conntrack_reasm.c |    2 -
>  net/ipv6/reassembly.c                   |    2 -
>  5 files changed, 110 insertions(+), 57 deletions(-)
> 
> diff --git a/include/net/inet_frag.h b/include/net/inet_frag.h
> index f2b46a5..974434a 100644
> --- a/include/net/inet_frag.h
> +++ b/include/net/inet_frag.h
> @@ -1,22 +1,31 @@
>  #ifndef __NET_FRAG_H__
>  #define __NET_FRAG_H__
>  
> -#include <linux/percpu_counter.h>
> +//#include <linux/percpu_counter.h>
> +#include <linux/spinlock.h>
> +#include <linux/atomic.h>
> +#include <linux/percpu.h>
>  
> -struct netns_frags {
> -	int			nqueues;
> -	struct list_head	lru_list;
> -	spinlock_t		lru_lock;
> +/* Need to maintain these resource limits per CPU, else we will kill
> + * performance due to cache-line bouncing
> + */
> +struct frag_cpu_limit {
> +	atomic_t                mem;
> +	struct list_head        lru_list;
> +	spinlock_t              lru_lock;
> +} ____cacheline_aligned_in_smp;
>  
> -	/* The percpu_counter "mem" need to be cacheline aligned.
> -	 *  mem.count must not share cacheline with other writers
> -	 */
> -	struct percpu_counter   mem ____cacheline_aligned_in_smp;
> +struct netns_frags {
>  
>  	/* sysctls */
>  	int			timeout;
>  	int			high_thresh;
>  	int			low_thresh;
> +
> +	struct frag_cpu_limit __percpu *percpu;
> +
> +	// TODO move "nqueues" elsewere...
> +	int			nqueues ____cacheline_aligned_in_smp;
>  };
>  
>  struct inet_frag_queue {
> @@ -25,6 +34,7 @@ struct inet_frag_queue {
>  	struct list_head	lru_list;   /* lru list member */
>  	struct hlist_node	list;
>  	atomic_t		refcnt;
> +	u32			cpu_alloc;  /* used for mem limit accounting */
>  	struct sk_buff		*fragments; /* list of received fragments */
>  	struct sk_buff		*fragments_tail;
>  	ktime_t			stamp;
> @@ -80,7 +90,8 @@ void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f);
>  void inet_frag_kill(struct inet_frag_queue *q, struct inet_frags *f);
>  void inet_frag_destroy(struct inet_frag_queue *q,
>  				struct inet_frags *f, int *work);
> -int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force);
> +int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f,
> +		      bool force, int on_cpu);
>  struct inet_frag_queue *inet_frag_find(struct netns_frags *nf,
>  		struct inet_frags *f, void *key, unsigned int hash)
>  	__releases(&f->lock);
> @@ -93,59 +104,65 @@ static inline void inet_frag_put(struct inet_frag_queue *q, struct inet_frags *f
>  
>  /* Memory Tracking Functions. */
>  
> -/* The default percpu_counter batch size is not big enough to scale to
> - * fragmentation mem acct sizes.
> - * The mem size of a 64K fragment is approx:
> - *  (44 fragments * 2944 truesize) + frag_queue struct(200) = 129736 bytes
> - */
> -static unsigned int frag_percpu_counter_batch = 130000;
> -
> -static inline int frag_mem_limit(struct netns_frags *nf)
> -{
> -	return percpu_counter_read(&nf->mem);
> -}
> -
>  static inline void sub_frag_mem_limit(struct inet_frag_queue *q, int i)
>  {
> -	__percpu_counter_add(&q->net->mem, -i, frag_percpu_counter_batch);
> +	int cpu = q->cpu_alloc;
> +	struct frag_cpu_limit *percpu = per_cpu_ptr(q->net->percpu, cpu);
> +	atomic_sub(i, &percpu->mem);
>  }
>  
>  static inline void add_frag_mem_limit(struct inet_frag_queue *q, int i)
>  {
> -	__percpu_counter_add(&q->net->mem, i, frag_percpu_counter_batch);
> -}
> -
> -static inline void init_frag_mem_limit(struct netns_frags *nf)
> -{
> -	percpu_counter_init(&nf->mem, 0);
> +	int cpu = q->cpu_alloc;
> +	struct frag_cpu_limit *percpu = per_cpu_ptr(q->net->percpu, cpu);
> +	atomic_add(i, &percpu->mem);
>  }
>  
>  static inline int sum_frag_mem_limit(struct netns_frags *nf)
>  {
> -	return percpu_counter_sum_positive(&nf->mem);
> +	unsigned int sum = 0;
> +	int cpu;
> +
> +	for_each_possible_cpu(cpu) {
> +		struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
> +
> +		sum += atomic_read(&percpu->mem);
> +	}
> +	return sum;
>  }
>  
> +/* LRU (Least Recently Used) resource functions */
> +
>  static inline void inet_frag_lru_move(struct inet_frag_queue *q)
>  {
> -	spin_lock(&q->net->lru_lock);
> -	list_move_tail(&q->lru_list, &q->net->lru_list);
> -	spin_unlock(&q->net->lru_lock);
> +	int cpu = q->cpu_alloc;
> +	struct frag_cpu_limit *percpu = per_cpu_ptr(q->net->percpu, cpu);
> +
> +	spin_lock(&percpu->lru_lock);
> +	list_move_tail(&q->lru_list, &percpu->lru_list);
> +	spin_unlock(&percpu->lru_lock);
>  }
>  
>  static inline void inet_frag_lru_del(struct inet_frag_queue *q)
>  {
> -	spin_lock(&q->net->lru_lock);
> -	list_del(&q->lru_list);
> -	q->net->nqueues--;
> -	spin_unlock(&q->net->lru_lock);
> +	int cpu = q->cpu_alloc;
> +	struct frag_cpu_limit *percpu = per_cpu_ptr(q->net->percpu, cpu);
> +
> +	spin_lock(&percpu->lru_lock);
> + 	list_del(&q->lru_list);
> +	q->net->nqueues--; //FIXME
> +	spin_unlock(&percpu->lru_lock);
>  }
>  
>  static inline void inet_frag_lru_add(struct netns_frags *nf,
>  				     struct inet_frag_queue *q)
>  {
> -	spin_lock(&nf->lru_lock);
> -	list_add_tail(&q->lru_list, &nf->lru_list);
> -	q->net->nqueues++;
> -	spin_unlock(&nf->lru_lock);
> +	int cpu = q->cpu_alloc;
> +	struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
> +
> +	spin_lock(&percpu->lru_lock);
> +	list_add_tail(&q->lru_list, &percpu->lru_list);
> +	q->net->nqueues++; //FIXME
> +	spin_unlock(&percpu->lru_lock);
>  }
>  #endif
> diff --git a/net/ipv4/inet_fragment.c b/net/ipv4/inet_fragment.c
> index e5c426f..f09fa7e 100644
> --- a/net/ipv4/inet_fragment.c
> +++ b/net/ipv4/inet_fragment.c
> @@ -23,6 +23,18 @@
>  
>  #include <net/inet_frag.h>
>  
> +static inline int frag_mem_limit_on_cpu(struct netns_frags *nf, int on_cpu)
> +{
> +	struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, on_cpu);
> +	return atomic_read(&percpu->mem);
> +}
> +
> +static inline int frag_mem_limit(struct netns_frags *nf)
> +{
> +	int cpu = smp_processor_id();
> +	return frag_mem_limit_on_cpu(nf, cpu);
> +}
> +
>  static void inet_frag_secret_rebuild(unsigned long dummy)
>  {
>  	struct inet_frags *f = (struct inet_frags *)dummy;
> @@ -81,12 +93,28 @@ void inet_frags_init(struct inet_frags *f)
>  }
>  EXPORT_SYMBOL(inet_frags_init);
>  
> +static int inet_frags_init_percpu_limit(struct netns_frags *nf)
> +{
> +	int cpu;
> +
> +	nf->percpu = alloc_percpu(struct frag_cpu_limit);
> +	if (!nf->percpu)
> +		return -ENOMEM;
> +
> +	for_each_possible_cpu(cpu) {
> +		struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
> +
> +		INIT_LIST_HEAD(&percpu->lru_list);
> +		spin_lock_init(&percpu->lru_lock);
> +		atomic_set(&percpu->mem, 0);
> +	}
> +	return 1;
> +}
> +
>  void inet_frags_init_net(struct netns_frags *nf)
>  {
>  	nf->nqueues = 0; //remove?
> -	init_frag_mem_limit(nf);
> -	INIT_LIST_HEAD(&nf->lru_list);
> -	spin_lock_init(&nf->lru_lock);
> +	inet_frags_init_percpu_limit(nf);
>  }
>  EXPORT_SYMBOL(inet_frags_init_net);
>  
> @@ -98,13 +126,16 @@ EXPORT_SYMBOL(inet_frags_fini);
>  
>  void inet_frags_exit_net(struct netns_frags *nf, struct inet_frags *f)
>  {
> +	int cpu;
> +
>  	nf->low_thresh = 0;
>  
>  	local_bh_disable();
> -	inet_frag_evictor(nf, f, true);
> +	for_each_possible_cpu(cpu)
> +		inet_frag_evictor(nf, f, true, cpu);
>  	local_bh_enable();
>  
> -	percpu_counter_destroy(&nf->mem);
> +	free_percpu(nf->percpu);
>  }
>  EXPORT_SYMBOL(inet_frags_exit_net);
>  
> @@ -179,33 +210,36 @@ void inet_frag_destroy(struct inet_frag_queue *q, struct inet_frags *f,
>  }
>  EXPORT_SYMBOL(inet_frag_destroy);
>  
> -int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f, bool force)
> +int inet_frag_evictor(struct netns_frags *nf, struct inet_frags *f,
> +		      bool force, int on_cpu)
>  {
>  	struct inet_frag_queue *q;
>  	int work, evicted = 0;
> +	int cpu = (likely(on_cpu < 0)) ? smp_processor_id() : on_cpu;
> +	struct frag_cpu_limit *percpu = per_cpu_ptr(nf->percpu, cpu);
>  
>  	if (!force) {
> -		if (frag_mem_limit(nf) <= nf->high_thresh)
> +		if (frag_mem_limit_on_cpu(nf, cpu) <= nf->high_thresh)
>  			return 0;
>  	}
>  
> -	work = frag_mem_limit(nf) - nf->low_thresh;
> +	work = frag_mem_limit_on_cpu(nf, cpu) - nf->low_thresh;
>  	while (work > 0) {
> -		spin_lock(&nf->lru_lock);
> +		spin_lock(&percpu->lru_lock);
>  
> -		if (list_empty(&nf->lru_list)) {
> -			spin_unlock(&nf->lru_lock);
> +		if (list_empty(&percpu->lru_list)) {
> +			spin_unlock(&percpu->lru_lock);
>  			break;
>  		}
>  
> -		q = list_first_entry(&nf->lru_list,
> +		q = list_first_entry(&percpu->lru_list,
>  				struct inet_frag_queue, lru_list);
>  		atomic_inc(&q->refcnt);
>  
>  		// TEST: remove q from list to avoid more CPUs grabbing it
>  		list_del_init(&q->lru_list);
>  
> -		spin_unlock(&nf->lru_lock);
> +		spin_unlock(&percpu->lru_lock);
>  
>  		spin_lock(&q->lock);
>  		if (!(q->last_in & INET_FRAG_COMPLETE))
> @@ -283,6 +317,7 @@ static struct inet_frag_queue *inet_frag_alloc(struct netns_frags *nf,
>  		return NULL;
>  
>  	q->net = nf;
> +	q->cpu_alloc = (u32) smp_processor_id();
>  	f->constructor(q, arg);
>  	add_frag_mem_limit(q, f->qsize);
>  
> diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
> index 1211613..4241417 100644
> --- a/net/ipv4/ip_fragment.c
> +++ b/net/ipv4/ip_fragment.c
> @@ -18,6 +18,7 @@
>   *		John McDonald	:	0 length frag bug.
>   *		Alexey Kuznetsov:	SMP races, threading, cleanup.
>   *		Patrick McHardy :	LRU queue of frag heads for evictor.
> + *		Jesper Brouer   :	SMP/NUMA scalability
>   */
>  
>  #define pr_fmt(fmt) "IPv4: " fmt
> @@ -212,7 +213,7 @@ static void ip_evictor(struct net *net)
>  {
>  	int evicted;
>  
> -	evicted = inet_frag_evictor(&net->ipv4.frags, &ip4_frags, false);
> +	evicted = inet_frag_evictor(&net->ipv4.frags, &ip4_frags, false, -1);
>  	if (evicted)
>  		IP_ADD_STATS_BH(net, IPSTATS_MIB_REASMFAILS, evicted);
>  }
> diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
> index c674f15..37291f9 100644
> --- a/net/ipv6/netfilter/nf_conntrack_reasm.c
> +++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
> @@ -569,7 +569,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
>  	fhdr = (struct frag_hdr *)skb_transport_header(clone);
>  
>  	local_bh_disable();
> -	inet_frag_evictor(&net->nf_frag.frags, &nf_frags, false);
> +	inet_frag_evictor(&net->nf_frag.frags, &nf_frags, false, -1);
>  	local_bh_enable();
>  
>  	fq = fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->daddr);
> diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
> index bab2c27..d1e70dd 100644
> --- a/net/ipv6/reassembly.c
> +++ b/net/ipv6/reassembly.c
> @@ -529,7 +529,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
>  		return 1;
>  	}
>  
> -	evicted = inet_frag_evictor(&net->ipv6.frags, &ip6_frags, false);
> +	evicted = inet_frag_evictor(&net->ipv6.frags, &ip6_frags, false, -1);
>  	if (evicted)
>  		IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
>  				 IPSTATS_MIB_REASMFAILS, evicted);
> 
