From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/4] [CORE]: datagram: mem_scheudle functions
Date: Sat, 15 Dec 2007 23:32:10 +0800
Message-ID: <20071215153210.GA29415@gondor.apana.org.au>
References: <47636120.4050701@redhat.com> <476362D8.4070807@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4290 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755521AbXLOPcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 10:32:17 -0500
Content-Disposition: inline
In-Reply-To: <476362D8.4070807@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 15, 2007 at 12:15:04AM -0500, Hideo AOKI wrote:
> This patch includes changes in network core sub system for memory
> accounting.
> 
> Memory scheduling, charging, uncharging and reclaiming functions are
> added. These functions use sk_forward_alloc to store socket local
> accounting. They also need to use lock to keep consistency of
> sk_forward_alloc and memory_allocated. They currently support only
> datagram protocols.

Thanks for the patch.  I think it's generally on the right track
but there's still a few issues with the implementation.

> +	spin_lock_irqsave(&sk->sk_lock.slock, flags);

Please use bh_lock_sock since this must never be used from an
IRQ handler.

> +static inline void sk_mem_reclaim(struct sock *sk)
> +{
> +	if (sk->sk_type == SOCK_DGRAM)
> +		sk_datagram_mem_reclaim(sk);
> +}

Please get rid of these wrappers since we should only get here
for datagram protocols.

> +static inline int sk_account_wmem_charge(struct sock *sk, int size)
> +{
> +	unsigned long flags;
> +
> +	/* account if protocol supports memory accounting. */
> +	if (!sk->sk_prot->memory_allocated || sk->sk_type != SOCK_DGRAM)
> +		return 1;
> +
> +	spin_lock_irqsave(&sk->sk_lock.slock, flags);
> +	if (sk_datagram_wmem_schedule(sk, size)) {
> +		sk->sk_forward_alloc -= size;
> +		spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
> +		return 1;
> +	}
> +	spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
> +	return 0;
> +}

This is probably too big to inline.

> +static inline int sk_account_rmem_charge(struct sock *sk, int size)
> +{
> +	unsigned long flags;
> +
> +	/* account if protocol supports memory accounting. */
> +	if (!sk->sk_prot->memory_allocated || sk->sk_type != SOCK_DGRAM)
> +		return 1;
> +
> +	spin_lock_irqsave(&sk->sk_lock.slock, flags);
> +	if (sk_datagram_rmem_schedule(sk, size)) {
> +		sk->sk_forward_alloc -= size;
> +		spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
> +		return 1;
> +	}
> +	spin_unlock_irqrestore(&sk->sk_lock.slock, flags);
> +	return 0;
> +}

Why are we duplicating the rmem/wmem versions when they're identical?

> -int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
> +int sock_queue_rcv_skb_with_owner(struct sock *sk, struct sk_buff *skb,
> +				  void set_owner_r(struct sk_buff *nskb,
> +						   struct sock* nsk))

Just make a new function for this rather than playing with function
pointers.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
