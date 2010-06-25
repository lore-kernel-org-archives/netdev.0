From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/8] netpoll: Allow netpoll_setup/cleanup recursion
Date: Thu, 24 Jun 2010 18:21:23 -0700
Message-ID: <20100624182123.45264dfe.akpm@linux-foundation.org>
References: <20100611021142.GA24490@gondor.apana.org.au>
	<E1OMtjk-0006P2-6r@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Qianfeng Zhang <frzhang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	WANG Cong <amwang@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Matt Mackall <mpm@selenic.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@elte.hu>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49991 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751338Ab0FYBV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 21:21:58 -0400
In-Reply-To: <E1OMtjk-0006P2-6r@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Jun 2010 12:12:48 +1000
Herbert Xu <herbert@gondor.hengli.com.au> wrote:

> netpoll: Allow netpoll_setup/cleanup recursion
> 
> This patch adds the functions __netpoll_setup/__netpoll_cleanup
> which is designed to be called recursively through ndo_netpoll_seutp.
> 
> They must be called with RTNL held, and the caller must initialise
> np->dev and ensure that it has a valid reference count.
> 
> ...
>
> -int netpoll_setup(struct netpoll *np)
> +int __netpoll_setup(struct netpoll *np)
>  {
> -	struct net_device *ndev = NULL;
> -	struct in_device *in_dev;
> +	struct net_device *ndev = np->dev;
>  	struct netpoll_info *npinfo;
>  	const struct net_device_ops *ops;
>  	unsigned long flags;
>  	int err;
>  
> +	if ((ndev->priv_flags & IFF_DISABLE_NETPOLL) ||
> +	    !ndev->netdev_ops->ndo_poll_controller) {
> +		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
> +		       np->name, np->dev_name);
> +		err = -ENOTSUPP;
> +		goto out;
> +	}
> +
> +	if (!ndev->npinfo) {
> +		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
> +		if (!npinfo) {
> +			err = -ENOMEM;
> +			goto out;
> +		}
> +
> +		npinfo->rx_flags = 0;
> +		INIT_LIST_HEAD(&npinfo->rx_np);
> +
> +		spin_lock_init(&npinfo->rx_lock);
> +		skb_queue_head_init(&npinfo->arp_tx);
> +		skb_queue_head_init(&npinfo->txq);
> +		INIT_DELAYED_WORK(&npinfo->tx_work, queue_process);
> +
> +		atomic_set(&npinfo->refcnt, 1);
> +
> +		ops = np->dev->netdev_ops;
> +		if (ops->ndo_netpoll_setup) {
> +			err = ops->ndo_netpoll_setup(ndev, npinfo);
> +			if (err)
> +				goto free_npinfo;
> +		}
> +	} else {
> +		npinfo = ndev->npinfo;
> +		atomic_inc(&npinfo->refcnt);
> +	}
> +
> +	npinfo->netpoll = np;
> +
> +	if (np->rx_hook) {
> +		spin_lock_irqsave(&npinfo->rx_lock, flags);
> +		npinfo->rx_flags |= NETPOLL_RX_ENABLED;
> +		list_add_tail(&np->rx, &npinfo->rx_np);
> +		spin_unlock_irqrestore(&npinfo->rx_lock, flags);
> +	}
> +
> +	/* last thing to do is link it to the net device structure */
> +	rcu_assign_pointer(ndev->npinfo, npinfo);
> +	rtnl_unlock();

And there it is, an unbalanced rtnl_unlock().

This stupid little thing took me over a day's work to find - it's just
been awful.

The user-visible symptom was that a bug in the netpoll code causes the
machine to hang after loading ipv6 (!), because
addrconf_fixup_forwarding()'s rtnl_trylock() kept on failing, and the
restart_syscall() kept on getting restarted, so an initscripts procfs
write just kept banging its head against the excessively-unlocked
mutex.

The mutex code handles an excessively-unlocked mutex (mutex.count==2)
really badly.  Some API functions say "its locked", others say "it
isn't", etc.

Maybe it's better with mutex debugging enabled - didn't try that. 
Things get pretty user-unfriendly when there's a bug within the
netconsole code itself.

Enabling lockdep simply made the bug cure itself - I suspect the mutex
code's handling of mutexes is different if lockdep is enabled.  That
would be pretty bad behaviour from the lockdep code.

I just removed the rtnl_unlock() - I couldn't see much in there which
needed rtnl_locking..

Dave, the fixup should be folded into the original patch please -
otherwise we'll have a machine-hangs-up bisection hole which spans two
weeks work of commits.

