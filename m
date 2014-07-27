From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [net-next PATCH v1 01/15] net: qdisc: use rcu prefix and silence
 sparse warnings
Date: Mon, 28 Jul 2014 01:46:36 +0200
Message-ID: <53D58F5C.3030200@redhat.com>
References: <20140726042439.21036.57721.stgit@nitbit.x32> <20140726042529.21036.62010.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>,
	xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63722 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039AbaG0Xqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jul 2014 19:46:45 -0400
In-Reply-To: <20140726042529.21036.62010.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/26/2014 06:25 AM, John Fastabend wrote:
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
<<snip>>
> @@ -416,11 +423,16 @@ static inline bool qdisc_all_tx_empty(const struct net_device *dev)
>  static inline bool qdisc_tx_changing(const struct net_device *dev)
>  {
>  	unsigned int i;
> +
> +	rcu_read_lock();
>  	for (i = 0; i < dev->num_tx_queues; i++) {
>  		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
> -		if (txq->qdisc != txq->qdisc_sleeping)
> +		if (rcu_dereference(txq->qdisc) != txq->qdisc_sleeping) {
Since there's going to be a v2 perhaps it'd be better to use
rcu_access_pointer() here ?
I don't think the depend barrier is necessary.

> +			rcu_read_unlock();
>  			return true;
> +		}
>  	}
> +	rcu_read_unlock();
>  	return false;
>  }
>  
<<snip>>
> @@ -157,9 +160,9 @@ teql_destroy(struct Qdisc *sch)
>  						txq = netdev_get_tx_queue(master->dev, 0);
>  						master->slaves = NULL;
>  
> -						root_lock = qdisc_root_sleeping_lock(txq->qdisc);
> +						root_lock = qdisc_root_sleeping_lock(rtnl_dereference(txq->qdisc));
>  						spin_lock_bh(root_lock);
> -						qdisc_reset(txq->qdisc);
> +						qdisc_reset(rtnl_dereference(txq->qdisc));
>  						spin_unlock_bh(root_lock);
>  					}
>  				}
> @@ -266,7 +269,7 @@ static inline int teql_resolve(struct sk_buff *skb,
>  	struct dst_entry *dst = skb_dst(skb);
>  	int res;
>  
> -	if (txq->qdisc == &noop_qdisc)
> +	if (rcu_dereference_bh(txq->qdisc) == &noop_qdisc)
Same here. Perhaps rcu_access_pointer() ?

Cheers,
 Nik
