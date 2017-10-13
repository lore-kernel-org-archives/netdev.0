From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next] ipv6: only update __use and lastusetime once per jiffy at most
Date: Fri, 13 Oct 2017 15:08:07 -0700
Message-ID: <20171013220807.90366-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Paolo Abeni <pabeni@redhat.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:45146 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752360AbdJMWIO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 18:08:14 -0400
Received: by mail-pg0-f43.google.com with SMTP id b192so2213110pga.2
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 15:08:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

In order to not dirty the cacheline too often, we try to only update
dst->__use and dst->lastusetime at most once per jiffy.
As dst->lastusetime is only used by ipv6 garbage collector, it should
be good enough time resolution.
And __use is only used in ipv6_route_seq_show() to show how many times a
dst has been used. And as __use is not atomic_t right now, it does not
show the precise number of usage times anyway. So we think it should be
OK to only update it at most once per jiffy.

According to my latest syn flood test on a machine with intel Xeon 6th
gen processor and 2 10G mlx nics bonded together, each with 8 rx queues
on 2 NUMA nodes:
With this patch, the packet process rate increases from ~3.49Mpps to
~3.75Mpps with a 7% increase rate.

Note: dst_use() is being renamed to dst_hold_and_use() to better specify
the purpose of the function.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Eric Dumazet <edumazet@googl.com>
---
 include/net/dst.h     | 15 ++++++++-------
 net/decnet/dn_route.c |  8 ++++----
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 204c19e25456..5047e8053d6c 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -255,17 +255,18 @@ static inline void dst_hold(struct dst_entry *dst)
 	WARN_ON(atomic_inc_not_zero(&dst->__refcnt) == 0);
 }
 
-static inline void dst_use(struct dst_entry *dst, unsigned long time)
+static inline void dst_use_noref(struct dst_entry *dst, unsigned long time)
 {
-	dst_hold(dst);
-	dst->__use++;
-	dst->lastuse = time;
+	if (time != dst->lastuse) {
+		dst->__use++;
+		dst->lastuse = time;
+	}
 }
 
-static inline void dst_use_noref(struct dst_entry *dst, unsigned long time)
+static inline void dst_hold_and_use(struct dst_entry *dst, unsigned long time)
 {
-	dst->__use++;
-	dst->lastuse = time;
+	dst_hold(dst);
+	dst_use_noref(dst, time);
 }
 
 static inline struct dst_entry *dst_clone(struct dst_entry *dst)
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 0bd3afd01dd2..bff5ab88cdbb 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -338,7 +338,7 @@ static int dn_insert_route(struct dn_route *rt, unsigned int hash, struct dn_rou
 					   dn_rt_hash_table[hash].chain);
 			rcu_assign_pointer(dn_rt_hash_table[hash].chain, rth);
 
-			dst_use(&rth->dst, now);
+			dst_hold_and_use(&rth->dst, now);
 			spin_unlock_bh(&dn_rt_hash_table[hash].lock);
 
 			dst_release_immediate(&rt->dst);
@@ -351,7 +351,7 @@ static int dn_insert_route(struct dn_route *rt, unsigned int hash, struct dn_rou
 	rcu_assign_pointer(rt->dst.dn_next, dn_rt_hash_table[hash].chain);
 	rcu_assign_pointer(dn_rt_hash_table[hash].chain, rt);
 
-	dst_use(&rt->dst, now);
+	dst_hold_and_use(&rt->dst, now);
 	spin_unlock_bh(&dn_rt_hash_table[hash].lock);
 	*rp = rt;
 	return 0;
@@ -1258,7 +1258,7 @@ static int __dn_route_output_key(struct dst_entry **pprt, const struct flowidn *
 			    (flp->flowidn_mark == rt->fld.flowidn_mark) &&
 			    dn_is_output_route(rt) &&
 			    (rt->fld.flowidn_oif == flp->flowidn_oif)) {
-				dst_use(&rt->dst, jiffies);
+				dst_hold_and_use(&rt->dst, jiffies);
 				rcu_read_unlock_bh();
 				*pprt = &rt->dst;
 				return 0;
@@ -1535,7 +1535,7 @@ static int dn_route_input(struct sk_buff *skb)
 		    (rt->fld.flowidn_oif == 0) &&
 		    (rt->fld.flowidn_mark == skb->mark) &&
 		    (rt->fld.flowidn_iif == cb->iif)) {
-			dst_use(&rt->dst, jiffies);
+			dst_hold_and_use(&rt->dst, jiffies);
 			rcu_read_unlock();
 			skb_dst_set(skb, (struct dst_entry *)rt);
 			return 0;
-- 
2.15.0.rc0.271.g36b669edcc-goog
