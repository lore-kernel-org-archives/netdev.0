From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Wed, 13 Aug 2008 10:27:01 +0000
Message-ID: <20080813102701.GD5367@ff.dom.local>
References: <20080813061317.GA4251@ff.dom.local> <20080812.231633.193696650.davem@davemloft.net> <20080813065302.GB4251@ff.dom.local> <20080813.022549.203848195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:52607 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbYHMK1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 06:27:10 -0400
Received: by mu-out-0910.google.com with SMTP id w8so5019059mue.1
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 03:27:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080813.022549.203848195.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 02:25:49AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 13 Aug 2008 06:53:03 +0000
> 
> > Otherwise, I think you would better send some code example with these
> > flags, so we could be sure there is no misunderstanding around this.
> 
> Here it my concrete proposal for a fix.
> 
> pkt_sched: Fix queue quiescence testing in dev_deactivate().
> 
> Based upon discussions with Jarek P. and Herbert Xu.
> 
> First, we're testing the wrong qdisc.  We just reset the device
> queue qdiscs to &noop_qdisc and checking it's state is completely
> pointless here.
> 
> We want to wait until the previous qdisc that was sitting at
> the ->qdisc pointer is not busy any more.  And that would be
> ->qdisc_sleeping.
> 
> Because of how we propagate the samples qdisc pointer down into
> qdisc_run and friends via per-cpu ->output_queue and netif_schedule,
> we have to wait also for the __QDISC_STATE_SCHED bit to clear as
> well.

Of course, checking this needs more time, but it looks like it could
work, only two little doubts:

- in net_tx_action() we can hit a place just after clear_bit() where
none of these bits is set. Of course, hitting this 2 times in a row
seems to be very unprobable, yet possible, and a lock isn't helpful
here, so probably some change around this would make this nicer.

- isn't there possible some longer ping-pong between qdic_run() and
net_tx_action() when dev_requeue_skb() would get it back to
__netif_schedule() and so on (with NETDEV_TX_BUSY)?

Otherwise, this patch looks OK to me.

Jarek P.


> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 7cf83b3..4685746 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -647,7 +647,7 @@ static void dev_deactivate_queue(struct net_device *dev,
>  	}
>  }
>  
> -static bool some_qdisc_is_running(struct net_device *dev, int lock)
> +static bool some_qdisc_is_busy(struct net_device *dev, int lock)
>  {
>  	unsigned int i;
>  
> @@ -658,13 +658,14 @@ static bool some_qdisc_is_running(struct net_device *dev, int lock)
>  		int val;
>  
>  		dev_queue = netdev_get_tx_queue(dev, i);
> -		q = dev_queue->qdisc;
> +		q = dev_queue->qdisc_sleeping;
>  		root_lock = qdisc_lock(q);
>  
>  		if (lock)
>  			spin_lock_bh(root_lock);
>  
> -		val = test_bit(__QDISC_STATE_RUNNING, &q->state);
> +		val = (test_bit(__QDISC_STATE_RUNNING, &q->state) ||
> +		       test_bit(__QDISC_STATE_SCHED, &q->state));
>  
>  		if (lock)
>  			spin_unlock_bh(root_lock);
> @@ -689,14 +690,14 @@ void dev_deactivate(struct net_device *dev)
>  
>  	/* Wait for outstanding qdisc_run calls. */
>  	do {
> -		while (some_qdisc_is_running(dev, 0))
> +		while (some_qdisc_is_busy(dev, 0))
>  			yield();
>  
>  		/*
>  		 * Double-check inside queue lock to ensure that all effects
>  		 * of the queue run are visible when we return.
>  		 */
> -		running = some_qdisc_is_running(dev, 1);
> +		running = some_qdisc_is_busy(dev, 1);
>  
>  		/*
>  		 * The running flag should never be set at this point because
