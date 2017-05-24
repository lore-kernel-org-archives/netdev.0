From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] rhashtable: Fix missing elements when inserting.
Date: Wed, 24 May 2017 12:36:17 +0800
Message-ID: <20170524043617.GA22594@gondor.apana.org.au>
References: <20170524014950.3261-1-ap420073@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ap420073@gmail.com
To: Taehee Yoo <ap420073@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [128.1.224.119] ([128.1.224.119]:48930 "EHLO deadmen.hmeau.com"
        rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S938071AbdEXEgf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 00:36:35 -0400
Content-Disposition: inline
In-Reply-To: <20170524014950.3261-1-ap420073@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taehee Yoo <ap420073@gmail.com> wrote:
> rhltable_insert_key() inserts a node into list of element,
> if node's key is duplicated, so that it becomes the chain of
> element(as known as rhead). Also bucket table points that element directly.
> If a inserted node's element chain is located at third,
> rhltable misses first and second element chain.
> This issue is causion of to failture the rhltable_remove().
> 
> After this patch, rhltable_insert_key() inserts a node into second of
> element's list, so that rhlist do not misses elements.
> 
> Signed-off-by: Taehee Yoo <ap420073@gmail.com>

I'm sorry but I don't understand your description of the problem.
The new duplicate object is always inserted at the head of the
list and therefore replaces the previous list head in the hash
bucket chain.

Do you have some code that reproduces the problem?

> diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
> index 7d56a7e..d3c24b9 100644
> --- a/include/linux/rhashtable.h
> +++ b/include/linux/rhashtable.h
> @@ -762,11 +762,9 @@ static inline void *__rhashtable_insert_fast(
>                list = container_of(obj, struct rhlist_head, rhead);
>                plist = container_of(head, struct rhlist_head, rhead);
> 
> -               RCU_INIT_POINTER(list->next, plist);
> -               head = rht_dereference_bucket(head->next, tbl, hash);
> -               RCU_INIT_POINTER(list->rhead.next, head);
> -               rcu_assign_pointer(*pprev, obj);
> -
> +               RCU_INIT_POINTER(list->next, rht_dereference_bucket(plist->next,
> +                                                                   tbl, hash));
> +               RCU_INIT_POINTER(plist->next, list);

Your second RCU_INIT_POINTER needs to be rcu_assign_pointer.

Your approach of retaining the first duplicate object as the head
of the list should work too but I don't really see any point in
changing this.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
