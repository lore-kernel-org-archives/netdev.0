From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Wed, 9 Jan 2008 20:46:37 +1100
Message-ID: <20080109094637.GA28874@gondor.apana.org.au>
References: <E1JCU1E-00076z-00@gondolin.me.apana.org.au> <47847A10.1020508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4350 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751306AbYAIJsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 04:48:13 -0500
Content-Disposition: inline
In-Reply-To: <47847A10.1020508@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2008 at 08:38:56AM +0100, Eric Dumazet wrote:
> 
> I am not sure this is valid, since it will do this :
> 
> r = rt_hash_table[st->bucket].chain;
> if (r)
>     return rcu_dereference(r);
> 
> So compiler might be dumb enough do dereference 
> &rt_hash_table[st->bucket].chain two times.

That wouldn't be a problem at all.  The key is to add a barrier between
reading the pointer:

	r = rt_hash_table[st->bucket].chain

and dereferencing it later, e.g.,

	r->u.dst.rt_next

The barrier is there so that when we dereference r we don't read
stale cache that was there before the memory at r was initialised.
How many times you read the pointer value before the barrier is
irrelevant to the effectiveness of the barrier preceding the
dereference.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
