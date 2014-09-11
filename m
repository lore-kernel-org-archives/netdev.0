From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v4 01/16] net: qdisc: use rcu prefix and
 silence sparse warnings
Date: Wed, 10 Sep 2014 17:23:58 -0700
Message-ID: <1410395038.7106.34.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140910154517.2036.53084.stgit@nitbit.x32>
	 <20140910154659.2036.95037.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, davem@davemloft.net, jhs@mojatatu.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:62461 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993AbaIKAYA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 20:24:00 -0400
Received: by mail-pd0-f182.google.com with SMTP id w10so7292546pde.41
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 17:24:00 -0700 (PDT)
In-Reply-To: <20140910154659.2036.95037.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-10 at 08:47 -0700, John Fastabend wrote:
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

...

>  
> @@ -416,10 +423,13 @@ static inline bool qdisc_all_tx_empty(const struct net_device *dev)
>  static inline bool qdisc_tx_changing(const struct net_device *dev)
>  {
>  	unsigned int i;
> +
>  	for (i = 0; i < dev->num_tx_queues; i++) {
>  		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
> -		if (txq->qdisc != txq->qdisc_sleeping)
> +		if (rcu_access_pointer(txq->qdisc) != txq->qdisc_sleeping) {
> +			rcu_read_unlock();

You forgot to remove this rcu_read_unlock();

>  			return true;
> +		}
>  	}
>  	return false;
>  }
> @@ -428,10 +438,13 @@ static inline bool qdisc_tx_changing(const struct net_device *dev)
>  static inline bool qdisc_tx_is_noop(const struct net_device *dev)
>  {
>  	unsigned int i;
> +
>  	for (i = 0; i < dev->num_tx_queues; i++) {
>  		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
> -		if (txq->qdisc != &noop_qdisc)
> +		if (rcu_dereference(txq->qdisc) != &noop_qdisc) {

		rcu_access_pointer()

> +			rcu_read_unlock();

You forgot to remove this rcu_read_unlock();

>  			return false;
> +		}
>  	}
>  	return true;
>  }
