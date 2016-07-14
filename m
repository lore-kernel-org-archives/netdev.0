From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v2 3/3] netfilter: replace list_head with single linked
 list
Date: Thu, 14 Jul 2016 19:58:12 +0200
Message-ID: <20160714175812.GA1021@salvia>
References: <1468337541-23930-1-git-send-email-aconole@bytheb.org>
 <1468337541-23930-4-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Florian Westphal <fw@strlen.de>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1468337541-23930-4-git-send-email-aconole@bytheb.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 12, 2016 at 11:32:21AM -0400, Aaron Conole wrote:
> The netfilter hook list never uses the prev pointer, and so can be
> trimmed to be a smaller singly-linked list.
> 
> In addition to having a more light weight structure for hook traversal,
> struct net becomes 5568 bytes (down from 6400) and struct net_device
> becomes 2176 bytes (down from 2240).
> 
> Signed-off-by: Aaron Conole <aconole@bytheb.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
> v2:
> * Adjusted the hook list head function, and retested with rcu and lockdep
>   debugging enabled.
> 
>  include/linux/netdevice.h         |   2 +-
>  include/linux/netfilter.h         |  18 +++---
>  include/linux/netfilter_ingress.h |  14 +++--
>  include/net/netfilter/nf_queue.h  |   9 ++-
>  include/net/netns/netfilter.h     |   2 +-
>  net/bridge/br_netfilter_hooks.c   |  21 +++----
>  net/netfilter/core.c              | 127 ++++++++++++++++++++++++--------------
>  net/netfilter/nf_internals.h      |  10 +--
>  net/netfilter/nf_queue.c          |  15 +++--
>  net/netfilter/nfnetlink_queue.c   |   5 +-
>  10 files changed, 130 insertions(+), 93 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 49736a3..9da07ad 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1749,7 +1749,7 @@ struct net_device {
>  #endif
>  	struct netdev_queue __rcu *ingress_queue;
>  #ifdef CONFIG_NETFILTER_INGRESS
> -	struct list_head	nf_hooks_ingress;
> +	struct nf_hook_entry __rcu *nf_hooks_ingress;
>  #endif
>  
>  	unsigned char		broadcast[MAX_ADDR_LEN];
> diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
> index ad444f0..3390a84 100644
> --- a/include/linux/netfilter.h
> +++ b/include/linux/netfilter.h
> @@ -55,12 +55,12 @@ struct nf_hook_state {
>  	struct net_device *out;
>  	struct sock *sk;
>  	struct net *net;
> -	struct list_head *hook_list;
> +	struct nf_hook_entry *hook_list;
>  	int (*okfn)(struct net *, struct sock *, struct sk_buff *);
>  };
>  
>  static inline void nf_hook_state_init(struct nf_hook_state *p,
> -				      struct list_head *hook_list,
> +				      struct nf_hook_entry *hook_list,
>  				      unsigned int hook,
>  				      int thresh, u_int8_t pf,
>  				      struct net_device *indev,
> @@ -97,6 +97,12 @@ struct nf_hook_ops {
>  	int			priority;
>  };
>  
> +struct nf_hook_entry {
> +	struct nf_hook_entry __rcu	*next;
> +	struct nf_hook_ops		ops;
> +	const struct nf_hook_ops	*orig_ops;
> +};
> +
>  struct nf_sockopt_ops {
>  	struct list_head list;
>  
> @@ -161,8 +167,6 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
>  				 int (*okfn)(struct net *, struct sock *, struct sk_buff *),
>  				 int thresh)
>  {
> -	struct list_head *hook_list;
> -
>  #ifdef HAVE_JUMP_LABEL
>  	if (__builtin_constant_p(pf) &&
>  	    __builtin_constant_p(hook) &&
> @@ -170,14 +174,14 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
>  		return 1;
>  #endif
>  
> -	hook_list = &net->nf.hooks[pf][hook];
> -

You have to place rcu_read_lock() here, see below.

> -	if (!list_empty(hook_list)) {
> +	if (rcu_access_pointer(net->nf.hooks[pf][hook])) {

This check above is out of the rcu read-side section, here this may
evaluate true...

> +		struct nf_hook_entry *hook_list;
>  		struct nf_hook_state state;
>  		int ret;
>  
>  		/* We may already have this, but read-locks nest anyway */
>  		rcu_read_lock();
> +		hook_list = rcu_dereference(net->nf.hooks[pf][hook]);

... but then, net->nf.hooks[pf][hook]) may have become NULL, I guess
this race will result in a crash.

General note on this patchset: With linked-lists, it was always true
that net->nf.hooks[pf][hook] is non-NULL since this was pointing to
the list head. After this patch this no longer true, that means we
have to be more careful ;).

>  		nf_hook_state_init(&state, hook_list, hook, thresh,
>  				   pf, indev, outdev, sk, net, okfn);
>  
> diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
> index 6965ba0..e3e3f6d 100644
> --- a/include/linux/netfilter_ingress.h
> +++ b/include/linux/netfilter_ingress.h
> @@ -11,23 +11,27 @@ static inline bool nf_hook_ingress_active(const struct sk_buff *skb)
>  	if (!static_key_false(&nf_hooks_needed[NFPROTO_NETDEV][NF_NETDEV_INGRESS]))
>  		return false;
>  #endif
> -	return !list_empty(&skb->dev->nf_hooks_ingress);
> +	return rcu_access_pointer(skb->dev->nf_hooks_ingress) != NULL;
>  }
>  
>  /* caller must hold rcu_read_lock */
>  static inline int nf_hook_ingress(struct sk_buff *skb)
>  {
> +	struct nf_hook_entry *e = rcu_dereference(skb->dev->nf_hooks_ingress);
>  	struct nf_hook_state state;
>  
> -	nf_hook_state_init(&state, &skb->dev->nf_hooks_ingress,
> -			   NF_NETDEV_INGRESS, INT_MIN, NFPROTO_NETDEV,
> -			   skb->dev, NULL, NULL, dev_net(skb->dev), NULL);
> +	if (unlikely(!e))
> +		return 0;

This check is correct since nf_hook_ingress_active() may have
evaluated true, but that may be now gone. You probably want to add a
comment here above so we remember why we need this check.

> +
> +	nf_hook_state_init(&state, e, NF_NETDEV_INGRESS, INT_MIN,
> +			   NFPROTO_NETDEV, skb->dev, NULL, NULL,
> +			   dev_net(skb->dev), NULL);
>  	return nf_hook_slow(skb, &state);
>  }
>  
>  static inline void nf_hook_ingress_init(struct net_device *dev)
>  {
> -	INIT_LIST_HEAD(&dev->nf_hooks_ingress);
> +	RCU_INIT_POINTER(dev->nf_hooks_ingress, NULL);
>  }
>  #else /* CONFIG_NETFILTER_INGRESS */
>  static inline int nf_hook_ingress_active(struct sk_buff *skb)
> diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
> index 0dbce55..1da5bc0 100644
> --- a/include/net/netfilter/nf_queue.h
> +++ b/include/net/netfilter/nf_queue.h
> @@ -11,7 +11,6 @@ struct nf_queue_entry {
>  	struct sk_buff		*skb;
>  	unsigned int		id;
>  
> -	struct nf_hook_ops	*elem;
>  	struct nf_hook_state	state;
>  	u16			size; /* sizeof(entry) + saved route keys */
>  
> @@ -22,10 +21,10 @@ struct nf_queue_entry {
>  
>  /* Packet queuing */
>  struct nf_queue_handler {
> -	int			(*outfn)(struct nf_queue_entry *entry,
> -					 unsigned int queuenum);
> -	void			(*nf_hook_drop)(struct net *net,
> -						struct nf_hook_ops *ops);
> +	int		(*outfn)(struct nf_queue_entry *entry,
> +				 unsigned int queuenum);
> +	void		(*nf_hook_drop)(struct net *net,
> +					const struct nf_hook_entry *ops);

This patch is rather large, so please place this cleanup in a
separated patch.

>  };
>  
>  void nf_register_queue_handler(struct net *net, const struct nf_queue_handler *qh);
> diff --git a/include/net/netns/netfilter.h b/include/net/netns/netfilter.h
> index 36d7235..58487b1 100644
> --- a/include/net/netns/netfilter.h
> +++ b/include/net/netns/netfilter.h
> @@ -16,6 +16,6 @@ struct netns_nf {
>  #ifdef CONFIG_SYSCTL
>  	struct ctl_table_header *nf_log_dir_header;
>  #endif
> -	struct list_head hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
> +	struct nf_hook_entry __rcu *hooks[NFPROTO_NUMPROTO][NF_MAX_HOOKS];
>  };
>  #endif
> diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
> index 7856129..56a87ed 100644
> --- a/net/bridge/br_netfilter_hooks.c
> +++ b/net/bridge/br_netfilter_hooks.c
> @@ -1000,28 +1000,21 @@ int br_nf_hook_thresh(unsigned int hook, struct net *net,
>  		      struct net_device *indev,
>  		      struct net_device *outdev,
>  		      int (*okfn)(struct net *, struct sock *,
> -				  struct sk_buf *))
> +				  struct sk_buff *))

I see, this is fixing the problem spotted by 1/3.

>  {
> -	struct nf_hook_ops *elem;
> +	struct nf_hook_entry *elem;
>  	struct nf_hook_state state;
> -	struct list_head *head;
>  	int ret;
>  
> -	head = &net->nf.hooks[NFPROTO_BRIDGE][hook];
> +	elem = rcu_dereference(net->nf.hooks[NFPROTO_BRIDGE][hook]);
>  
> -	list_for_each_entry_rcu(elem, head, list) {
> -		struct nf_hook_ops *next;
> +	while (elem && (elem->ops.priority <= NF_BR_PRI_BRNF))
> +		elem = rcu_dereference(elem->next);
>  
> -		next = list_entry_rcu(list_next_rcu(&elem->list),
> -				      struct nf_hook_ops, list);
> -		if (next->priority <= NF_BR_PRI_BRNF)
> -			continue;
> -	}
> -
> -	if (&elem->list == head)
> +	if (!elem)
>  		return okfn(net, sk, skb);
>  
> -	nf_hook_state_init(&state, head, hook, NF_BR_PRI_BRNF + 1,
> +	nf_hook_state_init(&state, elem, hook, NF_BR_PRI_BRNF + 1,
>  			   NFPROTO_BRIDGE, indev, outdev, sk, net, okfn);
>  
>  	ret = nf_hook_slow(skb, &state);
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index 6561d5c..ac64305 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -22,6 +22,7 @@
>  #include <linux/proc_fs.h>
>  #include <linux/mutex.h>
>  #include <linux/slab.h>
> +#include <linux/rcupdate.h>
>  #include <net/net_namespace.h>
>  #include <net/sock.h>
>  
> @@ -61,33 +62,53 @@ EXPORT_SYMBOL(nf_hooks_needed);
>  #endif
>  
>  static DEFINE_MUTEX(nf_hook_mutex);
> +#define nf_entry_dereference(e) \
> +	rcu_dereference_protected(e, lockdep_is_held(&nf_hook_mutex))
>  
> -static struct list_head *nf_find_hook_list(struct net *net,
> -					   const struct nf_hook_ops *reg)
> +static struct nf_hook_entry *nf_find_hook_list(struct net *net,
> +					       const struct nf_hook_ops *reg)

I find confusing that this function and further references in the code
keep using the hook_list notion, which actually used to refer to list
head. After this patch we get the first hook entry instead.

>  {
> -	struct list_head *hook_list = NULL;
> +	struct nf_hook_entry *hook_list = NULL;
>  
>  	if (reg->pf != NFPROTO_NETDEV)
> -		hook_list = &net->nf.hooks[reg->pf][reg->hooknum];
> +		hook_list = nf_entry_dereference(net->nf.hooks[reg->pf]
> +						 [reg->hooknum]);
>  	else if (reg->hooknum == NF_NETDEV_INGRESS) {
>  #ifdef CONFIG_NETFILTER_INGRESS
>  		if (reg->dev && dev_net(reg->dev) == net)
> -			hook_list = &reg->dev->nf_hooks_ingress;
> +			hook_list =
> +				nf_entry_dereference(
> +					reg->dev->nf_hooks_ingress);
>  #endif
>  	}
>  	return hook_list;
>  }
>  
> -struct nf_hook_entry {
> -	const struct nf_hook_ops	*orig_ops;
> -	struct nf_hook_ops		ops;
> -};
> +/* must hold nf_hook_mutex */
> +static void nf_set_hook_list(struct net *net, const struct nf_hook_ops *reg,
> +			     struct nf_hook_entry *e)

I don't 

> +{
> +	if (reg->pf != NFPROTO_NETDEV) {
> +		rcu_assign_pointer(net->nf.hooks[reg->pf][reg->hooknum], e);
> +#ifdef CONFIG_NETFILTER_INGRESS
> +	} else if (reg->hooknum == NF_NETDEV_INGRESS) {
> +		rcu_assign_pointer(reg->dev->nf_hooks_ingress, e);
> +#endif
> +	} else {
> +		net_warn_ratelimited("pf %d, hooknum %d: not set\n",
> +				     reg->pf, reg->hooknum);

This ugly warning will not ever happen because of the sanity extra
check you perform a bit below, right?

You can probably simplify this code to make it look like this?

        switch (reg->pf) {
        case NFPROTO_NETDEV:
                /* We already checked in nf_register_net_hook() that this is
                 * used from ingress.
                 */
                rcu_assign_pointer(reg->dev->nf_hooks_ingress, e);
                break;
        default:
                rcu_assign_pointer(net->nf.hooks[reg->pf][reg->hooknum], e);
                break;
        }

> +	}
> +}
>  
>  int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  {
> -	struct list_head *hook_list;
> +	struct nf_hook_entry *hook_list;
>  	struct nf_hook_entry *entry;
> -	struct nf_hook_ops *elem;
> +
> +	if (reg->pf == NFPROTO_NETDEV &&
> +	    (reg->hooknum != NF_NETDEV_INGRESS ||
> +	     !reg->dev || dev_net(reg->dev) != net))
> +		return -EINVAL;

I'm fine you want to make sure caller pass sane things to us. However,
given the complexity of this patch, I'd suggest you place this in a
separated patch.

>  	entry = kmalloc(sizeof(*entry), GFP_KERNEL);
>  	if (!entry)
> @@ -96,18 +117,20 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  	entry->orig_ops	= reg;
>  	entry->ops	= *reg;
>  
> +	mutex_lock(&nf_hook_mutex);
>  	hook_list = nf_find_hook_list(net, reg);

We have to rename nf_find_hook_list() so this show we're fetching the
first entry, we don't have a hook_list anymore, this is confusing.

> -	if (!hook_list) {
> -		kfree(entry);
> -		return -ENOENT;
> +	entry->next = hook_list;
> +	while (hook_list && reg->priority >= hook_list->orig_ops->priority &&
> +	       hook_list->next) {
> +		hook_list = nf_entry_dereference(hook_list->next);
>  	}
>  
> -	mutex_lock(&nf_hook_mutex);
> -	list_for_each_entry(elem, hook_list, list) {
> -		if (reg->priority < elem->priority)
> -			break;
> +	if (hook_list) {
> +		entry->next = hook_list->next;

I'm a bit confused that we use nf_entry_dereference() just a few lines
above but here we don't. Did you test this with rcu lockdep
instrumention?

> +		rcu_assign_pointer(hook_list->next, entry);
> +	} else {
> +		nf_set_hook_list(net, reg, entry);

nf_hook_set_first_entry() ? Not very enthusiastic about this name here
though, but this nf_set_hook_list() seems misleading. Probably we can
abstract this open-coded list in a better way?

>  	}
> -	list_add_rcu(&entry->ops.list, elem->list.prev);
>  	mutex_unlock(&nf_hook_mutex);
>  #ifdef CONFIG_NETFILTER_INGRESS
>  	if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)
> @@ -122,24 +145,34 @@ EXPORT_SYMBOL(nf_register_net_hook);
>  
>  void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  {
> -	struct list_head *hook_list;
>  	struct nf_hook_entry *entry;
> -	struct nf_hook_ops *elem;
> -
> -	hook_list = nf_find_hook_list(net, reg);
> -	if (!hook_list)
> -		return;
>  
>  	mutex_lock(&nf_hook_mutex);
> -	list_for_each_entry(elem, hook_list, list) {
> -		entry = container_of(elem, struct nf_hook_entry, ops);
> -		if (entry->orig_ops == reg) {
> -			list_del_rcu(&entry->ops.list);
> -			break;
> +	entry = nf_find_hook_list(net, reg);
> +	if (!entry)
> +		goto unlocked;
> +
> +	if (entry->orig_ops == reg) {
> +		nf_set_hook_list(net, reg,
> +				 nf_entry_dereference(entry->next));
> +	} else {
> +		while (entry && entry->next) {
> +			struct nf_hook_entry *next =
> +				nf_entry_dereference(entry->next);

Missing line break here between variable definition and body.

> +			if (next->orig_ops == reg) {

I'd suggest:

                        if (next->orig_ops != reg)
                                continue;

So we get one level less of indentation here, you can get *nn declared
above.

> +				struct nf_hook_entry *nn =
> +					nf_entry_dereference(next->next);

Missing line break.

> +				rcu_assign_pointer(entry->next, nn);
> +				entry = next;
> +				break;
> +			}
>  		}
>  	}
> +
> +unlocked:

All this rework for nf_unregister_net_hook() looks a bit convoluted to
me.

Could you check if you can implement entry iterators for walking
entries instead?

>  	mutex_unlock(&nf_hook_mutex);
> -	if (&elem->list == hook_list) {
> +
> +	if (!entry) {
>  		WARN(1, "nf_unregister_net_hook: hook not found!\n");
>  		return;
>  	}
> @@ -151,7 +184,7 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
>  #endif
>  	synchronize_net();
> -	nf_queue_nf_hook_drop(net, &entry->ops);
> +	nf_queue_nf_hook_drop(net, entry);
>  	/* other cpu might still process nfqueue verdict that used reg */
>  	synchronize_net();
>  	kfree(entry);
> @@ -193,6 +226,8 @@ int nf_register_hook(struct nf_hook_ops *reg)
>  	struct net *net, *last;
>  	int ret;
>  
> +	WARN_ON(reg->priv);

Why this?

>  	rtnl_lock();
>  	for_each_net(net) {
>  		ret = nf_register_net_hook(net, reg);
> @@ -253,10 +288,9 @@ void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n)
>  }
>  EXPORT_SYMBOL(nf_unregister_hooks);
>  
> -unsigned int nf_iterate(struct list_head *head,
> -			struct sk_buff *skb,
> +unsigned int nf_iterate(struct sk_buff *skb,
>  			struct nf_hook_state *state,
> -			struct nf_hook_ops **elemp)
> +			struct nf_hook_entry **elemp)
>  {
>  	unsigned int verdict;
>  
> @@ -264,20 +298,20 @@ unsigned int nf_iterate(struct list_head *head,
>  	 * The caller must not block between calls to this
>  	 * function because of risk of continuing from deleted element.
>  	 */
> -	list_for_each_entry_continue_rcu((*elemp), head, list) {
> -		if (state->thresh > (*elemp)->priority)
> +	while (*elemp) {
> +		if (state->thresh > (*elemp)->ops.priority)
>  			continue;
>  
>  		/* Optimization: we don't need to hold module
>  		   reference here, since function can't sleep. --RR */
>  repeat:
> -		verdict = (*elemp)->hook((*elemp)->priv, skb, state);
> +		verdict = (*elemp)->ops.hook((*elemp)->ops.priv, skb, state);
>  		if (verdict != NF_ACCEPT) {
>  #ifdef CONFIG_NETFILTER_DEBUG
>  			if (unlikely((verdict & NF_VERDICT_MASK)
>  							> NF_MAX_VERDICT)) {
>  				NFDEBUG("Evil return from %p(%u).\n",
> -					(*elemp)->hook, state->hook);
> +					(*elemp)->ops.hook, state->hook);
>  				continue;
>  			}
>  #endif
> @@ -285,6 +319,7 @@ repeat:
>  				return verdict;
>  			goto repeat;
>  		}
> +		*elemp = (*elemp)->next;

No rcu_dereference() to fetch the next entry?

>  	}
>  	return NF_ACCEPT;
>  }
> @@ -295,13 +330,13 @@ repeat:
>   * -EPERM for NF_DROP, 0 otherwise. */
>  int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
>  {
> -	struct nf_hook_ops *elem;
> +	struct nf_hook_entry *elem;

        struct nf_hook_entry *entry;

>  	unsigned int verdict;
>  	int ret = 0;
>  
> -	elem = list_entry_rcu(state->hook_list, struct nf_hook_ops, list);
> +	elem = state->hook_list;
>  next_hook:
> -	verdict = nf_iterate(state->hook_list, skb, state, &elem);
> +	verdict = nf_iterate(skb, state, &elem);
>  	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
>  		ret = 1;
>  	} else if ((verdict & NF_VERDICT_MASK) == NF_DROP) {
> @@ -310,8 +345,10 @@ next_hook:
>  		if (ret == 0)
>  			ret = -EPERM;
>  	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
> -		int err = nf_queue(skb, elem, state,
> -				   verdict >> NF_VERDICT_QBITS);
> +		int err;
> +
> +		state->hook_list = elem;

Will this work in terms of escapability? Scenario: 1) packet is
enqueued, 2) hook is gone and 3) userspace reinjects the packet. In
that case we hold a reference to an entry that doesn't exist anymore.

Ok, I'm stopping here, I think this needs another spin.

Thanks!
