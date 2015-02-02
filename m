From: Ying Xue <ying.xue@windriver.com>
Subject: Re: rhashtable: Fix potential crash on destroy in rhashtable_shrink
Date: Mon, 2 Feb 2015 17:34:40 +0800
Message-ID: <54CF44B0.4040205@windriver.com>
References: <20150131093637.GA29106@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:52012 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbbBBJf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 04:35:28 -0500
In-Reply-To: <20150131093637.GA29106@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/31/2015 05:36 PM, Herbert Xu wrote:
> The current being_destroyed check in rhashtable_expand is not
> enough since if we start a shrinking process after freeing all
> elements in the table that's also going to crash.
> 

Sorry, I cannot understand the scenario.

When we free the table in rhashtable_destroy(), we call
cancel_work_sync() to synchronously cancel the work. So, why does your
described crash still happen?

Please give a more explanation.

Thanks,
Ying

> This patch adds a being_destroyed check to the deferred worker
> thread so that we bail out as soon as we take the lock.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index 69a4eb0..4c3da1f 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -489,6 +489,9 @@ static void rht_deferred_worker(struct work_struct *work)
>  
>  	ht = container_of(work, struct rhashtable, run_work);
>  	mutex_lock(&ht->mutex);
> +	if (ht->being_destroyed)
> +		goto unlock;
> +
>  	tbl = rht_dereference(ht->tbl, ht);
>  
>  	list_for_each_entry(walker, &ht->walkers, list)
> @@ -499,6 +502,7 @@ static void rht_deferred_worker(struct work_struct *work)
>  	else if (ht->p.shrink_decision && ht->p.shrink_decision(ht, tbl->size))
>  		rhashtable_shrink(ht);
>  
> +unlock:
>  	mutex_unlock(&ht->mutex);
>  }
>  
> 
