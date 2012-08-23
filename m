From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next v3] net: remove delay at device dismantle
Date: Wed, 22 Aug 2012 23:34:22 -0700
Message-ID: <87txvum80h.fsf@xmission.com>
References: <1345691986.5904.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, gaofeng@cn.fujitsu.com,
	netdev@vger.kernel.org, maheshb@google.com, therbert@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:56336 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab2HWGef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 02:34:35 -0400
In-Reply-To: <1345691986.5904.40.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Thu, 23 Aug 2012 05:19:46 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> From: Eric Dumazet <edumazet@google.com>
>
> I noticed extra one second delay in device dismantle, tracked down to
> a call to dst_dev_event() while some call_rcu() are still in RCU queues.
>
> These call_rcu() were posted by rt_free(struct rtable *rt) calls.
>
> We then wait a little (but one second) in netdev_wait_allrefs() before
> kicking again NETDEV_UNREGISTER.
>
> As the call_rcu() are now completed, dst_dev_event() can do the needed
> device swap on busy dst.
>
> To solve this problem, add a new NETDEV_UNREGISTER_FINAL, called
> after a rcu_barrier(), but outside of RTNL lock.
>
> Use NETDEV_UNREGISTER_FINAL with care !
>
> Change dst_dev_event() handler to react to NETDEV_UNREGISTER_FINAL
>
> Also remove NETDEV_UNREGISTER_BATCH, as its not used anymore after
> IP cache removal.
>
> With help from Gao feng
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> ---
> v3: Gao Feng reported a lockdep issue.
>     I had to change some notifiers to check NETDEV_UNREGISTER_FINAL
>
> v2: NETDEV_UNREGISTER_FINAL called outside of rtnl lock
>     as its more risky, base this patch on net-next
>
>  include/linux/netdevice.h |    2 +-
>  net/core/dev.c            |   22 ++++++++--------------
>  net/core/dst.c            |    2 +-
>  net/core/fib_rules.c      |    3 ++-
>  net/core/rtnetlink.c      |    2 +-
>  net/ipv4/devinet.c        |    6 +++++-
>  net/ipv4/fib_frontend.c   |    8 ++++----
>  net/ipv6/addrconf.c       |    6 +++++-
>  8 files changed, 27 insertions(+), 24 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 4936f09..9ad7fa8 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1553,7 +1553,7 @@ struct packet_type {
>  #define NETDEV_PRE_TYPE_CHANGE	0x000E
>  #define NETDEV_POST_TYPE_CHANGE	0x000F
>  #define NETDEV_POST_INIT	0x0010
> -#define NETDEV_UNREGISTER_BATCH 0x0011
> +#define NETDEV_UNREGISTER_FINAL 0x0011
>  #define NETDEV_RELEASE		0x0012
>  #define NETDEV_NOTIFY_PEERS	0x0013
>  #define NETDEV_JOIN		0x0014
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 088923f..0640d2a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1406,7 +1406,6 @@ rollback:
>  				nb->notifier_call(nb, NETDEV_DOWN, dev);
>  			}
>  			nb->notifier_call(nb, NETDEV_UNREGISTER, dev);
> -			nb->notifier_call(nb, NETDEV_UNREGISTER_BATCH, dev);
>  		}
>  	}
>  
> @@ -1448,7 +1447,6 @@ int unregister_netdevice_notifier(struct notifier_block *nb)
>  				nb->notifier_call(nb, NETDEV_DOWN, dev);
>  			}
>  			nb->notifier_call(nb, NETDEV_UNREGISTER, dev);
> -			nb->notifier_call(nb, NETDEV_UNREGISTER_BATCH, dev);
>  		}
>  	}
>  unlock:
> @@ -1468,7 +1466,8 @@ EXPORT_SYMBOL(unregister_netdevice_notifier);
>  
>  int call_netdevice_notifiers(unsigned long val, struct net_device *dev)
>  {
> -	ASSERT_RTNL();
> +	if (val != NETDEV_UNREGISTER_FINAL)
> +		ASSERT_RTNL();

raw_notifier_call_chain isn't safe without holding some sort of lock.
So removing the ASSERT_RTNL assert here is papering over a bug elsewhere
in this patch.

Without holding a lock for traversing the notifier chain there will
be races with network module load and unload that could corrupt
this list while we are traversing it.
load/unlod.

You already have one of your NETDEV_UNREGISTER_FINAL calls under the
rtnl_lock so it doesn't look like a burden to put the other call under
the rtnl_lock as well.

>  	return raw_notifier_call_chain(&netdev_chain, val, dev);
>  }
>  EXPORT_SYMBOL(call_netdevice_notifiers);
> @@ -5331,10 +5330,6 @@ static void rollback_registered_many(struct list_head *head)
>  		netdev_unregister_kobject(dev);
>  	}
>  
> -	/* Process any work delayed until the end of the batch */
> -	dev = list_first_entry(head, struct net_device, unreg_list);
> -	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
> -
>  	synchronize_net();
>  
>  	list_for_each_entry(dev, head, unreg_list)
> @@ -5787,9 +5782,8 @@ static void netdev_wait_allrefs(struct net_device *dev)
>  
>  			/* Rebroadcast unregister notification */
>  			call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
> -			/* don't resend NETDEV_UNREGISTER_BATCH, _BATCH users
> -			 * should have already handle it the first time */
> -
> +			rcu_barrier();

You have just added an rcu_barrier() under the rtnl_lock.
Can you make this.
			__rtnl_unlock();
                        rcu_barrier();
                        rtnl_lock();

Which will be much better for rtnl_lock hold times.

> +			call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
>  			if (test_bit(__LINK_STATE_LINKWATCH_PENDING,
>  				     &dev->state)) {
>  				/* We must not have linkwatch events
> @@ -5851,9 +5845,8 @@ void netdev_run_todo(void)
>  
>  	__rtnl_unlock();
>  
> -	/* Wait for rcu callbacks to finish before attempting to drain
> -	 * the device list.  This usually avoids a 250ms wait.
> -	 */
> +
> +	/* Wait for rcu callbacks to finish before next phase */
>  	if (!list_empty(&list))
>  		rcu_barrier();
>  
> @@ -5862,6 +5855,8 @@ void netdev_run_todo(void)
>  			= list_first_entry(&list, struct net_device, todo_list);
>  		list_del(&dev->todo_list);

> +		call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
> +

Why are you skipping grapping the rtl_lock here? 

rtnl_lock();
__rtnl_unlock() doesn't look scary.

>  		if (unlikely(dev->reg_state != NETREG_UNREGISTERING)) {
>  			pr_err("network todo '%s' but state %d\n",
>  			       dev->name, dev->reg_state);
> @@ -6256,7 +6251,6 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
>  	   the device is just moving and can keep their slaves up.
>  	*/
>  	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
> -	call_netdevice_notifiers(NETDEV_UNREGISTER_BATCH, dev);
>  	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
>  
>  	/*
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 56d6361..f6593d2 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -374,7 +374,7 @@ static int dst_dev_event(struct notifier_block *this, unsigned long event,
>  	struct dst_entry *dst, *last = NULL;
>  
>  	switch (event) {
> -	case NETDEV_UNREGISTER:
> +	case NETDEV_UNREGISTER_FINAL:
>  	case NETDEV_DOWN:
>  		mutex_lock(&dst_gc_mutex);
>  		for (dst = dst_busy_list; dst; dst = dst->next) {
> diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
> index ab7db83..5850937 100644
> --- a/net/core/fib_rules.c
> +++ b/net/core/fib_rules.c
> @@ -711,15 +711,16 @@ static int fib_rules_event(struct notifier_block *this, unsigned long event,
>  	struct net *net = dev_net(dev);
>  	struct fib_rules_ops *ops;
>  
> -	ASSERT_RTNL();
>  
>  	switch (event) {
>  	case NETDEV_REGISTER:
> +		ASSERT_RTNL();
>  		list_for_each_entry(ops, &net->rules_ops, list)
>  			attach_rules(&ops->rules_list, dev);
>  		break;
>  
>  	case NETDEV_UNREGISTER:
> +		ASSERT_RTNL();
>  		list_for_each_entry(ops, &net->rules_ops, list)
>  			detach_rules(&ops->rules_list, dev);
>  		break;
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 34d975b..c64efcf 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2358,7 +2358,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
>  	case NETDEV_PRE_TYPE_CHANGE:
>  	case NETDEV_GOING_DOWN:
>  	case NETDEV_UNREGISTER:
> -	case NETDEV_UNREGISTER_BATCH:
> +	case NETDEV_UNREGISTER_FINAL:
>  	case NETDEV_RELEASE:
>  	case NETDEV_JOIN:
>  		break;
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index adf273f..6a5e6e4 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -1147,8 +1147,12 @@ static int inetdev_event(struct notifier_block *this, unsigned long event,
>  			 void *ptr)
>  {
>  	struct net_device *dev = ptr;
> -	struct in_device *in_dev = __in_dev_get_rtnl(dev);
> +	struct in_device *in_dev;
>  
> +	if (event == NETDEV_UNREGISTER_FINAL)
> +		goto out;
> +
> +	in_dev = __in_dev_get_rtnl(dev);
>  	ASSERT_RTNL();
>  
>  	if (!in_dev) {
> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 7f073a3..fd7d9ae 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c
> @@ -1041,7 +1041,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
>  static int fib_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
>  {
>  	struct net_device *dev = ptr;
> -	struct in_device *in_dev = __in_dev_get_rtnl(dev);
> +	struct in_device *in_dev;
>  	struct net *net = dev_net(dev);
>  
>  	if (event == NETDEV_UNREGISTER) {
> @@ -1050,9 +1050,11 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
>  		return NOTIFY_DONE;
>  	}
>  
> -	if (!in_dev)
> +	if (event == NETDEV_UNREGISTER_FINAL)
>  		return NOTIFY_DONE;
>  
> +	in_dev = __in_dev_get_rtnl(dev);
> +
>  	switch (event) {
>  	case NETDEV_UP:
>  		for_ifa(in_dev) {
> @@ -1071,8 +1073,6 @@ static int fib_netdev_event(struct notifier_block *this, unsigned long event, vo
>  	case NETDEV_CHANGE:
>  		rt_cache_flush(dev_net(dev), 0);
>  		break;
> -	case NETDEV_UNREGISTER_BATCH:
> -		break;
>  	}
>  	return NOTIFY_DONE;
>  }
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 6bc85f7..e581009 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2566,10 +2566,14 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>  			   void *data)
>  {
>  	struct net_device *dev = (struct net_device *) data;
> -	struct inet6_dev *idev = __in6_dev_get(dev);
> +	struct inet6_dev *idev;
>  	int run_pending = 0;
>  	int err;
>  
> +	if (event == NETDEV_UNREGISTER_FINAL)
> +		return NOTIFY_DONE;
> +
> +	idev = __in6_dev_get(dev);
>  	switch (event) {
>  	case NETDEV_REGISTER:
>  		if (!idev && dev->mtu >= IPV6_MIN_MTU) {
