From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 02/12] decnet: Move dn_next into decnet route structure.
Date: Wed, 25 Oct 2017 23:02:51 +0900 (KST)
Message-ID: <20171025.230251.835152108605487573.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48292 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751977AbdJYOCz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:02:55 -0400
Received: from localhost (unknown [106.252.28.196])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 2CE76133F06AD
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:02:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dn_route.h |  1 +
 include/net/dst.h      |  1 -
 net/decnet/dn_route.c  | 34 ++++++++++++++++++----------------
 3 files changed, 19 insertions(+), 17 deletions(-)

diff --git a/include/net/dn_route.h b/include/net/dn_route.h
index 55df9939bca2..342d2503cba5 100644
--- a/include/net/dn_route.h
+++ b/include/net/dn_route.h
@@ -69,6 +69,7 @@ int dn_route_rcv(struct sk_buff *skb, struct net_device *dev,
  */
 struct dn_route {
 	struct dst_entry dst;
+	struct dn_route __rcu *dn_next;
 
 	struct neighbour *n;
 
diff --git a/include/net/dst.h b/include/net/dst.h
index 75462861b12f..14a0eec8e7d8 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -101,7 +101,6 @@ struct dst_entry {
 	union {
 		struct dst_entry	*next;
 		struct rt6_info __rcu	*rt6_next;
-		struct dn_route __rcu	*dn_next;
 	};
 };
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index bff5ab88cdbb..fd43c442ab52 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -199,11 +199,11 @@ static void dn_dst_check_expire(unsigned long dummy)
 						lockdep_is_held(&dn_rt_hash_table[i].lock))) != NULL) {
 			if (atomic_read(&rt->dst.__refcnt) > 1 ||
 			    (now - rt->dst.lastuse) < expire) {
-				rtp = &rt->dst.dn_next;
+				rtp = &rt->dn_next;
 				continue;
 			}
-			*rtp = rt->dst.dn_next;
-			rt->dst.dn_next = NULL;
+			*rtp = rt->dn_next;
+			rt->dn_next = NULL;
 			dst_dev_put(&rt->dst);
 			dst_release(&rt->dst);
 		}
@@ -233,11 +233,11 @@ static int dn_dst_gc(struct dst_ops *ops)
 						lockdep_is_held(&dn_rt_hash_table[i].lock))) != NULL) {
 			if (atomic_read(&rt->dst.__refcnt) > 1 ||
 			    (now - rt->dst.lastuse) < expire) {
-				rtp = &rt->dst.dn_next;
+				rtp = &rt->dn_next;
 				continue;
 			}
-			*rtp = rt->dst.dn_next;
-			rt->dst.dn_next = NULL;
+			*rtp = rt->dn_next;
+			rt->dn_next = NULL;
 			dst_dev_put(&rt->dst);
 			dst_release(&rt->dst);
 			break;
@@ -333,8 +333,8 @@ static int dn_insert_route(struct dn_route *rt, unsigned int hash, struct dn_rou
 						lockdep_is_held(&dn_rt_hash_table[hash].lock))) != NULL) {
 		if (compare_keys(&rth->fld, &rt->fld)) {
 			/* Put it first */
-			*rthp = rth->dst.dn_next;
-			rcu_assign_pointer(rth->dst.dn_next,
+			*rthp = rth->dn_next;
+			rcu_assign_pointer(rth->dn_next,
 					   dn_rt_hash_table[hash].chain);
 			rcu_assign_pointer(dn_rt_hash_table[hash].chain, rth);
 
@@ -345,10 +345,10 @@ static int dn_insert_route(struct dn_route *rt, unsigned int hash, struct dn_rou
 			*rp = rth;
 			return 0;
 		}
-		rthp = &rth->dst.dn_next;
+		rthp = &rth->dn_next;
 	}
 
-	rcu_assign_pointer(rt->dst.dn_next, dn_rt_hash_table[hash].chain);
+	rcu_assign_pointer(rt->dn_next, dn_rt_hash_table[hash].chain);
 	rcu_assign_pointer(dn_rt_hash_table[hash].chain, rt);
 
 	dst_hold_and_use(&rt->dst, now);
@@ -369,8 +369,8 @@ static void dn_run_flush(unsigned long dummy)
 			goto nothing_to_declare;
 
 		for(; rt; rt = next) {
-			next = rcu_dereference_raw(rt->dst.dn_next);
-			RCU_INIT_POINTER(rt->dst.dn_next, NULL);
+			next = rcu_dereference_raw(rt->dn_next);
+			RCU_INIT_POINTER(rt->dn_next, NULL);
 			dst_dev_put(&rt->dst);
 			dst_release(&rt->dst);
 		}
@@ -1183,6 +1183,7 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowidn *o
 	if (rt == NULL)
 		goto e_nobufs;
 
+	rt->dn_next = NULL;
 	memset(&rt->fld, 0, sizeof(rt->fld));
 	rt->fld.saddr        = oldflp->saddr;
 	rt->fld.daddr        = oldflp->daddr;
@@ -1252,7 +1253,7 @@ static int __dn_route_output_key(struct dst_entry **pprt, const struct flowidn *
 	if (!(flags & MSG_TRYHARD)) {
 		rcu_read_lock_bh();
 		for (rt = rcu_dereference_bh(dn_rt_hash_table[hash].chain); rt;
-			rt = rcu_dereference_bh(rt->dst.dn_next)) {
+			rt = rcu_dereference_bh(rt->dn_next)) {
 			if ((flp->daddr == rt->fld.daddr) &&
 			    (flp->saddr == rt->fld.saddr) &&
 			    (flp->flowidn_mark == rt->fld.flowidn_mark) &&
@@ -1448,6 +1449,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	if (rt == NULL)
 		goto e_nobufs;
 
+	rt->dn_next = NULL;
 	memset(&rt->fld, 0, sizeof(rt->fld));
 	rt->rt_saddr      = fld.saddr;
 	rt->rt_daddr      = fld.daddr;
@@ -1529,7 +1531,7 @@ static int dn_route_input(struct sk_buff *skb)
 
 	rcu_read_lock();
 	for(rt = rcu_dereference(dn_rt_hash_table[hash].chain); rt != NULL;
-	    rt = rcu_dereference(rt->dst.dn_next)) {
+	    rt = rcu_dereference(rt->dn_next)) {
 		if ((rt->fld.saddr == cb->src) &&
 		    (rt->fld.daddr == cb->dst) &&
 		    (rt->fld.flowidn_oif == 0) &&
@@ -1749,7 +1751,7 @@ int dn_cache_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		rcu_read_lock_bh();
 		for(rt = rcu_dereference_bh(dn_rt_hash_table[h].chain), idx = 0;
 			rt;
-			rt = rcu_dereference_bh(rt->dst.dn_next), idx++) {
+			rt = rcu_dereference_bh(rt->dn_next), idx++) {
 			if (idx < s_idx)
 				continue;
 			skb_dst_set(skb, dst_clone(&rt->dst));
@@ -1795,7 +1797,7 @@ static struct dn_route *dn_rt_cache_get_next(struct seq_file *seq, struct dn_rou
 {
 	struct dn_rt_cache_iter_state *s = seq->private;
 
-	rt = rcu_dereference_bh(rt->dst.dn_next);
+	rt = rcu_dereference_bh(rt->dn_next);
 	while (!rt) {
 		rcu_read_unlock_bh();
 		if (--s->bucket < 0)
-- 
2.13.6
