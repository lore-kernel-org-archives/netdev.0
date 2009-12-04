From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 1/2] tcp: Fix a connect() race with timewait sockets
Date: Fri, 04 Dec 2009 14:46:54 +0100
Message-ID: <4B1912CE.5040304@gmail.com>
References: <99d458640911301802i4bde20f4wa314668d543e3170@mail.gmail.com> <4B152F97.1090409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	Evgeniy Polyakov <zbr@ioremap.net>
To: kapil dakhane <kdakhane@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <4B152F97.1090409@gmail.com>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First patch changes __inet_hash_nolisten() and __inet6_hash()
to get a timewait parameter to be able to unhash it from ehash
at same time the new socket is inserted in hash.

This makes sure timewait socket wont be found by a concurrent
writer in __inet_check_established()

Reported-by: kapil dakhane <kdakhane@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inet6_hashtables.h |    2 +-
 include/net/inet_hashtables.h  |    8 +++++---
 net/dccp/ipv4.c                |    2 +-
 net/dccp/ipv6.c                |    4 ++--
 net/ipv4/inet_hashtables.c     |   22 ++++++++++++++++------
 net/ipv4/tcp_ipv4.c            |    2 +-
 net/ipv6/inet6_hashtables.c    |    8 +++++++-
 net/ipv6/tcp_ipv6.c            |    4 ++--
 8 files changed, 35 insertions(+), 17 deletions(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index 92838d3..e46674d 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -53,7 +53,7 @@ static inline int inet6_sk_ehashfn(const struct sock *sk)
 	return inet6_ehashfn(net, laddr, lport, faddr, fport);
 }
 
-extern void __inet6_hash(struct sock *sk);
+extern int __inet6_hash(struct sock *sk, struct inet_timewait_sock *twp);
 
 /*
  * Sockets in TCP_CLOSE state are _always_ taken out of the hash, so
diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 41cbddd..74358d1 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -251,7 +251,7 @@ extern void inet_put_port(struct sock *sk);
 
 void inet_hashinfo_init(struct inet_hashinfo *h);
 
-extern void __inet_hash_nolisten(struct sock *sk);
+extern int __inet_hash_nolisten(struct sock *sk, struct inet_timewait_sock *tw);
 extern void inet_hash(struct sock *sk);
 extern void inet_unhash(struct sock *sk);
 
@@ -391,10 +391,12 @@ static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 }
 
 extern int __inet_hash_connect(struct inet_timewait_death_row *death_row,
-		struct sock *sk, u32 port_offset,
+		struct sock *sk,
+		u32 port_offset,
 		int (*check_established)(struct inet_timewait_death_row *,
 			struct sock *, __u16, struct inet_timewait_sock **),
-			       void (*hash)(struct sock *sk));
+		int (*hash)(struct sock *sk, struct inet_timewait_sock *twp));
+
 extern int inet_hash_connect(struct inet_timewait_death_row *death_row,
 			     struct sock *sk);
 #endif /* _INET_HASHTABLES_H */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index efbcfdc..dad7bc4 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -408,7 +408,7 @@ struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
 
 	dccp_sync_mss(newsk, dst_mtu(dst));
 
-	__inet_hash_nolisten(newsk);
+	__inet_hash_nolisten(newsk, NULL);
 	__inet_inherit_port(sk, newsk);
 
 	return newsk;
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 6574215..baf05cf 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -46,7 +46,7 @@ static void dccp_v6_hash(struct sock *sk)
 			return;
 		}
 		local_bh_disable();
-		__inet6_hash(sk);
+		__inet6_hash(sk, NULL);
 		local_bh_enable();
 	}
 }
@@ -644,7 +644,7 @@ static struct sock *dccp_v6_request_recv_sock(struct sock *sk,
 	newinet->inet_daddr = newinet->inet_saddr = LOOPBACK4_IPV6;
 	newinet->inet_rcv_saddr = LOOPBACK4_IPV6;
 
-	__inet6_hash(newsk);
+	__inet6_hash(newsk, NULL);
 	__inet_inherit_port(sk, newsk);
 
 	return newsk;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 21e5e32..c4201b7 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -351,12 +351,13 @@ static inline u32 inet_sk_port_offset(const struct sock *sk)
 					  inet->inet_dport);
 }
 
-void __inet_hash_nolisten(struct sock *sk)
+int __inet_hash_nolisten(struct sock *sk, struct inet_timewait_sock *tw)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct hlist_nulls_head *list;
 	spinlock_t *lock;
 	struct inet_ehash_bucket *head;
+	int twrefcnt = 0;
 
 	WARN_ON(!sk_unhashed(sk));
 
@@ -367,8 +368,13 @@ void __inet_hash_nolisten(struct sock *sk)
 
 	spin_lock(lock);
 	__sk_nulls_add_node_rcu(sk, list);
+	if (tw) {
+		WARN_ON(sk->sk_hash != tw->tw_hash);
+		twrefcnt = inet_twsk_unhash(tw);
+	}
 	spin_unlock(lock);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	return twrefcnt;
 }
 EXPORT_SYMBOL_GPL(__inet_hash_nolisten);
 
@@ -378,7 +384,7 @@ static void __inet_hash(struct sock *sk)
 	struct inet_listen_hashbucket *ilb;
 
 	if (sk->sk_state != TCP_LISTEN) {
-		__inet_hash_nolisten(sk);
+		__inet_hash_nolisten(sk, NULL);
 		return;
 	}
 
@@ -427,7 +433,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 		struct sock *sk, u32 port_offset,
 		int (*check_established)(struct inet_timewait_death_row *,
 			struct sock *, __u16, struct inet_timewait_sock **),
-		void (*hash)(struct sock *sk))
+		int (*hash)(struct sock *sk, struct inet_timewait_sock *twp))
 {
 	struct inet_hashinfo *hinfo = death_row->hashinfo;
 	const unsigned short snum = inet_sk(sk)->inet_num;
@@ -435,6 +441,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 	struct inet_bind_bucket *tb;
 	int ret;
 	struct net *net = sock_net(sk);
+	int twrefcnt = 1;
 
 	if (!snum) {
 		int i, remaining, low, high, port;
@@ -493,13 +500,16 @@ ok:
 		inet_bind_hash(sk, tb, port);
 		if (sk_unhashed(sk)) {
 			inet_sk(sk)->inet_sport = htons(port);
-			hash(sk);
+			twrefcnt += hash(sk, tw);
 		}
 		spin_unlock(&head->lock);
 
 		if (tw) {
 			inet_twsk_deschedule(tw, death_row);
-			inet_twsk_put(tw);
+			while (twrefcnt) {
+				twrefcnt--;
+				inet_twsk_put(tw);
+			}
 		}
 
 		ret = 0;
@@ -510,7 +520,7 @@ ok:
 	tb  = inet_csk(sk)->icsk_bind_hash;
 	spin_lock_bh(&head->lock);
 	if (sk_head(&tb->owners) == sk && !sk->sk_bind_node.next) {
-		hash(sk);
+		hash(sk, NULL);
 		spin_unlock_bh(&head->lock);
 		return 0;
 	} else {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 29002ab..15e9603 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1464,7 +1464,7 @@ struct sock *tcp_v4_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	}
 #endif
 
-	__inet_hash_nolisten(newsk);
+	__inet_hash_nolisten(newsk, NULL);
 	__inet_inherit_port(sk, newsk);
 
 	return newsk;
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index c813e29..633a6c2 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -22,9 +22,10 @@
 #include <net/inet6_hashtables.h>
 #include <net/ip.h>
 
-void __inet6_hash(struct sock *sk)
+int __inet6_hash(struct sock *sk, struct inet_timewait_sock *tw)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
+	int twrefcnt = 0;
 
 	WARN_ON(!sk_unhashed(sk));
 
@@ -45,10 +46,15 @@ void __inet6_hash(struct sock *sk)
 		lock = inet_ehash_lockp(hashinfo, hash);
 		spin_lock(lock);
 		__sk_nulls_add_node_rcu(sk, list);
+		if (tw) {
+			WARN_ON(sk->sk_hash != tw->tw_hash);
+			twrefcnt = inet_twsk_unhash(tw);
+		}
 		spin_unlock(lock);
 	}
 
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	return twrefcnt;
 }
 EXPORT_SYMBOL(__inet6_hash);
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index aadd7ce..ee9cf62 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -96,7 +96,7 @@ static void tcp_v6_hash(struct sock *sk)
 			return;
 		}
 		local_bh_disable();
-		__inet6_hash(sk);
+		__inet6_hash(sk, NULL);
 		local_bh_enable();
 	}
 }
@@ -1496,7 +1496,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
 	}
 #endif
 
-	__inet6_hash(newsk);
+	__inet6_hash(newsk, NULL);
 	__inet_inherit_port(sk, newsk);
 
 	return newsk;

