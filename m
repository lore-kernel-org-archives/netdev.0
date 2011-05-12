From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next-2.6] l2tp: fix potential rcu race
Date: Thu, 12 May 2011 07:26:41 -0700
Message-ID: <20110512142641.GO2258@linux.vnet.ibm.com>
References: <1305174156.3232.26.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	James Chapman <jchapman@katalix.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:53687 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757311Ab1ELO0r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 May 2011 10:26:47 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4CE53Mk031380
	for <netdev@vger.kernel.org>; Thu, 12 May 2011 10:05:03 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4CEQktG097200
	for <netdev@vger.kernel.org>; Thu, 12 May 2011 10:26:46 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4CEQiIV009873
	for <netdev@vger.kernel.org>; Thu, 12 May 2011 10:26:46 -0400
Content-Disposition: inline
In-Reply-To: <1305174156.3232.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 12, 2011 at 06:22:36AM +0200, Eric Dumazet wrote:
> While trying to remove useless synchronize_rcu() calls, I found l2tp is
> indeed incorrectly using two of such calls, but also bumps tunnel
> refcount after list insertion.
> 
> tunnel refcount must be incremented before being made publically visible
> by rcu readers.
> 
> This fix can be applied to 2.6.35+ and might need a backport for older
> kernels, since things were shuffled in commit fd558d186df2c
> (l2tp: Split pppol2tp patch into separate l2tp and ppp parts)

Ouch!  Good catch, Eric!

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> CC: James Chapman <jchapman@katalix.com>
> ---
> 
> I based this patch on net-next-2.6 because of recent commits in this
> file and linux-2.6 being on late RC phase. But its a stable candidate.
> 
>  net/l2tp/l2tp_core.c |   10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index 9be095e..ed8a233 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -1435,16 +1435,15 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
> 
>  	/* Add tunnel to our list */
>  	INIT_LIST_HEAD(&tunnel->list);
> -	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
> -	list_add_rcu(&tunnel->list, &pn->l2tp_tunnel_list);
> -	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
> -	synchronize_rcu();
>  	atomic_inc(&l2tp_tunnel_count);
> 
>  	/* Bump the reference count. The tunnel context is deleted
> -	 * only when this drops to zero.
> +	 * only when this drops to zero. Must be done before list insertion
>  	 */
>  	l2tp_tunnel_inc_refcount(tunnel);
> +	spin_lock_bh(&pn->l2tp_tunnel_list_lock);
> +	list_add_rcu(&tunnel->list, &pn->l2tp_tunnel_list);
> +	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
> 
>  	err = 0;
>  err:
> @@ -1636,7 +1635,6 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
>  			hlist_add_head_rcu(&session->global_hlist,
>  					   l2tp_session_id_hash_2(pn, session_id));
>  			spin_unlock_bh(&pn->l2tp_session_hlist_lock);
> -			synchronize_rcu();
>  		}
> 
>  		/* Ignore management session in session count value */
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
