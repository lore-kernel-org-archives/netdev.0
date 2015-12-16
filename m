From: Colin Ian King <colin.king@canonical.com>
Subject: Re: rhashtable: Fix walker list corruption
Date: Wed, 16 Dec 2015 14:02:54 +0000
Message-ID: <56716F0E.1030409@canonical.com>
References: <561797B7.3090807@canonical.com>
 <20151216084554.GA24395@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:48386 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166AbbLPOC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 09:02:57 -0500
In-Reply-To: <20151216084554.GA24395@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/12/15 08:45, Herbert Xu wrote:
> On Fri, Oct 09, 2015 at 11:32:23AM +0100, Colin Ian King wrote:
>>
>> I'm hitting a null ptr deference bug when running 2 or more instances of
>> the attached reproducer program.  I've bisected this down to the
>> following commit:
>>
>> commit ba7c95ea3870fe7b847466d39a049ab6f156aa2c
>> Author: Herbert Xu <herbert@gondor.apana.org.au>
>> Date:   Tue Mar 24 09:53:17 2015 +1100
>>
>>     rhashtable: Fix sleeping inside RCU critical section in walk_stop
>>
>>
>> Without this commit, the attached reproducer runs fine for hours. With
>> the commit, I can oops a 4 core (8 thread) Intel i7-6700 Sharkbay SDP in
>> a few seconds.
> 
> Thanks Colin.  This commit was indeed bogus, as we end up using
> two different locks for the one list.

I've given this a good soak test and it fixes the issue. Thanks Herbert!

Colin

> 
> ---8<---
> The commit ba7c95ea3870fe7b847466d39a049ab6f156aa2c ("rhashtable:
> Fix sleeping inside RCU critical section in walk_stop") introduced
> a new spinlock for the walker list.  However, it did not convert
> all existing users of the list over to the new spin lock.  Some
> continued to use the old mutext for this purpose.  This obviously
> led to corruption of the list.
> 
> The fix is to use the spin lock everywhere where we touch the list.
> 
> This also allows us to do rcu_rad_lock before we take the lock in
> rhashtable_walk_start.  With the old mutex this would've deadlocked
> but it's safe with the new spin lock.
> 
> Fixes: ba7c95ea3870 ("rhashtable: Fix sleeping inside RCU...")
> Reported-by: Colin Ian King <colin.king@canonical.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index 1c624db..ed7ba47 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -519,10 +519,10 @@ int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter)
>  	if (!iter->walker)
>  		return -ENOMEM;
>  
> -	mutex_lock(&ht->mutex);
> +	spin_lock(&ht->lock);
>  	iter->walker->tbl = rht_dereference(ht->tbl, ht);
>  	list_add(&iter->walker->list, &iter->walker->tbl->walkers);
> -	mutex_unlock(&ht->mutex);
> +	spin_unlock(&ht->lock);
>  
>  	return 0;
>  }
> @@ -536,10 +536,10 @@ EXPORT_SYMBOL_GPL(rhashtable_walk_init);
>   */
>  void rhashtable_walk_exit(struct rhashtable_iter *iter)
>  {
> -	mutex_lock(&iter->ht->mutex);
> +	spin_lock(&iter->ht->lock);
>  	if (iter->walker->tbl)
>  		list_del(&iter->walker->list);
> -	mutex_unlock(&iter->ht->mutex);
> +	spin_unlock(&iter->ht->lock);
>  	kfree(iter->walker);
>  }
>  EXPORT_SYMBOL_GPL(rhashtable_walk_exit);
> @@ -563,14 +563,12 @@ int rhashtable_walk_start(struct rhashtable_iter *iter)
>  {
>  	struct rhashtable *ht = iter->ht;
>  
> -	mutex_lock(&ht->mutex);
> +	rcu_read_lock();
>  
> +	spin_lock(&ht->lock);
>  	if (iter->walker->tbl)
>  		list_del(&iter->walker->list);
> -
> -	rcu_read_lock();
> -
> -	mutex_unlock(&ht->mutex);
> +	spin_unlock(&ht->lock);
>  
>  	if (!iter->walker->tbl) {
>  		iter->walker->tbl = rht_dereference_rcu(ht->tbl, ht);
> 
