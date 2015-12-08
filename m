From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 2/2] xfrm: add rcu protection to sk->sk_policy[]
Date: Tue,  8 Dec 2015 07:22:02 -0800
Message-ID: <1449588122-13941-2-git-send-email-edumazet@google.com>
References: <1449588122-13941-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35015 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756838AbbLHPWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 10:22:11 -0500
Received: by pacej9 with SMTP id ej9so13539301pac.2
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 07:22:10 -0800 (PST)
In-Reply-To: <1449588122-13941-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

XFRM can deal with SYNACK messages, sent while listener socket
is not locked. We add proper rcu protection to __xfrm_sk_clone_policy()
and xfrm_sk_policy_lookup()

This might serve as the first step to remove xfrm.xfrm_policy_lock
use in fast path.

Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener timer")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h     |  2 +-
 include/net/xfrm.h     | 24 +++++++++++++++---------
 net/core/sock.c        |  2 +-
 net/xfrm/xfrm_policy.c | 37 +++++++++++++++++++++++++------------
 4 files changed, 42 insertions(+), 23 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index b1d475b5db68..eaef41433d7a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -388,7 +388,7 @@ struct sock {
 		struct socket_wq	*sk_wq_raw;
 	};
 #ifdef CONFIG_XFRM
-	struct xfrm_policy	*sk_policy[2];
+	struct xfrm_policy __rcu *sk_policy[2];
 #endif
 	struct dst_entry	*sk_rx_dst;
 	struct dst_entry __rcu	*sk_dst_cache;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 8bae1ef647cd..d6f6e5006ee9 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1142,12 +1142,14 @@ static inline int xfrm6_route_forward(struct sk_buff *skb)
 	return xfrm_route_forward(skb, AF_INET6);
 }
 
-int __xfrm_sk_clone_policy(struct sock *sk);
+int __xfrm_sk_clone_policy(struct sock *sk, const struct sock *osk);
 
-static inline int xfrm_sk_clone_policy(struct sock *sk)
+static inline int xfrm_sk_clone_policy(struct sock *sk, const struct sock *osk)
 {
-	if (unlikely(sk->sk_policy[0] || sk->sk_policy[1]))
-		return __xfrm_sk_clone_policy(sk);
+	sk->sk_policy[0] = NULL;
+	sk->sk_policy[1] = NULL;
+	if (unlikely(osk->sk_policy[0] || osk->sk_policy[1]))
+		return __xfrm_sk_clone_policy(sk, osk);
 	return 0;
 }
 
@@ -1155,12 +1157,16 @@ int xfrm_policy_delete(struct xfrm_policy *pol, int dir);
 
 static inline void xfrm_sk_free_policy(struct sock *sk)
 {
-	if (unlikely(sk->sk_policy[0] != NULL)) {
-		xfrm_policy_delete(sk->sk_policy[0], XFRM_POLICY_MAX);
+	struct xfrm_policy *pol;
+
+	pol = rcu_dereference_protected(sk->sk_policy[0], 1);
+	if (unlikely(pol != NULL)) {
+		xfrm_policy_delete(pol, XFRM_POLICY_MAX);
 		sk->sk_policy[0] = NULL;
 	}
-	if (unlikely(sk->sk_policy[1] != NULL)) {
-		xfrm_policy_delete(sk->sk_policy[1], XFRM_POLICY_MAX+1);
+	pol = rcu_dereference_protected(sk->sk_policy[1], 1);
+	if (unlikely(pol != NULL)) {
+		xfrm_policy_delete(pol, XFRM_POLICY_MAX+1);
 		sk->sk_policy[1] = NULL;
 	}
 }
@@ -1170,7 +1176,7 @@ void xfrm_garbage_collect(struct net *net);
 #else
 
 static inline void xfrm_sk_free_policy(struct sock *sk) {}
-static inline int xfrm_sk_clone_policy(struct sock *sk) { return 0; }
+static inline int xfrm_sk_clone_policy(struct sock *sk, const struct sock *osk) { return 0; }
 static inline int xfrm6_route_forward(struct sk_buff *skb) { return 1; }  
 static inline int xfrm4_route_forward(struct sk_buff *skb) { return 1; } 
 static inline int xfrm6_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
diff --git a/net/core/sock.c b/net/core/sock.c
index d01c8f42dbb2..765be835b06c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1550,7 +1550,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 			 */
 			is_charged = sk_filter_charge(newsk, filter);
 
-		if (unlikely(!is_charged || xfrm_sk_clone_policy(newsk))) {
+		if (unlikely(!is_charged || xfrm_sk_clone_policy(newsk, sk))) {
 			/* It is still raw copy of parent, so invalidate
 			 * destructor and make plain sk_free() */
 			newsk->sk_destruct = NULL;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index f57a5712cedd..948fa5560de5 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1221,8 +1221,10 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
 	struct xfrm_policy *pol;
 	struct net *net = sock_net(sk);
 
+	rcu_read_lock();
 	read_lock_bh(&net->xfrm.xfrm_policy_lock);
-	if ((pol = sk->sk_policy[dir]) != NULL) {
+	pol = rcu_dereference(sk->sk_policy[dir]);
+	if (pol != NULL) {
 		bool match = xfrm_selector_match(&pol->selector, fl,
 						 sk->sk_family);
 		int err = 0;
@@ -1246,6 +1248,7 @@ static struct xfrm_policy *xfrm_sk_policy_lookup(const struct sock *sk, int dir,
 	}
 out:
 	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	rcu_read_unlock();
 	return pol;
 }
 
@@ -1314,13 +1317,14 @@ int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 #endif
 
 	write_lock_bh(&net->xfrm.xfrm_policy_lock);
-	old_pol = sk->sk_policy[dir];
-	sk->sk_policy[dir] = pol;
+	old_pol = rcu_dereference_protected(sk->sk_policy[dir],
+				lockdep_is_held(&net->xfrm.xfrm_policy_lock));
 	if (pol) {
 		pol->curlft.add_time = get_seconds();
 		pol->index = xfrm_gen_index(net, XFRM_POLICY_MAX+dir, 0);
 		xfrm_sk_policy_link(pol, dir);
 	}
+	rcu_assign_pointer(sk->sk_policy[dir], pol);
 	if (old_pol) {
 		if (pol)
 			xfrm_policy_requeue(old_pol, pol);
@@ -1368,17 +1372,26 @@ static struct xfrm_policy *clone_policy(const struct xfrm_policy *old, int dir)
 	return newp;
 }
 
-int __xfrm_sk_clone_policy(struct sock *sk)
+int __xfrm_sk_clone_policy(struct sock *sk, const struct sock *osk)
 {
-	struct xfrm_policy *p0 = sk->sk_policy[0],
-			   *p1 = sk->sk_policy[1];
+	const struct xfrm_policy *p;
+	struct xfrm_policy *np;
+	int i, ret = 0;
 
-	sk->sk_policy[0] = sk->sk_policy[1] = NULL;
-	if (p0 && (sk->sk_policy[0] = clone_policy(p0, 0)) == NULL)
-		return -ENOMEM;
-	if (p1 && (sk->sk_policy[1] = clone_policy(p1, 1)) == NULL)
-		return -ENOMEM;
-	return 0;
+	rcu_read_lock();
+	for (i = 0; i < 2; i++) {
+		p = rcu_dereference(osk->sk_policy[i]);
+		if (p) {
+			np = clone_policy(p, i);
+			if (unlikely(!np)) {
+				ret = -ENOMEM;
+				break;
+			}
+			rcu_assign_pointer(sk->sk_policy[i], np);
+		}
+	}
+	rcu_read_unlock();
+	return ret;
 }
 
 static int
-- 
2.6.0.rc2.230.g3dd15c0
