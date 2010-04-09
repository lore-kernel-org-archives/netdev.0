From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: sk_dst_cache RCUification
Date: Fri, 09 Apr 2010 11:03:29 +0200
Message-ID: <1270803809.2623.69.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:41375 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751062Ab0DIJDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 05:03:34 -0400
Received: by bwz1 with SMTP id 1so2370348bwz.21
        for <netdev@vger.kernel.org>; Fri, 09 Apr 2010 02:03:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With latest CONFIG_PROVE_RCU stuff, I felt more comfortable to make this
work.

sk->sk_dst_cache is currently protected by a rwlock (sk_dst_lock)

This rwlock is readlocked for a very small amount of time, and dst
entries are already freed after RCU grace period. This calls for RCU
again :)

This patch converts sk_dst_lock to a spinlock, and use RCU for readers.

__sk_dst_get() is supposed to be called with rcu_read_lock() or if
socket locked by user, so use appropriate rcu_dereference_check()
condition (rcu_read_lock_held() || sock_owned_by_user(sk))

This patch avoids two atomic ops per tx packet on UDP connected sockets,
for example, and permits sk_dst_lock to be much less dirtied.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/dst.h        |   15 -----------
 include/net/ip6_route.h  |    4 +--
 include/net/sock.h       |   47 +++++++++++++++++++++++--------------
 net/core/dev.c           |    2 -
 net/core/sock.c          |    8 +++---
 net/dccp/timer.c         |    4 +--
 net/decnet/af_decnet.c   |    6 ++--
 net/ipv4/af_inet.c       |    2 -
 net/ipv4/tcp_input.c     |    4 +--
 net/ipv4/tcp_timer.c     |    4 +--
 net/ipv6/ipv6_sockglue.c |   25 ++++++++++---------
 11 files changed, 60 insertions(+), 61 deletions(-)
diff --git a/include/net/dst.h b/include/net/dst.h
index ce078cd..aac5a5f 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -225,21 +225,6 @@ static inline void dst_confirm(struct dst_entry *dst)
 		neigh_confirm(dst->neighbour);
 }
 
-static inline void dst_negative_advice(struct dst_entry **dst_p,
-				       struct sock *sk)
-{
-	struct dst_entry * dst = *dst_p;
-	if (dst && dst->ops->negative_advice) {
-		*dst_p = dst->ops->negative_advice(dst);
-
-		if (dst != *dst_p) {
-			extern void sk_reset_txq(struct sock *sk);
-
-			sk_reset_txq(sk);
-		}
-	}
-}
-
 static inline void dst_link_failure(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 68f6783..278312c 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -152,9 +152,9 @@ static inline void __ip6_dst_store(struct sock *sk, struct dst_entry *dst,
 static inline void ip6_dst_store(struct sock *sk, struct dst_entry *dst,
 				 struct in6_addr *daddr, struct in6_addr *saddr)
 {
-	write_lock(&sk->sk_dst_lock);
+	spin_lock(&sk->sk_dst_lock);
 	__ip6_dst_store(sk, dst, daddr, saddr);
-	write_unlock(&sk->sk_dst_lock);
+	spin_unlock(&sk->sk_dst_lock);
 }
 
 static inline int ipv6_unicast_destination(struct sk_buff *skb)
diff --git a/include/net/sock.h b/include/net/sock.h
index 092b055..6d298be 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -261,7 +261,7 @@ struct sock {
 #ifdef CONFIG_XFRM
 	struct xfrm_policy	*sk_policy[2];
 #endif
-	rwlock_t		sk_dst_lock;
+	spinlock_t		sk_dst_lock;
 	atomic_t		sk_rmem_alloc;
 	atomic_t		sk_wmem_alloc;
 	atomic_t		sk_omem_alloc;
@@ -1191,7 +1191,8 @@ extern unsigned long sock_i_ino(struct sock *sk);
 static inline struct dst_entry *
 __sk_dst_get(struct sock *sk)
 {
-	return sk->sk_dst_cache;
+	return rcu_dereference_check(sk->sk_dst_cache, rcu_read_lock_held() ||
+						       sock_owned_by_user(sk));
 }
 
 static inline struct dst_entry *
@@ -1199,50 +1200,62 @@ sk_dst_get(struct sock *sk)
 {
 	struct dst_entry *dst;
 
-	read_lock(&sk->sk_dst_lock);
-	dst = sk->sk_dst_cache;
+	rcu_read_lock();
+	dst = rcu_dereference(sk->sk_dst_cache);
 	if (dst)
 		dst_hold(dst);
-	read_unlock(&sk->sk_dst_lock);
+	rcu_read_unlock();
 	return dst;
 }
 
+extern void sk_reset_txq(struct sock *sk);
+
+static inline void dst_negative_advice(struct sock *sk)
+{
+	struct dst_entry *ndst, *dst = __sk_dst_get(sk);
+
+	if (dst && dst->ops->negative_advice) {
+		ndst = dst->ops->negative_advice(dst);
+
+		if (ndst != dst) {
+			rcu_assign_pointer(sk->sk_dst_cache, ndst);
+			sk_reset_txq(sk);
+		}
+	}
+}
+
 static inline void
 __sk_dst_set(struct sock *sk, struct dst_entry *dst)
 {
 	struct dst_entry *old_dst;
 
 	sk_tx_queue_clear(sk);
-	old_dst = sk->sk_dst_cache;
-	sk->sk_dst_cache = dst;
+	old_dst = rcu_dereference_check(sk->sk_dst_cache,
+					lockdep_is_held(&sk->sk_dst_lock));
+	rcu_assign_pointer(sk->sk_dst_cache, dst);
 	dst_release(old_dst);
 }
 
 static inline void
 sk_dst_set(struct sock *sk, struct dst_entry *dst)
 {
-	write_lock(&sk->sk_dst_lock);
+	spin_lock(&sk->sk_dst_lock);
 	__sk_dst_set(sk, dst);
-	write_unlock(&sk->sk_dst_lock);
+	spin_unlock(&sk->sk_dst_lock);
 }
 
 static inline void
 __sk_dst_reset(struct sock *sk)
 {
-	struct dst_entry *old_dst;
-
-	sk_tx_queue_clear(sk);
-	old_dst = sk->sk_dst_cache;
-	sk->sk_dst_cache = NULL;
-	dst_release(old_dst);
+	__sk_dst_set(sk, NULL);
 }
 
 static inline void
 sk_dst_reset(struct sock *sk)
 {
-	write_lock(&sk->sk_dst_lock);
+	spin_lock(&sk->sk_dst_lock);
 	__sk_dst_reset(sk);
-	write_unlock(&sk->sk_dst_lock);
+	spin_unlock(&sk->sk_dst_lock);
 }
 
 extern struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie);
diff --git a/net/core/dev.c b/net/core/dev.c
index b98ddc6..e5dcb85 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2014,7 +2014,7 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 			if (dev->real_num_tx_queues > 1)
 				queue_index = skb_tx_hash(dev, skb);
 
-			if (sk && sk->sk_dst_cache)
+			if (sk && rcu_dereference_check(sk->sk_dst_cache, 1))
 				sk_tx_queue_set(sk, queue_index);
 		}
 	}
diff --git a/net/core/sock.c b/net/core/sock.c
index c5812bb..7effa1e 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -364,11 +364,11 @@ EXPORT_SYMBOL(sk_reset_txq);
 
 struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
 {
-	struct dst_entry *dst = sk->sk_dst_cache;
+	struct dst_entry *dst = __sk_dst_get(sk);
 
 	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
 		sk_tx_queue_clear(sk);
-		sk->sk_dst_cache = NULL;
+		rcu_assign_pointer(sk->sk_dst_cache, NULL);
 		dst_release(dst);
 		return NULL;
 	}
@@ -1157,7 +1157,7 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 		skb_queue_head_init(&newsk->sk_async_wait_queue);
 #endif
 
-		rwlock_init(&newsk->sk_dst_lock);
+		spin_lock_init(&newsk->sk_dst_lock);
 		rwlock_init(&newsk->sk_callback_lock);
 		lockdep_set_class_and_name(&newsk->sk_callback_lock,
 				af_callback_keys + newsk->sk_family,
@@ -1898,7 +1898,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	} else
 		sk->sk_sleep	=	NULL;
 
-	rwlock_init(&sk->sk_dst_lock);
+	spin_lock_init(&sk->sk_dst_lock);
 	rwlock_init(&sk->sk_callback_lock);
 	lockdep_set_class_and_name(&sk->sk_callback_lock,
 			af_callback_keys + sk->sk_family,
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index bbfeb5e..1a9aa05 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -38,7 +38,7 @@ static int dccp_write_timeout(struct sock *sk)
 
 	if (sk->sk_state == DCCP_REQUESTING || sk->sk_state == DCCP_PARTOPEN) {
 		if (icsk->icsk_retransmits != 0)
-			dst_negative_advice(&sk->sk_dst_cache, sk);
+			dst_negative_advice(sk);
 		retry_until = icsk->icsk_syn_retries ?
 			    : sysctl_dccp_request_retries;
 	} else {
@@ -63,7 +63,7 @@ static int dccp_write_timeout(struct sock *sk)
 			   Golden words :-).
 		   */
 
-			dst_negative_advice(&sk->sk_dst_cache, sk);
+			dst_negative_advice(sk);
 		}
 
 		retry_until = sysctl_dccp_retries2;
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 2b494fa..55e3b6b 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -446,7 +446,7 @@ static void dn_destruct(struct sock *sk)
 	skb_queue_purge(&scp->other_xmit_queue);
 	skb_queue_purge(&scp->other_receive_queue);
 
-	dst_release(xchg(&sk->sk_dst_cache, NULL));
+	dst_release(rcu_dereference_check(sk->sk_dst_cache, 1));
 }
 
 static int dn_memory_pressure;
@@ -1105,7 +1105,7 @@ static int dn_accept(struct socket *sock, struct socket *newsock, int flags)
 	release_sock(sk);
 
 	dst = skb_dst(skb);
-	dst_release(xchg(&newsk->sk_dst_cache, dst));
+	sk_dst_set(newsk, dst);
 	skb_dst_set(skb, NULL);
 
 	DN_SK(newsk)->state        = DN_CR;
@@ -1956,7 +1956,7 @@ static int dn_sendmsg(struct kiocb *iocb, struct socket *sock,
 	}
 
 	if ((flags & MSG_TRYHARD) && sk->sk_dst_cache)
-		dst_negative_advice(&sk->sk_dst_cache, sk);
+		dst_negative_advice(sk);
 
 	mss = scp->segsize_rem;
 	fctype = scp->services_rem & NSP_FC_MASK;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index b5924f1..b39600f 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -153,7 +153,7 @@ void inet_sock_destruct(struct sock *sk)
 	WARN_ON(sk->sk_forward_alloc);
 
 	kfree(inet->opt);
-	dst_release(sk->sk_dst_cache);
+	dst_release(rcu_dereference_check(sk->sk_dst_cache, 1));
 	sk_refcnt_debug_dec(sk);
 }
 EXPORT_SYMBOL(inet_sock_destruct);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7b31476..b4bca29 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3709,7 +3709,7 @@ static int tcp_ack(struct sock *sk, struct sk_buff *skb, int flag)
 	}
 
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP))
-		dst_confirm(sk->sk_dst_cache);
+		dst_confirm(__sk_dst_get(sk));
 
 	return 1;
 
@@ -5832,7 +5832,7 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			if (tp->snd_una == tp->write_seq) {
 				tcp_set_state(sk, TCP_FIN_WAIT2);
 				sk->sk_shutdown |= SEND_SHUTDOWN;
-				dst_confirm(sk->sk_dst_cache);
+				dst_confirm(__sk_dst_get(sk));
 
 				if (!sock_flag(sk, SOCK_DEAD))
 					/* Wake up lingering close() */
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index b2e6bbc..7b3741b 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -171,14 +171,14 @@ static int tcp_write_timeout(struct sock *sk)
 
 	if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
 		if (icsk->icsk_retransmits)
-			dst_negative_advice(&sk->sk_dst_cache, sk);
+			dst_negative_advice(sk);
 		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 	} else {
 		if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
 			/* Black hole detection */
 			tcp_mtu_probing(icsk, sk);
 
-			dst_negative_advice(&sk->sk_dst_cache, sk);
+			dst_negative_advice(sk);
 		}
 
 		retry_until = sysctl_tcp_retries2;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 430454e..089c983 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -113,9 +113,9 @@ struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
 		}
 		opt = xchg(&inet6_sk(sk)->opt, opt);
 	} else {
-		write_lock(&sk->sk_dst_lock);
+		spin_lock(&sk->sk_dst_lock);
 		opt = xchg(&inet6_sk(sk)->opt, opt);
-		write_unlock(&sk->sk_dst_lock);
+		spin_unlock(&sk->sk_dst_lock);
 	}
 	sk_dst_reset(sk);
 
@@ -970,14 +970,13 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 	case IPV6_MTU:
 	{
 		struct dst_entry *dst;
+
 		val = 0;
-		lock_sock(sk);
-		dst = sk_dst_get(sk);
-		if (dst) {
+		rcu_read_lock();
+		dst = __sk_dst_get(sk);
+		if (dst)
 			val = dst_mtu(dst);
-			dst_release(dst);
-		}
-		release_sock(sk);
+		rcu_read_unlock();
 		if (!val)
 			return -ENOTCONN;
 		break;
@@ -1065,12 +1064,14 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		else
 			val = np->mcast_hops;
 
-		dst = sk_dst_get(sk);
-		if (dst) {
-			if (val < 0)
+		if (val < 0) {
+			rcu_read_lock();
+			dst = __sk_dst_get(sk);
+			if (dst)
 				val = ip6_dst_hoplimit(dst);
-			dst_release(dst);
+			rcu_read_unlock();
 		}
+
 		if (val < 0)
 			val = sock_net(sk)->ipv6.devconf_all->hop_limit;
 		break;


