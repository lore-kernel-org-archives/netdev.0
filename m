From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 4/4] udp: memory accounting in IPv4
Date: Sat, 1 Dec 2007 23:21:20 +1100
Message-ID: <20071201122120.GB14368@gondor.apana.org.au>
References: <474DB80E.5070403@redhat.com> <474DB930.5080409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>
To: Hideo AOKI <haoki@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3119 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752625AbXLAMVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 07:21:24 -0500
Content-Disposition: inline
In-Reply-To: <474DB930.5080409@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 28, 2007 at 01:53:36PM -0500, Hideo AOKI wrote:
>
> +/**
> + *	__skb_queue_purge_and_sub_memory_allocated
> + *		- empty a list and subtruct memory allocation counter
> + *	@sk:   sk
> + *	@list: list to empty
> + *	Delete all buffers on an &sk_buff list and subtruct the
> + *	truesize of the sk_buff for memory accounting. Each buffer
> + *	is removed from the list and one reference dropped. This
> + *	function does not take the list lock and the caller must
> + *	hold the relevant locks to use it.
> + */
> +static inline void __skb_queue_purge_and_sub_memory_allocated(struct sock *sk,
> +					struct sk_buff_head *list)
> +{
> +	struct sk_buff *skb;
> +	int purged_skb_size = 0;
> +	while ((skb = __skb_dequeue(list)) != NULL) {
> +		purged_skb_size += sk_datagram_pages(skb->truesize);
> +		kfree_skb(skb);
> +	}
> +	atomic_sub(purged_skb_size, sk->sk_prot->memory_allocated);
> +}

Thanks, this is a lot better than before!

However, I'm still a little concerned about the effect of two more
atomic op's per packet that we're adding here.  Hang on a sec, that
should've been Dave's line since atomic ops are cheap on x86 :)

But seriously, it's not so much that we have two more atomic op's
per packet, but we have two more writes to a single global counter
for each packet.  This is going to really suck on SMP.

So what I'd like to see is a scheme that's similar to sk_forward_alloc.
The idea is that each socket allocates memory using mem_schedule and
then stores it in sk_forward_alloc.  Each packet then only has to
add to/subtract from sk_forward_alloc.

There is one big problem with this though, UDP is not serialised like
TCP.  So you can't just use sk_forward_alloc since it's not an atomic_t.

We'll need to think about this one a bit more.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
