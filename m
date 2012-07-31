From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Restore old dst_free() behavior.
Date: Mon, 30 Jul 2012 22:38:27 -0700 (PDT)
Message-ID: <20120730.223827.74792864437911339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755246Ab2GaFia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 01:38:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric, this is what I'd like to propose.

It seems the problem you were likely running into was simply
the fact that we were not inserting an RCU grace period for
the dst_free() that we do when purging a FIB nexthop.

So this reverts your change, and instead adds the necessary
call_rcu_bh() wrapper around the dst_free() done in fib_semantics.c

That makes it so that we don't need all of that inc_not_zero stuff for
sockets, and the special dst flag.  If we set the pointer to NULL,
then do the dst_free() via RCU, we can test that refcount safely in
dst_free() since it can only decrease at that point.

What do you think?  Does it pass your tests?

Thanks.

diff --git a/include/net/dst.h b/include/net/dst.h
index 31a9fd3..baf5978 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -61,7 +61,6 @@ struct dst_entry {
 #define DST_NOPEER		0x0040
 #define DST_FAKE_RTABLE		0x0080
 #define DST_XFRM_TUNNEL		0x0100
-#define DST_RCU_FREE		0x0200
 
 	unsigned short		pending_confirm;
 
@@ -383,6 +382,12 @@ static inline void dst_free(struct dst_entry *dst)
 	__dst_free(dst);
 }
 
+static inline void dst_rcu_free(struct rcu_head *head)
+{
+	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
+	dst_free(dst);
+}
+
 static inline void dst_confirm(struct dst_entry *dst)
 {
 	dst->pending_confirm = 1;
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index e3fd34c..613cfa4 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -249,17 +249,4 @@ static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
 	return flags;
 }
 
-static inline void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
-{
-	struct dst_entry *dst = skb_dst(skb);
-
-	if (atomic_inc_not_zero(&dst->__refcnt)) {
-		if (!(dst->flags & DST_RCU_FREE))
-			dst->flags |= DST_RCU_FREE;
-
-		sk->sk_rx_dst = dst;
-		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
-	}
-}
-
 #endif	/* _INET_SOCK_H */
diff --git a/net/core/dst.c b/net/core/dst.c
index d9e33eb..069d51d 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -258,15 +258,6 @@ again:
 }
 EXPORT_SYMBOL(dst_destroy);
 
-static void dst_rcu_destroy(struct rcu_head *head)
-{
-	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
-
-	dst = dst_destroy(dst);
-	if (dst)
-		__dst_free(dst);
-}
-
 void dst_release(struct dst_entry *dst)
 {
 	if (dst) {
@@ -274,14 +265,10 @@ void dst_release(struct dst_entry *dst)
 
 		newrefcnt = atomic_dec_return(&dst->__refcnt);
 		WARN_ON(newrefcnt < 0);
-		if (unlikely(dst->flags & (DST_NOCACHE | DST_RCU_FREE)) && !newrefcnt) {
-			if (dst->flags & DST_RCU_FREE) {
-				call_rcu_bh(&dst->rcu_head, dst_rcu_destroy);
-			} else {
-				dst = dst_destroy(dst);
-				if (dst)
-					__dst_free(dst);
-			}
+		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt) {
+			dst = dst_destroy(dst);
+			if (dst)
+				__dst_free(dst);
 		}
 	}
 }
@@ -333,14 +320,11 @@ EXPORT_SYMBOL(__dst_destroy_metrics_generic);
  */
 void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst)
 {
-	bool hold;
-
 	WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
 	/* If dst not in cache, we must take a reference, because
 	 * dst_release() will destroy dst as soon as its refcount becomes zero
 	 */
-	hold = (dst->flags & (DST_NOCACHE | DST_RCU_FREE)) == DST_NOCACHE;
-	if (unlikely(hold)) {
+	if (unlikely(dst->flags & DST_NOCACHE)) {
 		dst_hold(dst);
 		skb_dst_set(skb, dst);
 	} else {
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 2671977..85a3604 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -184,12 +184,6 @@ static __inline__ unsigned int dn_hash(__le16 src, __le16 dst)
 	return dn_rt_hash_mask & (unsigned int)tmp;
 }
 
-static inline void dst_rcu_free(struct rcu_head *head)
-{
-	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
-	dst_free(dst);
-}
-
 static inline void dnrt_free(struct dn_route *rt)
 {
 	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index e55171f..67bbaf5 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -161,6 +161,17 @@ static void free_nh_exceptions(struct fib_nh *nh)
 	kfree(hash);
 }
 
+static void rt_nexthop_free(struct rtable **rtp)
+{
+	struct rtable *rt = *rtp;
+
+	if (!rt)
+		return;
+	*rtp = NULL;
+
+	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
+}
+
 /* Release a nexthop info record */
 static void free_fib_info_rcu(struct rcu_head *head)
 {
@@ -171,10 +182,8 @@ static void free_fib_info_rcu(struct rcu_head *head)
 			dev_put(nexthop_nh->nh_dev);
 		if (nexthop_nh->nh_exceptions)
 			free_nh_exceptions(nexthop_nh);
-		if (nexthop_nh->nh_rth_output)
-			dst_release(&nexthop_nh->nh_rth_output->dst);
-		if (nexthop_nh->nh_rth_input)
-			dst_release(&nexthop_nh->nh_rth_input->dst);
+		rt_nexthop_free(&nexthop_nh->nh_rth_output);
+		rt_nexthop_free(&nexthop_nh->nh_rth_input);
 	} endfor_nexthops(fi);
 
 	release_net(fi->fib_net);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index d6eabcf..fc1a81c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1199,6 +1199,11 @@ restart:
 	fnhe->fnhe_stamp = jiffies;
 }
 
+static inline void rt_free(struct rtable *rt)
+{
+	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
+}
+
 static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 {
 	struct rtable *orig, *prev, **p = &nh->nh_rth_output;
@@ -1208,14 +1213,17 @@ static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 
 	orig = *p;
 
-	rt->dst.flags |= DST_RCU_FREE;
-	dst_hold(&rt->dst);
 	prev = cmpxchg(p, orig, rt);
 	if (prev == orig) {
 		if (orig)
-			dst_release(&orig->dst);
+			rt_free(orig);
 	} else {
-		dst_release(&rt->dst);
+		/* Routes we intend to cache in the FIB nexthop have
+		 * the DST_NOCACHE bit clear.  However, if we are
+		 * unsuccessful at storing this route into the cache
+		 * we really need to set it.
+		 */
+		rt->dst.flags |= DST_NOCACHE;
 	}
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9be30b0..a356e1f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5604,7 +5604,8 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 	tcp_set_state(sk, TCP_ESTABLISHED);
 
 	if (skb != NULL) {
-		inet_sk_rx_dst_set(sk, skb);
+		sk->sk_rx_dst = dst_clone(skb_dst(skb));
+		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
 		security_inet_conn_established(sk, skb);
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7f91e5a..2fbd992 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1617,19 +1617,19 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 #endif
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
-		struct dst_entry *dst = sk->sk_rx_dst;
-
 		sock_rps_save_rxhash(sk, skb);
-		if (dst) {
+		if (sk->sk_rx_dst) {
+			struct dst_entry *dst = sk->sk_rx_dst;
 			if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
 			    dst->ops->check(dst, 0) == NULL) {
 				dst_release(dst);
 				sk->sk_rx_dst = NULL;
 			}
 		}
-		if (unlikely(sk->sk_rx_dst == NULL))
-			inet_sk_rx_dst_set(sk, skb);
-
+		if (unlikely(sk->sk_rx_dst == NULL)) {
+			sk->sk_rx_dst = dst_clone(skb_dst(skb));
+			inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+		}
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
 			rsk = sk;
 			goto reset;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 232a90c..3f1cc20 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -387,7 +387,8 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_sock *oldtp = tcp_sk(sk);
 		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
 
-		inet_sk_rx_dst_set(newsk, skb);
+		newsk->sk_rx_dst = dst_clone(skb_dst(skb));
+		inet_sk(newsk)->rx_dst_ifindex = skb->skb_iif;
 
 		/* TCP Cookie Transactions require space for the cookie pair,
 		 * as it differs for each connection.  There is no need to
