From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache
Date: Wed, 9 Jan 2008 11:37:27 +0100
Message-ID: <20080109113727.50eae500.dada1@cosmosbay.com>
References: <E1JCU1E-00076z-00@gondolin.me.apana.org.au>
	<47847A10.1020508@cosmosbay.com>
	<20080109094637.GA28874@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, dipankar@in.ibm.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:52871 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752129AbYAIKhb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 05:37:31 -0500
In-Reply-To: <20080109094637.GA28874@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Jan 2008 20:46:37 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Wed, Jan 09, 2008 at 08:38:56AM +0100, Eric Dumazet wrote:
> > 
> > I am not sure this is valid, since it will do this :
> > 
> > r = rt_hash_table[st->bucket].chain;
> > if (r)
> >     return rcu_dereference(r);
> > 
> > So compiler might be dumb enough do dereference 
> > &rt_hash_table[st->bucket].chain two times.
> 
> That wouldn't be a problem at all.  The key is to add a barrier between
> reading the pointer:
> 
> 	r = rt_hash_table[st->bucket].chain
> 
> and dereferencing it later, e.g.,
> 
> 	r->u.dst.rt_next
> 
> The barrier is there so that when we dereference r we don't read
> stale cache that was there before the memory at r was initialised.
> How many times you read the pointer value before the barrier is
> irrelevant to the effectiveness of the barrier preceding the
> dereference.

You are absolutely right Herbert, so I changed the patch to :

[NET] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache

In rt_cache_get_next(), no need to guard seq->private by a rcu_dereference()
since seq is private to the thread running this function. Reading seq.private
once (as guaranted bu rcu_dereference()) or several time if compiler really is 
dumb enough wont change the result.

But we miss real spots where rcu_dereference() are needed, both in 
rt_cache_get_first() and rt_cache_get_next()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d337706..28484f3 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -283,12 +283,12 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
 			break;
 		rcu_read_unlock_bh();
 	}
-	return r;
+	return rcu_dereference(r);
 }
 
 static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
 {
-	struct rt_cache_iter_state *st = rcu_dereference(seq->private);
+	struct rt_cache_iter_state *st = seq->private;
 
 	r = r->u.dst.rt_next;
 	while (!r) {
@@ -298,7 +298,7 @@ static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
 		rcu_read_lock_bh();
 		r = rt_hash_table[st->bucket].chain;
 	}
-	return r;
+	return rcu_dereference(r);
 }
 
 static struct rtable *rt_cache_get_idx(struct seq_file *seq, loff_t pos)
