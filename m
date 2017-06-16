From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 16/21] decnet: take dst->__refcnt when struct dn_route is created
Date: Fri, 16 Jun 2017 10:47:39 -0700
Message-ID: <20170616174744.139688-17-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33467 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752548AbdFPRsj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:39 -0400
Received: by mail-pf0-f194.google.com with SMTP id w12so7568506pfk.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:39 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

struct dn_route is inserted into dn_rt_hash_table but no dst->__refcnt
is taken.
This patch makes sure the dn_rt_hash_table's reference to the dst is ref
counted.

As the dst is always ref counted properly, we can safely mark
DST_NOGC flag so dst_release() will release dst based on refcnt only.
And dst gc is no longer needed and all dst_free() or its related
function calls should be replaced with dst_release() or
dst_release_immediate(). And dst_dev_put() is called when removing dst
from the hash table to release the reference on dst->dev before we lose
pointer to it.

Also, correct the logic in dn_dst_check_expire() and dn_dst_gc() to
check dst->__refcnt to be > 1 to indicate it is referenced by other
users.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 net/decnet/dn_route.c | 36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 6f95612b4d32..f467c4e3205b 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -183,11 +183,6 @@ static __inline__ unsigned int dn_hash(__le16 src, __le16 dst)
 	return dn_rt_hash_mask & (unsigned int)tmp;
 }
 
-static inline void dnrt_free(struct dn_route *rt)
-{
-	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
-}
-
 static void dn_dst_check_expire(unsigned long dummy)
 {
 	int i;
@@ -202,14 +197,15 @@ static void dn_dst_check_expire(unsigned long dummy)
 		spin_lock(&dn_rt_hash_table[i].lock);
 		while ((rt = rcu_dereference_protected(*rtp,
 						lockdep_is_held(&dn_rt_hash_table[i].lock))) != NULL) {
-			if (atomic_read(&rt->dst.__refcnt) ||
-					(now - rt->dst.lastuse) < expire) {
+			if (atomic_read(&rt->dst.__refcnt) > 1 ||
+			    (now - rt->dst.lastuse) < expire) {
 				rtp = &rt->dst.dn_next;
 				continue;
 			}
 			*rtp = rt->dst.dn_next;
 			rt->dst.dn_next = NULL;
-			dnrt_free(rt);
+			dst_dev_put(&rt->dst);
+			dst_release(&rt->dst);
 		}
 		spin_unlock(&dn_rt_hash_table[i].lock);
 
@@ -235,14 +231,15 @@ static int dn_dst_gc(struct dst_ops *ops)
 
 		while ((rt = rcu_dereference_protected(*rtp,
 						lockdep_is_held(&dn_rt_hash_table[i].lock))) != NULL) {
-			if (atomic_read(&rt->dst.__refcnt) ||
-					(now - rt->dst.lastuse) < expire) {
+			if (atomic_read(&rt->dst.__refcnt) > 1 ||
+			    (now - rt->dst.lastuse) < expire) {
 				rtp = &rt->dst.dn_next;
 				continue;
 			}
 			*rtp = rt->dst.dn_next;
 			rt->dst.dn_next = NULL;
-			dnrt_free(rt);
+			dst_dev_put(&rt->dst);
+			dst_release(&rt->dst);
 			break;
 		}
 		spin_unlock_bh(&dn_rt_hash_table[i].lock);
@@ -344,7 +341,7 @@ static int dn_insert_route(struct dn_route *rt, unsigned int hash, struct dn_rou
 			dst_use(&rth->dst, now);
 			spin_unlock_bh(&dn_rt_hash_table[hash].lock);
 
-			dst_free(&rt->dst);
+			dst_release_immediate(&rt->dst);
 			*rp = rth;
 			return 0;
 		}
@@ -374,7 +371,8 @@ static void dn_run_flush(unsigned long dummy)
 		for(; rt; rt = next) {
 			next = rcu_dereference_raw(rt->dst.dn_next);
 			RCU_INIT_POINTER(rt->dst.dn_next, NULL);
-			dnrt_free(rt);
+			dst_dev_put(&rt->dst);
+			dst_release(&rt->dst);
 		}
 
 nothing_to_declare:
@@ -1181,7 +1179,8 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowidn *o
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
-	rt = dst_alloc(&dn_dst_ops, dev_out, 0, DST_OBSOLETE_NONE, DST_HOST);
+	rt = dst_alloc(&dn_dst_ops, dev_out, 1, DST_OBSOLETE_NONE,
+		       DST_HOST | DST_NOGC);
 	if (rt == NULL)
 		goto e_nobufs;
 
@@ -1215,6 +1214,7 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowidn *o
 		goto e_neighbour;
 
 	hash = dn_hash(rt->fld.saddr, rt->fld.daddr);
+	/* dn_insert_route() increments dst->__refcnt */
 	dn_insert_route(rt, hash, (struct dn_route **)pprt);
 
 done:
@@ -1237,7 +1237,7 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowidn *o
 	err = -ENOBUFS;
 	goto done;
 e_neighbour:
-	dst_free(&rt->dst);
+	dst_release_immediate(&rt->dst);
 	goto e_nobufs;
 }
 
@@ -1445,7 +1445,8 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	}
 
 make_route:
-	rt = dst_alloc(&dn_dst_ops, out_dev, 0, DST_OBSOLETE_NONE, DST_HOST);
+	rt = dst_alloc(&dn_dst_ops, out_dev, 1, DST_OBSOLETE_NONE,
+		       DST_HOST | DST_NOGC);
 	if (rt == NULL)
 		goto e_nobufs;
 
@@ -1491,6 +1492,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 		goto e_neighbour;
 
 	hash = dn_hash(rt->fld.saddr, rt->fld.daddr);
+	/* dn_insert_route() increments dst->__refcnt */
 	dn_insert_route(rt, hash, &rt);
 	skb_dst_set(skb, &rt->dst);
 
@@ -1514,7 +1516,7 @@ static int dn_route_input_slow(struct sk_buff *skb)
 	goto done;
 
 e_neighbour:
-	dst_free(&rt->dst);
+	dst_release_immediate(&rt->dst);
 	goto done;
 }
 
-- 
2.13.1.518.g3df882009-goog
