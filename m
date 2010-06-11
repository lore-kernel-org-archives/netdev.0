From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/8] netpoll: Fix RCU usage
Date: Fri, 11 Jun 2010 16:10:21 -0700
Message-ID: <20100611231021.GK2394@linux.vnet.ibm.com>
References: <20100611021142.GA24490@gondor.apana.org.au>
 <E1OMtjg-0006Ob-Sb@gondolin.me.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Matt Mackall <mpm@selenic.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:60574 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750861Ab0FKXKY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jun 2010 19:10:24 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5BN4ONU022748
	for <netdev@vger.kernel.org>; Fri, 11 Jun 2010 19:04:24 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5BNANvD2388024
	for <netdev@vger.kernel.org>; Fri, 11 Jun 2010 19:10:23 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5BNAMaQ032729
	for <netdev@vger.kernel.org>; Fri, 11 Jun 2010 19:10:23 -0400
Content-Disposition: inline
In-Reply-To: <E1OMtjg-0006Ob-Sb@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 11, 2010 at 12:12:44PM +1000, Herbert Xu wrote:
> netpoll: Fix RCU usage
> 
> The use of RCU in netpoll is incorrect in a number of places:
> 
> 1) The initial setting is lacking a write barrier.
> 2) The synchronize_rcu is in the wrong place.
> 3) Read barriers are missing.
> 4) Some places are even missing rcu_read_lock.
> 5) npinfo is zeroed after freeing.
> 
> This patch fixes those issues.  As most users are in BH context,
> this also converts the RCU usage to the BH variant.

Looks good for me from an RCU viewpoint, but as usual I confess much
ignorance of the surrounding code.

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> ---
> 
>  include/linux/netpoll.h |   13 ++++++++-----
>  net/core/netpoll.c      |   20 ++++++++++++--------
>  2 files changed, 20 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
> index e9e2312..95c9f7e 100644
> --- a/include/linux/netpoll.h
> +++ b/include/linux/netpoll.h
> @@ -57,12 +57,15 @@ void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb);
>  #ifdef CONFIG_NETPOLL
>  static inline bool netpoll_rx(struct sk_buff *skb)
>  {
> -	struct netpoll_info *npinfo = skb->dev->npinfo;
> +	struct netpoll_info *npinfo;
>  	unsigned long flags;
>  	bool ret = false;
> 
> +	rcu_read_lock_bh();
> +	npinfo = rcu_dereference(skb->dev->npinfo);
> +
>  	if (!npinfo || (list_empty(&npinfo->rx_np) && !npinfo->rx_flags))
> -		return false;
> +		goto out;
> 
>  	spin_lock_irqsave(&npinfo->rx_lock, flags);
>  	/* check rx_flags again with the lock held */
> @@ -70,12 +73,14 @@ static inline bool netpoll_rx(struct sk_buff *skb)
>  		ret = true;
>  	spin_unlock_irqrestore(&npinfo->rx_lock, flags);
> 
> +out:
> +	rcu_read_unlock_bh();
>  	return ret;
>  }
> 
>  static inline int netpoll_rx_on(struct sk_buff *skb)
>  {
> -	struct netpoll_info *npinfo = skb->dev->npinfo;
> +	struct netpoll_info *npinfo = rcu_dereference(skb->dev->npinfo);
> 
>  	return npinfo && (!list_empty(&npinfo->rx_np) || npinfo->rx_flags);
>  }
> @@ -91,7 +96,6 @@ static inline void *netpoll_poll_lock(struct napi_struct *napi)
>  {
>  	struct net_device *dev = napi->dev;
> 
> -	rcu_read_lock(); /* deal with race on ->npinfo */
>  	if (dev && dev->npinfo) {
>  		spin_lock(&napi->poll_lock);
>  		napi->poll_owner = smp_processor_id();
> @@ -108,7 +112,6 @@ static inline void netpoll_poll_unlock(void *have)
>  		napi->poll_owner = -1;
>  		spin_unlock(&napi->poll_lock);
>  	}
> -	rcu_read_unlock();
>  }
> 
>  #else
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index 748c930..4b7623d 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -292,6 +292,7 @@ void netpoll_send_skb(struct netpoll *np, struct sk_buff *skb)
>  	unsigned long tries;
>  	struct net_device *dev = np->dev;
>  	const struct net_device_ops *ops = dev->netdev_ops;
> +	/* It is up to the caller to keep npinfo alive. */
>  	struct netpoll_info *npinfo = np->dev->npinfo;
> 
>  	if (!npinfo || !netif_running(dev) || !netif_device_present(dev)) {
> @@ -841,10 +842,7 @@ int netpoll_setup(struct netpoll *np)
>  	refill_skbs();
> 
>  	/* last thing to do is link it to the net device structure */
> -	ndev->npinfo = npinfo;
> -
> -	/* avoid racing with NAPI reading npinfo */
> -	synchronize_rcu();
> +	rcu_assign_pointer(ndev->npinfo, npinfo);
> 
>  	return 0;
> 
> @@ -888,6 +886,16 @@ void netpoll_cleanup(struct netpoll *np)
> 
>  			if (atomic_dec_and_test(&npinfo->refcnt)) {
>  				const struct net_device_ops *ops;
> +
> +				ops = np->dev->netdev_ops;
> +				if (ops->ndo_netpoll_cleanup)
> +					ops->ndo_netpoll_cleanup(np->dev);
> +
> +				rcu_assign_pointer(np->dev->npinfo, NULL);
> +
> +				/* avoid racing with NAPI reading npinfo */
> +				synchronize_rcu_bh();
> +
>  				skb_queue_purge(&npinfo->arp_tx);
>  				skb_queue_purge(&npinfo->txq);
>  				cancel_rearming_delayed_work(&npinfo->tx_work);
> @@ -895,10 +903,6 @@ void netpoll_cleanup(struct netpoll *np)
>  				/* clean after last, unfinished work */
>  				__skb_queue_purge(&npinfo->txq);
>  				kfree(npinfo);
> -				ops = np->dev->netdev_ops;
> -				if (ops->ndo_netpoll_cleanup)
> -					ops->ndo_netpoll_cleanup(np->dev);
> -				np->dev->npinfo = NULL;
>  			}
>  		}
> 
