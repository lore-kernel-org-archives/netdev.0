From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Sun, 21 Sep 2008 17:25:38 +0200
Message-ID: <20080921152538.GC2551@ami.dom.local>
References: <20080920.002137.108837580.davem@davemloft.net> <20080920234843.GA2531@ami.dom.local> <20080920.223538.130375517.davem@davemloft.net> <20080920.225033.261544815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:4371 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbYIUPWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2008 11:22:08 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1087122fgg.17
        for <netdev@vger.kernel.org>; Sun, 21 Sep 2008 08:22:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080920.225033.261544815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 20, 2008 at 10:50:33PM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sat, 20 Sep 2008 22:35:38 -0700 (PDT)
> 
> > Therefore it seems logical that what really needs to happen is that
> > we simply pick some new local special token value for 'ret' so that
> > we can handle that case.  "-1" would probably work fine.
>  ...
> > I also think the qdisc_run() test needs to be there.  When the TX
> > queue fills up, we will doing tons of completely useless work going:
> 
> Ok, here is the kind of thing I'm suggesting in all of this.
> 
> It gets rid of bouncing unnecessarily into __qdisc_run() when
> dev_queue_xmit()'s finally selected TXQ is stopped.
> 
> It also gets rid of the dev_requeue_skb() looping case Jarek
> discovered.
> 
> diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
> index b786a5b..4082f39 100644
> --- a/include/net/pkt_sched.h
> +++ b/include/net/pkt_sched.h
> @@ -90,10 +90,7 @@ extern void __qdisc_run(struct Qdisc *q);
>  
>  static inline void qdisc_run(struct Qdisc *q)
>  {
> -	struct netdev_queue *txq = q->dev_queue;
> -
> -	if (!netif_tx_queue_stopped(txq) &&
> -	    !test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
> +	if (!test_and_set_bit(__QDISC_STATE_RUNNING, &q->state))
>  		__qdisc_run(q);
>  }
>  
> diff --git a/net/core/dev.c b/net/core/dev.c
> index fdfc4b6..4654127 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1809,7 +1809,15 @@ gso:
>  			rc = NET_XMIT_DROP;
>  		} else {
>  			rc = qdisc_enqueue_root(skb, q);
> -			qdisc_run(q);
> +
> +			txq = NULL;
> +			if (rc == NET_XMIT_SUCCESS) {
> +				int map = skb_get_queue_mapping(skb);

Deja vu? How about e.g. blackhole_enqueue()?

> +				txq = netdev_get_tx_queue(dev, map);
> +			}
> +
> +			if (!txq || !netif_tx_queue_stopped(txq))
> +				qdisc_run(q);
>  		}
>  		spin_unlock(root_lock);
>  
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index ec0a083..b6e6926 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -117,7 +117,7 @@ static inline int handle_dev_cpu_collision(struct sk_buff *skb,
>  static inline int qdisc_restart(struct Qdisc *q)
>  {
>  	struct netdev_queue *txq;
> -	int ret = NETDEV_TX_BUSY;
> +	int ret = -2;
>  	struct net_device *dev;
>  	spinlock_t *root_lock;
>  	struct sk_buff *skb;
> @@ -158,7 +158,7 @@ static inline int qdisc_restart(struct Qdisc *q)
>  		if (unlikely (ret != NETDEV_TX_BUSY && net_ratelimit()))
>  			printk(KERN_WARNING "BUG %s code %d qlen %d\n",
>  			       dev->name, ret, q->q.qlen);
> -
> +	case -2:
>  		ret = dev_requeue_skb(skb, q);

Hmm... I really can't see any difference - except getting rid of this
if sometimes.

>  		break;
>  	}

Jarek P.
