From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/6] inet: add IPv6 support to sk_ehashfn()
Date: Wed, 18 Mar 2015 14:05:35 -0700
Message-ID: <1426712738-23395-4-git-send-email-edumazet@google.com>
References: <1426712738-23395-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f201.google.com ([209.85.160.201]:33950 "EHLO
	mail-yk0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933571AbbCRVF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 17:05:59 -0400
Received: by ykq142 with SMTP id 142so1928649ykq.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 14:05:58 -0700 (PDT)
In-Reply-To: <1426712738-23395-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Intent is to converge IPv4 & IPv6 inet_hash functions to
factorize code.

IPv4 sockets initialize sk_rcv_saddr and sk_v6_daddr
in this patch, thanks to new sk_daddr_set() and sk_rcv_saddr_set()
helpers.

__inet6_hash can now use sk_ehashfn() instead of a private
inet6_sk_ehashfn() and will simply use __inet_hash() in a
following patch.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_hashtables.h | 19 +++++++++++++++++++
 net/dccp/ipv4.c               |  9 ++++-----
 net/dccp/ipv6.c               | 10 ++--------
 net/ipv4/inet_hashtables.c    | 11 ++++++++++-
 net/ipv4/tcp_ipv4.c           |  8 ++++----
 net/ipv6/inet6_hashtables.c   | 22 ++++------------------
 net/ipv6/tcp_ipv6.c           | 11 ++---------
 7 files changed, 45 insertions(+), 45 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index ef993ef571ea..06ad42182ec2 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -384,6 +384,25 @@ static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 }
 
 u32 sk_ehashfn(const struct sock *sk);
+u32 inet6_ehashfn(const struct net *net,
+		  const struct in6_addr *laddr, const u16 lport,
+		  const struct in6_addr *faddr, const __be16 fport);
+
+static inline void sk_daddr_set(struct sock *sk, __be32 addr)
+{
+	sk->sk_daddr = addr; /* alias of inet_daddr */
+#if IS_ENABLED(CONFIG_IPV6)
+	ipv6_addr_set_v4mapped(addr, &sk->sk_v6_daddr);
+#endif
+}
+
+static inline void sk_rcv_saddr_set(struct sock *sk, __be32 addr)
+{
+	sk->sk_rcv_saddr = addr; /* alias of inet_rcv_saddr */
+#if IS_ENABLED(CONFIG_IPV6)
+	ipv6_addr_set_v4mapped(addr, &sk->sk_v6_rcv_saddr);
+#endif
+}
 
 int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			struct sock *sk, u32 port_offset,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index bf897829f4f0..f3f8906f482e 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -89,10 +89,9 @@ int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	if (inet->inet_saddr == 0)
 		inet->inet_saddr = fl4->saddr;
-	inet->inet_rcv_saddr = inet->inet_saddr;
-
+	sk_rcv_saddr_set(sk, inet->inet_saddr);
 	inet->inet_dport = usin->sin_port;
-	inet->inet_daddr = daddr;
+	sk_daddr_set(sk, daddr);
 
 	inet_csk(sk)->icsk_ext_hdr_len = 0;
 	if (inet_opt)
@@ -408,8 +407,8 @@ struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	newinet		   = inet_sk(newsk);
 	ireq		   = inet_rsk(req);
-	newinet->inet_daddr	= ireq->ir_rmt_addr;
-	newinet->inet_rcv_saddr = ireq->ir_loc_addr;
+	sk_daddr_set(newsk, ireq->ir_rmt_addr);
+	sk_rcv_saddr_set(newsk, ireq->ir_loc_addr);
 	newinet->inet_saddr	= ireq->ir_loc_addr;
 	newinet->inet_opt	= ireq->opt;
 	ireq->opt	   = NULL;
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index d7e7c7b0a3f1..9216d173dd5f 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -470,11 +470,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 
 		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newsk->sk_v6_daddr);
-
-		ipv6_addr_set_v4mapped(newinet->inet_saddr, &newnp->saddr);
-
-		newsk->sk_v6_rcv_saddr = newnp->saddr;
+		newnp->saddr = newsk->sk_v6_rcv_saddr;
 
 		inet_csk(newsk)->icsk_af_ops = &dccp_ipv6_mapped;
 		newsk->sk_backlog_rcv = dccp_v4_do_rcv;
@@ -917,9 +913,7 @@ static int dccp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 			sk->sk_backlog_rcv = dccp_v6_do_rcv;
 			goto failure;
 		}
-		ipv6_addr_set_v4mapped(inet->inet_saddr, &np->saddr);
-		ipv6_addr_set_v4mapped(inet->inet_rcv_saddr, &sk->sk_v6_rcv_saddr);
-
+		np->saddr = sk->sk_v6_rcv_saddr;
 		return err;
 	}
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 3a86dfd7ae33..ab7f677a97db 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -36,9 +36,18 @@ static u32 inet_ehashfn(const struct net *net, const __be32 laddr,
 			      inet_ehash_secret + net_hash_mix(net));
 }
 
-
+/* This function handles inet_sock, but also timewait and request sockets
+ * for IPv4/IPv6.
+ */
 u32 sk_ehashfn(const struct sock *sk)
 {
+#if IS_ENABLED(CONFIG_IPV6)
+	if (sk->sk_family == AF_INET6 &&
+	    !ipv6_addr_v4mapped(&sk->sk_v6_daddr))
+		return inet6_ehashfn(sock_net(sk),
+				     &sk->sk_v6_rcv_saddr, sk->sk_num,
+				     &sk->sk_v6_daddr, sk->sk_dport);
+#endif
 	return inet_ehashfn(sock_net(sk),
 			    sk->sk_rcv_saddr, sk->sk_num,
 			    sk->sk_daddr, sk->sk_dport);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 80067d5858b4..ca207df4af1c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -189,7 +189,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 
 	if (!inet->inet_saddr)
 		inet->inet_saddr = fl4->saddr;
-	inet->inet_rcv_saddr = inet->inet_saddr;
+	sk_rcv_saddr_set(sk, inet->inet_saddr);
 
 	if (tp->rx_opt.ts_recent_stamp && inet->inet_daddr != daddr) {
 		/* Reset inherited state */
@@ -204,7 +204,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		tcp_fetch_timewait_stamp(sk, &rt->dst);
 
 	inet->inet_dport = usin->sin_port;
-	inet->inet_daddr = daddr;
+	sk_daddr_set(sk, daddr);
 
 	inet_csk(sk)->icsk_ext_hdr_len = 0;
 	if (inet_opt)
@@ -1319,8 +1319,8 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	newtp		      = tcp_sk(newsk);
 	newinet		      = inet_sk(newsk);
 	ireq		      = inet_rsk(req);
-	newinet->inet_daddr   = ireq->ir_rmt_addr;
-	newinet->inet_rcv_saddr = ireq->ir_loc_addr;
+	sk_daddr_set(newsk, ireq->ir_rmt_addr);
+	sk_rcv_saddr_set(newsk, ireq->ir_loc_addr);
 	newinet->inet_saddr	      = ireq->ir_loc_addr;
 	inet_opt	      = ireq->opt;
 	rcu_assign_pointer(newinet->inet_opt, inet_opt);
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index df7df99d1d7e..ed5787b20192 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -23,11 +23,9 @@
 #include <net/secure_seq.h>
 #include <net/ip.h>
 
-static u32 inet6_ehashfn(const struct net *net,
-			 const struct in6_addr *laddr,
-			 const u16 lport,
-			 const struct in6_addr *faddr,
-			 const __be16 fport)
+u32 inet6_ehashfn(const struct net *net,
+		  const struct in6_addr *laddr, const u16 lport,
+		  const struct in6_addr *faddr, const __be16 fport)
 {
 	static u32 inet6_ehash_secret __read_mostly;
 	static u32 ipv6_hash_secret __read_mostly;
@@ -44,18 +42,6 @@ static u32 inet6_ehashfn(const struct net *net,
 			       inet6_ehash_secret + net_hash_mix(net));
 }
 
-static int inet6_sk_ehashfn(const struct sock *sk)
-{
-	const struct inet_sock *inet = inet_sk(sk);
-	const struct in6_addr *laddr = &sk->sk_v6_rcv_saddr;
-	const struct in6_addr *faddr = &sk->sk_v6_daddr;
-	const __u16 lport = inet->inet_num;
-	const __be16 fport = inet->inet_dport;
-	struct net *net = sock_net(sk);
-
-	return inet6_ehashfn(net, laddr, lport, faddr, fport);
-}
-
 int __inet6_hash(struct sock *sk, struct inet_timewait_sock *tw)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
@@ -75,7 +61,7 @@ int __inet6_hash(struct sock *sk, struct inet_timewait_sock *tw)
 		struct hlist_nulls_head *list;
 		spinlock_t *lock;
 
-		sk->sk_hash = hash = inet6_sk_ehashfn(sk);
+		sk->sk_hash = hash = sk_ehashfn(sk);
 		list = &inet_ehash_bucket(hashinfo, hash)->chain;
 		lock = inet_ehash_lockp(hashinfo, hash);
 		spin_lock(lock);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e4761b22307b..5546df074583 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -233,11 +233,8 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
 			tp->af_specific = &tcp_sock_ipv6_specific;
 #endif
 			goto failure;
-		} else {
-			ipv6_addr_set_v4mapped(inet->inet_saddr, &np->saddr);
-			ipv6_addr_set_v4mapped(inet->inet_rcv_saddr,
-					       &sk->sk_v6_rcv_saddr);
 		}
+		np->saddr = sk->sk_v6_rcv_saddr;
 
 		return err;
 	}
@@ -1078,11 +1075,7 @@ static struct sock *tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
 
-		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newsk->sk_v6_daddr);
-
-		ipv6_addr_set_v4mapped(newinet->inet_saddr, &newnp->saddr);
-
-		newsk->sk_v6_rcv_saddr = newnp->saddr;
+		newnp->saddr = newsk->sk_v6_rcv_saddr;
 
 		inet_csk(newsk)->icsk_af_ops = &ipv6_mapped;
 		newsk->sk_backlog_rcv = tcp_v4_do_rcv;
-- 
2.2.0.rc0.207.ga3a616c
