From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: netfilter -stable 08/08: nf_conntrack: nf_conntrack_alloc()
	fixes
Date: Mon, 27 Jul 2009 10:55:48 -0700
Message-ID: <20090727175548.GB6782@linux.vnet.ibm.com>
References: <20090723141523.19029.89290.sendpatchset@x2.localnet> <20090723141533.19029.28754.sendpatchset@x2.localnet>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090723141533.19029.28754.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 23, 2009 at 04:15:34PM +0200, Patrick McHardy wrote:
> commit 2b12e9634d9676c55f576195a7f950956179d881
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Thu Jul 23 16:02:18 2009 +0200
> 
>     netfilter: nf_conntrack: nf_conntrack_alloc() fixes
>     
>     Upstream commit 941297f4:
>     
>     When a slab cache uses SLAB_DESTROY_BY_RCU, we must be careful when allocating
>     objects, since slab allocator could give a freed object still used by lockless
>     readers.
>     
>     In particular, nf_conntrack RCU lookups rely on ct->tuplehash[xxx].hnnode.next
>     being always valid (ie containing a valid 'nulls' value, or a valid pointer to next
>     object in hash chain.)
>     
>     kmem_cache_zalloc() setups object with NULL values, but a NULL value is not valid
>     for ct->tuplehash[xxx].hnnode.next.
>     
>     Fix is to call kmem_cache_alloc() and do the zeroing ourself.
>     
>     As spotted by Patrick, we also need to make sure lookup keys are committed to
>     memory before setting refcount to 1, or a lockless reader could get a reference
>     on the old version of the object. Its key re-check could then pass the barrier.

The atomic_inc() works, but only if ->refcnt is set to zero on the
initial allocation.  That said, this approach seems safer, so:

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

>     Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> diff --git a/Documentation/RCU/rculist_nulls.txt b/Documentation/RCU/rculist_nulls.txt
> index 6389dec..d0c017e 100644
> --- a/Documentation/RCU/rculist_nulls.txt
> +++ b/Documentation/RCU/rculist_nulls.txt
> @@ -83,11 +83,12 @@ not detect it missed following items in original chain.
>  obj = kmem_cache_alloc(...);
>  lock_chain(); // typically a spin_lock()
>  obj->key = key;
> -atomic_inc(&obj->refcnt);
>  /*
>   * we need to make sure obj->key is updated before obj->next
> + * or obj->refcnt
>   */
>  smp_wmb();
> +atomic_set(&obj->refcnt, 1);
>  hlist_add_head_rcu(&obj->obj_node, list);
>  unlock_chain(); // typically a spin_unlock()
> 
> @@ -159,6 +160,10 @@ out:
>  obj = kmem_cache_alloc(cachep);
>  lock_chain(); // typically a spin_lock()
>  obj->key = key;
> +/*
> + * changes to obj->key must be visible before refcnt one
> + */
> +smp_wmb();
>  atomic_set(&obj->refcnt, 1);
>  /*
>   * insert obj in RCU way (readers might be traversing chain)
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 2d3584f..0d961ee 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -525,22 +525,37 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
>  		}
>  	}
> 
> -	ct = kmem_cache_zalloc(nf_conntrack_cachep, gfp);
> +	/*
> +	 * Do not use kmem_cache_zalloc(), as this cache uses
> +	 * SLAB_DESTROY_BY_RCU.
> +	 */
> +	ct = kmem_cache_alloc(nf_conntrack_cachep, gfp);
>  	if (ct == NULL) {
>  		pr_debug("nf_conntrack_alloc: Can't alloc conntrack.\n");
>  		atomic_dec(&net->ct.count);
>  		return ERR_PTR(-ENOMEM);
>  	}
> -
> -	atomic_set(&ct->ct_general.use, 1);
> +	/*
> +	 * Let ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.next
> +	 * and ct->tuplehash[IP_CT_DIR_REPLY].hnnode.next unchanged.
> +	 */
> +	memset(&ct->tuplehash[IP_CT_DIR_MAX], 0,
> +	       sizeof(*ct) - offsetof(struct nf_conn, tuplehash[IP_CT_DIR_MAX]));
>  	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple = *orig;
> +	ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev = NULL;
>  	ct->tuplehash[IP_CT_DIR_REPLY].tuple = *repl;
> +	ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev = NULL;
>  	/* Don't set timer yet: wait for confirmation */
>  	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
>  #ifdef CONFIG_NET_NS
>  	ct->ct_net = net;
>  #endif
> 
> +	/*
> +	 * changes to lookup keys must be done before setting refcnt to 1
> +	 */
> +	smp_wmb();
> +	atomic_set(&ct->ct_general.use, 1);
>  	return ct;
>  }
>  EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
