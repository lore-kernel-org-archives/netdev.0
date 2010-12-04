From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 04 Dec 2010 14:15:45 +0100
Message-ID: <4CFA3F01.20109@gmail.com>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com> <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51134 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754876Ab0LDNPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 08:15:52 -0500
Received: by wwa36 with SMTP id 36so11106652wwa.1
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 05:15:50 -0800 (PST)
In-Reply-To: <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> tq is only used in ri_tasklet, so we move it from ifb_private to a
> stack variable of ri_tasklet.
> 
> skb_queue_splice_tail_init() is used instead of the open coded and slow
> one.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> ---
>  drivers/net/ifb.c |   49 ++++++++++++-------------------------------------
>  1 file changed, 12 insertions(+), 37 deletions(-)
> diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
> index d1e362a..cd6e90d 100644
> --- a/drivers/net/ifb.c
> +++ b/drivers/net/ifb.c
> @@ -39,9 +39,7 @@
>  #define TX_Q_LIMIT    32
>  struct ifb_private {
>  	struct tasklet_struct   ifb_tasklet;
> -	int     tasklet_pending;
>  	struct sk_buff_head     rq;
> -	struct sk_buff_head     tq;
>  };
>  
>  static int numifbs = 2;
> @@ -53,27 +51,25 @@ static int ifb_close(struct net_device *dev);
>  
>  static void ri_tasklet(unsigned long dev)
>  {
> -
>  	struct net_device *_dev = (struct net_device *)dev;
>  	struct ifb_private *dp = netdev_priv(_dev);
>  	struct net_device_stats *stats = &_dev->stats;
>  	struct netdev_queue *txq;
>  	struct sk_buff *skb;
> +	struct sk_buff_head tq;
>  
> +	__skb_queue_head_init(&tq);
>  	txq = netdev_get_tx_queue(_dev, 0);
> -	if ((skb = skb_peek(&dp->tq)) == NULL) {
> -		if (__netif_tx_trylock(txq)) {
> -			while ((skb = skb_dequeue(&dp->rq)) != NULL) {
> -				skb_queue_tail(&dp->tq, skb);
> -			}
> -			__netif_tx_unlock(txq);
> -		} else {
> -			/* reschedule */
> -			goto resched;
> -		}
> +	if (!__netif_tx_trylock(txq)) {
> +		tasklet_schedule(&dp->ifb_tasklet);
> +		return;
>  	}
> +	skb_queue_splice_tail_init(&dp->rq, &tq);
> +	if (netif_tx_queue_stopped(txq))
> +		netif_tx_wake_queue(txq);
> +	__netif_tx_unlock(txq);
>  
> -	while ((skb = skb_dequeue(&dp->tq)) != NULL) {
> +	while ((skb = __skb_dequeue(&tq)) != NULL) {
>  		u32 from = G_TC_FROM(skb->tc_verd);
>  
>  		skb->tc_verd = 0;
> @@ -87,7 +83,7 @@ static void ri_tasklet(unsigned long dev)
>  			rcu_read_unlock();
>  			dev_kfree_skb(skb);
>  			stats->tx_dropped++;
> -			break;
> +			continue;

IMHO this line is a bugfix and should be a separate patch (for stable).

The rest looks OK to me but you could probably skip locking of dp->rq
similarly to tq.

Jarek P.

>  		}
>  		rcu_read_unlock();
>  		skb->skb_iif = _dev->ifindex;
> @@ -100,23 +96,6 @@ static void ri_tasklet(unsigned long dev)
>  		} else
>  			BUG();
>  	}
> -
> -	if (__netif_tx_trylock(txq)) {
> -		if ((skb = skb_peek(&dp->rq)) == NULL) {
> -			dp->tasklet_pending = 0;
> -			if (netif_queue_stopped(_dev))
> -				netif_wake_queue(_dev);
> -		} else {
> -			__netif_tx_unlock(txq);
> -			goto resched;
> -		}
> -		__netif_tx_unlock(txq);
> -	} else {
> -resched:
> -		dp->tasklet_pending = 1;
> -		tasklet_schedule(&dp->ifb_tasklet);
> -	}
> -
>  }
>  
>  static const struct net_device_ops ifb_netdev_ops = {
> @@ -162,10 +141,8 @@ static netdev_tx_t ifb_xmit(struct sk_buff *skb, struct net_device *dev)
>  	}
>  
>  	skb_queue_tail(&dp->rq, skb);
> -	if (!dp->tasklet_pending) {
> -		dp->tasklet_pending = 1;
> +	if (skb_queue_len(&dp->rq) == 1)
>  		tasklet_schedule(&dp->ifb_tasklet);
> -	}
>  
>  	return NETDEV_TX_OK;
>  }
> @@ -177,7 +154,6 @@ static int ifb_close(struct net_device *dev)
>  	tasklet_kill(&dp->ifb_tasklet);
>  	netif_stop_queue(dev);
>  	skb_queue_purge(&dp->rq);
> -	skb_queue_purge(&dp->tq);
>  	return 0;
>  }
>  
> @@ -187,7 +163,6 @@ static int ifb_open(struct net_device *dev)
>  
>  	tasklet_init(&dp->ifb_tasklet, ri_tasklet, (unsigned long)dev);
>  	skb_queue_head_init(&dp->rq);
> -	skb_queue_head_init(&dp->tq);
>  	netif_start_queue(dev);
>  
>  	return 0;
