From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 7/8] Inet6: add struct net argument to inet6_ehashfn
Date: Mon, 16 Jun 2008 13:48:11 +0400
Message-ID: <485636DB.3010900@openvz.org>
References: <485633E4.10900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47586 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757444AbYFPJuf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:50:35 -0400
In-Reply-To: <485633E4.10900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same as for inet_hashfn, prepare its ipv6 incarnation.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/inet6_hashtables.h |    7 +++++--
 net/ipv6/inet6_hashtables.c    |    6 +++---
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/include/net/inet6_hashtables.h b/include/net/inet6_hashtables.h
index 62a5b69..72f13a9 100644
--- a/include/net/inet6_hashtables.h
+++ b/include/net/inet6_hashtables.h
@@ -28,7 +28,8 @@
 struct inet_hashinfo;
 
 /* I have no idea if this is a good hash for v6 or not. -DaveM */
-static inline unsigned int inet6_ehashfn(const struct in6_addr *laddr, const u16 lport,
+static inline unsigned int inet6_ehashfn(struct net *net,
+				const struct in6_addr *laddr, const u16 lport,
 				const struct in6_addr *faddr, const __be16 fport)
 {
 	u32 ports = (lport ^ (__force u16)fport);
@@ -46,7 +47,9 @@ static inline int inet6_sk_ehashfn(const struct sock *sk)
 	const struct in6_addr *faddr = &np->daddr;
 	const __u16 lport = inet->num;
 	const __be16 fport = inet->dport;
-	return inet6_ehashfn(laddr, lport, faddr, fport);
+	struct net *net = sock_net(sk);
+
+	return inet6_ehashfn(net, laddr, lport, faddr, fport);
 }
 
 extern void __inet6_hash(struct sock *sk);
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index b940156..a9cc8ab 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -68,7 +68,7 @@ struct sock *__inet6_lookup_established(struct net *net,
 	/* Optimize here for direct hit, only listening connections can
 	 * have wildcards anyways.
 	 */
-	unsigned int hash = inet6_ehashfn(daddr, hnum, saddr, sport);
+	unsigned int hash = inet6_ehashfn(net, daddr, hnum, saddr, sport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hashinfo, hash);
 	rwlock_t *lock = inet_ehash_lockp(hashinfo, hash);
 
@@ -166,14 +166,14 @@ static int __inet6_check_established(struct inet_timewait_death_row *death_row,
 	const struct in6_addr *saddr = &np->daddr;
 	const int dif = sk->sk_bound_dev_if;
 	const __portpair ports = INET_COMBINED_PORTS(inet->dport, lport);
-	const unsigned int hash = inet6_ehashfn(daddr, lport, saddr,
+	struct net *net = sock_net(sk);
+	const unsigned int hash = inet6_ehashfn(net, daddr, lport, saddr,
 						inet->dport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hinfo, hash);
 	rwlock_t *lock = inet_ehash_lockp(hinfo, hash);
 	struct sock *sk2;
 	const struct hlist_node *node;
 	struct inet_timewait_sock *tw;
-	struct net *net = sock_net(sk);
 
 	prefetch(head->chain.first);
 	write_lock(lock);
-- 
1.5.3.4

