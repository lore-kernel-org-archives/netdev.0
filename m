From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [CORE]: datagram: basic memory accounting functions
Date: Thu, 20 Dec 2007 03:43:04 -0800 (PST)
Message-ID: <20071220.034304.212231150.davem@davemloft.net>
References: <47673195.80004@redhat.com>
	<47673299.3010301@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com
To: haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60223
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756065AbXLTLnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 06:43:05 -0500
In-Reply-To: <47673299.3010301@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hideo AOKI <haoki@redhat.com>
Date: Mon, 17 Dec 2007 21:38:17 -0500

Why do we need seperate stream and datagram accounting functions?

Is it just to facilitate things like the following test?

> +static inline int sk_wmem_schedule(struct sock *sk, int size)
> +{
> +	if (sk->sk_type == SOCK_DGRAM)
> +		return sk_datagram_wmem_schedule(sk, size);
> +	else
> +		return 1;
> +}

If so, this can be greatly improved.

All of these other functions are identical copies of the stream
counterparts, they should all be consolidated.

I still see a lot of special casing, instead of large pieces of common
code.

There should be one core set of functions that handle the memory
accounting, regardless of socket type.  Maybe there is one spot where
something like sk->prot->doing_memory_accounting is tested, but that's
it.

I am still very dissatisfied with these changes.  They are
full of special cases, because they mix generic facilities
(the socket memory accounting) with an unrelated issue
(we only support memory accounting for datagram sockets which
are actually UDP).

Also, the memory accounting is done at different parts in
the socket code paths for stream vs. datagram.  This is why
everything is inconsistent, and, a mess.

What's funny is that I absolutely do not care if these changes are
perfect and pass every possible regression test.  Rather, I'm more
concerned that this thing is designed correctly and will allow us to
have one core set of memory accounting functions regardless of socket
type.  As it is coded now, we have two sets of code paths to
fix, two ways of doing the socket accounting, and therefore twice
as much code to maintain and debug.

The whole thing needs to be consistent and without special cases.

The "protocol supports memory accounting" test can be performed, as
you did in this patch, by simply checking if
sk->sk_prot->memory_allocated is non-NULL.
