From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 2/2] l2tp: take remote address into account in l2tp_ip
 and l2tp_ip6 socket lookups
Date: Fri, 30 Dec 2016 19:48:20 +0100
Message-ID: <ac4ccb1fd9ffb39d6248da1f3b1903f020b957a4.1483123297.git.g.nault@alphalink.fr>
References: <cover.1483123297.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:49288 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753932AbcL3SsY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 13:48:24 -0500
Content-Disposition: inline
In-Reply-To: <cover.1483123297.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For connected sockets, __l2tp_ip{,6}_bind_lookup() needs to check the
remote IP when looking for a matching socket. Otherwise a connected
socket can receive traffic not originating from its peer.

Drop l2tp_ip_bind_lookup() and l2tp_ip6_bind_lookup() instead of
updating their prototype, as these functions aren't used.

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_ip.c  | 19 ++++++-------------
 net/l2tp/l2tp_ip6.c | 20 ++++++--------------
 2 files changed, 12 insertions(+), 27 deletions(-)

diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 8938b6ba57a0..3d73278b86ca 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -47,7 +47,8 @@ static inline struct l2tp_ip_sock *l2tp_ip_sk(const struct sock *sk)
 	return (struct l2tp_ip_sock *)sk;
 }
 
-static struct sock *__l2tp_ip_bind_lookup(struct net *net, __be32 laddr, int dif, u32 tunnel_id)
+static struct sock *__l2tp_ip_bind_lookup(const struct net *net, __be32 laddr,
+					  __be32 raddr, int dif, u32 tunnel_id)
 {
 	struct sock *sk;
 
@@ -61,6 +62,7 @@ static struct sock *__l2tp_ip_bind_lookup(struct net *net, __be32 laddr, int dif
 		if ((l2tp->conn_id == tunnel_id) &&
 		    net_eq(sock_net(sk), net) &&
 		    !(inet->inet_rcv_saddr && inet->inet_rcv_saddr != laddr) &&
+		    (!inet->inet_daddr || !raddr || inet->inet_daddr == raddr) &&
 		    (!sk->sk_bound_dev_if || !dif ||
 		     sk->sk_bound_dev_if == dif))
 			goto found;
@@ -71,15 +73,6 @@ static struct sock *__l2tp_ip_bind_lookup(struct net *net, __be32 laddr, int dif
 	return sk;
 }
 
-static inline struct sock *l2tp_ip_bind_lookup(struct net *net, __be32 laddr, int dif, u32 tunnel_id)
-{
-	struct sock *sk = __l2tp_ip_bind_lookup(net, laddr, dif, tunnel_id);
-	if (sk)
-		sock_hold(sk);
-
-	return sk;
-}
-
 /* When processing receive frames, there are two cases to
  * consider. Data frames consist of a non-zero session-id and an
  * optional cookie. Control frames consist of a regular L2TP header
@@ -183,8 +176,8 @@ static int l2tp_ip_recv(struct sk_buff *skb)
 		struct iphdr *iph = (struct iphdr *) skb_network_header(skb);
 
 		read_lock_bh(&l2tp_ip_lock);
-		sk = __l2tp_ip_bind_lookup(net, iph->daddr, inet_iif(skb),
-					   tunnel_id);
+		sk = __l2tp_ip_bind_lookup(net, iph->daddr, iph->saddr,
+					   inet_iif(skb), tunnel_id);
 		if (!sk) {
 			read_unlock_bh(&l2tp_ip_lock);
 			goto discard;
@@ -280,7 +273,7 @@ static int l2tp_ip_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 		inet->inet_saddr = 0;  /* Use device */
 
 	write_lock_bh(&l2tp_ip_lock);
-	if (__l2tp_ip_bind_lookup(net, addr->l2tp_addr.s_addr,
+	if (__l2tp_ip_bind_lookup(net, addr->l2tp_addr.s_addr, 0,
 				  sk->sk_bound_dev_if, addr->l2tp_conn_id)) {
 		write_unlock_bh(&l2tp_ip_lock);
 		ret = -EADDRINUSE;
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 3135b9d55df5..331ccf5a7bad 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -59,12 +59,14 @@ static inline struct l2tp_ip6_sock *l2tp_ip6_sk(const struct sock *sk)
 
 static struct sock *__l2tp_ip6_bind_lookup(struct net *net,
 					   struct in6_addr *laddr,
+					   const struct in6_addr *raddr,
 					   int dif, u32 tunnel_id)
 {
 	struct sock *sk;
 
 	sk_for_each_bound(sk, &l2tp_ip6_bind_table) {
 		const struct in6_addr *sk_laddr = inet6_rcv_saddr(sk);
+		const struct in6_addr *sk_raddr = &sk->sk_v6_daddr;
 		struct l2tp_ip6_sock *l2tp = l2tp_ip6_sk(sk);
 
 		if (l2tp == NULL)
@@ -73,6 +75,7 @@ static struct sock *__l2tp_ip6_bind_lookup(struct net *net,
 		if ((l2tp->conn_id == tunnel_id) &&
 		    net_eq(sock_net(sk), net) &&
 		    (!sk_laddr || ipv6_addr_any(sk_laddr) || ipv6_addr_equal(sk_laddr, laddr)) &&
+		    (!raddr || ipv6_addr_any(sk_raddr) || ipv6_addr_equal(sk_raddr, raddr)) &&
 		    (!sk->sk_bound_dev_if || !dif ||
 		     sk->sk_bound_dev_if == dif))
 			goto found;
@@ -83,17 +86,6 @@ static struct sock *__l2tp_ip6_bind_lookup(struct net *net,
 	return sk;
 }
 
-static inline struct sock *l2tp_ip6_bind_lookup(struct net *net,
-						struct in6_addr *laddr,
-						int dif, u32 tunnel_id)
-{
-	struct sock *sk = __l2tp_ip6_bind_lookup(net, laddr, dif, tunnel_id);
-	if (sk)
-		sock_hold(sk);
-
-	return sk;
-}
-
 /* When processing receive frames, there are two cases to
  * consider. Data frames consist of a non-zero session-id and an
  * optional cookie. Control frames consist of a regular L2TP header
@@ -197,8 +189,8 @@ static int l2tp_ip6_recv(struct sk_buff *skb)
 		struct ipv6hdr *iph = ipv6_hdr(skb);
 
 		read_lock_bh(&l2tp_ip6_lock);
-		sk = __l2tp_ip6_bind_lookup(net, &iph->daddr, inet6_iif(skb),
-					    tunnel_id);
+		sk = __l2tp_ip6_bind_lookup(net, &iph->daddr, &iph->saddr,
+					    inet6_iif(skb), tunnel_id);
 		if (!sk) {
 			read_unlock_bh(&l2tp_ip6_lock);
 			goto discard;
@@ -330,7 +322,7 @@ static int l2tp_ip6_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	rcu_read_unlock();
 
 	write_lock_bh(&l2tp_ip6_lock);
-	if (__l2tp_ip6_bind_lookup(net, &addr->l2tp_addr, bound_dev_if,
+	if (__l2tp_ip6_bind_lookup(net, &addr->l2tp_addr, NULL, bound_dev_if,
 				   addr->l2tp_conn_id)) {
 		write_unlock_bh(&l2tp_ip6_lock);
 		err = -EADDRINUSE;
-- 
2.11.0
