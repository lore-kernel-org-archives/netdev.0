From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: nf_qeueue: Drop queue entries on
 nf_unregister_hook
Date: Sat, 20 Jun 2015 12:57:38 +0200
Message-ID: <20150620105738.GA3439@salvia>
References: <878ubffron.fsf@x220.int.ebiederm.org>
 <871th7frlg.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35617 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754008AbbFTKwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Jun 2015 06:52:22 -0400
Content-Disposition: inline
In-Reply-To: <871th7frlg.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 19, 2015 at 02:03:39PM -0500, Eric W. Biederman wrote:
> 
> Add code to nf_unregister_hook to flush the nf_queue when a hook is
> unregistered.  This guarantees that the pointer that the nf_queue code
> retains into the nf_hook list will remain valid while a packet is
> queued.

I think the real problem is that struct nf_queue_entry holds a pointer
to struct nf_hook_ops, which will be gone after removal. So you
uncovered a long standing problem that will amplify by when pernet
hooks are in place.

Regarding the pointer to nf_hook_list, now that new netdevice variant
doesn't support nf_queue yet, so that nf_hook_list will be always
valid since it will point to the global nf_hooks in the core.

> I tested what would happen if we do not flush queued packets and was
> trivially able to obtain the oops below.  All that was required was
> to stop the nf_queue listening process, to delete all of the nf_tables,
> and to awaken the nf_queue listening process.
[...]

Please, route netfilter patches through the netfilter trees, ie. nf
and nf-next.

> Cc: stable@vger.kernel.org

I guess this is a leftover since there is no Cc to stable. Anyway,
we have to wait until this hits master before we ask for -stable
inclusion.

More comments below. Thanks for this fix BTW.

> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
> 
> Apologies for the duplicate send but I forgot to include the appropriate
> mailing lists.
> 
>  include/net/netfilter/nf_queue.h     |  2 ++
>  net/netfilter/core.c                 |  1 +
>  net/netfilter/nf_internals.h         |  1 +
>  net/netfilter/nf_queue.c             | 17 +++++++++++++++++
>  net/netfilter/nfnetlink_queue_core.c | 24 +++++++++++++++++++++++-
>  5 files changed, 44 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
> index d81d584157e1..e8635854a55b 100644
> --- a/include/net/netfilter/nf_queue.h
> +++ b/include/net/netfilter/nf_queue.h
> @@ -24,6 +24,8 @@ struct nf_queue_entry {
>  struct nf_queue_handler {
>  	int			(*outfn)(struct nf_queue_entry *entry,
>  					 unsigned int queuenum);
> +	void			(*nf_hook_drop)(struct net *net,
> +						struct nf_hook_ops *ops);
>  };
>  
>  void nf_register_queue_handler(const struct nf_queue_handler *qh);
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index 653e32eac08c..a0e54974e2c9 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -118,6 +118,7 @@ void nf_unregister_hook(struct nf_hook_ops *reg)
>  	static_key_slow_dec(&nf_hooks_needed[reg->pf][reg->hooknum]);
>  #endif
>  	synchronize_net();
> +	nf_queue_nf_hook_drop(reg);
>  }
>  EXPORT_SYMBOL(nf_unregister_hook);
>  
> diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
> index ea7f36784b3d..399210693c2a 100644
> --- a/net/netfilter/nf_internals.h
> +++ b/net/netfilter/nf_internals.h
> @@ -19,6 +19,7 @@ unsigned int nf_iterate(struct list_head *head, struct sk_buff *skb,
>  /* nf_queue.c */
>  int nf_queue(struct sk_buff *skb, struct nf_hook_ops *elem,
>  	     struct nf_hook_state *state, unsigned int queuenum);
> +void nf_queue_nf_hook_drop(struct nf_hook_ops *ops);
>  int __init netfilter_queue_init(void);
>  
>  /* nf_log.c */
> diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
> index 2e88032cd5ad..cd60d397fe05 100644
> --- a/net/netfilter/nf_queue.c
> +++ b/net/netfilter/nf_queue.c
> @@ -105,6 +105,23 @@ bool nf_queue_entry_get_refs(struct nf_queue_entry *entry)
>  }
>  EXPORT_SYMBOL_GPL(nf_queue_entry_get_refs);
>  
> +void nf_queue_nf_hook_drop(struct nf_hook_ops *ops)

I'd suggest you rename all these 'nf_hook_drop' to 'flush'.

> +{
> +	const struct nf_queue_handler *qh;
> +	struct net *net;
> +
> +	rtnl_lock();

Why rtnl_lock() here?

> +	rcu_read_lock();
> +	qh = rcu_dereference(queue_handler);
> +	if (qh) {
> +		for_each_net(net) {
> +			qh->nf_hook_drop(net, ops);
> +		}
> +	}
> +	rcu_read_unlock();
> +	rtnl_unlock();
> +}
> +
>  /*
>   * Any packet that leaves via this function must come back
>   * through nf_reinject().
