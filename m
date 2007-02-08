From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 4/5 resend] NET : Convert decnet route to use the new dst_entry
 'next' pointer
Date: Thu, 08 Feb 2007 22:44:13 +0100
Message-ID: <45CB99AD.1040006@cosmosbay.com>
References: <20070202120528.GA10392@de.ibm.com> <20070206.144106.39659974.davem@davemloft.net> <45C9093D.1030605@cosmosbay.com> <45CB9890.40501@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070702020900020604070201"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54442 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423449AbXBHVoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:44:25 -0500
In-Reply-To: <45CB9890.40501@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070702020900020604070201
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch removes the next pointer from 'struct rt6_info.u' union, and 
renames u.next to u.dst.rt6_next.

It also moves 'struct flowi' right after 'struct dst_entry' to prepare speedup 
lookups.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------070702020900020604070201
Content-Type: text/plain;
 name="decnet.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="decnet.patch"

--- linux-2.6.20/include/net/dn_route.h.orig	2007-02-08 21:36:15.000000000 +0100
+++ linux-2.6.20-ed/include/net/dn_route.h	2007-02-08 21:36:15.000000000 +0100
@@ -68,9 +68,10 @@ extern void dn_rt_cache_flush(int delay)
 struct dn_route {
 	union {
 		struct dst_entry dst;
-		struct dn_route *rt_next;
 	} u;
 
+	struct flowi fl;
+
 	__le16 rt_saddr;
 	__le16 rt_daddr;
 	__le16 rt_gateway;
@@ -80,8 +81,6 @@ struct dn_route {
 
 	unsigned rt_flags;
 	unsigned rt_type;
-
-	struct flowi fl;
 };
 
 extern void dn_route_init(void);
--- linux-2.6.20/net/decnet/dn_route.c.orig	2007-02-08 21:39:03.000000000 +0100
+++ linux-2.6.20-ed/net/decnet/dn_route.c	2007-02-08 21:39:03.000000000 +0100
@@ -167,11 +167,11 @@ static void dn_dst_check_expire(unsigned
 		while((rt=*rtp) != NULL) {
 			if (atomic_read(&rt->u.dst.__refcnt) ||
 					(now - rt->u.dst.lastuse) < expire) {
-				rtp = &rt->u.rt_next;
+				rtp = &rt->u.dst.dn_next;
 				continue;
 			}
-			*rtp = rt->u.rt_next;
-			rt->u.rt_next = NULL;
+			*rtp = rt->u.dst.dn_next;
+			rt->u.dst.dn_next = NULL;
 			dnrt_free(rt);
 		}
 		spin_unlock(&dn_rt_hash_table[i].lock);
@@ -198,11 +198,11 @@ static int dn_dst_gc(void)
 		while((rt=*rtp) != NULL) {
 			if (atomic_read(&rt->u.dst.__refcnt) ||
 					(now - rt->u.dst.lastuse) < expire) {
-				rtp = &rt->u.rt_next;
+				rtp = &rt->u.dst.dn_next;
 				continue;
 			}
-			*rtp = rt->u.rt_next;
-			rt->u.rt_next = NULL;
+			*rtp = rt->u.dst.dn_next;
+			rt->u.dst.dn_next = NULL;
 			dnrt_drop(rt);
 			break;
 		}
@@ -286,8 +286,8 @@ static int dn_insert_route(struct dn_rou
 	while((rth = *rthp) != NULL) {
 		if (compare_keys(&rth->fl, &rt->fl)) {
 			/* Put it first */
-			*rthp = rth->u.rt_next;
-			rcu_assign_pointer(rth->u.rt_next,
+			*rthp = rth->u.dst.dn_next;
+			rcu_assign_pointer(rth->u.dst.dn_next,
 					   dn_rt_hash_table[hash].chain);
 			rcu_assign_pointer(dn_rt_hash_table[hash].chain, rth);
 
@@ -300,10 +300,10 @@ static int dn_insert_route(struct dn_rou
 			*rp = rth;
 			return 0;
 		}
-		rthp = &rth->u.rt_next;
+		rthp = &rth->u.dst.dn_next;
 	}
 
-	rcu_assign_pointer(rt->u.rt_next, dn_rt_hash_table[hash].chain);
+	rcu_assign_pointer(rt->u.dst.dn_next, dn_rt_hash_table[hash].chain);
 	rcu_assign_pointer(dn_rt_hash_table[hash].chain, rt);
 	
 	dst_hold(&rt->u.dst);
@@ -326,8 +326,8 @@ void dn_run_flush(unsigned long dummy)
 			goto nothing_to_declare;
 
 		for(; rt; rt=next) {
-			next = rt->u.rt_next;
-			rt->u.rt_next = NULL;
+			next = rt->u.dst.dn_next;
+			rt->u.dst.dn_next = NULL;
 			dst_free((struct dst_entry *)rt);
 		}
 
@@ -1169,7 +1169,7 @@ static int __dn_route_output_key(struct 
 	if (!(flags & MSG_TRYHARD)) {
 		rcu_read_lock_bh();
 		for(rt = rcu_dereference(dn_rt_hash_table[hash].chain); rt;
-			rt = rcu_dereference(rt->u.rt_next)) {
+			rt = rcu_dereference(rt->u.dst.dn_next)) {
 			if ((flp->fld_dst == rt->fl.fld_dst) &&
 			    (flp->fld_src == rt->fl.fld_src) &&
 			    (flp->mark == rt->fl.mark) &&
@@ -1443,7 +1443,7 @@ int dn_route_input(struct sk_buff *skb)
 
 	rcu_read_lock();
 	for(rt = rcu_dereference(dn_rt_hash_table[hash].chain); rt != NULL;
-	    rt = rcu_dereference(rt->u.rt_next)) {
+	    rt = rcu_dereference(rt->u.dst.dn_next)) {
 		if ((rt->fl.fld_src == cb->src) &&
 	 	    (rt->fl.fld_dst == cb->dst) &&
 		    (rt->fl.oif == 0) &&
@@ -1627,7 +1627,7 @@ int dn_cache_dump(struct sk_buff *skb, s
 		rcu_read_lock_bh();
 		for(rt = rcu_dereference(dn_rt_hash_table[h].chain), idx = 0;
 			rt;
-			rt = rcu_dereference(rt->u.rt_next), idx++) {
+			rt = rcu_dereference(rt->u.dst.dn_next), idx++) {
 			if (idx < s_idx)
 				continue;
 			skb->dst = dst_clone(&rt->u.dst);
@@ -1673,7 +1673,7 @@ static struct dn_route *dn_rt_cache_get_
 {
 	struct dn_rt_cache_iter_state *s = rcu_dereference(seq->private);
 
-	rt = rt->u.rt_next;
+	rt = rt->u.dst.dn_next;
 	while(!rt) {
 		rcu_read_unlock_bh();
 		if (--s->bucket < 0)

--------------070702020900020604070201--
