From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH] netfilter: replace list_head with single linked list
Date: Wed, 21 Sep 2016 11:46:57 -0400
Message-ID: <f7twpi5uufi.fsf@redhat.com>
References: <1474472107-12992-1-git-send-email-aconole@bytheb.org>
        <1474472107-12992-8-git-send-email-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1474472107-12992-8-git-send-email-aconole@bytheb.org> (Aaron
        Conole's message of "Wed, 21 Sep 2016 11:35:07 -0400")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Aaron Conole <aconole@bytheb.org> writes:

> The netfilter hook list never uses the prev pointer, and so can be trimmed to
> be a simple singly-linked list.
>
> In addition to having a more light weight structure for hook traversal,
> struct net becomes 5568 bytes (down from 6400) and struct net_device becomes
> 2176 bytes (down from 2240).
>
> Signed-off-by: Aaron Conole <aconole@bytheb.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Apologies, all.  This subject prefix is incorrect.  It should be:
[PATCH nf-next v3 7/7]

Should I repost?

> ---
>  include/linux/netdevice.h         |   2 +-
>  include/linux/netfilter.h         |  61 +++++++++--------
>  include/linux/netfilter_ingress.h |  16 +++--
>  include/net/netfilter/nf_queue.h  |   3 +-
>  include/net/netns/netfilter.h     |   2 +-
>  net/bridge/br_netfilter_hooks.c   |  19 ++---
>  net/netfilter/core.c              | 141 +++++++++++++++++++++++++-------------
>  net/netfilter/nf_internals.h      |  10 +--
>  net/netfilter/nf_queue.c          |  18 ++---
>  net/netfilter/nfnetlink_queue.c   |   8 ++-
>  10 files changed, 165 insertions(+), 115 deletions(-)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 67bb978..41f49f5 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1783,7 +1783,7 @@ struct net_device {
>  #endif
>  	struct netdev_queue __rcu *ingress_queue;
>  #ifdef CONFIG_NETFILTER_INGRESS
> -	struct list_head	nf_hooks_ingress;
> +	struct nf_hook_entry __rcu *nf_hooks_ingress;
>  #endif
>  
>  	unsigned char		broadcast[MAX_ADDR_LEN];
> diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
> index ad444f0..17c90b0 100644
> --- a/include/linux/netfilter.h
> +++ b/include/linux/netfilter.h
> @@ -55,12 +55,34 @@ struct nf_hook_state {
>  	struct net_device *out;
>  	struct sock *sk;
>  	struct net *net;
> -	struct list_head *hook_list;
> +	struct nf_hook_entry __rcu *hook_entries;
>  	int (*okfn)(struct net *, struct sock *, struct sk_buff *);
>  };
>  
> +typedef unsigned int nf_hookfn(void *priv,
> +			       struct sk_buff *skb,
> +			       const struct nf_hook_state *state);
> +struct nf_hook_ops {
> +	struct list_head	list;
> +
> +	/* User fills in from here down. */
> +	nf_hookfn		*hook;
> +	struct net_device	*dev;
> +	void			*priv;
> +	u_int8_t		pf;
> +	unsigned int		hooknum;
> +	/* Hooks are ordered in ascending priority. */
> +	int			priority;
> +};
> +
> +struct nf_hook_entry {
> +	struct nf_hook_entry __rcu	*next;
> +	struct nf_hook_ops		ops;
> +	const struct nf_hook_ops	*orig_ops;
> +};
> +
>  static inline void nf_hook_state_init(struct nf_hook_state *p,
> -				      struct list_head *hook_list,
> +				      struct nf_hook_entry *hook_entry,
>  				      unsigned int hook,
>  				      int thresh, u_int8_t pf,
>  				      struct net_device *indev,
> @@ -76,26 +98,11 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
>  	p->out = outdev;
>  	p->sk = sk;
>  	p->net = net;
> -	p->hook_list = hook_list;
> +	RCU_INIT_POINTER(p->hook_entries, hook_entry);
>  	p->okfn = okfn;
>  }
>  
> -typedef unsigned int nf_hookfn(void *priv,
> -			       struct sk_buff *skb,
> -			       const struct nf_hook_state *state);
>  
> -struct nf_hook_ops {
> -	struct list_head 	list;
> -
> -	/* User fills in from here down. */
> -	nf_hookfn		*hook;
> -	struct net_device	*dev;
> -	void			*priv;
> -	u_int8_t		pf;
> -	unsigned int		hooknum;
> -	/* Hooks are ordered in ascending priority. */
> -	int			priority;
> -};
>  
>  struct nf_sockopt_ops {
>  	struct list_head list;
> @@ -161,7 +168,8 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
>  				 int (*okfn)(struct net *, struct sock *, struct sk_buff *),
>  				 int thresh)
>  {
> -	struct list_head *hook_list;
> +	struct nf_hook_entry *hook_head;
> +	int ret = 1;
>  
>  #ifdef HAVE_JUMP_LABEL
>  	if (__builtin_constant_p(pf) &&
> @@ -170,22 +178,19 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
>  		return 1;
>  #endif
>  
> -	hook_list = &net->nf.hooks[pf][hook];
> +	rcu_read_lock();
>  
> -	if (!list_empty(hook_list)) {
> +	hook_head = rcu_dereference(net->nf.hooks[pf][hook]);
> +	if (hook_head) {
>  		struct nf_hook_state state;
> -		int ret;
>  
> -		/* We may already have this, but read-locks nest anyway */
> -		rcu_read_lock();
> -		nf_hook_state_init(&state, hook_list, hook, thresh,
> +		nf_hook_state_init(&state, hook_head, hook, thresh,
>  				   pf, indev, outdev, sk, net, okfn);
>  
>  		ret = nf_hook_slow(skb, &state);
> -		rcu_read_unlock();
> -		return ret;
>  	}
> -	return 1;
> +	rcu_read_unlock();
> +	return ret;
>  }
>  
>  static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
> diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
> index 6965ba0..b02fd80 100644
> --- a/include/linux/netfilter_ingress.h
> +++ b/include/linux/netfilter_ingress.h
> @@ -11,23 +11,29 @@ static inline bool nf_hook_ingress_active(const struct sk_buff *skb)
>  	if (!static_key_false(&nf_hooks_needed[NFPROTO_NETDEV][NF_NETDEV_INGRESS]))
>  		return false;
>  #endif
> -	return !list_empty(&skb->dev->nf_hooks_ingress);
> +	return rcu_access_pointer(skb->dev->nf_hooks_ingress);
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
> +	/* must recheck the ingress hook head, in the event it became NULL
> +	 * after the check in nf_hook_ingress_active evaluated to true. */
> +	if (unlikely(!e))
> +		return 0;
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
> index 66b3f3f..ef4f75d 100644
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
> @@ -25,7 +24,7 @@ struct nf_queue_handler {
>  	int		(*outfn)(struct nf_queue_entry *entry,
>  				 unsigned int queuenum);
>  	void		(*nf_hook_drop)(struct net *net,
> -					struct nf_hook_ops *ops);
> +					const struct nf_hook_entry *hooks);
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
> index 6029af4..2fe9345 100644
> --- a/net/bridge/br_netfilter_hooks.c
> +++ b/net/bridge/br_netfilter_hooks.c
> @@ -1002,28 +1002,21 @@ int br_nf_hook_thresh(unsigned int hook, struct net *net,
>  		      int (*okfn)(struct net *, struct sock *,
>  				  struct sk_buff *))
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
>  	/* We may already have this, but read-locks nest anyway */
>  	rcu_read_lock();
> -	nf_hook_state_init(&state, head, hook, NF_BR_PRI_BRNF + 1,
> +	nf_hook_state_init(&state, elem, hook, NF_BR_PRI_BRNF + 1,
>  			   NFPROTO_BRIDGE, indev, outdev, sk, net, okfn);
>  
>  	ret = nf_hook_slow(skb, &state);
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index 67b7428..360c63d 100644
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
> @@ -61,33 +62,50 @@ EXPORT_SYMBOL(nf_hooks_needed);
>  #endif
>  
>  static DEFINE_MUTEX(nf_hook_mutex);
> +#define nf_entry_dereference(e) \
> +	rcu_dereference_protected(e, lockdep_is_held(&nf_hook_mutex))
>  
> -static struct list_head *nf_find_hook_list(struct net *net,
> -					   const struct nf_hook_ops *reg)
> +static struct nf_hook_entry *nf_hook_entry_head(struct net *net,
> +						const struct nf_hook_ops *reg)
>  {
> -	struct list_head *hook_list = NULL;
> +	struct nf_hook_entry *hook_head = NULL;
>  
>  	if (reg->pf != NFPROTO_NETDEV)
> -		hook_list = &net->nf.hooks[reg->pf][reg->hooknum];
> +		hook_head = nf_entry_dereference(net->nf.hooks[reg->pf]
> +						 [reg->hooknum]);
>  	else if (reg->hooknum == NF_NETDEV_INGRESS) {
>  #ifdef CONFIG_NETFILTER_INGRESS
>  		if (reg->dev && dev_net(reg->dev) == net)
> -			hook_list = &reg->dev->nf_hooks_ingress;
> +			hook_head =
> +				nf_entry_dereference(
> +					reg->dev->nf_hooks_ingress);
>  #endif
>  	}
> -	return hook_list;
> +	return hook_head;
>  }
>  
> -struct nf_hook_entry {
> -	const struct nf_hook_ops	*orig_ops;
> -	struct nf_hook_ops		ops;
> -};
> +/* must hold nf_hook_mutex */
> +static void nf_set_hooks_head(struct net *net, const struct nf_hook_ops *reg,
> +			      struct nf_hook_entry *entry)
> +{
> +	switch (reg->pf) {
> +	case NFPROTO_NETDEV:
> +		/* We already checked in nf_register_net_hook() that this is
> +		 * used from ingress.
> +		 */
> +		rcu_assign_pointer(reg->dev->nf_hooks_ingress, entry);
> +		break;
> +	default:
> +		rcu_assign_pointer(net->nf.hooks[reg->pf][reg->hooknum],
> +				   entry);
> +		break;
> +	}
> +}
>  
>  int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  {
> -	struct list_head *hook_list;
> +	struct nf_hook_entry *hooks_entry;
>  	struct nf_hook_entry *entry;
> -	struct nf_hook_ops *elem;
>  
>  	if (reg->pf == NFPROTO_NETDEV &&
>  	    (reg->hooknum != NF_NETDEV_INGRESS ||
> @@ -100,19 +118,30 @@ int nf_register_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  
>  	entry->orig_ops	= reg;
>  	entry->ops	= *reg;
> +	entry->next	= NULL;
> +
> +	mutex_lock(&nf_hook_mutex);
> +	hooks_entry = nf_hook_entry_head(net, reg);
>  
> -	hook_list = nf_find_hook_list(net, reg);
> -	if (!hook_list) {
> -		kfree(entry);
> -		return -ENOENT;
> +	if (hooks_entry && hooks_entry->orig_ops->priority > reg->priority) {
> +		/* This is the case where we need to insert at the head */
> +		entry->next = hooks_entry;
> +		hooks_entry = NULL;
>  	}
>  
> -	mutex_lock(&nf_hook_mutex);
> -	list_for_each_entry(elem, hook_list, list) {
> -		if (reg->priority < elem->priority)
> -			break;
> +	while (hooks_entry &&
> +	       reg->priority >= hooks_entry->orig_ops->priority &&
> +	       nf_entry_dereference(hooks_entry->next)) {
> +		hooks_entry = nf_entry_dereference(hooks_entry->next);
> +	}
> +
> +	if (hooks_entry) {
> +		entry->next = nf_entry_dereference(hooks_entry->next);
> +		rcu_assign_pointer(hooks_entry->next, entry);
> +	} else {
> +		nf_set_hooks_head(net, reg, entry);
>  	}
> -	list_add_rcu(&entry->ops.list, elem->list.prev);
> +
>  	mutex_unlock(&nf_hook_mutex);
>  #ifdef CONFIG_NETFILTER_INGRESS
>  	if (reg->pf == NFPROTO_NETDEV && reg->hooknum == NF_NETDEV_INGRESS)
> @@ -127,24 +156,33 @@ EXPORT_SYMBOL(nf_register_net_hook);
>  
>  void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  {
> -	struct list_head *hook_list;
> -	struct nf_hook_entry *entry;
> -	struct nf_hook_ops *elem;
> -
> -	hook_list = nf_find_hook_list(net, reg);
> -	if (!hook_list)
> -		return;
> +	struct nf_hook_entry *hooks_entry;
>  
>  	mutex_lock(&nf_hook_mutex);
> -	list_for_each_entry(elem, hook_list, list) {
> -		entry = container_of(elem, struct nf_hook_entry, ops);
> -		if (entry->orig_ops == reg) {
> -			list_del_rcu(&entry->ops.list);
> -			break;
> +	hooks_entry = nf_hook_entry_head(net, reg);
> +	if (hooks_entry->orig_ops == reg) {
> +		nf_set_hooks_head(net, reg,
> +				  nf_entry_dereference(hooks_entry->next));
> +		goto unlock;
> +	}
> +	while (hooks_entry && nf_entry_dereference(hooks_entry->next)) {
> +		struct nf_hook_entry *next =
> +			nf_entry_dereference(hooks_entry->next);
> +		struct nf_hook_entry *nnext;
> +
> +		if (next->orig_ops != reg) {
> +			hooks_entry = next;
> +			continue;
>  		}
> +		nnext = nf_entry_dereference(next->next);
> +		rcu_assign_pointer(hooks_entry->next, nnext);
> +		hooks_entry = next;
> +		break;
>  	}
> +
> +unlock:
>  	mutex_unlock(&nf_hook_mutex);
> -	if (&elem->list == hook_list) {
> +	if (!hooks_entry) {
>  		WARN(1, "nf_unregister_net_hook: hook not found!\n");
>  		return;
>  	}
> @@ -156,10 +194,10 @@ void nf_unregister_net_hook(struct net *net, const struct nf_hook_ops *reg)
>  	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
>  #endif
>  	synchronize_net();
> -	nf_queue_nf_hook_drop(net, &entry->ops);
> +	nf_queue_nf_hook_drop(net, hooks_entry);
>  	/* other cpu might still process nfqueue verdict that used reg */
>  	synchronize_net();
> -	kfree(entry);
> +	kfree(hooks_entry);
>  }
>  EXPORT_SYMBOL(nf_unregister_net_hook);
>  
> @@ -258,10 +296,9 @@ void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n)
>  }
>  EXPORT_SYMBOL(nf_unregister_hooks);
>  
> -unsigned int nf_iterate(struct list_head *head,
> -			struct sk_buff *skb,
> +unsigned int nf_iterate(struct sk_buff *skb,
>  			struct nf_hook_state *state,
> -			struct nf_hook_ops **elemp)
> +			struct nf_hook_entry **entryp)
>  {
>  	unsigned int verdict;
>  
> @@ -269,20 +306,23 @@ unsigned int nf_iterate(struct list_head *head,
>  	 * The caller must not block between calls to this
>  	 * function because of risk of continuing from deleted element.
>  	 */
> -	list_for_each_entry_continue_rcu((*elemp), head, list) {
> -		if (state->thresh > (*elemp)->priority)
> +	while (*entryp) {
> +		if (state->thresh > (*entryp)->ops.priority) {
> +			*entryp = rcu_dereference((*entryp)->next);
>  			continue;
> +		}
>  
>  		/* Optimization: we don't need to hold module
>  		   reference here, since function can't sleep. --RR */
>  repeat:
> -		verdict = (*elemp)->hook((*elemp)->priv, skb, state);
> +		verdict = (*entryp)->ops.hook((*entryp)->ops.priv, skb, state);
>  		if (verdict != NF_ACCEPT) {
>  #ifdef CONFIG_NETFILTER_DEBUG
>  			if (unlikely((verdict & NF_VERDICT_MASK)
>  							> NF_MAX_VERDICT)) {
>  				NFDEBUG("Evil return from %p(%u).\n",
> -					(*elemp)->hook, state->hook);
> +					(*entryp)->ops.hook, state->hook);
> +				*entryp = rcu_dereference((*entryp)->next);
>  				continue;
>  			}
>  #endif
> @@ -290,6 +330,7 @@ repeat:
>  				return verdict;
>  			goto repeat;
>  		}
> +		*entryp = rcu_dereference((*entryp)->next);
>  	}
>  	return NF_ACCEPT;
>  }
> @@ -299,13 +340,13 @@ repeat:
>   * -EPERM for NF_DROP, 0 otherwise.  Caller must hold rcu_read_lock. */
>  int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state)
>  {
> -	struct nf_hook_ops *elem;
> +	struct nf_hook_entry *entry;
>  	unsigned int verdict;
>  	int ret = 0;
>  
> -	elem = list_entry_rcu(state->hook_list, struct nf_hook_ops, list);
> +	entry = rcu_dereference(state->hook_entries);
>  next_hook:
> -	verdict = nf_iterate(state->hook_list, skb, state, &elem);
> +	verdict = nf_iterate(skb, state, &entry);
>  	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
>  		ret = 1;
>  	} else if ((verdict & NF_VERDICT_MASK) == NF_DROP) {
> @@ -314,8 +355,10 @@ next_hook:
>  		if (ret == 0)
>  			ret = -EPERM;
>  	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
> -		int err = nf_queue(skb, elem, state,
> -				   verdict >> NF_VERDICT_QBITS);
> +		int err;
> +
> +		RCU_INIT_POINTER(state->hook_entries, entry);
> +		err = nf_queue(skb, state, verdict >> NF_VERDICT_QBITS);
>  		if (err < 0) {
>  			if (err == -ESRCH &&
>  			   (verdict & NF_VERDICT_FLAG_QUEUE_BYPASS))
> @@ -442,7 +485,7 @@ static int __net_init netfilter_net_init(struct net *net)
>  
>  	for (i = 0; i < ARRAY_SIZE(net->nf.hooks); i++) {
>  		for (h = 0; h < NF_MAX_HOOKS; h++)
> -			INIT_LIST_HEAD(&net->nf.hooks[i][h]);
> +			RCU_INIT_POINTER(net->nf.hooks[i][h], NULL);
>  	}
>  
>  #ifdef CONFIG_PROC_FS
> diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
> index 0655225..e0adb59 100644
> --- a/net/netfilter/nf_internals.h
> +++ b/net/netfilter/nf_internals.h
> @@ -13,13 +13,13 @@
>  
>  
>  /* core.c */
> -unsigned int nf_iterate(struct list_head *head, struct sk_buff *skb,
> -			struct nf_hook_state *state, struct nf_hook_ops **elemp);
> +unsigned int nf_iterate(struct sk_buff *skb, struct nf_hook_state *state,
> +			struct nf_hook_entry **entryp);
>  
>  /* nf_queue.c */
> -int nf_queue(struct sk_buff *skb, struct nf_hook_ops *elem,
> -	     struct nf_hook_state *state, unsigned int queuenum);
> -void nf_queue_nf_hook_drop(struct net *net, struct nf_hook_ops *ops);
> +int nf_queue(struct sk_buff *skb, struct nf_hook_state *state,
> +	     unsigned int queuenum);
> +void nf_queue_nf_hook_drop(struct net *net, const struct nf_hook_entry *entry);
>  int __init netfilter_queue_init(void);
>  
>  /* nf_log.c */
> diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
> index b19ad20..96964a0 100644
> --- a/net/netfilter/nf_queue.c
> +++ b/net/netfilter/nf_queue.c
> @@ -96,14 +96,14 @@ void nf_queue_entry_get_refs(struct nf_queue_entry *entry)
>  }
>  EXPORT_SYMBOL_GPL(nf_queue_entry_get_refs);
>  
> -void nf_queue_nf_hook_drop(struct net *net, struct nf_hook_ops *ops)
> +void nf_queue_nf_hook_drop(struct net *net, const struct nf_hook_entry *entry)
>  {
>  	const struct nf_queue_handler *qh;
>  
>  	rcu_read_lock();
>  	qh = rcu_dereference(net->nf.queue_handler);
>  	if (qh)
> -		qh->nf_hook_drop(net, ops);
> +		qh->nf_hook_drop(net, entry);
>  	rcu_read_unlock();
>  }
>  
> @@ -112,7 +112,6 @@ void nf_queue_nf_hook_drop(struct net *net, struct nf_hook_ops *ops)
>   * through nf_reinject().
>   */
>  int nf_queue(struct sk_buff *skb,
> -	     struct nf_hook_ops *elem,
>  	     struct nf_hook_state *state,
>  	     unsigned int queuenum)
>  {
> @@ -141,7 +140,6 @@ int nf_queue(struct sk_buff *skb,
>  
>  	*entry = (struct nf_queue_entry) {
>  		.skb	= skb,
> -		.elem	= elem,
>  		.state	= *state,
>  		.size	= sizeof(*entry) + afinfo->route_key_size,
>  	};
> @@ -165,11 +163,15 @@ err:
>  
>  void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
>  {
> +	struct nf_hook_entry *hook_entry;
>  	struct sk_buff *skb = entry->skb;
> -	struct nf_hook_ops *elem = entry->elem;
>  	const struct nf_afinfo *afinfo;
> +	struct nf_hook_ops *elem;
>  	int err;
>  
> +	hook_entry = rcu_dereference(entry->state.hook_entries);
> +	elem = &hook_entry->ops;
> +
>  	nf_queue_entry_release_refs(entry);
>  
>  	/* Continue traversal iff userspace said ok... */
> @@ -186,8 +188,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
>  
>  	if (verdict == NF_ACCEPT) {
>  	next_hook:
> -		verdict = nf_iterate(entry->state.hook_list,
> -				     skb, &entry->state, &elem);
> +		verdict = nf_iterate(skb, &entry->state, &hook_entry);
>  	}
>  
>  	switch (verdict & NF_VERDICT_MASK) {
> @@ -198,7 +199,8 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
>  		local_bh_enable();
>  		break;
>  	case NF_QUEUE:
> -		err = nf_queue(skb, elem, &entry->state,
> +		RCU_INIT_POINTER(entry->state.hook_entries, hook_entry);
> +		err = nf_queue(skb, &entry->state,
>  			       verdict >> NF_VERDICT_QBITS);
>  		if (err < 0) {
>  			if (err == -ESRCH &&
> diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
> index 7caa8b0..af832c5 100644
> --- a/net/netfilter/nfnetlink_queue.c
> +++ b/net/netfilter/nfnetlink_queue.c
> @@ -917,12 +917,14 @@ static struct notifier_block nfqnl_dev_notifier = {
>  	.notifier_call	= nfqnl_rcv_dev_event,
>  };
>  
> -static int nf_hook_cmp(struct nf_queue_entry *entry, unsigned long ops_ptr)
> +static int nf_hook_cmp(struct nf_queue_entry *entry, unsigned long entry_ptr)
>  {
> -	return entry->elem == (struct nf_hook_ops *)ops_ptr;
> +	return rcu_access_pointer(entry->state.hook_entries) ==
> +		(struct nf_hook_entry *)entry_ptr;
>  }
>  
> -static void nfqnl_nf_hook_drop(struct net *net, struct nf_hook_ops *hook)
> +static void nfqnl_nf_hook_drop(struct net *net,
> +			       const struct nf_hook_entry *hook)
>  {
>  	struct nfnl_queue_net *q = nfnl_queue_pernet(net);
>  	int i;
