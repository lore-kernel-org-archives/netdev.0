From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] neigh: __rcu annotations
Date: Fri, 21 Jan 2011 17:36:57 -0800
Message-ID: <20110122013657.GP17752@linux.vnet.ibm.com>
References: <1295510567.2653.487.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:45506 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750935Ab1AVIoy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 03:44:54 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0M8UMbs018028
	for <netdev@vger.kernel.org>; Sat, 22 Jan 2011 03:30:23 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 8D0B9728047
	for <netdev@vger.kernel.org>; Sat, 22 Jan 2011 03:44:48 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0M8im9M319204
	for <netdev@vger.kernel.org>; Sat, 22 Jan 2011 03:44:48 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0M8il2q008239
	for <netdev@vger.kernel.org>; Sat, 22 Jan 2011 03:44:48 -0500
Content-Disposition: inline
In-Reply-To: <1295510567.2653.487.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 20, 2011 at 09:02:47AM +0100, Eric Dumazet wrote:
> fix some minor issues and sparse (__rcu) warnings
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/core/neighbour.c |   13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 60a9029..799f06e 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -316,7 +316,7 @@ static struct neigh_hash_table *neigh_hash_alloc(unsigned int entries)
>  {
>  	size_t size = entries * sizeof(struct neighbour *);
>  	struct neigh_hash_table *ret;
> -	struct neighbour **buckets;
> +	struct neighbour __rcu **buckets;
> 
>  	ret = kmalloc(sizeof(*ret), GFP_ATOMIC);
>  	if (!ret)
> @@ -324,14 +324,14 @@ static struct neigh_hash_table *neigh_hash_alloc(unsigned int entries)
>  	if (size <= PAGE_SIZE)
>  		buckets = kzalloc(size, GFP_ATOMIC);
>  	else
> -		buckets = (struct neighbour **)
> +		buckets = (struct neighbour __rcu **)
>  			  __get_free_pages(GFP_ATOMIC | __GFP_ZERO,
>  					   get_order(size));
>  	if (!buckets) {
>  		kfree(ret);
>  		return NULL;
>  	}
> -	rcu_assign_pointer(ret->hash_buckets, buckets);
> +	ret->hash_buckets = buckets;
>  	ret->hash_mask = entries - 1;
>  	get_random_bytes(&ret->hash_rnd, sizeof(ret->hash_rnd));
>  	return ret;
> @@ -343,7 +343,7 @@ static void neigh_hash_free_rcu(struct rcu_head *head)
>  						    struct neigh_hash_table,
>  						    rcu);
>  	size_t size = (nht->hash_mask + 1) * sizeof(struct neighbour *);
> -	struct neighbour **buckets = nht->hash_buckets;
> +	struct neighbour __rcu **buckets = nht->hash_buckets;
> 
>  	if (size <= PAGE_SIZE)
>  		kfree(buckets);
> @@ -1540,7 +1540,7 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
>  		panic("cannot create neighbour proc dir entry");
>  #endif
> 
> -	tbl->nht = neigh_hash_alloc(8);
> +	RCU_INIT_POINTER(tbl->nht, neigh_hash_alloc(8));
> 
>  	phsize = (PNEIGH_HASHMASK + 1) * sizeof(struct pneigh_entry *);
>  	tbl->phash_buckets = kzalloc(phsize, GFP_KERNEL);
> @@ -1602,7 +1602,8 @@ int neigh_table_clear(struct neigh_table *tbl)
>  	}
>  	write_unlock(&neigh_tbl_lock);
> 
> -	call_rcu(&tbl->nht->rcu, neigh_hash_free_rcu);
> +	call_rcu(&rcu_dereference_protected(tbl->nht, 1)->rcu,
> +		 neigh_hash_free_rcu);

Hello, Eric,

Any chance of a comment?  Perhaps something like:

	/*
	 * Because this has been removed from the list, no other updater
	 * can access this element.
	 */

							Thanx, Paul

>  	tbl->nht = NULL;
> 
>  	kfree(tbl->phash_buckets);
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
