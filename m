From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] ipv6: kill sk_dst_lock
Date: Wed, 02 Dec 2015 21:53:57 -0800
Message-ID: <1449122037.6379.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1448731434.24696.97.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448854142.24696.109.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1448901315.24696.127.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151202.234216.1113392733011218992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, vyasevich@gmail.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33232 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751089AbbLCFx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 00:53:58 -0500
Received: by pabfh17 with SMTP id fh17so63358118pab.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 21:53:58 -0800 (PST)
In-Reply-To: <20151202.234216.1113392733011218992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

While testing the np->opt RCU conversion, I found that UDP/IPv6 was
using a mixture of xchg() and sk_dst_lock to protect concurrent changes
to sk->sk_dst_cache, leading to possible corruptions and crashes.

ip6_sk_dst_lookup_flow() uses sk_dst_check() anyway, so the simplest
way to fix the mess is to remove sk_dst_lock completely, as we did for
IPv4.

__ip6_dst_store() and ip6_dst_store() share same implementation.

sk_setup_caps() being called with socket lock being held or not,
we have to use sk_dst_set() instead of __sk_dst_set()

Note that I had to move the "np->dst_cookie = rt6_get_cookie(rt);"
in ip6_dst_store() before the sk_setup_caps(sk, dst) call.

This is because ip6_dst_store() can be called from process context,
without any lock held.

As soon as the dst is installed in sk->sk_dst_cache, dst can be freed
from another cpu doing a concurrent ip6_dst_store()

Doing the dst dereference before doing the install is needed to make
sure no use after free would trigger.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
---
v2: added the explanation about rt6_get_cookie(rt) called
before sk_setup_caps()

 include/net/ip6_route.h          |   17 ++++-------------
 include/net/sock.h               |    3 +--
 net/core/sock.c                  |    4 +---
 net/dccp/ipv6.c                  |    4 ++--
 net/ipv6/af_inet6.c              |    2 +-
 net/ipv6/icmp.c                  |   14 --------------
 net/ipv6/inet6_connection_sock.c |   10 +---------
 net/ipv6/tcp_ipv6.c              |    4 ++--
 8 files changed, 12 insertions(+), 46 deletions(-)
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 2bfb2ad2fab1..877f682989b8 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -133,27 +133,18 @@ void rt6_clean_tohost(struct net *net, struct in6_addr *gateway);
 /*
  *	Store a destination cache entry in a socket
  */
-static inline void __ip6_dst_store(struct sock *sk, struct dst_entry *dst,
-				   const struct in6_addr *daddr,
-				   const struct in6_addr *saddr)
+static inline void ip6_dst_store(struct sock *sk, struct dst_entry *dst,
+				 const struct in6_addr *daddr,
+				 const struct in6_addr *saddr)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct rt6_info *rt = (struct rt6_info *) dst;
 
+	np->dst_cookie = rt6_get_cookie((struct rt6_info *)dst);
 	sk_setup_caps(sk, dst);
 	np->daddr_cache = daddr;
 #ifdef CONFIG_IPV6_SUBTREES
 	np->saddr_cache = saddr;
 #endif
-	np->dst_cookie = rt6_get_cookie(rt);
-}
-
-static inline void ip6_dst_store(struct sock *sk, struct dst_entry *dst,
-				 struct in6_addr *daddr, struct in6_addr *saddr)
-{
-	spin_lock(&sk->sk_dst_lock);
-	__ip6_dst_store(sk, dst, daddr, saddr);
-	spin_unlock(&sk->sk_dst_lock);
 }
 
 static inline bool ipv6_unicast_destination(const struct sk_buff *skb)
diff --git a/include/net/sock.h b/include/net/sock.h
index 7f89e4ba18d1..27f1d03e7a73 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -254,7 +254,6 @@ struct cg_proto;
   *	@sk_wq: sock wait queue and async head
   *	@sk_rx_dst: receive input route used by early demux
   *	@sk_dst_cache: destination cache
-  *	@sk_dst_lock: destination cache lock
   *	@sk_policy: flow policy
   *	@sk_receive_queue: incoming packets
   *	@sk_wmem_alloc: transmit queue bytes committed
@@ -391,7 +390,7 @@ struct sock {
 #endif
 	struct dst_entry	*sk_rx_dst;
 	struct dst_entry __rcu	*sk_dst_cache;
-	spinlock_t		sk_dst_lock;
+	/* Note: 32bit hole on 64bit arches */
 	atomic_t		sk_wmem_alloc;
 	atomic_t		sk_omem_alloc;
 	int			sk_sndbuf;
diff --git a/net/core/sock.c b/net/core/sock.c
index 1e4dd54bfb5a..81cdeacfc5ce 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1530,7 +1530,6 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 		skb_queue_head_init(&newsk->sk_receive_queue);
 		skb_queue_head_init(&newsk->sk_write_queue);
 
-		spin_lock_init(&newsk->sk_dst_lock);
 		rwlock_init(&newsk->sk_callback_lock);
 		lockdep_set_class_and_name(&newsk->sk_callback_lock,
 				af_callback_keys + newsk->sk_family,
@@ -1607,7 +1606,7 @@ void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 {
 	u32 max_segs = 1;
 
-	__sk_dst_set(sk, dst);
+	sk_dst_set(sk, dst);
 	sk->sk_route_caps = dst->dev->features;
 	if (sk->sk_route_caps & NETIF_F_GSO)
 		sk->sk_route_caps |= NETIF_F_GSO_SOFTWARE;
@@ -2388,7 +2387,6 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	} else
 		sk->sk_wq	=	NULL;
 
-	spin_lock_init(&sk->sk_dst_lock);
 	rwlock_init(&sk->sk_callback_lock);
 	lockdep_set_class_and_name(&sk->sk_callback_lock,
 			af_callback_keys + sk->sk_family,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index db5fc2440a23..9ba3b69afea2 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -453,7 +453,7 @@ static struct sock *dccp_v6_request_recv_sock(const struct sock *sk,
 	 * comment in that function for the gory details. -acme
 	 */
 
-	__ip6_dst_store(newsk, dst, NULL, NULL);
+	ip6_dst_store(newsk, dst, NULL, NULL);
 	newsk->sk_route_caps = dst->dev->features & ~(NETIF_F_IP_CSUM |
 						      NETIF_F_TSO);
 	newdp6 = (struct dccp6_sock *)newsk;
@@ -873,7 +873,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	np->saddr = *saddr;
 	inet->inet_rcv_saddr = LOOPBACK4_IPV6;
 
-	__ip6_dst_store(sk, dst, NULL, NULL);
+	ip6_dst_store(sk, dst, NULL, NULL);
 
 	icsk->icsk_ext_hdr_len = 0;
 	if (np->opt != NULL)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 44bb66bde0e2..b8cd97e09829 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -668,7 +668,7 @@ int inet6_sk_rebuild_header(struct sock *sk)
 			return PTR_ERR(dst);
 		}
 
-		__ip6_dst_store(sk, dst, NULL, NULL);
+		ip6_dst_store(sk, dst, NULL, NULL);
 	}
 
 	return 0;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 36c5a98b0472..0a37ddc7af51 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -834,11 +834,6 @@ void icmpv6_flow_init(struct sock *sk, struct flowi6 *fl6,
 	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
 }
 
-/*
- * Special lock-class for __icmpv6_sk:
- */
-static struct lock_class_key icmpv6_socket_sk_dst_lock_key;
-
 static int __net_init icmpv6_sk_init(struct net *net)
 {
 	struct sock *sk;
@@ -860,15 +855,6 @@ static int __net_init icmpv6_sk_init(struct net *net)
 
 		net->ipv6.icmp_sk[i] = sk;
 
-		/*
-		 * Split off their lock-class, because sk->sk_dst_lock
-		 * gets used from softirqs, which is safe for
-		 * __icmpv6_sk (because those never get directly used
-		 * via userspace syscalls), but unsafe for normal sockets.
-		 */
-		lockdep_set_class(&sk->sk_dst_lock,
-				  &icmpv6_socket_sk_dst_lock_key);
-
 		/* Enough space for 2 64K ICMP packets, including
 		 * sk_buff struct overhead.
 		 */
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 5d1c7cee2cb2..af0524c59269 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -109,14 +109,6 @@ void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr)
 EXPORT_SYMBOL_GPL(inet6_csk_addr2sockaddr);
 
 static inline
-void __inet6_csk_dst_store(struct sock *sk, struct dst_entry *dst,
-			   const struct in6_addr *daddr,
-			   const struct in6_addr *saddr)
-{
-	__ip6_dst_store(sk, dst, daddr, saddr);
-}
-
-static inline
 struct dst_entry *__inet6_csk_dst_check(struct sock *sk, u32 cookie)
 {
 	return __sk_dst_check(sk, cookie);
@@ -149,7 +141,7 @@ static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
 		dst = ip6_dst_lookup_flow(sk, fl6, final_p);
 
 		if (!IS_ERR(dst))
-			__inet6_csk_dst_store(sk, dst, NULL, NULL);
+			ip6_dst_store(sk, dst, NULL, NULL);
 	}
 	return dst;
 }
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c5429a636f1a..bb1f0cc36ffb 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -255,7 +255,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 	inet->inet_rcv_saddr = LOOPBACK4_IPV6;
 
 	sk->sk_gso_type = SKB_GSO_TCPV6;
-	__ip6_dst_store(sk, dst, NULL, NULL);
+	ip6_dst_store(sk, dst, NULL, NULL);
 
 	if (tcp_death_row.sysctl_tw_recycle &&
 	    !tp->rx_opt.ts_recent_stamp &&
@@ -1056,7 +1056,7 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 	 */
 
 	newsk->sk_gso_type = SKB_GSO_TCPV6;
-	__ip6_dst_store(newsk, dst, NULL, NULL);
+	ip6_dst_store(newsk, dst, NULL, NULL);
 	inet6_sk_rx_dst_set(newsk, skb);
 
 	newtcp6sk = (struct tcp6_sock *)newsk;
