From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 1/4] net_sched: drop packets after root qdisc
 lock is released
Date: Wed, 22 Jun 2016 17:14:37 +0200
Message-ID: <20160622171437.3f52d3a4@redhat.com>
References: <1466576212-15012-1-git-send-email-edumazet@google.com>
	<1466576212-15012-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56100 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750957AbcFVPOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 11:14:42 -0400
In-Reply-To: <1466576212-15012-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jun 2016 23:16:49 -0700
Eric Dumazet <edumazet@google.com> wrote:

> Qdisc performance suffers when packets are dropped at enqueue()
> time because drops (kfree_skb()) are done while qdisc lock is held,
> delaying a dequeue() draining the queue.
> 
> Nominal throughput can be reduced by 50 % when this happens,
> at a time we would like the dequeue() to proceed as fast as possible.
> 
> Even FQ is vulnerable to this problem, while one of FQ goals was
> to provide some flow isolation.
> 
> This patch adds a 'struct sk_buff **to_free' parameter to all
> qdisc->enqueue(), and in qdisc_drop() helper.
> 
> I measured a performance increase of up to 12 %, but this patch
> is a prereq so that future batches in enqueue() can fly.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
[...]
> +/* Instead of calling kfree_skb() while root qdisc lock is held,
> + * queue the skb for future freeing at end of __dev_xmit_skb()
> + */
> +static inline void __qdisc_drop(struct sk_buff *skb, struct sk_buff **to_free)
> +{
> +	skb->next = *to_free;
> +	*to_free = skb;
> +}
> +
[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index d40593b3b9fb..aba10d2a8bc3 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3070,6 +3070,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>  				 struct netdev_queue *txq)
>  {
>  	spinlock_t *root_lock = qdisc_lock(q);
> +	struct sk_buff *to_free = NULL;
>  	bool contended;
>  	int rc;
>  
> @@ -3086,7 +3087,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>  
>  	spin_lock(root_lock);
>  	if (unlikely(test_bit(__QDISC_STATE_DEACTIVATED, &q->state))) {
> -		kfree_skb(skb);
> +		__qdisc_drop(skb, &to_free);
>  		rc = NET_XMIT_DROP;
>  	} else if ((q->flags & TCQ_F_CAN_BYPASS) && !qdisc_qlen(q) &&
>  		   qdisc_run_begin(q)) {
> @@ -3109,7 +3110,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>  
>  		rc = NET_XMIT_SUCCESS;
>  	} else {
> -		rc = q->enqueue(skb, q) & NET_XMIT_MASK;
> +		rc = q->enqueue(skb, q, &to_free) & NET_XMIT_MASK;
>  		if (qdisc_run_begin(q)) {
>  			if (unlikely(contended)) {
>  				spin_unlock(&q->busylock);
> @@ -3119,6 +3120,8 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>  		}
>  	}
>  	spin_unlock(root_lock);
> +	if (unlikely(to_free))
> +		kfree_skb_list(to_free);

Great, now there is a good argument for implementing kmem_cache bulk
freeing inside kfree_skb_list().  I did a ugly PoC implementation
once, but there was no use-case that really needed the performance
boost.

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
