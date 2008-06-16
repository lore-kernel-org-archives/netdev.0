From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 5/8] Inet: add struct net argument to inet_lhashfn
Date: Mon, 16 Jun 2008 13:44:55 +0400
Message-ID: <48563617.8050802@openvz.org>
References: <485633E4.10900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39350 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755456AbYFPJrS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 05:47:18 -0400
In-Reply-To: <485633E4.10900@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Listening-on-one-port sockets in many namespaces produce long 
chains in the listening_hash-es, so prepare the inet_lhashfn to 
take struct net into account.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/net/inet_hashtables.h |    4 ++--
 net/ipv4/inet_hashtables.c    |    2 +-
 net/ipv6/inet6_hashtables.c   |    3 ++-
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 61dd331..26336cd 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -211,14 +211,14 @@ extern void inet_bind_hash(struct sock *sk, struct inet_bind_bucket *tb,
 			   const unsigned short snum);
 
 /* These can have wildcards, don't try too hard. */
-static inline int inet_lhashfn(const unsigned short num)
+static inline int inet_lhashfn(struct net *net, const unsigned short num)
 {
 	return num & (INET_LHTABLE_SIZE - 1);
 }
 
 static inline int inet_sk_listen_hashfn(const struct sock *sk)
 {
-	return inet_lhashfn(inet_sk(sk)->num);
+	return inet_lhashfn(sock_net(sk), inet_sk(sk)->num);
 }
 
 /* Caller must disable local BH processing. */
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index dc1b78d..4f597b3 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -194,7 +194,7 @@ struct sock *__inet_lookup_listener(struct net *net,
 	const struct hlist_head *head;
 
 	read_lock(&hashinfo->lhash_lock);
-	head = &hashinfo->listening_hash[inet_lhashfn(hnum)];
+	head = &hashinfo->listening_hash[inet_lhashfn(net, hnum)];
 	if (!hlist_empty(head)) {
 		const struct inet_sock *inet = inet_sk((sk = __sk_head(head)));
 
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 580014a..b940156 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -104,7 +104,8 @@ struct sock *inet6_lookup_listener(struct net *net,
 	int score, hiscore = 0;
 
 	read_lock(&hashinfo->lhash_lock);
-	sk_for_each(sk, node, &hashinfo->listening_hash[inet_lhashfn(hnum)]) {
+	sk_for_each(sk, node,
+			&hashinfo->listening_hash[inet_lhashfn(net, hnum)]) {
 		if (net_eq(sock_net(sk), net) && inet_sk(sk)->num == hnum &&
 				sk->sk_family == PF_INET6) {
 			const struct ipv6_pinfo *np = inet6_sk(sk);
-- 
1.5.3.4

