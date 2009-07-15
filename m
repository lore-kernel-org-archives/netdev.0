From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] net: nf_conntrack_alloc() should not use kmem_cache_zalloc()
Date: Wed, 15 Jul 2009 17:28:52 +0200
Message-ID: <4A5DF5B4.5090809@trash.net>
References: <20090707.191424.167842005.davem@davemloft.net>	<4A5441A0.3050504@gmail.com>	<4A5581C5.5070409@gmail.com> <20090711.202727.18146102.davem@davemloft.net> <4A598BAB.6030400@gmail.com> <4A5DCB7C.9000502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57678 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435AbZGOP3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 11:29:02 -0400
In-Reply-To: <4A5DCB7C.9000502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> [PATCH] net: nf_conntrack_alloc() should not use kmem_cache_zalloc()
> 
> When a slab cache uses SLAB_DESTROY_BY_RCU, we must be careful when allocating
> objects, since slab allocator could give a freed object still used by lockless
> readers.
> 
> In particular, nf_conntrack RCU lookups rely on ct->tuplehash[xxx].hnnode.next
> being always valid (ie containing a valid 'nulls' value, or a valid pointer to next
> object in hash chain.)
> 
> kmem_cache_zalloc() setups object with NULL values, but a NULL value is not valid
> for ct->tuplehash[xxx].hnnode.next.
> 
> Fix is to call kmem_cache_alloc() and do the zeroing ourself.

I think this is still racy, please see below:

> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 7508f11..23feafa 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -561,17 +561,28 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
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

__nf_conntrack_find() on another CPU finds the entry at this point.

> +	/*
> +	 * Let ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.next
> +	 * and ct->tuplehash[IP_CT_DIR_REPLY].hnnode.next unchanged.
> +	 */
> +	memset(&ct->tuplehash[IP_CT_DIR_MAX], 0,
> +	       sizeof(*ct) - offsetof(struct nf_conn, tuplehash[IP_CT_DIR_MAX]));
>  	spin_lock_init(&ct->lock);
>  	atomic_set(&ct->ct_general.use, 1);

nf_conntrack_find_get() successfully tries to atomic_inc_not_zero()
at this point, following by another tuple comparison which is also
successful.

Am I missing something? I think we need to make sure the reference
count is not increased until the new tuples are visible.

>  	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple = *orig;
> +	ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev = NULL;
>  	ct->tuplehash[IP_CT_DIR_REPLY].tuple = *repl;
> +	ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev = NULL;
>  	/* Don't set timer yet: wait for confirmation */
>  	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
>  #ifdef CONFIG_NET_NS
> 

