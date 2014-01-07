From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: nf_conntrack: fix RCU race in
 nf_conntrack_find_get
Date: Tue, 07 Jan 2014 07:08:25 -0800
Message-ID: <1389107305.26646.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389090711-15843-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vvs@openvz.org,
	Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Andrey Vagin <avagin@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:53309 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbaAGPI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 10:08:29 -0500
In-Reply-To: <1389090711-15843-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-07 at 14:31 +0400, Andrey Vagin wrote:
> Lets look at destroy_conntrack:
> 
> hlist_nulls_del_rcu(&ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode);
> ...
> nf_conntrack_free(ct)
> 	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
> 
> net->ct.nf_conntrack_cachep is created with SLAB_DESTROY_BY_RCU.
> 
> The hash is protected by rcu, so readers look up conntracks without
> locks.
> A conntrack is removed from the hash, but in this moment a few readers
> still can use the conntrack. Then this conntrack is released and another
> thread creates conntrack with the same address and the equal tuple.
> After this a reader starts to validate the conntrack:
> * It's not dying, because a new conntrack was created
> * nf_ct_tuple_equal() returns true.
> 
> But this conntrack is not initialized yet, so it can not be used by two
> threads concurrently. In this case BUG_ON may be triggered from
> nf_nat_setup_info().
> 
> Florian Westphal suggested to check the confirm bit too. I think it's
> right.
> 
> task 1			task 2			task 3
> 			nf_conntrack_find_get
> 			 ____nf_conntrack_find
> destroy_conntrack
>  hlist_nulls_del_rcu
>  nf_conntrack_free
>  kmem_cache_free
> 						__nf_conntrack_alloc
> 						 kmem_cache_alloc
> 						 memset(&ct->tuplehash[IP_CT_DIR_MAX],
> 			 if (nf_ct_is_dying(ct))
> 			 if (!nf_ct_tuple_equal()
> 
> I'm not sure, that I have ever seen this race condition in a real life.
> Currently we are investigating a bug, which is reproduced on a few node.
> In our case one conntrack is initialized from a few tasks concurrently,
> we don't have any other explanation for this.

> 
> Cc: Florian Westphal <fw@strlen.de>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> ---
>  net/netfilter/nf_conntrack_core.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 43549eb..7a34bb2 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -387,8 +387,12 @@ begin:
>  			     !atomic_inc_not_zero(&ct->ct_general.use)))
>  			h = NULL;
>  		else {
> +			/* A conntrack can be recreated with the equal tuple,
> +			 * so we need to check that the conntrack is initialized
> +			 */
>  			if (unlikely(!nf_ct_tuple_equal(tuple, &h->tuple) ||
> -				     nf_ct_zone(ct) != zone)) {
> +				     nf_ct_zone(ct) != zone) ||
> +				     !nf_ct_is_confirmed(ct)) {
>  				nf_ct_put(ct);
>  				goto begin;
>  			}

I do not think this is the right way to fix this problem (if said
problem is confirmed)

Remember the rule about SLAB_DESTROY_BY_RCU :

When a struct is freed, then reused, its important to set the its refcnt
(from 0 to 1) only when the structure is fully ready for use.

If a lookup finds a structure which is not yet setup, the
atomic_inc_not_zero() will fail.

Take a look at sk_clone_lock() and Documentation/RCU/rculist_nulls.txt
