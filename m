From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH net-next-2.6] tcp: connect() race with timewait reuse
Date: Fri, 4 Dec 2009 02:22:47 +0300
Message-ID: <20091203232247.GA31496@ioremap.net>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com> <4B152F97.1090409@gmail.com> <20091202.005937.177088443.davem@davemloft.net> <4B163226.50801@gmail.com> <4B164293.7070804@gmail.com> <4B16830B.4010801@gmail.com> <20091202221552.GA17579@ioremap.net> <4B175E65.3070905@gmail.com> <4B177757.3010407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kdakhane@gmail.com,
	netdev@vger.kernel.org, netfilter@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B177757.3010407@gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric.

Patch looks good, thank you!

On Thu, Dec 03, 2009 at 09:31:19AM +0100, Eric Dumazet (eric.dumazet@gmail.com) wrote:
> +/*
> + * unhash a timewait socket from established hash
> + * lock must be hold by caller
> + */
> +int inet_twsk_unhash(struct inet_timewait_sock *tw)
> +{
> +	if (hlist_nulls_unhashed(&tw->tw_node))
> +		return 0;
> +
> +	hlist_nulls_del_rcu(&tw->tw_node);
> +	sk_nulls_node_init(&tw->tw_node);
> +	return 1;
> +}
> +
>  /* Must be called with locally disabled BHs. */
>  static void __inet_twsk_kill(struct inet_timewait_sock *tw,
>  			     struct inet_hashinfo *hashinfo)
>  {
>  	struct inet_bind_hashbucket *bhead;
>  	struct inet_bind_bucket *tb;
> +	int refcnt;
>  	/* Unlink from established hashes. */
>  	spinlock_t *lock = inet_ehash_lockp(hashinfo, tw->tw_hash);
>  
>  	spin_lock(lock);
> -	if (hlist_nulls_unhashed(&tw->tw_node)) {
> -		spin_unlock(lock);
> -		return;
> -	}
> -	hlist_nulls_del_rcu(&tw->tw_node);
> -	sk_nulls_node_init(&tw->tw_node);
> +	refcnt = inet_twsk_unhash(tw);

Tricky :)

>  	spin_unlock(lock);
>  
>  	/* Disassociate with bind bucket. */
> @@ -37,9 +48,12 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
>  			hashinfo->bhash_size)];
>  	spin_lock(&bhead->lock);
>  	tb = tw->tw_tb;
> -	__hlist_del(&tw->tw_bind_node);
> -	tw->tw_tb = NULL;
> -	inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
> +	if (tb) {
> +		__hlist_del(&tw->tw_bind_node);
> +		tw->tw_tb = NULL;
> +		inet_bind_bucket_destroy(hashinfo->bind_bucket_cachep, tb);
> +		refcnt++;
> +	}
>  	spin_unlock(&bhead->lock);
>  #ifdef SOCK_REFCNT_DEBUG
>  	if (atomic_read(&tw->tw_refcnt) != 1) {
> @@ -47,7 +61,10 @@ static void __inet_twsk_kill(struct inet_timewait_sock *tw,
>  		       tw->tw_prot->name, tw, atomic_read(&tw->tw_refcnt));
>  	}
>  #endif
> -	inet_twsk_put(tw);
> +	while (refcnt) {
> +		inet_twsk_put(tw);
> +		refcnt--;
> +	}
>  }

-- 
	Evgeniy Polyakov
