From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: ipv4: fix RCU races on dst refcounts
Date: Mon, 30 Jul 2012 11:20:37 +0200
Message-ID: <1343640037.21269.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45724 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297Ab2G3JUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 05:20:42 -0400
Received: by eaak13 with SMTP id k13so1031541eaa.19
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2012 02:20:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit c6cffba4ffa2 (ipv4: Fix input route performance regression.)
added various fatal races with dst refcounts.

crashes happen on tcp workloads if routes are added/deleted at the same
time.

The dst_free() calls from free_fib_info_rcu() are clearly racy.

We need instead regular dst refcounting (dst_release()) and make
sure dst_release() is aware of RCU grace periods :

Add DST_RCU_FREE flag so that dst_release() respects an RCU grace period
before dst destruction for cached dst

Introduce a new inet_sk_rx_dst_set() helper, using atomic_inc_not_zero()
to make sure we dont increase a zero refcount (On a dst currently
waiting an rcu grace period before destruction)

rt_cache_route() must take a reference on the new cached route, and
release it if was not able to install it.

With this patch, my machines survive various benchmarks.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/dst.h        |    7 +------
 include/net/inet_sock.h  |   13 +++++++++++++
 net/core/dst.c           |   26 +++++++++++++++++++++-----
 net/decnet/dn_route.c    |    6 ++++++
 net/ipv4/fib_semantics.c |    4 ++--
 net/ipv4/route.c         |   16 ++++------------
 net/ipv4/tcp_input.c     |    3 +--
 net/ipv4/tcp_ipv4.c      |   12 ++++++------
 net/ipv4/tcp_minisocks.c |    3 +--
 9 files changed, 55 insertions(+), 35 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index baf5978..31a9fd3 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -61,6 +61,7 @@ struct dst_entry {
 #define DST_NOPEER		0x0040
 #define DST_FAKE_RTABLE		0x0080
 #define DST_XFRM_TUNNEL		0x0100
+#define DST_RCU_FREE		0x0200
 
 	unsigned short		pending_confirm;
 
@@ -382,12 +383,6 @@ static inline void dst_free(struct dst_entry *dst)
 	__dst_free(dst);
 }
 
-static inline void dst_rcu_free(struct rcu_head *head)
-{
-	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
-	dst_free(dst);
-}
-
 static inline void dst_confirm(struct dst_entry *dst)
 {
 	dst->pending_confirm = 1;
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 613cfa4..e3fd34c 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -249,4 +249,17 @@ static inline __u8 inet_sk_flowi_flags(const struct sock *sk)
 	return flags;
 }
 
+static inline void inet_sk_rx_dst_set(struct sock *sk, const struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+
+	if (atomic_inc_not_zero(&dst->__refcnt)) {
+		if (!(dst->flags & DST_RCU_FREE))
+			dst->flags |= DST_RCU_FREE;
+
+		sk->sk_rx_dst = dst;
+		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+	}
+}
+
 #endif	/* _INET_SOCK_H */
diff --git a/net/core/dst.c b/net/core/dst.c
index 069d51d..d9e33eb 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -258,6 +258,15 @@ again:
 }
 EXPORT_SYMBOL(dst_destroy);
 
+static void dst_rcu_destroy(struct rcu_head *head)
+{
+	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
+
+	dst = dst_destroy(dst);
+	if (dst)
+		__dst_free(dst);
+}
+
 void dst_release(struct dst_entry *dst)
 {
 	if (dst) {
@@ -265,10 +274,14 @@ void dst_release(struct dst_entry *dst)
 
 		newrefcnt = atomic_dec_return(&dst->__refcnt);
 		WARN_ON(newrefcnt < 0);
-		if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt) {
-			dst = dst_destroy(dst);
-			if (dst)
-				__dst_free(dst);
+		if (unlikely(dst->flags & (DST_NOCACHE | DST_RCU_FREE)) && !newrefcnt) {
+			if (dst->flags & DST_RCU_FREE) {
+				call_rcu_bh(&dst->rcu_head, dst_rcu_destroy);
+			} else {
+				dst = dst_destroy(dst);
+				if (dst)
+					__dst_free(dst);
+			}
 		}
 	}
 }
@@ -320,11 +333,14 @@ EXPORT_SYMBOL(__dst_destroy_metrics_generic);
  */
 void skb_dst_set_noref(struct sk_buff *skb, struct dst_entry *dst)
 {
+	bool hold;
+
 	WARN_ON(!rcu_read_lock_held() && !rcu_read_lock_bh_held());
 	/* If dst not in cache, we must take a reference, because
 	 * dst_release() will destroy dst as soon as its refcount becomes zero
 	 */
-	if (unlikely(dst->flags & DST_NOCACHE)) {
+	hold = (dst->flags & (DST_NOCACHE | DST_RCU_FREE)) == DST_NOCACHE;
+	if (unlikely(hold)) {
 		dst_hold(dst);
 		skb_dst_set(skb, dst);
 	} else {
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 85a3604..2671977 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -184,6 +184,12 @@ static __inline__ unsigned int dn_hash(__le16 src, __le16 dst)
 	return dn_rt_hash_mask & (unsigned int)tmp;
 }
 
+static inline void dst_rcu_free(struct rcu_head *head)
+{
+	struct dst_entry *dst = container_of(head, struct dst_entry, rcu_head);
+	dst_free(dst);
+}
+
 static inline void dnrt_free(struct dn_route *rt)
 {
 	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index da0cc2e..e55171f 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -172,9 +172,9 @@ static void free_fib_info_rcu(struct rcu_head *head)
 		if (nexthop_nh->nh_exceptions)
 			free_nh_exceptions(nexthop_nh);
 		if (nexthop_nh->nh_rth_output)
-			dst_free(&nexthop_nh->nh_rth_output->dst);
+			dst_release(&nexthop_nh->nh_rth_output->dst);
 		if (nexthop_nh->nh_rth_input)
-			dst_free(&nexthop_nh->nh_rth_input->dst);
+			dst_release(&nexthop_nh->nh_rth_input->dst);
 	} endfor_nexthops(fi);
 
 	release_net(fi->fib_net);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index fc1a81c..d6eabcf 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1199,11 +1199,6 @@ restart:
 	fnhe->fnhe_stamp = jiffies;
 }
 
-static inline void rt_free(struct rtable *rt)
-{
-	call_rcu_bh(&rt->dst.rcu_head, dst_rcu_free);
-}
-
 static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 {
 	struct rtable *orig, *prev, **p = &nh->nh_rth_output;
@@ -1213,17 +1208,14 @@ static void rt_cache_route(struct fib_nh *nh, struct rtable *rt)
 
 	orig = *p;
 
+	rt->dst.flags |= DST_RCU_FREE;
+	dst_hold(&rt->dst);
 	prev = cmpxchg(p, orig, rt);
 	if (prev == orig) {
 		if (orig)
-			rt_free(orig);
+			dst_release(&orig->dst);
 	} else {
-		/* Routes we intend to cache in the FIB nexthop have
-		 * the DST_NOCACHE bit clear.  However, if we are
-		 * unsuccessful at storing this route into the cache
-		 * we really need to set it.
-		 */
-		rt->dst.flags |= DST_NOCACHE;
+		dst_release(&rt->dst);
 	}
 }
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a356e1f..9be30b0 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5604,8 +5604,7 @@ void tcp_finish_connect(struct sock *sk, struct sk_buff *skb)
 	tcp_set_state(sk, TCP_ESTABLISHED);
 
 	if (skb != NULL) {
-		sk->sk_rx_dst = dst_clone(skb_dst(skb));
-		inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
+		inet_sk_rx_dst_set(sk, skb);
 		security_inet_conn_established(sk, skb);
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2fbd992..7f91e5a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1617,19 +1617,19 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 #endif
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
+		struct dst_entry *dst = sk->sk_rx_dst;
+
 		sock_rps_save_rxhash(sk, skb);
-		if (sk->sk_rx_dst) {
-			struct dst_entry *dst = sk->sk_rx_dst;
+		if (dst) {
 			if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
 			    dst->ops->check(dst, 0) == NULL) {
 				dst_release(dst);
 				sk->sk_rx_dst = NULL;
 			}
 		}
-		if (unlikely(sk->sk_rx_dst == NULL)) {
-			sk->sk_rx_dst = dst_clone(skb_dst(skb));
-			inet_sk(sk)->rx_dst_ifindex = skb->skb_iif;
-		}
+		if (unlikely(sk->sk_rx_dst == NULL))
+			inet_sk_rx_dst_set(sk, skb);
+
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
 			rsk = sk;
 			goto reset;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 3f1cc20..232a90c 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -387,8 +387,7 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_sock *oldtp = tcp_sk(sk);
 		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
 
-		newsk->sk_rx_dst = dst_clone(skb_dst(skb));
-		inet_sk(newsk)->rx_dst_ifindex = skb->skb_iif;
+		inet_sk_rx_dst_set(newsk, skb);
 
 		/* TCP Cookie Transactions require space for the cookie pair,
 		 * as it differs for each connection.  There is no need to
