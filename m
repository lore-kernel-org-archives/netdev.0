From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/6] rhashtable: Fix walker behaviour during rehash
Date: Fri, 13 Mar 2015 15:50:23 +0000
Message-ID: <20150313155023.GG17829@casper.infradead.org>
References: <20150313095607.GA598@gondor.apana.org.au>
 <E1YWML8-0000B6-62@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57687 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbbCMPuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 11:50:24 -0400
Content-Disposition: inline
In-Reply-To: <E1YWML8-0000B6-62@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/15 at 08:57pm, Herbert Xu wrote:
> @@ -725,11 +727,9 @@ int rhashtable_walk_init(struct rhashtable *ht, struct rhashtable_iter *iter)
>  	if (!iter->walker)
>  		return -ENOMEM;
>  
> -	INIT_LIST_HEAD(&iter->walker->list);
> -	iter->walker->resize = false;
> -
>  	mutex_lock(&ht->mutex);
> -	list_add(&iter->walker->list, &ht->walkers);
> +	iter->walker->tbl = rht_dereference(ht->tbl, ht);
> +	list_add(&iter->walker->list, &iter->walker->tbl->walkers);
>  	mutex_unlock(&ht->mutex);
>  
>  	return 0;

Is there a reason to keeping rhashtable_walk_init() and
rhashtable_walk_start() separate? It seems like one always has
to call init for each iteration as start does not reset the
iterator bits. It would also safe a mutex_lock().

> @@ -826,17 +832,18 @@ next:
>  		iter->skip = 0;
>  	}
>  
> -	iter->p = NULL;
> -
> -out:
> -	if (iter->walker->resize) {
> -		iter->p = NULL;
> +	iter->walker->tbl = rht_dereference_rcu(ht->future_tbl, ht);
> +	if (iter->walker->tbl != tbl) {

I was confused at first because this would cause to always dump the
table twice in the regular case. I see that in patch 6/6 you change
the meaning of future_tbl and only make it non-NULL during the short
period of the rehashing. Ordering patch 6 in front of 1 would have
helped ;-)

Looks good in combination with patch 6.

Acked-by: Thomas Graf <tgraf@suug.ch>
