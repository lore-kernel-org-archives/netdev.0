From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [IPV4] ROUTE: Avoid sparse warnings
Date: Mon, 7 Jan 2008 12:01:17 +0100
Message-ID: <20080107120117.aeebd0c8.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:50021 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334AbYAGLBU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 06:01:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CHECK   net/ipv4/route.c
net/ipv4/route.c:298:2: warning: context imbalance in 'rt_cache_get_first' - wrong count at exit
net/ipv4/route.c:307:3: warning: context imbalance in 'rt_cache_get_next' - unexpected unlock
net/ipv4/route.c:346:3: warning: context imbalance in 'rt_cache_seq_stop' - unexpected unlock

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 10915bb..fec0571 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -289,11 +289,11 @@ static struct rtable *rt_cache_get_first(struct seq_file *seq)
 	struct rt_cache_iter_state *st = seq->private;
 
 	for (st->bucket = rt_hash_mask; st->bucket >= 0; --st->bucket) {
-		rcu_read_lock_bh();
 		r = rt_hash_table[st->bucket].chain;
 		if (r)
 			break;
 		rcu_read_unlock_bh();
+		rcu_read_lock_bh();
 	}
 	return r;
 }
@@ -305,9 +305,9 @@ static struct rtable *rt_cache_get_next(struct seq_file *seq, struct rtable *r)
 	r = r->u.dst.rt_next;
 	while (!r) {
 		rcu_read_unlock_bh();
+		rcu_read_lock_bh();
 		if (--st->bucket < 0)
 			break;
-		rcu_read_lock_bh();
 		r = rt_hash_table[st->bucket].chain;
 	}
 	return r;
@@ -324,7 +324,9 @@ static struct rtable *rt_cache_get_idx(struct seq_file *seq, loff_t pos)
 }
 
 static void *rt_cache_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(RCU_BH)
 {
+	rcu_read_lock_bh();
 	return *pos ? rt_cache_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 }
 
@@ -341,9 +343,9 @@ static void *rt_cache_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void rt_cache_seq_stop(struct seq_file *seq, void *v)
+	__releases(RCU_BH)
 {
-	if (v && v != SEQ_START_TOKEN)
-		rcu_read_unlock_bh();
+	rcu_read_unlock_bh();
 }
 
 static int rt_cache_seq_show(struct seq_file *seq, void *v)
