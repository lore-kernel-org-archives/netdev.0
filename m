From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: tcp_release_cb() should release socket ownership
Date: Wed, 05 Mar 2014 20:59:38 -0500 (EST)
Message-ID: <20140305.205938.287751582220842351.davem@davemloft.net>
References: <1393942583.26794.107.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140304.134811.86791174090638790.davem@davemloft.net>
	<1393972752.26794.145.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51874 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755769AbaCFB7k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 20:59:40 -0500
In-Reply-To: <1393972752.26794.145.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 Mar 2014 14:39:12 -0800

> @@ -767,6 +767,17 @@ void tcp_release_cb(struct sock *sk)
>  	if (flags & (1UL << TCP_TSQ_DEFERRED))
>  		tcp_tsq_handler(sk);
>  
> +	/* Here begins the tricky part :
> +	 * We are called from release_sock() with :
> +	 * 1) BH disabled
> +	 * 2) sk_lock.slock spinlock held
> +	 * 3) socket owned by us (sk->sk_lock.owned == 1)
> +	 *
> +	 * But following code is meant to be called from BH handlers,
> +	 * so we should keep BH disabled, but early release socket ownership
> +	 */
> +	sock_release_ownership(sk);
> +

It really means that sk_lock.owned cannot ever be accessed without the
sk_lock spinlock held.

Most of this is easy to hand audit, except sock_owned_by_user() which
has call sites everywhere.

Consider adding a locking assertion to it.
