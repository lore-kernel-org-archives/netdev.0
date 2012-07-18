From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: fix inet6_csk_xmit()
Date: Wed, 18 Jul 2012 09:38:04 +0200
Message-ID: <1342597084.2626.1851.camel@edumazet-glaptop>
References: <20120717.061418.1893307699868826531.davem@davemloft.net>
	 <20120717.110314.1984735460095688066.davem@davemloft.net>
	 <1342587513.2626.1518.camel@edumazet-glaptop>
	 <1342595099.2626.1774.camel@edumazet-glaptop>
	 <1342596218.2626.1813.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:39311 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230Ab2GRHiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 03:38:18 -0400
Received: by vbbff1 with SMTP id ff1so878064vbb.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 00:38:17 -0700 (PDT)
In-Reply-To: <1342596218.2626.1813.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We should provide to inet6_csk_route_socket a struct flowi6 pointer,
so that net6_csk_xmit() works correctly instead of sending garbage.

Also add some consts 

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Yuchung Cheng <ycheng@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 include/linux/ipv6.h             |    4 +-
 include/net/ip6_route.h          |    3 +-
 net/ipv6/inet6_connection_sock.c |   40 +++++++++++++++--------------
 3 files changed, 25 insertions(+), 22 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index bc6c8fd..379e433 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -299,9 +299,9 @@ struct ipv6_pinfo {
 	struct in6_addr 	rcv_saddr;
 	struct in6_addr		daddr;
 	struct in6_pktinfo	sticky_pktinfo;
-	struct in6_addr		*daddr_cache;
+	const struct in6_addr		*daddr_cache;
 #ifdef CONFIG_IPV6_SUBTREES
-	struct in6_addr		*saddr_cache;
+	const struct in6_addr		*saddr_cache;
 #endif
 
 	__be32			flow_label;
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index b6b6f7d..5fa2af0 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -158,7 +158,8 @@ extern void rt6_remove_prefsrc(struct inet6_ifaddr *ifp);
  *	Store a destination cache entry in a socket
  */
 static inline void __ip6_dst_store(struct sock *sk, struct dst_entry *dst,
-				   struct in6_addr *daddr, struct in6_addr *saddr)
+				   const struct in6_addr *daddr,
+				   const struct in6_addr *saddr)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct rt6_info *rt = (struct rt6_info *) dst;
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 4a0c4d2..0251a60 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -171,7 +171,8 @@ EXPORT_SYMBOL_GPL(inet6_csk_addr2sockaddr);
 
 static inline
 void __inet6_csk_dst_store(struct sock *sk, struct dst_entry *dst,
-			   struct in6_addr *daddr, struct in6_addr *saddr)
+			   const struct in6_addr *daddr,
+			   const struct in6_addr *saddr)
 {
 	__ip6_dst_store(sk, dst, daddr, saddr);
 
@@ -203,31 +204,31 @@ struct dst_entry *__inet6_csk_dst_check(struct sock *sk, u32 cookie)
 	return dst;
 }
 
-static struct dst_entry *inet6_csk_route_socket(struct sock *sk)
+static struct dst_entry *inet6_csk_route_socket(struct sock *sk,
+						struct flowi6 *fl6)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_addr *final_p, final;
 	struct dst_entry *dst;
-	struct flowi6 fl6;
 
-	memset(&fl6, 0, sizeof(fl6));
-	fl6.flowi6_proto = sk->sk_protocol;
-	fl6.daddr = np->daddr;
-	fl6.saddr = np->saddr;
-	fl6.flowlabel = np->flow_label;
-	IP6_ECN_flow_xmit(sk, fl6.flowlabel);
-	fl6.flowi6_oif = sk->sk_bound_dev_if;
-	fl6.flowi6_mark = sk->sk_mark;
-	fl6.fl6_sport = inet->inet_sport;
-	fl6.fl6_dport = inet->inet_dport;
-	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
+	memset(fl6, 0, sizeof(*fl6));
+	fl6->flowi6_proto = sk->sk_protocol;
+	fl6->daddr = np->daddr;
+	fl6->saddr = np->saddr;
+	fl6->flowlabel = np->flow_label;
+	IP6_ECN_flow_xmit(sk, fl6->flowlabel);
+	fl6->flowi6_oif = sk->sk_bound_dev_if;
+	fl6->flowi6_mark = sk->sk_mark;
+	fl6->fl6_sport = inet->inet_sport;
+	fl6->fl6_dport = inet->inet_dport;
+	security_sk_classify_flow(sk, flowi6_to_flowi(fl6));
 
-	final_p = fl6_update_dst(&fl6, np->opt, &final);
+	final_p = fl6_update_dst(fl6, np->opt, &final);
 
 	dst = __inet6_csk_dst_check(sk, np->dst_cookie);
 	if (!dst) {
-		dst = ip6_dst_lookup_flow(sk, &fl6, final_p, false);
+		dst = ip6_dst_lookup_flow(sk, fl6, final_p, false);
 
 		if (!IS_ERR(dst))
 			__inet6_csk_dst_store(sk, dst, NULL, NULL);
@@ -243,7 +244,7 @@ int inet6_csk_xmit(struct sk_buff *skb, struct flowi *fl_unused)
 	struct dst_entry *dst;
 	int res;
 
-	dst = inet6_csk_route_socket(sk);
+	dst = inet6_csk_route_socket(sk, &fl6);
 	if (IS_ERR(dst)) {
 		sk->sk_err_soft = -PTR_ERR(dst);
 		sk->sk_route_caps = 0;
@@ -265,12 +266,13 @@ EXPORT_SYMBOL_GPL(inet6_csk_xmit);
 
 struct dst_entry *inet6_csk_update_pmtu(struct sock *sk, u32 mtu)
 {
-	struct dst_entry *dst = inet6_csk_route_socket(sk);
+	struct flowi6 fl6;
+	struct dst_entry *dst = inet6_csk_route_socket(sk, &fl6);
 
 	if (IS_ERR(dst))
 		return NULL;
 	dst->ops->update_pmtu(dst, sk, NULL, mtu);
 
-	return inet6_csk_route_socket(sk);
+	return inet6_csk_route_socket(sk, &fl6);
 }
 EXPORT_SYMBOL_GPL(inet6_csk_update_pmtu);
