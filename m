From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v3 01/15] net: qdisc: use rcu prefix and
 silence sparse warnings
Date: Tue, 09 Sep 2014 05:05:59 -0700
Message-ID: <1410264359.11872.145.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140909055221.2071.99671.stgit@nitbit.x32>
	 <20140909055406.2071.44732.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:64366 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756185AbaIIMGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 08:06:02 -0400
Received: by mail-pd0-f174.google.com with SMTP id v10so8848299pde.33
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 05:06:01 -0700 (PDT)
In-Reply-To: <20140909055406.2071.44732.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 22:54 -0700, John Fastabend wrote:
> Add __rcu notation to qdisc handling by doing this we can make
> smatch output more legible. And anyways some of the cases should
> be using rcu_dereference() see qdisc_all_tx_empty(),
> qdisc_tx_chainging(), and so on.
> 
> Also *wake_queue() API is commonly called from driver timer routines
> without rcu lock or rtnl lock. So I added rcu_read_lock() blocks
> around netif_wake_subqueue and netif_tx_wake_queue.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  include/linux/netdevice.h |   29 ++++----------------------
>  include/net/sch_generic.h |   29 ++++++++++++++++++++------
>  net/core/dev.c            |   51 +++++++++++++++++++++++++++++++++++++++++++--
>  net/sched/sch_generic.c   |    4 ++--
>  net/sched/sch_mqprio.c    |    6 ++++-
>  net/sched/sch_teql.c      |   13 +++++++----
>  6 files changed, 90 insertions(+), 42 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index ba72f6b..ae721f5 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -543,7 +543,7 @@ struct netdev_queue {
>   * read mostly part
>   */
>  	struct net_device	*dev;
> -	struct Qdisc		*qdisc;
> +	struct Qdisc __rcu	*qdisc;
>  	struct Qdisc		*qdisc_sleeping;
>  #ifdef CONFIG_SYSFS
>  	struct kobject		kobj;
> @@ -2356,12 +2356,7 @@ static inline void input_queue_tail_incr_save(struct softnet_data *sd,
>  DECLARE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
>  
>  void __netif_schedule(struct Qdisc *q);
> -
> -static inline void netif_schedule_queue(struct netdev_queue *txq)
> -{
> -	if (!(txq->state & QUEUE_STATE_ANY_XOFF))
> -		__netif_schedule(txq->qdisc);
> -}
> +void netif_schedule_queue(struct netdev_queue *txq);
>  
>  static inline void netif_tx_schedule_all(struct net_device *dev)
>  {
> @@ -2397,11 +2392,7 @@ static inline void netif_tx_start_all_queues(struct net_device *dev)
>  	}
>  }
>  
> -static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
> -{
> -	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state))
> -		__netif_schedule(dev_queue->qdisc);
> -}
> +void netif_tx_wake_queue(struct netdev_queue *dev_queue);
>  
>  /**
>   *	netif_wake_queue - restart transmit
> @@ -2673,19 +2664,7 @@ static inline bool netif_subqueue_stopped(const struct net_device *dev,
>  	return __netif_subqueue_stopped(dev, skb_get_queue_mapping(skb));
>  }
>  
> -/**
> - *	netif_wake_subqueue - allow sending packets on subqueue
> - *	@dev: network device
> - *	@queue_index: sub queue index
> - *
> - * Resume individual transmit queue of a device with multiple transmit queues.
> - */
> -static inline void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
> -{
> -	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
> -	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &txq->state))
> -		__netif_schedule(txq->qdisc);
> -}
> +void netif_wake_subqueue(struct net_device *dev, u16 queue_index);
>  
>  #ifdef CONFIG_XPS
>  int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index a3cfb8e..19b1b36 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -259,7 +259,9 @@ static inline spinlock_t *qdisc_lock(struct Qdisc *qdisc)
>  
>  static inline struct Qdisc *qdisc_root(const struct Qdisc *qdisc)
>  {
> -	return qdisc->dev_queue->qdisc;
> +	struct Qdisc *q = rcu_dereference_rtnl(qdisc->dev_queue->qdisc);
> +
> +	return q;
>  }
>  
>  static inline struct Qdisc *qdisc_root_sleeping(const struct Qdisc *qdisc)
> @@ -384,7 +386,7 @@ static inline void qdisc_reset_all_tx_gt(struct net_device *dev, unsigned int i)
>  	struct Qdisc *qdisc;
>  
>  	for (; i < dev->num_tx_queues; i++) {
> -		qdisc = netdev_get_tx_queue(dev, i)->qdisc;
> +		qdisc = rtnl_dereference(netdev_get_tx_queue(dev, i)->qdisc);
>  		if (qdisc) {
>  			spin_lock_bh(qdisc_lock(qdisc));
>  			qdisc_reset(qdisc);
> @@ -402,13 +404,18 @@ static inline void qdisc_reset_all_tx(struct net_device *dev)
>  static inline bool qdisc_all_tx_empty(const struct net_device *dev)
>  {
>  	unsigned int i;
> +
> +	rcu_read_lock();
>  	for (i = 0; i < dev->num_tx_queues; i++) {
>  		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
> -		const struct Qdisc *q = txq->qdisc;
> +		const struct Qdisc *q = rcu_dereference(txq->qdisc);
>  
> -		if (q->q.qlen)
> +		if (q->q.qlen) {
> +			rcu_read_unlock();
>  			return false;
> +		}
>  	}
> +	rcu_read_unlock();
>  	return true;
>  }
>  
> @@ -416,11 +423,16 @@ static inline bool qdisc_all_tx_empty(const struct net_device *dev)
>  static inline bool qdisc_tx_changing(const struct net_device *dev)
>  {
>  	unsigned int i;
> +
> +	rcu_read_lock();...

No need for rcu_read_lock() : rcu_access_pointer() needs no such
protection

>  	for (i = 0; i < dev->num_tx_queues; i++) {
>  		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
> -		if (txq->qdisc != txq->qdisc_sleeping)
> +		if (rcu_access_pointer(txq->qdisc) != txq->qdisc_sleeping) {
> +			rcu_read_unlock();
>  			return true;
> +		}
>  	}
> +	rcu_read_unlock();
>  	return false;
>  }
>  
> @@ -428,11 +440,16 @@ static inline bool qdisc_tx_changing(const struct net_device *dev)
>  static inline bool qdisc_tx_is_noop(const struct net_device *dev)
>  {
>  	unsigned int i;
> +
> +	rcu_read_lock();

No need for rcu_read_lock() : rcu_access_pointer() needs no such
protection


>  	for (i = 0; i < dev->num_tx_queues; i++) {
>  		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
> -		if (txq->qdisc != &noop_qdisc)
> +		if (rcu_dereference(txq->qdisc) != &noop_qdisc) {
> +			rcu_read_unlock();
>  			return false;
> +		}
>  	}
> +	rcu_read_unlock();
>  	return true;
>  }
>  
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 3c6a967..1e25640 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2177,6 +2177,53 @@ static struct dev_kfree_skb_cb *get_kfree_skb_cb(const struct sk_buff *skb)
>  	return (struct dev_kfree_skb_cb *)skb->cb;
>  }
>  
> +void netif_schedule_queue(struct netdev_queue *txq)
> +{
> +	rcu_read_lock();
> +	if (!(txq->state & QUEUE_STATE_ANY_XOFF)) {
> +		struct Qdisc *q = rcu_dereference(txq->qdisc);
> +
> +		__netif_schedule(q);
> +	}
> +	rcu_read_unlock();
> +}
> +EXPORT_SYMBOL(netif_schedule_queue);
> +
> +/**
> + *	netif_wake_subqueue - allow sending packets on subqueue
> + *	@dev: network device
> + *	@queue_index: sub queue index
> + *
> + * Resume individual transmit queue of a device with multiple transmit queues.
> + */
> +void netif_wake_subqueue(struct net_device *dev, u16 queue_index)
> +{
> +	struct netdev_queue *txq = netdev_get_tx_queue(dev, queue_index);
> +
> +	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &txq->state)) {
> +		struct Qdisc *q;
> +
> +		rcu_read_lock();
> +		q = rcu_dereference(txq->qdisc);
> +		__netif_schedule(q);
> +		rcu_read_unlock();
> +	}
> +}
> +EXPORT_SYMBOL(netif_wake_subqueue);
> +
> +void netif_tx_wake_queue(struct netdev_queue *dev_queue)
> +{
> +	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state)) {
> +		struct Qdisc *q;
> +
> +		rcu_read_lock();
> +		q = rcu_dereference(dev_queue->qdisc);
> +		__netif_schedule(q);
> +		rcu_read_unlock();
> +	}
> +}
> +EXPORT_SYMBOL(netif_tx_wake_queue);
> +
>  void __dev_kfree_skb_irq(struct sk_buff *skb, enum skb_free_reason reason)
>  {
>  	unsigned long flags;
> @@ -3432,7 +3479,7 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
>  	skb->tc_verd = SET_TC_RTTL(skb->tc_verd, ttl);
>  	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
>  
> -	q = rxq->qdisc;
> +	q = rcu_dereference(rxq->qdisc);
>  	if (q != &noop_qdisc) {
>  		spin_lock(qdisc_lock(q));
>  		if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
> @@ -3449,7 +3496,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
>  {
>  	struct netdev_queue *rxq = rcu_dereference(skb->dev->ingress_queue);
>  
> -	if (!rxq || rxq->qdisc == &noop_qdisc)
> +	if (!rxq || rcu_dereference_bh(rxq->qdisc) == &noop_qdisc)

This is not consistent with previous rcu_dereference(), and anyway
you can use rcu_access_pointer()

>  		goto out;
>  
>  	if (*pt_prev) {

rest was fine.

Thanks !
