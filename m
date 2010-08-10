From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netpoll: use non-BH variant of RCU
Date: Tue, 10 Aug 2010 16:43:58 -0400
Message-ID: <20100810204358.GA1076@gondor.apana.org.au>
References: <1281471924-2237-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44107 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757916Ab0HJUoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 16:44:01 -0400
Content-Disposition: inline
In-Reply-To: <1281471924-2237-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 10, 2010 at 04:25:24PM -0400, John W. Linville wrote:
> "netpoll: Fix RCU usage" switched netpoll_rx to use the BH variant
> of RCU.  Unfortunately, calling netpoll_rx from netif_rx resulted in
> the following backtrace:

Thanks for catching this John!

> diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
> index 413742c..0bdd527 100644
> --- a/include/linux/netpoll.h
> +++ b/include/linux/netpoll.h
> @@ -63,8 +63,8 @@ static inline bool netpoll_rx(struct sk_buff *skb)
>  	unsigned long flags;
>  	bool ret = false;
>  
> -	rcu_read_lock_bh();
> -	npinfo = rcu_dereference_bh(skb->dev->npinfo);
> +	rcu_read_lock();
> +	npinfo = rcu_dereference(skb->dev->npinfo);

I really wanted to avoid mixing the two different RCU primitives
because they require different synchronisations.

In this case, the problem is that we're being called in IRQ
context, where BH is diabled anyway, so we don't actually need
to do anything (assuming IRQ is off).

Paul, what could we do to resolve this (other than by switching
to the non-BH variant of RCU)? Perhaps an additional variant
of rcu_read_lock_bh that checks whether IRQ is off?

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
