From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [DECNET] ROUTE: fix rcu_dereference() uses in
 /proc/net/decnet_cache
Date: Thu, 10 Jan 2008 15:06:10 +0100
Message-ID: <20080110150610.c13e2125.dada1@cosmosbay.com>
References: <E1JCU1E-00076z-00@gondolin.me.apana.org.au>
	<47847A10.1020508@cosmosbay.com>
	<20080109094637.GA28874@gondor.apana.org.au>
	<20080109113727.50eae500.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	dipankar@in.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:41562 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754118AbYAJOGL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 09:06:11 -0500
In-Reply-To: <20080109113727.50eae500.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

Here is DECNET part, shadowing commit 0bcceadceb0907094ba4e40bf9a7cd9b080f13fb ([IPV4] ROUTE: fix rcu_dereference() uses in /proc/net/rt_cache )

Thank you


[DECNET] ROUTE: fix rcu_dereference() uses in /proc/net/decnet_cache

In dn_rt_cache_get_next(), no need to guard seq->private by a rcu_dereference()
since seq is private to the thread running this function. Reading seq.private
once (as guaranted bu rcu_dereference()) or several time if compiler really is 
dumb enough wont change the result.
 
But we miss real spots where rcu_dereference() are needed, both in 
dn_rt_cache_get_first() and dn_rt_cache_get_next()

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 66663e5..0e10ff2 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -1665,12 +1665,12 @@ static struct dn_route *dn_rt_cache_get_first(struct seq_file *seq)
 			break;
 		rcu_read_unlock_bh();
 	}
-	return rt;
+	return rcu_dereference(rt);
 }
 
 static struct dn_route *dn_rt_cache_get_next(struct seq_file *seq, struct dn_route *rt)
 {
-	struct dn_rt_cache_iter_state *s = rcu_dereference(seq->private);
+	struct dn_rt_cache_iter_state *s = seq->private;
 
 	rt = rt->u.dst.dn_next;
 	while(!rt) {
@@ -1680,7 +1680,7 @@ static struct dn_route *dn_rt_cache_get_next(struct seq_file *seq, struct dn_rou
 		rcu_read_lock_bh();
 		rt = dn_rt_hash_table[s->bucket].chain;
 	}
-	return rt;
+	return rcu_dereference(rt);
 }
 
 static void *dn_rt_cache_seq_start(struct seq_file *seq, loff_t *pos)
