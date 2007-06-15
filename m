From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH 1/2] qdisc_restart - readability changes, one bug fix.
Date: Fri, 15 Jun 2007 11:01:33 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329030A0E5F@orsmsx414.amr.corp.intel.com>
References: <1181724047.10679.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <kumarkr@linux.vnet.ibm.com>, <davem@davemloft.net>,
	<jamal@cyberus.ca>, <herbert@gondor.apana.org.au>, <tgraf@suug.ch>,
	<kaber@trash.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20102 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581AbXFOSBf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 14:01:35 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1181724047.10679.30.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> - "if (ret == NETDEV_TX_LOCKED && lockless)" is buggy, and 
> the lockless
>   check should be removed, since driver will return 
> NETDEV_TX_LOCKED only
>   if lockless is true and driver has to do the locking. In 
> the original
>   code as well as the latest code, this code can result in a bug where
>   if LLTX is not set for a driver (lockless == 0) but the 
> driver is written
>   wrongly to do a trylock (despite LLTX being set), the driver returns
>   LOCKED. But since lockless is zero, the packet is requeue'd 
> instead of
>   calling collision code, issuing a warning and freeing up 
> the skb. This
>   skb will be retried with this driver next time, and the 
> same result will
>   ensue. Removing this check will catch these driver bugs 
> instead of hiding
>   the problem. I am keeping this change to readability section since :
>   	a. it is confusing to check two things as it is; and
>   	b. it is difficult to keep this check in the changed 
> 'switch' code.

I agree that the case shouldn't happen, and will only surface if the
driver is indeed buggy.  I've thought about this conditional being
removed for awhile, since it will protect against a poorly written
driver wrt locking, but then again a driver behaving like that shouldn't
be making it into the kernel.  That being said, out-of-tree drivers are
heavily used (we have an out-of-tree e1000), and something like this
could be missed.  But since that is the corner case of a crappy driver,
I'm ok with this being removed.

> 
> - Changed some names, like try_get_tx_pkt to dequeue_skb (as 
> that is the work
>   being done and easier to understand) and do_dev_requeue to 
> requeue_skb,

These, at a glance, look very similar to the qdisc ->enqueue() and
->dequeue() function pointers.  I know I had to look a few times to
realize they were separate calls through the qdisc and this new function
name.  Perhaps dequeue_skb() can become dev_dequeue_skb() and
requeue_skb() can be dev_requeue_skb()?  Something that helps
differentiate these from the function pointers of the qdisc_ops might
help distinguish what layer the operation is running on.

> +static inline int handle_dev_cpu_collision(struct sk_buff *skb,
> +					   struct net_device *dev,
> +					   struct Qdisc *q)
>  {
> -	int ret = handle_dev_cpu_collision(dev);
> +	int ret;
>  
> -	if (ret == SCHED_TX_DROP) {
> +	if (unlikely(dev->xmit_lock_owner == smp_processor_id())) {
> +		/*
> +		 * Same CPU holding the lock. It may be a transient
> +		 * configuration error, when hard_start_xmit() 
> recurses. We
> +		 * detect it by checking xmit owner and drop 
> the packet when
> +		 * deadloop is detected. Return OK to try the next skb.
> +		 */
>  		kfree_skb(skb);
> -		return qdisc_qlen(q);
> +		if (net_ratelimit())
> +			printk(KERN_DEBUG "Dead loop on netdevice %s, "
> +			       "fix it urgently!\n", dev->name);
> +		ret = qdisc_qlen(q);
> +	} else {
> +		/*
> +		 * Another cpu is holding lock, requeue & delay 
> xmits for
> +		 * some time.
> +		 */
> +		__get_cpu_var(netdev_rx_stat).cpu_collision++;
> +		ret = requeue_skb(skb, dev, q);
>  	}
>  
> -	return do_dev_requeue(skb, dev, q);
> +	return ret;
>  }

I like the single return here.

>  static inline int qdisc_restart(struct net_device *dev)  {
>  	struct Qdisc *q = dev->qdisc;
> -	unsigned lockless = (dev->features & NETIF_F_LLTX);
>  	struct sk_buff *skb;
> +	unsigned lockless;
>  	int ret;
>  
> -	skb = try_get_tx_pkt(dev, q);
> -	if (skb == NULL)
> +	/* Dequeue packet */
> +	if (unlikely((skb = dequeue_skb(dev, q)) == NULL))
>  		return 0;

I know there's been discussion on the driver side of the world to stop
using unlikely() and likely() clauses.  I personally think it's ok in
situations like this where you have one corner-case conditional without
an else, but it's something to keep in mind when using them in
new/rewritten code like this.

>  	if (!netif_queue_stopped(dev))
>  		ret = dev_hard_start_xmit(skb, dev);

I thought you were removing this check of netif_queue_stopped(dev)?
Nevermind, I see the followup patch takes care of this.

> +	switch (ret) {
> +	case NETDEV_TX_OK:
> +		/* Driver sent out skb successfully */
> +		ret = qdisc_qlen(q);
> +		break;
> +
> +	case NETDEV_TX_LOCKED:
> +		/* Driver try lock failed */
> +		ret = handle_dev_cpu_collision(skb, dev, q);
> +		break;
> +
> +	default:
> +		/* Driver returned NETDEV_TX_BUSY - requeue skb */
> +		ret = requeue_skb(skb, dev, q);
> +		break;
> +	}

Ooo.  I like this; very clean and simple.

The patch looks fine to me outside of the choice of names for
dequeue_skb() and requeue_skb(), but I can be easily swayed.

Cheers,

-PJ Waskiewicz
