From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Wed, 9 Jan 2008 06:22:58 -0800
Message-ID: <20080109142258.GC13714@linux.vnet.ibm.com>
References: <E1JCU1E-00076z-00@gondolin.me.apana.org.au> <47847A10.1020508@cosmosbay.com> <20080109094637.GA28874@gondor.apana.org.au> <20080109113727.50eae500.dada1@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	dipankar@in.ibm.com, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:60273 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbYAIOXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 09:23:10 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m09EN9Uw017057
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 09:23:10 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09EN1ET115500
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 07:23:09 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09EN0JC019401
	for <netdev@vger.kernel.org>; Wed, 9 Jan 2008 07:23:00 -0700
Content-Disposition: inline
In-Reply-To: <20080109113727.50eae500.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2008 at 11:37:27AM +0100, Eric Dumazet wrote:
> On Wed, 9 Jan 2008 20:46:37 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > On Wed, Jan 09, 2008 at 08:38:56AM +0100, Eric Dumazet wrote:
> > > 
> > > I am not sure this is valid, since it will do this :
> > > 
> > > r = rt_hash_table[st->bucket].chain;
> > > if (r)
> > >     return rcu_dereference(r);
> > > 
> > > So compiler might be dumb enough do dereference 
> > > &rt_hash_table[st->bucket].chain two times.
> > 
> > That wouldn't be a problem at all.  The key is to add a barrier between
> > reading the pointer:
> > 
> > 	r = rt_hash_table[st->bucket].chain
> > 
> > and dereferencing it later, e.g.,
> > 
> > 	r->u.dst.rt_next
> > 
> > The barrier is there so that when we dereference r we don't read
> > stale cache that was there before the memory at r was initialised.
> > How many times you read the pointer value before the barrier is
> > irrelevant to the effectiveness of the barrier preceding the
> > dereference.

Agreed -- as long as you don't try to dereference the pointer before
passing it through rcu_dereference(), and as long as both the initial
fetch of the pointer, the rcu_dereference(), and the actual dereferencing
of the pointer are all within the same RCU read-side critical section.

> You are absolutely right Herbert, so I changed the patch to :
> 
> [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
> 
> In rt_cache_get_next(), no need to guard seq->private by a rcu_dereference()
> since seq is private to the thread running this function. Reading seq.private
> once (as guaranted bu rcu_dereference()) or several time if compiler really is 
> dumb enough wont change the result.
> 
> But we miss real spots where rcu_dereference() are needed, both in 
> rt_cache_get_first() and rt_cache_get_next()
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index d337706..28484f3 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -283,12 +283,12 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
>  			break;
>  		rcu_read_unlock_bh();
>  	}
> -	return r;
> +	return rcu_dereference(r);
>  }

Would it be possible to tag rt_cache_get_first() with an __acquires(RCU)
to help out sparse?

>  static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
>  {
> -	struct rt_cache_iter_state *st = rcu_dereference(seq->private);
> +	struct rt_cache_iter_state *st = seq->private;
> 
>  	r = r->u.dst.rt_next;
>  	while (!r) {
> @@ -298,7 +298,7 @@ static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
>  		rcu_read_lock_bh();
>  		r = rt_hash_table[st->bucket].chain;
>  	}
> -	return r;
> +	return rcu_dereference(r);
>  }

Ditto for rt_cache_get_next()?

>  static struct rtable *rt_cache_get_idx(struct seq_file *seq, loff_t pos)

There would need to be a __releases(RCU) somewhere -- possibly
in rt_cache_seq_stop(), but need to defer to you guys on this one.

						Thanx, Paul
