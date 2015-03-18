From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/6] net: introduce sk_ehashfn() helper
Date: Wed, 18 Mar 2015 14:05:34 -0700
Message-ID: <1426712738-23395-3-git-send-email-edumazet@google.com>
References: <1426712738-23395-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f201.google.com ([209.85.213.201]:34273 "EHLO
	mail-ig0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932889AbbCRVFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 17:05:51 -0400
Received: by igqa13 with SMTP id a13so3406967igq.1
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2015 14:05:50 -0700 (PDT)
In-Reply-To: <1426712738-23395-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Goal is to unify IPv4/IPv6 inet_hash handling, and use common helpers
for all kind of sockets (full sockets, timewait and request sockets)

inet_sk_ehashfn() becomes sk_ehashfn() but still only copes with IPv4

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_hashtables.h |  2 ++
 net/ipv4/inet_hashtables.c    | 17 ++++++-----------
 2 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index eb1963af0ebd..ef993ef571ea 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -383,6 +383,8 @@ static inline struct sock *__inet_lookup_skb(struct inet_hashinfo *hashinfo,
 				     iph->daddr, dport, inet_iif(skb));
 }
 
+u32 sk_ehashfn(const struct sock *sk);
+
 int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 			struct sock *sk, u32 port_offset,
 			int (*check_established)(struct inet_timewait_death_row *,
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 330a08bcd1c1..3a86dfd7ae33 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -37,16 +37,11 @@ static u32 inet_ehashfn(const struct net *net, const __be32 laddr,
 }
 
 
-static unsigned int inet_sk_ehashfn(const struct sock *sk)
+u32 sk_ehashfn(const struct sock *sk)
 {
-	const struct inet_sock *inet = inet_sk(sk);
-	const __be32 laddr = inet->inet_rcv_saddr;
-	const __u16 lport = inet->inet_num;
-	const __be32 faddr = inet->inet_daddr;
-	const __be16 fport = inet->inet_dport;
-	struct net *net = sock_net(sk);
-
-	return inet_ehashfn(net, laddr, lport, faddr, fport);
+	return inet_ehashfn(sock_net(sk),
+			    sk->sk_rcv_saddr, sk->sk_num,
+			    sk->sk_daddr, sk->sk_dport);
 }
 
 /*
@@ -407,13 +402,13 @@ int __inet_hash_nolisten(struct sock *sk, struct inet_timewait_sock *tw)
 {
 	struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo;
 	struct hlist_nulls_head *list;
-	spinlock_t *lock;
 	struct inet_ehash_bucket *head;
+	spinlock_t *lock;
 	int twrefcnt = 0;
 
 	WARN_ON(!sk_unhashed(sk));
 
-	sk->sk_hash = inet_sk_ehashfn(sk);
+	sk->sk_hash = sk_ehashfn(sk);
 	head = inet_ehash_bucket(hashinfo, sk->sk_hash);
 	list = &head->chain;
 	lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
-- 
2.2.0.rc0.207.ga3a616c
