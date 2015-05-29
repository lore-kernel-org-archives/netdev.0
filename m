From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next] neigh: Add missing rcu_assign_pointer
Date: Fri, 29 May 2015 10:04:10 +0800
Message-ID: <5567C91A.5060407@windriver.com>
References: <1432801700-29300-1-git-send-email-ying.xue@windriver.com>	 <1432808028.24345.5.camel@edumazet-glaptop2.roam.corp.google.com>	 <5567BF28.6050900@windriver.com> <1432864234.7456.56.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:33446 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbbE2CET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 22:04:19 -0400
In-Reply-To: <1432864234.7456.56.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2015 09:50 AM, Eric Dumazet wrote:
> I count 5 places of redundancy. 
> 

Another two places you found are necessary indeed!

Acked-by: Ying Xue <ying.xue@windriver.com>

> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 3a74df750af4044eba0e7d88ae01ca9b4dac0e72..ac3b69183cc982e722d9683d6de7a39f66b50b64 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -141,9 +141,7 @@ static int neigh_forced_gc(struct neigh_table *tbl)
>  			write_lock(&n->lock);
>  			if (atomic_read(&n->refcnt) == 1 &&
>  			    !(n->nud_state & NUD_PERMANENT)) {
> -				rcu_assign_pointer(*np,
> -					rcu_dereference_protected(n->next,
> -						  lockdep_is_held(&tbl->lock)));
> +				*np = n->next;
>  				n->dead = 1;
>  				shrunk	= 1;
>  				write_unlock(&n->lock);
> @@ -210,9 +208,7 @@ static void neigh_flush_dev(struct neigh_table *tbl, struct net_device *dev)
>  				np = &n->next;
>  				continue;
>  			}
> -			rcu_assign_pointer(*np,
> -				   rcu_dereference_protected(n->next,
> -						lockdep_is_held(&tbl->lock)));
> +			*np = n->next;
>  			write_lock(&n->lock);
>  			neigh_del_timer(n);
>  			n->dead = 1;
> @@ -380,10 +376,8 @@ static struct neigh_hash_table *neigh_hash_grow(struct neigh_table *tbl,
>  			next = rcu_dereference_protected(n->next,
>  						lockdep_is_held(&tbl->lock));
>  
> -			rcu_assign_pointer(n->next,
> -					   rcu_dereference_protected(
> -						new_nht->hash_buckets[hash],
> -						lockdep_is_held(&tbl->lock)));
> +			n->next = new_nht->hash_buckets[hash];
> +
>  			rcu_assign_pointer(new_nht->hash_buckets[hash], n);
>  		}
>  	}
> @@ -515,9 +509,7 @@ struct neighbour *__neigh_create(struct neigh_table *tbl, const void *pkey,
>  	n->dead = 0;
>  	if (want_ref)
>  		neigh_hold(n);
> -	rcu_assign_pointer(n->next,
> -			   rcu_dereference_protected(nht->hash_buckets[hash_val],
> -						     lockdep_is_held(&tbl->lock)));
> +	n->next = nht->hash_buckets[hash_val];
>  	rcu_assign_pointer(nht->hash_buckets[hash_val], n);
>  	write_unlock_bh(&tbl->lock);
>  	neigh_dbg(2, "neigh %p is created\n", n);
> @@ -2381,9 +2373,7 @@ void __neigh_for_each_release(struct neigh_table *tbl,
>  			write_lock(&n->lock);
>  			release = cb(n);
>  			if (release) {
> -				rcu_assign_pointer(*np,
> -					rcu_dereference_protected(n->next,
> -						lockdep_is_held(&tbl->lock)));
> +				*np = n->next;
>  				n->dead = 1;
>  			} else
>  				np = &n->next;
