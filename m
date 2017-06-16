From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net] decnet: always not take dst->__refcnt when inserting dst into hash table
Date: Fri, 16 Jun 2017 10:46:37 -0700
Message-ID: <20170616174637.139429-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32962 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdFPRrG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:47:06 -0400
Received: by mail-pg0-f65.google.com with SMTP id u62so1637613pgb.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:47:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

In the existing dn_route.c code, dn_route_output_slow() takes
dst->__refcnt before calling dn_insert_route() while dn_route_input_slow()
does not take dst->__refcnt before calling dn_insert_route().
This makes the whole routing code very buggy.
In dn_dst_check_expire(), dnrt_free() is called when rt expires. This
makes the routes inserted by dn_route_output_slow() not able to be
freed as the refcnt is not released.
In dn_dst_gc(), dnrt_drop() is called to release rt which could
potentially cause the dst->__refcnt to be dropped to -1.
In dn_run_flush(), dst_free() is called to release all the dst. Again,
it makes the dst inserted by dn_route_output_slow() not able to be
released and also, it does not wait on the rcu and could potentially
cause crash in the path where other users still refer to this dst.

This patch makes sure both input and output path do not take
dst->__refcnt before calling dn_insert_route() and also makes sure
dnrt_free()/dst_free() is called when removing dst from the hash table.
The only difference between those 2 calls is that dnrt_free() waits on
the rcu while dst_free() does not.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 net/decnet/dn_route.c | 14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 4b9518a0d248..6f95612b4d32 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -188,12 +188,6 @@ static inline void dnrt_free(struct dn_route *rt)
 	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
 }
 
-static inline void dnrt_drop(struct dn_route *rt)
-{
-	dst_release(&rt->dst);
-	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
-}
-
 static void dn_dst_check_expire(unsigned long dummy)
 {
 	int i;
@@ -248,7 +242,7 @@ static int dn_dst_gc(struct dst_ops *ops)
 			}
 			*rtp = rt->dst.dn_next;
 			rt->dst.dn_next = NULL;
-			dnrt_drop(rt);
+			dnrt_free(rt);
 			break;
 		}
 		spin_unlock_bh(&dn_rt_hash_table[i].lock);
@@ -350,7 +344,7 @@ static int dn_insert_route(struct dn_route *rt, unsigned int hash, struct dn_rou
 			dst_use(&rth->dst, now);
 			spin_unlock_bh(&dn_rt_hash_table[hash].lock);
 
-			dnrt_drop(rt);
+			dst_free(&rt->dst);
 			*rp = rth;
 			return 0;
 		}
@@ -380,7 +374,7 @@ static void dn_run_flush(unsigned long dummy)
 		for(; rt; rt = next) {
 			next = rcu_dereference_raw(rt->dst.dn_next);
 			RCU_INIT_POINTER(rt->dst.dn_next, NULL);
-			dst_free((struct dst_entry *)rt);
+			dnrt_free(rt);
 		}
 
 nothing_to_declare:
@@ -1187,7 +1181,7 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowidn *o
 	if (dev_out->flags & IFF_LOOPBACK)
 		flags |= RTCF_LOCAL;
 
-	rt = dst_alloc(&dn_dst_ops, dev_out, 1, DST_OBSOLETE_NONE, DST_HOST);
+	rt = dst_alloc(&dn_dst_ops, dev_out, 0, DST_OBSOLETE_NONE, DST_HOST);
 	if (rt == NULL)
 		goto e_nobufs;
 
-- 
2.13.1.518.g3df882009-goog
