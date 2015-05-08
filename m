From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 00/11] netns: don't switch namespace while creating kernel sockets
Date: Fri, 08 May 2015 12:36:56 -0500
Message-ID: <87sib76kef.fsf@x220.int.ebiederm.org>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
	<87wq0kcqlm.fsf@x220.int.ebiederm.org>
	<20150508140733.GA13325@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ying Xue <ying.xue@windriver.com>, netdev@vger.kernel.org,
	cwang@twopensource.com, xemul@openvz.org, davem@davemloft.net,
	eric.dumazet@gmail.com, maxk@qti.qualcomm.com,
	stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:52370 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932079AbbEHRld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 13:41:33 -0400
In-Reply-To: <20150508140733.GA13325@gondor.apana.org.au> (Herbert Xu's
	message of "Fri, 8 May 2015 22:07:33 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Thu, May 07, 2015 at 11:14:13AM -0500, Eric W. Biederman wrote:
>>
>> The following change shows how it is possible to always know that your
>> network namespace has a non-zero reference count in the network
>> namespace initialization methods.  My implementation of
>> lock_network_namespaces is problematic in that it does not sleep
>> while network namespaces are unregistering.  But it is enough to show
>> how the locking and reference counting can be fixed.
>
> If name spaces are created/deleted constantly this could take
> a long time.  How about forcibly cleaning up entries when we
> register a new op?

That certainly seems more sensible than waiting for an indefinite amount
of time, and the code looks reasonably sound.  Placing on things on
lists and then not removing them, and then later stomping the list
pointers gives me flashbacks of other bugs I have fought, but we already
do that in this code, and in this context it appears harmless.

So overall I think I like it.

At the same time while a network namespace remains discoverable we might
be using it in small ways.  So I am wondering if this is the right
approach.

It really is invalid for a network namespace init routine to grab the
reference count of it's network namespace (thus making the network
namespace unfreeable).  So I am wondering if perhaps all we need to do
is find a clean refactoring of the socket code so this case does not
come up at all.

Perhaps just a flag that says this is a kernel socket so don't get/put
the refcount on the network namespace.  

> ---8<---
> Subject: netns: Do not init dead nets when registering new op
>
> Currently when a new op is registered we will initialise all
> current namespaces through that op, even those that are zombies
> (zero ref count).  This is bad because it puts the onus on each
> op implementor to deal with this and they are bound to slip up.
>
> This patch fixes this by only initialising live namespaces.
>
> This however brings about a new problem as when those zombies
> are eventually cleaned up we will call op->exit even on them
> even though they have not been initialised.
>
> This is fixed by bringing forward parts of the work of the cleanup
> thread and performing them during registration.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
> index f733656..4931100 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -133,6 +133,7 @@ struct net {
>  #endif
>  	struct sock		*diag_nlsk;
>  	atomic_t		fnhe_genid;
> +	bool			dead;
>  };
>  
>  #include <linux/seq_file_net.h>
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index 78fc04a..1f888a7 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -339,41 +339,38 @@ struct net *copy_net_ns(unsigned long flags,
>  	return net;
>  }
>  
> -static DEFINE_SPINLOCK(cleanup_list_lock);
> -static LIST_HEAD(cleanup_list);  /* Must hold cleanup_list_lock to touch */
> -
> -static void cleanup_net(struct work_struct *work)
> +static void unlink_net(struct net *net, struct list_head *net_exit_list)
>  {
> -	const struct pernet_operations *ops;
> -	struct net *net, *tmp;
> -	struct list_head net_kill_list;
> -	LIST_HEAD(net_exit_list);
> +	struct net *tmp;
>  
> -	/* Atomically snapshot the list of namespaces to cleanup */
> -	spin_lock_irq(&cleanup_list_lock);
> -	list_replace_init(&cleanup_list, &net_kill_list);
> -	spin_unlock_irq(&cleanup_list_lock);
> +	if (net->dead)
> +		return;
>  
> -	mutex_lock(&net_mutex);
> +	net->dead = true;
> +
> +	list_add_tail(&net->exit_list, net_exit_list);
>  
>  	/* Don't let anyone else find us. */
>  	rtnl_lock();
> -	list_for_each_entry(net, &net_kill_list, cleanup_list) {
> -		list_del_rcu(&net->list);
> -		list_add_tail(&net->exit_list, &net_exit_list);
> -		for_each_net(tmp) {
> -			int id = __peernet2id(tmp, net, false);
> +	list_del_rcu(&net->list);
>  
> -			if (id >= 0) {
> -				rtnl_net_notifyid(tmp, net, RTM_DELNSID, id);
> -				idr_remove(&tmp->netns_ids, id);
> -			}
> -		}
> -		idr_destroy(&net->netns_ids);
> +	for_each_net(tmp) {
> +		int id = __peernet2id(tmp, net, false);
>  
> +		if (id >= 0) {
> +			rtnl_net_notifyid(tmp, net, RTM_DELNSID, id);
> +			idr_remove(&tmp->netns_ids, id);
> +		}
>  	}
>  	rtnl_unlock();
>  
> +	idr_destroy(&net->netns_ids);
> +}
> +
> +static void exit_all_ops(struct list_head *net_exit_list)
> +{
> +	const struct pernet_operations *ops;
> +
>  	/*
>  	 * Another CPU might be rcu-iterating the list, wait for it.
>  	 * This needs to be before calling the exit() notifiers, so
> @@ -383,11 +380,33 @@ static void cleanup_net(struct work_struct *work)
>  
>  	/* Run all of the network namespace exit methods */
>  	list_for_each_entry_reverse(ops, &pernet_list, list)
> -		ops_exit_list(ops, &net_exit_list);
> +		ops_exit_list(ops, net_exit_list);
>  
>  	/* Free the net generic variables */
>  	list_for_each_entry_reverse(ops, &pernet_list, list)
> -		ops_free_list(ops, &net_exit_list);
> +		ops_free_list(ops, net_exit_list);
> +}
> +
> +static DEFINE_SPINLOCK(cleanup_list_lock);
> +static LIST_HEAD(cleanup_list);  /* Must hold cleanup_list_lock to touch */
> +
> +static void cleanup_net(struct work_struct *work)
> +{
> +	struct list_head net_kill_list;
> +	struct net *net, *tmp;
> +	LIST_HEAD(net_exit_list);
> +
> +	/* Atomically snapshot the list of namespaces to cleanup */
> +	spin_lock_irq(&cleanup_list_lock);
> +	list_replace_init(&cleanup_list, &net_kill_list);
> +	spin_unlock_irq(&cleanup_list_lock);
> +
> +	mutex_lock(&net_mutex);
> +
> +	list_for_each_entry(net, &net_kill_list, cleanup_list)
> +		unlink_net(net, &net_exit_list);
> +
> +	exit_all_ops(&net_exit_list);
>  
>  	mutex_unlock(&net_mutex);
>  
> @@ -397,8 +416,7 @@ static void cleanup_net(struct work_struct *work)
>  	rcu_barrier();
>  
>  	/* Finally it is safe to free my network namespace structure */
> -	list_for_each_entry_safe(net, tmp, &net_exit_list, exit_list) {
> -		list_del_init(&net->exit_list);
> +	list_for_each_entry_safe(net, tmp, &net_kill_list, cleanup_list) {
>  		put_user_ns(net->user_ns);
>  		net_drop_ns(net);
>  	}
> @@ -727,30 +745,59 @@ static int __init net_ns_init(void)
>  pure_initcall(net_ns_init);
>  
>  #ifdef CONFIG_NET_NS
> +static void grab_all_nets(struct list_head *all_net_list)
> +{
> +	struct net *net;
> +	LIST_HEAD(net_exit_list);
> +
> +	for_each_net(net) {
> +		if (maybe_get_net(net)) 
> +			list_add_tail(&net->cleanup_list, all_net_list);
> +		else
> +			unlink_net(net, &net_exit_list);
> +	}
> +
> +	exit_all_ops(&net_exit_list);
> +}
> +
> +static void drop_all_nets(struct list_head *all_net_list)
> +{
> +	struct net *net, *next;
> +
> +	list_for_each_entry_safe(net, next, all_net_list, cleanup_list)
> +		put_net(net);
> +}
> +
>  static int __register_pernet_operations(struct list_head *list,
>  					struct pernet_operations *ops)
>  {
>  	struct net *net;
> -	int error;
> +	int error = 0;
> +	LIST_HEAD(all_net_list);
>  	LIST_HEAD(net_exit_list);
>  
> +	grab_all_nets(&all_net_list);
> +
>  	list_add_tail(&ops->list, list);
>  	if (ops->init || (ops->id && ops->size)) {
> -		for_each_net(net) {
> +		list_for_each_entry(net, &all_net_list, cleanup_list) {
>  			error = ops_init(ops, net);
>  			if (error)
>  				goto out_undo;
>  			list_add_tail(&net->exit_list, &net_exit_list);
>  		}
>  	}
> -	return 0;
> +
> +out_drop_nets:
> +	drop_all_nets(&all_net_list);
> +	return error;
>  
>  out_undo:
>  	/* If I have an error cleanup all namespaces I initialized */
>  	list_del(&ops->list);
>  	ops_exit_list(ops, &net_exit_list);
>  	ops_free_list(ops, &net_exit_list);
> -	return error;
> +	goto out_drop_nets;
>  }
>  
>  static void __unregister_pernet_operations(struct pernet_operations *ops)
