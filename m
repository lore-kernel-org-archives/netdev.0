From: David Miller <davem@davemloft.net>
Subject: Re: suspicious RCU usage (netlink/rhashtable)
Date: Tue, 22 Dec 2015 16:42:25 -0500 (EST)
Message-ID: <20151222.164225.926367017579760543.davem@davemloft.net>
References: <CAEfhGiwEhWqwtbAhbaVCEohePUyUC+f-Ap6b4oHk1Mdkg+ZKUA@mail.gmail.com>
	<20151222.162841.889225793486693960.davem@davemloft.net>
	<CAEfhGiz1FnghHRpcYUVKhWNV=4yjfU-pAsjynKTgwPctsNQ5Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@codemonkey.org.uk, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbbLVVm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:42:27 -0500
In-Reply-To: <CAEfhGiz1FnghHRpcYUVKhWNV=4yjfU-pAsjynKTgwPctsNQ5Gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Tue, 22 Dec 2015 16:38:32 -0500

> On Tue, Dec 22, 2015 at 4:28 PM, David Miller <davem@davemloft.net> wrote:
>> From: Craig Gallek <kraigatgoog@gmail.com>
>> Date: Tue, 22 Dec 2015 15:51:19 -0500
>>
>>> I was actually just looking at this as well (though a slightly
>>> different stack).  The issue is with: c6ff5268293e rhashtable: Fix
>>> walker list corruption
>>>
>>> It changed the lock acquired in rhashtable_walk_init to use the new
>>> spinlock, but the rht_dereference macro expects the mutex.  I was
>>> still trying to track down which repository this change came in
>>> through, though...
>>
>> Both cam via my networking tree.
> Simple fix is below.  Though, I don't understand the history of the
> multiple locks in this structure to be sure it's correct.  I'll send
> it as a formal patch.  Please reject if it's not the right approach.
> 
> diff --git a/lib/rhashtable.c b/lib/rhashtable.c
> index 1c149e9..cc80870 100644
> --- a/lib/rhashtable.c
> +++ b/lib/rhashtable.c
> @@ -516,7 +516,8 @@ int rhashtable_walk_init(struct rhashtable *ht,
> struct rhashtable_iter *iter)
>                 return -ENOMEM;
> 
>         spin_lock(&ht->lock);
> -       iter->walker->tbl = rht_dereference(ht->tbl, ht);
> +       iter->walker->tbl =
> +               rcu_dereference_protected(ht->tbl, lockdep_is_held(&ht->lock));
>         list_add(&iter->walker->list, &iter->walker->tbl->walkers);
>         spin_unlock(&ht->lock);

How can this be the "fix"?  That's exactly what's in the tree.
