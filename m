From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 6/8] Inet: add struct net argument to inet_ehashfn
Date: Mon, 16 Jun 2008 13:47:06 +0400
Message-ID: <4856369A.2090905@openvz.org>
References: <485633E4.10900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47575 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758657AbYFPJtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:49:31 -0400
In-Reply-To: <485633E4.10900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although this hash takes addresses into account, the ehash chains
can also be too long when, for instance, communications via lo occur.
So, prepare the inet_hashfn to take struct net into account.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/inet_sock.h    |    6 ++++--
 net/ipv4/inet_hashtables.c |    6 +++---
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index a42cd63..ab8e19d 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -171,7 +171,8 @@ extern int inet_sk_rebuild_header(struct sock *sk);
 extern u32 inet_ehash_secret;
 extern void build_ehash_secret(void);
 
-static inline unsigned int inet_ehashfn(const __be32 laddr, const __u16 lport,
+static inline unsigned int inet_ehashfn(struct net *net,
+					const __be32 laddr, const __u16 lport,
 					const __be32 faddr, const __be16 fport)
 {
 	return jhash_3words((__force __u32) laddr,
@@ -187,8 +188,9 @@ static inline int inet_sk_ehashfn(const struct sock *sk)
 	const __u16 lport = inet->num;
 	const __be32 faddr = inet->daddr;
 	const __be16 fport = inet->dport;
+	struct net *net = sock_net(sk);
 
-	return inet_ehashfn(laddr, lport, faddr, fport);
+	return inet_ehashfn(net, laddr, lport, faddr, fport);
 }
 
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 4f597b3..eca5899 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -227,7 +227,7 @@ struct sock * __inet_lookup_established(struct net *net,
 	/* Optimize here for direct hit, only listening connections can
 	 * have wildcards anyways.
 	 */
-	unsigned int hash = inet_ehashfn(daddr, hnum, saddr, sport);
+	unsigned int hash = inet_ehashfn(net, daddr, hnum, saddr, sport);
 	struct inet_ehash_bucket *head = inet_ehash_bucket(hashinfo, hash);
 	rwlock_t *lock = inet_ehash_lockp(hashinfo, hash);
 
@@ -267,13 +267,13 @@ static int __inet_check_established(struct inet_timewait_death_row *death_row,
 	int dif = sk->sk_bound_dev_if;
 	INET_ADDR_COOKIE(acookie, saddr, daddr)
 	const __portpair ports = INET_COMBINED_PORTS(inet->dport, lport);
-	unsigned int hash = inet_ehashfn(daddr, lport, saddr, inet->dport);
+	struct net *net = sock_net(sk);
+	unsigned int hash = inet_ehashfn(net, daddr, lport, saddr, inet->dport);
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

