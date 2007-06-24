From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Sun, 24 Jun 2007 14:16:16 +0200
Message-ID: <467E6090.6070703@trash.net>
References: <20070623213614.18241.45511.stgit@localhost.localdomain> <20070623213633.18241.24627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	auke-jan.h.kok@intel.com, hadi@cyberus.ca
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41800 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754212AbXFXMQS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jun 2007 08:16:18 -0400
In-Reply-To: <20070623213633.18241.24627.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PJ Waskiewicz wrote:
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index 09808b7..ec3a9a5 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -103,8 +103,8 @@ struct tc_prio_qopt
>  
>  enum
>  {
> -	TCA_PRIO_UNPSEC,
> -	TCA_PRIO_TEST,


You misunderstood me. You can work on top of my compat attribute
patches, but the example code should not have to go in to apply
your patch.


> diff --git a/net/sched/Kconfig b/net/sched/Kconfig
> index 475df84..7f14fa6 100644
> --- a/net/sched/Kconfig
> +++ b/net/sched/Kconfig
> @@ -102,8 +102,16 @@ config NET_SCH_ATM
>  	  To compile this code as a module, choose M here: the
>  	  module will be called sch_atm.
>  
> +config NET_SCH_BANDS
> +        bool "Multi Band Queueing (PRIO and RR)"

This options seems useless. Its not used *anywhere* except for
dependencies.

> +        ---help---
> +          Say Y here if you want to use n-band multiqueue packet
> +          schedulers.  These include a priority-based scheduler and
> +	   a round-robin scheduler.
> +
>  config NET_SCH_PRIO
>  	tristate "Multi Band Priority Queueing (PRIO)"
> +	depends on NET_SCH_BANDS

And this dependency as well.

>  	---help---
>  	  Say Y here if you want to use an n-band priority queue packet
>  	  scheduler.
> @@ -111,6 +119,28 @@ config NET_SCH_PRIO
>  	  To compile this code as a module, choose M here: the
>  	  module will be called sch_prio.
>  
> +config NET_SCH_RR
> +	tristate "Multi Band Round Robin Queuing (RR)"
> +	depends on NET_SCH_BANDS

Same here. RR

> +	select NET_SCH_PRIO
> +	---help---
> +	  Say Y here if you want to use an n-band round robin packet
> +	  scheduler.
> +
> +	  The module uses sch_prio for its framework and is aliased as
> +	  sch_rr, so it will load sch_prio, although it is referred
> +	  to using sch_rr.
> +
> +config NET_SCH_BANDS_MQ
> +	bool "Multiple hardware queue support"
> +	depends on NET_SCH_BANDS


OK, again:

Introduce NET_SCH_RR. NET_SCH_RR selects NET_SCH_PRIO. Nothing at
all changes for NET_SCH_PRIO itself. Additionally introduce a
boolean NET_SCH_MULTIQUEUE. No dependencies at all. Use
NET_SCH_MULTIQUEUE to guard the multiqueue code in sch_prio.c.
Your current code doesn't even have any ifdefs anymore though,
so this might not be needed at all.

Additionally you could later introduce E1000_MULTIQUEUE and
have that select NET_SCH_MULTIQUEUE.

> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index 9461e8a..203d5c4 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -168,7 +168,8 @@ static inline int qdisc_restart(struct net_device *dev)
>  	spin_unlock(&dev->queue_lock);
>  
>  	ret = NETDEV_TX_BUSY;
> -	if (!netif_queue_stopped(dev))
> +	if (!netif_queue_stopped(dev) &&
> +	    !netif_subqueue_stopped(dev, skb->queue_mapping))
>  		/* churn baby churn .. */
>  		ret = dev_hard_start_xmit(skb, dev);

I'll try again - please move this to patch 2/3.



> diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
> index 40a13e8..8a716f0 100644
> --- a/net/sched/sch_prio.c
> +++ b/net/sched/sch_prio.c
> @@ -40,9 +40,11 @@
>  struct prio_sched_data
>  {
>  	int bands;
> +	int curband; /* for round-robin */
>  	struct tcf_proto *filter_list;
>  	u8  prio2band[TC_PRIO_MAX+1];
>  	struct Qdisc *queues[TCQ_PRIO_BANDS];
> +	unsigned char mq;
>  };
>  
>  
> @@ -70,14 +72,28 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
>  #endif
>  			if (TC_H_MAJ(band))
>  				band = 0;
> +			if (q->mq)
> +				skb->queue_mapping = 
> +						q->prio2band[band&TC_PRIO_MAX];
> +			else
> +				skb->queue_mapping = 0;


Might look cleaner if you have one central point where queue_mapping is
set and the band is returned.

> +	/* If we're multiqueue, make sure the number of incoming bands
> +	 * matches the number of queues on the device we're associating with.
> +	 */
> +	if (tb[TCA_PRIO_MQ - 1])
> +		q->mq = *(unsigned char *)RTA_DATA(tb[TCA_PRIO_MQ - 1]);


If you're using it as a flag, please use RTA_GET_FLAG(),
otherwise RTA_GET_U8.

> +	if (q->mq && (qopt->bands != sch->dev->egress_subqueue_count))
> +		return -EINVAL;
>  
>  	sch_tree_lock(sch);
>  	q->bands = qopt->bands;
> @@ -280,7 +342,7 @@ static int prio_dump(struct Qdisc *sch, struct sk_buff *skb)
>  	memcpy(&opt.priomap, q->prio2band, TC_PRIO_MAX+1);
>  
>  	nest = RTA_NEST_COMPAT(skb, TCA_OPTIONS, sizeof(opt), &opt);
> -	RTA_PUT_U32(skb, TCA_PRIO_TEST, 321);
> +	RTA_PUT_U8(skb, TCA_PRIO_MQ, q->mq);


And RTA_PUT_FLAG. Now that I think of it, does it even makes sense
to have a prio private flag for this instead of a qdisc global one?

>  static int __init prio_module_init(void)
>  {
> -	return register_qdisc(&prio_qdisc_ops);
> +	register_qdisc(&prio_qdisc_ops);
> +	register_qdisc(&rr_qdisc_ops);

Proper error handling please.
