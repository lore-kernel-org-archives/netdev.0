From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 0/4] net_sched: bulk dequeue and deferred drops
Date: Wed, 22 Jun 2016 17:44:41 +0200
Message-ID: <20160622174441.559023b9@redhat.com>
References: <1466576212-15012-1-git-send-email-edumazet@google.com>
	<20160622164736.0ab98e6b@redhat.com>
	<1466607343.6850.37.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>, brouer@redhat.com,
	Luigi Rizzo <rizzo@iet.unipi.it>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752187AbcFVPos (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 11:44:48 -0400
In-Reply-To: <1466607343.6850.37.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Jun 2016 07:55:43 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2016-06-22 at 16:47 +0200, Jesper Dangaard Brouer wrote:
> > On Tue, 21 Jun 2016 23:16:48 -0700
> > Eric Dumazet <edumazet@google.com> wrote:
> >   
> > > First patch adds an additional parameter to ->enqueue() qdisc method
> > > so that drops can be done outside of critical section
> > > (after locks are released).
> > > 
> > > Then fq_codel can have a small optimization to reduce number of cache
> > > lines misses during a drop event
> > > (possibly accumulating hundreds of packets to be freed).
> > > 
> > > A small htb change exports the backlog in class dumps.
> > > 
> > > Final patch adds bulk dequeue to qdiscs that were lacking this feature.
> > > 
> > > This series brings a nice qdisc performance increase (more than 80 %
> > > in some cases).  
> > 
> > Thanks for working on this Eric! this is great work! :-)  
> 
> Thanks Jesper
> 
> I worked yesterday on bulk enqueues, but initial results are not that
> great.

Hi Eric,

This is interesting work! But I think you should read Luigi Rizzo's
(Cc'ed) paper on title "A Fast and Practical Software Packet Scheduling
Architecture"[1]

[1] http://info.iet.unipi.it/~luigi/papers/20160511-mysched-preprint.pdf

Luigi will be at Netfilter Workshop next week, and will actually
present on topic/paper.... you two should talk ;-)

The article is not a 100% match for what we need, but there is some
good ideas.  The article also have a sort of "prequeue" that
enqueue'ing CPUs will place packets into.

My understanding of the article:

1. transmitters submit packets to an intermediate queue
   (replace q->enqueue call) lockless submit as queue per CPU
   (runs in parallel)

2. like we only have _one_ qdisc dequeue process, this process (called
   arbiter) empty the intermediate queues, and then invoke q->enqueue()
   and q->dequeue(). (in a locked session/region)

3. Packets returned from q->dequeue() is placed on an outgoing
   intermediate queue.

4. the transmitter then looks to see there are any packets to drain()
   from the outgoing queue.  This can run in parallel.

If the transmitter submitting a packet, detect no arbiter is running,
it can become the arbiter itself.  Like we do with qdisc_run_begin()
setting state __QDISC___STATE_RUNNING.

The problem with this scheme is push-back from qdisc->enqueue
(NET_XMIT_CN) does not "reach" us.  And push-back in-form of processes
blocking on qdisc root lock, but that could be handled by either
blocking in article's submit() or returning some congestion return code
from submit(). 


(left patch intact below for Luigi to see)

> Here is my current patch, on top of my last series :
> 
> (A second patch would remove the busylock spinlock, of course)
> 
>  include/net/sch_generic.h |    9 ++
>  net/core/dev.c            |  135 ++++++++++++++++++++++++++++--------
>  2 files changed, 115 insertions(+), 29 deletions(-)
> 
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index 909aff2db2b3..1975a6fab10f 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -87,7 +87,14 @@ struct Qdisc {
>  	int			padded;
>  	atomic_t		refcnt;
>  
> -	spinlock_t		busylock ____cacheline_aligned_in_smp;
> +	spinlock_t		busylock;
> +
> +#ifdef CONFIG_SMP
> +	struct pcpu_skb_context *prequeue0 ____cacheline_aligned_in_smp;
> +#ifdef CONFIG_NUMA
> +	struct pcpu_skb_context *prequeue1 ____cacheline_aligned_in_smp;
> +#endif
> +#endif
>  };
>  
>  static inline bool qdisc_is_running(const struct Qdisc *qdisc)
> diff --git a/net/core/dev.c b/net/core/dev.c
> index aba10d2a8bc3..5f0d3fe5b109 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3065,26 +3065,117 @@ static void qdisc_pkt_len_init(struct sk_buff *skb)
>  	}
>  }
>  
> -static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
> -				 struct net_device *dev,
> -				 struct netdev_queue *txq)
> +
> +#ifdef CONFIG_SMP
> +
> +struct pcpu_skb_context {
> +	struct pcpu_skb_context		*next;
> +	union {
> +		struct sk_buff		*skb;
> +		unsigned long		status;
> +		struct pcpu_skb_context	*self;
> +	};
> +};
> +static DEFINE_PER_CPU_ALIGNED(struct pcpu_skb_context, pcpu_skb_context);
> +
> +/* Provides a small queue before qdisc so that we can batch ->enqueue()
> + * under SMP stress.
> + */
> +static noinline int dev_xmit_skb_slow(struct sk_buff *skb, struct Qdisc *q,
> +				      struct pcpu_skb_context **prequeue)
> +{
> +	struct pcpu_skb_context *prev, *myptr;
> +	struct sk_buff *to_free = NULL;
> +	spinlock_t *root_lock;
> +	void *status;
> +	int i, rc;
> +
> +	myptr = this_cpu_ptr(&pcpu_skb_context);
> +	myptr->skb = skb;
> +	myptr->next = NULL;
> +
> +	/* Take our ticket in prequeue file, a la MCS lock */
> +	prev = xchg(prequeue, myptr);
> +	if (prev) {
> +		/* Ok, another cpu got the lock and serves the prequeue.
> +		 * Wait that it either processed our skb or it exhausted
> +		 * its budget and told us to process a batch ourself.
> +		 */
> +		WRITE_ONCE(prev->next, myptr);
> +
> +		while ((status = READ_ONCE(myptr->skb)) == skb)
> +			cpu_relax_lowlatency();
> +
> +		/* Nice ! Our skb was handled by another cpu */
> +		if ((unsigned long)status < NET_XMIT_MASK)
> +			return (int)(unsigned long)status;
> +
> +		/* Oh well, we got the responsability of next batch */
> +		BUG_ON(myptr != status);
> +	}
> +	root_lock = qdisc_lock(q);
> +	spin_lock(root_lock);
> +
> +	for (i = 0; i < 16; i++) {
> +		bool may_release = true;
> +
> +		if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> +			__qdisc_drop(skb, &to_free);
> +			rc = NET_XMIT_DROP;
> +		} else {
> +			rc = q->enqueue(skb, q, &to_free) & NET_XMIT_MASK;
> +		}
> +		while (!(prev = READ_ONCE(myptr->next))) {
> +			if (may_release) {
> +				if (cmpxchg_release(prequeue, myptr, NULL) == myptr)
> +					break;
> +				may_release = false;
> +			}
> +			cpu_relax_lowlatency();
> +		}
> +		smp_store_release(&myptr->status, (unsigned long)rc);
> +		myptr = prev;
> +		if (!myptr)
> +			break;
> +		skb = READ_ONCE(myptr->skb);
> +	}
> +
> +	qdisc_run(q);
> +	spin_unlock(root_lock);
> +
> +	/* Give control to another cpu for following batch */
> +	if (myptr)
> +		smp_store_release(&myptr->self, myptr);
> +
> +	if (unlikely(to_free))
> +		kfree_skb_list(to_free);
> +
> +	return (int)this_cpu_read(pcpu_skb_context.status);
> +}
> +#endif
> +
> +static int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
> +			  struct net_device *dev,
> +			  struct netdev_queue *txq)
>  {
>  	spinlock_t *root_lock = qdisc_lock(q);
>  	struct sk_buff *to_free = NULL;
> -	bool contended;
>  	int rc;
>  
>  	qdisc_calculate_pkt_len(skb, q);
> -	/*
> -	 * Heuristic to force contended enqueues to serialize on a
> -	 * separate lock before trying to get qdisc main lock.
> -	 * This permits qdisc->running owner to get the lock more
> -	 * often and dequeue packets faster.
> -	 */
> -	contended = qdisc_is_running(q);
> -	if (unlikely(contended))
> -		spin_lock(&q->busylock);
>  
> +#ifdef CONFIG_SMP
> +	{
> +	struct pcpu_skb_context **prequeue = &q->prequeue0;
> +
> +#ifdef CONFIG_NUMA
> +	if (numa_node_id() & 1)
> +		prequeue = &q->prequeue1;
> +#endif
> +	if (unlikely(*prequeue || qdisc_is_running(q)))
> +		return dev_xmit_skb_slow(skb, q, prequeue);
> +	}
> +#endif
>  	spin_lock(root_lock);
>  	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
>  		__qdisc_drop(skb, &to_free);
> @@ -3099,31 +3190,19 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>  
>  		qdisc_bstats_update(q, skb);
>  
> -		if (sch_direct_xmit(skb, q, dev, txq, root_lock, true)) {
> -			if (unlikely(contended)) {
> -				spin_unlock(&q->busylock);
> -				contended = false;
> -			}
> +		if (sch_direct_xmit(skb, q, dev, txq, root_lock, true))
>  			__qdisc_run(q);
> -		} else
> +		else
>  			qdisc_run_end(q);
>  
>  		rc = NET_XMIT_SUCCESS;
>  	} else {
>  		rc = q->enqueue(skb, q, &to_free) & NET_XMIT_MASK;
> -		if (qdisc_run_begin(q)) {
> -			if (unlikely(contended)) {
> -				spin_unlock(&q->busylock);
> -				contended = false;
> -			}
> -			__qdisc_run(q);
> -		}
> +		qdisc_run(q);
>  	}
>  	spin_unlock(root_lock);
>  	if (unlikely(to_free))
>  		kfree_skb_list(to_free);
> -	if (unlikely(contended))
> -		spin_unlock(&q->busylock);
>  	return rc;
>  }
>  
> 
> 
> 
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
