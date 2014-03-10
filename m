From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RCU PATCH 01/14] net: qdisc: use rcu prefix and silence sparse
 warnings
Date: Mon, 10 Mar 2014 10:20:27 -0700
Message-ID: <1394472027.3607.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32>
	 <20140310170345.3011.81706.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:49768 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809AbaCJRU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 13:20:29 -0400
Received: by mail-pd0-f181.google.com with SMTP id p10so7291802pdj.26
        for <netdev@vger.kernel.org>; Mon, 10 Mar 2014 10:20:29 -0700 (PDT)
In-Reply-To: <20140310170345.3011.81706.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-10 at 10:03 -0700, John Fastabend wrote:
> Add __rcu notation to qdisc handling by doing this we can make
> smatch output more legible. And anyways some of the cases should
> be using rcu_dereference() see qdisc_all_tx_empty(),
> qdisc_tx_chainging(), and so on.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  include/linux/netdevice.h |   41 ++++------------------------------
>  include/net/sch_generic.h |   29 +++++++++++++++++++-----
>  net/core/dev.c            |   54 +++++++++++++++++++++++++++++++++++++++++++--
>  net/sched/sch_generic.c   |    4 ++-
>  net/sched/sch_mqprio.c    |    4 ++-
>  net/sched/sch_teql.c      |    9 ++++----
>  6 files changed, 89 insertions(+), 52 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 1a86948..e7c890b 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -546,7 +546,7 @@ struct netdev_queue {
>   * read mostly part
>   */
>  	struct net_device	*dev;
> -	struct Qdisc		*qdisc;
> +	struct Qdisc __rcu	*qdisc;
>  	struct Qdisc		*qdisc_sleeping;
>  #ifdef CONFIG_SYSFS
>  	struct kobject		kobj;
> @@ -2142,13 +2142,8 @@ static inline void input_queue_tail_incr_save(struct softnet_data *sd,
>  
>  DECLARE_PER_CPU_ALIGNED(struct softnet_data, softnet_data);
>  
> -void __netif_schedule(struct Qdisc *q);
> -
> -static inline void netif_schedule_queue(struct netdev_queue *txq)
> -{
> -	if (!(txq->state & QUEUE_STATE_ANY_XOFF))
> -		__netif_schedule(txq->qdisc);
> -}
> +extern void __netif_schedule(struct Qdisc *q);
> +extern void netif_schedule_queue(struct netdev_queue *txq);

Please drop the 'extern', we no longer add them in include files

>  
>  static inline void netif_tx_schedule_all(struct net_device *dev)
>  {
> @@ -2184,17 +2179,7 @@ static inline void netif_tx_start_all_queues(struct net_device *dev)
>  	}
>  }
>  
> -static inline void netif_tx_wake_queue(struct netdev_queue *dev_queue)
> -{
> -#ifdef CONFIG_NETPOLL_TRAP
> -	if (netpoll_trap()) {
> -		netif_tx_start_queue(dev_queue);
> -		return;
> -	}
> -#endif
> -	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &dev_queue->state))
> -		__netif_schedule(dev_queue->qdisc);
> -}
> +extern void netif_tx_wake_queue(struct netdev_queue *dev_queue);
>  

here as well

>  /**
>   *	netif_wake_queue - restart transmit
> @@ -2463,23 +2448,7 @@ static inline bool netif_subqueue_stopped(const struct net_device *dev,
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
> -#ifdef CONFIG_NETPOLL_TRAP
> -	if (netpoll_trap())
> -		return;
> -#endif
> -	if (test_and_clear_bit(__QUEUE_STATE_DRV_XOFF, &txq->state))
> -		__netif_schedule(txq->qdisc);
> -}
> +extern void netif_wake_subqueue(struct net_device *dev, u16 queue_index);


same


Otherwise, this looks fine. I attempted this same patch months ago and
somehow was blocked on one issue I cannot remember....

Thanks !
