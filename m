From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next-2.6] net: fix a lockdep rcu warning in
 __sk_dst_set()
Date: Tue, 27 Apr 2010 09:17:16 -0700
Message-ID: <20100427161716.GB2424@linux.vnet.ibm.com>
References: <1272350443.4861.9.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:50825 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756144Ab0D0QRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Apr 2010 12:17:20 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e6.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3RGF58c031822
	for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 12:15:05 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3RGHJEZ161672
	for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 12:17:19 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3RGHHGD009868
	for <netdev@vger.kernel.org>; Tue, 27 Apr 2010 12:17:18 -0400
Content-Disposition: inline
In-Reply-To: <1272350443.4861.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 27, 2010 at 08:40:43AM +0200, Eric Dumazet wrote:
> __sk_dst_set() might be called while no state can be integrated in a
> rcu_dereference_check() condition.
> 
> So use rcu_dereference_raw() to shutup lockdep warnings (if
> CONFIG_PROVE_RCU is set)

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 86a8ca1..94dbdbc 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1236,8 +1236,11 @@ __sk_dst_set(struct sock *sk, struct dst_entry *dst)
>  	struct dst_entry *old_dst;
> 
>  	sk_tx_queue_clear(sk);
> -	old_dst = rcu_dereference_check(sk->sk_dst_cache,
> -					lockdep_is_held(&sk->sk_dst_lock));
> +	/*
> +	 * This can be called while sk is owned by the caller only,
> +	 * with no state that can be checked in a rcu_dereference_check() cond
> +	 */
> +	old_dst = rcu_dereference_raw(sk->sk_dst_cache);
>  	rcu_assign_pointer(sk->sk_dst_cache, dst);
>  	dst_release(old_dst);
>  }
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
