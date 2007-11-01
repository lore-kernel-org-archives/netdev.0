From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Thu, 01 Nov 2007 17:06:03 +0100
Message-ID: <4729F96B.8000802@o2.pl>
References: <4729A774.9030409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andi Kleen <ak@suse.de>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:46523 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751216AbXKAQBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 12:01:44 -0400
In-Reply-To: <4729A774.9030409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A few doubts below: 

Eric Dumazet wrote:
> As done two years ago on IP route cache table (commit 
> 22c047ccbc68fa8f3fa57f0e8f906479a062c426) , we can avoid using one lock per 
> hash bucket for the huge TCP/DCCP hash tables.
...
> diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
> index 4427dcd..5cbfbac 100644
> --- a/include/net/inet_hashtables.h
> +++ b/include/net/inet_hashtables.h
> @@ -37,7 +37,6 @@
>   * I'll experiment with dynamic table growth later.
>   */
>  struct inet_ehash_bucket {
> -	rwlock_t	  lock;
>  	struct hlist_head chain;
>  	struct hlist_head twchain;
>  };
> @@ -91,6 +90,28 @@ struct inet_bind_hashbucket {
>  /* This is for listening sockets, thus all sockets which possess wildcards. */
>  #define INET_LHTABLE_SIZE	32	/* Yes, really, this is all you need. */
>  
> +#if defined(CONFIG_SMP) || defined(CONFIG_PROVE_LOCKING)

Probably "|| defined(CONFIG_DEBUG_SPINLOCK)" is needed here.

> +/*
> + * Instead of using one rwlock for each inet_ehash_bucket, we use a table of locks
> + * The size of this table is a power of two and depends on the number of CPUS.
> + */
> +# if defined(CONFIG_DEBUG_LOCK_ALLOC)
> +#  define EHASH_LOCK_SZ 256
> +# elif NR_CPUS >= 32
> +#  define EHASH_LOCK_SZ	4096
> +# elif NR_CPUS >= 16
> +#  define EHASH_LOCK_SZ	2048
> +# elif NR_CPUS >= 8
> +#  define EHASH_LOCK_SZ	1024
> +# elif NR_CPUS >= 4
> +#  define EHASH_LOCK_SZ	512
> +# else
> +#  define EHASH_LOCK_SZ	256
> +# endif
> +#else
> +# define EHASH_LOCK_SZ 0
> +#endif
> +

Looks hackish: usually DEBUG code checks "real" environment, and here it's
a special case. But omitting locks if no SMP or DEBUG is strange. IMHO,
there should be 1 instead of 0.

>  struct inet_hashinfo {
>  	/* This is for sockets with full identity only.  Sockets here will
>  	 * always be without wildcards and will have the following invariant:
> @@ -100,6 +121,7 @@ struct inet_hashinfo {
>  	 * TIME_WAIT sockets use a separate chain (twchain).
>  	 */
>  	struct inet_ehash_bucket	*ehash;
> +	rwlock_t			*ehash_locks;
>  
>  	/* Ok, let's try this, I give up, we do need a local binding
>  	 * TCP hash as well as the others for fast bind/connect.
> @@ -134,6 +156,13 @@ static inline struct inet_ehash_bucket *inet_ehash_bucket(
>  	return &hashinfo->ehash[hash & (hashinfo->ehash_size - 1)];
>  }
>  
> +static inline rwlock_t *inet_ehash_lockp(
> +	struct inet_hashinfo *hashinfo,
> +	unsigned int hash)
> +{
> +	return &hashinfo->ehash_locks[hash & (EHASH_LOCK_SZ - 1)];
> +}
> +

Is it OK for EHASH_LOCK_SZ == 0?

...
> diff --git a/net/dccp/proto.c b/net/dccp/proto.c
> index d849739..3b5f97a 100644
> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -1072,11 +1072,18 @@ static int __init dccp_init(void)
>  	}
>  
>  	for (i = 0; i < dccp_hashinfo.ehash_size; i++) {
> -		rwlock_init(&dccp_hashinfo.ehash[i].lock);
>  		INIT_HLIST_HEAD(&dccp_hashinfo.ehash[i].chain);
>  		INIT_HLIST_HEAD(&dccp_hashinfo.ehash[i].twchain);
>  	}
> -
> +	if (EHASH_LOCK_SZ) {

Why not #ifdef then? But, IMHO, rwlock_init() should be done at least
once here. (Similarly later for tcp.)

> +		dccp_hashinfo.ehash_locks =
> +			kmalloc(EHASH_LOCK_SZ * sizeof(rwlock_t),
> +				GFP_KERNEL);
> +		if (!dccp_hashinfo.ehash_locks)
> +			goto out_free_dccp_ehash;
> +		for (i = 0; i < EHASH_LOCK_SZ; i++)
> +			rwlock_init(&dccp_hashinfo.ehash_locks[i]);
> +	}
>  	bhash_order = ehash_order;
>  
>  	do {
> @@ -1091,7 +1098,7 @@ static int __init dccp_init(void)
>  
>  	if (!dccp_hashinfo.bhash) {
>  		DCCP_CRIT("Failed to allocate DCCP bind hash table");
> -		goto out_free_dccp_ehash;
> +		goto out_free_dccp_locks;
>  	}
>  
>  	for (i = 0; i < dccp_hashinfo.bhash_size; i++) {
> @@ -1121,6 +1128,9 @@ out_free_dccp_mib:
>  out_free_dccp_bhash:
>  	free_pages((unsigned long)dccp_hashinfo.bhash, bhash_order);
>  	dccp_hashinfo.bhash = NULL;
> +out_free_dccp_locks:
> +	kfree(dccp_hashinfo.ehash_locks);
> +	dccp_hashinfo.ehash_locks = NULL;
>  out_free_dccp_ehash:
>  	free_pages((unsigned long)dccp_hashinfo.ehash, ehash_order);
>  	dccp_hashinfo.ehash = NULL;

Isn't such kfree(dccp_hashinfo.ehash_locks) needed in dccp_fini()?

Regards,
Jarek P.
